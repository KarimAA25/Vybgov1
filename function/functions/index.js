/**
 * Firebase function to assign ride to nearest driver or cancel if no one accepts.
 */

const {
    onDocumentWritten
} = require("firebase-functions/v2/firestore");
const {
    initializeApp
} = require("firebase-admin/app");
const {
    getFirestore,
    Timestamp,
    FieldValue
} = require("firebase-admin/firestore");
const {
    getMessaging
} = require("firebase-admin/messaging");
const {
    v4: uuidv4
} = require("uuid");

initializeApp();
const db = getFirestore();

exports.cancelledRide = onDocumentWritten({
    document: "bookings/{bookingId}"
}, async (event) => {
    const beforeData = event.data.before.exists ? event.data.before.data() : null;
    const afterData = event.data.after.exists ? event.data.after.data() : null;
    const bookingId = event.params.bookingId;

    if (!afterData || !["booking_placed", "booking_rejected"].includes(afterData.bookingStatus)) return null;
    if (beforeData && beforeData.bookingStatus === afterData.bookingStatus) return null;

    const vehicleTypeId = afterData.vehicleType?.id;
    const rejectedDriverIds = afterData.rejectedDriverId || [];
    const pickupLocation = afterData?.pickUpLocation;

    if (!pickupLocation?.latitude || !pickupLocation?.longitude) {
        console.error("Invalid Pickup Location", pickupLocation);
        return null;
    }

    const bookingZone = await findZoneForBooking(pickupLocation);
    if (!bookingZone) {
        console.error("❌ Booking does not fall inside any active zone!");
        // await cancelBooking(afterData, bookingId, "No Zone Found for Pickup Location");
        return null;
    }

    console.log(`🗺️ Booking belongs to Zone: ${bookingZone.id} (${bookingZone.name || "Unnamed"})`);

    const nearestDrivers = await getNearestAvailableDrivers(pickupLocation, rejectedDriverIds, vehicleTypeId, bookingZone.id, !!afterData.isOnlyForFemale);
    const settingData = await db.collection("settings").doc("constant").get();
    const orderSeconds = parseInt(settingData.data()?.secondsForRideCancel, 10) || 60;

    if (nearestDrivers.length === 0) {
        console.log("No nearby drivers found for Ride:", bookingId);
        setTimeout(async () => {
            const bookingDoc = await db.collection("bookings").doc(bookingId).get();
            const bookingData = bookingDoc.data();
            if (bookingData && ["booking_placed", "booking_rejected"].includes(bookingData.bookingStatus)) {
                console.log(`Cancelling ride ${bookingId} after timeout due to no drivers.`);
                await cancelBooking(bookingData, bookingId, "No Nearest Driver Available");
            }
        }, orderSeconds * 1000);
        return null;
    }

    for (let driver of nearestDrivers) {
        if (driver.isActive !== false && driver.isOnline !== false && driver.isVerified !== false) {
            console.log(`🚖 Assigning booking ${bookingId} to driver ${driver.id} (${driver.fullName || "Unknown"})`);

            await assignOrderToDriver(bookingId, driver.id);

            await sendNotification(driver.fcmToken, "New Ride Request", "A customer has placed a ride in your area. Accept now!", true);

            await saveNotification({
                type: "order",
                title: "New Ride Request",
                description: "A customer has placed a ride in your area. Accept now!",
                bookingId: bookingId,
                driverId: driver.id,
                senderId: afterData.customerId,
            });

            const settingData = await db.collection("settings").doc("constant").get();
            const orderSeconds = parseInt(settingData.data()?.secondsForRideCancel, 10) || 60;

            setTimeout(async () => {
                const updatedOrder = (await db.collection("bookings").doc(afterData.id).get()).data();
                if (updatedOrder.bookingStatus === "driver_assigned") {
                    await db
                        .collection("bookings")
                        .doc(afterData.id)
                        .update({
                            rejectedDriverId: FieldValue.arrayUnion(driver.id),
                        });

                    await db.collection("drivers").doc(driver.id).update({
                        bookingId: "",
                        status: "free",
                    });

                    console.log(`${driver.fullName || driver.id} marked free. Reassigning...`);
                    await reassignOrCancelOrder(afterData.id);
                }
            }, orderSeconds * 1000);

            return null;
        }
    }

    return null;
});

async function getNearestAvailableDrivers(pickupLocation, rejectedDriverIds, vehicleTypeId, zoneId, isOnlyForFemale = false) {
    console.log(`🔍 Searching drivers in Zone: ${zoneId}`);
    console.log(`🎯 Female-only booking: ${isOnlyForFemale}`);
    const snapshot = await db.collection("drivers").where("isOnline", "==", true).where("status", "==", "free").where("zoneId", "array-contains", zoneId).get();

    console.log(`👨‍✈️ Found ${snapshot.size} drivers in zone ${zoneId}`);

    const settings = await db.collection("settings").doc("globalValue").get();
    const driverRadius = parseFloat(settings.data()?.radius || 100);

    const drivers = snapshot.docs
        .map((doc) => {
            const data = doc.data();
            const driverLocation = data.location;
            const driverVehicleTypeId = data.driverVehicleDetails?.vehicleTypeId;

            // Skip if no valid location
            if (!driverLocation?.latitude || !driverLocation?.longitude) {
                console.log(`⛔ Skipping driver ${doc.id} - Invalid location`);
                return null;
            }

            // Skip if vehicle type doesn’t match
            if (driverVehicleTypeId !== vehicleTypeId) {
                console.log(`⛔ Skipping driver ${doc.id} - Vehicle type mismatch (${driverVehicleTypeId} != ${vehicleTypeId})`);
                return null;
            }


            if (isOnlyForFemale) {
                const gender = (data.gender || "").toString().trim().toLowerCase();
                if (gender !== "female") {
                    console.log(`🚫 Skipped ${doc.id} — not female (gender: ${data.gender}).`);
                    return null;
                } else {
                    console.log(`💁‍♀️ Accepted ${doc.id} — female driver.`);
                }
            }

            const distance = calculateDistance(pickupLocation, driverLocation);
            // Skip if out of allowed radius
            if (distance > driverRadius) {
                console.log(`⛔ Skipping driver ${doc.id} - Too far (${distance.toFixed(2)} km > ${driverRadius} km)`);
                return null;
            }

            console.log(`➡️ Driver ${doc.id} (${data.fullName || "Unknown"}) | Distance: ${distance.toFixed(2)} km`);

            return {
                ...data,
                id: doc.id,
                distance,
            };
        })
        .filter((driver) => driver !== null && !rejectedDriverIds.includes(driver.id));

    console.log(`✅ Eligible Drivers after filter: ${drivers.length}`);

    return drivers.sort((a, b) => a.distance - b.distance);
}

async function getAllZones() {
    try {
        const snapshot = await db.collection("zones").where("status", "==", true).get();

        console.log(`🗺️ Active zones fetched: ${snapshot.size}`);

        const zones = snapshot.docs.map((doc) => ({
            id: doc.id,
            ...doc.data(),
        }));
        return zones;
    } catch (e) {
        console.error("❌ Error Fetching Zones:", e);
        return [];
    }
}

async function findZoneForBooking(pickupLocation) {
    const zones = await getAllZones();

    for (let zone of zones) {
        if (isPointInPolygon(pickupLocation, zone.area)) {
            return zone;
        }
    }
    return null;
}

function isPointInPolygon(point, polygon) {
    let inside = false;
    for (let i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
        const xi = polygon[i].latitude,
            yi = polygon[i].longitude;
        const xj = polygon[j].latitude,
            yj = polygon[j].longitude;

        const intersect = yi > point.longitude !== yj > point.longitude && point.latitude < ((xj - xi) * (point.longitude - yi)) / (yj - yi) + xi;
        if (intersect) inside = !inside;
    }
    return inside;
}

async function assignOrderToDriver(bookingId, driverId) {
    await db.collection("bookings").doc(bookingId).update({
        driverId,
        bookingStatus: "driver_assigned",
        assignedAt: FieldValue.serverTimestamp(),
    });

    await db.collection("drivers").doc(driverId).update({
        status: "busy",
        bookingId,
    });
}

async function reassignOrCancelOrder(bookingId) {
    const bookingRef = db.collection("bookings").doc(bookingId);
    const bookingDetails = (await bookingRef.get()).data();

    const rejectedDriverIds = bookingDetails.rejectedDriverId || [];
    const bookingZone = await findZoneForBooking(bookingDetails.pickUpLocation);
    if (!bookingZone) {
        console.log(`❌ No zone found for booking ${bookingId}`);
        return;
    }
    const nearestDrivers = await getNearestAvailableDrivers(bookingDetails.pickUpLocation, rejectedDriverIds, bookingDetails.vehicleType?.id, bookingZone.id, !!bookingDetails.isOnlyForFemale);

    if (nearestDrivers.length === 0) {
        await cancelBooking(bookingDetails, bookingId, "No Nearest Driver Available");
        return;
    }

    for (let driver of nearestDrivers) {
        if (driver.isActive !== false && driver.isOnline !== false && driver.isVerified !== false) {
            console.log(`🚖 Assigning booking ${bookingId} to driver ${driver.id} (${driver.fullName || "Unknown"})`);
            await assignOrderToDriver(bookingDetails.id, driver.id);
            await sendNotification(driver.fcmToken, "New Ride Request", "A customer has placed a ride in your area. Accept now!", true);
            await saveNotification({
                type: "order",
                title: "New Ride Request",
                description: "A customer has placed a ride in your area. Accept now!",
                bookingId: bookingDetails.id,
                driverId: driver.id,
                senderId: bookingDetails.customerId,
            });

            const settingData = await db.collection("settings").doc("constant").get();
            const orderSeconds = parseInt(settingData.data()?.secondsForRideCancel, 10) || 60;

            setTimeout(async () => {
                const updatedOrder = (await db.collection("bookings").doc(bookingDetails.id).get()).data();
                if (updatedOrder.bookingStatus === "driver_assigned") {
                    await db
                        .collection("bookings")
                        .doc(bookingDetails.id)
                        .update({
                            rejectedDriverId: FieldValue.arrayUnion(driver.id),
                        });

                    await db.collection("drivers").doc(driver.id).update({
                        bookingId: "",
                        status: "free",
                    });

                    await reassignOrCancelOrder(bookingDetails.id);
                }
            }, orderSeconds * 1000);
            return;
        }
    }
}

async function cancelBooking(bookingDetails, bookingId, reason) {
    await db.collection("bookings").doc(bookingId).update({
        driverId: "",
        bookingStatus: "booking_cancelled",
        cancelledReason: reason,
    });

    if (bookingDetails.driverId) {
        await db.collection("drivers").doc(bookingDetails.driverId).update({
            bookingId: "",
            status: "free",
        });
    }

    if (bookingDetails.customerId !== null) {
        console.log(`Active Ride Id Become Null`);
        await db.collection("users").doc(bookingDetails.customerId).update({
            activeRideId: "",
        });
    }

    const userProfile = await getUserProfile(bookingDetails.customerId);
    if (userProfile?.fcmToken) {
        await sendNotification(userProfile.fcmToken, "Your Ride is Cancelled", `Your ride with #${bookingId.substring(0, 4)} has been cancelled because no driver accepted.`, false);

        await saveNotification({
            type: "order",
            title: "Your Ride is Cancelled",
            description: `Your ride with #${bookingId.substring(0, 4)} has been cancelled because no driver accepted.`,
            bookingId: bookingDetails.id,
            customerId: bookingDetails.customerId,
            senderId: "",
        });
    }
}

function calculateDistance(location1, location2) {
    const lat1 = location1.latitude;
    const lon1 = location1.longitude;
    const lat2 = location2.latitude;
    const lon2 = location2.longitude;

    const R = 6371;
    const dLat = ((lat2 - lat1) * Math.PI) / 180;
    const dLon = ((lon2 - lon1) * Math.PI) / 180;

    const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) + Math.cos((lat1 * Math.PI) / 180) * Math.cos((lat2 * Math.PI) / 180) * Math.sin(dLon / 2) * Math.sin(dLon / 2);

    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c;
}

async function getUserProfile(customerId) {
    try {
        const userProfile = await db.collection("users").doc(customerId).get();
        return userProfile.exists ? userProfile.data() : null;
    } catch (error) {
        console.error(`Error fetching profile for ${customerId}:`, error);
        return null;
    }
}

async function sendNotification(fcmToken, title, body, isNewBooking = false) {
    const message = {
        token: fcmToken,
        notification: {
            title: title,
            body: body,
        },
        android: {
            notification: {
                sound: isNewBooking ? "booking_notification" : "default",
                channelId: isNewBooking ? "booking_channel" : "default_channel", // must exist in Driver app
            },
        },
        'apns': {
            'headers': {
                'apns-priority': '10'
            },
            'payload': {
                'aps': {
                    'alert': {
                        'title': title,
                        'body': body
                    }, // Required for iOS display
                    'sound': isNewBooking ? 'booking_channel.wav' : 'default',
                    'content-available': 1, // Optional: for background updates
                },
            },
        },
        data: {
            isBooking: isNewBooking ? "true" : "false", // 👈 important
            type: "order",
        },
    };

    try {
        await getMessaging().send(message);
        console.log("Notification sent to Driver:", fcmToken);
    } catch (error) {
        console.error("Error sending Driver notification:", error);
    }
}

async function saveNotification({
    type,
    title,
    description,
    bookingId,
    driverId = null,
    customerId = null,
    senderId
}) {
    try {
        const notification = {
            id: uuidv4(),
            type,
            title,
            description,
            bookingId,
            driverId,
            customerId,
            senderId,
            createdAt: Timestamp.now(),
        };
        await db.collection("notification").doc(notification.id).set(notification);
        console.log("Notification saved for:", driverId || customerId);
    } catch (error) {
        console.error("Error saving notification:", error);
    }
}
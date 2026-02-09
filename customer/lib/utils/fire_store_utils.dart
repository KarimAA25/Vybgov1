// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/app/models/admin_commission.dart';
import 'package:customer/app/models/banner_model.dart';
import 'package:customer/app/models/booking_model.dart';
import 'package:customer/app/models/cancellation_charge_model.dart';
import 'package:customer/app/models/coupon_model.dart';
import 'package:customer/app/models/currencies_model.dart';
import 'package:customer/app/models/driver_user_model.dart';
import 'package:customer/app/models/emergency_number_model.dart';
import 'package:customer/app/models/loyalty_point_model.dart';
import 'package:customer/app/models/loyalty_point_transaction_model.dart';
import 'package:customer/app/models/night_timing_model.dart';
import 'package:customer/app/models/referral_model.dart';
import 'package:customer/app/models/rental_booking_model.dart';
import 'package:customer/app/models/rental_package_model.dart';
import 'package:customer/app/models/smtp_setting_model.dart';
import 'package:customer/app/models/sos_alerts_model.dart';
import 'package:customer/app/models/time_slots_charges_model.dart';
import 'package:customer/app/models/intercity_model.dart';
import 'package:customer/app/models/language_model.dart';
import 'package:customer/app/models/notification_model.dart';
import 'package:customer/app/models/parcel_model.dart';
import 'package:customer/app/models/payment_method_model.dart';
import 'package:customer/app/models/person_model.dart';
import 'package:customer/app/models/review_customer_model.dart';
import 'package:customer/app/models/support_reason_model.dart';
import 'package:customer/app/models/support_ticket_model.dart';
import 'package:customer/app/models/tax_model.dart';
import 'package:customer/app/models/transaction_log_model.dart';
import 'package:customer/app/models/user_model.dart';
import 'package:customer/app/models/vehicle_type_model.dart';
import 'package:customer/app/models/wallet_transaction_model.dart';
import 'package:customer/app/models/zone_model.dart';
import 'package:customer/constant/booking_status.dart';
import 'package:customer/constant/collection_name.dart';
import 'package:customer/constant/constant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';

import '../app/models/onboarding_model.dart';

class FireStoreUtils {
  static FirebaseFirestore fireStore = FirebaseFirestore.instance;

  static String getCurrentUid() => FirebaseAuth.instance.currentUser!.uid;

  static Future<bool> isLogin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    return await userExistOrNot(user.uid);
  }

  static Future<bool> userExistOrNot(String uid) async {
    try {
      final doc = await fireStore.collection(CollectionName.users).doc(uid).get();
      return doc.exists;
    } catch (e) {
      log("Failed to check user exist: $e");
      return false;
    }
  }

  static Future<bool> addSharingPerson(PersonModel personModel) async {
    try {
      await fireStore.collection(CollectionName.users).doc(getCurrentUid()).collection('sharing_persons').doc(personModel.id).set(personModel.toJson());
      return true;
    } catch (e) {
      log("Failed to add sharing person: $e");
      return false;
    }
  }

  static Future<Map<String, List<TimeSlotsChargesModel>>> fetchIntercityService() async {
    try {
      Map<String, List<TimeSlotsChargesModel>> documentLists = {
        "parcel": [],
        "intercity_sharing": [],
        "intercity": [],
        "cab": [],
        "rental": [],
      };

      for (String docName in documentLists.keys) {
        DocumentSnapshot doc = await fireStore.collection("intercity_service").doc(docName).get();

        if (doc.exists) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

          if (docName == "cab") {
            Constant.isCabAvailable = data["isAvailable"] ?? false;
            log("Cab availability: ${Constant.isCabAvailable}");
            continue;
          }

          if (docName == "rental") {
            Constant.isRentalAvailable = data["isAvailable"] ?? false;
            log("Rental availability: ${Constant.isRentalAvailable}");
            continue;
          }

          TimeSlotsChargesModel model = TimeSlotsChargesModel.fromJson(docName, data);

          if (docName == 'parcel') {
            Constant.isParcelBid = model.isBidEnable;
          } else if (docName == 'intercity_sharing') {
            Constant.isInterCitySharingBid = model.isBidEnable;
          } else if (docName == 'intercity') {
            Constant.isInterCityBid = model.isBidEnable;
          }
          documentLists[docName]!.add(model);
        }
      }

      return documentLists;
    } catch (e, st) {
      log("Error fetching intercity services: $e");
      log("Stacktrace: $st");
      return {
        "parcel": [],
        "intercity_sharing": [],
        "intercity": [],
        "cab": [],
      };
    }
  }

  static Future<List<VehicleTypeModel>> fetchAllCabServices() async {
    try {
      final vehicleTypeTimeSlotList = <VehicleTypeModel>[];
      final value = await fireStore.collection(CollectionName.vehicleType).where("isActive", isEqualTo: true).get();
      for (var element in value.docs) {
        vehicleTypeTimeSlotList.add(VehicleTypeModel.fromJson(element.data()));
      }
      return vehicleTypeTimeSlotList;
    } catch (e) {
      log("Error fetching all cab services: $e");
      return [];
    }
  }

  static StreamSubscription getSharingPersonsList(Function(List<PersonModel>) onUpdate) {
    return fireStore.collection(CollectionName.users).doc(getCurrentUid()).collection('sharing_persons').snapshots().listen((querySnapshot) {
      final updatedList = querySnapshot.docs.map((doc) => PersonModel.fromJson(doc.data())).toList();
      onUpdate(updatedList);
    }, onError: (error) {
      log("Error fetching sharing persons: $error");
      onUpdate([]);
    });
  }

  static Future<bool> deleteSharingPerson(String personId) async {
    try {
      await fireStore.collection(CollectionName.users).doc(getCurrentUid()).collection('sharing_persons').doc(personId).delete();
      return true;
    } catch (e) {
      log("Failed to delete sharing person: $e");
      return false;
    }
  }

  static Future<bool> updateUser(UserModel userModel) async {
    bool isUpdate = false;
    await fireStore.collection(CollectionName.users).doc(userModel.id).set(userModel.toJson()).whenComplete(() {
      isUpdate = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isUpdate = false;
    });
    return isUpdate;
  }

  static Future<List<VehicleTypeModel>> getVehicleType() async {
    final vehicleTypeList = <VehicleTypeModel>[];
    try {
      final value = await fireStore.collection(CollectionName.vehicleType).where("isActive", isEqualTo: true).get();
      log("Length : ${value.docs.length}");
      for (var element in value.docs) {
        vehicleTypeList.add(VehicleTypeModel.fromJson(element.data()));
      }
    } catch (e) {
      log(e.toString());
    }
    return vehicleTypeList;
  }

  static Future<bool?> setTransactionLog(TransactionLogModel transactionLogModel) async {
    bool isAdded = false;
    await fireStore.collection(CollectionName.transactionLog).doc(transactionLogModel.id).set(transactionLogModel.toJson()).then((value) {
      isAdded = true;
    }).catchError((error) {
      log("Failed to update transaction log: $error");
      isAdded = false;
    });
    return isAdded;
  }

  static Future<UserModel?> getUserProfile(String uuid) async {
    UserModel? userModel;
    await fireStore.collection(CollectionName.users).doc(uuid).get().then((value) {
      if (value.exists) {
        userModel = UserModel.fromJson(value.data()!);
        Constant.userModel = userModel;
      }
    }).catchError((error) {
      log("Failed to update user: $error");
      userModel = null;
    });
    return userModel;
  }

  static Future<bool?> updateUserWallet({required String amount}) async {
    bool isAdded = false;
    await getUserProfile(FireStoreUtils.getCurrentUid()).then((value) async {
      if (value != null) {
        UserModel userModel = value;
        userModel.walletAmount = (double.parse(userModel.walletAmount.toString()) + double.parse(amount)).toString();
        await FireStoreUtils.updateUser(userModel).then((value) {
          isAdded = value;
        });
      }
    });
    return isAdded;
  }

  static Future<bool?> updateOtherUserWallet({required String amount, required String id}) async {
    bool isAdded = false;
    await getDriverUserProfile(id).then((value) async {
      if (value != null) {
        DriverUserModel driverUserModel = value;
        driverUserModel.walletAmount = (double.parse(driverUserModel.walletAmount.toString()) + double.parse(amount)).toStringAsFixed(2).toString();
        driverUserModel.totalEarning = (double.parse(driverUserModel.totalEarning.toString()) + double.parse(amount)).toStringAsFixed(2).toString();
        await FireStoreUtils.updateDriverUser(driverUserModel).then((value) {
          isAdded = value;
        });
      }
    }).catchError((error) {
      log('error in update user wallet : $error');
    });
    return isAdded;
  }

  static Future<List<DriverUserModel>> getAllDriver() async {
    final vehicleTypeList = <DriverUserModel>[];
    try {
      final value = await fireStore.collection(CollectionName.drivers).get();
      log("Length : ${value.docs.length}");
      for (var element in value.docs) {
        vehicleTypeList.add(DriverUserModel.fromJson(element.data()));
      }
    } catch (e) {
      log(e.toString());
    }
    return vehicleTypeList;
  }

  Future<CurrencyModel?> getCurrency() async {
    CurrencyModel? currencyModel;
    await fireStore.collection(CollectionName.currency).where("active", isEqualTo: true).get().then((value) {
      if (value.docs.isNotEmpty) {
        currencyModel = CurrencyModel.fromJson(value.docs.first.data());
      }
    });
    return currencyModel;
  }

  Future<void> getSettings() async {
    await fireStore.collection(CollectionName.settings).doc("constant").get().then((value) {
      if (value.exists) {
        Constant.senderId = value.data()!["notification_senderId"];
        Constant.jsonFileURL = value.data()!["jsonFileURL"];
        Constant.minimumAmountToWithdrawal = value.data()!["minimum_amount_withdraw"];
        Constant.minimumAmountToDeposit = value.data()!["minimum_amount_deposit"];
        Constant.appName = value.data()!["appName"];
        Constant.appColor = value.data()!["appColor"];
        Constant.aboutApp = value.data()!["aboutApp"];
        Constant.isOtpFeatureEnable = value.data()!["isOTPEnable"] ?? true;
        Constant.isHomeFeatureEnable = value.data()!["isHomeFeatureEnable"] ?? true;
        Constant.referralAmount = value.data()!["referral_Amount"];
        Constant.countryCode = value.data()!["countryCode"];
        Constant.sosAlertNumber = value.data()!["sosNumber"];
        if (value.data()!["loyaltyProgram"] != null) {
          Constant.loyaltyPoint = LoyaltyPointModel.fromJson(
            Map<String, dynamic>.from(value.data()!["loyaltyProgram"]),
          );
        }
        final mapSettings = value.data()!["mapSettings"] as Map<String, dynamic>?;

        if (mapSettings != null) {
          // Constant.mapAPIKey = "AIzaSyB5_ImjYNXF0qVNe1A9Nrn0OTYhu_gcvaM";
          Constant.mapAPIKey = mapSettings["googleMapKey"] ?? "";
          Constant.selectedMap = mapSettings["mapType"] ?? "Google Map";
        }
      }
    });
    await fireStore.collection(CollectionName.settings).doc("globalValue").get().then((value) {
      if (value.exists) {
        Constant.distanceType = value.data()!["distanceType"];
        Constant.driverLocationUpdate = value.data()!["driverLocationUpdate"];
        Constant.radius = value.data()!["radius"];
        if (value.data()!["nightTime"] != null) {
          Constant.nightTimingModel = NightTimingModel.fromJson(
            Map<String, dynamic>.from(value.data()!["nightTime"]),
          );
        }
      }
    });
    await fireStore.collection(CollectionName.settings).doc("canceling_reason").get().then((value) {
      if (value.exists) {
        Constant.cancellationReason = value.data()!["reasons"];
      }
    });

    await fireStore.collection(CollectionName.settings).doc("admin_commission").get().then((value) {
      AdminCommission adminCommission = AdminCommission.fromJson(value.data()!);
      if (adminCommission.active == true) {
        Constant.adminCommission = adminCommission;
      }
    });

    await fireStore.collection(CollectionName.settings).doc("ride_cancellation_charge").get().then((value) {
      CancellationChargeModel cancellationCharge = CancellationChargeModel.fromJson(value.data()!);
      if (cancellationCharge.active == true) {
        Constant.cancellationCharge = cancellationCharge;
      }
    });

    await fireStore.collection(CollectionName.settings).doc("privacy_policy").get().then((value) {
      if (value.exists) {
        Constant.privacyPolicy = value.data()?["privacy_policy_customer"] ?? "";
      }
    });

    await fireStore.collection(CollectionName.settings).doc("terms_and_Conditions").get().then((value) {
      if (value.exists) {
        Constant.termsAndConditions = value.data()?["terms_and_Conditions_customer"] ?? "";
      }
    });
  }

  Future<PaymentModel?> getPayment() async {
    PaymentModel? paymentModel;
    await fireStore.collection(CollectionName.settings).doc("payment").get().then((value) {
      paymentModel = PaymentModel.fromJson(value.data()!);
      Constant.paymentModel = PaymentModel.fromJson(value.data()!);
    });
    return paymentModel;
  }

  Future<List<TaxModel>?> getTaxList() async {
    List<TaxModel> taxList = [];

    await fireStore.collection(CollectionName.countryTax).where('country', isEqualTo: Constant.country).where('active', isEqualTo: true).get().then((value) {
      for (var element in value.docs) {
        TaxModel taxModel = TaxModel.fromJson(element.data());
        taxList.add(taxModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return taxList;
  }

  static Future<List<CouponModel>?> getCoupon() async {
    List<CouponModel> couponList = [];
    await fireStore
        .collection(CollectionName.coupon)
        .where("active", isEqualTo: true)
        .where("isPrivate", isEqualTo: false)
        .where('expireAt', isGreaterThanOrEqualTo: Timestamp.now())
        .get()
        .then((value) {
      for (var element in value.docs) {
        CouponModel couponModel = CouponModel.fromJson(element.data());
        couponList.add(couponModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return couponList;
  }

  static Future<bool?> setBooking(BookingModel bookingModel) async {
    bool isAdded = false;
    await fireStore.collection(CollectionName.bookings).doc(bookingModel.id).set(bookingModel.toJson()).then((value) {
      isAdded = true;
    }).catchError((error) {
      log("Failed to add ride: $error");
      isAdded = false;
    });
    return isAdded;
  }

  static Future<bool?> setInterCityBooking(IntercityModel bookingModel) async {
    bool isAdded = false;
    await fireStore.collection(CollectionName.interCityRide).doc(bookingModel.id).set(bookingModel.toJson()).then((value) {
      isAdded = true;
    }).catchError((error) {
      log("Failed to add ride: $error");
      isAdded = false;
    });
    return isAdded;
  }

  static Future<bool?> setInterCity(IntercityModel intercityRideModel) async {
    bool isAdded = false;
    await fireStore.collection(CollectionName.interCityRide).doc(intercityRideModel.id).set(intercityRideModel.toJson()).then((value) {
      isAdded = true;
    }).catchError((error) {
      log("Failed to add inter city : $error");
      isAdded = false;
    });
    return isAdded;
  }

  static Future<bool?> setRentalRide(RentalBookingModel rentalModel) async {
    try {
      await fireStore.collection(CollectionName.rentalRide).doc(rentalModel.id).set(rentalModel.toJson());
      return true;
    } catch (error) {
      log("Failed to add rental ride: $error");
      return false;
    }
  }

  StreamController<List<DriverUserModel>>? getNearestDriverController;

  Future<List<DriverUserModel>> sendOrderData(RentalBookingModel bookingModel) async {
    // Close previous stream if open
    await getNearestDriverController?.close();
    getNearestDriverController = StreamController<List<DriverUserModel>>.broadcast();

    final List<DriverUserModel> ordersList = [];
    // final Set<String> driverIdSet = {};

    try {
      final Query query =
          fireStore.collection(CollectionName.drivers).where('driverVehicleDetails.vehicleTypeId', isEqualTo: bookingModel.vehicleType?.id).where('isOnline', isEqualTo: true);

      final GeoFirePoint center = GeoFlutterFire().point(
        latitude: bookingModel.pickUpLocation?.latitude ?? 0.0,
        longitude: bookingModel.pickUpLocation?.longitude ?? 0.0,
      );

      final Stream<List<DocumentSnapshot>> stream = GeoFlutterFire().collection(collectionRef: query).within(
            center: center,
            radius: double.parse(Constant.radius),
            field: 'position',
            strictMode: true,
          );

      stream.listen((documentList) async {
        if (getNearestDriverController?.isClosed ?? true) return;

        ordersList.clear();

        for (final doc in documentList) {
          final data = doc.data() as Map<String, dynamic>;
          final driver = DriverUserModel.fromJson(data);
          ordersList.add(driver);
        }

        getNearestDriverController?.sink.add(List<DriverUserModel>.from(ordersList));
      });
    } catch (e, stackTrace) {
      log("Error in sendOrderData: $e\n$stackTrace");
    }

    return ordersList;
  }

  void closeStream() {
    if (getNearestDriverController != null && !getNearestDriverController!.isClosed) {
      getNearestDriverController!.close();
      getNearestDriverController = null;
      log("==> Nearest driver stream closed.");
    }
  }

  StreamController<List<BookingModel>>? getHomeOngoingBookingController;

  Stream<List<BookingModel>> getHomeOngoingBookings() async* {
    // Close previous controller if open
    if (getHomeOngoingBookingController != null && !getHomeOngoingBookingController!.isClosed) {
      await getHomeOngoingBookingController!.close();
    }
    getHomeOngoingBookingController = StreamController<List<BookingModel>>.broadcast();
    final customerId = getCurrentUid();

    try {
      final stream = fireStore
          .collection(CollectionName.bookings)
          .where('bookingStatus', whereIn: [
            BookingStatus.bookingAccepted,
            BookingStatus.bookingPlaced,
            BookingStatus.bookingOngoing,
            BookingStatus.driverAssigned,
          ])
          .where("customerId", isEqualTo: customerId)
          .orderBy("createAt", descending: true)
          .snapshots();

      stream.listen((querySnapshot) {
        final bookingsList = querySnapshot.docs.map((doc) => BookingModel.fromJson(doc.data())).toList();
        getHomeOngoingBookingController?.sink.add(bookingsList);
      }, onError: (error) {
        log("Error fetching ongoing bookings: $error");
        getHomeOngoingBookingController?.sink.add([]);
      });
    } catch (e) {
      log("Exception in getHomeOngoingBookings: $e");
      getHomeOngoingBookingController?.sink.add([]);
    }

    yield* getHomeOngoingBookingController!.stream;
  }

  void closeHomeOngoingStream() {
    if (getHomeOngoingBookingController != null && !getHomeOngoingBookingController!.isClosed) {
      getHomeOngoingBookingController!.close();
      getHomeOngoingBookingController = null;
    }
  }

  StreamController<BookingModel>? getBookingStatusController;

  Stream<BookingModel> getBookingStatusData(String bookingId) async* {
    // Close previous controller if open
    if (getBookingStatusController != null && !getBookingStatusController!.isClosed) {
      await getBookingStatusController!.close();
    }
    getBookingStatusController = StreamController<BookingModel>.broadcast();

    try {
      final stream = fireStore.collection(CollectionName.bookings).where('id', isEqualTo: bookingId).snapshots();

      stream.listen((querySnapshot) {
        for (var document in querySnapshot.docs) {
          if (getBookingStatusController == null || getBookingStatusController!.isClosed) {
            return;
          }
          final data = document.data();
          final bookingModel = BookingModel.fromJson(data);
          getBookingStatusController?.sink.add(bookingModel);
        }
      }, onError: (error) {
        log("Error in getBookingStatusData: $error");
      });
    } catch (e) {
      log("Exception in getBookingStatusData: $e");
    }

    yield* getBookingStatusController!.stream;
  }

  void closeBookingStatusStream() {
    if (getBookingStatusController != null && !getBookingStatusController!.isClosed) {
      getBookingStatusController!.close();
      getBookingStatusController = null;
    }
  }

  static Future<BookingModel?> getRideDetails(String bookingId) async {
    try {
      final querySnapshot = await fireStore.collection(CollectionName.bookings).where("id", isEqualTo: bookingId).get();

      if (querySnapshot.docs.isNotEmpty) {
        return BookingModel.fromJson(querySnapshot.docs.first.data());
      }
    } catch (e) {
      log("Error in getRideDetails: $e");
    }
    return null;
  }

  static Stream<IntercityModel?> getInterCityRideDetails(String bookingId) {
    return fireStore.collection(CollectionName.interCityRide).where("id", isEqualTo: bookingId).snapshots().map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        return IntercityModel.fromJson(snapshot.docs.first.data());
      }
      return null;
    });
  }

  static Stream<ParcelModel?> getParcelRideDetails(String bookingId) {
    return fireStore.collection(CollectionName.parcelRide).where("id", isEqualTo: bookingId).snapshots().map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        return ParcelModel.fromJson(snapshot.docs.first.data());
      }
      return null;
    });
  }

  static void getOngoingRides(Function(List<BookingModel>) onUpdate) {
    final customerId = getCurrentUid();
    try {
      fireStore
          .collection(CollectionName.bookings)
          .where("customerId", isEqualTo: customerId)
          .where('bookingStatus', whereIn: [BookingStatus.bookingPlaced, BookingStatus.bookingAccepted, BookingStatus.bookingOngoing, BookingStatus.bookingOnHold])
          .orderBy("createAt", descending: true)
          .snapshots()
          .listen((querySnapshot) {
            final bookingList = querySnapshot.docs.map((doc) => BookingModel.fromJson(doc.data())).toList();
            onUpdate(bookingList);
          }, onError: (error) {
            log("Error fetching ongoing rides: $error");
            onUpdate([]);
          });
    } catch (e) {
      log("Exception in getOngoingRides: $e");
      onUpdate([]);
    }
  }

  static void getInterCityOngoingRides(Function(List<IntercityModel>) onUpdate) {
    final customerId = getCurrentUid();
    try {
      fireStore
          .collection(CollectionName.interCityRide)
          .where("customerId", isEqualTo: customerId)
          .where('bookingStatus', whereIn: [BookingStatus.bookingAccepted, BookingStatus.bookingOngoing, BookingStatus.bookingOnHold])
          .orderBy("createAt", descending: true)
          .snapshots()
          .listen((querySnapshot) {
            final bookingList = querySnapshot.docs.map((doc) => IntercityModel.fromJson(doc.data())).toList();
            onUpdate(bookingList);
          }, onError: (error) {
            log("Error fetching ongoing intercity rides: $error");
            onUpdate([]);
          });
    } catch (e) {
      log("Exception in getInterCityOngoingRides: $e");
      onUpdate([]);
    }
  }

  static void getInterCityCompletedRides(Function(List<IntercityModel>) onUpdate) {
    final customerId = getCurrentUid();
    try {
      fireStore
          .collection(CollectionName.interCityRide)
          .where("customerId", isEqualTo: customerId)
          .where('bookingStatus', isEqualTo: BookingStatus.bookingCompleted)
          .orderBy("createAt", descending: true)
          .snapshots()
          .listen((querySnapshot) {
        final updatedList = querySnapshot.docs.map((doc) => IntercityModel.fromJson(doc.data())).toList();
        onUpdate(updatedList);
      }, onError: (error) {
        log("Error fetching completed intercity rides: $error");
        onUpdate([]);
      });
    } catch (e) {
      log("Exception in getInterCityCompletedRides: $e");
      onUpdate([]);
    }
  }

  static void getInterCityActiveRides(Function(List<IntercityModel>) onUpdate) {
    final customerId = getCurrentUid();
    try {
      fireStore
          .collection(CollectionName.interCityRide)
          .where("customerId", isEqualTo: customerId)
          .where('bookingStatus', whereIn: [BookingStatus.bookingPlaced])
          .orderBy("createAt", descending: true)
          .snapshots()
          .listen((querySnapshot) {
            final bookingList = querySnapshot.docs.map((doc) => IntercityModel.fromJson(doc.data())).toList();
            onUpdate(bookingList);
          }, onError: (error) {
            log("Error fetching active intercity rides: $error");
            onUpdate([]);
          });
    } catch (e) {
      log("Exception in getInterCityActiveRides: $e");
      onUpdate([]);
    }
  }

  static void getInterCityRejectedRides(Function(List<IntercityModel>) onUpdate) {
    final customerId = getCurrentUid();
    try {
      fireStore
          .collection(CollectionName.interCityRide)
          .where("customerId", isEqualTo: customerId)
          .where('bookingStatus', whereIn: [BookingStatus.bookingCancelled, BookingStatus.bookingRejected])
          .orderBy("createAt", descending: true)
          .snapshots()
          .listen((querySnapshot) {
            final updatedList = querySnapshot.docs.map((doc) => IntercityModel.fromJson(doc.data())).toList();
            onUpdate(updatedList);
          }, onError: (error) {
            log("Error fetching rejected intercity rides: $error");
            onUpdate([]);
          });
    } catch (e) {
      log("Exception in getInterCityRejectedRides: $e");
      onUpdate([]);
    }
  }

  static void getParcelActiveRides(Function(List<ParcelModel>) onUpdate) {
    final customerId = getCurrentUid();
    try {
      fireStore
          .collection(CollectionName.parcelRide)
          .where("customerId", isEqualTo: customerId)
          .where('bookingStatus', whereIn: [BookingStatus.bookingPlaced])
          .orderBy("createAt", descending: true)
          .snapshots()
          .listen((querySnapshot) {
            final bookingList = querySnapshot.docs.map((doc) => ParcelModel.fromJson(doc.data())).toList();
            onUpdate(bookingList);
          }, onError: (error) {
            log("Error fetching active parcel rides: $error");
            onUpdate([]);
          });
    } catch (e) {
      log("Exception in getParcelActiveRides: $e");
      onUpdate([]);
    }
  }

  static void getParcelOngoingRides(Function(List<ParcelModel>) onUpdate) {
    final customerId = getCurrentUid();
    try {
      fireStore
          .collection(CollectionName.parcelRide)
          .where("customerId", isEqualTo: customerId)
          .where('bookingStatus', whereIn: [BookingStatus.bookingAccepted, BookingStatus.bookingOngoing])
          .orderBy("createAt", descending: true)
          .snapshots()
          .listen((querySnapshot) {
            final bookingList = querySnapshot.docs.map((doc) => ParcelModel.fromJson(doc.data())).toList();
            onUpdate(bookingList);
          }, onError: (error) {
            log("Error fetching ongoing parcel rides: $error");
            onUpdate([]);
          });
    } catch (e) {
      log("Exception in getParcelOngoingRides: $e");
      onUpdate([]);
    }
  }

  static void getParcelCompletedRides(Function(List<ParcelModel>) onUpdate) {
    final customerId = getCurrentUid();
    try {
      fireStore
          .collection(CollectionName.parcelRide)
          .where("customerId", isEqualTo: customerId)
          .where('bookingStatus', isEqualTo: BookingStatus.bookingCompleted)
          .orderBy("createAt", descending: true)
          .snapshots()
          .listen((querySnapshot) {
        final updatedList = querySnapshot.docs.map((doc) => ParcelModel.fromJson(doc.data())).toList();
        onUpdate(updatedList);
      }, onError: (error) {
        log("Error fetching completed parcel rides: $error");
        onUpdate([]);
      });
    } catch (e) {
      log("Exception in getParcelCompletedRides: $e");
      onUpdate([]);
    }
  }

  static void getParcelRejectedRides(Function(List<ParcelModel>) onUpdate) {
    final customerId = getCurrentUid();
    try {
      fireStore
          .collection(CollectionName.parcelRide)
          .where("customerId", isEqualTo: customerId)
          .where('bookingStatus', whereIn: [BookingStatus.bookingCancelled, BookingStatus.bookingRejected])
          .orderBy("createAt", descending: true)
          .snapshots()
          .listen((querySnapshot) {
            final updatedList = querySnapshot.docs.map((doc) => ParcelModel.fromJson(doc.data())).toList();
            onUpdate(updatedList);
          }, onError: (error) {
            log("Error fetching rejected parcel rides: $error");
            onUpdate([]);
          });
    } catch (e) {
      log("Exception in getParcelRejectedRides: $e");
      onUpdate([]);
    }
  }

  static Future<bool?> setParcelBooking(ParcelModel bookingModel) async {
    bool isAdded = false;
    try {
      await fireStore.collection(CollectionName.parcelRide).doc(bookingModel.id).set(bookingModel.toJson());
      isAdded = true;
    } catch (error) {
      log("Failed to add parcel ride: $error");
      isAdded = false;
    }
    return isAdded;
  }

  static void getCompletedRides(Function(List<BookingModel>) onUpdate) {
    final customerId = getCurrentUid();
    try {
      fireStore
          .collection(CollectionName.bookings)
          .where("customerId", isEqualTo: customerId)
          .where('bookingStatus', isEqualTo: BookingStatus.bookingCompleted)
          .orderBy("createAt", descending: true)
          .snapshots()
          .listen((querySnapshot) {
        final updatedList = querySnapshot.docs.map((doc) => BookingModel.fromJson(doc.data())).toList();
        onUpdate(updatedList);
      }, onError: (error) {
        log("Error fetching completed rides: $error");
        onUpdate([]);
      });
    } catch (e) {
      log("Exception in getCompletedRides: $e");
      onUpdate([]);
    }
  }

  static void getRejectedRides(Function(List<BookingModel>) onUpdate) {
    final customerId = getCurrentUid();
    try {
      fireStore
          .collection(CollectionName.bookings)
          .where("customerId", isEqualTo: customerId)
          .where('bookingStatus', whereIn: [BookingStatus.bookingCancelled, BookingStatus.bookingRejected])
          .orderBy("createAt", descending: true)
          .snapshots()
          .listen((querySnapshot) {
            final updatedList = querySnapshot.docs.map((doc) => BookingModel.fromJson(doc.data())).toList();
            onUpdate(updatedList);
          }, onError: (error) {
            log("Error fetching rejected rides: $error");
            onUpdate([]);
          });
    } catch (e) {
      log("Exception in getRejectedRides: $e");
      onUpdate([]);
    }
  }

  static Future<DriverUserModel?> getDriverUserProfile(String uuid) async {
    try {
      final value = await fireStore.collection(CollectionName.drivers).doc(uuid).get();
      if (value.exists) {
        return DriverUserModel.fromJson(value.data()!);
      }
    } catch (error) {
      log("Failed to get user: $error");
    }
    return null;
  }

  static Future<bool?> setWalletTransaction(WalletTransactionModel walletTransactionModel) async {
    bool isAdded = false;
    try {
      walletTransactionModel.id ??= Constant.getUuid();
      walletTransactionModel.userId ??= FireStoreUtils.getCurrentUid();
      walletTransactionModel.createdDate ??= Timestamp.now();
      await fireStore.collection(CollectionName.walletTransaction).doc(walletTransactionModel.id).set(walletTransactionModel.toJson());
      isAdded = true;
    } catch (error) {
      log("Failed to update user: $error");
      isAdded = false;
    }
    return isAdded;
  }

  static Future<List<WalletTransactionModel>?> getWalletTransaction() async {
    final walletTransactionModelList = <WalletTransactionModel>[];
    try {
      final value = await fireStore
          .collection(CollectionName.walletTransaction)
          .where('userId', isEqualTo: FireStoreUtils.getCurrentUid())
          .where('type', isEqualTo: "customer")
          .orderBy('createdDate', descending: true)
          .get();
      for (var element in value.docs) {
        walletTransactionModelList.add(WalletTransactionModel.fromJson(element.data()));
      }
    } catch (error) {
      log("Error fetching wallet transactions: $error");
    }
    return walletTransactionModelList;
  }

  static Future<ReviewModel?> getReview(String orderId) async {
    try {
      final doc = await fireStore.collection(CollectionName.review).doc(orderId).get();
      if (doc.data() != null) {
        return ReviewModel.fromJson(doc.data()!);
      }
    } catch (error) {
      log("Error getting review: $error");
    }
    return null;
  }

  static Future<bool?> setReview(ReviewModel reviewModel) async {
    try {
      await fireStore.collection(CollectionName.review).doc(reviewModel.id).set(reviewModel.toJson());
      return true;
    } catch (error) {
      log("Failed to set review: $error");
      return false;
    }
  }

  static Future<bool> updateDriverUser(DriverUserModel userModel) async {
    try {
      await fireStore.collection(CollectionName.drivers).doc(userModel.id).set(userModel.toJson());
      return true;
    } catch (error) {
      log("Failed to update driver user: $error");
      return false;
    }
  }

  static Future<List<NotificationModel>?> getNotificationList() async {
    final notificationList = <NotificationModel>[];
    try {
      final value =
          await fireStore.collection(CollectionName.notification).where('customerId', isEqualTo: FireStoreUtils.getCurrentUid()).orderBy('createdAt', descending: true).get();
      for (var element in value.docs) {
        notificationList.add(NotificationModel.fromJson(element.data()));
      }
    } catch (error) {
      log("Error fetching notifications: $error");
    }
    return notificationList;
  }

  static Future<bool?> setNotification(NotificationModel notificationModel) async {
    try {
      notificationModel.id ??= Constant.getUuid();
      notificationModel.customerId ??= FireStoreUtils.getCurrentUid();
      notificationModel.createdAt ??= Timestamp.now();
      await fireStore.collection(CollectionName.notification).doc(notificationModel.id).set(notificationModel.toJson());
      return true;
    } catch (error) {
      log("Failed to set notification: $error");
      return false;
    }
  }

  static Future<List<BannerModel>?> getBannerList() async {
    final bannerList = <BannerModel>[];
    try {
      final value = await fireStore.collection(CollectionName.banner).where("isEnable", isEqualTo: true).get();
      for (var element in value.docs) {
        bannerList.add(BannerModel.fromJson(element.data()));
      }
    } catch (error) {
      log("Error fetching banners: $error");
    }
    return bannerList;
  }

  static Future<List<LanguageModel>> getLanguage() async {
    final languageModelList = <LanguageModel>[];
    try {
      final snap = await FirebaseFirestore.instance.collection(CollectionName.languages).get();
      for (var document in snap.docs) {
        final data = document.data() as Map<String, dynamic>?;
        if (data != null) {
          languageModelList.add(LanguageModel.fromJson(data));
        } else {
          log('getLanguage is null');
        }
      }
    } catch (error) {
      log("Error fetching languages: $error");
    }
    return languageModelList;
  }

  static Future<List<SupportReasonModel>> getSupportReason() async {
    final supportReasonList = <SupportReasonModel>[];
    try {
      final value = await fireStore.collection(CollectionName.supportReason).where("type", isEqualTo: "customer").get();
      for (var element in value.docs) {
        supportReasonList.add(SupportReasonModel.fromJson(element.data()));
      }
    } catch (error) {
      log("Error fetching support reasons: $error");
    }
    return supportReasonList;
  }

  static Future<bool> addSupportTicket(SupportTicketModel supportTicketModel) async {
    try {
      supportTicketModel.id ??= Constant.getUuid();
      supportTicketModel.userId ??= FireStoreUtils.getCurrentUid();
      supportTicketModel.type ??= "customer";
      supportTicketModel.createAt ??= Timestamp.now();
      supportTicketModel.updateAt ??= Timestamp.now();
      await fireStore.collection(CollectionName.supportTicket).doc(supportTicketModel.id).set(supportTicketModel.toJson());
      return true;
    } catch (error) {
      log("Failed to add Support Ticket: $error");
      return false;
    }
  }

  static Future<List<SupportTicketModel>> getSupportTicket(String id) async {
    final supportTicketList = <SupportTicketModel>[];
    try {
      final value = await fireStore.collection(CollectionName.supportTicket).where("userId", isEqualTo: id).orderBy("createAt", descending: true).get();
      for (var element in value.docs) {
        supportTicketList.add(SupportTicketModel.fromJson(element.data()));
      }
    } catch (error) {
      log("Error fetching support tickets: $error");
    }
    return supportTicketList;
  }

  static Future<List<IntercityModel>> getDataForPdfInterCity(DateTimeRange? dateTimeRange) async {
    final interCityModelList = <IntercityModel>[];
    try {
      final querySnapshot = await fireStore
          .collection(CollectionName.interCityRide)
          .where("customerId", isEqualTo: getCurrentUid())
          .where('createAt', isGreaterThanOrEqualTo: dateTimeRange!.start, isLessThanOrEqualTo: dateTimeRange.end)
          .orderBy('createAt', descending: true)
          .get();
      for (var element in querySnapshot.docs) {
        interCityModelList.add(IntercityModel.fromJson(element.data()));
      }
    } catch (error) {
      log('Error in getDataForPdfInterCity: $error');
    }
    return interCityModelList;
  }

  static Future<List<BookingModel>> getDataForPdfCab(DateTimeRange? dateTimeRange) async {
    final cabModelList = <BookingModel>[];
    try {
      final querySnapshot = await fireStore
          .collection(CollectionName.bookings)
          .where("customerId", isEqualTo: getCurrentUid())
          .where('createAt', isGreaterThanOrEqualTo: dateTimeRange!.start, isLessThanOrEqualTo: dateTimeRange.end)
          .orderBy('createAt', descending: true)
          .get();
      for (var element in querySnapshot.docs) {
        cabModelList.add(BookingModel.fromJson(element.data()));
      }
    } catch (error) {
      log('Error in getDataForPdfCab: $error');
    }
    return cabModelList;
  }

  static Future<List<ParcelModel>> getDataForPdfParcel(DateTimeRange? dateTimeRange) async {
    final parcelList = <ParcelModel>[];
    try {
      final querySnapshot = await fireStore
          .collection(CollectionName.parcelRide)
          .where("customerId", isEqualTo: getCurrentUid())
          .where('createAt', isGreaterThanOrEqualTo: dateTimeRange!.start, isLessThanOrEqualTo: dateTimeRange.end)
          .orderBy('createAt', descending: true)
          .get();
      for (var element in querySnapshot.docs) {
        parcelList.add(ParcelModel.fromJson(element.data()));
      }
    } catch (error) {
      log('Error in getDataForPdfParcel: $error');
    }
    return parcelList;
  }

  static Future<bool> hasActiveRide() async {
    try {
      QuerySnapshot querySnapshot = await fireStore
          .collection(CollectionName.bookings)
          .where("customerId", isEqualTo: getCurrentUid())
          .where('bookingStatus', whereIn: [BookingStatus.bookingPlaced, BookingStatus.bookingAccepted, BookingStatus.bookingOngoing, BookingStatus.driverAssigned]).get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      log("Error checking for active ride: $e");
      return false;
    }
  }

  Future<List<RentalPackageModel>?> getRentalPackages(String vehicleId) async {
    List<RentalPackageModel> rentalPackageList = [];

    await fireStore.collection(CollectionName.rentalPackage).where("vehicleId", isEqualTo: vehicleId).get().then((value) {
      for (var element in value.docs) {
        RentalPackageModel rentalPackageModel = RentalPackageModel.fromJson(element.data());
        rentalPackageList.add(rentalPackageModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return rentalPackageList;
  }

  static void getRentalOngoingRides(Function(List<RentalBookingModel>) onUpdate) {
    try {
      fireStore
          .collection(CollectionName.rentalRide)
          .where("customerId", isEqualTo: FireStoreUtils.getCurrentUid())
          .where('bookingStatus', whereIn: [
            BookingStatus.bookingAccepted,
            BookingStatus.bookingOngoing,
          ])
          .orderBy("createAt", descending: true)
          .snapshots()
          .listen((querySnapshot) {
            final bookingList = querySnapshot.docs.map((doc) => RentalBookingModel.fromJson(doc.data())).toList();
            onUpdate(bookingList);
          }, onError: (error) {
            log("Error fetching ongoing Rental rides: $error");
            onUpdate([]);
          });
    } catch (e) {
      log("Exception in get ongoing Rental rides: $e");
      onUpdate([]);
    }
  }

  static void getRentalCompletedRides(Function(List<RentalBookingModel>) onUpdate) {
    try {
      fireStore
          .collection(CollectionName.rentalRide)
          .where("customerId", isEqualTo: FireStoreUtils.getCurrentUid())
          .where('bookingStatus', isEqualTo: BookingStatus.bookingCompleted)
          .orderBy("createAt", descending: true)
          .snapshots()
          .listen((querySnapshot) {
        final updatedList = querySnapshot.docs.map((doc) => RentalBookingModel.fromJson(doc.data())).toList();
        onUpdate(updatedList);
      }, onError: (error) {
        log("Error fetching completed Rental rides: $error");
        onUpdate([]);
      });
    } catch (e) {
      log("Exception in get completed Rental rides: $e");
      onUpdate([]);
    }
  }

  static void getRentalActiveRides(Function(List<RentalBookingModel>) onUpdate) {
    try {
      fireStore
          .collection(CollectionName.rentalRide)
          .where("customerId", isEqualTo: FireStoreUtils.getCurrentUid())
          .where('bookingStatus', whereIn: [BookingStatus.bookingPlaced])
          .orderBy("createAt", descending: true)
          .snapshots()
          .listen((querySnapshot) {
            final bookingList = querySnapshot.docs.map((doc) => RentalBookingModel.fromJson(doc.data())).toList();
            onUpdate(bookingList);
          }, onError: (error) {
            log("Error fetching active Rental rides: $error");
            onUpdate([]);
          });
    } catch (e) {
      log("Exception in get Rental Active Ride: $e");
      onUpdate([]);
    }
  }

  static void getRentalRejectedRides(Function(List<RentalBookingModel>) onUpdate) {
    try {
      fireStore
          .collection(CollectionName.rentalRide)
          .where("customerId", isEqualTo: FireStoreUtils.getCurrentUid())
          .where('bookingStatus', whereIn: [BookingStatus.bookingCancelled, BookingStatus.bookingRejected])
          .orderBy("createAt", descending: true)
          .snapshots()
          .listen((querySnapshot) {
            final updatedList = querySnapshot.docs.map((doc) => RentalBookingModel.fromJson(doc.data())).toList();
            onUpdate(updatedList);
          }, onError: (error) {
            log("Error fetching rejected Rental rides: $error");
            onUpdate([]);
          });
    } catch (e) {
      log("Exception in get Rental Rejected/Cancelled Ride: $e");
      onUpdate([]);
    }
  }

  static Future<List<OnBoardingModel>> getOnboarding() async {
    List<OnBoardingModel> onboardingList = [];
    try {
      await FirebaseFirestore.instance
          .collection(CollectionName.onBoarding)
          .where("status", isEqualTo: true)
          .where("type", isEqualTo: "customer")
          .orderBy("createdAt", descending: false)
          .get()
          .then((value) {
        for (var element in value.docs) {
          onboardingList.add(OnBoardingModel.fromJson(element.data()));
        }
      });
    } catch (error) {
      log(error.toString());
    }
    return onboardingList;
  }

  static Future<List<ZoneModel>?> getActiveZones() async {
    List<ZoneModel> zoneList = [];
    try {
      final snapshot = await fireStore.collection(CollectionName.zones).where("status", isEqualTo: true).get();
      for (var doc in snapshot.docs) {
        zoneList.add(ZoneModel.fromJson(doc.data()));
      }
    } catch (error) {
      log(error.toString());
    }
    return zoneList;
  }

  static Future<ReferralModel?> getReferral() async {
    ReferralModel? referralModel;
    await fireStore.collection(CollectionName.referral).doc(FireStoreUtils.getCurrentUid()).get().then((value) {
      if (value.exists) {
        referralModel = ReferralModel.fromJson(value.data()!);
      }
    }).catchError((error) {
      log("Failed to get Referral: $error");
      referralModel = null;
    });
    return referralModel;
  }

  static Future<ReferralModel?> getReferralUserByCode(String referralCode) async {
    ReferralModel? referralModel;
    try {
      await fireStore.collection(CollectionName.referral).where("referralCode", isEqualTo: referralCode).get().then((value) {
        referralModel = ReferralModel.fromJson(value.docs.first.data());
      });
    } catch (e, s) {
      log('FireStoreUtils.firebaseCreateNewUser $e $s');
      return null;
    }
    return referralModel;
  }

  static Future<String?> referralAdd(ReferralModel referral) async {
    try {
      await fireStore.collection(CollectionName.referral).doc(referral.userId).set(referral.toJson());
    } catch (e, s) {
      log('add referral error:  $e $s');
      return null;
    }
    return null;
  }

  static Future<bool?> checkReferralCodeValidOrNot(String referralCode) async {
    bool? isExit;
    try {
      await fireStore.collection(CollectionName.referral).where("referralCode", isEqualTo: referralCode).get().then((value) {
        if (value.size > 0) {
          isExit = true;
        } else {
          isExit = false;
        }
      });
    } catch (e, s) {
      log('FireStoreUtils.firebaseCreateNewUser $e $s');
      return false;
    }
    return isExit;
  }

  static Future<bool?> updateWalletForReferral({required String userId, required String amount, required role}) async {
    bool isAdded = false;
    String collection = role == Constant.typeCustomer ? CollectionName.users : CollectionName.drivers;

    final docSnapshot = await FirebaseFirestore.instance.collection(collection).doc(userId).get();
    if (docSnapshot.exists) {
      double currentWalletAmount = double.tryParse(docSnapshot.data()?['walletAmount']?.toString() ?? '0') ?? 0;
      double updatedWalletAmount = currentWalletAmount + double.parse(amount);

      await FirebaseFirestore.instance.collection(collection).doc(userId).update({'walletAmount': updatedWalletAmount.toStringAsFixed(2)}).then((value) {
        isAdded = true;
      }).catchError((error) {
        log('Error updating wallet for referral: $error');
        isAdded = false;
      });
    } else {
      log("User not found in $collection collection for ID: $userId");
    }
    return isAdded;
  }

  static Future<List<LoyaltyPointTransactionModel>?> getLoyaltyPointTransaction() async {
    final loyaltyPointTransactionModelList = <LoyaltyPointTransactionModel>[];
    try {
      final value = await fireStore
          .collection(CollectionName.loyaltyPointHistory)
          .where('customerId', isEqualTo: FireStoreUtils.getCurrentUid())
          .orderBy('createdAt', descending: true)
          .get();
      for (var doc in value.docs) {
        loyaltyPointTransactionModelList.add(
          LoyaltyPointTransactionModel.fromJson(doc.data()),
        );
      }
      log("loyaltyPointTransactionModelList length: ${loyaltyPointTransactionModelList.length}");
    } catch (error) {
      log("Error fetching loyalty transactions: $error");
    }
    return loyaltyPointTransactionModelList;
  }

  static Future<bool> setLoyaltyPointTransaction(LoyaltyPointTransactionModel loyaltyPointTransactionModel) async {
    try {
      await fireStore.collection(CollectionName.loyaltyPointHistory).doc(loyaltyPointTransactionModel.id).set(loyaltyPointTransactionModel.toJson());
      return true;
    } catch (error) {
      log("Failed to add ride: $error");
      return false;
    }
  }

  static Future<SMTPSettingModel?> getSMTPSettings() async {
    try {
      final doc = await FirebaseFirestore.instance.collection(CollectionName.settings).doc("smtp_settings").get();
      if (doc.exists && doc.data() != null) {
        return SMTPSettingModel.fromJson(doc.data()!);
      }
      return null;
    } catch (error) {
      log("Failed to get SMTP Settings: $error");
      return null;
    }
  }

  static StreamSubscription getEmergencyContacts(Function(List<EmergencyContactModel>) onUpdate) {
    return fireStore.collection(CollectionName.users).doc(getCurrentUid()).collection('emergency_contacts').snapshots().listen((querySnapshot) {
      final updatedList = querySnapshot.docs.map((doc) => EmergencyContactModel.fromJson(doc.data())).toList();
      onUpdate(updatedList);
    }, onError: (error) {
      log("Error fetching emergency contacts: $error");
      onUpdate([]);
    });
  }

  static Future<bool> addEmergencyContact(EmergencyContactModel contactModel) async {
    try {
      await fireStore.collection(CollectionName.users).doc(getCurrentUid()).collection('emergency_contacts').doc(contactModel.id).set(contactModel.toJson());
      return true;
    } catch (e) {
      log("Failed to add emergency contacts: $e");
      return false;
    }
  }

  static Future<bool> deleteEmergencyContact(String personId) async {
    try {
      await fireStore.collection(CollectionName.users).doc(getCurrentUid()).collection('emergency_contacts').doc(personId).delete();
      return true;
    } catch (e) {
      log("Failed to delete emergency contacts: $e");
      return false;
    }
  }

  static Future<bool> addSOSAlerts(SOSAlertsModel alertModel) async {
    try {
      await fireStore.collection(CollectionName.sosAlerts).doc(alertModel.id).set(alertModel.toJson());
      return true;
    } catch (e) {
      log("Failed to add Add Sos Alerts: $e");
      return false;
    }
  }

  static Future<List<SOSAlertsModel>?> getSOSRequest() async {
    List<SOSAlertsModel> sosList = [];
    try {
      final query = await fireStore.collection(CollectionName.sosAlerts).where("userId", isEqualTo: getCurrentUid()).where("type", isEqualTo: Constant.typeCustomer).get();
      for (var element in query.docs) {
        SOSAlertsModel sOSAlertsModel = SOSAlertsModel.fromJson(element.data());
        sosList.add(sOSAlertsModel);
      }
    } catch (error) {
      log("Failed to fetch Sos: $error");
    }
    return sosList;
  }

  static Future<EmergencyContactModel?> getEmergencyContactById({
    required String ownerId,
    required String contactId,
    required String ownerType, // customer | driver
  }) async {
    try {
      final String parentCollection = ownerType == "customer" ? CollectionName.users : CollectionName.drivers;

      final doc = await FirebaseFirestore.instance.collection(parentCollection).doc(ownerId).collection('emergency_contacts').doc(contactId).get();

      if (doc.exists && doc.data() != null) {
        return EmergencyContactModel.fromJson(doc.data()!);
      }

      return EmergencyContactModel(
        id: contactId,
        name: "Unknown",
        phoneNumber: "N/A",
        countryCode: "",
      );
    } catch (e) {
      log('Error fetching emergency contact: $e');
      return null;
    }
  }
}

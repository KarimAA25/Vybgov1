import 'dart:async';
import 'dart:developer';

// ignore_for_file: depend_on_referenced_packages
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/app/models/admin_commission.dart';
import 'package:driver/app/models/bank_detail_model.dart';
import 'package:driver/app/models/booking_model.dart';
import 'package:driver/app/models/currencies_model.dart';
import 'package:driver/app/models/documents_model.dart';
import 'package:driver/app/models/driver_user_model.dart';
import 'package:driver/app/models/emergency_number_model.dart';
import 'package:driver/app/models/loyalty_point_model.dart';
import 'package:driver/app/models/onboarding_model.dart';
import 'package:driver/app/models/loyalty_point_transaction_model.dart';
import 'package:driver/app/models/referral_model.dart';
import 'package:driver/app/models/rental_booking_model.dart';
import 'package:driver/app/models/sos_alerts_model.dart';
import 'package:driver/app/models/time_slots_charge_model.dart';
import 'package:driver/app/models/intercity_model.dart';
import 'package:driver/app/models/language_model.dart';
import 'package:driver/app/models/notification_model.dart';
import 'package:driver/app/models/parcel_model.dart';
import 'package:driver/app/models/payment_method_model.dart';
import 'package:driver/app/models/review_customer_model.dart';
import 'package:driver/app/models/subscription_model.dart';
import 'package:driver/app/models/subscription_plan_history.dart';
import 'package:driver/app/models/support_reason_model.dart';
import 'package:driver/app/models/support_ticket_model.dart';
import 'package:driver/app/models/transaction_log_model.dart';
import 'package:driver/app/models/user_model.dart';
import 'package:driver/app/models/vehicle_brand_model.dart';
import 'package:driver/app/models/vehicle_model_model.dart';
import 'package:driver/app/models/vehicle_type_model.dart';
import 'package:driver/app/models/wallet_transaction_model.dart';
import 'package:driver/app/models/withdraw_model.dart';
import 'package:driver/app/models/zone_model.dart';
import 'package:driver/constant/booking_status.dart';
import 'package:driver/constant/collection_name.dart';
import 'package:driver/constant/constant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:intl/intl.dart';

class FireStoreUtils {
  static FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  static FirebaseFirestore fireStore = FirebaseFirestore.instance;

  static String getCurrentUid() => firebaseAuth.currentUser!.uid;

  static Future<bool> setTransactionLog(TransactionLogModel transactionLogModel) async {
    try {
      await fireStore.collection(CollectionName.transactionLog).doc(transactionLogModel.id).set(transactionLogModel.toJson());
      return true;
    } catch (error) {
      log("Failed to update transaction log: $error");
      return false;
    }
  }

  static Future<bool> isLogin() async {
    final user = firebaseAuth.currentUser;
    if (user == null) return false;
    return await userExistOrNot(user.uid);
  }

  static Future<bool> userExistOrNot(String uid) async {
    try {
      final doc = await fireStore.collection(CollectionName.drivers).doc(uid).get();
      return doc.exists;
    } catch (error) {
      log("Failed to check user exist: $error");
      return false;
    }
  }

  static Future<bool> updateDriverUser(DriverUserModel userModel) async {
    try {
      await fireStore.collection(CollectionName.drivers).doc(userModel.id).set(userModel.toJson());
      return true;
    } catch (error) {
      log("Failed to update user: $error");
      return false;
    }
  }

  static Future<bool> updateUser(UserModel userModel) async {
    try {
      await fireStore.collection(CollectionName.users).doc(userModel.id).set(userModel.toJson());
      return true;
    } catch (error) {
      log("Failed to update user: $error");
      return false;
    }
  }

  static Future<List<LanguageModel>> getLanguage() async {
    try {
      final snap = await FirebaseFirestore.instance.collection(CollectionName.languages).get();
      return snap.docs.map((doc) => LanguageModel.fromJson(doc.data())).toList();
    } catch (e) {
      log("Failed to fetch languages: $e");
      return [];
    }
  }

  static Future<bool> updateDriverUserOnline(bool isOnline) async {
    try {
      final userModel = Constant.userModel ?? await getDriverUserProfile(getCurrentUid());
      if (userModel == null) return false;
      userModel.isOnline = isOnline;

      await fireStore.collection(CollectionName.drivers).doc(userModel.id).set(userModel.toJson());
      return true;
    } catch (error) {
      log("Failed to update user: $error");
      return false;
    }
  }

  static Future<void> fetchIntercityService() async {
    try {
      final documentLists = {
        "parcel": Constant.parcelDocuments,
        "intercity_sharing": Constant.intercitySharingDocuments,
        "intercity": Constant.intercityPersonalDocuments,
        "cab": Constant.cabDocuments,
      };

      for (final docName in documentLists.keys) {
        final doc = await fireStore.collection("intercity_service").doc(docName).get();
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          final model = TimeSlotsChargesModel.fromJson(docName, data);

          if (docName == 'parcel') {
            Constant.isParcelBid = model.isBidEnable;
          } else if (docName == 'intercity_sharing') {
            Constant.isInterCitySharingBid = model.isBidEnable;
          } else if (docName == 'cab') {
            Constant.isCabAvailable = model.isAvailable;
          } else if (docName == 'rental') {
            Constant.isRentalAvailable = model.isAvailable;
          } else {
            Constant.isInterCityBid = model.isBidEnable;
          }
          documentLists[docName]?.add(model);
        }
      }
    } catch (e) {
      log("Error fetching intercity services: $e");
    }
  }

  static Future<DriverUserModel?> getDriverUserProfile(String uuid) async {
    try {
      final doc = await fireStore.collection(CollectionName.drivers).doc(uuid).get();
      if (doc.exists && doc.data() != null) {
        final user = DriverUserModel.fromJson(doc.data()!);
        if (uuid == getCurrentUid()) {
          Constant.userModel = user;
        }
        return user;
      }
      return null;
    } catch (error) {
      log("Failed to get user: $error");
      return null;
    }
  }

  static Future<UserModel?> getUserProfile(String uuid) async {
    try {
      final doc = await fireStore.collection(CollectionName.users).doc(uuid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromJson(doc.data()!);
      }
      return null;
    } catch (error) {
      log("Failed to get user: $error");
      return null;
    }
  }

  static Future<bool> deleteDriverUser() async {
    try {
      await fireStore.collection(CollectionName.drivers).doc(FireStoreUtils.getCurrentUid()).delete();
      await firebaseAuth.currentUser!.delete();
      return true;
    } catch (e, s) {
      log('FireStoreUtils.deleteDriverUser $e $s');
      return false;
    }
  }

  static Future<bool> updateDriverUserWallet({required String amount}) async {
    try {
      final userModel = Constant.userModel ?? await getDriverUserProfile(FireStoreUtils.getCurrentUid());
      if (userModel == null) return false;
      userModel.walletAmount = (double.parse(userModel.walletAmount.toString()) + double.parse(amount)).toString();
      return await FireStoreUtils.updateDriverUser(userModel);
    } catch (error) {
      log("Failed to update wallet: $error");
      return false;
    }
  }

  static Future<bool> updateTotalEarning({required String amount}) async {
    try {
      final userModel = Constant.userModel ?? await getDriverUserProfile(FireStoreUtils.getCurrentUid());
      if (userModel == null) return false;
      userModel.totalEarning = (double.parse(userModel.totalEarning.toString()) + double.parse(amount)).toString();
      return await FireStoreUtils.updateDriverUser(userModel);
    } catch (error) {
      log("Failed to update total earning: $error");
      return false;
    }
  }

  static Future<bool> updateOtherUserWallet({required String amount, required String id}) async {
    try {
      final userModel = await getDriverUserProfile(id);
      if (userModel == null) return false;
      userModel.walletAmount = (double.parse(userModel.walletAmount.toString()) + double.parse(amount)).toString();
      return await FireStoreUtils.updateDriverUser(userModel);
    } catch (error) {
      log("Failed to update other user wallet: $error");
      return false;
    }
  }

  static Stream<IntercityModel?> getInterCityRideDetails(String bookingId) {
    return fireStore
        .collection(CollectionName.interCityRide)
        .where("id", isEqualTo: bookingId)
        .snapshots()
        .map((snapshot) => snapshot.docs.isNotEmpty ? IntercityModel.fromJson(snapshot.docs.first.data()) : null);
  }

  static Stream<ParcelModel?> getParcelRideDetails(String bookingId) {
    return fireStore
        .collection(CollectionName.parcelRide)
        .where("id", isEqualTo: bookingId)
        .snapshots()
        .map((snapshot) => snapshot.docs.isNotEmpty ? ParcelModel.fromJson(snapshot.docs.first.data()) : null);
  }

  static Future<VehicleTypeModel?> getVehicleTypeById(String vehicleId) async {
    try {
      final querySnapshot = await fireStore.collection(CollectionName.vehicleType).where("id", isEqualTo: vehicleId).get();
      if (querySnapshot.docs.isNotEmpty) {
        return VehicleTypeModel.fromJson(querySnapshot.docs.first.data());
      }
    } catch (error) {
      log("Failed to fetch vehicle type: $error");
    }
    return null;
  }

  static Future<List<VehicleTypeModel>> getVehicleType() async {
    try {
      final snapshot = await fireStore.collection(CollectionName.vehicleType).where("isActive", isEqualTo: true).get();
      return snapshot.docs.map((doc) => VehicleTypeModel.fromJson(doc.data())).toList();
    } catch (error) {
      log(error.toString());
      return [];
    }
  }

  static Future<List<DocumentsModel>> getDocumentList() async {
    try {
      final snapshot = await fireStore.collection(CollectionName.documents).where("isEnable", isEqualTo: true).get();
      return snapshot.docs.map((doc) => DocumentsModel.fromJson(doc.data())).toList();
    } catch (error) {
      log(error.toString());
      return [];
    }
  }

  static Future<List<VehicleBrandModel>> getVehicleBrand() async {
    try {
      final snapshot = await fireStore.collection(CollectionName.vehicleBrand).where("isEnable", isEqualTo: true).get();
      return snapshot.docs.map((doc) => VehicleBrandModel.fromJson(doc.data())).toList();
    } catch (error) {
      log(error.toString());
      return [];
    }
  }

  static Future<List<VehicleModelModel>> getVehicleModel(String brandId) async {
    try {
      final snapshot = await fireStore.collection(CollectionName.vehicleModel).where("isEnable", isEqualTo: true).where("brandId", isEqualTo: brandId).get();
      return snapshot.docs.map((doc) => VehicleModelModel.fromJson(doc.data())).toList();
    } catch (error) {
      log(error.toString());
      return [];
    }
  }

  static Future<List<ZoneModel>> getZoneList() async {
    try {
      final snapshot = await fireStore.collection(CollectionName.zones).where("status", isEqualTo: true).get();
      return snapshot.docs.map((doc) => ZoneModel.fromJson(doc.data())).toList();
    } catch (error) {
      log(error.toString());
      return [];
    }
  }

  Future<CurrencyModel?> getCurrency() async {
    try {
      final snapshot = await fireStore.collection(CollectionName.currency).where("active", isEqualTo: true).get();
      if (snapshot.docs.isNotEmpty) {
        return CurrencyModel.fromJson(snapshot.docs.first.data());
      }
      return null;
    } catch (error) {
      log("Failed to get currency: $error");
      return null;
    }
  }

  Future<void> getAdminCommission() async {
    try {
      final doc = await fireStore.collection(CollectionName.settings).doc("admin_commission").get();
      log('========================> get admin commission');
      if (doc.data() != null) {
        final adminCommission = AdminCommission.fromJson(doc.data()!);
        if (adminCommission.active == true) {
          Constant.adminCommission = adminCommission;
        }
      }
    } catch (error) {
      log("Failed to get admin commission: $error");
    }
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

  Future<void> getSettings() async {
    try {
      final constantDoc = await fireStore.collection(CollectionName.settings).doc("constant").get();
      if (constantDoc.exists) {
        final data = constantDoc.data()!;
        // Constant.mapAPIKey = data["googleMapKey"];
        Constant.senderId = data["notification_senderId"];
        Constant.jsonFileURL = data["jsonFileURL"];
        Constant.minimumAmountToWithdrawal = data["minimum_amount_withdraw"];
        Constant.minimumAmountToDeposit = data["minimum_amount_deposit"];
        Constant.appName = data["appName"];
        Constant.appColor = data["appColor"];
        Constant.aboutApp = data["aboutApp"];
        Constant.interCityRadius = double.parse(data["interCityRadius"]);
        Constant.isSubscriptionEnable = data["isSubscriptionEnable"] ?? false;
        Constant.isDocumentVerificationEnable = data["isDocumentVerificationEnable"] ?? true;
        Constant.isDriverAutoApproved = data["isDriverAutoApproved"] ?? false;
        Constant.isOtpFeatureEnable = data["isOTPEnable"] ?? true;
        Constant.referralAmount = data["referral_Amount"];
        Constant.countryCode = data["countryCode"];
        // Constant.selectedMap = data["selectedMap"];
        Constant.sosAlertNumber = data["sosNumber"];
        Constant.loyaltyProgram = data["loyaltyProgram"] == null ? null : LoyaltyPointModel.fromJson(data["loyaltyProgram"]);
        final mapSettings = data["mapSettings"] as Map<String, dynamic>?;

        if (mapSettings != null) {
          // Constant.mapAPIKey = "AIzaSyB5_ImjYNXF0qVNe1A9Nrn0OTYhu_gcvaM";
          Constant.mapAPIKey = mapSettings["googleMapKey"] ?? "";
          Constant.selectedMap = mapSettings["mapType"] ?? "Google Map";
        }
      }

      final globalValueDoc = await fireStore.collection(CollectionName.settings).doc("globalValue").get();
      if (globalValueDoc.exists) {
        final data = globalValueDoc.data()!;
        Constant.distanceType = data["distanceType"];
        Constant.driverLocationUpdate = data["driverLocationUpdate"];
        Constant.radius = data["radius"];
        Constant.minimumAmountToAcceptRide = data["minimum_amount_accept_ride"];
      }

      await fireStore.collection(CollectionName.settings).doc("privacy_policy").get().then((value) {
        if (value.exists) {
          Constant.privacyPolicy = value.data()?["privacy_policy_driver"] ?? "";
        }
      });

      await fireStore.collection(CollectionName.settings).doc("terms_and_Conditions").get().then((value) {
        if (value.exists) {
          Constant.termsAndConditions = value.data()?["terms_and_Conditions_driver"] ?? "";
        }
      });

      final cancelReasonDoc = await fireStore.collection(CollectionName.settings).doc("canceling_reason").get();
      if (cancelReasonDoc.exists) {
        Constant.cancellationReason = cancelReasonDoc.data()!["reasons"];
      }
    } catch (error) {
      log("Failed to get settings: $error");
    }
  }

  Future<PaymentModel?> getPayment() async {
    try {
      final doc = await fireStore.collection(CollectionName.settings).doc("payment").get();
      if (doc.exists && doc.data() != null) {
        final payment = PaymentModel.fromJson(doc.data()!);
        Constant.paymentModel = payment;
        return payment;
      }
      return null;
    } catch (error) {
      log("Failed to get payment: $error");
      return null;
    }
  }

  static Future<List<WalletTransactionModel>> getWalletTransaction() async {
    try {
      final snapshot = await fireStore
          .collection(CollectionName.walletTransaction)
          .where('userId', isEqualTo: FireStoreUtils.getCurrentUid())
          .where('type', isEqualTo: "driver")
          .orderBy('createdDate', descending: true)
          .get();
      return snapshot.docs.map((doc) => WalletTransactionModel.fromJson(doc.data())).toList();
    } catch (error) {
      log("Failed to get wallet transactions: $error");
      return [];
    }
  }

  static Future<bool> setWalletTransaction(WalletTransactionModel walletTransactionModel) async {
    try {
      walletTransactionModel.id ??= Constant.getUuid();
      walletTransactionModel.userId ??= FireStoreUtils.getCurrentUid();
      walletTransactionModel.createdDate ??= Timestamp.now();
      await fireStore.collection(CollectionName.walletTransaction).doc(walletTransactionModel.id).set(walletTransactionModel.toJson());
      return true;
    } catch (error) {
      log("Failed to update user: $error");
      return false;
    }
  }

  static Future<bool> setBooking(BookingModel bookingModel) async {
    try {
      await fireStore.collection(CollectionName.bookings).doc(bookingModel.id).set(bookingModel.toJson());
      return true;
    } catch (error) {
      log("Failed to add ride: $error");
      return false;
    }
  }

  static Future<bool> setInterCityBooking(IntercityModel bookingModel) async {
    try {
      await fireStore.collection(CollectionName.interCityRide).doc(bookingModel.id).set(bookingModel.toJson());
      return true;
    } catch (error) {
      log("Failed to add ride: $error");
      return false;
    }
  }

  static Future<bool> setParcelBooking(ParcelModel bookingModel) async {
    try {
      await fireStore.collection(CollectionName.parcelRide).doc(bookingModel.id).set(bookingModel.toJson());
      return true;
    } catch (error) {
      log("Failed to add ride: $error");
      return false;
    }
  }

  static Future<bool> setRentalRide(RentalBookingModel rentalModel) async {
    try {
      await fireStore.collection(CollectionName.rentalRide).doc(rentalModel.id).set(rentalModel.toJson());
      return true;
    } catch (error) {
      log("Failed to add Rental ride: $error");
      return false;
    }
  }

  // static Future<List<IntercityModel>> getNearestIntercityRide({
  //   required double srcLat,
  //   required double srcLng,
  //   required DateTime date,
  // }) async {
  //   final ref = fireStore
  //       .collection(CollectionName.interCityRide)
  //       .where('bookingStatus', isEqualTo: BookingStatus.bookingPlaced)
  //       .where('vehicleTypeID', isEqualTo: Constant.userModel!.driverVehicleDetails!.vehicleTypeId.toString());
  //
  //   GeoFirePoint center = GeoFlutterFire().point(latitude: srcLat, longitude: srcLng);
  //
  //   // Take first snapshot from the stream
  //   final docs = await GeoFlutterFire()
  //       .collection(collectionRef: ref)
  //       .within(
  //         center: center,
  //         radius: double.parse(Constant.radius),
  //         field: "pickupPosition",
  //         strictMode: true,
  //       )
  //       .first; // 👈 this makes it a Future
  //
  //   final filtered = docs.where((doc) {
  //     final data = doc.data() as Map<String, dynamic>;
  //     if (data['bookingTime'] == null) return false;
  //
  //     final Timestamp ts = data['bookingTime'];
  //     final orderDate = ts.toDate().toLocal();
  //     final inputDate = date.toLocal();
  //
  //     bool sameDay = orderDate.year == inputDate.year && orderDate.month == inputDate.month && orderDate.day == inputDate.day;
  //
  //     if (!sameDay) return false;
  //
  //     // // Destination check
  //     // if (destLat != null && destLng != null && data['receiverLatLong'] != null) {
  //     //   final rec = data['receiverLatLong'];
  //     //   double recLat = rec['latitude'];
  //     //   double recLng = rec['longitude'];
  //     //
  //     //   double distance = Geoflutterfire().point(latitude: destLat, longitude: destLng).kmDistance(lat: recLat, lng: recLng);
  //     //
  //     //   if (distance > radiusInKm) return false;
  //     // }
  //
  //     return true;
  //   }).toList();
  //
  //   log("++++++++++++++ ${filtered.length}");
  //   return filtered.map((e) => IntercityModel.fromJson(e.data() as Map<String, dynamic>)).toList();
  // }

  static Future<List<IntercityModel>> getNearestIntercityRide({required double srcLat, required double srcLng, required DateTime date}) async {
    final ref = fireStore.collection(CollectionName.interCityRide).where('bookingStatus', isEqualTo: BookingStatus.bookingPlaced).where("rejectedDriverId",
        whereNotIn: [FireStoreUtils.getCurrentUid()]).where('vehicleTypeID', isEqualTo: Constant.userModel!.driverVehicleDetails!.vehicleTypeId.toString());

    GeoFirePoint center = GeoFlutterFire().point(latitude: srcLat, longitude: srcLng);

    final docs = await GeoFlutterFire()
        .collection(collectionRef: ref)
        .within(
          center: center,
          radius: double.parse(Constant.radius), // radius in KM
          field: "pickupPosition",
          strictMode: true,
        )
        .first;

    // Filter only rides on the selected date
    final inputDateStr = DateFormat('yyyy-MM-dd').format(date.toLocal());

    final filtered = docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['bookingTime'] == null) return false;

      final Timestamp ts = data['bookingTime'];
      final rideDate = ts.toDate().toLocal();
      final rideDateStr = DateFormat('yyyy-MM-dd').format(rideDate);

      return rideDateStr == inputDateStr;
    }).toList();

    log("✅ Intercity rides from Firestore (after filter): ${filtered.length}");

    return filtered.map((e) {
      final data = e.data() as Map<String, dynamic>;
      return IntercityModel.fromJson(data);
    }).toList();
  }

  static Future<List<ParcelModel>> getNearestParcelRide({
    required double srcLat,
    required double srcLng,
    double? destLat,
    double? destLng,
    required DateTime date,
  }) async {
    final ref = fireStore
        .collection(CollectionName.parcelRide)
        .where("rejectedDriverId", whereNotIn: [FireStoreUtils.getCurrentUid()]).where('bookingStatus', isEqualTo: BookingStatus.bookingPlaced);

    GeoFirePoint center = GeoFlutterFire().point(latitude: srcLat, longitude: srcLng);

    final docs = await GeoFlutterFire()
        .collection(collectionRef: ref)
        .within(
          center: center,
          radius: double.parse(Constant.radius), // in KM
          field: "pickupPosition",
          strictMode: true,
        )
        .first;

    final inputDateStr = DateFormat('yyyy-MM-dd').format(date.toLocal());

    final filtered = docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['bookingTime'] == null) return false;

      final Timestamp ts = data['bookingTime'];
      final rideDate = ts.toDate().toLocal();
      final rideDateStr = DateFormat('yyyy-MM-dd').format(rideDate);

      return rideDateStr == inputDateStr;
    }).toList();

    log("✅ Intercity rides from Firestore (after filter): ${filtered.length}");

    return filtered.map((e) {
      final data = e.data() as Map<String, dynamic>;
      return ParcelModel.fromJson(data);
    }).toList();
  }

  StreamController<List<BookingModel>>? getHomeOngoingBookingController;

  Stream<List<BookingModel>> getHomeOngoingBookings() async* {
    getHomeOngoingBookingController = StreamController<List<BookingModel>>.broadcast();
    List<BookingModel> bookingsList = [];
    try {
      if (Constant.userModel?.id == null) {
        yield [];
        return;
      }
      Stream<QuerySnapshot> stream1 = fireStore
          .collection(CollectionName.bookings)
          .where('bookingStatus', whereIn: [BookingStatus.bookingAccepted, BookingStatus.bookingPlaced, BookingStatus.bookingOngoing])
          .where('driverId', isEqualTo: Constant.userModel!.id)
          .snapshots();
      stream1.listen((QuerySnapshot querySnapshot) {
        log("Length= : ${querySnapshot.docs.length}");
        bookingsList.clear();
        for (var document in querySnapshot.docs) {
          final data = document.data() as Map<String, dynamic>;
          BookingModel bookingModel = BookingModel.fromJson(data);
          if (bookingModel.driverId != null && bookingModel.driverId!.isNotEmpty) {
            if ((bookingModel.driverId ?? '') == FireStoreUtils.getCurrentUid()) {
              bookingsList.add(bookingModel);
            }
          }
        }
        getHomeOngoingBookingController?.sink.add(bookingsList);
      });
      yield* getHomeOngoingBookingController!.stream;
    } catch (e) {
      log('Error in getHomeOngoingBookings: $e');
      yield [];
    }
  }

  void closeHomeOngoingStream() {
    getHomeOngoingBookingController?.close();
    getHomeOngoingBookingController = null;
  }

  // StreamController<List<BookingModel>>? getOngoingBookingController;
  //
  // Stream<List<BookingModel>> getOngoingBookings() async* {
  //   getOngoingBookingController = StreamController<List<BookingModel>>.broadcast();
  //   List<BookingModel> bookingsList = [];
  //   try {
  //     if (Constant.userModel?.id == null) {
  //       log('User id is null');
  //       yield [];
  //       return;
  //     }
  //     Stream<QuerySnapshot> stream = fireStore
  //         .collection(CollectionName.bookings)
  //         .where('bookingStatus', isEqualTo: BookingStatus.bookingAccepted)
  //         .where('driverId', isEqualTo: Constant.userModel!.id)
  //         .orderBy('createAt', descending: true)
  //         .snapshots();
  //     stream.listen((QuerySnapshot querySnapshot) {
  //       log("Length= : ${querySnapshot.docs.length}");
  //       bookingsList.clear();
  //       for (var document in querySnapshot.docs) {
  //         final data = document.data() as Map<String, dynamic>;
  //         BookingModel bookingModel = BookingModel.fromJson(data);
  //         if (bookingModel.driverId != null && bookingModel.driverId!.isNotEmpty) {
  //           if ((bookingModel.driverId ?? '') == FireStoreUtils.getCurrentUid()) {
  //             bookingsList.add(bookingModel);
  //           }
  //         }
  //       }
  //       getOngoingBookingController?.sink.add(bookingsList);
  //     });
  //     Stream<QuerySnapshot> stream1 = fireStore
  //         .collection(CollectionName.bookings)
  //         .where('bookingStatus', isEqualTo: BookingStatus.bookingOngoing)
  //         .where('driverId', isEqualTo: Constant.userModel!.id)
  //         .snapshots();
  //     stream1.listen((QuerySnapshot querySnapshot) {
  //       log("Length= : ${querySnapshot.docs.length}");
  //       for (var document in querySnapshot.docs) {
  //         final data = document.data() as Map<String, dynamic>;
  //         BookingModel bookingModel = BookingModel.fromJson(data);
  //         if (bookingModel.driverId != null && bookingModel.driverId!.isNotEmpty) {
  //           if ((bookingModel.driverId ?? '') == FireStoreUtils.getCurrentUid()) {
  //             bookingsList.add(bookingModel);
  //           }
  //         }
  //       }
  //       getOngoingBookingController?.sink.add(bookingsList);
  //     });
  //     yield* getOngoingBookingController!.stream;
  //   } catch (e) {
  //     log('Error in getOngoingBookings: $e');
  //     yield [];
  //   }
  // }
  //
  // void closeOngoingStream() {
  //   getOngoingBookingController?.close();
  //   getOngoingBookingController = null;
  // }

  // StreamController<List<BookingModel>>? getCompletedBookingController;
  //
  // Stream<List<BookingModel>> getCompletedBookings() async* {
  //   getCompletedBookingController = StreamController<List<BookingModel>>.broadcast();
  //   List<BookingModel> bookingsList = [];
  //   try {
  //     final userId = Constant.userModel?.id;
  //     if (userId == null) {
  //       log('User id is null');
  //       yield [];
  //       return;
  //     }
  //     Stream<QuerySnapshot> stream = fireStore
  //         .collection(CollectionName.bookings)
  //         .where('bookingStatus', isEqualTo: BookingStatus.bookingCompleted)
  //         .where('driverId', isEqualTo: userId)
  //         .orderBy('createAt', descending: true)
  //         .snapshots();
  //     stream.listen((QuerySnapshot querySnapshot) {
  //       log("Length= : ${querySnapshot.docs.length}");
  //       bookingsList.clear();
  //       for (var document in querySnapshot.docs) {
  //         final data = document.data() as Map<String, dynamic>;
  //         BookingModel bookingModel = BookingModel.fromJson(data);
  //         if (bookingModel.driverId != null && bookingModel.driverId!.isNotEmpty) {
  //           if ((bookingModel.driverId ?? '') == FireStoreUtils.getCurrentUid()) {
  //             bookingsList.add(bookingModel);
  //           }
  //         }
  //       }
  //       getCompletedBookingController?.sink.add(bookingsList);
  //     });
  //     yield* getCompletedBookingController!.stream;
  //   } catch (e) {
  //     log('Error in getCompletedBookings: $e');
  //     yield [];
  //   }
  // }
  //
  // void closeCompletedStream() {
  //   getCompletedBookingController?.close();
  //   getCompletedBookingController = null;
  // }

  // StreamController<List<BookingModel>>? getCancelledBookingController;
  //
  // Stream<List<BookingModel>> getCancelledBookings() async* {
  //   getCancelledBookingController = StreamController<List<BookingModel>>.broadcast();
  //   List<BookingModel> bookingsList = [];
  //   try {
  //     final userId = Constant.userModel?.id;
  //     if (userId == null) {
  //       log('User id is null');
  //       yield [];
  //       return;
  //     }
  //     Stream<QuerySnapshot> stream = fireStore
  //         .collection(CollectionName.bookings)
  //         .where('bookingStatus', isEqualTo: BookingStatus.bookingCancelled)
  //         .where('driverId', isEqualTo: userId)
  //         .orderBy('createAt', descending: true)
  //         .snapshots();
  //     stream.listen((QuerySnapshot querySnapshot) {
  //       log("Length= : ${querySnapshot.docs.length}");
  //       bookingsList.clear();
  //       for (var document in querySnapshot.docs) {
  //         final data = document.data() as Map<String, dynamic>;
  //         BookingModel bookingModel = BookingModel.fromJson(data);
  //         if (bookingModel.driverId != null && bookingModel.driverId!.isNotEmpty) {
  //           if ((bookingModel.driverId ?? '') == FireStoreUtils.getCurrentUid()) {
  //             bookingsList.add(bookingModel);
  //           }
  //         }
  //       }
  //       getCancelledBookingController?.sink.add(bookingsList);
  //     });
  //     yield* getCancelledBookingController!.stream;
  //   } catch (e) {
  //     log('Error in getCancelledBookings: $e');
  //     yield [];
  //   }
  // }
  //
  // void closeCancelledStream() {
  //   getCancelledBookingController?.close();
  //   getCancelledBookingController = null;
  // }

  // StreamController<List<BookingModel>>? getRejectedBookingController;
  //
  // Stream<List<BookingModel>> getRejectedBookings() async* {
  //   getRejectedBookingController = StreamController<List<BookingModel>>.broadcast();
  //   List<BookingModel> bookingsList = [];
  //   try {
  //     final userId = Constant.userModel?.id;
  //     if (userId == null) {
  //       log('User id is null');
  //       yield [];
  //       return;
  //     }
  //     Stream<QuerySnapshot> stream = fireStore
  //         .collection(CollectionName.bookings)
  //         .where('rejectedDriverId', arrayContains: userId)
  //         .orderBy("createAt", descending: true)
  //         .snapshots();
  //     stream.listen((QuerySnapshot querySnapshot) {
  //       log("Length= : ${querySnapshot.docs.length}");
  //       bookingsList.clear();
  //       for (var document in querySnapshot.docs) {
  //         final data = document.data() as Map<String, dynamic>;
  //         BookingModel bookingModel = BookingModel.fromJson(data);
  //         if (bookingModel.rejectedDriverId != null && bookingModel.rejectedDriverId!.isNotEmpty) {
  //           if ((bookingModel.rejectedDriverId ?? []).contains(FireStoreUtils.getCurrentUid())) {
  //             bookingsList.add(bookingModel);
  //           }
  //         }
  //       }
  //       getRejectedBookingController?.sink.add(bookingsList);
  //     });
  //     yield* getRejectedBookingController!.stream;
  //   } catch (e) {
  //     log('Error in getRejectedBookings: $e');
  //     yield [];
  //   }
  // }
  //
  // void closeRejectedStream() {
  //   getRejectedBookingController?.close();
  //   getRejectedBookingController = null;
  // }

  static Future<List<NotificationModel>?> getNotificationList() async {
    List<NotificationModel> notificationModelList = [];
    try {
      final query =
          await fireStore.collection(CollectionName.notification).where('driverId', isEqualTo: FireStoreUtils.getCurrentUid()).orderBy('createdAt', descending: true).get();
      for (var element in query.docs) {
        NotificationModel notificationModel = NotificationModel.fromJson(element.data());
        notificationModelList.add(notificationModel);
      }
    } catch (error) {
      log("Failed to fetch notifications: $error");
    }
    return notificationModelList;
  }

  static Future<bool?> setNotification(NotificationModel notificationModel) async {
    try {
      notificationModel.id ??= Constant.getUuid();
      notificationModel.driverId ??= FireStoreUtils.getCurrentUid();
      notificationModel.createdAt ??= Timestamp.now();
      await fireStore.collection(CollectionName.notification).doc(notificationModel.id).set(notificationModel.toJson());
      return true;
    } catch (error) {
      log("Failed to update user: $error");
      return false;
    }
  }

  static Future<List<ReviewModel>?> getReviewList() async {
    List<ReviewModel> reviewModelList = [];
    try {
      final query = await fireStore.collection(CollectionName.review).where("driverId", isEqualTo: getCurrentUid()).where("type", isEqualTo: Constant.typeDriver).get();
      for (var element in query.docs) {
        ReviewModel reviewModel = ReviewModel.fromJson(element.data());
        reviewModelList.add(reviewModel);
      }
    } catch (error) {
      log("Failed to fetch reviews: $error");
    }
    return reviewModelList;
  }

  static Future<List<BankDetailsModel>> getBankDetailList(String? driverId) async {
    List<BankDetailsModel> bankDetailsList = [];
    try {
      final query = await fireStore.collection(CollectionName.bankDetails).where("driverID", isEqualTo: driverId).get();
      for (var element in query.docs) {
        bankDetailsList.add(BankDetailsModel.fromJson(element.data()));
      }
    } catch (error) {
      log("Failed to fetch bank details: $error");
    }
    return bankDetailsList;
  }

  static Future<bool> addBankDetail(BankDetailsModel bankDetailsModel) async {
    try {
      await fireStore.collection(CollectionName.bankDetails).doc(bankDetailsModel.id).set(bankDetailsModel.toJson());
      return true;
    } catch (error) {
      log("Failed to add bank detail: $error");
      return false;
    }
  }

  static Future<bool> updateBankDetail(BankDetailsModel bankDetailsModel) async {
    try {
      await fireStore.collection(CollectionName.bankDetails).doc(bankDetailsModel.id).update(bankDetailsModel.toJson());
      return true;
    } catch (error) {
      log("Failed to update bank detail: $error");
      return false;
    }
  }

  static Future<bool> setWithdrawRequest(WithdrawModel withdrawModel) async {
    try {
      await fireStore.collection(CollectionName.withdrawalHistory).doc(withdrawModel.id).set(withdrawModel.toJson());
      return true;
    } catch (error) {
      log("Failed to set withdraw request: $error");
      return false;
    }
  }

  static Future<List<WithdrawModel>> getWithDrawRequest() async {
    List<WithdrawModel> withdrawalList = [];
    try {
      final query = await fireStore.collection(CollectionName.withdrawalHistory).where('driverId', isEqualTo: getCurrentUid()).orderBy('createdDate', descending: true).get();
      for (var element in query.docs) {
        withdrawalList.add(WithdrawModel.fromJson(element.data()));
      }
    } catch (error) {
      log("Failed to fetch withdraw requests: $error");
    }
    return withdrawalList;
  }

  static Future<int> getTotalRide() async {
    try {
      final productList = FirebaseFirestore.instance.collection(CollectionName.bookings).where("driverId", isEqualTo: getCurrentUid());
      final query = await productList.count().get();
      log('The number of products: ${query.count}');
      return query.count ?? 0;
    } catch (e) {
      log('Error in getTotalRide: $e');
      return 0;
    }
  }

  static Future<int> getCompletedRide() async {
    try {
      final productList = FirebaseFirestore.instance
          .collection(CollectionName.bookings)
          .where("driverId", isEqualTo: getCurrentUid())
          .where("bookingStatus", isEqualTo: BookingStatus.bookingCompleted);
      final query = await productList.count().get();
      log('The number of products: ${query.count}');
      return query.count ?? 0;
    } catch (e) {
      log('Error in getCompletedRide: $e');
      return 0;
    }
  }

  static Future<int> getOngoingRide() async {
    try {
      final productList = FirebaseFirestore.instance
          .collection(CollectionName.bookings)
          .where("driverId", isEqualTo: getCurrentUid())
          .where("bookingStatus", isEqualTo: BookingStatus.bookingOngoing);
      final query = await productList.count().get();
      log('The number of products: ${query.count}');
      return query.count ?? 0;
    } catch (e) {
      log('Error in getOngoingRide: $e');
      return 0;
    }
  }

  static Future<BookingModel?> getBookingBuBookingId(String bookingId) async {
    BookingModel? referralModel;
    try {
      await fireStore.collection(CollectionName.bookings).doc(bookingId).get().then((value) {
        if (value.exists) {
          referralModel = BookingModel.fromJson(value.data()!);
        }
      });
    } catch (e, s) {
      log('FireStoreUtils.firebaseCreateNewUser $e $s');
      return null;
    }
    return referralModel;
  }

  static Future<int> getNewRide() async {
    try {
      final productList = FirebaseFirestore.instance
          .collection(CollectionName.bookings)
          .where("driverId", isEqualTo: getCurrentUid())
          .where("bookingStatus", isEqualTo: BookingStatus.bookingAccepted);
      final query = await productList.count().get();
      return query.count ?? 0;
    } catch (e) {
      log('Error in getNewRide: $e');
      return 0;
    }
  }

  static Future<int> getRejectedRide() async {
    try {
      final productList = FirebaseFirestore.instance.collection(CollectionName.bookings).where("rejectedDriverId", arrayContains: getCurrentUid());
      final query = await productList.count().get();
      log('The number of products: ${query.count}');
      return query.count ?? 0;
    } catch (e) {
      log('Error in getRejectedRide: $e');
      return 0;
    }
  }

  static Future<int> getCancelledRide() async {
    try {
      final productList = FirebaseFirestore.instance
          .collection(CollectionName.bookings)
          .where("driverId", isEqualTo: getCurrentUid())
          .where("bookingStatus", isEqualTo: BookingStatus.bookingCancelled);
      final query = await productList.count().get();
      log('The number of products: ${query.count}');
      return query.count ?? 0;
    } catch (e) {
      log('Error in getCancelledRide: $e');
      return 0;
    }
  }

  static Future<List<SupportReasonModel>> getSupportReason() async {
    List<SupportReasonModel> supportReasonList = [];
    try {
      final value = await fireStore.collection(CollectionName.supportReason).where("type", isEqualTo: "driver").get();
      for (var element in value.docs) {
        supportReasonList.add(SupportReasonModel.fromJson(element.data()));
      }
    } catch (error) {
      log("Failed to fetch support reasons: $error");
    }
    return supportReasonList;
  }

  static Future<bool> addSupportTicket(SupportTicketModel supportTicketModel) async {
    try {
      supportTicketModel.id ??= Constant.getUuid();
      supportTicketModel.userId ??= FireStoreUtils.getCurrentUid();
      supportTicketModel.type ??= "driver";
      supportTicketModel.createAt ??= Timestamp.now();
      supportTicketModel.updateAt ??= Timestamp.now();
      await fireStore.collection(CollectionName.supportTicket).doc(supportTicketModel.id).set(supportTicketModel.toJson());
      return true;
    } catch (error) {
      log("Failed to add Support Ticket : $error");
      return false;
    }
  }

  static Future<List<SupportTicketModel>> getSupportTicket(String id) async {
    List<SupportTicketModel> supportTicketList = [];
    try {
      final value = await fireStore.collection(CollectionName.supportTicket).where("userId", isEqualTo: id).orderBy("createAt", descending: true).get();
      for (var element in value.docs) {
        supportTicketList.add(SupportTicketModel.fromJson(element.data()));
      }
    } catch (error) {
      log("Failed to fetch support tickets: $error");
    }
    return supportTicketList;
  }

  static void getInterCityOngoingRides(Function(List<IntercityModel>) onUpdate) {
    fireStore
        .collection(CollectionName.interCityRide)
        .where("driverId", isEqualTo: getCurrentUid())
        .where('bookingStatus', whereIn: [BookingStatus.bookingOngoing, BookingStatus.bookingOnHold])
        .orderBy("createAt", descending: true)
        .snapshots()
        .listen((querySnapshot) {
          List<IntercityModel> bookingList = querySnapshot.docs.map((doc) => IntercityModel.fromJson(doc.data())).toList();
          onUpdate(bookingList);
        }, onError: (error) {
          log("Error fetching ongoing rides: $error");
          onUpdate([]);
        });
  }

  static void getInterCityCompletedRides(Function(List<IntercityModel>) onUpdate) {
    fireStore
        .collection(CollectionName.interCityRide)
        .where("driverId", isEqualTo: getCurrentUid())
        .where('bookingStatus', whereIn: [BookingStatus.bookingCompleted])
        .orderBy("createAt", descending: true)
        .snapshots()
        .listen((querySnapshot) {
          List<IntercityModel> updatedList = querySnapshot.docs.map((doc) => IntercityModel.fromJson(doc.data())).toList();
          onUpdate(updatedList);
        }, onError: (error) {
          log("Error fetching completed rides: $error");
          onUpdate([]);
        });
  }

  static void getInterCityActiveRides(Function(List<IntercityModel>) onUpdate) {
    final isFemaleDriver = Constant.userModel!.gender?.toLowerCase() == 'female';
    String customerId = getCurrentUid();

    List<IntercityModel> bidRides = [];
    List<IntercityModel> directRides = [];

    fireStore
        .collection(CollectionName.interCityRide)
        .where('bookingStatus', whereIn: [BookingStatus.bookingPlaced, BookingStatus.bookingAccepted])
        .where('driverBidIdList', arrayContains: customerId)
        .orderBy("createAt", descending: true)
        .snapshots()
        .listen((querySnapshot) {
          bidRides = querySnapshot.docs.map((doc) => IntercityModel.fromJson(doc.data())).toList();

          List<IntercityModel> all = [...bidRides, ...directRides];

          // female filter
          all = all.where((ride) {
            if (ride.isOnlyForFemale == true && !isFemaleDriver) {
              return false;
            }
            return true;
          }).toList();

          onUpdate(all);
        });

    fireStore
        .collection(CollectionName.interCityRide)
        .where('bookingStatus', isEqualTo: BookingStatus.bookingAccepted)
        .where('driverId', isEqualTo: customerId)
        .orderBy("createAt", descending: true)
        .snapshots()
        .listen((querySnapshot) {
      directRides = querySnapshot.docs.map((doc) => IntercityModel.fromJson(doc.data())).toList();

      List<IntercityModel> all = [...bidRides, ...directRides];

      // female filter
      all = all.where((ride) {
        if (ride.isOnlyForFemale == true && !isFemaleDriver) {
          return false;
        }
        return true;
      }).toList();

      onUpdate(all);
    });
  }

  static void getInterCityRejectedRides(Function(List<IntercityModel>) onUpdate) {
    fireStore
        .collection(CollectionName.interCityRide)
        .where("driverId", isEqualTo: getCurrentUid())
        .where('bookingStatus', whereIn: [BookingStatus.bookingCancelled, BookingStatus.bookingRejected])
        .orderBy("createAt", descending: true)
        .snapshots()
        .listen((querySnapshot) {
          final updatedList = querySnapshot.docs.map((doc) => IntercityModel.fromJson(doc.data())).toList();
          onUpdate(updatedList);
        }, onError: (error) {
          log("Error fetching rejected rides: $error");
          onUpdate([]);
        });
  }

  static void getParcelActiveRides(Function(List<ParcelModel>) onUpdate) {
    final customerId = getCurrentUid();

    List<ParcelModel> bidRides = [];
    List<ParcelModel> directRides = [];
    fireStore
        .collection(CollectionName.parcelRide)
        .where('bookingStatus', isEqualTo: BookingStatus.bookingPlaced)
        .where('driverBidIdList', arrayContains: customerId)
        .orderBy("createAt", descending: true)
        .snapshots()
        .listen((querySnapshot) {
      bidRides = querySnapshot.docs.map((doc) => ParcelModel.fromJson(doc.data())).toList();

      List<ParcelModel> all = [...bidRides, ...directRides];

      onUpdate(all);
    });
    fireStore
        .collection(CollectionName.parcelRide)
        .where('bookingStatus', isEqualTo: BookingStatus.bookingAccepted)
        .where('driverId', isEqualTo: customerId)
        .orderBy("createAt", descending: true)
        .snapshots()
        .listen((querySnapshot) {
      directRides = querySnapshot.docs.map((doc) => ParcelModel.fromJson(doc.data())).toList();

      List<ParcelModel> all = [...bidRides, ...directRides];

      onUpdate(all);
    });
  }

  static void getParcelOngoingRides(Function(List<ParcelModel>) onUpdate) {
    fireStore
        .collection(CollectionName.parcelRide)
        .where("driverId", isEqualTo: getCurrentUid())
        .where('bookingStatus', whereIn: [BookingStatus.bookingOngoing, BookingStatus.bookingAccepted])
        .orderBy("createAt", descending: true)
        .snapshots()
        .listen((querySnapshot) {
          final bookingList = querySnapshot.docs.map((doc) => ParcelModel.fromJson(doc.data())).toList();
          onUpdate(bookingList);
        }, onError: (error) {
          log("Error fetching ongoing rides: $error");
          onUpdate([]);
        });
  }

  static void getParcelCompletedRides(Function(List<ParcelModel>) onUpdate) {
    fireStore
        .collection(CollectionName.parcelRide)
        .where("driverId", isEqualTo: getCurrentUid())
        .where('bookingStatus', whereIn: [BookingStatus.bookingCompleted])
        .orderBy("createAt", descending: true)
        .snapshots()
        .listen((querySnapshot) {
          final updatedList = querySnapshot.docs.map((doc) => ParcelModel.fromJson(doc.data())).toList();
          onUpdate(updatedList);
        }, onError: (error) {
          log("Error fetching completed rides: $error");
          onUpdate([]);
        });
  }

  static void getParcelRejectedRides(Function(List<ParcelModel>) onUpdate) {
    fireStore
        .collection(CollectionName.parcelRide)
        .where("driverId", isEqualTo: getCurrentUid())
        .where('bookingStatus', whereIn: [BookingStatus.bookingCancelled, BookingStatus.bookingRejected])
        .orderBy("createAt", descending: true)
        .snapshots()
        .listen((querySnapshot) {
          final updatedList = querySnapshot.docs.map((doc) => ParcelModel.fromJson(doc.data())).toList();
          onUpdate(updatedList);
        }, onError: (error) {
          log("Error fetching rejected rides: $error");
          onUpdate([]);
        });
  }

  static void getRentalActiveRides(Function(List<RentalBookingModel>) onUpdate) {
    final isFemaleDriver = (Constant.userModel!.gender?.toLowerCase() == 'female');
    fireStore
        .collection(CollectionName.rentalRide)
        .where("driverId", isEqualTo: getCurrentUid())
        .where('bookingStatus', whereIn: [BookingStatus.bookingPlaced])
        .orderBy("createAt", descending: true)
        .snapshots()
        .listen((querySnapshot) {
          List<RentalBookingModel> allRides = querySnapshot.docs.map((doc) => RentalBookingModel.fromJson(doc.data())).toList();

          List<RentalBookingModel> filteredRides = allRides.where((ride) {
            if (ride.isOnlyForFemale == true && !isFemaleDriver) {
              return false;
            }
            return true;
          }).toList();

          onUpdate(filteredRides);
        }, onError: (error) {
          log("Error fetching ongoing rides: $error");
          onUpdate([]);
        });
  }

  static void getRentalOngoingRides(Function(List<RentalBookingModel>) onUpdate) {
    fireStore
        .collection(CollectionName.rentalRide)
        .where("driverId", isEqualTo: getCurrentUid())
        .where('bookingStatus', whereIn: [BookingStatus.bookingOngoing, BookingStatus.bookingAccepted])
        .orderBy("createAt", descending: true)
        .snapshots()
        .listen((querySnapshot) {
          List<RentalBookingModel> bookingList = querySnapshot.docs.map((doc) => RentalBookingModel.fromJson(doc.data())).toList();
          onUpdate(bookingList);
        }, onError: (error) {
          log("Error fetching ongoing Rental rides: $error");
          onUpdate([]);
        });
  }

  static void getRentalCompletedRides(Function(List<RentalBookingModel>) onUpdate) {
    fireStore
        .collection(CollectionName.rentalRide)
        .where("driverId", isEqualTo: getCurrentUid())
        .where('bookingStatus', whereIn: [BookingStatus.bookingCompleted])
        .orderBy("createAt", descending: true)
        .snapshots()
        .listen((querySnapshot) {
          List<RentalBookingModel> updatedList = querySnapshot.docs.map((doc) => RentalBookingModel.fromJson(doc.data())).toList();
          onUpdate(updatedList);
        }, onError: (error) {
          log("Error fetching completed Rental rides: $error");
          onUpdate([]);
        });
  }

  static void getRentalRejectedRides(Function(List<RentalBookingModel>) onUpdate) {
    fireStore
        .collection(CollectionName.rentalRide)
        .where("driverId", isEqualTo: getCurrentUid())
        .where('bookingStatus', whereIn: [BookingStatus.bookingCancelled, BookingStatus.bookingRejected])
        .orderBy("createAt", descending: true)
        .snapshots()
        .listen((querySnapshot) {
          final updatedList = querySnapshot.docs.map((doc) => RentalBookingModel.fromJson(doc.data())).toList();
          onUpdate(updatedList);
        }, onError: (error) {
          log("Error fetching rejected rides: $error");
          onUpdate([]);
        });
  }

  static Future<List<IntercityModel>> getDataForPdfInterCity(DateTimeRange? dateTimeRange) async {
    final interCityModelList = <IntercityModel>[];
    try {
      final querySnapshot = await fireStore
          .collection(CollectionName.interCityRide)
          .where("driverId", isEqualTo: getCurrentUid())
          .where('createAt', isGreaterThanOrEqualTo: dateTimeRange!.start, isLessThanOrEqualTo: dateTimeRange.end)
          .orderBy('createAt', descending: true)
          .get();
      for (var element in querySnapshot.docs) {
        interCityModelList.add(IntercityModel.fromJson(element.data()));
      }
    } catch (error) {
      log("Error $error");
    }
    return interCityModelList;
  }

  static Future<List<BookingModel>> getDataForPdfCab(DateTimeRange? dateTimeRange) async {
    final cabModelList = <BookingModel>[];
    try {
      final querySnapshot = await fireStore
          .collection(CollectionName.bookings)
          .where("driverId", isEqualTo: getCurrentUid())
          .where('createAt', isGreaterThanOrEqualTo: dateTimeRange!.start, isLessThanOrEqualTo: dateTimeRange.end)
          .orderBy('createAt', descending: true)
          .get();
      for (var element in querySnapshot.docs) {
        cabModelList.add(BookingModel.fromJson(element.data()));
      }
    } catch (error) {
      log("Error $error");
    }
    return cabModelList;
  }

  static Future<List<ParcelModel>> getDataForPdfParcel(DateTimeRange? dateTimeRange) async {
    List<ParcelModel> parcelList = [];
    try {
      final querySnapshot = await fireStore
          .collection(CollectionName.parcelRide)
          .where("driverId", isEqualTo: getCurrentUid())
          .where('createAt', isGreaterThanOrEqualTo: dateTimeRange!.start, isLessThanOrEqualTo: dateTimeRange.end)
          .orderBy('createAt', descending: true)
          .get();
      for (var element in querySnapshot.docs) {
        parcelList.add(ParcelModel.fromJson(element.data()));
      }
    } catch (error) {
      log("Error $error");
    }
    return parcelList;
  }

  static Future<List<SubscriptionModel>> getSubscription() async {
    List<SubscriptionModel> subscriptionList = [];
    try {
      final value = await fireStore.collection(CollectionName.subscriptionPlans).where("isEnable", isEqualTo: true).orderBy("createdAt", descending: false).get();
      for (var element in value.docs) {
        subscriptionList.add(SubscriptionModel.fromJson(element.data()));
      }
    } catch (error) {
      log(error.toString());
    }
    log("Subscription list length: ${subscriptionList.length}");
    return subscriptionList;
  }

  static Future<bool> setSubscriptionHistory(SubscriptionHistoryModel subscriptionHistoryModel) async {
    try {
      await fireStore.collection(CollectionName.subscriptionHistory).doc(subscriptionHistoryModel.id).set(subscriptionHistoryModel.toJson());
      return true;
    } catch (error, stackTrace) {
      log("Failed to update subscription history: $error\n$stackTrace");
      return false;
    }
  }

  Stream<List<SubscriptionHistoryModel>> getPurchasedSubscription(String driverId) {
    return fireStore
        .collection(CollectionName.subscriptionHistory)
        .where("driverId", isEqualTo: driverId)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) {
              try {
                return SubscriptionHistoryModel.fromJson(doc.data());
              } catch (e, st) {
                log("Failed to parse subscription history: $e\n$st");
                return null;
              }
            })
            .whereType<SubscriptionHistoryModel>()
            .toList());
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

  static Future<List<ReviewModel>> getReview(String bookingId) async {
    List<ReviewModel> reviewList = [];
    try {
      final value = await fireStore.collection(CollectionName.review).where("bookingId", isEqualTo: bookingId).where("type", isEqualTo: "customer").get();
      for (var element in value.docs) {
        reviewList.add(ReviewModel.fromJson(element.data()));
      }
    } catch (error) {
      log(error.toString());
    }
    return reviewList;
  }

  static Future<List<OnBoardingModel>> getOnboarding() async {
    List<OnBoardingModel> onboardingList = [];
    try {
      await FirebaseFirestore.instance
          .collection(CollectionName.onBoarding)
          .where("status", isEqualTo: true)
          .where("type", isEqualTo: "driver")
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

  static Future<bool> setLoyaltyPointTransaction(LoyaltyPointTransactionModel loyaltyPointTransactionModel) async {
    try {
      await fireStore.collection(CollectionName.loyaltyPointHistory).doc(loyaltyPointTransactionModel.id).set(loyaltyPointTransactionModel.toJson());
      return true;
    } catch (error) {
      log("Failed to add ride: $error");
      return false;
    }
  }

  static Future<bool> addEmergencyContact(EmergencyContactModel contactModel) async {
    try {
      await fireStore.collection(CollectionName.drivers).doc(getCurrentUid()).collection('emergency_contacts').doc(contactModel.id).set(contactModel.toJson());
      return true;
    } catch (e) {
      log("Failed to add emergency contacts: $e");
      return false;
    }
  }

  static StreamSubscription<QuerySnapshot> getEmergencyContacts(Function(List<EmergencyContactModel>) onUpdate) {
    return fireStore.collection(CollectionName.drivers).doc(getCurrentUid()).collection('emergency_contacts').snapshots().listen((querySnapshot) {
      final updatedList = querySnapshot.docs.map((doc) => EmergencyContactModel.fromJson(doc.data())).toList();
      onUpdate(updatedList);
    }, onError: (error) {
      log("Error fetching emergency contacts: $error");
      onUpdate([]);
    });
  }

  static Future<bool> deleteEmergencyContact(String personId) async {
    try {
      await fireStore.collection(CollectionName.drivers).doc(getCurrentUid()).collection('emergency_contacts').doc(personId).delete();
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
      final query = await fireStore.collection(CollectionName.sosAlerts).where("userId", isEqualTo: getCurrentUid()).where("type", isEqualTo: Constant.typeDriver).get();
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

// ignore_for_file: unnecessary_overrides

import 'dart:async';

import 'package:driver/app/models/booking_model.dart';
import 'package:driver/constant/booking_status.dart';
import 'package:driver/constant/collection_name.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:get/get.dart';

class CabRidesController extends GetxController {
  var selectedType = 0.obs;

  RxList<BookingModel> bookingsCancelledList = <BookingModel>[].obs;
  RxList<BookingModel> bookingsOnGoingList = <BookingModel>[].obs;
  RxList<BookingModel> bookingsCompletedList = <BookingModel>[].obs;
  RxList<BookingModel> bookingsRejectedList = <BookingModel>[].obs;
  RxList<BookingModel> newRideList = <BookingModel>[].obs;

  StreamSubscription? _newRideSub;
  StreamSubscription? _ongoingSub;
  StreamSubscription? _cancelledSub;
  StreamSubscription? _completedSub;
  StreamSubscription? _rejectedSub;

  @override
  void onInit() {
    getBookingData();
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    _newRideSub?.cancel();
    _ongoingSub?.cancel();
    _cancelledSub?.cancel();
    _completedSub?.cancel();
    _rejectedSub?.cancel();
    super.onClose();
  }

  void getBookingData() {
    _newRideSub?.cancel();
    _ongoingSub?.cancel();
    _cancelledSub?.cancel();
    _completedSub?.cancel();
    _rejectedSub?.cancel();

    _newRideSub = FireStoreUtils.fireStore
        .collection(CollectionName.bookings)
        .where('bookingStatus', whereIn: [BookingStatus.bookingPlaced, BookingStatus.driverAssigned])
        .where('driverId', isEqualTo: FireStoreUtils.getCurrentUid())
        .orderBy('createAt', descending: true)
        .snapshots()
        .listen((event) {
          for (var document in event.docs) {
            final data = document.data();
            BookingModel bookingModel = BookingModel.fromJson(data);
            newRideList.add(bookingModel);
          }
        });

    _ongoingSub = FireStoreUtils.fireStore
        .collection(CollectionName.bookings)
        .where('bookingStatus', whereIn: [BookingStatus.bookingOngoing, BookingStatus.bookingAccepted, BookingStatus.bookingOnHold])
        .where('driverId', isEqualTo: FireStoreUtils.getCurrentUid())
        .orderBy('createAt', descending: true)
        .snapshots()
        .listen((event) {
          for (var document in event.docs) {
            final data = document.data();
            BookingModel bookingModel = BookingModel.fromJson(data);
            bookingsOnGoingList.add(bookingModel);
          }
        });

    _cancelledSub = FireStoreUtils.fireStore
        .collection(CollectionName.bookings)
        .where('bookingStatus', isEqualTo: BookingStatus.bookingCancelled)
        .where('driverId', isEqualTo: FireStoreUtils.getCurrentUid())
        .snapshots()
        .listen((event) {
      for (var document in event.docs) {
        final data = document.data();
        BookingModel bookingModel = BookingModel.fromJson(data);
        bookingsCancelledList.add(bookingModel);
      }
    });

    _completedSub = FireStoreUtils.fireStore
        .collection(CollectionName.bookings)
        .where('bookingStatus', isEqualTo: BookingStatus.bookingCompleted)
        .where('driverId', isEqualTo: FireStoreUtils.getCurrentUid())
        .orderBy('createAt', descending: true)
        .snapshots()
        .listen((event) {
      for (var document in event.docs) {
        final data = document.data();
        BookingModel bookingModel = BookingModel.fromJson(data);
        bookingsCompletedList.add(bookingModel);
      }
    });

    _rejectedSub = FireStoreUtils.fireStore
        .collection(CollectionName.bookings)
        .where('rejectedDriverId', arrayContains: FireStoreUtils.getCurrentUid())
        .orderBy("createAt", descending: true)
        .snapshots()
        .listen((event) {
      for (var document in event.docs) {
        final data = document.data();
        BookingModel bookingModel = BookingModel.fromJson(data);
        bookingsRejectedList.add(bookingModel);
      }
    });
  }
}

// ignore_for_file: unnecessary_overrides
import 'dart:developer';

// ignore_for_file: depend_on_referenced_packages
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/app/models/driver_user_model.dart';
import 'package:driver/app/models/intercity_model.dart';
import 'package:driver/app/models/parcel_model.dart';
import 'package:driver/app/models/loyalty_point_transaction_model.dart';
import 'package:driver/app/models/review_customer_model.dart';
import 'package:driver/app/modules/search_intercity_ride/controllers/search_ride_controller.dart';
import 'package:driver/constant/collection_name.dart';
import 'package:driver/services/email_template_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:driver/app/models/user_model.dart';
import 'package:driver/constant/booking_status.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/constant/send_notification.dart';
import 'package:driver/constant_widgets/show_toast_dialog.dart';
import 'package:driver/utils/fire_store_utils.dart';

class ParcelBookingDetailsController extends GetxController {
  RxString bookingId = ''.obs;
  RxList<ReviewModel> reviewList = <ReviewModel>[].obs;
  Rx<ParcelModel> parcelModel = ParcelModel().obs;
  Rx<GlobalKey<FormState>> formKey = GlobalKey<FormState>().obs;
  TextEditingController enterBidAmountController = TextEditingController();
  RxBool isLoading = true.obs;
  RxBool isSearch = false.obs;

  Rx<ReviewModel> driverToCustomerReview = ReviewModel().obs;
  Rx<ReviewModel> customerToDriverReview = ReviewModel().obs;

  @override
  void onInit() {
    super.onInit();
    getBookingDetails();
    getReview();
  }

  Future<void> getReview() async {
    final snapshot = await FirebaseFirestore.instance.collection(CollectionName.review).get();
    reviewList.value = snapshot.docs.map((doc) => ReviewModel.fromJson(doc.data())).toList();

    try {
      customerToDriverReview.value = reviewList.firstWhere((r) => r.bookingId == parcelModel.value.id && r.type == Constant.typeDriver);
    } catch (_) {
      customerToDriverReview.value = ReviewModel();
    }

    try {
      driverToCustomerReview.value = reviewList.firstWhere((r) => r.bookingId == parcelModel.value.id && r.type == Constant.typeCustomer);
    } catch (_) {
      driverToCustomerReview.value = ReviewModel();
    }
  }

  Future<void> getBookingDetails() async {
    isLoading.value = true;
    final args = Get.arguments;
    if (args != null && args["bookingId"] != null) {
      bookingId.value = args["bookingId"];
      isSearch.value = args["isSearch"] ?? false;
      try {
        FireStoreUtils.getParcelRideDetails(bookingId.value).listen((ParcelModel? model) {
          if (model != null) {
            parcelModel.value = model;
          } else {
            log("⚠️ No booking details found for ID: \\${bookingId.value}");
          }
          isLoading.value = false;
        });
      } catch (error) {
        log(" Error fetching booking details: $error");
        isLoading.value = false;
      }
    } else {
      isLoading.value = false;
    }
  }

  Future<bool> completeParcelBooking(ParcelModel bookingModel) async {
    if (Constant.loyaltyProgram != null) {
      LoyaltyPointTransactionModel pointTransaction = LoyaltyPointTransactionModel(
        id: Constant.getUuid(),
        note: "Loyalty Point earned for Parcel Ride #${bookingModel.id!.substring(0, 5)}",
        customerId: bookingModel.customerId,
        transactionId: bookingModel.id,
        points: Constant.loyaltyProgram!.points ?? "0",
        isCredit: true,
        createdAt: Timestamp.now(),
      );

      await FireStoreUtils.setLoyaltyPointTransaction(pointTransaction);

      UserModel? userModel = await FireStoreUtils.getUserProfile(bookingModel.customerId ?? "");
      if (userModel != null) {
        int newCredits = int.parse(userModel.loyaltyCredits ?? "0") + int.parse(Constant.loyaltyProgram!.points ?? "0");
        userModel.loyaltyCredits = newCredits.toString();

        await FireStoreUtils.updateUser(userModel);
      }
    }

    bookingModel.bookingStatus = BookingStatus.bookingCompleted;
    bookingModel.updateAt = Timestamp.now();
    bookingModel.dropTime = Timestamp.now();
    bool? isStarted = await FireStoreUtils.setParcelBooking(bookingModel);
    ShowToastDialog.showToast("Your parcel ride is completed....".tr);

    UserModel? receiverUserModel = await FireStoreUtils.getUserProfile(bookingModel.customerId.toString());
    Map<String, dynamic> playLoad = <String, dynamic>{"bookingId": bookingModel.id};

    await SendNotification.sendOneNotification(
        type: "order",
        token: receiverUserModel!.fcmToken.toString(),
        title: 'Your Parcel Ride is Completed',
        customerId: receiverUserModel.id,
        senderId: FireStoreUtils.getCurrentUid(),
        bookingId: bookingModel.id.toString(),
        driverId: bookingModel.driverId.toString(),
        body: 'Your parcel ride has been successfully completed. Please take a moment to review your experience.',
        payload: playLoad,isBooking: false);

    await EmailTemplateService.sendEmail(
      type: "booking_completed",
      toEmail: receiverUserModel.email.toString(),
      variables: {
        "name": receiverUserModel.fullName.toString(),
        "booking_id": bookingModel.id.toString(),
        "pickup_location": bookingModel.pickUpLocationAddress.toString(),
        "drop_location": bookingModel.dropLocationAddress.toString(),
        "amount": Constant.calculateParcelFinalAmount(bookingModel).toString(),
        "booking_time": "${Constant.timestampToDate(bookingModel.createAt!)} ${Constant.timestampToTime12Hour(bookingModel.createAt)}"
      },
    );

    DriverUserModel? driverModel = await FireStoreUtils.getDriverUserProfile(bookingModel.driverId.toString());
    await EmailTemplateService.sendEmail(
      type: "booking_completed",
      toEmail: driverModel!.email.toString(),
      variables: {
        "name": driverModel.fullName.toString(),
        "booking_id": bookingModel.id.toString(),
        "pickup_location": bookingModel.pickUpLocationAddress.toString(),
        "drop_location": bookingModel.dropLocationAddress.toString(),
        "amount": Constant.calculateParcelFinalAmount(bookingModel).toString(),
        "booking_time": "${Constant.timestampToDate(bookingModel.createAt!)} ${Constant.timestampToTime12Hour(bookingModel.createAt)}"
      },
    );
    // Get.offAll(const HomeView());
    return (isStarted);
  }

  Future<void> saveBidDetail() async {
    ShowToastDialog.showLoader('Please Wait..'.tr);
    BidModel bidModel = BidModel();
    bidModel.driverID = FireStoreUtils.getCurrentUid();
    bidModel.bidStatus = 'pending';
    bidModel.amount = enterBidAmountController.value.text;
    bidModel.id = Constant.getUuid();
    bidModel.createAt = Timestamp.now();
    // bidModel.driverVehicleDetails = Constant.userModel!.driverVehicleDetails;
    parcelModel.value.driverBidIdList!.add(FireStoreUtils.getCurrentUid());
    parcelModel.value.bidList!.add(bidModel);

    await FireStoreUtils.setParcelBooking(parcelModel.value);

    if (isSearch.value == true) {
      SearchRideController searchController = Get.put(SearchRideController());
      searchController.searchParcelList.removeWhere((parcel) => parcel.id == parcelModel.value.id);
      searchController.parcelBookingList.removeWhere((parcel) => parcel.id == parcelModel.value.id);
      ShowToastDialog.closeLoader();
    }
  }
}

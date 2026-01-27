// ignore_for_file: depend_on_referenced_packages
import 'dart:developer';

import 'package:admin/app/constant/collection_name.dart';
import 'package:admin/app/constant/constants.dart';
import 'package:admin/app/constant/send_notification.dart';
import 'package:admin/app/constant/show_toast.dart';
import 'package:admin/app/models/booking_model.dart';
import 'package:admin/app/models/driver_user_model.dart';
import 'package:admin/app/models/payout_request_model.dart';
import 'package:admin/app/models/subscription_plan_history.dart';
import 'package:admin/app/models/wallet_transaction_model.dart';
import 'package:admin/app/routes/app_pages.dart';
import 'package:admin/app/utils/fire_store_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class DriverDetailScreenController extends GetxController {
  final ScrollController scrollController = ScrollController();

  RxString title = "Driver Detail".tr.obs;
  RxString bookingTitle = "Booking Details".tr.obs;
  RxString subscriptionHistoryTitle = "Subscription History".tr.obs;
  RxString walletTransactionTitle = "Wallet Transaction History".tr.obs;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  RxBool isLoading = true.obs;
  Rx<DriverUserModel> driverUserModel = DriverUserModel().obs;
  RxList<BookingModel> driverDetailsList = <BookingModel>[].obs;
  RxList<BookingModel> bookingList = <BookingModel>[].obs;
  Rx<TextEditingController> topupController = TextEditingController().obs;
  RxList<WalletTransactionModel> walletTransactionList = <WalletTransactionModel>[].obs;
  RxList<WalletTransactionModel> currentPageWalletTransaction = <WalletTransactionModel>[].obs;

  var currentPage = 1.obs;
  var startIndex = 1.obs;
  var endIndex = 1.obs;
  var totalPage = 1.obs;
  RxList<BookingModel> currentPageBooking = <BookingModel>[].obs;
  RxList<SubscriptionHistoryModel> currentPageSubscriptionHistory = <SubscriptionHistoryModel>[].obs;
  RxList<SubscriptionHistoryModel> subscriptionHistoryList = <SubscriptionHistoryModel>[].obs;
  RxList<BankDetailsModel> bankList = <BankDetailsModel>[].obs;

  Rx<TextEditingController> dateFiledController = TextEditingController().obs;
  RxString selectedPayoutStatus = "All".obs;
  RxString selectedPayoutStatusForData = "All".obs;
  List<String> payoutStatus = [
    "All",
    "Place",
    "Complete",
    "Rejected",
    "Cancelled",
    "Accepted",
    "OnGoing",
  ];

  RxString selectedDateOption = "All".obs;
  List<String> dateOption = ["All", "Last Month", "Last 6 Months", "Last Year", "Custom"];

  @override
  void onInit() {
    super.onInit();
    totalItemPerPage.value = Constant.numOfPageIemList.first;
    _initializeData();
  }

  Future<void> _initializeData() async {
    isLoading.value = true;
    try {
      await _getArgument();
      totalItemPerPage.value = Constant.numOfPageIemList.first;
      await getBookings();
      getDriverBankDetails();
      dateFiledController.value.text = "${DateFormat('yyyy-MM-dd').format(selectedDate.value.start)} to ${DateFormat('yyyy-MM-dd').format(selectedDate.value.end)}";
      await getWalletTransactions();
      await getSubscriptionHistory();
    } catch (e, stack) {
      log('Error initializing driver detail: $e\n$stack');
      Get.offAllNamed(Routes.ERROR_SCREEN);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _getArgument() async {
    String driverId = Get.parameters['driverId']!;
    log("==============> Driver ID: $driverId");

    await FireStoreUtils.getDriverByDriverID(driverId).then((driver) {
      if (driver != null) {
        driverUserModel.value = driver;
      } else {
        throw Exception('Driver not found');
      }
    });
    isLoading.value = false;
  }

  Future<void> getBookingDataForConverter() async {
    if (selectedPayoutStatus.value == "Rejected") {
      selectedPayoutStatusForData.value = "booking_rejected";
      await getBookings();
    } else if (selectedPayoutStatus.value == "Place") {
      selectedPayoutStatusForData.value = "booking_placed";
      await getBookings();
    } else if (selectedPayoutStatus.value == "Complete") {
      selectedPayoutStatusForData.value = "booking_completed";
      await getBookings();
    } else if (selectedPayoutStatus.value == "Cancelled") {
      selectedPayoutStatusForData.value = 'booking_cancelled';
      await getBookings();
    } else if (selectedPayoutStatus.value == "Accepted") {
      selectedPayoutStatusForData.value = 'booking_accepted';
      await getBookings();
    } else if (selectedPayoutStatus.value == "OnGoing") {
      selectedPayoutStatusForData.value = 'booking_ongoing';
      await getBookings();
    } else {
      // booking_accepted
      selectedPayoutStatusForData.value = "All";
      await getBookings();
    }
  }

  Future<void> removeBooking(BookingModel bookingModel) async {
    isLoading = true.obs;
    await FirebaseFirestore.instance.collection(CollectionName.bookings).doc(bookingModel.id).delete().then((value) {
      ShowToastDialog.successToast("Booking deleted...!".tr);
    }).catchError((error) {
      ShowToastDialog.errorToast("Something went wrong".tr);
    });
    isLoading = false.obs;
  }

  Future<void> getBookings() async {
    isLoading.value = true;
    bookingList.value = await FireStoreUtils.getBookingByDriverId(selectedPayoutStatusForData.value, driverUserModel.value.id);
    setPagination(totalItemPerPage.value);
    isLoading.value = false;
  }

  Rx<DateTimeRange> selectedDate = DateTimeRange(
          start: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 0, 0, 0),
          end: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 23, 59, 0))
      .obs;

  void setPagination(String page) {
    totalItemPerPage.value = page;
    int itemPerPage = pageValue(page);
    totalPage.value = (bookingList.length / itemPerPage).ceil();
    startIndex.value = (currentPage.value - 1) * itemPerPage;
    endIndex.value = (currentPage.value * itemPerPage) > bookingList.length ? bookingList.length : (currentPage.value * itemPerPage);
    if (endIndex.value < startIndex.value) {
      currentPage.value = 1;
      setPagination(page);
    } else {
      currentPageBooking.value = bookingList.sublist(startIndex.value, endIndex.value);
    }
    isLoading.value = false;
    update();
  }

  RxString totalItemPerPage = '0'.obs;

  int pageValue(String data) {
    if (data == 'All') {
      return bookingList.length;
    } else {
      return int.parse(data);
    }
  }

  Future<void> completeOrder(String transactionId) async {
    WalletTransactionModel transactionModel = WalletTransactionModel(
        id: Constant.getUuid(),
        amount: topupController.value.text,
        createdDate: Timestamp.now(),
        paymentType: "wallet",
        transactionId: transactionId,
        userId: driverUserModel.value.id!,
        isCredit: true,
        type: "driver",
        note: "Wallet Top up by admin");
    ShowToastDialog.showLoader("Please wait".tr);
    try {
      await FireStoreUtils.setWalletTransaction(transactionModel).then((value) async {
        if (value == true) {
          await FireStoreUtils.updateDriverWallet(amount: topupController.value.text, userId: driverUserModel.value.id!).then((value) async {});
        }
      });
      driverUserModel.value = (await FireStoreUtils.getDriverByDriverID(driverUserModel.value.id!))!;
      Get.back();
      ShowToastDialog.closeLoader();
      ShowToastDialog.successToast("Amount added in wallet.");
      Map<String, dynamic> payLoad = <String, dynamic>{"bookingId": ""};
      if (driverUserModel.value.fcmToken != null && driverUserModel.value.fcmToken!.isNotEmpty) {
        await SendNotification.sendOneNotification(
            isBooking: false,
            token: driverUserModel.value.fcmToken.toString(),
            title: "Wallet Top-Up Successful",
            body: "${Constant.amountShow(amount: topupController.value.text)} has been successfully added to your wallet by the Admin.",
            type: "wallet-topup",
            payload: payLoad,
            senderId: FireStoreUtils.getCurrentUid(),
            driverId: driverUserModel.value.id.toString(),
            bookingId: "");
      }
    } catch (e) {
      ShowToastDialog.toast("An error occurred. Please try again.");
    } finally {
      ShowToastDialog.closeLoader();
    }
  }

  Future<void> getWalletTransactions() async {
    await FireStoreUtils.getWalletTransactionOfUser(driverUserModel.value.id!, "driver").then((value) {
      walletTransactionList.value = value;
      setPaginationForTransactionHistory(totalItemPerPage.value);
    });
  }

  void setDefaultData() {
    currentPage = 1.obs;
    startIndex = 1.obs;
    endIndex = 1.obs;
    totalPage = 1.obs;
  }

  void setPaginationForTransactionHistory(String page) {
    totalItemPerPage.value = page;
    int itemPerPage = pageValue(page);
    totalPage.value = (walletTransactionList.length / itemPerPage).ceil();
    startIndex.value = (currentPage.value - 1) * itemPerPage;
    endIndex.value = (currentPage.value * itemPerPage) > walletTransactionList.length ? walletTransactionList.length : (currentPage.value * itemPerPage);
    if (endIndex.value < startIndex.value) {
      currentPage.value = 1;
      setPagination(page);
    } else {
      currentPageWalletTransaction.value = walletTransactionList.sublist(startIndex.value, endIndex.value);
    }
    isLoading.value = false;
    update();
  }

  Future<void> getSubscriptionHistory() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(CollectionName.subscriptionHistory)
          .where('driverId', isEqualTo: driverUserModel.value.id)
          .orderBy('createdAt', descending: true)
          .get();

      subscriptionHistoryList.value = snapshot.docs.map((e) => SubscriptionHistoryModel.fromJson(e.data())).toList();

      setPaginationForSubscriptionHistory(totalItemPerPage.value);
    } catch (e) {
      log('Error fetching subscription history: $e');
    }
  }

  void setPaginationForSubscriptionHistory(String page) {
    totalItemPerPage.value = page;
    int itemPerPage = pageValue(page);

    totalPage.value = (subscriptionHistoryList.length / itemPerPage).ceil();
    startIndex.value = (currentPage.value - 1) * itemPerPage;
    endIndex.value = (currentPage.value * itemPerPage) > subscriptionHistoryList.length ? subscriptionHistoryList.length : (currentPage.value * itemPerPage);

    if (endIndex.value < startIndex.value) {
      currentPage.value = 1;
      setPaginationForSubscriptionHistory(page);
    } else {
      currentPageSubscriptionHistory.value = subscriptionHistoryList.sublist(startIndex.value, endIndex.value);
    }

    update();
  }

  Future<void> getDriverBankDetails() async {
    await FireStoreUtils.fireStore.collection(CollectionName.bankDetails).where('driverID', isEqualTo: driverUserModel.value.id.toString()).get().then(
      (value) {
        bankList.value = value.docs.map((e) => BankDetailsModel.fromJson(e.data())).toList();
      },
    );
  }

  void checkAndVerifyDriver() async {
    final docs = driverUserModel.value.verifyDocument;

    if (docs == null || docs.isEmpty) return;

    bool allVerified = docs.every((doc) => doc.isVerify == true);

    if (allVerified && driverUserModel.value.isVerified != true) {
      driverUserModel.value.isVerified = true;
      await FireStoreUtils.updateDriver(driverUserModel.value);

      update(); // refresh UI
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}

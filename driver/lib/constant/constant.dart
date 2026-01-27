// ignore_for_file: strict_top_level_inference

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

// ignore_for_file: depend_on_referenced_packages
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/app/models/admin_commission.dart';
import 'package:driver/app/models/booking_model.dart';
import 'package:driver/app/models/currencies_model.dart';
import 'package:driver/app/models/driver_user_model.dart';
import 'package:driver/app/models/loyalty_point_model.dart';
import 'package:driver/app/models/rental_booking_model.dart';
import 'package:driver/app/models/time_slots_charge_model.dart';
import 'package:driver/app/models/intercity_model.dart';
import 'package:driver/app/models/language_model.dart';
import 'package:driver/app/models/location_lat_lng.dart';
import 'package:driver/app/models/map_model.dart';
import 'package:driver/app/models/parcel_model.dart';
import 'package:driver/app/models/payment_method_model.dart';
import 'package:driver/app/models/tax_model.dart';
import 'package:driver/constant_widgets/show_toast_dialog.dart';
import 'package:driver/extension/string_extensions.dart';
import 'package:driver/theme/app_them_data.dart';
import 'package:driver/utils/dark_theme_provider.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import '../utils/preferences.dart';
import 'package:location/location.dart' as loc;

class Constant {
  static const String phoneLoginType = "phone";
  static const String googleLoginType = "google";
  static const String appleLoginType = "apple";
  static const String profileConstant =
      "https://firebasestorage.googleapis.com/v0/b/gocab-a8627.appspot.com/o/constant_assets%2F59.png?alt=media&token=a0b1aebd-9c01-45f6-9569-240c4bc08e23";
  static const String placeHolder =
      "https://firebasestorage.googleapis.com/v0/b/mytaxi-a8627.appspot.com/o/constant_assets%2Fno-image.png?alt=media&token=e3dc71ac-b600-45aa-8161-5eac1f58d68c";
  static String appName = '';
  static String? appColor;
  static DriverUserModel? userModel;
  static LocationLatLng? currentLocation;
  static const userPlaceHolder = 'assets/images/user_placeholder.png';
  static String mapAPIKey = "";
  static String senderId = "";
  static String jsonFileURL = "";
  static String radius = "100";
  static double interCityRadius = 100.0;
  static String distanceType = "";
  static bool isInterCityBid = false;
  static bool isParcelBid = false;
  static bool isInterCitySharingBid = false;
  static bool isCabAvailable = false;
  static bool? isRentalAvailable = true;
  static String termsAndConditions = "";
  static String privacyPolicy = "";
  static String aboutApp = "";
  static String supportURL = "";
  static String minimumAmountToDeposit = "0.0";
  static String minimumAmountToWithdrawal = "0.0";
  static String minimumAmountToAcceptRide = "0.0";
  static String? referralAmount = "0.0";
  static String driverLocationUpdate = "10";
  static CurrencyModel? currencyModel = CurrencyModel(
      id: "",
      code: "USD",
      decimalDigits: 2,
      active: true,
      name: "US Dollar",
      symbol: "\$",
      symbolAtRight: false);
  static List<dynamic> cancellationReason = [];

  static List<TaxModel>? taxList;
  static String? country;
  static String? selectedMap;

  static String? countryCode = '+91';
  static String? sosAlertNumber = "112";

  static AdminCommission? adminCommission;
  static PaymentModel? paymentModel;
  static LoyaltyPointModel? loyaltyProgram;
  static bool? isOtpFeatureEnable = true;
  static bool? isSubscriptionEnable = false;
  static bool? isDocumentVerificationEnable = true;
  static bool? isDriverAutoApproved = false;
  static const String typeDriver = "driver";
  static const String typeCustomer = "customer";

  static RxList<TimeSlotsChargesModel> parcelDocuments =
      <TimeSlotsChargesModel>[].obs;
  static RxList<TimeSlotsChargesModel> intercitySharingDocuments =
      <TimeSlotsChargesModel>[].obs;
  static RxList<TimeSlotsChargesModel> intercityPersonalDocuments =
      <TimeSlotsChargesModel>[].obs;
  static RxList<TimeSlotsChargesModel> cabDocuments =
      <TimeSlotsChargesModel>[].obs;

  static String amountShow({required String? amount}) {
    if (Constant.currencyModel!.symbolAtRight == true) {
      return "${double.parse(amount.toString()).toStringAsFixed(Constant.currencyModel!.decimalDigits!)}${Constant.currencyModel!.symbol.toString()}";
    } else {
      return "${Constant.currencyModel!.symbol.toString()} ${double.parse(amount.toString()).toStringAsFixed(Constant.currencyModel!.decimalDigits!)}";
    }
  }

  static const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz0123456789';
  static final math.Random _rnd = math.Random();

  static String getUuid() {
    return const Uuid().v4();
  }

  static Widget loader() {
    return Center(
      child:
          Lottie.asset('assets/animation/loder.json', height: 100, width: 100),
    );
  }

  static Widget showEmptyView({required String message}) {
    return Center(
      child: Text(message, style: GoogleFonts.inter(fontSize: 18)),
    );
  }

  static String getReferralCode(String firstTwoChar) {
    var rng = math.Random();
    return firstTwoChar + (rng.nextInt(9000) + 1000).toString();
  }

  static String getRandomString(int length) {
    String randomString = String.fromCharCodes(Iterable.generate(
        length - 1, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
    // print("Random String :- $randomString");
    int underScorePosition = _rnd.nextInt(length);
    // print("UnderScore Position :- $underScorePosition");
    return '${randomString.substring(0, underScorePosition)}_${randomString.substring(underScorePosition)}';
  }

  //
  // double calculateTax({String? amount, TaxModel? taxModel}) {
  //   double taxAmount = 0.0;
  //   if (taxModel != null && taxModel.enable == true) {
  //     if (taxModel.type == "fix") {
  //       taxAmount = double.parse(taxModel.tax.toString());
  //     } else {
  //       taxAmount = (double.parse(amount.toString()) * double.parse(taxModel.tax!.toString())) / 100;
  //     }
  //   }
  //   return taxAmount;
  // }

  static InputDecoration defaultInputDecoration(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return InputDecoration(
        iconColor: AppThemData.primary500,
        isDense: true,
        filled: true,
        fillColor: themeChange.isDarkTheme()
            ? AppThemData.grey900
            : AppThemData.grey50,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        disabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(100)),
          borderSide: BorderSide(
            color: themeChange.isDarkTheme()
                ? AppThemData.grey900
                : AppThemData.grey50,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(100)),
          borderSide: BorderSide(
            color: themeChange.isDarkTheme()
                ? AppThemData.grey900
                : AppThemData.grey50,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(100)),
          borderSide: BorderSide(
            color: themeChange.isDarkTheme()
                ? AppThemData.grey900
                : AppThemData.grey50,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(100)),
          borderSide: BorderSide(
            color: themeChange.isDarkTheme()
                ? AppThemData.grey900
                : AppThemData.grey50,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(100)),
          borderSide: BorderSide(
            color: themeChange.isDarkTheme()
                ? AppThemData.grey900
                : AppThemData.grey50,
          ),
        ),
        hintText: "Select Brand",
        hintStyle: TextStyle(
          fontSize: 16,
          color: themeChange.isDarkTheme()
              ? AppThemData.grey25
              : AppThemData.grey950,
          fontWeight: FontWeight.w500,
        ));
  }

  static Future<bool> isPermissionApplied() async {
    try {
      loc.Location location = loc.Location();
      loc.PermissionStatus permissionStatus = await location.hasPermission();
      bool serviceEnabled = await location.serviceEnabled();

      print(
          "Permission Status: $permissionStatus, Service Enabled: $serviceEnabled");

      if ((permissionStatus == loc.PermissionStatus.granted ||
              permissionStatus == loc.PermissionStatus.grantedLimited) &&
          serviceEnabled) {
        // Permission granted and service enabled
        return true;
      }

      // Permission denied forever
      else if (permissionStatus == loc.PermissionStatus.deniedForever) {
        ShowToastDialog.showToast(
          "Location permission is permanently denied. Please enable it from app settings."
              .tr,
        );
        return false;
      }

      // Permission denied but not forever
      else if (permissionStatus == loc.PermissionStatus.denied) {
        ShowToastDialog.showToast(
          "Location permission denied. Please allow access to continue.".tr,
        );
        return false;
      }

      // Location service disabled
      else if (!serviceEnabled) {
        ShowToastDialog.showToast(
          "Location services are turned off. Please enable GPS to continue.".tr,
        );
        return false;
      }

      return false;
    } catch (e) {
      // Catch any unexpected error
      ShowToastDialog.showToast(
        "An error occurred while checking permissions. Please try again.".tr,
      );
      return false;
    }
  }

  static Future<bool> isLocationServiceEnabled() async {
    loc.Location location = loc.Location();
    return await location.serviceEnabled();
  }

  static double calculateAdminCommission(
      {String? amount, AdminCommission? adminCommission}) {
    double taxAmount = 0.0;
    if (adminCommission != null && adminCommission.active == true) {
      if ((adminCommission.isFix ?? false)) {
        taxAmount = double.parse(adminCommission.value.toString());
      } else {
        taxAmount = (double.parse(amount.toString()) *
                double.parse(adminCommission.value!.toString())) /
            100;
      }
    }
    return taxAmount;
  }

  static String calculateReview(
      {required String? reviewCount, required String? reviewSum}) {
    final double count = double.tryParse(reviewCount ?? "0") ?? 0;
    final double sum = double.tryParse(reviewSum ?? "0") ?? 0;

    if (count == 0 || sum == 0) {
      return "0.0";
    }

    return (sum / count).toStringAsFixed(1);
  }

  static String amountToShow({required String? amount}) {
    double value = 0.0;

    if (amount != null && amount.isNotEmpty) {
      try {
        value = double.parse(amount);
      } catch (e) {
        value = 0.0;
      }
    }

    if (Constant.currencyModel!.symbolAtRight == true) {
      return "${value.toStringAsFixed(Constant.currencyModel!.decimalDigits!)}${Constant.currencyModel!.symbol.toString()}";
    } else {
      return "${Constant.currencyModel!.symbol.toString()} ${value.toStringAsFixed(Constant.currencyModel!.decimalDigits!)}";
    }
  }

  static double calculateTax({String? amount, TaxModel? taxModel}) {
    double taxAmount = 0.0;
    if (taxModel != null && taxModel.active == true) {
      if (taxModel.isFix == true) {
        taxAmount = double.parse(taxModel.value.toString());
      } else {
        taxAmount = (double.parse(amount.toString()) *
                double.parse(taxModel.value!.toString())) /
            100;
      }
    }
    return taxAmount;
  }

  static double amountBeforeTax(BookingModel bookingModel) {
    return ((double.parse(bookingModel.subTotal ?? '0.0') +
            (double.parse(bookingModel.nightCharge ?? '0.0')) +
            (double.parse(bookingModel.holdCharges ?? '0.0'))) -
        double.parse((bookingModel.discount ?? '0.0').toString()));
  }

  static double amountInterCityBeforeTax(IntercityModel bookingModel) {
    return ((double.parse(bookingModel.subTotal ?? '0.0') +
            (double.parse(bookingModel.holdCharges ?? '0.0'))) -
        double.parse((bookingModel.discount ?? '0.0').toString()));
  }

  static double calculateFinalAmount(BookingModel bookingModel) {
    RxString taxAmount = "0.0".obs;
    for (var element in (bookingModel.taxList ?? [])) {
      taxAmount.value = (double.parse(taxAmount.value) +
              Constant.calculateTax(
                  amount: (((double.parse(bookingModel.subTotal ?? '0.0')) +
                              (double.parse(
                                  bookingModel.nightCharge ?? '0.0')) +
                              (double.parse(
                                  bookingModel.holdCharges ?? '0.0'))) -
                          double.parse(
                              (bookingModel.discount ?? '0.0').toString()))
                      .toString(),
                  taxModel: element))
          .toStringAsFixed(Constant.currencyModel!.decimalDigits!);
    }
    return ((double.parse(bookingModel.subTotal ?? '0.0')) +
            (double.parse(bookingModel.nightCharge ?? '0.0')) +
            (double.parse(bookingModel.holdCharges ?? '0.0'))) -
        double.parse((bookingModel.discount ?? '0.0').toString()) +
        double.parse(taxAmount.value);
  }

  static double calculateInterCityFinalAmount(IntercityModel interCityModel) {
    RxString taxAmount = "0.0".obs;
    for (var element in (interCityModel.taxList ?? [])) {
      taxAmount.value = (double.parse(taxAmount.value) +
              Constant.calculateTax(
                  amount: (((double.parse(interCityModel.subTotal ?? '0.0')) +
                              (double.parse(
                                  interCityModel.holdCharges ?? '0.0'))) -
                          double.parse(
                              (interCityModel.discount ?? '0.0').toString()))
                      .toString(),
                  taxModel: element))
          .toStringAsFixed(Constant.currencyModel!.decimalDigits!);
    }
    return ((double.parse(interCityModel.subTotal ?? '0.0')) +
            (double.parse(interCityModel.holdCharges ?? '0.0')) -
            double.parse((interCityModel.discount ?? '0.0').toString())) +
        double.parse(taxAmount.value);
  }

  static double calculateParcelFinalAmount(ParcelModel interCityModel) {
    RxString taxAmount = "0.0".obs;
    for (var element in (interCityModel.taxList ?? [])) {
      taxAmount.value = (double.parse(taxAmount.value) +
              Constant.calculateTax(
                  amount: ((double.parse(interCityModel.subTotal ?? '0.0')) -
                          double.parse(
                              (interCityModel.discount ?? '0.0').toString()))
                      .toString(),
                  taxModel: element))
          .toStringAsFixed(Constant.currencyModel!.decimalDigits!);
    }
    return (double.parse(interCityModel.subTotal ?? '0.0') -
            double.parse((interCityModel.discount ?? '0.0').toString())) +
        double.parse(taxAmount.value);
  }

  static double calculateFinalRentalRideAmount(RentalBookingModel rentalModel) {
    RxString taxAmount = "0.0".obs;
    for (var element in (rentalModel.taxList ?? [])) {
      taxAmount.value = (double.parse(taxAmount.value) +
              Constant.calculateTax(
                  amount: (((double.parse(rentalModel.subTotal ?? '0.0')) +
                              double.parse(
                                  rentalModel.extraHourCharge ?? '0.0') +
                              double.parse(
                                  rentalModel.extraKmCharge ?? '0.0')) -
                          double.parse(
                              (rentalModel.discount ?? '0.0').toString()))
                      .toString(),
                  taxModel: element))
          .toStringAsFixed(Constant.currencyModel!.decimalDigits!);
    }
    return ((double.parse(rentalModel.subTotal ?? '0.0') +
                double.parse(rentalModel.extraHourCharge ?? '0.0') +
                double.parse(rentalModel.extraKmCharge ?? '0.0')) -
            double.parse((rentalModel.discount ?? '0.0').toString())) +
        double.parse(taxAmount.value);
  }

  static Future<LanguageModel> getLanguage() async {
    final String language =
        await Preferences.getString(Preferences.languageCodeKey);
    if (language.isEmpty) {
      await Preferences.setString(
          Preferences.languageCodeKey,
          json.encode({
            "id": "CcrGiUvJbPTXaU31s5l8",
            "name": "English",
            "code": "en",
            "active": true,
            "isDefault": true
          }));
      return LanguageModel.fromJson({
        "id": "CcrGiUvJbPTXaU31s5l8",
        "name": "English",
        "code": "en",
        "active": true,
        "isDefault": true
      });
    }
    Map<String, dynamic> languageMap = jsonDecode(language);
    log(languageMap.toString());
    return LanguageModel.fromJson(languageMap);
  }

  String? validateRequired(String? value, String type) {
    if (value!.isEmpty) {
      return '$type required';
    }
    return null;
  }

  String? validateMobile(String? value) {
    String patttern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
    RegExp regExp = RegExp(patttern);
    if (value!.isEmpty) {
      return 'Please enter mobile number';
    } else if (!regExp.hasMatch(value)) {
      return 'Please enter valid mobile number';
    }
    return null;
  }

  String? validateEmail(String? value) {
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = RegExp(pattern);
    if (value == null || value.isEmpty) {
      return "Email is Required";
    } else if (!regExp.hasMatch(value)) {
      return "Invalid Email";
    } else {
      return null;
    }
  }

  static bool hasValidUrl(String value) {
    String pattern =
        r'(http|https)://[\w-]+(\.[\w-]+)+([\w.,@?^=%&amp;:/~+#-]*[\w@?^=%&amp;/~+#-])?';
    RegExp regExp = RegExp(pattern);
    if (value.isEmpty) {
      return false;
    } else if (!regExp.hasMatch(value)) {
      return false;
    }
    return true;
  }

  static Future<String> uploadDriverDocumentImageToFireStorage(
      File image, String filePath, String fileName) async {
    Reference upload =
        FirebaseStorage.instance.ref().child('$filePath/$fileName');
    UploadTask uploadTask = upload.putFile(image);
    var downloadUrl = await (await uploadTask).ref.getDownloadURL();
    return downloadUrl.toString();
  }

  static Future<String> uploadUserImageToFireStorage(
      File image, String filePath, String fileName) async {
    Reference upload =
        FirebaseStorage.instance.ref().child('$filePath/$fileName');
    UploadTask uploadTask = upload.putFile(image);
    var downloadUrl =
        await (await uploadTask.whenComplete(() {})).ref.getDownloadURL();
    return downloadUrl.toString();
  }

  static Future<List<String>> uploadSupportImage(List<String> images) async {
    var imageUrls = await Future.wait(images.map((image) =>
        uploadUserImageToFireStorage(
            File(image),
            "supportImages/${FireStoreUtils.getCurrentUid()}",
            File(image).path.split("/").last)));
    return imageUrls;
  }

  Future<void> commonLaunchUrl(String url,
      {LaunchMode launchMode = LaunchMode.inAppWebView}) async {
    await launchUrl(Uri.parse(url), mode: launchMode).catchError((e) {
      // toast('Invalid URL: $url');
      throw e;
    });
  }

  void launchCall(String? url) {
    if (url!.validate().isNotEmpty) {
      if (Platform.isIOS) {
        commonLaunchUrl('tel://$url',
            launchMode: LaunchMode.externalApplication);
      } else {
        commonLaunchUrl('tel:$url', launchMode: LaunchMode.externalApplication);
      }
    }
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  static Future<MapModel?> getDurationDistance(
      LatLng departureLatLong, LatLng destinationLatLong) async {
    String url = 'https://maps.googleapis.com/maps/api/distancematrix/json';
    http.Response restaurantToCustomerTime = await http.get(Uri.parse(
        '$url?units=metric&origins=${departureLatLong.latitude},'
        '${departureLatLong.longitude}&destinations=${destinationLatLong.latitude},${destinationLatLong.longitude}&key=${Constant.mapAPIKey}'));

    log(restaurantToCustomerTime.body.toString());
    MapModel mapModel =
        MapModel.fromJson(jsonDecode(restaurantToCustomerTime.body));

    if (mapModel.status == 'OK' &&
        mapModel.rows!.first.elements!.first.status == "OK") {
      return mapModel;
    } else {
      ShowToastDialog.showToast(mapModel.errorMessage);
    }
    return null;
  }

  static Future<TimeOfDay?> selectTime(context) async {
    FocusScope.of(context).requestFocus(FocusNode()); //remove focus
    TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (newTime != null) {
      return newTime;
    }
    return null;
  }

  static Future<DateTime?> selectDate(context, bool isForFuture) async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: AppThemData.primary600, // header background color
                onPrimary: AppThemData.grey800, // header text color
                onSurface: AppThemData.grey800, // body text color
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: AppThemData.grey800, // button text color
                ),
              ),
            ),
            child: child!,
          );
        },
        initialDate: DateTime.now(),
        //get today's date
        firstDate: isForFuture ? DateTime.now() : DateTime(1945),
        //DateTime.now() - not to allow to choose before today.
        lastDate: isForFuture ? DateTime(2101) : DateTime.now());
    return pickedDate;
  }

  static String timestampToDate(Timestamp timestamp) {
    return DateFormat('MMM dd,yyyy').format(timestamp.toDate());
  }

  static String formatDate(DateTime? date) {
    if (date == null) return "No Date Selected";
    return DateFormat("dd MMM yyyy").format(date);
  }

  static String timestampToTime(Timestamp timestamp) {
    return DateFormat('HH:mm aa').format(timestamp.toDate());
  }

  static String timestampToDateChat(Timestamp timestamp) {
    return DateFormat('dd/MM/yyyy').format(timestamp.toDate());
  }

  static String timestampToTime12Hour(Timestamp? timestamp) {
    if (timestamp == null) return "";
    return DateFormat.jm().format(timestamp.toDate());
  }

  static DateTime? parseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;

    try {
      return DateFormat("yyyy-MM-dd").parse(dateString);
    } catch (e) {
      return null;
    }
  }

  Timestamp? addDayInTimestamp(
      {required String? days, required Timestamp date}) {
    if (days?.isNotEmpty == true && days != '0') {
      Timestamp now = date;
      DateTime dateTime = now.toDate();
      DateTime newDateTime = dateTime.add(Duration(days: int.parse(days!)));
      Timestamp newTimestamp = Timestamp.fromDate(newDateTime);
      return newTimestamp;
    } else {
      return null;
    }
  }

  static String timeAgo(dynamic timestamp) {
    if (timestamp == null) return '';

    DateTime dateTime;
    // Accept either Firebase Timestamp or DateTime
    if (timestamp is Timestamp) {
      dateTime = timestamp.toDate();
    } else if (timestamp is DateTime) {
      dateTime = timestamp;
    } else {
      // try parse if it's a string
      try {
        dateTime = DateTime.parse(timestamp.toString());
      } catch (e) {
        return '';
      }
    }

    final now = DateTime.now();
    // If timestamp is in future, treat as just now
    if (dateTime.isAfter(now)) return "Just now";

    final diff = now.difference(dateTime);

    if (diff.inSeconds < 60) {
      return "Just now";
    } else if (diff.inMinutes < 60) {
      final m = diff.inMinutes;
      return "${m}m ago";
    } else if (diff.inHours < 24) {
      final h = diff.inHours;
      return "${h}h ago";
    } else if (diff.inDays < 7) {
      final d = diff.inDays;
      return "${d}d ago";
    } else {
      // older than a week -> use your existing formatDate helper
      return formatDate(dateTime);
    }
  }

  static List<String> generateKeywords(String text) {
    if (text.isEmpty) return [];

    final lower = text.toLowerCase().trim();
    final List<String> keywords = [];

    final words = lower.split(' ').where((w) => w.isNotEmpty).toList();

    for (int i = 0; i < words.length; i++) {
      for (int j = i + 1; j <= words.length; j++) {
        keywords.add(words.sublist(i, j).join(' '));
      }
    }

    for (var word in words) {
      for (int i = 1; i <= word.length; i++) {
        keywords.add(word.substring(0, i));
      }
    }

    for (int i = 1; i <= lower.length; i++) {
      keywords.add(lower.substring(0, i));
    }

    return keywords.toSet().toList();
  }
}

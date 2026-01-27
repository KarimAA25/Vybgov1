import 'dart:developer' as developer;

import 'package:admin/app/constant/constants.dart';
import 'package:admin/app/constant/show_toast.dart';
import 'package:admin/app/models/constant_model.dart';
import 'package:admin/app/models/global_value_model.dart';
import 'package:admin/app/models/loyalty_point_model.dart';
import 'package:admin/app/utils/app_colors.dart';
import 'package:admin/app/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppSettingsController extends GetxController {
  Rx<TextEditingController> minimumDepositController = TextEditingController().obs;
  Rx<TextEditingController> minimumAmountAcceptRideController = TextEditingController().obs;
  Rx<TextEditingController> minimumWithdrawalController = TextEditingController().obs;
  Rx<TextEditingController> referralAmountController = TextEditingController().obs;
  Rx<TextEditingController> mapRadiusController = TextEditingController().obs;
  Rx<TextEditingController> appNameController = TextEditingController().obs;
  Rx<TextEditingController> colourCodeController = TextEditingController().obs;
  Rx<TextEditingController> globalDriverLocationUpdateController = TextEditingController().obs;
  Rx<TextEditingController> globalRadiusController = TextEditingController().obs;
  Rx<TextEditingController> globalInterCityRadiusController = TextEditingController().obs;
  Rx<TextEditingController> secondsForRideCancelController = TextEditingController().obs;
  Rx<TextEditingController> nightStartTimeController = TextEditingController().obs;
  Rx<TextEditingController> nightEndTimeController = TextEditingController().obs;
  Rx<TextEditingController> loyaltyPointPerRideController = TextEditingController().obs;
  Rx<TextEditingController> loyaltyConversionRideController = TextEditingController().obs;
  Rx<TextEditingController> loyaltyMinimumRedeemablePointsController = TextEditingController().obs;

  TextEditingController countryCodeController = TextEditingController(text: '+91');
  TextEditingController sosNumberController = TextEditingController();

  Rx<Color> selectedColor = AppThemData.primary500.obs;
  Rx<ConstantModel> constantModel = ConstantModel().obs;
  Rx<GlobalValueModel> globalValueModel = GlobalValueModel().obs;
  Rx<Status> isGstActive = Status.active.obs;
  Rx<Status> isDocumentVerificationActive = Status.active.obs;
  Rx<Status> isDriverApprovedActive = Status.active.obs;

  Rx<Status> isHomeFeatureEnable = Status.active.obs;

  List<String> distanceType = ["Km", "Miles"];
  RxString selectedDistanceType = "Km".obs;

  RxString title = "App Setting".tr.obs;

  RxBool isLoading = false.obs;

  @override
  void onInit() {
    getData();
    super.onInit();
  }

  @override
  void onClose() {
    // Dispose controllers to prevent memory leaks
    minimumDepositController.value.dispose();
    minimumAmountAcceptRideController.value.dispose();
    minimumWithdrawalController.value.dispose();
    referralAmountController.value.dispose();
    mapRadiusController.value.dispose();
    appNameController.value.dispose();
    colourCodeController.value.dispose();
    globalDriverLocationUpdateController.value.dispose();
    globalRadiusController.value.dispose();
    globalInterCityRadiusController.value.dispose();
    secondsForRideCancelController.value.dispose();
    sosNumberController.dispose();
    super.onClose();
  }

  Future<void> getData() async {
    isLoading(true);
    await getSettingData();
    await getGlobalValueSetting();
    isLoading(false);
  }

  Future<void> getSettingData() async {
    await FireStoreUtils.getGeneralSetting().then((value) {
      if (value != null) {
        constantModel.value = value;
        minimumDepositController.value.text = constantModel.value.minimumAmountDeposit!;
        referralAmountController.value.text = constantModel.value.referralAmount!;
        minimumWithdrawalController.value.text = constantModel.value.minimumAmountWithdraw!;
        colourCodeController.value.text = constantModel.value.appColor!;
        globalInterCityRadiusController.value.text = constantModel.value.interCityRadius!;
        appNameController.value.text = constantModel.value.appName!;
        loyaltyPointPerRideController.value.text = constantModel.value.loyaltyProgram!.points!;
        loyaltyConversionRideController.value.text = constantModel.value.loyaltyProgram!.conversionRate!;
        loyaltyMinimumRedeemablePointsController.value.text = constantModel.value.loyaltyProgram!.minRedeemPoint!;
        countryCodeController.text = constantModel.value.countryCode!;
        sosNumberController.text = constantModel.value.sosNumber!;
        selectedColor.value = HexColor.fromHex(colourCodeController.value.text);
        isDocumentVerificationActive.value = constantModel.value.isDocumentVerificationEnable == true ? Status.active : Status.inactive;
        isDriverApprovedActive.value = constantModel.value.isDriverAutoApproved == true ? Status.active : Status.inactive;
        isHomeFeatureEnable.value = constantModel.value.isHomeFeatureEnable == true ? Status.active : Status.inactive;
        secondsForRideCancelController.value.text = constantModel.value.secondsForRideCancel!;
      }
    });
  }

  Future<void> getGlobalValueSetting() async {
    await FireStoreUtils.getGlobalValueSetting().then((value) {
      if (value != null) {
        globalValueModel.value = value;
        developer.log("SelectedType:::: ${globalValueModel.value.distanceType}");
        selectedDistanceType.value = globalValueModel.value.distanceType ?? "Km";
        globalDriverLocationUpdateController.value.text = globalValueModel.value.driverLocationUpdate!;
        minimumAmountAcceptRideController.value.text = globalValueModel.value.minimumAmountAcceptRide!;
        globalRadiusController.value.text = globalValueModel.value.radius!;
        nightStartTimeController.value.text = globalValueModel.value.nightTime!.startTime!;
        nightEndTimeController.value.text = globalValueModel.value.nightTime!.endTime!;
      }
    });
  }

  dynamic saveSettingData() {
    if (minimumDepositController.value.text.isEmpty || minimumDepositController.value.text == "") {
      return ShowToastDialog.errorToast(" Please Add Deposit".tr);
    } else if (minimumWithdrawalController.value.text.isEmpty || minimumWithdrawalController.value.text == "") {
      return ShowToastDialog.errorToast(" Please Add Withdrawal Amount".tr);
    } else if (appNameController.value.text.isEmpty || appNameController.value.text == "") {
      return ShowToastDialog.errorToast(" Please Add App Name".tr);
    } else if (colourCodeController.value.text.isEmpty || colourCodeController.value.text == "") {
      return ShowToastDialog.errorToast(" Please Add App Colors".tr);
    } else if (minimumAmountAcceptRideController.value.text.isEmpty || minimumAmountAcceptRideController.value.text == "") {
      return ShowToastDialog.errorToast(" Please Add Amount Accept Ride".tr);
    } else if (loyaltyPointPerRideController.value.text.isEmpty || loyaltyPointPerRideController.value.text == "") {
      return ShowToastDialog.errorToast(" Please Add Loyalty Point Per Ride".tr);
    } else if (loyaltyConversionRideController.value.text.isEmpty || loyaltyConversionRideController.value.text == "") {
      return ShowToastDialog.errorToast(" Please Add Loyalty Conversion Ride".tr);
    } else if (loyaltyMinimumRedeemablePointsController.value.text.isEmpty || loyaltyMinimumRedeemablePointsController.value.text == "") {
      return ShowToastDialog.errorToast(" Please Add Loyalty Minimum Redeemable Points".tr);
    } else if (globalDriverLocationUpdateController.value.text.isEmpty || globalDriverLocationUpdateController.value.text == "") {
      return ShowToastDialog.errorToast(" Please Add App Global Location".tr);
    } else if (globalRadiusController.value.text.isEmpty || globalRadiusController.value.text == "") {
      return ShowToastDialog.errorToast(" Please Add App Global Radius".tr);
    } else if (globalInterCityRadiusController.value.text.isEmpty || globalInterCityRadiusController.value.text == "") {
      return ShowToastDialog.errorToast(" Please Add App interCity Radius".tr);
    } else if (secondsForRideCancelController.value.text.isEmpty || secondsForRideCancelController.value.text == "") {
      return ShowToastDialog.errorToast(" Please Add Seconds for ride Cancellation  ".tr);
    } else if (nightStartTimeController.value.text.isEmpty || nightStartTimeController.value.text == "") {
      return ShowToastDialog.errorToast(" Please Add Start Time For Night.".tr);
    } else if (nightEndTimeController.value.text.isEmpty || nightEndTimeController.value.text == "") {
      return ShowToastDialog.errorToast(" Please Add End Time For Night.".tr);
    } else if (referralAmountController.value.text.isEmpty || referralAmountController.value.text == "") {
      return ShowToastDialog.errorToast(" Please Add referral Amount.".tr);
    } else if (countryCodeController.value.text.isEmpty || countryCodeController.value.text == "") {
      return ShowToastDialog.errorToast(" Please Select Country Code.".tr);
    } else if (sosNumberController.value.text.isEmpty || sosNumberController.value.text == "") {
      return ShowToastDialog.errorToast(" Please Enter SOS Number.".tr);
    } else {
      constantModel.value.minimumAmountDeposit = minimumDepositController.value.text;
      constantModel.value.referralAmount = referralAmountController.value.text;
      constantModel.value.isDocumentVerificationEnable = isDocumentVerificationActive.value == Status.inactive ? false : true;
      constantModel.value.isDriverAutoApproved = isDriverApprovedActive.value == Status.inactive ? false : true;
      constantModel.value.secondsForRideCancel = secondsForRideCancelController.value.text;
      constantModel.value.isHomeFeatureEnable = isHomeFeatureEnable.value == Status.inactive ? false : true;
      constantModel.value.countryCode = countryCodeController.value.text;
      constantModel.value.sosNumber = sosNumberController.value.text;
      constantModel.value.minimumAmountWithdraw = minimumWithdrawalController.value.text;
      constantModel.value.appName = appNameController.value.text;
      constantModel.value.appColor = colourCodeController.value.text;
      constantModel.value.interCityRadius = globalInterCityRadiusController.value.text;
      constantModel.value.loyaltyProgram ??= LoyaltyPointModel();
      constantModel.value.loyaltyProgram!.points = loyaltyPointPerRideController.value.text;
      constantModel.value.loyaltyProgram!.conversionRate = loyaltyConversionRideController.value.text;
      constantModel.value.loyaltyProgram!.minRedeemPoint = loyaltyMinimumRedeemablePointsController.value.text;

      globalValueModel.value.driverLocationUpdate = globalDriverLocationUpdateController.value.text;
      globalValueModel.value.distanceType = selectedDistanceType.value.toString();
      globalValueModel.value.radius = globalRadiusController.value.text;
      globalValueModel.value.minimumAmountAcceptRide = minimumAmountAcceptRideController.value.text;
      globalValueModel.value.nightTime!.startTime = nightStartTimeController.value.text;
      globalValueModel.value.nightTime!.endTime = nightEndTimeController.value.text;
      FireStoreUtils.setGeneralSetting(constantModel.value);
      FireStoreUtils.setGlobalValueSetting(globalValueModel.value);
      ShowToastDialog.successToast('Information Saved'.tr);
    }
  }
}

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}

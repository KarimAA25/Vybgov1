// ignore_for_file: use_build_context_synchronously

import 'dart:developer' as developer;
import 'dart:io';

// ignore_for_file: depend_on_referenced_packages
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/app/models/coupon_model.dart';
import 'package:customer/app/models/distance_model.dart';
import 'package:customer/app/models/time_slots_charges_model.dart';
import 'package:customer/app/models/location_lat_lng.dart';
import 'package:customer/app/models/map_model.dart';
import 'package:customer/app/models/parcel_model.dart';
import 'package:customer/app/models/positions.dart';
import 'package:customer/app/models/tax_model.dart';
import 'package:customer/app/models/vehicle_type_model.dart';
import 'package:customer/app/models/zone_model.dart';
import 'package:customer/constant/booking_status.dart';
import 'package:customer/constant/collection_name.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant_widgets/show_toast_dialog.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart' as latlang;
import 'package:path_provider/path_provider.dart';

class BookParcelController extends GetxController {
  RxBool isLoading = true.obs;
  FocusNode pickUpFocusNode = FocusNode();
  FocusNode dropFocusNode = FocusNode();
  TextEditingController dropLocationController = TextEditingController();
  TextEditingController pickupLocationController = TextEditingController();
  LatLng? sourceLocation;
  LatLng? destination;
  Rx<DateTime?> selectedDate = DateTime.now().obs;

  /// OSM MAP
  latlang.LatLng? osmSourceLocation;
  latlang.LatLng? osmDestination;

  Rx<TextEditingController> addPriceController = TextEditingController().obs;
  Rx<TextEditingController> weightController = TextEditingController().obs;
  Rx<TextEditingController> dimensionController = TextEditingController().obs;

  final ImagePicker imagePicker = ImagePicker();
  Rxn<File> selectedImage = Rxn<File>();

  Rx<ParcelModel> parcelModel = ParcelModel().obs;
  RxList<TaxModel> taxList = (Constant.taxList ?? []).obs;

  RxString pikUpAddress = ''.obs;
  RxString dropAddress = ''.obs;
  Rx<MapModel?> mapModel = MapModel().obs;

  RxString selectedPaymentMethod = 'Cash'.obs;

  RxString mimeType = 'image/png'.obs;

  Rx<VehicleTypeModel> vehicleTypeModel = VehicleTypeModel().obs;
  RxList<VehicleTypeModel> vehicleTypeList = <VehicleTypeModel>[].obs;

  RxDouble estimatePrice = 0.0.obs;
  RxBool isEstimatePriceVisible = false.obs;

  Rx<DistanceModel> distanceOfKm = DistanceModel().obs;

  RxList<ZoneModel> zoneList = <ZoneModel>[].obs;
  Rx<ZoneModel> selectedZone = ZoneModel().obs;

  RxString couponCode = "".obs;
  Rx<CouponModel> selectedCouponModel = CouponModel().obs;
  Rx<TextEditingController> couponCodeController = TextEditingController().obs;

  @override
  void onInit() {
    getData();

    super.onInit();
  }

  Future<void> getData() async {
    await FireStoreUtils.getVehicleType().then((value) {
      vehicleTypeList.value = value;
      if (vehicleTypeList.isNotEmpty) {
        vehicleTypeModel.value = vehicleTypeList[0];
      }
    });

    await FireStoreUtils.getActiveZones().then(
      (value) {
        if (value != null) {
          zoneList.value = value;
        }
      },
    );

    await FireStoreUtils.fetchIntercityService().then(
      (value) {
        parcelDocuments.value = value["parcel"] ?? [];
      },
    );

    if (Constant.taxList == null || Constant.taxList!.isEmpty) {
      getTax();
    } else {
      taxList.value = Constant.taxList!;
    }
    isLoading.value = false;
  }

  Future<void> updateData() async {
    LatLng? start;
    LatLng? end;
    if (Constant.selectedMap == "Google Map") {
      start = sourceLocation;
      end = destination;
    } else {
      if (osmSourceLocation != null && osmDestination != null) {
        start = LatLng(osmSourceLocation!.latitude, osmSourceLocation!.longitude);
        end = LatLng(osmDestination!.latitude, osmDestination!.longitude);
      }
    }
    if (start != null && end != null) {
      ShowToastDialog.showLoader("Please wait".tr);
      try {
        mapModel.value = await Constant.getDurationDistance(start, end);
        distanceOfKm.value = DistanceModel(
          distance: distanceCalculate(mapModel.value),
          distanceType: Constant.distanceType,
        );
        updateCalculation();
        findZone();
      } catch (e) {
        developer.log("Error in updateData: $e");
      } finally {
        ShowToastDialog.closeLoader(); // ✅ Always closes
      }
    }
  }

  void findZone() {
    for (int i = 0; i < zoneList.length; i++) {
      if (isPointInPolygon(LatLng(sourceLocation!.latitude, sourceLocation!.longitude), zoneList[i].area!)) {
        selectedZone.value = zoneList[i];
        break;
      } else {
        selectedZone.value = zoneList[i];
      }
    }
  }

  RxDouble subTotal = 0.0.obs;
  RxDouble discountAmount = 0.0.obs;
  RxDouble totalAmount = 0.0.obs;
  RxList<TimeSlotsChargesModel> parcelDocuments = <TimeSlotsChargesModel>[].obs;

  void updateCalculation() {
    double baseFare = 0.0;

    ZoneChargesModel? currentZoneCharge = parcelDocuments.first.zoneCharges.firstWhere(
      (z) => z.zoneId == selectedZone.value.id,
      orElse: () => parcelDocuments.first.zoneCharges.first,
    );

    developer.log("++++++++++++++ ${parcelDocuments.first.zoneCharges.toList()}");
    final charges = currentZoneCharge.charges!;

    final distance = double.tryParse(distanceOfKm.value.distance ?? '0') ?? 0;
    final minKm = double.tryParse(charges.fareMinimumChargesWithinKm ?? "0") ?? 0;
    final minCharge = double.tryParse(charges.farMinimumCharges ?? "0") ?? 0;
    final perKm = double.tryParse(charges.farePerKm ?? "0") ?? 0;

    if (distance < minKm) {
      baseFare = minCharge;
    } else {
      baseFare = double.parse((perKm * distance).toStringAsFixed(Constant.currencyModel!.decimalDigits!));
    }

    try {} catch (e) {
      developer.log("❌ Invalid time format: ${selectedTime.value}");
      return;
    }

    // estimatePrice.value = baseFare;
    // addPriceController.value.text = baseFare.toStringAsFixed(Constant.currencyModel!.decimalDigits!);
    // isEstimatePriceVisible.value = true;

    subTotal.value = baseFare;
    estimatePrice.value = subTotal.value;
    addPriceController.value.text = estimatePrice.value.toStringAsFixed(Constant.currencyModel!.decimalDigits!);
    isEstimatePriceVisible.value = true;
    applyCouponCalculation();

    developer.log("✅ BaseFare: $baseFare,  ( distance: $distance)");
  }

  void applyCouponCalculation() {
    final coupon = selectedCouponModel.value;

    double subtotal = subTotal.value;
    double discount = 0.0;

    /// WHEN NO COUPON APPLIED
    if (coupon.id == null || coupon.id!.trim().isEmpty) {
      discountAmount.value = 0.0;

      /// Recalculate tax normally on subtotal
      double taxAmount = 0.0;
      for (var element in taxList) {
        taxAmount += Constant.calculateTax(
          amount: subtotal.toString(),
          taxModel: element,
        );
      }

      totalAmount.value = subtotal + taxAmount;
      return;
    }

    /// MINIMUM AMOUNT CHECK
    double minAmount = double.tryParse(coupon.minAmount ?? "0") ?? 0;
    if (subtotal < minAmount) {
      ShowToastDialog.showToast("MinAmount".trParams({"minAmount": minAmount.toString()})
          //"Subtotal must be at least $minAmount for this coupon"
          );
      discountAmount.value = 0.0;

      double taxAmount = 0.0;
      for (var element in taxList) {
        taxAmount += Constant.calculateTax(
          amount: subtotal.toString(),
          taxModel: element,
        );
      }
      totalAmount.value = subtotal + taxAmount;

      return;
    }

    /// COUPON CALCULATION
    double amount = double.tryParse(coupon.amount ?? "0") ?? 0;

    if (coupon.isFix == true) {
      discount = amount;
    } else {
      discount = subtotal * (amount / 100);
    }

    discountAmount.value = discount;

    /// TAX AFTER DISCOUNT
    double taxableAmount = subtotal - discount;
    double taxAmount = 0.0;

    for (var element in taxList) {
      taxAmount += Constant.calculateTax(
        amount: taxableAmount.toString(),
        taxModel: element,
      );
    }

    totalAmount.value = taxableAmount + taxAmount;

    if (totalAmount.value < 0) totalAmount.value = 0;
  }

  Future<void> getCoupon() async {
    final code = couponCodeController.value.text;
    if (code.isEmpty) return;
    ShowToastDialog.showLoader("Please wait..".tr);
    try {
      final query = await FireStoreUtils.fireStore
          .collection(CollectionName.coupon)
          .where('code', isEqualTo: code)
          .where('active', isEqualTo: true)
          .where('expireAt', isGreaterThanOrEqualTo: Timestamp.now())
          .limit(1)
          .get();
      ShowToastDialog.closeLoader();
      if (query.docs.isNotEmpty) {
        selectedCouponModel.value = CouponModel.fromJson(query.docs.first.data());
        couponCodeController.value.text = selectedCouponModel.value.code!;
        // Do NOT call updateCalculation() here — that was overwriting the user-entered price
        // Instead compute discount & total based on the current subtotal (either user-entered price or estimate)
        double currentSubtotal = double.tryParse(addPriceController.value.text) ?? estimatePrice.value;
        subTotal.value = currentSubtotal;

        if (selectedCouponModel.value.id != null) {
          if (selectedCouponModel.value.isFix == true) {
            discountAmount.value = double.tryParse(selectedCouponModel.value.amount?.toString() ?? '0') ?? 0.0;
          } else {
            double percent = double.tryParse(selectedCouponModel.value.amount?.toString() ?? '0') ?? 0.0;
            discountAmount.value = (subTotal.value) * percent / 100;
          }
        } else {
          discountAmount.value = 0.0;
        }

        // Recalculate taxes and total
        double taxAmount = 0.0;
        for (var element in taxList) {
          taxAmount = taxAmount + Constant.calculateTax(amount: ((subTotal.value) - discountAmount.value).toString(), taxModel: element);
        }
        totalAmount.value = (subTotal.value - discountAmount.value) + taxAmount;
      } else {
        selectedCouponModel.value = CouponModel();
        ShowToastDialog.toast("Invalid or expired coupon code".tr);
      }
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.toast("Error fetching coupon".tr);
      developer.log(e.toString());
    }
    FocusScope.of(Get.context!).unfocus();
  }

  DateTime convertToDateTime(String time) {
    final format = DateFormat("h:mm a");
    return format.parse(time);
  }

  Future<void> getTax() async {
    final value = await FireStoreUtils().getTaxList();
    if (value != null) {
      Constant.taxList = value;
      taxList.value = value;
    }
    isLoading.value = false;
  }

  RxString selectedTime = "Select Time".tr.obs;

  void pickTime(BuildContext context) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      selectedTime.value = pickedTime.format(context);
      if (sourceLocation != null) findZone();
      if (distanceOfKm.value.distance != null) updateCalculation();
      // ChargesModel? intercityModel = calculationOfEstimatePrice();
      //
      // if (intercityModel != null) {
      //   if (Constant.distanceType == "Km") {
      //     var distance = (mapModel.value!.rows!.first.elements!.first.distance!.value!.toInt() / 1000);
      //     if (distance > double.parse(intercityModel.fareMinimumChargesWithinKm)) {
      //       estimatePrice.value = double.parse(Constant.amountCalculate(intercityModel.farePerKm.toString(), distance.toString()).toStringAsFixed(Constant.currencyModel!.decimalDigits!));
      //       isEstimatePriceVisible.value = true;
      //     } else {
      //       double.parse(Constant.amountCalculate(intercityModel.farMinimumCharges.toString(), distance.toString()).toStringAsFixed(Constant.currencyModel!.decimalDigits!));
      //       isEstimatePriceVisible.value = true;
      //     }
      //     addPriceController.value.text = double.parse(estimatePrice.value.toString()).toString();
      //   } else {
      //     var distance = (mapModel.value!.rows!.first.elements!.first.distance!.value!.toInt() / 1609.34);
      //     if (distance > double.parse(intercityModel.fareMinimumChargesWithinKm)) {
      //       estimatePrice.value = double.parse(Constant.amountCalculate(intercityModel.farePerKm.toString(), distance.toString()).toStringAsFixed(Constant.currencyModel!.decimalDigits!));
      //       isEstimatePriceVisible.value = true;
      //     } else {
      //       double.parse(Constant.amountCalculate(intercityModel.farMinimumCharges.toString(), distance.toString()).toStringAsFixed(Constant.currencyModel!.decimalDigits!));
      //       isEstimatePriceVisible.value = true;
      //     }
      //     addPriceController.value.text = double.parse(estimatePrice.value.toString()).toString();
      //
      //     log("Distance is greater than or equal to the minimum charge threshold");
      //   }
      // } else {
      //   log("No matching time slot found.");
      // }
    }
  }

  Future<void> saveParcelData() async {
    if (selectedImage.value == null) {
      ShowToastDialog.showToast("Please add an image".tr);
      return;
    }

    // Determine active map locations (Google Map / OSM)
    final double pickupLat = Constant.selectedMap == "Google Map" ? sourceLocation!.latitude : osmSourceLocation!.latitude;

    final double pickupLng = Constant.selectedMap == "Google Map" ? sourceLocation!.longitude : osmSourceLocation!.longitude;

    final double dropLat = Constant.selectedMap == "Google Map" ? destination!.latitude : osmDestination!.latitude;

    final double dropLng = Constant.selectedMap == "Google Map" ? destination!.longitude : osmDestination!.longitude;

    if (pickupLat == 0 || dropLat == 0) {
      ShowToastDialog.showToast("Please select pickup & drop location".tr);
      return;
    }

    ShowToastDialog.showLoader("Please wait..".tr);
    parcelModel.value.id = Constant.getUuid();
    if (selectedImage.value!.path.isNotEmpty) {
      mimeType.value = 'image/png';
      String docId = parcelModel.value.id.toString();
      String url = await Constant.uploadPic(PickedFile(selectedImage.value!.path), "parcelImage", docId, mimeType.value);
      parcelModel.value.parcelImage = url;
    }
    parcelModel.value.dropLocationAddress = dropAddress.value;
    parcelModel.value.pickUpLocationAddress = pikUpAddress.value;
    parcelModel.value.customerId = FireStoreUtils.getCurrentUid();
    parcelModel.value.bookingStatus = BookingStatus.bookingPlaced;
    parcelModel.value.createAt = Timestamp.now();
    parcelModel.value.updateAt = Timestamp.now();
    parcelModel.value.bookingTime = Timestamp.now();
    parcelModel.value.rideStartTime = selectedTime.value;
    parcelModel.value.pickUpLocation = LocationLatLng(latitude: pickupLat, longitude: pickupLng);
    parcelModel.value.dropLocation = LocationLatLng(latitude: dropLat, longitude: dropLng);
    parcelModel.value.discount = discountAmount.toString();
    if (selectedCouponModel.value.id != null) {
      parcelModel.value.coupon = selectedCouponModel.value;
    }
    parcelModel.value.pickupPosition = Positions(
        geoPoint: GeoFlutterFire().point(latitude: pickupLat, longitude: pickupLng).geoPoint, geohash: GeoFlutterFire().point(latitude: pickupLat, longitude: pickupLng).hash);
    parcelModel.value.dropPosition =
        Positions(geoPoint: GeoFlutterFire().point(latitude: dropLat, longitude: dropLng).geoPoint, geohash: GeoFlutterFire().point(latitude: dropLat, longitude: dropLng).hash);
    parcelModel.value.distance = DistanceModel(
      distance: distanceCalculate(mapModel.value),
      distanceType: Constant.distanceType,
    );
    parcelModel.value.otp = Constant.isOtpFeatureEnable == true ? Constant.getOTPCode() : "";
    parcelModel.value.paymentType = selectedPaymentMethod.value;
    parcelModel.value.paymentStatus = false;
    parcelModel.value.taxList = taxList;
    parcelModel.value.adminCommission = Constant.adminCommission;
    parcelModel.value.startDate = DateFormat('yyyy-MM-dd').format(selectedDate.value!);
    parcelModel.value.subTotal = addPriceController.value.text;
    parcelModel.value.setPrice = addPriceController.value.text;
    parcelModel.value.weight = weightController.value.text;
    parcelModel.value.dimension = dimensionController.value.text;
    parcelModel.value.recommendedPrice = estimatePrice.value.toString();
    parcelModel.value = ParcelModel.fromJson(parcelModel.value.toJson());
    await FireStoreUtils.setParcelBooking(parcelModel.value).then((value) {
      if (value == true) {
        ShowToastDialog.closeLoader();
        Get.back();
        Get.back();
        ShowToastDialog.showToast("Parcel Ride Placed Successfully.".tr);
      }
    });
  }

  Future<void> pickFile({required ImageSource source}) async {
    try {
      XFile? image = await imagePicker.pickImage(source: source, imageQuality: 100);
      if (image == null) return;
      Get.back();

      final tempDir = await getTemporaryDirectory();
      final compressedFilePath = '${tempDir.path}/compressed_${image.name}';

      Uint8List? compressedBytes = await FlutterImageCompress.compressWithFile(
        image.path,
        quality: 50,
      );

      if (compressedBytes == null) {
        Get.snackbar("Error", "Failed to compress image.");
        return;
      }

      File compressedFile = File(compressedFilePath);
      await compressedFile.writeAsBytes(compressedBytes);

      developer.log('==========> compressedFile ${compressedFile.path}');
      selectedImage.value = compressedFile;
    } on PlatformException catch (e) {
      Get.snackbar("Error", "Failed to pick image: $e");
    }
  }

  void removeImage() {
    selectedImage.value = null;
  }

  String distanceCalculate(MapModel? value) {
    if (Constant.distanceType == "Km") {
      return (value!.rows!.first.elements!.first.distance!.value!.toInt() / 1000).toString();
    } else {
      return (value!.rows!.first.elements!.first.distance!.value!.toInt() / 1609.34).toString();
    }
  }

  bool isPointInPolygon(LatLng point, List<GeoPoint> polygon) {
    int crossings = 0;
    for (int i = 0; i < polygon.length; i++) {
      int next = (i + 1) % polygon.length;
      if (polygon[i].latitude <= point.latitude && polygon[next].latitude > point.latitude || polygon[i].latitude > point.latitude && polygon[next].latitude <= point.latitude) {
        double edgeLong = polygon[next].longitude - polygon[i].longitude;
        double edgeLat = polygon[next].latitude - polygon[i].latitude;
        double interpol = (point.latitude - polygon[i].latitude) / edgeLat;
        if (point.longitude < polygon[i].longitude + interpol * edgeLong) {
          crossings++;
        }
      }
    }
    return (crossings % 2 != 0);
  }
}

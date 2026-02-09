// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:developer';

// ignore_for_file: depend_on_referenced_packages
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/app/models/booking_model.dart';
import 'package:customer/app/models/coupon_model.dart';
import 'package:customer/app/models/distance_model.dart';
import 'package:customer/app/models/time_slots_charges_model.dart';
import 'package:customer/app/models/intercity_model.dart';
import 'package:customer/app/models/location_lat_lng.dart';
import 'package:customer/app/models/map_model.dart';
import 'package:customer/app/models/person_model.dart';
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
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart' as latlang;

class BookIntercityController extends GetxController {
  StreamSubscription? _sharingPersonsSub;
  RxBool isLoading = true.obs;
  RxInt selectedRideType = 1.obs;
  RxInt selectedPersons = 1.obs;
  Rx<DateTime?> selectedDate = DateTime.now().obs;
  Rx<IntercityModel> interCityModel = IntercityModel().obs;
  Rx<PersonModel> personModel = PersonModel().obs;

  RxString selectedPaymentMethod = 'Cash'.obs;
  RxList<TaxModel> taxList = (Constant.taxList ?? []).obs;
  RxString couponCode = "".obs;
  Rx<CouponModel> selectedCouponModel = CouponModel().obs;
  Rx<TextEditingController> couponCodeController = TextEditingController().obs;

  FocusNode pickUpFocusNode = FocusNode();
  FocusNode dropFocusNode = FocusNode();
  TextEditingController pickupLocationController = TextEditingController();
  TextEditingController dropLocationController = TextEditingController();
  RxString pikUpAddress = ''.obs;
  RxString dropAddress = ''.obs;

  Rx<TextEditingController> addPriceController = TextEditingController().obs;
  Rx<TextEditingController> enterNameController = TextEditingController().obs;
  Rx<TextEditingController> enterNumberController = TextEditingController().obs;

  RxList<PersonModel> totalAddPersonShare = <PersonModel>[].obs;
  RxList<PersonModel> addInSharing = <PersonModel>[].obs;

  // LatLng? sourceLocation;
  // LatLng? destination;
  Rx<MapModel?> mapModel = MapModel().obs;

  // /// OSM MAP
  // latlang.LatLng? osmSourceLocation;
  // latlang.LatLng? osmDestination;
  // RxList<latlang.LatLng?> osmStopsLatLng = <latlang.LatLng?>[].obs;
  // RxList<String> osmStopAddresses = <String>[].obs;

  /// GOOGLE MAP
  LatLng? sourceLocation;
  LatLng? destination;
  RxList<LatLng?> stopsLatLng = <LatLng?>[].obs;
  RxList<String> googleStopAddresses = <String>[].obs;

  /// OSM MAP
  latlang.LatLng? osmSourceLocation;
  latlang.LatLng? osmDestination;
  RxList<latlang.LatLng?> osmStopsLatLng = <latlang.LatLng?>[].obs;
  RxList<String> osmStopAddresses = <String>[].obs;

  RxDouble estimatePrice = 0.0.obs;
  RxBool isEstimatePriceVisible = false.obs;

  Rx<DistanceModel> distanceOfKm = DistanceModel().obs;

  Rx<VehicleTypeModel> vehicleTypeModel = VehicleTypeModel().obs;
  RxList<VehicleTypeModel> vehicleTypeList = <VehicleTypeModel>[].obs;

  RxList<TimeSlotsChargesModel> intercitySharingDocuments = <TimeSlotsChargesModel>[].obs;
  RxList<TimeSlotsChargesModel> intercityPersonalDocuments = <TimeSlotsChargesModel>[].obs;

  //RxList<String> googleStopAddresses = <String>[].obs;
  RxList<TextEditingController> stopControllers = <TextEditingController>[].obs;

  //RxList<LatLng?> stopsLatLng = <LatLng?>[].obs;
  RxList<FocusNode> stopFocusNodes = <FocusNode>[].obs;

  RxList<ZoneModel> zoneList = <ZoneModel>[].obs;
  Rx<ZoneModel> selectedZone = ZoneModel().obs;

  RxBool isForFemale = false.obs;

  @override
  void onInit() {
    getData();
    super.onInit();
  }

  Future<void> getData() async {
    await FireStoreUtils.fetchIntercityService().then(
      (value) {
        intercityPersonalDocuments.value = value["intercity"] ?? [];
        intercitySharingDocuments.value = value["intercity_sharing"] ?? [];
      },
    );

    await FireStoreUtils.getActiveZones().then(
      (value) {
        if (value != null) {
          zoneList.value = value;
        }
      },
    );

    await FireStoreUtils.getVehicleType().then((value) {
      vehicleTypeList.value = value;
      if (vehicleTypeList.isNotEmpty) {
        vehicleTypeModel.value = vehicleTypeList[0];
      }
    });
    getTax();
    listenForLiveUpdates();

    if (intercityPersonalDocuments.first.isAvailable == false) {
      selectedRideType.value = 2;
    }

    isLoading.value = false;
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

  void addStop() {
    stopControllers.add(TextEditingController());
    stopFocusNodes.add(FocusNode());
    // Google Map
    stopsLatLng.add(null);
    googleStopAddresses.add('');
    // OSM Map ✅ REQUIRED
    osmStopsLatLng.add(null);
    osmStopAddresses.add('');
    update();
  }

  void removeStop(int index) {
    stopControllers[index].dispose();
    stopControllers.removeAt(index);
    stopFocusNodes.removeAt(index);
    // Google
    stopsLatLng.removeAt(index);
    googleStopAddresses.removeAt(index);
    // OSM ✅ REQUIRED
    osmStopsLatLng.removeAt(index);
    osmStopAddresses.removeAt(index);
    update();
  }

  // Future<void> updateData() async {
  //   if (destination == null || sourceLocation == null) {
  //     ShowToastDialog.closeLoader();
  //     return;
  //   }
  //   ShowToastDialog.showLoader("Please wait".tr);
  //   try {
  //     mapModel.value = await Constant.getDurationDistance(sourceLocation!, destination!);
  //     distanceOfKm.value = DistanceModel(
  //       distance: distanceCalculate(mapModel.value),
  //       distanceType: Constant.distanceType,
  //     );
  //     updateCalculation();
  //     if (sourceLocation != null) {
  //       findZone();
  //     }
  //   } catch (e) {
  //     log("Error in updateData: $e");
  //   } finally {
  //     ShowToastDialog.closeLoader();
  //   }
  // }

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
    }
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
      log(e.toString());
    }
    FocusScope.of(Get.context!).unfocus();
  }

  // void pickTime(BuildContext context) async {
  //   TimeOfDay? pickedTime = await showTimePicker(
  //     context: context,
  //     initialTime: TimeOfDay.now(),
  //   );
  //
  //   if (pickedTime != null) {
  //     selectedTime.value = pickedTime.format(context);
  //     findZone();
  //     updateCalculation();
  //     ChargesModel? intercityModel = calculationOfEstimatePrice();
  //
  //     if (intercityModel != null) {
  //       if (Constant.distanceType == "Km") {
  //         var distance = (mapModel.value!.rows!.first.elements!.first.distance!.value!.toInt() / 1000);
  //         if (distance > double.parse(intercityModel.fareMinimumChargesWithinKm)) {
  //           estimatePrice.value = double.parse(Constant.amountCalculate(intercityModel.farePerKm.toString(), distance.toString()).toStringAsFixed(Constant.currencyModel!.decimalDigits!));
  //           isEstimatePriceVisible.value = true;
  //         } else {
  //           double.parse(Constant.amountCalculate(intercityModel.farMinimumCharges.toString(), distance.toString()).toStringAsFixed(Constant.currencyModel!.decimalDigits!));
  //           isEstimatePriceVisible.value = true;
  //         }
  //         addPriceController.value.text = double.parse(estimatePrice.value.toString()).toString();
  //       } else {
  //         var distance = (mapModel.value!.rows!.first.elements!.first.distance!.value!.toInt() / 1609.34);
  //         if (distance > double.parse(intercityModel.fareMinimumChargesWithinKm)) {
  //           estimatePrice.value = double.parse(Constant.amountCalculate(intercityModel.farePerKm.toString(), distance.toString()).toStringAsFixed(Constant.currencyModel!.decimalDigits!));
  //           isEstimatePriceVisible.value = true;
  //         } else {
  //           double.parse(Constant.amountCalculate(intercityModel.farMinimumCharges.toString(), distance.toString()).toStringAsFixed(Constant.currencyModel!.decimalDigits!));
  //           isEstimatePriceVisible.value = true;
  //         }
  //         addPriceController.value.text = double.parse(estimatePrice.value.toString()).toString();
  //       }
  //     } else {
  //       log("No matching time slot found.");
  //     }
  //   }
  // }
  RxDouble subTotal = 0.0.obs;
  RxDouble nightCharges = 0.0.obs;
  RxDouble discountAmount = 0.0.obs;
  RxDouble totalAmount = 0.0.obs;

  void updateCalculation() {
    double baseFare = 0.0;
    double nightCharge = 0.0;

    List<ZoneChargesModel>? zoneCharges = selectedRideType.value == 1 ? intercityPersonalDocuments.first.zoneCharges : intercitySharingDocuments.first.zoneCharges;

    ZoneChargesModel? currentZoneCharge = zoneCharges.firstWhere(
      (z) => z.zoneId == selectedZone.value.id,
      orElse: () => zoneCharges.first,
    );

    final charges = currentZoneCharge.charges!;

    final distance = double.tryParse(distanceOfKm.value.distance ?? '0') ?? 0;
    final minKm = double.tryParse(charges.fareMinimumChargesWithinKm ?? "0") ?? 0;
    final minCharge = double.tryParse(charges.farMinimumCharges ?? "0") ?? 0;
    final perKm = double.tryParse(charges.farePerKm ?? "0") ?? 0;

    if (distance <= minKm) {
      baseFare = minCharge;
    } else {
      baseFare = double.parse((perKm * distance).toStringAsFixed(Constant.currencyModel!.decimalDigits!));
    }

    DateTime time;
    try {
      time = convertToDateTime(selectedTime.value);
    } catch (e) {
      log("❌ Invalid time format: ${selectedTime.value}");
      return;
    }

    final nightTiming = Constant.nightTimingModel;
    bool isNight = false;

    if (nightTiming != null) {
      try {
        List<String> startParts = nightTiming.startTime!.split(":");
        List<String> endParts = nightTiming.endTime!.split(":");

        int nightStart = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
        int nightEnd = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);
        int currentMinutes = time.hour * 60 + time.minute;

        if (nightStart < nightEnd) {
          isNight = currentMinutes >= nightStart && currentMinutes < nightEnd;
        } else {
          isNight = currentMinutes >= nightStart || currentMinutes < nightEnd;
        }
      } catch (e) {
        log("❌ Error parsing night timing: $e");
      }
    }

    if (isNight && charges.incrementOfNightCharge != null) {
      double nightPercentage = double.tryParse(charges.incrementOfNightCharge!) ?? 0;
      nightCharge = double.parse(
        (baseFare * (nightPercentage / 100)).toStringAsFixed(Constant.currencyModel!.decimalDigits!),
      );
      nightCharges.value = nightCharge;
    } else {
      nightCharges.value = 0.0;
    }

    /// FINAL SUBTOTAL (NO COUPON EFFECT HERE)
    subTotal.value = baseFare + nightCharge;

    estimatePrice.value = subTotal.value;

    addPriceController.value.text = estimatePrice.value.toStringAsFixed(Constant.currencyModel!.decimalDigits!);

    isEstimatePriceVisible.value = true;

    /// APPLY COUPON EFFECT AFTER CALCULATION
    applyCouponCalculation();

    log("✅ BaseFare: $baseFare, NightCharge: $nightCharge, (isNight: $isNight, distance: $distance)");
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

  DateTime convertToDateTime(String time) {
    final format = DateFormat("h:mm a");
    return format.parse(time);
  }

  // void updateCalculation() {
  //   if (selectedZone.value == null) {
  //     log("❌ No zone selected for pickup.");
  //     return;
  //   }
  //   if (selectedTime.value == 'Select Time' || selectedTime.value.isEmpty) return;
  //
  //   final intercityModel = calculationOfEstimatePrice();
  //   if (intercityModel == null) {
  //     return;
  //   }
  //
  //   ZoneChargesModel? currentZoneCharge = vehicleTypeModel.value.zoneCharges?.firstWhere(
  //         (element) => element.zoneId == selectedZone.value.id,
  //     orElse: () => vehicleTypeModel.value.zoneCharges!.first,
  //   );
  //   if (currentZoneCharge == null) {
  //     log("❌ No zone charges found for this vehicle/zone.");
  //     return;
  //   }
  //
  //   Charges? charges = currentZoneCharge.charges;
  //   if (charges == null) return;
  //
  //   final distance = double.tryParse(distanceOfKm.value.distance ?? '');
  //   final minChargeDistance = double.tryParse(intercityModel.fareMinimumChargesWithinKm);
  //   if (distance == null || minChargeDistance == null) {
  //     return;
  //   }
  //
  //   if (distance < minChargeDistance) {
  //     estimatePrice.value = double.parse(intercityModel.farMinimumCharges);
  //   } else {
  //     estimatePrice.value = double.parse(
  //       (double.parse(intercityModel.farePerKm) * distance).toStringAsFixed(2),
  //     );
  //   }
  //   addPriceController.value.text = estimatePrice.value.toString();
  //   isEstimatePriceVisible.value = true;
  // }
  //
  // RxList<ChargesModel> intercitySharingList = <ChargesModel>[].obs;
  //
  // ChargesModel? calculationOfEstimatePrice() {
  //   if (selectedTime.value == 'Select Time' || selectedTime.value.isEmpty) return null;
  //
  //   final selectedDateTime = convertToDateTime(selectedTime.value);
  //   intercitySharingList.value = selectedRideType.value == 1 ? intercityPersonalDocuments.first.zoneCharges : intercitySharingDocuments.first.zoneCharges;
  //
  //   for (var model in intercitySharingList) {
  //     log('Checking time slot: ${model.timeSlot}');
  //     if (isTimeInRange(selectedDateTime, model.timeSlot)) {
  //       return model;
  //     }
  //   }
  //   log("❌ No matching time slot found.");
  //   return null;
  // }
  //
  // bool isTimeInRange(DateTime selectedTime, String timeSlot) {
  //   log("Checking time slot: $timeSlot");
  //
  //   RegExp timeRangeRegex = RegExp(r"(\d+)\s*-\s*(\d+)\s*(AM|PM)", caseSensitive: false);
  //   Match? match = timeRangeRegex.firstMatch(timeSlot);
  //
  //   if (match == null) {
  //     log("❌ Could not extract range from: $timeSlot");
  //     return false;
  //   }
  //
  //   int startHour = int.parse(match.group(1)!);
  //   int endHour = int.parse(match.group(2)!);
  //   String period = match.group(3)!.toUpperCase();
  //
  //   int startMinutes = convertToMinutes(startHour, period);
  //   int endMinutes = convertToMinutes(endHour, period);
  //
  //   if (timeSlot.contains("12-") || timeSlot.contains("Afternoon")) {
  //     if (period == "PM" && endHour < startHour) {
  //       endMinutes += 12 * 60;
  //     }
  //   }
  //
  //   int selectedMinutes = selectedTime.hour * 60 + selectedTime.minute;
  //
  //   if (period == "PM" && selectedTime.hour < 12) {
  //     selectedMinutes += 12 * 60;
  //   }
  //
  //   bool inRange;
  //   if (startMinutes < endMinutes) {
  //     inRange = (selectedMinutes >= startMinutes && selectedMinutes < endMinutes);
  //   } else {
  //     inRange = (selectedMinutes >= startMinutes || selectedMinutes < endMinutes);
  //   }
  //
  //   log("Extracted range: $startHour - $endHour $period -> minutes $startMinutes-$endMinutes");
  //   log("Selected: ${selectedTime.hour}:${selectedTime.minute} ($selectedMinutes min) => Result: $inRange");
  //
  //   return inRange;
  // }
  //
  // int convertToMinutes(int hour, String period) {
  //   if (hour == 12) {
  //     hour = (period == "AM") ? 0 : 12;
  //   } else if (period == "PM") {
  //     hour += 12;
  //   }
  //   return hour * 60;
  // }
  //
  // DateTime convertToDateTime(String time) {
  //   final format = DateFormat("h:mm a");
  //   DateTime dateTime = format.parse(time);
  //   return dateTime;
  // }

  void listenForLiveUpdates() {
    _sharingPersonsSub?.cancel();
    _sharingPersonsSub = FireStoreUtils.getSharingPersonsList((updatedList) {
      final uniquePersons = <String, PersonModel>{};
      for (final person in updatedList) {
        final id = person.id;
        if (id != null && id.isNotEmpty) {
          uniquePersons[id] = person;
        }
      }
      if (totalAddPersonShare.length != uniquePersons.length || !totalAddPersonShare.every((p) => uniquePersons[p.id] != null)) {
        totalAddPersonShare.value = uniquePersons.values.toList();
        log('Updated sharing person list: ${totalAddPersonShare.length}');
      }
    });
  }

  @override
  void onClose() {
    _sharingPersonsSub?.cancel();
    super.onClose();
  }

  void toggleSelection(PersonModel person) {
    final idx = addInSharing.indexWhere((p) => p.id == person.id);
    if (idx != -1) {
      addInSharing.removeAt(idx);
    } else {
      addInSharing.add(person);
    }
    selectedPersons.value = 1 + addInSharing.length;
  }

  void deletePerson(String personId) async {
    final idx = totalAddPersonShare.indexWhere((person) => person.id == personId);
    if (idx != -1) {
      final isDeleted = await FireStoreUtils.deleteSharingPerson(personId);
      if (isDeleted) {
        totalAddPersonShare.removeAt(idx);
        addInSharing.removeWhere((id) => id.id == personId);
        selectedPersons.value = 1 + addInSharing.length;
      }
    }
  }

  Future<void> getTax() async {
    await FireStoreUtils().getTaxList().then((value) {
      if (value != null) {
        Constant.taxList = value;
        taxList.value = value;
      }
    });
  }

  Future<void> bookInterCity() async {
    ShowToastDialog.showLoader("Please wait..".tr);

    /// -------- MAP DATA SYNC (OSM → GOOGLE STRUCTURE) --------
    if (Constant.selectedMap != "Google Map") {
      if (osmSourceLocation != null) {
        sourceLocation = LatLng(
          osmSourceLocation!.latitude,
          osmSourceLocation!.longitude,
        );
      }

      if (osmDestination != null) {
        destination = LatLng(
          osmDestination!.latitude,
          osmDestination!.longitude,
        );
      }

      for (int i = 0; i < osmStopsLatLng.length; i++) {
        if (osmStopsLatLng[i] != null) {
          stopsLatLng[i] = LatLng(
            osmStopsLatLng[i]!.latitude,
            osmStopsLatLng[i]!.longitude,
          );
          googleStopAddresses[i] = osmStopAddresses[i];
        }
      }
    }

    /// -------- REQUIRED LOCATION CHECK --------
    if (sourceLocation == null || destination == null) {
      ShowToastDialog.showToast("Please select both pickup and drop locations.".tr);
      ShowToastDialog.closeLoader();
      return;
    }

    String finalDistance = "0.00";
    if (Constant.selectedMap == "Google Map") {
      finalDistance = distanceCalculate(mapModel.value);
    } else {
      finalDistance = calculateOSMDistance();
    }

    interCityModel.value.dropLocationAddress = dropAddress.value;
    interCityModel.value.pickUpLocationAddress = pikUpAddress.value;
    interCityModel.value.customerId = FireStoreUtils.getCurrentUid();
    interCityModel.value.bookingStatus = BookingStatus.bookingPlaced;
    interCityModel.value.id = Constant.getUuid();
    interCityModel.value.createAt = Timestamp.now();
    interCityModel.value.updateAt = Timestamp.now();
    interCityModel.value.bookingTime = Timestamp.now();
    interCityModel.value.type = 'Intercity Ride';
    interCityModel.value.rideStartTime = selectedTime.value;
    interCityModel.value.vehicleType = vehicleTypeModel.value;
    interCityModel.value.vehicleTypeID = vehicleTypeModel.value.id;
    interCityModel.value.pickUpLocation = LocationLatLng(latitude: sourceLocation!.latitude, longitude: sourceLocation!.longitude);
    interCityModel.value.dropLocation = LocationLatLng(latitude: destination!.latitude, longitude: destination!.longitude);
    interCityModel.value.pickupPosition = Positions(
        geoPoint: GeoFlutterFire().point(latitude: sourceLocation!.latitude, longitude: sourceLocation!.longitude).geoPoint,
        geohash: GeoFlutterFire().point(latitude: sourceLocation!.latitude, longitude: sourceLocation!.longitude).hash);
    interCityModel.value.dropPosition = Positions(
        geoPoint: GeoFlutterFire().point(latitude: destination!.latitude, longitude: destination!.longitude).geoPoint,
        geohash: GeoFlutterFire().point(latitude: destination!.latitude, longitude: destination!.longitude).hash);
    interCityModel.value.sharingPersonList = addInSharing;

    interCityModel.value.distance = DistanceModel(
      distance: finalDistance,
      distanceType: Constant.distanceType,
    );
    interCityModel.value.stops = [];
    for (int i = 0; i < googleStopAddresses.length; i++) {
      if (googleStopAddresses[i].isNotEmpty && stopsLatLng[i] != null) {
        interCityModel.value.stops!.add(
          StopModel(
            location: LocationLatLng(
              latitude: stopsLatLng[i]!.latitude,
              longitude: stopsLatLng[i]!.longitude,
            ),
            address: googleStopAddresses[i],
          ),
        );
      }
    }
    interCityModel.value.zoneModel = selectedZone.value;
    interCityModel.value.otp = Constant.isOtpFeatureEnable == true ? Constant.getOTPCode() : "";
    interCityModel.value.paymentType = selectedPaymentMethod.value;
    interCityModel.value.paymentStatus = false;
    interCityModel.value.isOnlyForFemale = isForFemale.value;
    interCityModel.value.persons = selectedPersons.value.toString();
    interCityModel.value.taxList = taxList;
    interCityModel.value.isPersonalRide = selectedRideType.value == 1 ? true : false;
    interCityModel.value.adminCommission = Constant.adminCommission;
    interCityModel.value.startDate = DateFormat('yyyy-MM-dd').format(selectedDate.value!);
    interCityModel.value.subTotal = addPriceController.value.text;
    interCityModel.value.setPrice = addPriceController.value.text;
    interCityModel.value.recommendedPrice = double.parse(estimatePrice.value.toString()).toString();
    interCityModel.value.discount = discountAmount.value.toString();
    interCityModel.value.coupon = selectedCouponModel.value;

    await FireStoreUtils.setInterCity(interCityModel.value).then((value) {
      if (value == true) {
        ShowToastDialog.closeLoader();
        Get.back();
        Get.back();
        Get.back();
        ShowToastDialog.showToast("Ride Placed Successfully.".tr);
      }
    });
  }

  String distanceCalculate(MapModel? value) {
    if (value == null ||
        value.rows == null ||
        value.rows!.isEmpty ||
        value.rows!.first.elements == null ||
        value.rows!.first.elements!.isEmpty ||
        value.rows!.first.elements!.first.distance == null ||
        value.rows!.first.elements!.first.distance!.value == null) {
      return "0.00";
    }

    final int meters = value.rows!.first.elements!.first.distance!.value!.toInt();

    if (Constant.distanceType == "Km") {
      return (meters / 1000).toStringAsFixed(2);
    } else {
      return (meters / 1609.34).toStringAsFixed(2);
    }
  }

  String calculateOSMDistance() {
    double totalMeters = 0.0;
    LatLng lastPoint = sourceLocation!;

    // stops
    for (final stop in stopsLatLng) {
      if (stop != null) {
        totalMeters += Geolocator.distanceBetween(
          lastPoint.latitude,
          lastPoint.longitude,
          stop.latitude,
          stop.longitude,
        );
        lastPoint = stop;
      }
    }

    // destination
    totalMeters += Geolocator.distanceBetween(
      lastPoint.latitude,
      lastPoint.longitude,
      destination!.latitude,
      destination!.longitude,
    );

    if (Constant.distanceType == "Km") {
      return (totalMeters / 1000).toStringAsFixed(2);
    } else {
      return (totalMeters / 1609.34).toStringAsFixed(2);
    }
  }

  Future<void> updateData() async {
    // 1️⃣ Sync OSM → Google variables
    if (Constant.selectedMap != "Google Map") {
      if (osmSourceLocation != null) {
        sourceLocation = LatLng(osmSourceLocation!.latitude, osmSourceLocation!.longitude);
      }
      if (osmDestination != null) {
        destination = LatLng(osmDestination!.latitude, osmDestination!.longitude);
      }
      for (int i = 0; i < osmStopsLatLng.length; i++) {
        if (osmStopsLatLng[i] != null) {
          stopsLatLng[i] = LatLng(osmStopsLatLng[i]!.latitude, osmStopsLatLng[i]!.longitude);
          googleStopAddresses[i] = osmStopAddresses[i];
        }
      }
    }

    // 2️⃣ Check required locations
    if (sourceLocation == null || destination == null) {
      ShowToastDialog.closeLoader();
      return;
    }
    ShowToastDialog.showLoader("Please wait".tr);
    try {
      // 3️⃣ Calculate distance
      if (Constant.selectedMap == "Google Map") {
        mapModel.value = await Constant.getDurationDistance(sourceLocation!, destination!);
        distanceOfKm.value = DistanceModel(
          distance: distanceCalculate(mapModel.value),
          distanceType: Constant.distanceType,
        );
      } else {
        distanceOfKm.value = DistanceModel(
          distance: calculateOSMDistance(),
          distanceType: Constant.distanceType,
        );
      }

      // 4️⃣ Update price & zone
      updateCalculation();
      if (sourceLocation != null) findZone();
    } catch (e) {
      log("Error in updateData: $e");
    } finally {
      ShowToastDialog.closeLoader();
    }
  }

  Future<void> addPerson() async {
    ShowToastDialog.showLoader("Please wait..".tr);
    final name = enterNameController.value.text.trim();
    final number = enterNumberController.value.text.trim();
    if (number.isNotEmpty && totalAddPersonShare.any((p) => p.mobileNumber == number)) {
      ShowToastDialog.showToast("Person with this number already exists".tr);
      ShowToastDialog.closeLoader();
      return;
    }
    personModel.value.id = Constant.getUuid();
    personModel.value.mobileNumber = number;
    personModel.value.name = name;
    await FireStoreUtils.addSharingPerson(personModel.value);
    enterNameController.value.clear();
    enterNumberController.value.clear();
    ShowToastDialog.closeLoader();
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

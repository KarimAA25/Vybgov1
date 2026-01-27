// ignore_for_file: depend_on_referenced_packages

import 'dart:io';

import 'package:admin/app/constant/collection_name.dart';
import 'package:admin/app/constant/constants.dart';
import 'package:admin/app/constant/show_toast.dart';
import 'package:admin/app/models/vehicle_type_model.dart';
import 'package:admin/app/models/zone_model.dart';
import 'package:admin/app/utils/fire_store_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class VehicleTypeScreenController extends GetxController {
  RxString title = "VehicleType".obs;
  RxBool isEnable = false.obs;
  Rx<File> imageFile = File('').obs;
  RxString mimeType = 'image/png'.obs;
  RxBool isLoading = false.obs;
  RxBool isEditing = false.obs;
  RxBool isImageUpdated = false.obs;
  RxString imageURL = "".obs;
  RxString editingId = "".obs;
  Rx<TextEditingController> vehicleTitle = TextEditingController().obs;
  Rx<TextEditingController> person = TextEditingController().obs;
  RxList<VehicleTypeModel> vehicleTypeList = <VehicleTypeModel>[].obs;
  Rx<TextEditingController> vehicleTypeImage = TextEditingController().obs;

  // RxList<TextEditingController> perKmControllers = <TextEditingController>[].obs;
  // RxList<TextEditingController> minimumChargesControllers = <TextEditingController>[].obs;
  // RxList<TextEditingController> minimumChargeWithKmControllers = <TextEditingController>[].obs;
  // RxList<TextEditingController> holdingChargeControllers = <TextEditingController>[].obs;
  // RxList<TextEditingController> minuteChargeControllers = <TextEditingController>[].obs;
  // RxList<TextEditingController> incrementForNightChargeControllers = <TextEditingController>[].obs;

  RxList<ZoneModel> zoneList = <ZoneModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    getData();
  }

  void getArgument(VehicleTypeModel vehicleModel) {
    isEditing.value = true;
    editingId.value = vehicleModel.id!;
    imageURL.value = vehicleModel.image!;
    editingId.value = vehicleModel.id!;
    isEnable.value = vehicleModel.isActive!;
    vehicleTitle.value.text = vehicleModel.title!;
    person.value.text = vehicleModel.persons!;
    vehicleTypeImage.value.text = vehicleModel.image!;

    debugPrint("Vehicle model zone charges count: ${vehicleModel.zoneCharges?.length ?? 0}");

    // Map each zone in zoneList
    zoneList.value = zoneList.map((element) {
      debugPrint("Mapping Zone ID: '${element.id}', Name: '${element.name}'");

      // Find corresponding charges by matching trimmed IDs
      ZoneChargesModel? match = vehicleModel.zoneCharges?.firstWhere(
        (zc) => zc.zoneId?.trim() == element.id?.trim(),
        orElse: () {
          debugPrint("No match found for Zone ID '${element.id}', creating default Charges.");
          return ZoneChargesModel(
            zoneId: element.id,
            zoneName: element.name,
            charges: Charges(
              fareMinimumChargesWithinKm: '0',
              farMinimumCharges: '0',
              farePerKm: '0',
              holdCharge: '0',
              minuteCharge: '0',
              incrementOfNightCharge: '0',
            ),
          );
        },
      );

      debugPrint("Matched ZoneChargesModel: ZoneID='${match!.zoneId}', Charges: ${match.charges?.toJson()}");

      // Initialize element.charges with string values (safe)
      element.charges = Charges(
        fareMinimumChargesWithinKm: match.charges?.fareMinimumChargesWithinKm?.toString() ?? '0',
        farMinimumCharges: match.charges?.farMinimumCharges?.toString() ?? '0',
        farePerKm: match.charges?.farePerKm?.toString() ?? '0',
        holdCharge: match.charges?.holdCharge?.toString() ?? '0',
        minuteCharge: match.charges?.minuteCharge?.toString() ?? '0',
        incrementOfNightCharge: match.charges?.incrementOfNightCharge?.toString() ?? '0',
      );

      element.minDistanceController ??= TextEditingController();
      element.minDistanceController!.text = element.charges?.fareMinimumChargesWithinKm ?? '';

      element.minFareController ??= TextEditingController();
      element.minFareController!.text = element.charges?.farMinimumCharges ?? '';

      element.perKmController ??= TextEditingController();
      element.perKmController!.text = element.charges?.farePerKm ?? '';

      element.holdChargeController ??= TextEditingController();
      element.holdChargeController!.text = element.charges?.holdCharge ?? '';

      element.minuteChargeController ??= TextEditingController();
      element.minuteChargeController!.text = element.charges?.minuteCharge ?? '';

      element.nightChargeController ??= TextEditingController();
      element.nightChargeController!.text = element.charges?.incrementOfNightCharge ?? '';

      return element;
    }).toList();

    debugPrint("Zone mapping complete. Total zones: ${zoneList.length}");
  }

  Future<void> getData() async {
    isLoading(true);
    vehicleTypeList.clear();
    List<VehicleTypeModel> data = await FireStoreUtils.getVehicleType();
    vehicleTypeList.addAll(data);
    await getZoneList();
    isLoading(false);
  }

  Future<void> getZoneList() async {
    await FireStoreUtils.getActiveZones().then((value) {
      if (value != null) {
        zoneList.clear();
        for (var element in value) {
          element.charges ??= Charges();

          // attach controllers once
          element.minDistanceController = TextEditingController(text: element.charges?.fareMinimumChargesWithinKm ?? '');
          element.minFareController = TextEditingController(text: element.charges?.farMinimumCharges ?? '');
          element.perKmController = TextEditingController(text: element.charges?.farePerKm ?? '');
          element.holdChargeController = TextEditingController(text: element.charges?.holdCharge ?? '');
          element.minuteChargeController = TextEditingController(text: element.charges?.minuteCharge ?? '');
          element.nightChargeController = TextEditingController(text: element.charges?.incrementOfNightCharge ?? '');

          zoneList.add(element);
        }
      }
    });
  }

  Future<void> updateVehicleType() async {
    isLoading = true.obs;
    String docId = editingId.value;
    String vehicleUrl = imageURL.value;
    if (isImageUpdated.value && imageFile.value.path.isNotEmpty) {
      vehicleUrl = await FireStoreUtils.uploadPic(PickedFile(imageFile.value.path), "vehicleTyepImage", docId, mimeType.value);
    }
    List<ZoneChargesModel> updatedZoneCharges = zoneList.map((zone) {
      return ZoneChargesModel(
        zoneId: zone.id,
        zoneName: zone.name,
        charges: zone.charges, // already updated via controllers
      );
    }).toList();

    await FireStoreUtils.updateVehicleType(VehicleTypeModel(
      id: docId,
      image: vehicleUrl,
      isActive: isEnable.value,
      title: vehicleTitle.value.text,
      persons: person.value.text,
      zoneCharges: updatedZoneCharges,
    ));
    await getData();
    isLoading = false.obs;
  }

  Future<void> addVehicleType() async {
    isLoading = true.obs;
    String docId = Constant.getRandomString(20);
    String url = '';
    if (imageFile.value.path.isNotEmpty) {
      url = await FireStoreUtils.uploadPic(PickedFile(imageFile.value.path), "vehicleTyepImage", docId, mimeType.value);
    }
    List<ZoneChargesModel> zoneChargesList = zoneList.map((zone) {
      return ZoneChargesModel(
        zoneId: zone.id,
        zoneName: zone.name,
        charges: zone.charges, // already updated via controllers
      );
    }).toList();

    await FireStoreUtils.addVehicleType(VehicleTypeModel(
      id: docId,
      image: url,
      isActive: isEnable.value,
      title: vehicleTitle.value.text,
      persons: person.value.text,
      zoneCharges: zoneChargesList,
    ));
    await getData();
    isLoading = false.obs;
  }

  Future<void> removeVehicleTypeModel(VehicleTypeModel vehicleTypeModel) async {
    isLoading = true.obs;
    await FirebaseFirestore.instance.collection(CollectionName.vehicleType).doc(vehicleTypeModel.id).delete().then((value) {
      ShowToastDialog.successToast("VehicleType deleted...!".tr);
    }).catchError((error) {
      ShowToastDialog.errorToast("Something went wrong".tr);
    });
    await getData();
    isLoading = false.obs;
  }

  void setDefaultData() {
    vehicleTitle.value.text = "";
    vehicleTypeImage.value.clear();
    person.value.text = "";
    imageFile.value = File('');
    mimeType.value = 'image/png';
    imageURL.value = '';
    editingId.value = '';
    isEditing.value = false;
    isEnable.value = false;
    isImageUpdated.value = false;
    for (var zone in zoneList) {
      zone.charges = Charges();
      zone.minDistanceController?.text = '';
      zone.minFareController?.text = '';
      zone.perKmController?.text = '';
      zone.holdChargeController?.text = '';
      zone.minuteChargeController?.text = '';
      zone.nightChargeController?.text = '';
    }
  }
}

// class VehicleTypeScreenController extends GetxController {
//   Rx<TextEditingController> vehicleTitle = TextEditingController().obs;
//   Rx<TextEditingController> person = TextEditingController().obs;
//   RxList<VehicleTypeModel> vehicleTypeList = <VehicleTypeModel>[].obs;
//   Rx<TextEditingController> vehicleTypeImage = TextEditingController().obs;
//   RxString title = "VehicleType".obs;
//   RxBool isEnable = false.obs;
//   Rx<File> imageFile = File('').obs;
//   RxString mimeType = 'image/png'.obs;
//   RxBool isLoading = false.obs;
//   RxBool isEditing = false.obs;
//   RxBool isImageUpdated = false.obs;
//   RxString imageURL = "".obs;
//   RxString editingId = "".obs;
//
//   final List<String> timeSlots = ["Early Morning 4-8 AM", "Morning 8-12 AM", "Afternoon 12-4 PM", "Evening 4-8 PM", "Night 8 PM-12 AM", "Midnight 12-4 AM"];
//   RxList<ZoneChargesModel> serviceSlots = <ZoneChargesModel>[].obs;
//   RxList<TextEditingController> perKmControllers = <TextEditingController>[].obs;
//   RxList<TextEditingController> minimumChargesControllers = <TextEditingController>[].obs;
//   RxList<TextEditingController> minimumChargeWithKmControllers = <TextEditingController>[].obs;
//   List<Charges> updatedTimeSlots = [];
//   RxBool allFillChecked = false.obs;
//   RxBool isFillAll = false.obs;
//
//   RxString selectedZoneId = "".obs;
//   RxList<ZoneModel> zoneList = <ZoneModel>[].obs;
//
//   @override
//   void onInit() {
//     getData();
//     super.onInit();
//   }
//
//   void fillAllValues() {
//     if (perKmControllers.isNotEmpty && minimumChargesControllers.isNotEmpty && minimumChargeWithKmControllers.isNotEmpty) {
//       String minChargeWithKm = minimumChargeWithKmControllers[0].text;
//       String farePerKm = perKmControllers[0].text;
//       String minCharge = minimumChargesControllers[0].text;
//
//       for (int i = 1; i < timeSlots.length; i++) {
//         minimumChargeWithKmControllers[i].text = minChargeWithKm;
//         perKmControllers[i].text = farePerKm;
//         minimumChargesControllers[i].text = minCharge;
//       }
//     }
//   }
//
//   Future<void> getData() async {
//     isLoading(true);
//     vehicleTypeList.clear();
//     serviceSlots.clear();
//     perKmControllers.clear();
//     minimumChargesControllers.clear();
//     minimumChargeWithKmControllers.clear();
//     isFillAll.value = false;
//     List<VehicleTypeModel> data = await FireStoreUtils.getVehicleType();
//     vehicleTypeList.addAll(data);
//     getZoneList();
//     isLoading(false);
//   }
//
//   Future<void> getZoneList() async {
//     await FireStoreUtils.getActiveZones().then(
//       (value) {
//         if (value != null) {
//           zoneList.value = value;
//         }
//       },
//     );
//   }
//
//   void setDefaultData() {
//     vehicleTitle.value.text = "";
//     vehicleTypeImage.value.clear();
//     person.value.text = "";
//     imageFile.value = File('');
//     mimeType.value = 'image/png';
//     imageURL.value = '';
//     editingId.value = '';
//     isEditing.value = false;
//     isEnable.value = false;
//     isImageUpdated.value = false;
//     isFillAll.value = false;
//     allFillChecked.value = false;
//   }
//
//   Future<void> updateVehicleType() async {
//     // isLoading = true.obs;
//     // updatedTimeSlots.clear();
//     // for (int i = 0; i < serviceSlots.length; i++) {
//     //   updatedTimeSlots.add(TimeSlotsChargesModel(
//     //     timeSlot: serviceSlots[i].timeSlot,
//     //     fareMinimumChargesWithinKm: minimumChargeWithKmControllers[i].text.trim(),
//     //     farePerKm: perKmControllers[i].text.trim(),
//     //     farMinimumCharges: minimumChargesControllers[i].text.trim(),
//     //   ));
//     // }
//     // String docId = editingId.value;
//     // String vehicleUrl = imageURL.value;
//     // if (isImageUpdated.value && imageFile.value.path.isNotEmpty) {
//     //   vehicleUrl = await FireStoreUtils.uploadPic(PickedFile(imageFile.value.path), "vehicleTyepImage", docId, mimeType.value);
//     // }
//     // await FireStoreUtils.updateVehicleType(VehicleTypeModel(
//     //   timeSlots: updatedTimeSlots,
//     //   id: docId,
//     //   image: vehicleUrl,
//     //   isActive: isEnable.value,
//     //   title: vehicleTitle.value.text,
//     //   persons: person.value.text,
//     // ));
//     // await getData();
//     // isLoading = false.obs;
//   }
//
//   Future<void> addVehicleType() async {
//     // isLoading = true.obs;
//     // String docId = Constant.getRandomString(20);
//     // String url = '';
//     // if (imageFile.value.path.isNotEmpty) {
//     //   url = await FireStoreUtils.uploadPic(PickedFile(imageFile.value.path), "vehicleTyepImage", docId, mimeType.value);
//     // }
//     // updatedTimeSlots.clear();
//     // for (int i = 0; i < serviceSlots.length; i++) {
//     //   updatedTimeSlots.add(TimeSlotsChargesModel(
//     //     timeSlot: serviceSlots[i].timeSlot,
//     //     fareMinimumChargesWithinKm: minimumChargeWithKmControllers[i].text.trim(),
//     //     farePerKm: perKmControllers[i].text.trim(),
//     //     farMinimumCharges: minimumChargesControllers[i].text.trim(),
//     //   ));
//     // }
//     // await FireStoreUtils.addVehicleType(VehicleTypeModel(
//     //   timeSlots: updatedTimeSlots,
//     //   id: docId,
//     //   image: url,
//     //   isActive: isEnable.value,
//     //   title: vehicleTitle.value.text,
//     //   persons: person.value.text,
//     // ));
//     // await getData();
//     // isLoading = false.obs;
//   }
//
//   Future<void> removeVehicleTypeModel(VehicleTypeModel vehicleTypeModel) async {
//     isLoading = true.obs;
//     await FirebaseFirestore.instance.collection(CollectionName.vehicleType).doc(vehicleTypeModel.id).delete().then((value) {
//       ShowToastDialog.successToast("VehicleType deleted...!".tr);
//     }).catchError((error) {
//       ShowToastDialog.errorToast("Something went wrong".tr);
//     });
//     await getData();
//     isLoading = false.obs;
//   }
// }

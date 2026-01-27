// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter, depend_on_referenced_packages, use_build_context_synchronously, unused_local_variable
import 'package:admin/app/constant/constants.dart';
import 'package:admin/app/constant/show_toast.dart';
import 'package:admin/app/models/rental_package_model.dart';
import 'package:admin/app/models/vehicle_type_model.dart';
import 'package:admin/app/utils/fire_store_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../constant/collection_name.dart';

class RentalPackageScreenController extends GetxController {
  RxString title = "Rental Package".tr.obs;
  RxBool isLoading = true.obs;
  Rx<TextEditingController> titleController = TextEditingController().obs;
  Rx<TextEditingController> baseFareController = TextEditingController().obs;
  Rx<TextEditingController> includedHoursController = TextEditingController().obs;
  Rx<TextEditingController> includedDistanceController = TextEditingController().obs;
  Rx<TextEditingController> extraKmFareController = TextEditingController().obs;
  Rx<TextEditingController> extraHourFareController = TextEditingController().obs;
  Rx<VehicleTypeModel> selectedVehicleId = VehicleTypeModel().obs;
  RxBool isEditing = false.obs;
  RxBool isEnable = false.obs;
  Rx<RentalPackageModel> rentalPackageModel = RentalPackageModel().obs;
  RxList<RentalPackageModel> rentalPackageList = <RentalPackageModel>[].obs;
  RxList<VehicleTypeModel> vehicleList = <VehicleTypeModel>[].obs;

  RxString editingId = "".obs;

  @override
  void onInit() {
    super.onInit();
    getData();
    getVehicleData();
  }

  @override
  void onClose() {
    titleController.value.dispose();
    baseFareController.value.dispose();
    includedHoursController.value.dispose();
    includedDistanceController.value.dispose();
    extraKmFareController.value.dispose();
    extraHourFareController.value.dispose();
    super.onClose();
  }

  Future<void> getData() async {
    isLoading.value = true;
    rentalPackageList.clear();

    try {
      List<RentalPackageModel> data = await FireStoreUtils.getRentalPackage();

      // 🔥 Sort packages based on numeric value of baseFare (string)
      data.sort((a, b) {
        final aFare = double.tryParse(a.baseFare ?? "0") ?? 0;
        final bFare = double.tryParse(b.baseFare ?? "0") ?? 0;
        return aFare.compareTo(bFare); // ascending (lowest → highest)
      });

      rentalPackageList.addAll(data);
    } catch (e, stack) {
      log('Error fetching RentalList: $e\n$stack');
      ShowToastDialog.errorToast('Failed to load RentalPackageList');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getVehicleData() async {
    await FireStoreUtils.getVehicleType().then(
      (value) {
        vehicleList.value = value;
      },
    );
  }

  void setDefaultData() {
    titleController.value.text = "";
    baseFareController.value.text = "";
    includedHoursController.value.text = "";
    includedDistanceController.value.text = "";
    extraKmFareController.value.text = "";
    extraHourFareController.value.text = "";
    selectedVehicleId.value = VehicleTypeModel();
    isEnable.value = false;
    isEditing.value = false;
  }

  Future<void> addRentalPackage(BuildContext context) async {
    Constant.loader();
    isLoading.value = true;
    rentalPackageModel.value.id = Constant.getRandomString(20);
    rentalPackageModel.value.title = titleController.value.text;
    rentalPackageModel.value.baseFare = baseFareController.value.text;
    rentalPackageModel.value.includedHours = includedHoursController.value.text;
    rentalPackageModel.value.includedDistance = includedDistanceController.value.text;
    rentalPackageModel.value.extraKmFare = extraKmFareController.value.text;
    rentalPackageModel.value.extraHourFare = extraHourFareController.value.text;
    rentalPackageModel.value.vehicleId = selectedVehicleId.value.id!;

    ShowToastDialog.closeLoader();
    await FireStoreUtils.addRentalPackage(rentalPackageModel.value).then((value) async {
      if (value == true) {
        ShowToastDialog.successToast("Rental Package Added".tr);
        setDefaultData();
        await getData();
        Get.back();
      }
    });
    isLoading.value = false;
  }

  Future<bool> removeRentalPackage(String docId) {
    return FirebaseFirestore.instance.collection(CollectionName.rentalPackage).doc(docId).delete().then((value) async {
      return true;
    }).catchError((error) {
      return false;
    });
  }

  Future<void> updateRentalPackage(RentalPackageModel rentalPackageModel) async {
    isLoading.value = true;
    rentalPackageModel.id = editingId.value;
    rentalPackageModel.title = titleController.value.text;
    rentalPackageModel.baseFare = baseFareController.value.text;
    rentalPackageModel.extraKmFare = extraKmFareController.value.text;
    rentalPackageModel.extraHourFare = extraHourFareController.value.text;
    rentalPackageModel.includedHours = includedHoursController.value.text;
    rentalPackageModel.includedDistance = includedDistanceController.value.text;
    rentalPackageModel.vehicleId = selectedVehicleId.value.id;

    bool isSaved = await FireStoreUtils.updateRentalPackage(rentalPackageModel);
    if (isSaved) {
      Get.back();
      getData();
      ShowToastDialog.successToast("Rental Package Updated Successfully".tr);
    } else {
      ShowToastDialog.errorToast("Something went wrong, Please try later!");
      isLoading.value = false;
    }
  }
}

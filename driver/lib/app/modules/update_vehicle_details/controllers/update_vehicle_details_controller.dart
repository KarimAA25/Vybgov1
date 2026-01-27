import 'package:driver/app/models/zone_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:driver/app/models/driver_user_model.dart';
import 'package:driver/app/models/vehicle_brand_model.dart';
import 'package:driver/app/models/vehicle_model_model.dart';
import 'package:driver/app/models/vehicle_type_model.dart';
import 'package:driver/constant_widgets/show_toast_dialog.dart';
import 'package:driver/utils/fire_store_utils.dart';

class UpdateVehicleDetailsController extends GetxController {
  Rx<DriverVehicleDetails> driverDetails = DriverVehicleDetails().obs;

  Rx<VehicleBrandModel> selectedBrandModel = VehicleBrandModel().obs;
  Rx<VehicleModelModel> selectedVehicleModelModel = VehicleModelModel().obs;
  Rx<VehicleTypeModel> selectedVehicleTypeModel = VehicleTypeModel().obs;

  RxList<VehicleTypeModel> vehicleTypeList = <VehicleTypeModel>[].obs;
  RxList<VehicleBrandModel> vehicleBrandList = <VehicleBrandModel>[].obs;
  RxList<VehicleModelModel> vehicleModelList = <VehicleModelModel>[].obs;

  TextEditingController vehicleModelController = TextEditingController();
  TextEditingController vehicleBrandController = TextEditingController();
  TextEditingController vehicleNumberController = TextEditingController();

  RxList<ZoneModel> zoneList = <ZoneModel>[].obs;
  RxList<String> selectedZoneIds = <String>[].obs;

  Rx<DriverUserModel> userModel = DriverUserModel().obs;
  RxBool isLoading = false.obs;

  @override
  Future<void> onInit() async {
    getData();
    super.onInit();
  }

  Future<void> getData() async {
    vehicleBrandList.value = await FireStoreUtils.getVehicleBrand();
    vehicleTypeList.value = await FireStoreUtils.getVehicleType();
    zoneList.value = await FireStoreUtils.getZoneList();
    await FireStoreUtils.getDriverUserProfile(FireStoreUtils.getCurrentUid()).then((value) {
      if (value != null) {
        userModel.value = value;
        selectedZoneIds.value = value.zoneId ?? [];
        getDriverVehicleDetails();
      }
    });
  }

  Future<void> getDriverVehicleDetails() async {
    if (userModel.value.driverVehicleDetails != null || userModel.value.driverVehicleDetails!.vehicleTypeId!.isNotEmpty) {
      vehicleBrandController.text = userModel.value.driverVehicleDetails!.brandName ?? '';
      vehicleModelController.text = userModel.value.driverVehicleDetails!.modelName ?? '';
      vehicleNumberController.text = userModel.value.driverVehicleDetails!.vehicleNumber ?? '';

      selectedVehicleTypeModel.value = vehicleTypeList.firstWhere((element) => element.id == userModel.value.driverVehicleDetails!.vehicleTypeId);
      selectedBrandModel.value = vehicleBrandList.firstWhere((element) => element.id == userModel.value.driverVehicleDetails!.brandId);
      await getVehicleModel(selectedBrandModel.value.id.toString());
      selectedVehicleModelModel.value = vehicleModelList.firstWhere((element) => element.id == userModel.value.driverVehicleDetails!.modelId);
    }
  }

  Future<void> getVehicleModel(String id) async {
    vehicleModelList.value = await FireStoreUtils.getVehicleModel(id);
  }

  Future<void> saveVehicleDetails() async {
    ShowToastDialog.showLoader("Please Wait..".tr);
    bool isNewVehicle = userModel.value.driverVehicleDetails == null;
    DriverVehicleDetails driverVehicleDetails = DriverVehicleDetails(
      brandName: selectedBrandModel.value.title,
      brandId: selectedBrandModel.value.id,
      modelName: selectedVehicleModelModel.value.title,
      modelId: selectedVehicleModelModel.value.id,
      vehicleNumber: vehicleNumberController.text,
      vehicleTypeName: selectedVehicleTypeModel.value.title,
      vehicleTypeId: selectedVehicleTypeModel.value.id,
    );
    userModel.value.zoneId = selectedZoneIds.toList();
    userModel.value.driverVehicleDetails = driverVehicleDetails;

    bool isUpdated = await FireStoreUtils.updateDriverUser(userModel.value);
    ShowToastDialog.closeLoader();
    if (isUpdated) {
      if (isNewVehicle) {
        ShowToastDialog.showToast("Vehicle details added successfully.".tr);
      } else {
        ShowToastDialog.showToast("Vehicle details updated successfully.".tr);
      } //ShowToastDialog.showToast("Vehicle details updated, Please Wait.. for verification.");
      Get.back(result: true);
    } else {
      ShowToastDialog.showToast("Something went wrong, Please try again later.".tr);
      Get.back();
    }
  }
}

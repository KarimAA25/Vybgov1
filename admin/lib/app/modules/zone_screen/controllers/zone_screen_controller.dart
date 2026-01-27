// ignore_for_file: depend_on_referenced_packages, body_might_complete_normally_catch_error, use_build_context_synchronously, avoid_web_libraries_in_flutter, unused_local_variable

import 'package:admin/app/constant/collection_name.dart';
import 'package:admin/app/constant/show_toast.dart';
import 'package:admin/app/models/intercity_document_model.dart';
import 'package:admin/app/models/vehicle_type_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../../models/zone_model.dart';
import '../../../utils/fire_store_utils.dart';

class ZoneScreenController extends GetxController {
  RxString title = 'Zone'.tr.obs;
  RxBool isLoading = false.obs;
  RxBool isEditing = false.obs;
  RxString editingId = "".obs;
  RxList<ZoneModel> zoneList = <ZoneModel>[].obs;

  @override
  void onInit() {
    getData();
    super.onInit();
  }

  Future<void> getData() async {
    isLoading.value = true;
    try {
      zoneList.clear();
      final data = await FireStoreUtils.getZones();
      if (data!.isNotEmpty) {
        zoneList.addAll(data);
      }
    } catch (e) {
      ShowToastDialog.errorToast('Failed to load zones');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> removeZone(ZoneModel zoneModel) async {
    isLoading.value = true;

    try {
      // Step 1: Delete Zone from zones collection
      await FirebaseFirestore.instance.collection(CollectionName.zones).doc(zoneModel.id).delete();

      // Step 2: Remove zoneCharges entry from all vehicleTypes
      final vehicleTypes = await FirebaseFirestore.instance.collection(CollectionName.vehicleType).get();
      for (var vehicleDoc in vehicleTypes.docs) {
        final data = vehicleDoc.data();
        VehicleTypeModel vehicleType = VehicleTypeModel.fromJson(data);
        vehicleType.zoneCharges = vehicleType.zoneCharges?.where((zc) => zc.zoneId != zoneModel.id).toList();
        await vehicleDoc.reference.update({
          "zoneCharges": vehicleType.zoneCharges?.map((zc) => zc.toJson()).toList(),
        });
      }

      // Step 3: Remove zoneCharges entry from all intercity_service docs
      final interCityTypes = await FirebaseFirestore.instance.collection("intercity_service").get();
      for (var interCityDoc in interCityTypes.docs) {
        final data = interCityDoc.data();
        IntercityDocumentModel interCityType = IntercityDocumentModel.fromJson(interCityDoc.id, data);
        interCityType.zoneCharges = interCityType.zoneCharges.where((zc) => zc.zoneId != zoneModel.id).toList();
        await interCityDoc.reference.update({
          "zoneCharges": interCityType.zoneCharges.map((zc) => zc.toJson()).toList(),
        });
      }

      ShowToastDialog.successToast("Zone deleted successfully!".tr);
    } catch (error) {
      ShowToastDialog.errorToast("Something went wrong while deleting zone".tr);
    }

    await getData();
    isLoading.value = false;
  }
}

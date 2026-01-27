import 'package:driver/app/models/parcel_model.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:get/get.dart';

class ParcelRideForHomeController extends GetxController {
  RxList<ParcelModel> parcelRideList = <ParcelModel>[].obs;

  @override
  void onInit() {
    getParcelRides();
    super.onInit();
  }

  Future<void> getParcelRides() async {
    FireStoreUtils.getParcelOngoingRides((List<ParcelModel> updatedList) {
      parcelRideList.value = updatedList;
    });
  }
}

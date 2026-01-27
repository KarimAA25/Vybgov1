import 'package:driver/app/models/rental_booking_model.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:get/get.dart';

class RentalRidesController extends GetxController {
  var selectedType = 0.obs;

  @override
  void onInit() {
    getData(isActiveDataFetch: true, isOngoingDataFetch: true, isCompletedDataFetch: true, isRejectedDataFetch: true);
    super.onInit();
  }

  RxBool isLoading = true.obs;

  RxList<RentalBookingModel> activeRides = <RentalBookingModel>[].obs;
  RxList<RentalBookingModel> ongoingRides = <RentalBookingModel>[].obs;
  RxList<RentalBookingModel> completedRides = <RentalBookingModel>[].obs;
  RxList<RentalBookingModel> rejectedRides = <RentalBookingModel>[].obs;

  Future<void> getData({required bool isActiveDataFetch, required bool isOngoingDataFetch, required bool isCompletedDataFetch, required bool isRejectedDataFetch}) async {
    if (isActiveDataFetch) {
      FireStoreUtils.getRentalActiveRides((List<RentalBookingModel> updatedList) {
        activeRides.value = updatedList;
      });
    }

    if (isOngoingDataFetch) {
      FireStoreUtils.getRentalOngoingRides((List<RentalBookingModel> updatedList) {
        ongoingRides.value = updatedList;
      });
    }
    if (isCompletedDataFetch) {
      FireStoreUtils.getRentalCompletedRides((List<RentalBookingModel> completeList) {
        completedRides.value = completeList;
      });
    }

    if (isRejectedDataFetch) {
      FireStoreUtils.getRentalRejectedRides((List<RentalBookingModel> rejectList) {
        rejectedRides.value = rejectList;
      });
    }
    isLoading.value = false;
  }
}

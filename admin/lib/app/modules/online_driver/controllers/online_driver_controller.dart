import 'dart:developer';
import 'package:admin/app/constant/collection_name.dart';
import 'package:admin/app/constant/constants.dart';
import 'package:admin/app/models/driver_user_model.dart';
import 'package:admin/app/utils/fire_store_utils.dart';
import 'package:admin/app/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart' as osm;
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong2/latlong.dart' as osm_lat_lng;
import '../../../routes/app_pages.dart';

class OnlineDriverController extends GetxController {
  RxBool isLoading = true.obs;
  RxString title = "Online Drivers".tr.obs;
  GoogleMapController? googleMapController;
  osm.MapController? osmMapController;

  RxList<DriverUserModel> onlineDriverList = <DriverUserModel>[].obs;
  RxSet<Marker> markers = <Marker>{}.obs;
  RxList<osm.Marker> osmMarkers = <osm.Marker>[].obs;

  @override
  void onInit() {
    getData();
    super.onInit();
  }

  Future<void> getData() async {
    await getLocation();
    await addMarkerSetup();
    getOnlineDriver();
  }

  Future<void> getLocation() async {
    Constant.currentPosition = await Utils.getCurrentLocation();
  }

  void getOnlineDriver() {
    FireStoreUtils.fireStore
        .collection(CollectionName.drivers)
        .where('isActive', isEqualTo: true)
        .where('isOnline', isEqualTo: true)
        .where('isVerified', isEqualTo: true)
        .snapshots()
        .listen((event) {
      if (event.docs.isNotEmpty) {
        onlineDriverList.clear();
        markers.clear();

        for (var doc in event.docs) {
          final driverUserModel = DriverUserModel.fromJson(doc.data());
          onlineDriverList.add(driverUserModel);

          if (driverUserModel.location != null && driverUserModel.location!.latitude != null && driverUserModel.location!.longitude != null) {
            final id = driverUserModel.id ?? '';
            markers.add(
              Marker(
                markerId: MarkerId(driverUserModel.id ?? ''),
                position: LatLng(
                  driverUserModel.location!.latitude!,
                  driverUserModel.location!.longitude!,
                ),
                icon: driverIcon ?? BitmapDescriptor.defaultMarker,
                infoWindow: InfoWindow(title: driverUserModel.fullName),
                rotation: driverUserModel.rotation ?? 0.0,
                anchor: const Offset(0.5, 0.5),
                flat: true,
                onTap: () {
                  if (id.isEmpty) {
                    log('Driver id is empty, cannot navigate');
                    return;
                  }
                  Get.toNamed('${Routes.DRIVER_DETAIL_SCREEN}/$id');
                },
              ),
            );

            osmMarkers.add(osm.Marker(
                point: osm_lat_lng.LatLng(driverUserModel.location!.latitude!, driverUserModel.location!.longitude!),
                child: GestureDetector(
                  onTap: () {
                    if (id.isEmpty) return;
                    Get.toNamed('${Routes.DRIVER_DETAIL_SCREEN}/$id');
                  },
                  child: Transform.rotate(
                    angle: ((driverUserModel.rotation ?? 0) * 3.1415926535) / 180,
                    child: Image.asset(
                      'assets/icons/ic_car_4.png',
                      width: 30,
                      height: 30,
                    ),
                  ),
                )));
          }
        }
      } else {
        onlineDriverList.clear();
        markers.clear();
        osmMarkers.clear();
      }
      isLoading.value = false;
      update();
    });
  }

  BitmapDescriptor? driverIcon;

  Future<void> addMarkerSetup() async {
    final Uint8List pickUpUint8List = await Constant.getBytesFromAsset('assets/icons/ic_car_4.png', 20);
    driverIcon = BitmapDescriptor.fromBytes(pickUpUint8List);
  }
}

// ignore_for_file: depend_on_referenced_packages
import 'dart:developer';
import 'package:admin/app/models/intercity_document_model.dart';
import 'package:admin/app/models/intercity_time_model.dart';
import 'package:admin/app/models/vehicle_type_model.dart';
import 'package:admin/app/models/zone_model.dart';
import 'package:admin/app/utils/fire_store_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IntercityServiceController extends GetxController {
  RxString title = "Intercity Service".tr.obs;

  RxBool isEditing = false.obs;
  RxBool isLoading = false.obs;
  RxBool isActive = false.obs;
  RxString editingId = "".obs;
  RxList<InterCityTimeModel> serviceList = <InterCityTimeModel>[].obs;
  RxList<ZoneChargesModel> serviceSlots = <ZoneChargesModel>[].obs;

  // RxList<TextEditingController> perKmControllers = <TextEditingController>[].obs;
  // RxList<TextEditingController> minimumChargesControllers = <TextEditingController>[].obs;
  // RxList<TextEditingController> minimumChargeWithKmControllers = <TextEditingController>[].obs;
  // RxList<TextEditingController> holdingChargeControllers = <TextEditingController>[].obs;
  // RxList<TextEditingController> incrementForNightChargeControllers = <TextEditingController>[].obs;
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;

  RxList<IntercityDocumentModel> intercityDocuments = <IntercityDocumentModel>[].obs;
  RxString selectedDocId = ''.obs;

  RxString selectedZoneId = "".obs;
  RxList<ZoneModel> zoneList = <ZoneModel>[].obs;

  void setDefaultData() {
    if (serviceList.isEmpty) {
      serviceList.add(InterCityTimeModel(title: "Default Title", timeZone: []));
    }
  }

  @override
  Future<void> onInit() async {
    fetchIntercityService();
    getZoneList();
    super.onInit();
  }

  Future<void> getZoneList() async {
    await FireStoreUtils.getActiveZones().then(
      (value) {
        if (value != null) {
          zoneList.clear();
          for (var element in value) {
            element.charges ??= Charges();

            // attach controllers once
            element.minDistanceController = TextEditingController(text: element.charges?.fareMinimumChargesWithinKm ?? '');
            element.minFareController = TextEditingController(text: element.charges?.farMinimumCharges ?? '');
            element.perKmController = TextEditingController(text: element.charges?.farePerKm ?? '');
            if (selectedDocId.value != "parcel") {
              element.holdChargeController = TextEditingController(text: element.charges?.holdCharge ?? '');
              element.nightChargeController = TextEditingController(text: element.charges?.incrementOfNightCharge ?? '');
            }

            zoneList.add(element);
          }
        }
      },
    );
  }

  Future<void> fetchIntercityService() async {
    isLoading.value = true;
    try {
      intercityDocuments.clear();

      List<String> docNames = ["parcel", "intercity_sharing", "intercity", "rental", "cab"];

      for (String docName in docNames) {
        DocumentSnapshot doc = await fireStore.collection("intercity_service").doc(docName).get();

        if (doc.exists) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          intercityDocuments.add(IntercityDocumentModel.fromJson(docName, data));
        }
      }
    } catch (e) {
      log("Error fetching intercity services: $e");
    }
    isLoading.value = false;
  }

  void loadZoneCharge(IntercityDocumentModel doc) {
    selectedDocId.value = doc.id;
    zoneList.value = zoneList.map((element) {
      // Check if the zone already has charges; if not, create an empty Charges object
      ZoneChargesModel? match = doc.zoneCharges.firstWhere(
        (zc) => zc.zoneId == element.id,
        orElse: () => ZoneChargesModel(
          zoneId: element.id,
          zoneName: element.name,
          charges: Charges(), // Default empty Charges if not found
        ),
      );

      // Only update the charges if the charges were not found or need to be updated
      if (element.charges == null || element.charges != match.charges) {
        element.charges = Charges(
          fareMinimumChargesWithinKm: match.charges?.fareMinimumChargesWithinKm ?? '',
          farMinimumCharges: match.charges?.farMinimumCharges ?? '',
          farePerKm: match.charges?.farePerKm ?? '',
          holdCharge: doc.id != "parcel" ? match.charges?.holdCharge ?? '' : '',
          incrementOfNightCharge: doc.id != "parcel" ? match.charges?.incrementOfNightCharge ?? '' : '',
        );
      }

      element.minDistanceController ??= TextEditingController();
      element.minDistanceController!.text = element.charges?.fareMinimumChargesWithinKm ?? '';

      element.minFareController ??= TextEditingController();
      element.minFareController!.text = element.charges?.farMinimumCharges ?? '';

      element.perKmController ??= TextEditingController();
      element.perKmController!.text = element.charges?.farePerKm ?? '';

      if (doc.id != "parcel") {
        element.holdChargeController ??= TextEditingController();
        element.holdChargeController!.text = element.charges?.holdCharge ?? '';

        element.nightChargeController ??= TextEditingController();
        element.nightChargeController!.text = element.charges?.incrementOfNightCharge ?? '';
      }

      return element;
    }).toList();
  }

  Future<void> saveToFirestore() async {
    try {
      List<Map<String, dynamic>> zoneChargesList = zoneList.map((zone) {
        return {
          "zoneId": zone.id,
          "zoneName": zone.name,
          "charges": {
            "fareMinimumChargesWithinKm": zone.charges?.fareMinimumChargesWithinKm ?? '',
            "farMinimumCharges": zone.charges?.farMinimumCharges ?? '',
            "farePerKm": zone.charges?.farePerKm ?? '',
            "holdCharge": selectedDocId.value != "parcel" ? zone.charges?.holdCharge ?? '' : '',
            "minuteCharge": selectedDocId.value != "parcel" ? zone.charges?.minuteCharge ?? '' : '',
            "incrementOfNightCharge": zone.charges?.incrementOfNightCharge ?? '',
          }
        };
      }).toList();

      await FirebaseFirestore.instance.collection("intercity_service").doc(selectedDocId.value).update({"zoneCharges": zoneChargesList});

      Get.back();
      fetchIntercityService();
    } catch (e) {
      log("Error saving data: $e");
    }
  }
}

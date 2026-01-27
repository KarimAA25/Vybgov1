import 'package:customer/app/models/driver_user_model.dart';
import 'package:customer/app/models/emergency_number_model.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/theme/app_them_data.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../controllers/sos_request_controller.dart';

class SosRequestView extends GetView<SosRequestController> {
  const SosRequestView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<SosRequestController>(
      init: SosRequestController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: themeChange.isDarkTheme() ? AppThemData.black : AppThemData.white,
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: controller.isLoading.value
                ? Constant.loader()
                : controller.sosList.isEmpty
                    ? Constant.showEmptyView(message: "No SOS Requests".tr)
                    : ListView.builder(
                        itemCount: controller.sosList.length,
                        itemBuilder: (context, index) {
                          final sos = controller.sosList[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: themeChange.isDarkTheme() ? AppThemData.grey900 : AppThemData.grey50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      DateFormat("d MMM, yyyy hh:mm a").format(sos.createdAt!.toDate()),
                                    ),
                                    const Spacer(),
                                    Text(
                                      sos.status!.toUpperCase(),
                                      style: TextStyle(
                                        color: controller.getStatusColor(sos.status!),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                FutureBuilder(
                                  future: FireStoreUtils.getDriverUserProfile(sos.driverId.toString()),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return Container();
                                    }
                                    if (!snapshot.hasData) {
                                      return Container();
                                    }
                                    DriverUserModel? driver = snapshot.data ?? DriverUserModel();
                                    return Row(
                                      children: [
                                        Text(
                                          "Driver Name : ",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(driver.fullName!.isEmpty ? "N/A" : driver.fullName.toString()),
                                      ],
                                    );
                                  },
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Text(
                                      "Emergency Type : ",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(sos.emergencyType == "contacts" ? "Emergency Contacts".tr : "Call ${Constant.sosAlertNumber}"),
                                  ],
                                ),
                                const Divider(),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (sos.contactIds != null && sos.contactIds!.isNotEmpty) ...[
                                      const Text(
                                        "Emergency Contacts : ",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: sos.contactIds!
                                            .map(
                                              (contactId) => FutureBuilder<EmergencyContactModel?>(
                                                future: FireStoreUtils.getEmergencyContactById(
                                                  ownerId: sos.type == "customer" ? sos.userId! : sos.driverId!,
                                                  contactId: contactId,
                                                  ownerType: sos.type!,
                                                ),
                                                builder: (context, snapshot) {
                                                  if (!snapshot.hasData) return const SizedBox();
                                                  final contact = snapshot.data!;
                                                  return Padding(
                                                    padding: const EdgeInsets.symmetric(vertical: 2),
                                                    child: Text(
                                                      "${contact.name} (${contact.countryCode} ${contact.phoneNumber})",
                                                      style: const TextStyle(fontSize: 15),
                                                    ),
                                                  );
                                                },
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        );
      },
    );
  }
}

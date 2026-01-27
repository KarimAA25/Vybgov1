import 'package:driver/app/models/emergency_number_model.dart';
import 'package:driver/app/models/user_model.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/theme/app_them_data.dart';
import 'package:driver/utils/dark_theme_provider.dart';
import 'package:driver/utils/fire_store_utils.dart';
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
                                    Spacer(),
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
                                  future: FireStoreUtils.getUserProfile(sos.userId.toString()),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return Container();
                                    }
                                    if (!snapshot.hasData) {
                                      return Container();
                                    }
                                    UserModel? user = snapshot.data ?? UserModel();
                                    return Row(
                                      children: [
                                        Text(
                                          "Customer Name : ",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(user.fullName!.isEmpty ? "N/A" : user.fullName.toString()),
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

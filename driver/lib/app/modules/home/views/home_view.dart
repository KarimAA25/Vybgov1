import 'package:driver/app/modules/cab_rides/views/cab_rides_view.dart';
import 'package:driver/app/modules/emergency_contacts/views/emergency_contacts_view.dart';
import 'package:driver/app/modules/home/views/widgets/drawer_view.dart';
import 'package:driver/app/modules/html_view_screen/views/html_view_screen_view.dart';
import 'package:driver/app/modules/inbox_screen/views/inbox_screen_view.dart';
import 'package:driver/app/modules/intercity_rides/views/intercity_rides_view.dart';
import 'package:driver/app/modules/language/views/language_view.dart';
import 'package:driver/app/modules/my_bank/views/my_bank_view.dart';
import 'package:driver/app/modules/my_wallet/views/my_wallet_view.dart';
import 'package:driver/app/modules/notifications/views/notifications_view.dart';
import 'package:driver/app/modules/parcel_rides/views/parcel_rides_view.dart';
import 'package:driver/app/modules/referral_screen/views/referral_screen_view.dart';
import 'package:driver/app/modules/rental_rides/views/rental_rides_view.dart';
import 'package:driver/app/modules/statement_screen/views/statement_view.dart';
import 'package:driver/app/modules/support_screen/views/support_screen_view.dart';
import 'package:driver/app/modules/update_vehicle_details/views/update_vehicle_details_view.dart';
import 'package:driver/app/modules/verify_documents/views/verify_documents_view.dart';
import 'package:driver/app/modules/your_subscription/views/your_subscription_view.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/theme/app_them_data.dart';
import 'package:driver/theme/responsive.dart';
import 'package:driver/utils/dark_theme_provider.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../sos_request/views/sos_request_view.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return GetBuilder<HomeController>(
        init: HomeController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: themeChange.isDarkTheme() ? AppThemData.black : AppThemData.grey25,
            appBar: AppBar(
              shape: Border(bottom: BorderSide(color: themeChange.isDarkTheme() ? AppThemData.grey800 : AppThemData.grey100, width: 1)),
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset("assets/icon/logo_only.svg"),
                  const SizedBox(width: 10),
                  Text(
                    "MyTaxi".tr,
                    style: GoogleFonts.inter(
                      color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              centerTitle: true,
              actions: [
                IconButton(
                    onPressed: () {
                      Get.to(() => const NotificationsView());
                    },
                    icon: const Icon(Icons.notifications_none_rounded))
              ],
            ),
            drawer: const DrawerView(),
            body: Obx(
              () => controller.isLoading.value
                  ? Constant.loader()
                  : controller.drawerIndex.value == 1
                      ? CabRidesView()
                      : controller.drawerIndex.value == 2
                          ? const InterCityRidesView()
                          : controller.drawerIndex.value == 3
                              ? const ParcelRidesView()
                              : controller.drawerIndex.value == 4
                                  ? const MyWalletView()
                                  : controller.drawerIndex.value == 5
                                      ? const YourSubscriptionView()
                                      : controller.drawerIndex.value == 6
                                          ? const MyBankView()
                                          : controller.drawerIndex.value == 7
                                              ? const VerifyDocumentsView(
                                                  isFromDrawer: true,
                                                )
                                              : controller.drawerIndex.value == 8
                                                  ? const SupportScreenView()
                                                  : controller.drawerIndex.value == 9
                                                      ? const StatementView()
                                                      : controller.drawerIndex.value == 10
                                                          ? HtmlViewScreenView(title: "Privacy & Policy".tr, htmlData: Constant.privacyPolicy)
                                                          : controller.drawerIndex.value == 11
                                                              ? HtmlViewScreenView(title: "Terms & Condition".tr, htmlData: Constant.termsAndConditions)
                                                              : controller.drawerIndex.value == 12
                                                                  ? const LanguageView()
                                                                  : controller.drawerIndex.value == 13
                                                                      ? const RentalRidesView()
                                                                      : controller.drawerIndex.value == 14
                                                                          ? const UpdateVehicleDetailsView(isUploaded: true)
                                                                          : controller.drawerIndex.value == 15
                                                                              ? const ReferralScreenView()
                                                                              : controller.drawerIndex.value == 16
                                                                                  ? const InboxScreenView()
                                                                                  : controller.drawerIndex.value == 17
                                                                                      ? const EmergencyContactsView(isFromDrawer: true,)
                                                                                      : controller.drawerIndex.value == 18
                                                                                          ? const SosRequestView()
                                                                                          : Padding(
                                                                                              padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
                                                                                              child: Column(
                                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                                                children: [
                                                                                                  const SizedBox(height: 8),
                                                                                                  controller.userModel.value.isVerified == false
                                                                                                      ? Padding(
                                                                                                          padding: const EdgeInsets.all(8.0),
                                                                                                          child: goOnlineDialog(
                                                                                                            context: context,
                                                                                                            title: "Document Verification Required".tr,
                                                                                                            descriptions:
                                                                                                                "Your account is not verified yet. Please upload and verify your documents to continue."
                                                                                                                    .tr,
                                                                                                            img: SvgPicture.asset(
                                                                                                              "assets/icon/ic_document_drawer.svg",
                                                                                                              height: 58,
                                                                                                              width: 58,
                                                                                                              colorFilter: ColorFilter.mode(AppThemData.grey500, BlendMode.srcIn),
                                                                                                            ),
                                                                                                            onClick: () {
                                                                                                              Get.to(() => VerifyDocumentsView(isFromDrawer: false));
                                                                                                            },
                                                                                                            string: "Verify".tr,
                                                                                                            themeChange: themeChange,
                                                                                                          ),
                                                                                                        )
                                                                                                      : controller.userModel.value.driverVehicleDetails == null ||
                                                                                                              controller
                                                                                                                  .userModel.value.driverVehicleDetails!.vehicleTypeId!.isEmpty
                                                                                                          ? Padding(
                                                                                                              padding: const EdgeInsets.all(8.0),
                                                                                                              child: goOnlineDialog(
                                                                                                                context: context,
                                                                                                                title: "Vehicle Details Required".tr,
                                                                                                                descriptions:
                                                                                                                    "Your vehicle details are not added or verified yet. Please provide and verify your vehicle information to continue."
                                                                                                                        .tr,
                                                                                                                img: SvgPicture.asset(
                                                                                                                  "assets/icon/my_ride.svg",
                                                                                                                  colorFilter:
                                                                                                                      ColorFilter.mode(AppThemData.grey500, BlendMode.srcIn),
                                                                                                                  height: 48,
                                                                                                                  width: 48,
                                                                                                                ),
                                                                                                                onClick: () {
                                                                                                                  Get.to(() => UpdateVehicleDetailsView(
                                                                                                                            isUploaded: false,
                                                                                                                          ))!
                                                                                                                      .then(
                                                                                                                    (value) {
                                                                                                                      if (value == true) {
                                                                                                                        controller.getData();
                                                                                                                      }
                                                                                                                    },
                                                                                                                  );
                                                                                                                },
                                                                                                                string: "Add Vehicle".tr,
                                                                                                                themeChange: themeChange,
                                                                                                              ),
                                                                                                            )
                                                                                                          : controller.isOnline.value == false
                                                                                                              ? Column(
                                                                                                                  children: [
                                                                                                                    Padding(
                                                                                                                      padding: const EdgeInsets.all(8.0),
                                                                                                                      child: goOnlineDialog(
                                                                                                                        context: context,
                                                                                                                        title: "You're Now Offline".tr,
                                                                                                                        descriptions:
                                                                                                                            "Please change your status to online to access all features. When offline, you won't be able to access any functionalities."
                                                                                                                                .tr,
                                                                                                                        img: SvgPicture.asset(
                                                                                                                          "assets/icon/ic_offline.svg",
                                                                                                                          height: 58,
                                                                                                                          width: 58,
                                                                                                                        ),
                                                                                                                        onClick: () async {
                                                                                                                          await FireStoreUtils.updateDriverUserOnline(true);
                                                                                                                          controller.tabInitate();
                                                                                                                          controller.isOnline.value = true;
                                                                                                                        },
                                                                                                                        string: "Go Online".tr,
                                                                                                                        themeChange: themeChange,
                                                                                                                      ),
                                                                                                                    ),
                                                                                                                    const SizedBox(height: 20),
                                                                                                                  ],
                                                                                                                )
                                                                                                              : Expanded(
                                                                                                                  child: DefaultTabController(
                                                                                                                    length: controller.rideTabs.length,
                                                                                                                    child: Column(
                                                                                                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                                                                                                      children: [
                                                                                                                        Container(
                                                                                                                          margin: const EdgeInsets.symmetric(horizontal: 16),
                                                                                                                          padding: const EdgeInsets.all(6),
                                                                                                                          decoration: BoxDecoration(
                                                                                                                            color: themeChange.isDarkTheme()
                                                                                                                                ? AppThemData.primary900
                                                                                                                                : AppThemData.primary50,
                                                                                                                            borderRadius: BorderRadius.circular(50),
                                                                                                                          ),
                                                                                                                          child: TabBar(
                                                                                                                            controller: controller.tabController,
                                                                                                                            isScrollable: false,
                                                                                                                            // tabAlignment: TabAlignment.start,
                                                                                                                            labelStyle: GoogleFonts.inter(
                                                                                                                              fontSize: 16,
                                                                                                                              fontWeight: FontWeight.w600,
                                                                                                                              color: AppThemData.black,
                                                                                                                            ),
                                                                                                                            unselectedLabelStyle: GoogleFonts.inter(
                                                                                                                              fontSize: 14,
                                                                                                                              fontWeight: FontWeight.w500,
                                                                                                                              color: themeChange.isDarkTheme()
                                                                                                                                  ? AppThemData.grey200
                                                                                                                                  : AppThemData.grey800,
                                                                                                                            ),
                                                                                                                            dividerColor: Colors.transparent,
                                                                                                                            indicator: BoxDecoration(
                                                                                                                              color: AppThemData.primary500,
                                                                                                                              borderRadius: BorderRadius.circular(50),
                                                                                                                            ),
                                                                                                                            indicatorSize: TabBarIndicatorSize.tab,
                                                                                                                            indicatorColor: AppThemData.primary300,
                                                                                                                            labelPadding: EdgeInsets.zero,
                                                                                                                            indicatorPadding: EdgeInsets.zero,
                                                                                                                            tabs: controller.rideTabs
                                                                                                                                .map((tab) => Tab(
                                                                                                                                      child: Text(
                                                                                                                                        tab['title'].toString().tr,
                                                                                                                                      ),
                                                                                                                                    ))
                                                                                                                                .toList(),
                                                                                                                          ),
                                                                                                                        ),
                                                                                                                        const SizedBox(height: 12),
                                                                                                                        Expanded(
                                                                                                                          child: TabBarView(
                                                                                                                            controller: controller.tabController,
                                                                                                                            children: controller.rideTabs
                                                                                                                                .map((tab) => tab['widget'] as Widget)
                                                                                                                                .toList(),
                                                                                                                          ),
                                                                                                                        ),
                                                                                                                      ],
                                                                                                                    ),
                                                                                                                  ),
                                                                                                                ),
                                                                                                ],
                                                                                              ),
                                                                                            ),
            ),
          );
        });
  }
}

Container goOnlineDialog({
  required BuildContext context,
  required String title,
  required descriptions,
  required string,
  required Widget img,
  required Function() onClick,
  required DarkThemeProvider themeChange,
  Color? buttonColor,
  Color? buttonTextColor,
}) {
  return Container(
    padding: const EdgeInsets.only(left: 20, top: 20, right: 20, bottom: 20),
    decoration: BoxDecoration(shape: BoxShape.rectangle, color: themeChange.isDarkTheme() ? Colors.black : Colors.white, borderRadius: BorderRadius.circular(20)),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        img,
        const SizedBox(
          height: 20,
        ),
        Visibility(
          visible: title.isNotEmpty,
          child: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
            ),
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        Visibility(
          visible: descriptions.isNotEmpty,
          child: Text(
            descriptions,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  onClick();
                },
                child: Container(
                  width: Responsive.width(100, context),
                  height: 45,
                  decoration: ShapeDecoration(
                    color: buttonColor ?? AppThemData.primary500,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(200),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        string.toString(),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          color: buttonTextColor ?? AppThemData.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        )
      ],
    ),
  );
}

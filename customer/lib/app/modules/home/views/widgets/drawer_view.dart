// ignore_for_file: use_build_context_synchronously, depend_on_referenced_packages, deprecated_member_use

import 'dart:developer';
import 'dart:io';

import 'package:customer/app/modules/edit_profile/views/edit_profile_view.dart';
import 'package:customer/app/modules/home/controllers/home_controller.dart';
import 'package:customer/app/modules/login/views/login_view.dart';
import 'package:customer/app/routes/app_pages.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant_widgets/custom_dialog_box.dart';
import 'package:customer/constant_widgets/show_toast_dialog.dart';
import 'package:customer/theme/app_them_data.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class DrawerView extends StatelessWidget {
  const DrawerView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetBuilder(
        init: HomeController(),
        builder: (controller) {
          return Drawer(
            child: Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 50),
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: <Widget>[
                        Container(
                          color: AppThemData.primary500,
                          padding: const EdgeInsets.only(bottom: 30, left: 16, right: 24),
                          child: Padding(
                            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                            child: InkWell(
                              onTap: () async {
                                Get.back();
                                bool? isSave = await Get.to(const EditProfileView());
                                if ((isSave ?? false)) {
                                  log("===> ");
                                  controller.getUserData();
                                  log("=====> ");
                                }
                              },
                              child: Obx(
                                () => Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 60,
                                      margin: const EdgeInsets.only(right: 10),
                                      clipBehavior: Clip.antiAlias,
                                      decoration: ShapeDecoration(
                                        color: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(200),
                                        ),
                                        image: DecorationImage(
                                          image: NetworkImage(controller.profilePic.value),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            controller.name.value,
                                            style: GoogleFonts.inter(
                                              color: AppThemData.black,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            controller.phoneNumber.value,
                                            style: GoogleFonts.inter(
                                              color: AppThemData.black,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SvgPicture.asset("assets/icon/ic_drawer_edit.svg")
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            "Services".tr,
                            style: GoogleFonts.inter(fontSize: 16, color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black, fontWeight: FontWeight.w600),
                          ),
                        ),
                        ListTile(
                          leading: SvgPicture.asset(
                            "assets/icon/ic_my_rides.svg",
                            colorFilter: ColorFilter.mode(
                              controller.drawerIndex.value == 0 ? AppThemData.primary500 : (themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black),
                              BlendMode.srcIn,
                            ),
                          ),
                          trailing: Icon(
                            Icons.keyboard_arrow_right_rounded,
                            size: 30,
                            color: controller.drawerIndex.value == 0 ? AppThemData.primary500 : (themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black),
                          ),
                          title: Text(
                            "Home".tr,
                            style: GoogleFonts.inter(
                                fontSize: 16,
                                color: controller.drawerIndex.value == 0 ? AppThemData.primary500 : (themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black),
                                fontWeight: FontWeight.w400),
                          ),
                          onTap: () {
                            Get.back();
                            controller.drawerIndex.value = 0;
                          },
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 50),
                          child: Divider(),
                        ),
                        ExpansionTileItem(
                          title: "My Rides".tr,
                          titleColor:
                              (controller.drawerIndex.value == 1 || controller.drawerIndex.value == 7 || controller.drawerIndex.value == 8 || controller.drawerIndex.value == 10)
                                  ? AppThemData.warning06
                                  : themeChange.isDarkTheme()
                                      ? AppThemData.white
                                      : AppThemData.black,
                          icon: SvgPicture.asset(
                            "assets/icon/my_ride.svg",
                            width: 20,
                            height: 17,
                            color:
                                (controller.drawerIndex.value == 1 || controller.drawerIndex.value == 7 || controller.drawerIndex.value == 8 || controller.drawerIndex.value == 10)
                                    ? AppThemData.warning06
                                    : themeChange.isDarkTheme()
                                        ? AppThemData.white
                                        : AppThemData.black,
                          ),
                          iconColor:
                              (controller.drawerIndex.value == 1 || controller.drawerIndex.value == 2 || controller.drawerIndex.value == 3 || controller.drawerIndex.value == 13)
                                  ? AppThemData.warning06
                                  : AppThemData.black,
                          children: [
                            if (Constant.isCabAvailable)
                              ListTile(
                                title: Text(
                                  "Cab Rides".tr,
                                  style: GoogleFonts.inter(
                                      fontSize: 16,
                                      color: controller.drawerIndex.value == 1
                                          ? AppThemData.warning06
                                          : themeChange.isDarkTheme()
                                              ? AppThemData.white
                                              : themeChange.isDarkTheme()
                                                  ? AppThemData.white
                                                  : AppThemData.black,
                                      fontWeight: FontWeight.w400),
                                ),
                                onTap: () {
                                  Get.back();
                                  controller.drawerIndex.value = 1;
                                },
                              ),
                            if ((controller.intercityPersonalDocuments.isNotEmpty && controller.intercityPersonalDocuments.first.isAvailable) ||
                                (controller.intercitySharingDocuments.isNotEmpty && controller.intercitySharingDocuments.first.isAvailable))
                              ListTile(
                                title: Text(
                                  "Intercity Rides".tr,
                                  style: GoogleFonts.inter(
                                      fontSize: 16,
                                      color: controller.drawerIndex.value == 7
                                          ? AppThemData.warning06
                                          : themeChange.isDarkTheme()
                                              ? AppThemData.white
                                              : themeChange.isDarkTheme()
                                                  ? AppThemData.white
                                                  : AppThemData.black,
                                      fontWeight: FontWeight.w400),
                                ),
                                onTap: () {
                                  Get.back();
                                  controller.drawerIndex.value = 7;
                                },
                              ),
                            if (controller.parcelDocuments.isNotEmpty && controller.parcelDocuments.first.isAvailable)
                              ListTile(
                                title: Text(
                                  "Parcel Rides".tr,
                                  style: GoogleFonts.inter(
                                      fontSize: 16,
                                      color: controller.drawerIndex.value == 8
                                          ? AppThemData.warning06
                                          : themeChange.isDarkTheme()
                                              ? AppThemData.white
                                              : themeChange.isDarkTheme()
                                                  ? AppThemData.white
                                                  : AppThemData.black,
                                      fontWeight: FontWeight.w400),
                                ),
                                onTap: () {
                                  Get.back();
                                  controller.drawerIndex.value = 8;
                                },
                              ),
                            if (Constant.isRentalAvailable == true)
                              ListTile(
                                title: Text(
                                  "Rental Rides".tr,
                                  style: GoogleFonts.inter(
                                      fontSize: 16,
                                      color: controller.drawerIndex.value == 10
                                          ? AppThemData.warning06
                                          : themeChange.isDarkTheme()
                                              ? AppThemData.white
                                              : themeChange.isDarkTheme()
                                                  ? AppThemData.white
                                                  : AppThemData.black,
                                      fontWeight: FontWeight.w400),
                                ),
                                onTap: () {
                                  Get.back();
                                  controller.drawerIndex.value = 10;
                                },
                              ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 50),
                          child: Divider(),
                        ),
                        ListTile(
                          leading: SvgPicture.asset(
                            "assets/icon/ic_emergency.svg",
                            colorFilter: ColorFilter.mode(
                              controller.drawerIndex.value == 14 ? AppThemData.primary500 : (themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black),
                              BlendMode.srcIn,
                            ),
                          ),
                          trailing: Icon(
                            Icons.keyboard_arrow_right_rounded,
                            size: 30,
                            color: controller.drawerIndex.value == 14 ? AppThemData.primary500 : (themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black),
                          ),
                          title: Text(
                            "Emergency Contacts".tr,
                            style: GoogleFonts.inter(
                                fontSize: 16,
                                color: controller.drawerIndex.value == 14 ? AppThemData.primary500 : (themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black),
                                fontWeight: FontWeight.w400),
                          ),
                          onTap: () {
                            Get.back();
                            controller.drawerIndex.value = 14;
                          },
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 50),
                          child: Divider(),
                        ),
                        ListTile(
                          leading: SvgPicture.asset(
                            "assets/icon/ic_emergency.svg",
                            colorFilter: ColorFilter.mode(
                              controller.drawerIndex.value == 15 ? AppThemData.primary500 : (themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black),
                              BlendMode.srcIn,
                            ),
                          ),
                          trailing: Icon(
                            Icons.keyboard_arrow_right_rounded,
                            size: 30,
                            color: controller.drawerIndex.value == 15 ? AppThemData.primary500 : (themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black),
                          ),
                          title: Text(
                            "SOS Request".tr,
                            style: GoogleFonts.inter(
                                fontSize: 16,
                                color: controller.drawerIndex.value == 15 ? AppThemData.primary500 : (themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black),
                                fontWeight: FontWeight.w400),
                          ),
                          onTap: () {
                            Get.back();
                            controller.drawerIndex.value = 15;
                          },
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 50),
                          child: Divider(),
                        ),
                        ListTile(
                          leading: SvgPicture.asset(
                            "assets/icon/ic_refer.svg",
                            colorFilter: ColorFilter.mode(
                              controller.drawerIndex.value == 11 ? AppThemData.primary500 : (themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black),
                              BlendMode.srcIn,
                            ),
                          ),
                          trailing: Icon(
                            Icons.keyboard_arrow_right_rounded,
                            size: 30,
                            color: controller.drawerIndex.value == 11 ? AppThemData.primary500 : (themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black),
                          ),
                          title: Text(
                            "Refer & Earn".tr,
                            style: GoogleFonts.inter(
                                fontSize: 16,
                                color: controller.drawerIndex.value == 11 ? AppThemData.primary500 : (themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black),
                                fontWeight: FontWeight.w400),
                          ),
                          onTap: () {
                            Get.back();
                            controller.drawerIndex.value = 11;
                          },
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 50),
                          child: Divider(),
                        ),
                        ListTile(
                          leading: SvgPicture.asset(
                            "assets/icon/ic_my_wallet.svg",
                            colorFilter: ColorFilter.mode(
                              controller.drawerIndex.value == 2 ? AppThemData.primary500 : (themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black),
                              BlendMode.srcIn,
                            ),
                          ),
                          trailing: Icon(
                            Icons.keyboard_arrow_right_rounded,
                            size: 30,
                            color: controller.drawerIndex.value == 2 ? AppThemData.primary500 : (themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black),
                          ),
                          title: Text(
                            "My Wallet".tr,
                            style: GoogleFonts.inter(
                                fontSize: 16,
                                color: controller.drawerIndex.value == 2 ? AppThemData.primary500 : (themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black),
                                fontWeight: FontWeight.w400),
                          ),
                          onTap: () {
                            Get.back();
                            controller.drawerIndex.value = 2;
                          },
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 50),
                          child: Divider(),
                        ),
                        ListTile(
                          onTap: () async {
                            Get.back();
                            controller.drawerIndex.value = 12;
                          },
                          leading: Icon(
                            Icons.message_rounded,
                            size: 20,
                            color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black,
                          ),
                          trailing: const Icon(Icons.keyboard_arrow_right_rounded, size: 30),
                          title: Text(
                            "Inbox".tr,
                            style: GoogleFonts.inter(fontSize: 16, color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black, fontWeight: FontWeight.w400),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 50),
                          child: Divider(),
                        ),
                        ListTile(
                          leading: SvgPicture.asset(
                            "assets/icon/ic_gift.svg",
                            colorFilter: ColorFilter.mode(
                              controller.drawerIndex.value == 13 ? AppThemData.primary500 : (themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black),
                              BlendMode.srcIn,
                            ),
                          ),
                          trailing: Icon(
                            Icons.keyboard_arrow_right_rounded,
                            size: 30,
                            color: controller.drawerIndex.value == 13 ? AppThemData.primary500 : (themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black),
                          ),
                          title: Text(
                            "Loyalty Points".tr,
                            style: GoogleFonts.inter(
                                fontSize: 16,
                                color: controller.drawerIndex.value == 13 ? AppThemData.primary500 : (themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black),
                                fontWeight: FontWeight.w400),
                          ),
                          onTap: () {
                            Get.back();
                            controller.drawerIndex.value = 13;
                          },
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 50),
                          child: Divider(),
                        ),
                        ListTile(
                          onTap: () async {
                            PackageInfo packageInfo = await PackageInfo.fromPlatform();
                            String packageName = packageInfo.packageName;
                            String appStoreUrl = 'https://apps.apple.com/app/$packageName';
                            String playStoreUrl = 'https://play.google.com/store/apps/details?id=$packageName';
                            if (await canLaunchUrl(Uri.parse(appStoreUrl)) && !Platform.isAndroid) {
                              await launchUrl(Uri.parse(appStoreUrl));
                            } else if (await canLaunchUrl(Uri.parse(playStoreUrl)) && Platform.isAndroid) {
                              await launchUrl(Uri.parse(playStoreUrl));
                            } else {
                              throw 'Could not launch store';
                            }
                          },
                          leading: Icon(
                            Icons.star_border_rounded,
                            color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black,
                          ),
                          trailing: const Icon(Icons.keyboard_arrow_right_rounded, size: 30),
                          title: Text(
                            "Rate Us".tr,
                            style: GoogleFonts.inter(fontSize: 16, color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black, fontWeight: FontWeight.w400),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 50),
                          child: Divider(),
                        ),
                        ListTile(
                          leading: SvgPicture.asset(
                            "assets/icon/ic_support.svg",
                            height: 22,
                            colorFilter: ColorFilter.mode(
                              controller.drawerIndex.value == 3 ? AppThemData.primary500 : (themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black),
                              BlendMode.srcIn,
                            ),
                          ),
                          trailing: Icon(
                            Icons.keyboard_arrow_right_rounded,
                            size: 30,
                            color: controller.drawerIndex.value == 3 ? AppThemData.primary500 : (themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black),
                          ),
                          title: Text(
                            "Support".tr,
                            style: GoogleFonts.inter(
                                fontSize: 16,
                                color: controller.drawerIndex.value == 3 ? AppThemData.primary500 : (themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black),
                                fontWeight: FontWeight.w400),
                          ),
                          onTap: () {
                            Get.back();
                            controller.drawerIndex.value = 3;
                          },
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 50),
                          child: Divider(),
                        ),
                        ListTile(
                          onTap: () async {
                            Get.back();
                            controller.drawerIndex.value = 9;
                          },
                          leading: SvgPicture.asset(
                            "assets/icon/ic_downlod.svg",
                            colorFilter: ColorFilter.mode(
                              controller.drawerIndex.value == 9 ? AppThemData.primary500 : (themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black),
                              BlendMode.srcIn,
                            ),
                          ),
                          trailing: Icon(
                            Icons.keyboard_arrow_right_rounded,
                            size: 30,
                            color: controller.drawerIndex.value == 9 ? AppThemData.primary500 : (themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black),
                          ),
                          title: Text(
                            "Ride Statement".tr,
                            style: GoogleFonts.inter(
                                fontSize: 16,
                                color: controller.drawerIndex.value == 9 ? AppThemData.primary500 : (themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black),
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 50),
                          child: Divider(),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            "About".tr,
                            style: GoogleFonts.inter(fontSize: 16, color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black, fontWeight: FontWeight.w600),
                          ),
                        ),
                        ListTile(
                          onTap: () {
                            Get.back();
                            controller.drawerIndex.value = 4;
                          },
                          leading: Icon(
                            Icons.privacy_tip_outlined,
                            color: controller.drawerIndex.value == 4 ? AppThemData.primary500 : (themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black),
                          ),
                          trailing: Icon(
                            Icons.keyboard_arrow_right_rounded,
                            size: 30,
                            color: controller.drawerIndex.value == 4 ? AppThemData.primary500 : (themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black),
                          ),
                          title: Text(
                            "Privacy & Policy".tr,
                            style: GoogleFonts.inter(
                                fontSize: 16,
                                color: controller.drawerIndex.value == 4 ? AppThemData.primary500 : (themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black),
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 50),
                          child: Divider(),
                        ),
                        ListTile(
                          onTap: () {
                            controller.drawerIndex.value = 5;
                            Get.back();
                          },
                          leading: Icon(
                            Icons.contact_support_outlined,
                            color: controller.drawerIndex.value == 5 ? AppThemData.primary500 : (themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black),
                          ),
                          trailing: Icon(
                            Icons.keyboard_arrow_right_rounded,
                            size: 30,
                            color: controller.drawerIndex.value == 5 ? AppThemData.primary500 : (themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black),
                          ),
                          title: Text(
                            "Terms & Condition".tr,
                            style: GoogleFonts.inter(
                                fontSize: 16,
                                color: controller.drawerIndex.value == 5 ? AppThemData.primary500 : (themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black),
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 50),
                          child: Divider(),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            "App Setting".tr,
                            style: GoogleFonts.inter(fontSize: 16, color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black, fontWeight: FontWeight.w600),
                          ),
                        ),
                        ListTile(
                          leading: const Icon(Icons.light_mode_outlined),
                          trailing: Switch(
                            value: !themeChange.isDarkTheme(),
                            activeColor: AppThemData.white,
                            activeTrackColor: AppThemData.success,
                            onChanged: (value) {
                              themeChange.darkTheme = value ? 1 : 0;
                            },
                          ),
                          title: Text(
                            "Light Mode".tr,
                            style: GoogleFonts.inter(fontSize: 16, color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black, fontWeight: FontWeight.w400),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 50),
                          child: Divider(),
                        ),
                        ListTile(
                          leading: SvgPicture.asset(
                            "assets/icon/ic_language.svg",
                            colorFilter: ColorFilter.mode(
                              controller.drawerIndex.value == 6 ? AppThemData.primary500 : (themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black),
                              BlendMode.srcIn,
                            ),
                          ),
                          trailing: const Icon(Icons.keyboard_arrow_right_rounded, size: 30),
                          title: Text(
                            "Language".tr,
                            style: GoogleFonts.inter(
                                fontSize: 16,
                                color: controller.drawerIndex.value == 6 ? AppThemData.primary500 : (themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black),
                                fontWeight: FontWeight.w400),
                          ),
                          onTap: () {
                            Get.back();
                            controller.drawerIndex.value = 6;
                          },
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 50),
                          child: Divider(),
                        ),
                        ListTile(
                          onTap: () {
                            Get.back();
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return CustomDialogBox(
                                      themeChange: themeChange,
                                      title: "Delete Account".tr,
                                      descriptions: "Your account will be deleted permanently. Your Data will not be Restored Again".tr,
                                      positiveString: "Delete".tr,
                                      negativeString: "Cancel".tr,
                                      positiveClick: () async {
                                        ShowToastDialog.showLoader("Please wait..".tr);
                                        controller.deleteUserAccount().then((value) async {
                                          await FirebaseAuth.instance.signOut();
                                          Get.offAllNamed(Routes.LOGIN);
                                          ShowToastDialog.closeLoader();
                                          Navigator.pop(context);
                                          ShowToastDialog.showToast("Account Deleted Successfully..".tr);
                                        });
                                      },
                                      negativeClick: () {
                                        Navigator.pop(context);
                                      },
                                      img: SvgPicture.asset(
                                        "assets/icon/ic_delete.svg",
                                        height: 40,
                                      ));
                                });
                          },
                          leading: SvgPicture.asset(
                            "assets/icon/ic_delete.svg",
                          ),
                          title: Text(
                            "Delete Account".tr,
                            style: GoogleFonts.inter(fontSize: 16, color: AppThemData.error07, fontWeight: FontWeight.w400),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 50),
                          child: Divider(),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: ListTile(
                      onTap: () {
                        Get.back();
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return CustomDialogBox(
                                themeChange: themeChange,
                                title: "Logout".tr,
                                descriptions: "Are you sure you want to logout?".tr,
                                positiveString: "Log out".tr,
                                negativeString: "Cancel".tr,
                                positiveClick: () async {
                                  await FirebaseAuth.instance.signOut();
                                  Navigator.pop(context);
                                  Get.offAll(const LoginView());
                                },
                                negativeClick: () {
                                  Navigator.pop(context);
                                },
                                img: const Icon(
                                  Icons.logout,
                                  color: Colors.red,
                                  size: 40,
                                ),
                              );
                            });
                      },
                      leading: const Icon(
                        Icons.logout,
                        color: AppThemData.error07,
                      ),
                      title: Text(
                        "Logout".tr,
                        style: GoogleFonts.inter(fontSize: 16, color: AppThemData.error07, fontWeight: FontWeight.w400),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}

class ExpansionTileItem extends StatelessWidget {
  final Color? titleColor;
  final Color? iconColor;
  final Color? buttonColor;
  final String? title;
  final Widget? icon;
  final List<Widget>? children;

  const ExpansionTileItem({
    super.key,
    this.titleColor,
    this.iconColor,
    this.title,
    this.icon,
    this.children,
    this.buttonColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: buttonColor,
      ),
      child: ListTileTheme(
        minLeadingWidth: 20,
        child: ExpansionTile(
          shape: const Border(),
          title: Text(
            title!,
            style: GoogleFonts.inter(fontSize: 16, color: titleColor, fontWeight: FontWeight.w400),
          ),
          initiallyExpanded: false,
          childrenPadding: const EdgeInsets.only(left: 70, top: 0, bottom: 0, right: 0),
          backgroundColor: Colors.transparent,
          iconColor: AppThemData.grey300,
          leading: icon,
          children: children!.toList(),
        ),
      ),
    );
  }
}

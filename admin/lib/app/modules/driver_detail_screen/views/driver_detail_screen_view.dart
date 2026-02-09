// ignore_for_file: depend_on_referenced_packages

import 'package:admin/app/components/custom_button.dart';
import 'package:admin/app/components/custom_text_form_field.dart';
import 'package:admin/app/components/menu_widget.dart';
import 'package:admin/app/modules/driver_detail_screen/views/other_screen/driver_booking_widget.dart';
import 'package:admin/app/modules/driver_detail_screen/views/other_screen/driver_information_widget.dart';
import 'package:admin/app/modules/driver_detail_screen/views/other_screen/driver_subscription_history_widget.dart';
import 'package:admin/app/modules/driver_detail_screen/views/other_screen/driver_wallet_transaction_widget.dart';
import 'package:admin/app/routes/app_pages.dart';
import 'package:admin/app/utils/app_colors.dart';
import 'package:admin/app/utils/app_them_data.dart';
import 'package:admin/app/utils/dark_theme_provider.dart';
import 'package:admin/app/utils/responsive.dart';
import 'package:admin/widget/common_ui.dart';
import 'package:admin/widget/global_widgets.dart';
import 'package:admin/widget/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';

import '../controllers/driver_detail_screen_controller.dart';

class DriverDetailScreenView extends StatelessWidget {
  const DriverDetailScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<DriverDetailScreenController>(
      init: DriverDetailScreenController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: themeChange.isDarkTheme() ? AppThemData.greyShade950 : AppThemData.greyShade50,
          appBar: AppBar(
            elevation: 0.0,
            toolbarHeight: 70,
            automaticallyImplyLeading: false,
            backgroundColor: themeChange.isDarkTheme() ? AppThemData.primaryBlack : AppThemData.primaryWhite,
            leadingWidth: 200,
            // title: title,
            leading: Builder(
              builder: (BuildContext context) {
                return GestureDetector(
                  onTap: () {
                    if (!ResponsiveWidget.isDesktop(context)) {
                      Scaffold.of(context).openDrawer();
                    }
                  },
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: !ResponsiveWidget.isDesktop(context)
                        ? Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Icon(
                              Icons.menu,
                              size: 30,
                              color: themeChange.isDarkTheme() ? AppThemData.primary500 : AppThemData.primary500,
                            ),
                          )
                        : SizedBox(
                            height: 45,
                            child: InkWell(
                              onTap: () {
                                Get.toNamed(Routes.DASHBOARD_SCREEN);
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "assets/image/logo.png",
                                    height: 45,
                                    color: AppThemData.primary500,
                                  ),
                                  spaceW(),
                                  const TextCustom(
                                    title: 'My Taxi',
                                    color: AppThemData.primary500,
                                    fontSize: 30,
                                    fontFamily: AppThemeData.semiBold,
                                    fontWeight: FontWeight.w700,
                                  )
                                ],
                              ),
                            ),
                          ),
                  ),
                );
              },
            ),
            actions: [
              GestureDetector(
                onTap: () {
                  if (themeChange.darkTheme == 1) {
                    themeChange.darkTheme = 0;
                  } else if (themeChange.darkTheme == 0) {
                    themeChange.darkTheme = 1;
                  } else if (themeChange.darkTheme == 2) {
                    themeChange.darkTheme = 0;
                  } else {
                    themeChange.darkTheme = 2;
                  }
                },
                child: themeChange.isDarkTheme()
                    ? SvgPicture.asset(
                        "assets/icons/ic_sun.svg",
                        color: AppThemData.yellow600,
                        height: 20,
                        width: 20,
                      )
                    : SvgPicture.asset(
                        "assets/icons/ic_moon.svg",
                        color: AppThemData.blue400,
                        height: 20,
                        width: 20,
                      ),
              ),
              spaceW(),
              const LanguagePopUp(),
              spaceW(),
              ProfilePopUp()
            ],
          ),
          drawer: Drawer(
            width: 270,
            backgroundColor: themeChange.isDarkTheme() ? AppThemData.primaryBlack : AppThemData.primaryWhite,
            child: const MenuWidget(),
          ),
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (ResponsiveWidget.isDesktop(context)) ...{const MenuWidget()},
              Expanded(
                child: Padding(
                    padding: paddingEdgeInsets(),
                    child: DefaultTabController(
                        length: 4,
                        child: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Container(
                            padding: const EdgeInsets.fromLTRB(18, 16, 16, 0),
                            decoration: BoxDecoration(
                                color: themeChange.isDarkTheme() ? AppThemData.primaryBlack : AppThemData.primaryWhite,
                                borderRadius: const BorderRadius.only(topLeft: Radius.circular(10))),
                            child: Column(
                              children: [
                                ResponsiveWidget.isDesktop(context)
                                    ? Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          InkWell(
                                            onTap: () => Get.back(),
                                            child: SvgPicture.asset(
                                              "assets/icons/ic_arrow_back.svg",
                                              height: 20,
                                              width: 20,
                                              colorFilter: ColorFilter.mode(
                                                themeChange.isDarkTheme() ? AppThemData.primaryWhite : AppThemData.primaryBlack,
                                                BlendMode.srcIn,
                                              ),
                                            ),
                                          ),
                                          10.width,
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              TextCustom(title: controller.title.value, fontSize: 20, fontFamily: AppThemeData.bold),
                                              spaceH(height: 4),
                                              Row(
                                                children: [
                                                  InkWell(
                                                    onTap: () => Get.offAllNamed(Routes.DASHBOARD_SCREEN),
                                                    child: TextCustom(title: "Dashboard".tr, fontSize: 14, fontFamily: AppThemeData.medium, color: AppThemData.greyShade500),
                                                  ),
                                                  TextCustom(title: ' / ', fontSize: 14, fontFamily: AppThemeData.medium, color: AppThemData.greyShade500),
                                                  InkWell(
                                                    onTap: () => Get.back(),
                                                    child: TextCustom(title: "Drivers".tr, fontSize: 14, fontFamily: AppThemeData.medium, color: AppThemData.greyShade500),
                                                  ),
                                                  TextCustom(title: ' / ', fontSize: 14, fontFamily: AppThemeData.medium, color: AppThemData.greyShade500),
                                                  TextCustom(title: controller.title.value, fontSize: 14, fontFamily: AppThemeData.medium, color: AppThemData.primary500),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Spacer(),
                                          CustomButtonWidget(
                                            buttonTitle: "+ Add Wallet Amount",
                                            textColor: AppThemData.primaryBlack,
                                            buttonColor: AppThemData.primary500,
                                            onPress: () {
                                              showDialog(context: context, builder: (context) => TopUpDialog());
                                            },
                                          )
                                        ],
                                      )
                                    : Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              InkWell(
                                                onTap: () => Get.back(),
                                                child: SvgPicture.asset(
                                                  "assets/icons/ic_arrow_back.svg",
                                                  height: 20,
                                                  width: 20,
                                                  colorFilter: ColorFilter.mode(
                                                    themeChange.isDarkTheme() ? AppThemData.primaryWhite : AppThemData.primaryBlack,
                                                    BlendMode.srcIn,
                                                  ),
                                                ),
                                              ),
                                              10.width,
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    TextCustom(title: controller.title.value, fontSize: 20, fontFamily: AppThemeData.bold),
                                                    spaceH(height: 2),
                                                    Row(
                                                      children: [
                                                        InkWell(
                                                          onTap: () => Get.offAllNamed(Routes.DASHBOARD_SCREEN),
                                                          child: TextCustom(title: "Dashboard".tr, fontSize: 14, fontFamily: AppThemeData.medium, color: AppThemData.greyShade500),
                                                        ),
                                                        TextCustom(title: ' / ', fontSize: 14, fontFamily: AppThemeData.medium, color: AppThemData.greyShade500),
                                                        InkWell(
                                                          onTap: () => Get.offAllNamed(Routes.DRIVER_SCREEN),
                                                          child: TextCustom(title: "Drivers".tr, fontSize: 14, fontFamily: AppThemeData.medium, color: AppThemData.greyShade500),
                                                        ),
                                                        TextCustom(title: ' / ', fontSize: 14, fontFamily: AppThemeData.medium, color: AppThemData.greyShade500),
                                                        Flexible(
                                                          child: TextCustom(
                                                              title: controller.title.value, fontSize: 14, fontFamily: AppThemeData.medium, color: AppThemData.primary500),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                spaceH(height: 20),
                                TabBar(
                                  indicatorColor: AppThemData.primary500,
                                  unselectedLabelColor: themeChange.isDarkTheme() ? AppThemData.greyShade400 : AppThemData.greyShade500,
                                  labelColor: AppThemData.primary500,
                                  tabs: [
                                    Tab(text: "Driver Information".tr),
                                    Tab(text: "Booking Details".tr),
                                    Tab(text: "Wallet Transaction".tr),
                                    Tab(text: "Subscription History".tr),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          spaceH(height: 16),
                          const Expanded(
                            child: TabBarView(
                              physics: NeverScrollableScrollPhysics(),
                              children: [DriverInformationWidget(), DriverBookingWidget(), DriverWalletTransactionWidget(), DriverSubscriptionHistoryWidget()],
                            ),
                          ),
                        ]))),
              ),
            ],
          ),
        );
      },
    );
  }
}

class TopUpDialog extends StatelessWidget {
  const TopUpDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return GetX<DriverDetailScreenController>(
      init: DriverDetailScreenController(),
      builder: (controller) {
        return CustomDialog(
          title: "Top Up",
          widgetList: [
            SizedBox(
              child: CustomTextFormField(title: "Top up Amount".tr, hintText: "Enter Top up Amount".tr, controller: controller.topupController.value),
            ),
          ],
          bottomWidgetList: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomButtonWidget(
                  buttonTitle: "Close".tr,
                  buttonColor: themeChange.isDarkTheme() ? AppThemData.greyShade900 : AppThemData.greyShade100,
                  onPress: () {
                    controller.topupController.value.text = "";
                    Navigator.pop(context);
                  },
                ),
                spaceW(),
                CustomButtonWidget(
                  buttonTitle: "Top up".tr,
                  onPress: () {
                    // if (Constant.isDemo) {
                    //   DialogBox.demoDialogBox();
                    // } else {
                    controller.completeOrder(DateTime.now().millisecondsSinceEpoch.toString());
                    // }
                  },
                ),
              ],
            ),
          ],
          controller: controller,
        );
      },
    );
  }
}

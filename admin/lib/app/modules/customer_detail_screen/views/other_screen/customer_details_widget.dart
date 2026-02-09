// ignore_for_file: deprecated_member_use

import 'package:admin/app/components/custom_button.dart';
import 'package:admin/app/components/custom_text_form_field.dart';
import 'package:admin/app/constant/constants.dart';
import 'package:admin/app/extension/date_time_extension.dart';
import 'package:admin/app/models/loyalty_point_transaction_model.dart';
import 'package:admin/app/models/wallet_transaction_model.dart';
import 'package:admin/app/modules/customer_detail_screen/controllers/customer_detail_screen_controller.dart';
import 'package:admin/app/utils/app_colors.dart';
import 'package:admin/app/utils/app_them_data.dart';
import 'package:admin/app/utils/dark_theme_provider.dart';
import 'package:admin/app/utils/responsive.dart';
import 'package:admin/widget/container_custom.dart';
import 'package:admin/widget/global_widgets.dart';
import 'package:admin/widget/text_widget.dart';
import 'package:admin/widget/web_pagination.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import '../../../../../widget/common_ui.dart';

class CustomerDetailsWidget extends StatelessWidget {
  const CustomerDetailsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: CustomerDetailScreenController(),
        builder: (controller) {
          return Scaffold(
              backgroundColor: themeChange.isDarkTheme() ? AppThemData.greyShade950 : AppThemData.greyShade50,
              body: ResponsiveWidget(
                mobile: controller.isLoading.value
                    ? Constant.loader()
                    : ContainerCustom(
                        color: themeChange.isDarkTheme() ? AppThemData.primaryBlack : AppThemData.primaryWhite,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: paddingEdgeInsets(horizontal: 20, vertical: 20),
                                    decoration: BoxDecoration(
                                      color: themeChange.isDarkTheme() ? AppThemData.greyShade950 : AppThemData.greyShade50,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextCustom(
                                          title: "User Details".tr,
                                          fontSize: 16,
                                          fontFamily: AppThemeData.bold,
                                        ),
                                        spaceH(height: 16),
                                        rowDataWidget(name: "Name", value: controller.userModel.value.fullName.toString(), themeChange: themeChange),
                                        spaceH(height: 10),
                                        rowDataWidget(
                                            name: "Phone Number",
                                            value: Constant.maskMobileNumber(
                                                mobileNumber: controller.userModel.value.phoneNumber.toString(), countryCode: controller.userModel.value.countryCode.toString()),
                                            themeChange: themeChange),
                                        spaceH(height: 10),
                                        rowDataWidget(name: "Email ", value: Constant.maskEmail(email: controller.userModel.value.email.toString()), themeChange: themeChange),
                                        spaceH(height: 10),
                                        rowDataWidget(name: "Gender", value: controller.userModel.value.gender.toString(), themeChange: themeChange),
                                      ],
                                    ),
                                  ).expand(),
                                ],
                              ),
                              spaceH(height: 20),
                              Row(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
                                    decoration: BoxDecoration(
                                      image: const DecorationImage(image: AssetImage("assets/image/wallet_card.png"), fit: BoxFit.fill),
                                      border: Border.all(color: AppThemData.lightGrey06.withOpacity(.5)),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(shape: BoxShape.circle, color: AppThemData.primaryWhite.withOpacity(.2)),
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: SvgPicture.asset(
                                                  'assets/icons/ic_wallet.svg',
                                                  colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
                                                  height: 30,
                                                  width: 30,
                                                ),
                                              ),
                                            ),
                                            spaceW(width: 14),
                                            Expanded(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  TextCustom(
                                                    title: 'Wallet Amount',
                                                    fontSize: 14,
                                                    color: themeChange.isDarkTheme() ? AppThemData.primaryWhite.withOpacity(.7) : AppThemData.primaryBlack.withOpacity(.7),
                                                    fontFamily: AppThemeData.medium,
                                                  ),
                                                  spaceH(height: 7),
                                                  FittedBox(
                                                    child: Text(
                                                      Constant.amountShow(amount: controller.userModel.value.walletAmount!),
                                                      style: Constant.defaultTextStyle(
                                                        size: 18,
                                                        color: themeChange.isDarkTheme() ? AppThemData.primaryWhite.withOpacity(.7) : AppThemData.primaryBlack.withOpacity(.7),
                                                      ),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        spaceH(height: 20),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            CustomButtonWidget(
                                              padding: const EdgeInsets.symmetric(horizontal: 22),
                                              buttonTitle: "Top Up".tr,
                                              borderRadius: 60,
                                              width: 70,
                                              textColor: AppThemData.primaryWhite,
                                              buttonColor: AppThemData.primaryBlack,
                                              onPress: () {
                                                controller.setDefaultData();
                                                showDialog(context: context, builder: (context) => const TopUpDialog());
                                              },
                                            ).expand(),
                                            spaceW(width: 10),
                                            CustomButtonWidget(
                                              padding: const EdgeInsets.symmetric(horizontal: 22),
                                              buttonTitle: "Transaction History".tr,
                                              borderRadius: 60,
                                              width: 70,
                                              textColor: AppThemData.primaryBlack,
                                              buttonColor: AppThemData.primary200,
                                              onPress: () {
                                                controller.setDefaultData();
                                                showDialog(context: context, builder: (context) => const TransactionHistoryDialog());
                                              },
                                            ).expand(),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ).expand(),
                                  Container(
                                    margin: const EdgeInsets.fromLTRB(16, 0, 0, 0),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [Color(0xFFFF8008), Color(0xFFFFC837)], // Using your defined gradient
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.15),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(shape: BoxShape.circle, color: AppThemData.primaryWhite.withOpacity(.2)),
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: SvgPicture.asset(
                                                  'assets/icons/ic_gift.svg',
                                                  colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
                                                  height: 30,
                                                  width: 30,
                                                ),
                                              ),
                                            ),
                                            spaceW(width: 14),
                                            Expanded(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  TextCustom(
                                                    title: 'Loyalty Credits',
                                                    fontSize: 14,
                                                    color: themeChange.isDarkTheme() ? AppThemData.primaryWhite.withOpacity(.7) : AppThemData.primaryBlack.withOpacity(.7),
                                                    fontFamily: AppThemeData.medium,
                                                  ),
                                                  spaceH(height: 7),
                                                  FittedBox(
                                                    child: Text(
                                                      controller.userModel.value.loyaltyCredits != null ? "${controller.userModel.value.loyaltyCredits!} pts" : '0 pts',
                                                      style: Constant.defaultTextStyle(
                                                        size: 18,
                                                        color: themeChange.isDarkTheme() ? AppThemData.primaryWhite.withOpacity(.7) : AppThemData.primaryBlack.withOpacity(.7),
                                                      ),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        spaceH(height: 20),
                                        CustomButtonWidget(
                                          buttonTitle: "History",
                                          textColor: AppThemData.primaryBlack,
                                          buttonColor: AppThemData.primary200,
                                          borderRadius: 60,
                                          width: double.infinity,
                                          onPress: () {
                                            showDialog(context: context, builder: (context) => const LoyaltyTransactionDialog());
                                          },
                                        )
                                      ],
                                    ),
                                  ).expand(),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                tablet: controller.isLoading.value
                    ? Constant.loader()
                    : SingleChildScrollView(
                  child: Column(
                    children: [
                      ContainerCustom(
                        color: themeChange.isDarkTheme() ? AppThemData.primaryBlack : AppThemData.primaryWhite,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
                                  width: 400,
                                  decoration: BoxDecoration(
                                    image: const DecorationImage(image: AssetImage("assets/image/wallet_card.png"), fit: BoxFit.fill),
                                    border: Border.all(color: AppThemData.lightGrey06.withOpacity(.5)),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(shape: BoxShape.circle, color: AppThemData.primaryWhite.withOpacity(.2)),
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: SvgPicture.asset(
                                                'assets/icons/ic_wallet.svg',
                                                colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
                                                height: 30,
                                                width: 30,
                                              ),
                                            ),
                                          ),
                                          spaceW(width: 14),
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                TextCustom(
                                                  title: 'Wallet Amount',
                                                  fontSize: 14,
                                                  color: themeChange.isDarkTheme() ? AppThemData.primaryWhite.withOpacity(.7) : AppThemData.primaryBlack.withOpacity(.7),
                                                  fontFamily: AppThemeData.medium,
                                                ),
                                                spaceH(height: 7),
                                                FittedBox(
                                                  child: Text(
                                                    Constant.amountShow(amount: controller.userModel.value.walletAmount!),
                                                    style: Constant.defaultTextStyle(
                                                      size: 18,
                                                      color: themeChange.isDarkTheme() ? AppThemData.primaryWhite.withOpacity(.7) : AppThemData.primaryBlack.withOpacity(.7),
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      spaceH(height: 20),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          CustomButtonWidget(
                                            padding: const EdgeInsets.symmetric(horizontal: 22),
                                            buttonTitle: "Top Up".tr,
                                            borderRadius: 60,
                                            width: 70,
                                            textColor: AppThemData.primaryWhite,
                                            buttonColor: AppThemData.primaryBlack,
                                            onPress: () {
                                              controller.setDefaultData();
                                              showDialog(context: context, builder: (context) => const TopUpDialog());
                                            },
                                          ).expand(),
                                          spaceW(width: 10),
                                          CustomButtonWidget(
                                            padding: const EdgeInsets.symmetric(horizontal: 22),
                                            buttonTitle: "Transaction History".tr,
                                            borderRadius: 60,
                                            width: 70,
                                            textColor: AppThemData.primaryBlack,
                                            buttonColor: AppThemData.primary200,
                                            onPress: () {
                                              controller.setDefaultData();
                                              showDialog(context: context, builder: (context) => const TransactionHistoryDialog());
                                            },
                                          ).expand(),
                                        ],
                                      ),
                                    ],
                                  ),
                                ).expand(),
                                Container(
                                  margin: const EdgeInsets.fromLTRB(20, 0, 16, 0),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
                                  width: 400,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Color(0xFFFF8008), Color(0xFFFFC837)], // Using your defined gradient
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.15),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(shape: BoxShape.circle, color: AppThemData.primaryWhite.withOpacity(.2)),
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: SvgPicture.asset(
                                                'assets/icons/ic_gift.svg',
                                                colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
                                                height: 30,
                                                width: 30,
                                              ),
                                            ),
                                          ),
                                          spaceW(width: 14),
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                TextCustom(
                                                  title: 'Loyalty Credits',
                                                  fontSize: 14,
                                                  color: themeChange.isDarkTheme() ? AppThemData.primaryWhite.withOpacity(.7) : AppThemData.primaryBlack.withOpacity(.7),
                                                  fontFamily: AppThemeData.medium,
                                                ),
                                                spaceH(height: 7),
                                                FittedBox(
                                                  child: Text(
                                                    controller.userModel.value.loyaltyCredits != null ? "${controller.userModel.value.loyaltyCredits!} pts" : '0 pts',
                                                    style: Constant.defaultTextStyle(
                                                      size: 18,
                                                      color: themeChange.isDarkTheme() ? AppThemData.primaryWhite.withOpacity(.7) : AppThemData.primaryBlack.withOpacity(.7),
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      spaceH(height: 20),
                                      CustomButtonWidget(
                                        buttonTitle: "History",
                                        textColor: AppThemData.primaryBlack,
                                        buttonColor: AppThemData.primary200,
                                        borderRadius: 60,
                                        width: double.infinity,
                                        onPress: () {
                                          showDialog(context: context, builder: (context) => const LoyaltyTransactionDialog());
                                        },
                                      )
                                    ],
                                  ),
                                ).expand(),
                              ],
                            ),
                            spaceH(height: 16),
                            Row(
                              children: [
                                Container(
                                  padding: paddingEdgeInsets(horizontal: 20, vertical: 20),
                                  decoration: BoxDecoration(
                                    color: themeChange.isDarkTheme() ? AppThemData.greyShade950 : AppThemData.greyShade50,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextCustom(
                                        title: "User Details".tr,
                                        fontSize: 16,
                                        fontFamily: AppThemeData.bold,
                                      ),
                                      spaceH(height: 16),
                                      rowDataWidget(name: "Name", value: controller.userModel.value.fullName.toString(), themeChange: themeChange),
                                      spaceH(height: 10),
                                      rowDataWidget(
                                          name: "Phone Number",
                                          value: Constant.maskMobileNumber(
                                              mobileNumber: controller.userModel.value.phoneNumber.toString(),
                                              countryCode: controller.userModel.value.countryCode.toString()),
                                          themeChange: themeChange),
                                      spaceH(height: 10),
                                      rowDataWidget(name: "Email ", value: Constant.maskEmail(email: controller.userModel.value.email.toString()), themeChange: themeChange),
                                      spaceH(height: 10),
                                      rowDataWidget(name: "Gender", value: controller.userModel.value.gender.toString(), themeChange: themeChange),
                                    ],
                                  ),
                                ).expand(),
                                SizedBox().expand()
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                desktop: controller.isLoading.value
                    ? Constant.loader()
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            ContainerCustom(
                              color: themeChange.isDarkTheme() ? AppThemData.primaryBlack : AppThemData.primaryWhite,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
                                        width: 400,
                                        decoration: BoxDecoration(
                                          image: const DecorationImage(image: AssetImage("assets/image/wallet_card.png"), fit: BoxFit.fill),
                                          border: Border.all(color: AppThemData.lightGrey06.withOpacity(.5)),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(shape: BoxShape.circle, color: AppThemData.primaryWhite.withOpacity(.2)),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: SvgPicture.asset(
                                                      'assets/icons/ic_wallet.svg',
                                                      colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
                                                      height: 30,
                                                      width: 30,
                                                    ),
                                                  ),
                                                ),
                                                spaceW(width: 14),
                                                Expanded(
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      TextCustom(
                                                        title: 'Wallet Amount',
                                                        fontSize: 14,
                                                        color: themeChange.isDarkTheme() ? AppThemData.primaryWhite.withOpacity(.7) : AppThemData.primaryBlack.withOpacity(.7),
                                                        fontFamily: AppThemeData.medium,
                                                      ),
                                                      spaceH(height: 7),
                                                      FittedBox(
                                                        child: Text(
                                                          Constant.amountShow(amount: controller.userModel.value.walletAmount!),
                                                          style: Constant.defaultTextStyle(
                                                            size: 18,
                                                            color: themeChange.isDarkTheme() ? AppThemData.primaryWhite.withOpacity(.7) : AppThemData.primaryBlack.withOpacity(.7),
                                                          ),
                                                          textAlign: TextAlign.center,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            spaceH(height: 20),
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                CustomButtonWidget(
                                                  padding: const EdgeInsets.symmetric(horizontal: 22),
                                                  buttonTitle: "Top Up".tr,
                                                  borderRadius: 60,
                                                  width: 70,
                                                  textColor: AppThemData.primaryWhite,
                                                  buttonColor: AppThemData.primaryBlack,
                                                  onPress: () {
                                                    controller.setDefaultData();
                                                    showDialog(context: context, builder: (context) => const TopUpDialog());
                                                  },
                                                ).expand(),
                                                spaceW(width: 10),
                                                CustomButtonWidget(
                                                  padding: const EdgeInsets.symmetric(horizontal: 22),
                                                  buttonTitle: "Transaction History".tr,
                                                  borderRadius: 60,
                                                  width: 70,
                                                  textColor: AppThemData.primaryBlack,
                                                  buttonColor: AppThemData.primary200,
                                                  onPress: () {
                                                    controller.setDefaultData();
                                                    showDialog(context: context, builder: (context) => const TransactionHistoryDialog());
                                                  },
                                                ).expand(),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ).expand(),
                                      Container(
                                        margin: const EdgeInsets.fromLTRB(20, 0, 16, 0),
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
                                        width: 400,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [Color(0xFFFF8008), Color(0xFFFFC837)], // Using your defined gradient
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius: BorderRadius.circular(16),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.15),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(shape: BoxShape.circle, color: AppThemData.primaryWhite.withOpacity(.2)),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: SvgPicture.asset(
                                                      'assets/icons/ic_gift.svg',
                                                      colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
                                                      height: 30,
                                                      width: 30,
                                                    ),
                                                  ),
                                                ),
                                                spaceW(width: 14),
                                                Expanded(
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      TextCustom(
                                                        title: 'Loyalty Credits',
                                                        fontSize: 14,
                                                        color: themeChange.isDarkTheme() ? AppThemData.primaryWhite.withOpacity(.7) : AppThemData.primaryBlack.withOpacity(.7),
                                                        fontFamily: AppThemeData.medium,
                                                      ),
                                                      spaceH(height: 7),
                                                      FittedBox(
                                                        child: Text(
                                                          controller.userModel.value.loyaltyCredits != null ? "${controller.userModel.value.loyaltyCredits!} pts" : '0 pts',
                                                          style: Constant.defaultTextStyle(
                                                            size: 18,
                                                            color: themeChange.isDarkTheme() ? AppThemData.primaryWhite.withOpacity(.7) : AppThemData.primaryBlack.withOpacity(.7),
                                                          ),
                                                          textAlign: TextAlign.center,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            spaceH(height: 20),
                                            CustomButtonWidget(
                                              buttonTitle: "History",
                                              textColor: AppThemData.primaryBlack,
                                              buttonColor: AppThemData.primary200,
                                              borderRadius: 60,
                                              width: double.infinity,
                                              onPress: () {
                                                showDialog(context: context, builder: (context) => const LoyaltyTransactionDialog());
                                              },
                                            )
                                          ],
                                        ),
                                      ).expand(),
                                    ],
                                  ),
                                  spaceH(height: 16),
                                  Row(
                                    children: [
                                      Container(
                                        padding: paddingEdgeInsets(horizontal: 20, vertical: 20),
                                        decoration: BoxDecoration(
                                          color: themeChange.isDarkTheme() ? AppThemData.greyShade950 : AppThemData.greyShade50,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            TextCustom(
                                              title: "User Details".tr,
                                              fontSize: 16,
                                              fontFamily: AppThemeData.bold,
                                            ),
                                            spaceH(height: 16),
                                            rowDataWidget(name: "Name", value: controller.userModel.value.fullName.toString(), themeChange: themeChange),
                                            spaceH(height: 10),
                                            rowDataWidget(
                                                name: "Phone Number",
                                                value: Constant.maskMobileNumber(
                                                    mobileNumber: controller.userModel.value.phoneNumber.toString(),
                                                    countryCode: controller.userModel.value.countryCode.toString()),
                                                themeChange: themeChange),
                                            spaceH(height: 10),
                                            rowDataWidget(name: "Email ", value: Constant.maskEmail(email: controller.userModel.value.email.toString()), themeChange: themeChange),
                                            spaceH(height: 10),
                                            rowDataWidget(name: "Gender", value: controller.userModel.value.gender.toString(), themeChange: themeChange),
                                          ],
                                        ),
                                      ).expand(),
                                      SizedBox().expand()
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
              ));
        });
  }
}

Row rowDataWidget({required String name, required String value, required themeChange}) {
  return Row(
    children: [
      TextCustom(title: name.tr, fontSize: 14, fontFamily: AppThemeData.medium).expand(flex: 3),
      const TextCustom(title: ":   ", fontSize: 14, fontFamily: AppThemeData.medium),
      TextCustom(
        title: value,
        fontSize: 14,
        fontFamily: AppThemeData.regular,
      ).expand(flex: 3),
    ],
  );
}

class TopUpDialog extends StatelessWidget {
  const TopUpDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return GetX<CustomerDetailScreenController>(
      init: CustomerDetailScreenController(),
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

class TransactionHistoryDialog extends StatelessWidget {
  const TransactionHistoryDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return GetX<CustomerDetailScreenController>(
      init: CustomerDetailScreenController(),
      builder: (controller) {
        return CustomDialog(
          title: "Transaction History",
          widgetList: [
            Obx(
              () => controller.currentPageWalletTransaction.isEmpty
                  ? const TextCustom(title: "Transaction History not available")
                  : SizedBox(
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: ListView.builder(
                        itemCount: controller.currentPageWalletTransaction.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          WalletTransactionModel walletTransactionModel = controller.currentPageWalletTransaction[index];
                          return Container(
                            width: 358,
                            height: 80,
                            clipBehavior: Clip.antiAlias,
                            decoration: const BoxDecoration(),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  margin: const EdgeInsets.only(right: 16),
                                  decoration: ShapeDecoration(
                                    color: (walletTransactionModel.isCredit ?? false)
                                        ? themeChange.isDarkTheme()
                                            ? AppThemData.green950
                                            : AppThemData.green50
                                        : themeChange.isDarkTheme()
                                            ? AppThemData.secondary950
                                            : AppThemData.secondary50,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                  ),
                                  child: Center(
                                    child: SvgPicture.asset(
                                      // "assets/icon/ic_my_wallet.svg",
                                      "assets/icons/ic_my_wallet.svg",
                                      colorFilter: ColorFilter.mode((walletTransactionModel.isCredit ?? false) ? AppThemData.green500 : AppThemData.red500, BlendMode.srcIn),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          width: 1,
                                          color: themeChange.isDarkTheme() ? AppThemData.greyShade800 : AppThemData.greyShade100,
                                        ),
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: TextCustom(
                                                title: walletTransactionModel.note ?? '',
                                                fontSize: 16,
                                                fontFamily: AppThemeData.medium,
                                                color: themeChange.isDarkTheme() ? AppThemData.greyShade50 : AppThemData.greyShade950,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            TextCustom(
                                              title: Constant.amountToShow(amount: walletTransactionModel.amount ?? ''),
                                              fontSize: 16,
                                              fontFamily: AppThemeData.bold,
                                              color: (walletTransactionModel.isCredit ?? false) ? AppThemData.green500 : AppThemData.red500,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  TextCustom(
                                                    title: (walletTransactionModel.createdDate ?? Timestamp.now()).toDate().dateMonthYear(),
                                                    fontFamily: AppThemeData.medium,
                                                    fontSize: 14,
                                                    color: themeChange.isDarkTheme() ? AppThemData.greyShade400 : AppThemData.greyShade500,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Container(
                                                    height: 16,
                                                    decoration: ShapeDecoration(
                                                      shape: RoundedRectangleBorder(
                                                        side: BorderSide(
                                                          width: 1,
                                                          strokeAlign: BorderSide.strokeAlignCenter,
                                                          color: themeChange.isDarkTheme() ? AppThemData.greyShade800 : AppThemData.greyShade100,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  TextCustom(
                                                    title: (walletTransactionModel.createdDate ?? Timestamp.now()).toDate().time(),
                                                    fontSize: 14,
                                                    fontFamily: AppThemeData.medium,
                                                    color: themeChange.isDarkTheme() ? AppThemData.greyShade400 : AppThemData.greyShade500,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
            )
          ],
          bottomWidgetList: [
            Visibility(
              visible: controller.totalPage.value > 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: WebPagination(
                        currentPage: controller.currentPage.value,
                        totalPage: controller.totalPage.value,
                        displayItemCount: controller.pageValue("3"),
                        onPageChanged: (page) {
                          controller.currentPage.value = page;
                          controller.setPaginationForTransactionHistory(controller.totalItemPerPage.value);
                        }),
                  ),
                ],
              ),
            )
          ],
          controller: controller,
        );
      },
    );
  }
}

class LoyaltyTransactionDialog extends StatelessWidget {
  const LoyaltyTransactionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return GetX<CustomerDetailScreenController>(
      init: CustomerDetailScreenController(),
      builder: (controller) {
        return CustomDialog(
          title: "Loyalty Credits History",
          widgetList: [
            controller.loyaltyPointTransactionList.isEmpty
                ? Center(child: const TextCustom(title: "Transaction History not available"))
                : SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: ListView.builder(
                      itemCount: controller.loyaltyPointTransactionList.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        LoyaltyPointTransactionModel loyaltyTransactionModel = controller.loyaltyPointTransactionList[index];
                        return Container(
                          width: 358,
                          height: 80,
                          clipBehavior: Clip.antiAlias,
                          decoration: const BoxDecoration(),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                margin: const EdgeInsets.only(right: 16),
                                decoration: ShapeDecoration(
                                  color: (loyaltyTransactionModel.isCredit ?? false)
                                      ? themeChange.isDarkTheme()
                                          ? AppThemData.green950
                                          : AppThemData.green50
                                      : themeChange.isDarkTheme()
                                          ? AppThemData.secondary950
                                          : AppThemData.secondary50,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                ),
                                child: Center(
                                  child: SvgPicture.asset(
                                    // "assets/icon/ic_my_wallet.svg",
                                    "assets/icons/ic_gift.svg",
                                    colorFilter: ColorFilter.mode((loyaltyTransactionModel.isCredit ?? false) ? AppThemData.green500 : AppThemData.red500, BlendMode.srcIn),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        width: 1,
                                        color: themeChange.isDarkTheme() ? AppThemData.greyShade800 : AppThemData.greyShade100,
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: TextCustom(
                                              title: loyaltyTransactionModel.note ?? '',
                                              fontSize: 16,
                                              fontFamily: AppThemeData.medium,
                                              color: themeChange.isDarkTheme() ? AppThemData.greyShade50 : AppThemData.greyShade950,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          TextCustom(
                                            title: "${loyaltyTransactionModel.points ?? '0'} pts",
                                            fontSize: 16,
                                            fontFamily: AppThemeData.bold,
                                            color: (loyaltyTransactionModel.isCredit ?? false) ? AppThemData.green500 : AppThemData.red500,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                TextCustom(
                                                  title: (loyaltyTransactionModel.createdAt ?? Timestamp.now()).toDate().dateMonthYear(),
                                                  fontFamily: AppThemeData.medium,
                                                  fontSize: 14,
                                                  color: themeChange.isDarkTheme() ? AppThemData.greyShade400 : AppThemData.greyShade500,
                                                ),
                                                const SizedBox(width: 8),
                                                Container(
                                                  height: 16,
                                                  decoration: ShapeDecoration(
                                                    shape: RoundedRectangleBorder(
                                                      side: BorderSide(
                                                        width: 1,
                                                        strokeAlign: BorderSide.strokeAlignCenter,
                                                        color: themeChange.isDarkTheme() ? AppThemData.greyShade800 : AppThemData.greyShade100,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                TextCustom(
                                                  title: (loyaltyTransactionModel.createdAt ?? Timestamp.now()).toDate().time(),
                                                  fontSize: 14,
                                                  fontFamily: AppThemeData.medium,
                                                  color: themeChange.isDarkTheme() ? AppThemData.greyShade400 : AppThemData.greyShade500,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
          ],
          bottomWidgetList: [],
          controller: controller,
        );
      },
    );
  }
}

// ignore_for_file: depend_on_referenced_packages

import 'package:customer/app/models/loyalty_point_transaction_model.dart';
import 'package:customer/app/models/wallet_transaction_model.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant_widgets/custom_dialog_box.dart';
import 'package:customer/constant_widgets/no_data_view.dart';
import 'package:customer/constant_widgets/round_shape_button.dart';
import 'package:customer/constant_widgets/show_toast_dialog.dart';
import 'package:customer/constant_widgets/title_view.dart';
import 'package:customer/extension/date_time_extension.dart';
import 'package:customer/theme/app_them_data.dart';
import 'package:customer/theme/responsive.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../controllers/loyalty_point_screen_controller.dart';

class LoyaltyPointScreenView extends GetView<LoyaltyPointScreenController> {
  const LoyaltyPointScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetBuilder(
        init: LoyaltyPointScreenController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: themeChange.isDarkTheme() ? AppThemData.black : AppThemData.white,
            // appBar: AppBarWithBorder(
            //   title: "My Wallet".tr,
            //   bgColor: themeChange.isDarkTheme() ? AppThemData.black : AppThemData.white,
            // ),
            resizeToAvoidBottomInset: false,
            body: Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).padding.bottom + 14),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: Responsive.width(100, context),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                      decoration: ShapeDecoration(
                        color: AppThemData.secondary500,
                        image: const DecorationImage(image: AssetImage("assets/images/bg_wallet.png")),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Total Points".tr,
                                      style: GoogleFonts.inter(
                                        color: themeChange.isDarkTheme() ? AppThemData.black : AppThemData.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Obx(
                                      () => Text(
                                        "${controller.userModel.value.loyaltyCredits ?? '0.0'} Pts",
                                        style: GoogleFonts.inter(
                                          color: themeChange.isDarkTheme() ? AppThemData.black : AppThemData.white,
                                          fontSize: 28,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: RoundShapeButton(
                                  title: "title".tr,
                                  buttonColor: themeChange.isDarkTheme() ? AppThemData.black : AppThemData.white,
                                  buttonTextColor: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black,
                                  titleWidget: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    // mainAxisAlignment: MainAxisAlignment.center,
                                    // crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Convert".tr,
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.inter(
                                          color: themeChange.isDarkTheme() ? AppThemData.grey50 : AppThemData.grey950,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    double userPoints = double.tryParse(controller.userModel.value.loyaltyCredits ?? "0.0") ?? 0.0;
                                    // SAFELY CHECK loyaltyPoint first
                                    double minRedeemPoints = 0.0;
                                    if (Constant.loyaltyPoint != null && Constant.loyaltyPoint!.minRedeemPoint != null) {
                                      minRedeemPoints = double.tryParse(Constant.loyaltyPoint!.minRedeemPoint!) ?? 0.0;
                                    }

                                    if (userPoints >= minRedeemPoints && minRedeemPoints > 0) {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return CustomDialogBox(
                                                themeChange: themeChange,
                                                title: "Convert Points".tr,
                                                descriptions: "Are you sure you want to convert your loyalty points into wallet balance?".tr,
                                                positiveString: "Convert".tr,
                                                negativeString: "Cancel".tr,
                                                positiveClick: () async {
                                                  Navigator.pop(context);
                                                  ShowToastDialog.showLoader("Converting...".tr);
                                                  controller.isLoading.value = true;
                                                  LoyaltyPointTransactionModel pointTransaction = LoyaltyPointTransactionModel(
                                                    id: Constant.getUuid(),
                                                    note: "Loyalty Points Converted to Wallet Balance",
                                                    customerId: controller.userModel.value.id,
                                                    transactionId: Constant.getUuid(),
                                                    points: controller.userModel.value.loyaltyCredits.toString(),
                                                    isCredit: false,
                                                    createdAt: Timestamp.now(),
                                                  );
                                                  await FireStoreUtils.setLoyaltyPointTransaction(pointTransaction);

                                                  // Calculate wallet amount based on conversion rate
                                                  double conversionRate = 0.0;
                                                  if (Constant.loyaltyPoint != null && Constant.loyaltyPoint!.conversionRate != null) {
                                                    conversionRate = double.tryParse(Constant.loyaltyPoint!.conversionRate!) ?? 0.0;
                                                  }
                                                  double walletAmount = userPoints * conversionRate;

                                                  // Create a wallet transaction
                                                  WalletTransactionModel walletTransaction = WalletTransactionModel(
                                                    id: Constant.getUuid(),
                                                    userId: controller.userModel.value.id,
                                                    amount: walletAmount.toStringAsFixed(2),
                                                    type: "customer",
                                                    paymentType: "Loyalty Points Conversion",
                                                    note: "Converted $userPoints Points to \$$walletAmount",
                                                    isCredit: true,
                                                    createdDate: Timestamp.now(),
                                                  );

                                                  controller.userModel.value.loyaltyCredits = "0";
                                                  double currentWalletBalance = double.tryParse(controller.userModel.value.walletAmount ?? "0.0") ?? 0.0;
                                                  controller.userModel.value.walletAmount = (currentWalletBalance + walletAmount).toStringAsFixed(2);
                                                  await FireStoreUtils.setWalletTransaction(walletTransaction);
                                                  await FireStoreUtils.updateUser(controller.userModel.value); // Save to Firestore
                                                  ShowToastDialog.closeLoader();
                                                  ShowToastDialog.showToast("Loyalty points converted successfully!".tr);
                                                  controller.getData();
                                                },
                                                negativeClick: () {
                                                  Navigator.pop(context);
                                                },
                                                img: Image.asset(
                                                  "assets/icon/ic_loyaltyPoint.png",
                                                  height: 90,
                                                  width: 90,
                                                ));
                                          });
                                    } else {
                                      ShowToastDialog.showToast("You don't have enough points to convert".tr);
                                    }
                                  },
                                  size: const Size(0, 48),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("•  "),
                              Expanded(
                                child: Text(
                                  "🎊 Every time you complete a ride, you automatically earn loyalty points.".tr,
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("•  "),
                              Expanded(
                                child: Text(
                                  "MinRedeemPoint".trParams({"minRedeemPoint": Constant.loyaltyPoint?.minRedeemPoint ?? '0'}),
                                  // "⌛ Minimum points to convert: ${Constant.loyaltyPoint?.minRedeemPoint} Pts".tr,
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("•  "),
                              Expanded(
                                child: Text(
                                  "🔄 When you convert, points will be added to your wallet and reset to 0.".tr,
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    TitleView(titleText: "Transaction History".tr, padding: const EdgeInsets.fromLTRB(0, 20, 0, 16)),
                    Obx(
                      () => controller.loyaltyPointList.isEmpty
                          ? NoDataView(
                              themeChange: themeChange,
                              // height: Responsive.height(30, context),
                            )
                          : ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: controller.loyaltyPointList.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                LoyaltyPointTransactionModel loyaltyTransactionModel = controller.loyaltyPointList[index];
                                return Container(
                                  width: 358,
                                  // height: 80,
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
                                                  ? AppThemData.success950
                                                  : AppThemData.success50
                                              : themeChange.isDarkTheme()
                                                  ? AppThemData.secondary950
                                                  : AppThemData.secondary50,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(100),
                                          ),
                                        ),
                                        child: Center(
                                          child: SvgPicture.asset(
                                            "assets/icon/ic_gift.svg",
                                            colorFilter:
                                                ColorFilter.mode((loyaltyTransactionModel.isCredit ?? false) ? AppThemData.success500 : AppThemData.danger500, BlendMode.srcIn),
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
                                                color: themeChange.isDarkTheme() ? AppThemData.grey800 : AppThemData.grey100,
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
                                                    child: Text(
                                                      loyaltyTransactionModel.note ?? '',
                                                      style: GoogleFonts.inter(
                                                        color: themeChange.isDarkTheme() ? AppThemData.grey50 : AppThemData.grey950,
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w400,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Text(
                                                    "${loyaltyTransactionModel.points ?? ''} Pts",
                                                    textAlign: TextAlign.right,
                                                    style: GoogleFonts.inter(
                                                      color: (loyaltyTransactionModel.isCredit ?? false) ? AppThemData.success500 : AppThemData.danger500,
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w600,
                                                    ),
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
                                                        Text(
                                                          (loyaltyTransactionModel.createdAt ?? Timestamp.now()).toDate().dateMonthYear(),
                                                          style: GoogleFonts.inter(
                                                            color: themeChange.isDarkTheme() ? AppThemData.grey400 : AppThemData.grey500,
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.w400,
                                                          ),
                                                        ),
                                                        const SizedBox(width: 8),
                                                        Container(
                                                          height: 16,
                                                          decoration: ShapeDecoration(
                                                            shape: RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 1,
                                                                strokeAlign: BorderSide.strokeAlignCenter,
                                                                color: themeChange.isDarkTheme() ? AppThemData.grey800 : AppThemData.grey100,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(width: 8),
                                                        Text(
                                                          (loyaltyTransactionModel.createdAt ?? Timestamp.now()).toDate().time(),
                                                          style: GoogleFonts.inter(
                                                            color: themeChange.isDarkTheme() ? AppThemData.grey400 : AppThemData.grey500,
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.w400,
                                                          ),
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
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }
}

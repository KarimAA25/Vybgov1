// ignore_for_file: deprecated_member_use, unnecessary_null_comparison


import 'package:cached_network_image/cached_network_image.dart';
import 'package:customer/app/models/vehicle_type_model.dart';
import 'package:customer/app/modules/payment_method/views/payment_method_view.dart';
import 'package:customer/app/modules/select_location/controllers/select_location_controller.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant_widgets/round_shape_button.dart';
import 'package:customer/theme/app_them_data.dart';
import 'package:customer/theme/responsive.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SelectVehicleTypeBottomSheet extends StatelessWidget {
  final ScrollController scrollController;

  const SelectVehicleTypeBottomSheet({
    super.key,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: SelectLocationController(),
        builder: (controller) {
          return Container(
            height: Responsive.height(100, context),
            decoration: BoxDecoration(
              color: themeChange.isDarkTheme() ? AppThemData.black : AppThemData.white,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
            padding: const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 0),
            child: Align(
              alignment: Alignment.topCenter,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            width: 44,
                            height: 5,
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: ShapeDecoration(
                              color: themeChange.isDarkTheme() ? AppThemData.grey700 : AppThemData.grey200,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                          ),
                          (controller.mapModel.value == null)
                              ? Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Gathering options".tr,
                                      style: GoogleFonts.inter(
                                        color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.grey950,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    const LinearProgressIndicator()
                                  ],
                                )
                              : Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Choose a trip".tr,
                                      style: GoogleFonts.inter(
                                        color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.grey950,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                      Text(
                                        "Allow booking only for women".tr,
                                        style:
                                            GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black),
                                      ),
                                      Transform.scale(
                                        scale: .9,
                                        child: CupertinoSwitch(
                                          value: controller.isForFemale.value,
                                          activeTrackColor: AppThemData.primary500,
                                          inactiveTrackColor: themeChange.isDarkTheme() ? AppThemData.grey700 : AppThemData.grey100,
                                          onChanged: (value) {
                                            controller.isForFemale.value = value;
                                          },
                                        ),
                                      )
                                    ]),
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: controller.vehicleTypeList.length,
                                      padding: EdgeInsets.zero,
                                      itemBuilder: (context, index) {
                                        VehicleTypeModel vehicleTypeModel = controller.vehicleTypeList[index];
                                        String finalPrice = controller.getVehiclePrice(vehicleTypeModel);
                                        return Obx(
                                          () => InkWell(
                                            onTap: () {
                                              controller.changeVehicleType(vehicleTypeModel);
                                            },
                                            child: Container(
                                              width: Responsive.width(100, context),
                                              padding: const EdgeInsets.all(16),
                                              margin: const EdgeInsets.only(top: 12),
                                              decoration: ShapeDecoration(
                                                shape: RoundedRectangleBorder(
                                                  side: controller.selectVehicleType.value.id == vehicleTypeModel.id
                                                      ? BorderSide(width: 1, color: AppThemData.primary500)
                                                      : BorderSide(width: 1, color: themeChange.isDarkTheme() ? AppThemData.grey800 : AppThemData.grey100),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  CachedNetworkImage(
                                                    width: 50,
                                                    height: 50,
                                                    imageUrl: vehicleTypeModel.image.toString(),
                                                    fit: BoxFit.cover,
                                                    placeholder: (context, url) => Constant.loader(),
                                                    errorWidget: (context, url, error) => Image.network(Constant.userPlaceHolder),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          vehicleTypeModel.title.toString(),
                                                          style: GoogleFonts.inter(
                                                            color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 2),
                                                        Text(
                                                          '${'We will arrived in '.tr}${controller.mapModel.value.rows!.first.elements!.first.duration!.text ?? ''}',
                                                          style: GoogleFonts.inter(
                                                            color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.w400,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.end,
                                                    children: [
                                                      Text(
                                                        "${controller.distanceOfKm.value.distance} ${controller.distanceOfKm.value.distanceType}", // e.g. "287.672 Km"
                                                        textAlign: TextAlign.right,
                                                        style: GoogleFonts.inter(
                                                          color: themeChange.isDarkTheme() ? AppThemData.grey400 : AppThemData.grey700,
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.w400,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        Constant.amountToShow(amount: finalPrice.toString()),
                                                        textAlign: TextAlign.right,
                                                        style: GoogleFonts.inter(
                                                          color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 2),
                                                      Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        children: [
                                                          SvgPicture.asset("assets/icon/ic_multi_person.svg"),
                                                          const SizedBox(width: 6),
                                                          Text(
                                                            vehicleTypeModel.persons.toString(),
                                                            style: GoogleFonts.inter(
                                                              color: AppThemData.primary500,
                                                              fontSize: 16,
                                                              fontWeight: FontWeight.w400,
                                                              height: 0.09,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                  ],
                                ),
                        ],
                      ),
                    ),
                  ),
                  Obx(
                    () => Padding(
                      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 14, top: 8),
                      child: Visibility(
                          visible: controller.mapModel.value != null,
                          child: Container(
                            width: Responsive.width(100, context),
                            decoration: BoxDecoration(
                                color: themeChange.isDarkTheme() ? AppThemData.black : AppThemData.white,
                                border: Border(
                                  top: BorderSide(width: 1.0, color: themeChange.isDarkTheme() ? AppThemData.grey800 : AppThemData.grey100),
                                )),
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Total'.tr,
                                            style: GoogleFonts.inter(
                                              color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Obx(
                                            () => Text(
                                              Constant.amountToShow(amount: controller.totalAmount.value.toString()),
                                              style: GoogleFonts.inter(
                                                color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      InkWell(
                                        onTap: () {
                                          Get.to(PaymentMethodView());
                                        },
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: 32,
                                              height: 32,
                                              padding: const EdgeInsets.all(5),
                                              decoration: ShapeDecoration(
                                                color: themeChange.isDarkTheme() ? AppThemData.grey900 : AppThemData.grey50,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(100),
                                                ),
                                              ),
                                              child: (controller.selectedPaymentMethod.value == Constant.paymentModel!.cash!.name)
                                                  ? SvgPicture.asset("assets/icon/ic_cash.svg")
                                                  : (controller.selectedPaymentMethod.value == Constant.paymentModel!.wallet!.name)
                                                      ? SvgPicture.asset(
                                                          "assets/icon/ic_wallet.svg",
                                                          color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black,
                                                        )
                                                      : (controller.selectedPaymentMethod.value == Constant.paymentModel!.paypal!.name)
                                                          ? Image.asset("assets/images/ig_paypal.png", height: 24, width: 24)
                                                          : (controller.selectedPaymentMethod.value == Constant.paymentModel!.strip!.name)
                                                              ? Image.asset("assets/images/ig_stripe.png", height: 24, width: 24)
                                                              : (controller.selectedPaymentMethod.value == Constant.paymentModel!.razorpay!.name)
                                                                  ? Image.asset("assets/images/ig_razorpay.png", height: 24, width: 24)
                                                                  : (controller.selectedPaymentMethod.value == Constant.paymentModel!.payStack!.name)
                                                                      ? Image.asset("assets/images/ig_paystack.png", height: 24, width: 24)
                                                                      : (controller.selectedPaymentMethod.value == Constant.paymentModel!.mercadoPago!.name)
                                                                          ? Image.asset("assets/images/ig_marcadopago.png", height: 24, width: 24)
                                                                          : (controller.selectedPaymentMethod.value == Constant.paymentModel!.payFast!.name)
                                                                              ? Image.asset("assets/images/ig_payfast.png", height: 24, width: 24)
                                                                              : (controller.selectedPaymentMethod.value == Constant.paymentModel!.flutterWave!.name)
                                                                                  ? Image.asset("assets/images/ig_flutterwave.png", height: 24, width: 24)
                                                                                  : (controller.selectedPaymentMethod.value == Constant.paymentModel!.midtrans!.name)
                                                                                      ? Image.asset("assets/images/ig_midtrans.png", height: 24, width: 24)
                                                                                      : (controller.selectedPaymentMethod.value == Constant.paymentModel!.xendit!.name)
                                                                                          ? Image.asset("assets/images/ig_xendit.png", height: 24, width: 24)
                                                                                          : const SizedBox(height: 24, width: 24),
                                            ),
                                            const SizedBox(width: 8),
                                            SizedBox(
                                              width: 80,
                                              child: Text(
                                                controller.selectedPaymentMethod.value.toString(),
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.inter(
                                                  color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 2),
                                            const Icon(Icons.keyboard_arrow_right_rounded)
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 3),
                                RoundShapeButton(
                                    size: const Size(151, 45),
                                    title: "Continue".tr,
                                    buttonColor: AppThemData.primary500,
                                    buttonTextColor: AppThemData.black,
                                    onTap: () {
                                      controller.confirmBooking();
                                    }),
                              ],
                            ),
                          )),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }
}

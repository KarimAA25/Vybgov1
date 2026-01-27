import 'package:customer/app/modules/chat_screen/views/chat_screen_view.dart';
import 'package:customer/app/modules/reason_for_cancel/views/reason_for_cancel_view.dart';
import 'package:customer/app/modules/select_location/controllers/select_location_controller.dart';
import 'package:customer/constant/booking_status.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant_widgets/pick_drop_point_view.dart';
import 'package:customer/constant_widgets/round_shape_button.dart';
import 'package:customer/theme/app_them_data.dart';
import 'package:customer/theme/responsive.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class FindingDriverBottomSheet extends StatelessWidget {
  final ScrollController scrollController;

  const FindingDriverBottomSheet({
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
            decoration: BoxDecoration(
              color: themeChange.isDarkTheme() ? AppThemData.black : AppThemData.white,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
            padding: const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 10),
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
                  (controller.bookingModel.value.driverId != null &&
                          controller.bookingModel.value.driverId!.isNotEmpty &&
                          controller.bookingModel.value.bookingStatus != BookingStatus.bookingPlaced &&
                          controller.bookingModel.value.bookingStatus != BookingStatus.driverAssigned)
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                              child: Obx(
                                () => Text(
                                  controller.etaInMinutes.value > 0 ? "Driver arriving in ${controller.etaInMinutes.value} min..".tr : "Driver is arriving...".tr,
                                  style: GoogleFonts.inter(
                                    color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            if (controller.bookingModel.value.otp != null && controller.bookingModel.value.otp!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                                child: SizedBox(
                                  width: Responsive.width(100, context),
                                  child: Wrap(
                                    alignment: WrapAlignment.start,
                                    children: [
                                      Text(
                                        "Your OTP for this Ride is ".tr,
                                        style: GoogleFonts.inter(
                                          color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      Text(
                                        controller.bookingModel.value.otp ?? '',
                                        textAlign: TextAlign.right,
                                        style: GoogleFonts.inter(
                                          color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            Container(
                              width: Responsive.width(100, context),
                              padding: const EdgeInsets.all(16),
                              margin: const EdgeInsets.all(16),
                              decoration: ShapeDecoration(
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(width: 1, color: themeChange.isDarkTheme() ? AppThemData.grey800 : AppThemData.grey100),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    margin: const EdgeInsets.only(right: 10),
                                    clipBehavior: Clip.antiAlias,
                                    decoration: ShapeDecoration(
                                      color: themeChange.isDarkTheme() ? AppThemData.grey950 : Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(200),
                                      ),
                                      image: const DecorationImage(
                                        image: NetworkImage(Constant.profileConstant),
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Obx(
                                          () => Text(
                                            controller.driverModel.value.fullName ?? '',
                                            style: GoogleFonts.inter(
                                              color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            if ((controller.driverModel.value.reviewsSum ?? '').isNotEmpty) ...{const Icon(Icons.star_rate_rounded, color: AppThemData.warning500)},
                                            Text(
                                              (controller.driverModel.value.reviewsSum ?? "No reviews yet".tr).toString(),
                                              style: GoogleFonts.inter(
                                                color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  InkWell(
                                      onTap: () {
                                        Get.to(() => ChatScreenView(receiverId: controller.driverModel.value.id.toString()));
                                      },
                                      child: SvgPicture.asset("assets/icon/ic_message.svg")),
                                  const SizedBox(width: 12),
                                  InkWell(
                                      onTap: () {
                                        Constant().launchCall("${controller.driverModel.value.countryCode}${controller.driverModel.value.phoneNumber}");
                                      },
                                      child: SvgPicture.asset("assets/icon/ic_phone.svg"))
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: PickDropPointView(
                                pickUpAddress: controller.bookingModel.value.pickUpLocationAddress ?? '',
                                dropAddress: controller.bookingModel.value.dropLocationAddress ?? '',
                                stopAddress: controller.bookingModel.value.stops!.map((e) => e.address!).toList(),
                              ),
                            ),
                            const SizedBox(height: 12),
                            RoundShapeButton(
                                size: Size(Responsive.width(100, context), 45),
                                title: "Cancel",
                                buttonColor: AppThemData.danger500,
                                buttonTextColor: AppThemData.white,
                                onTap: () {
                                  Get.to(const ReasonForCancelView(), arguments: {"bookingModel": controller.bookingModel.value});
                                }),
                          ],
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Confirming your trip".tr,
                              style: GoogleFonts.inter(
                                color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.grey950,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Center(child: Lottie.asset('assets/animation/driver.json', height: 500, width: 500)),
                          ],
                        )
                ],
              ),
            ),
          );
        });
  }
}

// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:customer/app/models/vehicle_type_model.dart';
import 'package:customer/app/modules/rental_location/controllers/rental_select_location_controller.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant_widgets/round_shape_button.dart';
import 'package:customer/theme/app_them_data.dart';
import 'package:customer/theme/responsive.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class RentalSelectVehicleTypeBottomSheet extends StatelessWidget {
  final ScrollController scrollController;

  const RentalSelectVehicleTypeBottomSheet({
    super.key,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetBuilder(
        init: RentalSelectLocationController(),
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
                          Obx(() => (controller.mapModel.value == null)
                              ? Column(
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
                              : Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.start, children: [
                                  Text(
                                    "Choose a trip".tr,
                                    style: GoogleFonts.inter(
                                      color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.grey950,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      controller.popupIndex.value = 2;
                                      controller.getRentalPackage();
                                    },
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: controller.vehicleTypeList.length,
                                      padding: EdgeInsets.zero,
                                      itemBuilder: (context, index) {
                                        VehicleTypeModel vehicleTypeModel = controller.vehicleTypeList[index];
                                        return InkWell(
                                          onTap: () {
                                            controller.changeVehicleType(vehicleTypeModel);
                                          },
                                          child: Obx(() {
                                            return Container(
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
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.end,
                                                    children: [
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
                                            );
                                          }),
                                        );
                                      },
                                    ),
                                  )
                                ]))
                        ],
                      ),
                    ),
                  ),
                  Obx(
                    () => Padding(
                      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom, top: 8),
                      child: Visibility(
                          visible: controller.mapModel.value != null,
                          child: Container(
                            width: Responsive.width(100, context),
                            decoration: BoxDecoration(
                              color: themeChange.isDarkTheme() ? AppThemData.black : AppThemData.white,
                              // border: Border(
                              //   top: BorderSide(width: 1.0, color: themeChange.isDarkTheme() ? AppThemData.grey800 : AppThemData.grey100),
                              // )
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // const SizedBox(width: 3),
                                Expanded(
                                  child: RoundShapeButton(
                                      size: const Size(0, 45),
                                      title: "Continue".tr,
                                      buttonColor: AppThemData.primary500,
                                      buttonTextColor: AppThemData.black,
                                      onTap: () {
                                        controller.popupIndex.value = 2;
                                        controller.getRentalPackage();
                                      }),
                                ),
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

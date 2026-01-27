// ignore_for_file: deprecated_member_use

import 'dart:developer';
import 'package:customer/app/models/vehicle_type_model.dart';
import 'package:customer/app/modules/book_intercity/views/widget/select_payment_type.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant_widgets/app_bar_with_border.dart';
import 'package:customer/constant_widgets/osm_place_picker/osm_location_picker_screen.dart';
import 'package:customer/constant_widgets/osm_place_picker/osm_selected_location_model.dart';
import 'package:customer/constant_widgets/place_picker/location_picker_screen.dart';
import 'package:customer/constant_widgets/place_picker/selected_location_model.dart';
import 'package:customer/constant_widgets/round_shape_button.dart';
import 'package:customer/constant_widgets/show_toast_dialog.dart';
import 'package:customer/extension/date_time_extension.dart';
import 'package:customer/extension/string_extensions.dart';
import 'package:customer/theme/app_them_data.dart';
import 'package:customer/theme/responsive.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:timelines_plus/timelines_plus.dart';
import '../controllers/book_intercity_controller.dart';

class BookIntercityView extends StatelessWidget {
  const BookIntercityView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetBuilder(
        init: BookIntercityController(),
        builder: (controller) {
          return Scaffold(
            appBar: AppBarWithBorder(
              title: "",
              bgColor: themeChange.isDarkTheme() ? AppThemData.black : AppThemData.white,
            ),
            backgroundColor: themeChange.isDarkTheme() ? AppThemData.black : AppThemData.grey50,
            body: Obx(
              () => controller.isLoading.value
                  ? Center(child: Constant.loader())
                  : Padding(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                      child: Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (controller.intercityPersonalDocuments.first.isAvailable ^ controller.intercitySharingDocuments.first.isAvailable)
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Ride Type".tr,
                                          style: GoogleFonts.inter(
                                            color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.grey950,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          controller.intercityPersonalDocuments.first.isAvailable ? "Personal Ride".tr : "Ride Sharing".tr,
                                          style: GoogleFonts.inter(
                                            color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  if (controller.intercityPersonalDocuments.first.isAvailable && controller.intercitySharingDocuments.first.isAvailable)
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Select Ride Type".tr,
                                          style: GoogleFonts.inter(
                                            color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        RadioGroup<int>(
                                          groupValue: controller.selectedRideType.value,
                                          onChanged: (value) {
                                            controller.selectedRideType.value = value ?? 1;
                                            controller.updateCalculation();
                                          },
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Visibility(
                                                visible: controller.intercityPersonalDocuments.first.isAvailable,
                                                child: Row(
                                                  children: [
                                                    Radio(
                                                      value: 1,
                                                      activeColor: AppThemData.primary500,
                                                    ),
                                                    InkWell(
                                                      onTap: () {
                                                        controller.selectedRideType.value = 1;
                                                        controller.updateCalculation();
                                                        log('------------------------> personal ride selected ');
                                                      },
                                                      child: Text(
                                                        "Personal Ride".tr,
                                                        style: GoogleFonts.inter(
                                                            fontSize: 14,
                                                            color: controller.selectedRideType.value == 1
                                                                ? themeChange.isDarkTheme()
                                                                    ? AppThemData.white
                                                                    : AppThemData.grey950
                                                                : AppThemData.grey500,
                                                            fontWeight: FontWeight.w500),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Visibility(
                                                visible: controller.intercitySharingDocuments.first.isAvailable,
                                                child: Row(
                                                  children: [
                                                    Radio(
                                                      value: 2,
                                                      activeColor: AppThemData.primary500,
                                                    ),
                                                    InkWell(
                                                      onTap: () {
                                                        controller.selectedRideType.value = 2;
                                                        controller.updateCalculation();
                                                      },
                                                      child: Text(
                                                        "Ride Sharing".tr,
                                                        style: GoogleFonts.inter(
                                                            fontSize: 14,
                                                            color: controller.selectedRideType.value == 2
                                                                ? themeChange.isDarkTheme()
                                                                    ? AppThemData.white
                                                                    : AppThemData.grey950
                                                                : AppThemData.grey500,
                                                            fontWeight: FontWeight.w500),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Select Location".tr,
                                        style: GoogleFonts.inter(
                                          color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.grey950,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      TextButton(
                                          onPressed: () {
                                            controller.addStop();
                                          },
                                          child: Text(
                                            "+ Add stops".tr,
                                            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, color: AppThemData.primary500),
                                          ))
                                    ],
                                  ),
                                  Timeline.tileBuilder(
                                    shrinkWrap: true,
                                    theme: TimelineThemeData(nodePosition: 0),
                                    padding: EdgeInsets.zero,
                                    builder: TimelineTileBuilder.connected(
                                      contentsAlign: ContentsAlign.basic,
                                      indicatorBuilder: (context, index) {
                                        if (index == 0) {
                                          return SvgPicture.asset("assets/icon/ic_pick_up.svg");
                                        } else if (index == controller.stopControllers.length + 1) {
                                          return SvgPicture.asset("assets/icon/ic_drop_in.svg");
                                        } else {
                                          return SvgPicture.asset(
                                            "assets/icon/ic_stop_icon.svg",
                                            color: AppThemData.primary500,
                                          ); // stop
                                        }
                                      },
                                      connectorBuilder: (context, index, connectorType) {
                                        return DashedLineConnector(
                                          color: themeChange.isDarkTheme() ? AppThemData.grey600 : AppThemData.grey300,
                                        );
                                      },
                                      contentsBuilder: (context, index) {
                                        if (index == 0) {
                                          // Source
                                          return buildLocationField(context, controller, controller.pickupLocationController, "Pick up Location".tr, controller.pickUpFocusNode,
                                              isSource: true);
                                        } else if (index == controller.stopControllers.length + 1) {
                                          // Destination
                                          return buildLocationField(context, controller, controller.dropLocationController, "Destination Location".tr, controller.dropFocusNode,
                                              isDestination: true);
                                        } else {
                                          // Stops in between
                                          final stopIndex = index - 1;
                                          return buildLocationField(
                                            context,
                                            controller,
                                            controller.stopControllers[stopIndex],
                                            "Stop ${stopIndex + 1}",
                                            controller.stopFocusNodes[stopIndex],
                                            isStop: true,
                                            stopIndex: stopIndex,
                                            onRemove: () {
                                              controller.removeStop(stopIndex);
                                            },
                                          );
                                        }
                                      },
                                      itemCount: controller.stopControllers.length + 2,
                                    ),
                                  ),
                                  if (controller.selectedRideType.value == 1) ...{
                                    Text(
                                      "Select Date".tr,
                                      style: GoogleFonts.inter(
                                        color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.grey950,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    InkWell(
                                      onTap: () async {
                                        final DateTime? selectedDate = await showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime.now(),
                                          lastDate: DateTime.now().add(const Duration(days: 1000)),
                                        );

                                        if (selectedDate != null) {
                                          controller.selectedDate.value = selectedDate;
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        margin: const EdgeInsets.only(top: 4),
                                        clipBehavior: Clip.antiAlias,
                                        decoration: ShapeDecoration(
                                          color: themeChange.isDarkTheme() ? AppThemData.grey950 : AppThemData.grey25,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(100),
                                          ),
                                        ),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Obx(
                                              () => Text(
                                                controller.selectedDate.value == null ? "Select Date".tr : controller.selectedDate.value!.dateMonthYear(),
                                                style: GoogleFonts.inter(
                                                  color: themeChange.isDarkTheme() ? AppThemData.grey50 : AppThemData.grey500,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ),
                                            const Icon(
                                              Icons.calendar_month_outlined,
                                              color: AppThemData.grey500,
                                              size: 24,
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  },
                                  if (controller.selectedRideType.value == 2) ...{
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Select Date".tr,
                                                style: GoogleFonts.inter(
                                                  color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.grey950,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              InkWell(
                                                onTap: () async {
                                                  final DateTime? selectedDate = await showDatePicker(
                                                    context: context,
                                                    initialDate: DateTime.now(),
                                                    firstDate: DateTime.now(),
                                                    lastDate: DateTime.now().add(const Duration(days: 1000)),
                                                  );

                                                  if (selectedDate != null) {
                                                    controller.selectedDate.value = selectedDate;
                                                  }
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets.all(16),
                                                  margin: const EdgeInsets.only(top: 4),
                                                  clipBehavior: Clip.antiAlias,
                                                  decoration: ShapeDecoration(
                                                    color: themeChange.isDarkTheme() ? AppThemData.grey950 : AppThemData.grey25,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(100),
                                                    ),
                                                  ),
                                                  child: Row(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Obx(
                                                        () => Text(
                                                          controller.selectedDate.value == null ? "Select Date".tr : controller.selectedDate.value!.dateMonthYear(),
                                                          style: GoogleFonts.inter(
                                                            color: themeChange.isDarkTheme() ? AppThemData.grey50 : AppThemData.grey500,
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.w400,
                                                          ),
                                                        ),
                                                      ),
                                                      const Icon(
                                                        Icons.calendar_month_outlined,
                                                        color: AppThemData.grey500,
                                                        size: 24,
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          flex: 1,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Persons".tr,
                                                style: GoogleFonts.inter(
                                                  color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.grey950,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Container(
                                                width: 116,
                                                height: 56,
                                                padding: const EdgeInsets.all(16),
                                                clipBehavior: Clip.antiAlias,
                                                decoration: ShapeDecoration(
                                                  color: themeChange.isDarkTheme() ? AppThemData.grey950 : AppThemData.grey25,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(100),
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    InkWell(
                                                        onTap: () {
                                                          if (controller.selectedPersons.value != 1) {
                                                            controller.selectedPersons.value = controller.selectedPersons.value - 1;
                                                          }
                                                        },
                                                        child: const Icon(Icons.remove)),
                                                    Expanded(
                                                      child: Text(
                                                        controller.selectedPersons.value.toString(),
                                                        textAlign: TextAlign.center,
                                                        style: GoogleFonts.inter(
                                                          color: themeChange.isDarkTheme() ? AppThemData.grey50 : AppThemData.grey500,
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.w400,
                                                        ),
                                                      ),
                                                    ),
                                                    InkWell(
                                                        onTap: () {
                                                          controller.selectedPersons.value = controller.selectedPersons.value + 1;
                                                        },
                                                        child: const Icon(Icons.add)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  },
                                  const SizedBox(height: 20),
                                  Text(
                                    "Select Time".tr,
                                    style: GoogleFonts.inter(
                                      color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.grey950,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  GestureDetector(
                                    onTap: () => controller.pickTime(context),
                                    child: Obx(() => Container(
                                          width: MediaQuery.of(context).size.width,
                                          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                                          decoration: BoxDecoration(
                                            color: themeChange.isDarkTheme() ? AppThemData.grey950 : AppThemData.grey25,
                                            borderRadius: BorderRadius.circular(100),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Icon(Icons.watch_later_outlined, color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.grey950),
                                              SizedBox(width: 10),
                                              Text(
                                                controller.selectedTime.value,
                                                style: GoogleFonts.inter(
                                                  color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.grey950,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    "Set Price".tr,
                                    style: GoogleFonts.inter(
                                      color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.grey950,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  TextFormField(
                                    controller: controller.addPriceController.value,
                                    decoration: InputDecoration(
                                      hintText: "Add your price".tr,
                                      fillColor: themeChange.isDarkTheme() ? AppThemData.grey950 : AppThemData.grey25,
                                      focusColor: Colors.white,
                                      filled: true,
                                      suffixIcon: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: SvgPicture.asset(
                                          "assets/icon/ic_currency_usd.svg",
                                        ),
                                      ),
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(100),
                                          borderSide: BorderSide(color: themeChange.isDarkTheme() ? AppThemData.grey950 : AppThemData.grey25)),
                                      disabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(100),
                                          borderSide: BorderSide(color: themeChange.isDarkTheme() ? AppThemData.grey950 : AppThemData.grey25)),
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(100),
                                          borderSide: BorderSide(color: themeChange.isDarkTheme() ? AppThemData.grey950 : AppThemData.grey25)),
                                      errorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(100),
                                          borderSide: BorderSide(color: themeChange.isDarkTheme() ? AppThemData.grey950 : AppThemData.grey25)),
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(100),
                                          borderSide: BorderSide(color: themeChange.isDarkTheme() ? AppThemData.grey950 : AppThemData.grey25)),
                                      focusedErrorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(100),
                                          borderSide: BorderSide(color: themeChange.isDarkTheme() ? AppThemData.grey950 : AppThemData.grey25)),
                                      hintStyle: GoogleFonts.inter(
                                        color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    style: GoogleFonts.inter(
                                      color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.grey950,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Obx(
                                    () => Visibility(
                                      visible: controller.isEstimatePriceVisible.value,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10), color: themeChange.isDarkTheme() ? AppThemData.secondary900 : AppThemData.secondary100),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "EstimatePrice".trParams({"estimatePrice": Constant.amountToShow(amount: controller.estimatePrice.value.toString())}),
                                              // 'Recommended price for this ride: ${Constant.amountToShow(amount: controller.estimatePrice.value.toString())}.',
                                              style: GoogleFonts.inter(
                                                textStyle: TextStyle(
                                                  color: AppThemData.secondary500,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            if (controller.nightCharges.value.toString() != "0.0")
                                              Text(
                                                "NightCharges".trParams({"nightCharges": Constant.amountToShow(amount: controller.nightCharges.value.toString())}),
                                                //'You Select the Night Timing so Night charge has been included: ${Constant.amountToShow(amount: controller.nightCharges.value.toString())}.',
                                                style: GoogleFonts.inter(
                                                  textStyle: TextStyle(
                                                    color: AppThemData.secondary500,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                    Text(
                                      "Allow booking only for women".tr,
                                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black),
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
                                  const SizedBox(height: 20),
                                  Text(
                                    "Select Vehicle".tr,
                                    style: GoogleFonts.inter(
                                      color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.grey950,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 0),
                                  Container(
                                    height: 58.0,
                                    width: Responsive.width(100, context),
                                    margin: const EdgeInsets.only(top: 6, bottom: 0),
                                    decoration: BoxDecoration(
                                      color: themeChange.isDarkTheme() ? AppThemData.grey950 : AppThemData.grey25,
                                      borderRadius: BorderRadius.circular(2000.0),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: Obx(
                                        () => DropdownButton<VehicleTypeModel>(
                                          style: GoogleFonts.inter(
                                            fontSize: 16,
                                            color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.grey950,
                                          ),
                                          hint: Text(
                                            "Select Vehicle Type".tr,
                                            style: GoogleFonts.inter(
                                              color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.grey950,
                                              fontSize: 16,
                                            ),
                                          ),
                                          itemHeight: 70,
                                          dropdownColor: themeChange.isDarkTheme() ? AppThemData.grey600 : AppThemData.grey25,
                                          padding: const EdgeInsets.only(right: 12),
                                          selectedItemBuilder: (context) {
                                            return controller.vehicleTypeList.map((VehicleTypeModel value) {
                                              return Padding(
                                                padding: const EdgeInsets.only(left: 12, right: 12),
                                                child: Row(
                                                  children: [
                                                    Image.network(
                                                      value.image.toString(),
                                                      height: 42,
                                                      width: 42,
                                                    ),
                                                    const SizedBox(
                                                      width: 15,
                                                    ),
                                                    Text(value.title.toString()),
                                                  ],
                                                ),
                                              );
                                            }).toList();
                                          },
                                          items: controller.vehicleTypeList.map<DropdownMenuItem<VehicleTypeModel>>((VehicleTypeModel value) {
                                            return DropdownMenuItem(
                                              value: value,
                                              child: Column(
                                                children: [
                                                  Row(
                                                    children: [
                                                      Image.network(
                                                        value.image.toString(),
                                                        height: 42,
                                                        width: 42,
                                                      ),
                                                      const SizedBox(
                                                        width: 15,
                                                      ),
                                                      Text(value.title.toString()),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  Visibility(visible: controller.vehicleTypeList.indexOf(value) != (controller.vehicleTypeList.length - 1), child: const Divider())
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                          borderRadius: BorderRadius.circular(12),
                                          isExpanded: false,
                                          isDense: false,
                                          onChanged: (VehicleTypeModel? newSelectedBank) {
                                            controller.vehicleTypeModel.value = newSelectedBank!;
                                          },
                                          value: controller.vehicleTypeModel.value,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  if (controller.selectedRideType.value == 2) ...{
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Add person".tr,
                                          style: GoogleFonts.inter(
                                            color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.grey950,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        InkWell(
                                          onTap: () {
                                            showModalBottomSheet(
                                                shape: const RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
                                                ),
                                                context: context,
                                                enableDrag: true,
                                                isScrollControlled: true,
                                                useSafeArea: true,
                                                builder: (BuildContext context) {
                                                  return AddPersonPopup(
                                                    themeChange: themeChange,
                                                    controller: controller,
                                                  );
                                                });
                                          },
                                          child: Container(
                                            width: Responsive.width(100, context),
                                            height: 60,
                                            padding: const EdgeInsets.all(8),
                                            decoration: ShapeDecoration(
                                              color: themeChange.isDarkTheme() ? AppThemData.grey950 : AppThemData.grey25,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(200),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                    padding: const EdgeInsets.all(10),
                                                    decoration: ShapeDecoration(
                                                      color: AppThemData.primary50,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(200),
                                                      ),
                                                    ),
                                                    child: SvgPicture.asset("assets/icon/ic_user_add.svg")),
                                                const SizedBox(width: 12),
                                                Text(
                                                  "Add Person".tr,
                                                  style: GoogleFonts.inter(
                                                    color: themeChange.isDarkTheme() ? Colors.white : Colors.black,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  },
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 14, top: 10),
                            child: RoundShapeButton(
                                size: const Size(200, 45),
                                title: "Next".tr,
                                buttonColor: AppThemData.primary500,
                                buttonTextColor: AppThemData.black,
                                onTap: () {
                                  controller.subTotal.value = controller.addPriceController.value.text.toDouble();
                                  if (controller.selectedCouponModel.value.id != null) {
                                    if (controller.selectedCouponModel.value.isFix == true) {
                                      controller.discountAmount.value = double.parse(controller.selectedCouponModel.value.amount.toString());
                                    } else {
                                      controller.discountAmount.value = (controller.subTotal.value) * double.parse(controller.selectedCouponModel.value.amount.toString()) / 100;
                                    }
                                  }
                                  double taxAmount = 0.0;
                                  for (var element in controller.taxList) {
                                    taxAmount =
                                        taxAmount + Constant.calculateTax(amount: ((controller.subTotal.value) - controller.discountAmount.value).toString(), taxModel: element);
                                  }

                                  controller.totalAmount.value = (controller.subTotal.value - controller.discountAmount.value) + taxAmount;

                                  if (controller.pickupLocationController.value.text.isEmpty || controller.pickupLocationController.value.text == '') {
                                    return ShowToastDialog.showToast("Please Enter pickUp Location".tr);
                                  }
                                  if (controller.dropLocationController.value.text.isEmpty || controller.dropLocationController.value.text == '') {
                                    return ShowToastDialog.showToast("Please Enter Destination Location".tr);
                                  } else if (controller.addPriceController.value.text.isEmpty || controller.addPriceController.value.text == '') {
                                    controller.addPriceController.value.text = controller.estimatePrice.value.toString();
                                  } else if (controller.selectedRideType.value == 2) {
                                    if (controller.selectedPersons.value != controller.addInSharing.length + 1) {
                                      return ShowToastDialog.showToast("Please Add person".tr);
                                    } else if (controller.selectedTime.value == 'Select Time') {
                                      return ShowToastDialog.showToast("Please Select Start Time".tr);
                                    } else {
                                      Get.to(() => SelectPaymentType());
                                    }
                                  } else if (controller.selectedTime.value == 'Select Time') {
                                    return ShowToastDialog.showToast("Please Select Start Time".tr);
                                  } else {
                                    Get.to(() => SelectPaymentType());
                                  }
                                }),
                          ),
                        ],
                      ),
                    ),
            ),
          );
        });
  }

  Widget buildLocationField(
    BuildContext context,
    BookIntercityController controller,
    TextEditingController textController,
    String hint,
    FocusNode focusNode, {
    bool isSource = false,
    bool isDestination = false,
    bool isStop = false,
    int? stopIndex,
    VoidCallback? onRemove,
  }) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          focusNode: focusNode,
          cursorColor: AppThemData.primary500,
          readOnly: true,
          controller: textController,
          onTap: () {
            focusNode.requestFocus();
            if (Constant.selectedMap == "Google Map") {
              Get.to(LocationPickerScreen())!.then((value) {
                if (value != null) {
                  SelectedLocationModel selectedLocationModel = value;
                  String formattedAddress = "${selectedLocationModel.address?.street ?? ''}, "
                      "${selectedLocationModel.address?.subLocality ?? ''}, "
                      "${selectedLocationModel.address?.locality ?? ''}, "
                      "${selectedLocationModel.address?.administrativeArea}, "
                      "${selectedLocationModel.address?.postalCode} "
                      "${selectedLocationModel.address?.country ?? ''}";

                  if (isSource) {
                    controller.sourceLocation = selectedLocationModel.latLng;
                    controller.pikUpAddress.value = formattedAddress;
                    textController.text = formattedAddress;
                  } else if (isDestination) {
                    controller.destination = selectedLocationModel.latLng;
                    controller.dropAddress.value = formattedAddress;
                    textController.text = formattedAddress;
                  } else if (stopIndex != null) {
                    controller.stopsLatLng[stopIndex] = selectedLocationModel.latLng;
                    controller.googleStopAddresses[stopIndex] = formattedAddress;
                    textController.text = formattedAddress;
                  }

                  controller.updateData();
                } else {
                  Future.delayed(const Duration(milliseconds: 100), () => focusNode.requestFocus());
                }
              });
            } else {
              Get.to(OSMLocationPickerScreen())!.then((value) {
                if (value != null) {
                  OsmSelectedLocationModel osmSelectedLocationModel = value;
                  String formattedAddress = "${osmSelectedLocationModel.address?.street ?? ''}, "
                      "${osmSelectedLocationModel.address?.subLocality ?? ''}, "
                      "${osmSelectedLocationModel.address?.locality ?? ''}, "
                      "${osmSelectedLocationModel.address?.administrativeArea ?? ''}, "
                      "${osmSelectedLocationModel.address?.postalCode ?? ''} "
                      "${osmSelectedLocationModel.address?.country ?? ''}";

                  // 1️⃣ Save OSM location
                  if (isSource) {
                    controller.osmSourceLocation = osmSelectedLocationModel.latLng;
                    controller.pikUpAddress.value = formattedAddress;
                    textController.text = formattedAddress;
                  } else if (isDestination) {
                    controller.osmDestination = osmSelectedLocationModel.latLng;
                    controller.dropAddress.value = formattedAddress;
                    textController.text = formattedAddress;
                  } else if (stopIndex != null) {
                    controller.osmStopsLatLng[stopIndex] = osmSelectedLocationModel.latLng;
                    controller.osmStopAddresses[stopIndex] = formattedAddress;
                    textController.text = formattedAddress;
                  }

                  // 2️⃣ Sync to Google variables for calculation
                  if (controller.osmSourceLocation != null) {
                    controller.sourceLocation = LatLng(
                      controller.osmSourceLocation!.latitude,
                      controller.osmSourceLocation!.longitude,
                    );
                  }
                  if (controller.osmDestination != null) {
                    controller.destination = LatLng(
                      controller.osmDestination!.latitude,
                      controller.osmDestination!.longitude,
                    );
                  }
                  for (int i = 0; i < controller.osmStopsLatLng.length; i++) {
                    if (controller.osmStopsLatLng[i] != null) {
                      controller.stopsLatLng[i] = LatLng(
                        controller.osmStopsLatLng[i]!.latitude,
                        controller.osmStopsLatLng[i]!.longitude,
                      );
                      controller.googleStopAddresses[i] = controller.osmStopAddresses[i];
                    }
                  }

                  // 3️⃣ Update distance & price
                  controller.updateData();
                }
              });
            }
          },
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: themeChange.isDarkTheme() ? AppThemData.grey950 : AppThemData.grey25,
            focusColor: AppThemData.primary500,
            suffixIcon: isStop
                ? InkWell(
                    onTap: onRemove,
                    child: const Icon(Icons.delete, color: Colors.red),
                  )
                : (textController.text.isNotEmpty
                    ? InkWell(
                        onTap: () {
                          if (isSource) {
                            if (Constant.selectedMap == "Google Map") {
                              controller.sourceLocation = null;
                            } else {
                              controller.osmSourceLocation = null;
                            }
                            controller.pikUpAddress.value = '';
                          } else if (isDestination) {
                            if (Constant.selectedMap == "Google Map") {
                              controller.destination = null;
                            } else {
                              controller.osmDestination = null;
                            }
                            controller.dropAddress.value = '';
                          } else if (stopIndex != null) {
                            if (Constant.selectedMap == "Google Map") {
                              controller.stopsLatLng[stopIndex] = null;
                              controller.googleStopAddresses[stopIndex] = '';
                            } else {
                              controller.osmStopsLatLng[stopIndex] = null;
                              controller.osmStopAddresses[stopIndex] = '';
                            }
                          }
                          textController.clear();
                          controller.update();
                        },
                        child: const Icon(Icons.close),
                      )
                    : null),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(100), borderSide: BorderSide(color: themeChange.isDarkTheme() ? AppThemData.grey950 : AppThemData.grey25)),
            disabledBorder:
                OutlineInputBorder(borderRadius: BorderRadius.circular(100), borderSide: BorderSide(color: themeChange.isDarkTheme() ? AppThemData.grey950 : AppThemData.grey25)),
            enabledBorder:
                OutlineInputBorder(borderRadius: BorderRadius.circular(100), borderSide: BorderSide(color: themeChange.isDarkTheme() ? AppThemData.grey950 : AppThemData.grey25)),
            errorBorder:
                OutlineInputBorder(borderRadius: BorderRadius.circular(100), borderSide: BorderSide(color: themeChange.isDarkTheme() ? AppThemData.grey950 : AppThemData.grey25)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100), borderSide: BorderSide(color: AppThemData.primary500)),
            focusedErrorBorder:
                OutlineInputBorder(borderRadius: BorderRadius.circular(100), borderSide: BorderSide(color: themeChange.isDarkTheme() ? AppThemData.grey950 : AppThemData.grey25)),
            hintStyle: GoogleFonts.inter(
              color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          style: GoogleFonts.inter(
            color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ));
  }
}

class AddPersonPopup extends StatelessWidget {
  const AddPersonPopup({
    super.key,
    required this.themeChange,
    required this.controller,
  });

  final DarkThemeProvider themeChange;
  final BookIntercityController controller;

  @override
  Widget build(BuildContext context) {
    // કીબોર્ડની હાઈટ મેળવવા માટે
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      // કીબોર્ડ ખુલે ત્યારે કન્ટેનરને ઉપર ધકેલવા માટે બોટમ પેડિંગ
      padding: EdgeInsets.fromLTRB(16, 24, 16, bottomInset > 0 ? bottomInset + 10 : 20),
      decoration: ShapeDecoration(
        color: themeChange.isDarkTheme() ? Colors.black : Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // કન્ટેન્ટ જેટલી જ હાઈટ લેશે
        children: [
          // ઉપરનો ટાઈટલ અને ટેક્સ્ટફીલ્ડ્સ વાળો ભાગ સ્ક્રોલ થઈ શકે તે માટે Expanded + SingleChildScrollView
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Add Sharing Persons".tr,
                    style: GoogleFonts.inter(
                      color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  // પર્સન લિસ્ટ સેક્શન
                  Obx(() => controller.totalAddPersonShare.isEmpty
                      ? const SizedBox.shrink()
                      : Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(top: 12),
                          decoration: ShapeDecoration(
                            color: themeChange.isDarkTheme() ? AppThemData.grey950 : AppThemData.grey25,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Column(
                            children: controller.totalAddPersonShare.map((person) {
                              return Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(person.name ?? '',
                                                style: GoogleFonts.inter(
                                                    color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950, fontSize: 16, fontWeight: FontWeight.w500)),
                                            Text(person.mobileNumber ?? '',
                                                style: GoogleFonts.inter(color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950, fontSize: 12)),
                                          ],
                                        ),
                                      ),
                                      Checkbox(
                                        value: controller.addInSharing.any((p) => p.id == person.id),
                                        activeColor: AppThemData.warning06,
                                        onChanged: (value) => controller.toggleSelection(person),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete, color: AppThemData.error07, size: 20),
                                        onPressed: () => controller.deletePerson(person.id!),
                                      ),
                                    ],
                                  ),
                                  Divider(color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950),
                                ],
                              );
                            }).toList(),
                          ),
                        )),
                  const SizedBox(height: 20),
                  Text(
                    "Name".tr,
                    style: GoogleFonts.inter(
                      color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  buildTextField(
                    controller: controller.enterNameController.value,
                    hint: "Enter Name".tr,
                    icon: "assets/icon/ic_user_round.svg",
                    formatters: [FilteringTextInputFormatter.allow(RegExp("[a-zA-Z ]"))],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Name".tr,
                    style: GoogleFonts.inter(
                      color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  buildTextField(
                    controller: controller.enterNumberController.value,
                    hint: "Enter Number".tr,
                    icon: "assets/icon/ic_phone_ring.svg",
                    keyboardType: TextInputType.phone,
                  ),

                  const SizedBox(height: 10),

                  // Add Person Button
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        if (controller.enterNameController.value.text.trim().isEmpty) {
                          ShowToastDialog.showToast("Please Enter Name".tr);
                        } else if (controller.enterNumberController.value.text.trim().isEmpty) {
                          ShowToastDialog.showToast("Please Enter Mobile Number".tr);
                        } else {
                          controller.addPerson();
                        }
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(shape: BoxShape.circle, color: AppThemData.grey25),
                            child: SvgPicture.asset("assets/icon/ic_user_add.svg"),
                          ),
                          const SizedBox(width: 12),
                          Text("Add Person".tr, style: GoogleFonts.inter(color: AppThemData.primary500, fontSize: 16, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: RoundShapeButton(
                size: const Size(200, 45),
                title: "Save".tr,
                buttonColor: AppThemData.primary500,
                buttonTextColor: AppThemData.black,
                onTap: () {
                  Navigator.pop(context);
                }),
          )
        ],
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String hint,
    required String icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? formatters,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: formatters,
      style: GoogleFonts.inter(color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: themeChange.isDarkTheme() ? AppThemData.grey950 : AppThemData.grey50,
        suffixIcon: Padding(padding: const EdgeInsets.all(12.0), child: SvgPicture.asset(icon)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(100), borderSide: BorderSide.none),
        hintStyle: GoogleFonts.inter(color: AppThemData.grey400),
      ),
    );
  }
}

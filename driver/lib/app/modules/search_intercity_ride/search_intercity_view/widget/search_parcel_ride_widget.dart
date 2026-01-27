// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:driver/app/models/parcel_model.dart';
import 'package:driver/app/models/user_model.dart';
import 'package:driver/app/modules/parcel_detail_details/views/parcel_booking_details_view.dart';
import 'package:driver/app/modules/search_intercity_ride/controllers/search_ride_controller.dart';
import 'package:driver/constant/booking_status.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/constant/send_notification.dart';
import 'package:driver/constant_widgets/custom_dialog_box.dart';
import 'package:driver/constant_widgets/custom_loader.dart';
import 'package:driver/constant_widgets/osm_place_picker/osm_location_picker_screen.dart';
import 'package:driver/constant_widgets/osm_place_picker/osm_selected_location_model.dart';
import 'package:driver/constant_widgets/pick_drop_point_view.dart';
import 'package:driver/constant_widgets/place_picker/location_picker_screen.dart';
import 'package:driver/constant_widgets/place_picker/selected_location_model.dart';
import 'package:driver/constant_widgets/round_shape_button.dart';
import 'package:driver/constant_widgets/show_toast_dialog.dart';
import 'package:driver/extension/date_time_extension.dart';
import 'package:driver/theme/app_them_data.dart';
import 'package:driver/theme/responsive.dart';
import 'package:driver/utils/dark_theme_provider.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:timelines_plus/timelines_plus.dart';

// ignore_for_file: depend_on_referenced_packages
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchParcelRideWidget extends StatelessWidget {
  const SearchParcelRideWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return GetBuilder(
        init: SearchRideController(),
        builder: (controller) {
          return Obx(
            () => Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Location'.tr,
                      style: GoogleFonts.inter(
                        color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.grey950,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Timeline.tileBuilder(
                      shrinkWrap: true,
                      // physics: const NeverScrollableScrollPhysics(),
                      theme: TimelineThemeData(
                        nodePosition: 0,
                      ),
                      padding: const EdgeInsets.only(top: 10),
                      builder: TimelineTileBuilder.connected(
                        contentsAlign: ContentsAlign.basic,
                        indicatorBuilder: (context, index) {
                          return index == 0 ? SvgPicture.asset("assets/icon/ic_pick_up.svg") : SvgPicture.asset("assets/icon/ic_drop_in.svg");
                        },
                        connectorBuilder: (context, index, connectorType) {
                          return DashedLineConnector(
                            color: themeChange.isDarkTheme() ? AppThemData.grey600 : AppThemData.grey300,
                          );
                        },
                        contentsBuilder: (context, index) => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              focusNode: index == 0 ? controller.pickUpFocusNode : controller.dropFocusNode,
                              cursorColor: AppThemData.primary500,
                              readOnly: true,
                              controller: index == 0 ? controller.pickupLocationController : controller.dropLocationController,
                              onTap: () {
                                index == 0 ? controller.pickUpFocusNode.requestFocus() : controller.dropFocusNode.requestFocus();
                                Constant.selectedMap == "Google Map"
                                    ? Get.to(LocationPickerScreen())!.then((value) {
                                        if (value != null) {
                                          SelectedLocationModel selectedLocationModel = value;

                                          String formattedAddress = "${selectedLocationModel.address?.street ?? ''}, "
                                              "${selectedLocationModel.address?.subLocality}, "
                                              "${selectedLocationModel.address?.locality ?? ''}, "
                                              "${selectedLocationModel.address?.administrativeArea}, "
                                              "${selectedLocationModel.address?.postalCode} "
                                              "${selectedLocationModel.address?.country ?? ''}";

                                          if (index == 0) {
                                            controller.sourceLocation = selectedLocationModel.latLng;
                                            controller.pickupLocationController.text = formattedAddress;
                                            log("Pickup Location :: ${controller.sourceLocation}");
                                          } else {
                                            // controller.isFetchingDropLatLng.value = true;
                                            controller.destination = selectedLocationModel.latLng;
                                            controller.dropLocationController.text = formattedAddress;
                                            log("Drop Location :: ${controller.destination}");
                                            // controller.isFetchingDropLatLng.value = false;
                                            // controller.updateData();
                                          }
                                        } else {
                                          Future.delayed(Duration(milliseconds: 100), () {
                                            index == 0 ? controller.pickUpFocusNode.requestFocus() : controller.dropFocusNode.requestFocus();
                                          });
                                        }
                                      })
                                    : Get.to(OSMLocationPickerScreen())!.then((value) {
                                        if (value != null) {
                                          OsmSelectedLocationModel osmSelectedLocationModel = value;

                                          String formattedAddress = "${osmSelectedLocationModel.address?.street ?? ''}, "
                                              "${osmSelectedLocationModel.address?.subLocality}, "
                                              "${osmSelectedLocationModel.address?.locality ?? ''}, "
                                              "${osmSelectedLocationModel.address?.administrativeArea}, "
                                              "${osmSelectedLocationModel.address?.postalCode} "
                                              "${osmSelectedLocationModel.address?.country ?? ''}";

                                          if (index == 0) {
                                            controller.osmSourceLocation = osmSelectedLocationModel.latLng;
                                            controller.pickupLocationController.text = formattedAddress;
                                            log("Pickup Location :: ${controller.osmSourceLocation}");
                                          } else {
                                            // controller.isFetchingDropLatLng.value = true;
                                            controller.osmDestination = osmSelectedLocationModel.latLng;
                                            controller.dropLocationController.text = formattedAddress;
                                            log("Drop Location :: ${controller.osmDestination}");
                                            // controller.isFetchingDropLatLng.value = false;
                                            // controller.updateData();
                                          }
                                        } else {
                                          Future.delayed(Duration(milliseconds: 100), () {
                                            index == 0 ? controller.pickUpFocusNode.requestFocus() : controller.dropFocusNode.requestFocus();
                                          });
                                        }
                                      });
                              },
                              decoration: InputDecoration(
                                hintText: index == 0 ? "Pick up Location".tr : "Destination Location".tr,
                                filled: true,
                                fillColor: themeChange.isDarkTheme() ? AppThemData.grey950 : AppThemData.grey25,
                                focusColor: AppThemData.primary500,
                                suffixIcon: (index == 0 ? controller.pickupLocationController.text.isNotEmpty : controller.pickupLocationController.text.isNotEmpty)
                                    ? InkWell(
                                        onTap: () {
                                          if (index == 0) {
                                            controller.sourceLocation = null;
                                            controller.pickupLocationController.clear();
                                            controller.searchIntercityList.clear();
                                            log('==========> Pickup Location Cleared');
                                          } else {
                                            controller.destination = null;
                                            controller.dropLocationController.clear();
                                            log('==========> Drop Location Cleared');
                                            // controller.updateData();
                                            // controller.polyLines.clear();
                                          }
                                        },
                                        child: const Icon(Icons.close),
                                      )
                                    : null,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(100), borderSide: BorderSide(color: themeChange.isDarkTheme() ? AppThemData.grey950 : AppThemData.grey25)),
                                disabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(100), borderSide: BorderSide(color: themeChange.isDarkTheme() ? AppThemData.grey950 : AppThemData.grey25)),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(100), borderSide: BorderSide(color: themeChange.isDarkTheme() ? AppThemData.grey950 : AppThemData.grey25)),
                                errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(100), borderSide: BorderSide(color: themeChange.isDarkTheme() ? AppThemData.grey950 : AppThemData.grey25)),
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100), borderSide: BorderSide(color: AppThemData.primary500)),
                                focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(100), borderSide: BorderSide(color: themeChange.isDarkTheme() ? AppThemData.grey950 : AppThemData.grey25)),
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
                            )
                            // GooglePlaceAutoCompleteTextFieldOnlyCity(
                            //   textEditingController: index == 0 ? controller.pickupLocationController : controller.dropLocationController,
                            //   googleAPIKey: Constant.mapAPIKey,
                            //   boxDecoration: BoxDecoration(
                            //     color: themeChange.isDarkTheme() ? AppThemData.grey800 : AppThemData.white,
                            //     borderRadius: BorderRadius.circular(100),
                            //   ),
                            //   inputDecoration: InputDecoration(
                            //     hintText: index == 0 ? "Pick up Location".tr : "Destination Location".tr,
                            //     border: InputBorder.none,
                            //     disabledBorder: InputBorder.none,
                            //     enabledBorder: InputBorder.none,
                            //     errorBorder: InputBorder.none,
                            //     focusedBorder: InputBorder.none,
                            //     focusedErrorBorder: InputBorder.none,
                            //     hintStyle: GoogleFonts.inter(
                            //       color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                            //       fontSize: 16,
                            //       fontWeight: FontWeight.w500,
                            //     ),
                            //   ),
                            //   textStyle: GoogleFonts.inter(
                            //     color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                            //     fontSize: 16,
                            //     fontWeight: FontWeight.w500,
                            //   ),
                            //   clearData: () {
                            //     if (index == 0) {
                            //       controller.sourceLocation = null;
                            //       controller.pickupLocationController.clear();
                            //       controller.searchParcelList.clear();
                            //       log('==========>Parcel Pickup Location Cleared');
                            //       // controller.updateData();
                            //       // controller.polyLines.clear();
                            //     } else {
                            //       controller.destination = null;
                            //       controller.dropLocationController.clear();
                            //       log('==========>Parcel Drop Location Cleared');
                            //       // controller.updateData();
                            //       // controller.polyLines.clear();
                            //     }
                            //   },
                            //   debounceTime: 800,
                            //   isLatLngRequired: true,
                            //   focusNode: index == 0 ? controller.pickUpFocusNode : controller.dropFocusNode,
                            //   getPlaceDetailWithLatLng: (Prediction prediction) {
                            //     if (index == 0) {
                            //       controller.sourceLocation = LatLng(double.parse(prediction.lat ?? '0.00'), double.parse(prediction.lng ?? '0.00'));
                            //       controller.parcelPickUpAddress.value = prediction.description!;
                            //
                            //       // controller.updateData();
                            //     } else {
                            //       controller.destination = LatLng(double.parse(prediction.lat ?? '0.00'), double.parse(prediction.lng ?? '0.00'));
                            //       controller.parcelDropAddress.value = prediction.description!;
                            //
                            //       // controller.updateData();
                            //     }
                            //   },
                            //   itemClick: (postalCodeResponse) {
                            //     if (index == 0) {
                            //       controller.pickupLocationController.text = postalCodeResponse.description ?? '';
                            //     } else {
                            //       controller.dropLocationController.text = postalCodeResponse.description ?? '';
                            //     }
                            //   },
                            //   itemBuilder: (context, index, Prediction prediction) {
                            //     return Container(
                            //       padding: const EdgeInsets.all(10),
                            //       color: themeChange.isDarkTheme() ? AppThemData.black : AppThemData.white,
                            //       child: Row(
                            //         children: [
                            //           Icon(
                            //             Icons.location_on,
                            //             color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                            //           ),
                            //           const SizedBox(
                            //             width: 7,
                            //           ),
                            //           Expanded(
                            //               child: Text(
                            //             prediction.description ?? "",
                            //             style: GoogleFonts.inter(
                            //               color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                            //               fontSize: 16,
                            //               fontWeight: FontWeight.w500,
                            //             ),
                            //           ))
                            //         ],
                            //       ),
                            //     );
                            //   },
                            //   seperatedBuilder: Container(),
                            //   isCrossBtnShown: true,
                            //   containerHorizontalPadding: 10,
                            // ),
                            ),
                        itemCount: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Select Date'.tr,
                          style: GoogleFonts.inter(
                            color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.grey950,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        InkWell(
                          onTap: () async {
                            final DateTime? selectedParcelDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 1000)),
                            );

                            if (selectedParcelDate != null) {
                              controller.selectedParcelDate.value = selectedParcelDate;
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            margin: const EdgeInsets.only(top: 4),
                            clipBehavior: Clip.antiAlias,
                            decoration: ShapeDecoration(
                              color: themeChange.isDarkTheme() ? AppThemData.grey900 : AppThemData.white,
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
                                    controller.selectedParcelDate.value == null ? "Select Date".tr : controller.selectedParcelDate.value!.dateMonthYear(),
                                    style: GoogleFonts.inter(
                                      color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.grey950,
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
                    const SizedBox(height: 16),
                    RoundShapeButton(
                      title: "Search".tr,
                      buttonColor: AppThemData.primary500,
                      buttonTextColor: AppThemData.black,
                      onTap: () async {
                        if (controller.pickupLocationController.value.text.isEmpty) {
                          return ShowToastDialog.toast('Enter pick up location ');
                        }

                        if (controller.dropLocationController.value.text.isNotEmpty) {
                          if (controller.destination == null) {
                            controller.searchParcelList.clear();
                            return ShowToastDialog.toast('Please Wait....');
                          }
                        }

                        controller.searchParcelList.clear();
                        controller.isSearchParcelCity.value = true;
                        await controller.fetchNearestParcelRide();
                        controller.isSearchParcelCity.value = false;
                        // controller.fetchNearestParcelRide();
                        // log('Filtered Results Count: ${controller.searchParcelList.length}');
                      },
                      size: Size(Responsive.width(100, context), 52),
                    ),
                    const SizedBox(height: 20),
                    controller.searchParcelList.isEmpty
                        ? controller.isSearchParcelCity.value == true
                            ? Constant.loader()
                            : Center(
                                child: Text('No Search Data'.tr,
                                    style: GoogleFonts.inter(
                                      color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    )),
                              )
                        : ListView.builder(
                            itemCount: controller.searchParcelList.length,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              ParcelModel parcelModel = controller.searchParcelList[index];
                              return GestureDetector(
                                onTap: () {},
                                child: Container(
                                  width: Responsive.width(100, context),
                                  padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
                                  margin: const EdgeInsets.only(top: 12, left: 0, right: 0),
                                  decoration: ShapeDecoration(
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(width: 1, color: themeChange.isDarkTheme() ? AppThemData.grey800 : AppThemData.grey100),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
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
                                            parcelModel.bookingTime == null ? "" : parcelModel.bookingTime!.toDate().dateMonthYear(),
                                            style: GoogleFonts.inter(
                                              color: themeChange.isDarkTheme() ? AppThemData.grey400 : AppThemData.grey500,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            height: 15,
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
                                          Expanded(
                                            child: Text(
                                              parcelModel.bookingTime == null ? "" : parcelModel.bookingTime!.toDate().time(),
                                              style: GoogleFonts.inter(
                                                color: themeChange.isDarkTheme() ? AppThemData.grey400 : AppThemData.grey500,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          GestureDetector(
                                            onTap: () {
                                              Get.to(
                                                ParcelBookingDetailsView(),
                                                arguments: {
                                                  "bookingId": parcelModel.id ?? '',
                                                  "isSearch": true,
                                                },
                                              );
                                            },
                                            child: Icon(
                                              Icons.keyboard_arrow_right_sharp,
                                              color: themeChange.isDarkTheme() ? AppThemData.grey400 : AppThemData.grey500,
                                            ),
                                          )
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Container(
                                        padding: const EdgeInsets.only(bottom: 12),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            FutureBuilder<UserModel?>(
                                              future: FireStoreUtils.getUserProfile(parcelModel.customerId ?? ''),
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState == ConnectionState.waiting) {
                                                  return Center(
                                                    child: CustomLoader(),
                                                  );
                                                }

                                                if (!snapshot.hasData || snapshot.data == null) {
                                                  return Container();
                                                }
                                                UserModel customerModel = snapshot.data ?? UserModel();
                                                return Container(
                                                  width: 60,
                                                  height: 60,
                                                  margin: const EdgeInsets.only(right: 10),
                                                  clipBehavior: Clip.antiAlias,
                                                  decoration: ShapeDecoration(
                                                    color: themeChange.isDarkTheme() ? AppThemData.grey950 : AppThemData.white,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(200),
                                                    ),
                                                  ),
                                                  child: CachedNetworkImage(
                                                    imageUrl: (customerModel.profilePic != null && customerModel.profilePic!.isNotEmpty)
                                                        ? customerModel.profilePic!
                                                        : Constant.profileConstant,
                                                    fit: BoxFit.cover,
                                                    placeholder: (context, url) => Center(
                                                      child: CustomLoader(),
                                                    ),
                                                    errorWidget: (context, url, error) => Image.asset(Constant.userPlaceHolder),
                                                  ),
                                                );
                                              },
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'ID: ${parcelModel.id!.substring(0, 5)}',
                                                    style: GoogleFonts.inter(
                                                      color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    'Ride Start Date: ${Constant.formatDate(Constant.parseDate(parcelModel.startDate))}',
                                                    style: GoogleFonts.inter(
                                                      color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                                  ),
                                                  // Text(
                                                  //   (bookingModel.paymentStatus ?? false) ? 'Payment is Completed'.tr : 'Payment is Pending'.tr,
                                                  //   style: GoogleFonts.inter(
                                                  //     color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                                  //     fontSize: 14,
                                                  //     fontWeight: FontWeight.w400,
                                                  //   ),
                                                  // ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  Constant.amountToShow(amount: Constant.calculateParcelFinalAmount(parcelModel).toString()),
                                                  // amount: Constant.calculateInterCityFinalAmount(bookingModel).toStringAsFixed(2)),
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
                                                    SvgPicture.asset("assets/icon/ic_weight.svg"),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      '${parcelModel.weight}',
                                                      style: GoogleFonts.inter(
                                                        color: AppThemData.primary500,
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w400,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          const SizedBox(height: 12),
                                          PickDropPointView(pickUpAddress: parcelModel.pickUpLocationAddress ?? '', dropAddress: parcelModel.dropLocationAddress ?? ''),
                                          const SizedBox(height: 16),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Constant.isParcelBid == false
                                                  ? parcelModel.bookingStatus == BookingStatus.bookingPlaced
                                                      ? Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            RoundShapeButton(
                                                              title: "Cancel Ride".tr,
                                                              buttonColor: AppThemData.danger500,
                                                              buttonTextColor: AppThemData.white,
                                                              onTap: () {
                                                                showDialog(
                                                                    context: context,
                                                                    builder: (BuildContext context) {
                                                                      return CustomDialogBox(
                                                                          themeChange: themeChange,
                                                                          title: "Cancel Ride".tr,
                                                                          negativeButtonColor: themeChange.isDarkTheme() ? AppThemData.grey950 : AppThemData.grey50,
                                                                          negativeButtonTextColor: themeChange.isDarkTheme() ? AppThemData.grey50 : AppThemData.grey950,
                                                                          positiveButtonColor: AppThemData.danger500,
                                                                          positiveButtonTextColor: AppThemData.grey25,
                                                                          descriptions: "Are you sure you want cancel this parcel?".tr,
                                                                          positiveString: "Cancel parcel".tr,
                                                                          negativeString: "Cancel".tr,
                                                                          positiveClick: () async {
                                                                            Navigator.pop(context);
                                                                            List rejectedId = parcelModel.rejectedDriverId ?? [];
                                                                            rejectedId.add(FireStoreUtils.getCurrentUid());
                                                                            parcelModel.bookingStatus = BookingStatus.bookingRejected;
                                                                            parcelModel.rejectedDriverId = rejectedId;
                                                                            parcelModel.updateAt = Timestamp.now();
                                                                            FireStoreUtils.setParcelBooking(parcelModel).then((value) async {
                                                                              if (value == true) {
                                                                                ShowToastDialog.showToast("Parcel cancelled successfully!".tr);
                                                                                controller.searchParcelList.removeAt(index);
                                                                                // DriverUserModel? driverModel =
                                                                                //     await FireStoreUtils.getDriverUserProfile(bookingModel!.driverId.toString());
                                                                                UserModel? receiverUserModel =
                                                                                    await FireStoreUtils.getUserProfile(parcelModel.customerId.toString());
                                                                                Map<String, dynamic> playLoad = <String, dynamic>{"bookingId": parcelModel.id};

                                                                                await SendNotification.sendOneNotification(
                                                                                    type: "order",
                                                                                    token: receiverUserModel!.fcmToken.toString(),
                                                                                    title: 'Your Parcel is Rejected',isBooking: false,
                                                                                    customerId: receiverUserModel.id,
                                                                                    senderId: FireStoreUtils.getCurrentUid(),
                                                                                    bookingId: parcelModel.id.toString(),
                                                                                    driverId: parcelModel.driverId.toString(),
                                                                                    body: 'Your parcel #${parcelModel.id.toString().substring(0, 5)} has been Rejected by Driver.',
                                                                                    // body: 'Your ride has been rejected by ${driverModel!.fullName}.',
                                                                                    payload: playLoad);
                                                                                Navigator.pop(context);
                                                                              } else {
                                                                                ShowToastDialog.showToast("Something went wrong!".tr);
                                                                                Navigator.pop(context);
                                                                              }
                                                                            });
                                                                          },
                                                                          negativeClick: () {
                                                                            Navigator.pop(context);
                                                                          },
                                                                          img: Image.asset(
                                                                            "assets/icon/ic_close.png",
                                                                            height: 58,
                                                                            width: 58,
                                                                          ));
                                                                    });
                                                              },
                                                              size: Size(Responsive.width(40, context), 42),
                                                            ),
                                                            SizedBox(
                                                              width: 4,
                                                            ),
                                                            RoundShapeButton(
                                                              title: "Accept".tr,
                                                              buttonColor: AppThemData.primary500,
                                                              buttonTextColor: AppThemData.black,
                                                              onTap: () {
                                                                if (double.parse(Constant.userModel!.walletAmount.toString()) >=
                                                                    double.parse(Constant.minimumAmountToAcceptRide.toString())) {
                                                                  showDialog(
                                                                    context: context,
                                                                    builder: (context) {
                                                                      return CustomDialogBox(
                                                                          title: "Confirm Parcel Request".tr,
                                                                          descriptions:
                                                                              "Are you sure you want to accept this ride request? Once confirmed, you will be directed to the next step to proceed with the ride."
                                                                                  .tr,
                                                                          img: Image.asset(
                                                                            "assets/icon/ic_green_right.png",
                                                                            height: 58,
                                                                            width: 58,
                                                                          ),
                                                                          positiveClick: () async {
                                                                            if (Constant.isSubscriptionEnable == true) {
                                                                              if (Constant.userModel!.subscriptionPlanId != null &&
                                                                                  Constant.userModel!.subscriptionPlanId!.isNotEmpty) {
                                                                                if (Constant.userModel!.subscriptionTotalBookings == '0') {
                                                                                  Navigator.pop(context);
                                                                                  showDialog(
                                                                                      context: context,
                                                                                      builder: (context) {
                                                                                        return SubscriptionAlertDialog(
                                                                                          title: "You can't accept more Rides.Upgrade your Plan.",
                                                                                          themeChange: themeChange,
                                                                                        );
                                                                                      });
                                                                                  // ShowToastDialog.showToast("You can't accept more Bookings.Upgrade your Plan.");
                                                                                  return;
                                                                                }
                                                                              }
                                                                              if (Constant.userModel!.subscriptionExpiryDate != null &&
                                                                                  Constant.userModel!.subscriptionExpiryDate!.toDate().isBefore(DateTime.now())) {
                                                                                Navigator.pop(context);
                                                                                showDialog(
                                                                                    context: context,
                                                                                    builder: (context) {
                                                                                      return SubscriptionAlertDialog(
                                                                                        title: "Your subscription has expired. Please renew your plan.",
                                                                                        themeChange: themeChange,
                                                                                      );
                                                                                    });
                                                                                // ShowToastDialog.showToast("Your subscription has expired. Please renew your plan.");
                                                                                return;
                                                                              }
                                                                            }
                                                                            await FireStoreUtils.getVehicleTypeById(
                                                                                Constant.userModel!.driverVehicleDetails!.vehicleTypeId.toString());
                                                                            parcelModel.driverVehicleDetails = Constant.userModel!.driverVehicleDetails;
                                                                            parcelModel.driverId = FireStoreUtils.getCurrentUid();
                                                                            parcelModel.bookingStatus = BookingStatus.bookingAccepted;
                                                                            parcelModel.updateAt = Timestamp.now();
                                                                            FireStoreUtils.setParcelBooking(parcelModel).then((value) async {
                                                                              if (value == true) {
                                                                                ShowToastDialog.showToast("Parcel accepted successfully!".tr);
                                                                                controller.searchParcelList.removeAt(index);
                                                                                UserModel? receiverUserModel =
                                                                                    await FireStoreUtils.getUserProfile(parcelModel.customerId.toString());
                                                                                Map<String, dynamic> playLoad = <String, dynamic>{"bookingId": parcelModel.id};

                                                                                if (Constant.isSubscriptionEnable == true &&
                                                                                    Constant.userModel!.subscriptionPlanId != null &&
                                                                                    Constant.userModel!.subscriptionPlanId!.isNotEmpty &&
                                                                                    Constant.userModel!.subscriptionTotalBookings != '0' &&
                                                                                    Constant.userModel!.subscriptionTotalBookings != '-1' &&
                                                                                    Constant.userModel!.subscriptionTotalBookings != null) {
                                                                                  int remainingBookings = int.parse(Constant.userModel!.subscriptionTotalBookings!) - 1;
                                                                                  Constant.userModel!.subscriptionTotalBookings = remainingBookings.toString();
                                                                                  await FireStoreUtils.updateDriverUser(Constant.userModel!);
                                                                                }

                                                                                await SendNotification.sendOneNotification(
                                                                                    type: "order",
                                                                                    token: receiverUserModel!.fcmToken.toString(),
                                                                                    title: 'Your Parcel is Accepted',isBooking: false,
                                                                                    customerId: receiverUserModel.id,
                                                                                    senderId: FireStoreUtils.getCurrentUid(),
                                                                                    bookingId: parcelModel.id.toString(),
                                                                                    driverId: parcelModel.driverId.toString(),
                                                                                    body: 'Your Parcel #${parcelModel.id.toString().substring(0, 5)} has been confirmed.',
                                                                                    payload: playLoad);
                                                                                if (context.mounted) {
                                                                                  Navigator.pop(context);
                                                                                }
                                                                              } else {
                                                                                ShowToastDialog.showToast("Something went wrong!".tr);
                                                                                Navigator.pop(context);
                                                                              }
                                                                            });
                                                                            Navigator.pop(context);
                                                                          },
                                                                          negativeClick: () {
                                                                            Navigator.pop(context);
                                                                          },
                                                                          positiveString: "Confirm".tr,
                                                                          negativeString: "Cancel".tr,
                                                                          themeChange: themeChange);
                                                                    },
                                                                  );
                                                                } else {
                                                                  ShowToastDialog.showToast("minimumAmountToAcceptRide"
                                                                      .trParams({"minimumAmountToAcceptRide": Constant.amountShow(amount: Constant.minimumAmountToAcceptRide)}));

                                                                  // ShowToastDialog.showToast(
                                                                  //     "You do not have sufficient wallet balance to accept the ride, as the minimum amount required is ${Constant.amountShow(amount: Constant.minimumAmountToAcceptRide)}.");
                                                                }
                                                              },
                                                              size: Size(Responsive.width(40, context), 42),
                                                            )
                                                          ],
                                                        )
                                                      : SizedBox()
                                                  : parcelModel.bookingStatus == BookingStatus.bookingPlaced
                                                      ? Expanded(
                                                          child: RoundShapeButton(
                                                            title: "Add Bid".tr,
                                                            buttonColor: AppThemData.primary500,
                                                            buttonTextColor: AppThemData.black,
                                                            onTap: () {
                                                              Get.to(
                                                                ParcelBookingDetailsView(),
                                                                arguments: {
                                                                  "bookingId": parcelModel.id ?? '',
                                                                  "isSearch": true,
                                                                },
                                                              );
                                                            },
                                                            size: const Size(double.infinity, 48),
                                                          ),
                                                        )
                                                      : parcelModel.bookingStatus == BookingStatus.bookingAccepted
                                                          ? RoundShapeButton(
                                                              title: "Cancel Ride".tr,
                                                              buttonColor: AppThemData.danger500,
                                                              buttonTextColor: AppThemData.white,
                                                              onTap: () {
                                                                showDialog(
                                                                    context: context,
                                                                    builder: (BuildContext context) {
                                                                      return CustomDialogBox(
                                                                          themeChange: themeChange,
                                                                          title: "Cancel Ride".tr,
                                                                          negativeButtonColor: themeChange.isDarkTheme() ? AppThemData.grey950 : AppThemData.grey50,
                                                                          negativeButtonTextColor: themeChange.isDarkTheme() ? AppThemData.grey50 : AppThemData.grey950,
                                                                          positiveButtonColor: AppThemData.danger500,
                                                                          positiveButtonTextColor: AppThemData.grey25,
                                                                          descriptions: "Are you sure you want cancel this ride?".tr,
                                                                          positiveString: "Cancel Ride".tr,
                                                                          negativeString: "Cancel".tr,
                                                                          positiveClick: () async {
                                                                            Navigator.pop(context);
                                                                            List rejectedId = parcelModel.rejectedDriverId ?? [];
                                                                            rejectedId.add(FireStoreUtils.getCurrentUid());
                                                                            parcelModel.bookingStatus = BookingStatus.bookingRejected;
                                                                            parcelModel.rejectedDriverId = rejectedId;
                                                                            parcelModel.updateAt = Timestamp.now();
                                                                            FireStoreUtils.setParcelBooking(parcelModel).then((value) async {
                                                                              if (value == true) {
                                                                                ShowToastDialog.showToast("Ride cancelled successfully!".tr);
                                                                                // DriverUserModel? driverModel =
                                                                                //     await FireStoreUtils.getDriverUserProfile(bookingModel!.driverId.toString());
                                                                                UserModel? receiverUserModel =
                                                                                    await FireStoreUtils.getUserProfile(parcelModel.customerId.toString());
                                                                                Map<String, dynamic> playLoad = <String, dynamic>{"bookingId": parcelModel.id};
                                                                                await SendNotification.sendOneNotification(
                                                                                    type: "order",
                                                                                    token: receiverUserModel!.fcmToken.toString(),
                                                                                    title: 'Your Ride is Rejected',isBooking: false,
                                                                                    customerId: receiverUserModel.id,
                                                                                    senderId: FireStoreUtils.getCurrentUid(),
                                                                                    bookingId: parcelModel.id.toString(),
                                                                                    driverId: parcelModel.driverId.toString(),
                                                                                    body: 'Your ride #${parcelModel.id.toString().substring(0, 5)} has been Rejected by Driver.',
                                                                                    // body: 'Your ride has been rejected by ${driverModel!.fullName}.',
                                                                                    payload: playLoad);

                                                                                Navigator.pop(context);
                                                                              } else {
                                                                                ShowToastDialog.showToast("Something went wrong!".tr);
                                                                                Navigator.pop(context);
                                                                              }
                                                                            });
                                                                          },
                                                                          negativeClick: () {
                                                                            Navigator.pop(context);
                                                                          },
                                                                          img: Image.asset(
                                                                            "assets/icon/ic_close.png",
                                                                            height: 58,
                                                                            width: 58,
                                                                          ));
                                                                    });
                                                              },
                                                              size: Size(Responsive.width(79, context), 42),
                                                            )
                                                          : SizedBox(),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                  ],
                ),
              ),
            ),
          );
        });
  }
}

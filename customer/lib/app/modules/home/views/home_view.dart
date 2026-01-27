// ignore_for_file: must_be_immutable, deprecated_member_use, use_build_context_synchronously
import 'package:cached_network_image/cached_network_image.dart';
import 'package:customer/app/modules/book_parcel/views/book_parcel_view.dart';
import 'package:customer/app/modules/cab_ride_details/views/cab_ride_details_view.dart';
import 'package:customer/app/modules/cab_rides/views/cab_ride_view.dart';
import 'package:customer/app/modules/chat_screen/views/chat_screen_view.dart';
import 'package:customer/app/modules/emergency_contacts/views/emergency_contacts_view.dart';
import 'package:customer/app/modules/home/views/widgets/drawer_view.dart';
import 'package:customer/app/modules/html_view_screen/views/html_view_screen_view.dart';
import 'package:customer/app/modules/inbox_screen/views/inbox_screen_view.dart';
import 'package:customer/app/modules/intercity_rides/views/intercity_rides_view.dart';
import 'package:customer/app/modules/language/views/language_view.dart';
import 'package:customer/app/modules/loyalty_point_screen/views/loyalty_point_screen_view.dart';
import 'package:customer/app/modules/my_wallet/views/my_wallet_view.dart';
import 'package:customer/app/modules/notification/views/notification_view.dart';
import 'package:customer/app/modules/parcel_rides/views/parcel_rides_view.dart';
import 'package:customer/app/modules/referral_screen/views/referral_screen_view.dart';
import 'package:customer/app/modules/rental_location/views/rental_select_location_view.dart';
import 'package:customer/app/modules/rental_rides/views/rental_rides_view.dart';
import 'package:customer/app/modules/select_location/views/select_location_view.dart';
import 'package:customer/app/modules/sos_request/views/sos_request_view.dart';
import 'package:customer/app/modules/start_intercity/views/start_intercity_view.dart';
import 'package:customer/app/modules/statement_screen/views/statement_view.dart';
import 'package:customer/app/modules/support_screen/views/support_screen_view.dart';
import 'package:customer/constant/booking_status.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant_widgets/custom_dialog_box.dart';
import 'package:customer/constant_widgets/no_rides_view.dart';
import 'package:customer/extension/date_time_extension.dart';
import 'package:customer/theme/app_them_data.dart';
import 'package:customer/theme/responsive.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as osm;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart' as latlang;
import 'package:provider/provider.dart';
import '../controllers/home_controller.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetBuilder<HomeController>(
        init: HomeController(),
        builder: (controller) {
          return Scaffold(
              backgroundColor: themeChange.isDarkTheme() ? Color(0xff1D1D21) : AppThemData.grey50,
              extendBody: true,
              appBar: AppBar(
                backgroundColor: themeChange.isDarkTheme() ? AppThemData.black : AppThemData.white,
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
                        Get.to(const NotificationView());
                      },
                      icon: const Icon(Icons.notifications_none_rounded))
                ],
              ),
              drawer: const DrawerView(),
              body: Obx(() => controller.drawerIndex.value == 0
                  ? HomeScreenView()
                  : controller.drawerIndex.value == 1
                      ? const CabRideView()
                      : controller.drawerIndex.value == 2
                          ? const MyWalletView()
                          : controller.drawerIndex.value == 3
                              ? const SupportScreenView()
                              : controller.drawerIndex.value == 4
                                  ? HtmlViewScreenView(title: "Privacy & Policy".tr, htmlData: Constant.privacyPolicy)
                                  : controller.drawerIndex.value == 5
                                      ? HtmlViewScreenView(title: "Terms & Condition".tr, htmlData: Constant.termsAndConditions)
                                      : controller.drawerIndex.value == 6
                                          ? const LanguageView()
                                          : controller.drawerIndex.value == 7
                                              ? InterCityRidesView()
                                              : controller.drawerIndex.value == 8
                                                  ? ParcelRidesView()
                                                  : controller.drawerIndex.value == 9
                                                      ? StatementView()
                                                      : controller.drawerIndex.value == 10
                                                          ? RentalRidesView()
                                                          : controller.drawerIndex.value == 11
                                                              ? ReferralScreenView()
                                                              : controller.drawerIndex.value == 12
                                                                  ? InboxScreenView()
                                                                  : controller.drawerIndex.value == 13
                                                                      ? LoyaltyPointScreenView()
                                                                      : controller.drawerIndex.value == 14
                                                                          ? EmergencyContactsView()
                                                                          : SosRequestView()));
        });
  }
}

class HomeScreenView extends StatelessWidget {
  const HomeScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: HomeController(),
        builder: (controller) {
          return controller.isLoading.value
              ? Constant.loader()
              : Constant.isHomeFeatureEnable
                  ? HomeMapView()
                  : SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 14),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
                              child: InkWell(
                                onTap: () async {
                                  if (controller.userModel.value.activeRideId != null && controller.userModel.value.activeRideId!.isNotEmpty) {
                                    controller.showActiveRideDialog(context, themeChange);
                                  } else {
                                    Get.to(const SelectLocationView());
                                  }
                                },
                                child: Container(
                                  width: Responsive.width(100, context),
                                  height: 56,
                                  padding: const EdgeInsets.all(16),
                                  decoration: ShapeDecoration(
                                    color: themeChange.isDarkTheme() ? AppThemData.black : AppThemData.white,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(width: 1, color: themeChange.isDarkTheme() ? AppThemData.grey900 : AppThemData.grey50),
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.search_rounded,
                                        color: themeChange.isDarkTheme() ? AppThemData.grey400 : AppThemData.grey500,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          "Where to?".tr,
                                          style: GoogleFonts.inter(
                                            color: themeChange.isDarkTheme() ? AppThemData.grey400 : AppThemData.grey500,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            if ((controller.intercityPersonalDocuments.isNotEmpty && controller.intercityPersonalDocuments.first.isAvailable) ||
                                (controller.intercitySharingDocuments.isNotEmpty && controller.intercitySharingDocuments.first.isAvailable) ||
                                (controller.parcelDocuments.isNotEmpty && controller.parcelDocuments.first.isAvailable))
                              SuggestionRow(controller: controller),
                            const SizedBox(height: 24),
                            Text(
                              "Your Rides".tr,
                              style: GoogleFonts.inter(
                                color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            controller.bookingList.isEmpty
                                ? NoRidesView(
                                    themeChange: themeChange,
                                    height: Responsive.height(40, context),
                                    onTap: () {
                                      if (Constant.userModel!.activeRideId != null && Constant.userModel!.activeRideId!.isNotEmpty) {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return Dialog(
                                              child: ActiveRideDialog(themeChange: themeChange),
                                            );
                                          },
                                        );
                                      } else {
                                        Get.to(const SelectLocationView());
                                      }
                                    },
                                  )
                                : ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: controller.bookingList.length,
                                    itemBuilder: (context, index) {
                                      return Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              Get.to(const CabRideDetailsView(), arguments: {"bookingModel": controller.bookingList[index]});
                                            },
                                            child: Container(
                                              width: Responsive.width(100, context),
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color: themeChange.isDarkTheme() ? AppThemData.black : AppThemData.white,
                                                borderRadius: BorderRadius.circular(12),
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
                                                        controller.bookingList[index].bookingTime == null
                                                            ? ""
                                                            : controller.bookingList[index].bookingTime!.toDate().dateMonthYear(),
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
                                                          controller.bookingList[index].bookingTime == null ? "" : controller.bookingList[index].bookingTime!.toDate().time(),
                                                          style: GoogleFonts.inter(
                                                            color: themeChange.isDarkTheme() ? AppThemData.grey400 : AppThemData.grey500,
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.w400,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        BookingStatus.getBookingStatusTitle(controller.bookingList[index].bookingStatus ?? ''),
                                                        textAlign: TextAlign.right,
                                                        style: GoogleFonts.inter(
                                                          color: BookingStatus.getBookingStatusTitleColor(controller.bookingList[index].bookingStatus ?? ''),
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.w600,
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
                                                        CachedNetworkImage(
                                                          height: 60,
                                                          width: 60,
                                                          imageUrl: controller.bookingList[index].vehicleType == null
                                                              ? Constant.profileConstant
                                                              : controller.bookingList[index].vehicleType!.image.toString(),
                                                        ),
                                                        const SizedBox(width: 12),
                                                        Expanded(
                                                          child: Column(
                                                            mainAxisSize: MainAxisSize.min,
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text(
                                                                controller.bookingList[index].vehicleType == null
                                                                    ? ""
                                                                    : controller.bookingList[index].vehicleType!.title.toString(),
                                                                style: GoogleFonts.inter(
                                                                  color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                                                  fontSize: 16,
                                                                  fontWeight: FontWeight.w600,
                                                                ),
                                                              ),
                                                              const SizedBox(height: 2),
                                                              if (controller.bookingList[index].bookingStatus == BookingStatus.bookingAccepted &&
                                                                  controller.bookingList[index].otp != null &&
                                                                  controller.bookingList[index].otp!.isNotEmpty)
                                                                Row(
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: [
                                                                    Text(
                                                                      "OTP: ".tr,
                                                                      style: GoogleFonts.inter(
                                                                        color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                                                        fontSize: 14,
                                                                        fontWeight: FontWeight.w400,
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      child: FittedBox(
                                                                        fit: BoxFit.scaleDown,
                                                                        alignment: Alignment.centerLeft,
                                                                        child: Row(
                                                                          children: controller.bookingList[index].otp!
                                                                              .split('')
                                                                              .map(
                                                                                (digit) => Container(
                                                                                  height: 20,
                                                                                  width: 18,
                                                                                  margin: const EdgeInsets.symmetric(horizontal: 2),
                                                                                  alignment: Alignment.center,
                                                                                  decoration: BoxDecoration(
                                                                                    borderRadius: BorderRadius.circular(4),
                                                                                    border: Border.all(
                                                                                      color: AppThemData.grey500,
                                                                                    ),
                                                                                  ),
                                                                                  child: Text(
                                                                                    digit,
                                                                                    style: GoogleFonts.inter(
                                                                                      color: AppThemData.primary500,
                                                                                      fontSize: 14,
                                                                                      fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              )
                                                                              .toList(),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                )
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
                                                              Constant.amountToShow(amount: Constant.calculateFinalAmount(controller.bookingList[index]).toStringAsFixed(2)),
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
                                                                SvgPicture.asset(
                                                                  "assets/icon/ic_multi_person.svg",
                                                                ),
                                                                const SizedBox(width: 6),
                                                                Text(
                                                                  controller.bookingList[index].vehicleType == null
                                                                      ? ""
                                                                      : controller.bookingList[index].vehicleType!.persons.toString(),
                                                                  style: GoogleFonts.inter(
                                                                    color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
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
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                        ],
                                      );
                                    },
                                  ),
                            const SizedBox(height: 12),
                            BannerView(),
                          ],
                        ),
                      ),
                    );
        });
  }
}

class HomeMapView extends StatelessWidget {
  const HomeMapView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
      init: HomeController(),
      builder: (controller) {
        return Stack(
          children: [
            Constant.selectedMap == "Google Map"
                ? GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        controller.currentLocation?.latitude ?? 0.0,
                        controller.currentLocation?.longitude ?? 0.0,
                      ),
                      zoom: 14,
                    ),
                    padding: const EdgeInsets.only(
                      top: 22.0,
                    ),
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    polylines: Set<Polyline>.of(controller.googlePolylines.values),
                    markers: Set<Marker>.of(controller.googleMarkers.values),
                    onMapCreated: (GoogleMapController mapController) {
                      controller.googleMapController = mapController;
                    },
                  )
                : osm.FlutterMap(
                    mapController: controller.osmMapController,
                    options: osm.MapOptions(
                      initialCenter: latlang.LatLng(controller.currentLocation!.latitude!, controller.currentLocation!.longitude!),
                      initialZoom: 14,
                    ),
                    children: [
                      osm.TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
                      if (controller.osmRoute.isNotEmpty)
                        osm.PolylineLayer(
                          polylines: [
                            osm.Polyline(points: controller.osmRoute.toList(), strokeWidth: 4, color: AppThemData.primary500),
                          ],
                        ),
                      osm.MarkerLayer(markers: controller.osmMarkers.toList()),
                    ],
                  ),
            if (Constant.userModel!.activeRideId != null &&
                Constant.userModel!.activeRideId!.isNotEmpty &&
                (controller.bookingModel.value.bookingStatus == BookingStatus.bookingPlaced ||
                    controller.bookingModel.value.bookingStatus == BookingStatus.driverAssigned ||
                    controller.bookingModel.value.bookingStatus == BookingStatus.bookingAccepted ||
                    controller.bookingModel.value.bookingStatus == BookingStatus.bookingOngoing ||
                    controller.bookingModel.value.bookingStatus == BookingStatus.bookingOnHold))
              Container(
                margin: EdgeInsets.all(12),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(color: themeChange.isDarkTheme() ? AppThemData.black : AppThemData.white, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        Get.to(const CabRideDetailsView(), arguments: {"bookingModel": controller.bookingModel.value});
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            controller.bookingModel.value.bookingTime == null ? "" : controller.bookingModel.value.bookingTime!.toDate().dateMonthYear(),
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
                              controller.bookingModel.value.bookingTime == null ? "" : controller.bookingModel.value.bookingTime!.toDate().time(),
                              style: GoogleFonts.inter(
                                color: themeChange.isDarkTheme() ? AppThemData.grey400 : AppThemData.grey500,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.keyboard_arrow_right_sharp,
                            color: themeChange.isDarkTheme() ? AppThemData.grey400 : AppThemData.grey500,
                          )
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        CachedNetworkImage(
                          imageUrl: controller.bookingModel.value.vehicleType == null ? Constant.profileConstant : controller.bookingModel.value.vehicleType!.image.toString(),
                          fit: BoxFit.cover,
                          height: 50,
                          width: 50,
                          placeholder: (context, url) => Constant.loader(),
                          errorWidget: (context, url, error) => Image.asset(Constant.userPlaceHolder),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                controller.bookingModel.value.vehicleType == null ? "" : controller.bookingModel.value.vehicleType!.title.toString(),
                                style: GoogleFonts.inter(
                                  color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              controller.bookingModel.value.bookingStatus == BookingStatus.bookingPlaced ||
                                      controller.bookingModel.value.bookingStatus == BookingStatus.driverAssigned
                                  ? Text(
                                      "Wait for the Driver".tr,
                                      style: GoogleFonts.inter(
                                        color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    )
                                  : (controller.bookingModel.value.bookingStatus == BookingStatus.bookingAccepted ||
                                          controller.bookingModel.value.bookingStatus == BookingStatus.bookingOngoing ||
                                          controller.bookingModel.value.bookingStatus == BookingStatus.bookingOnHold)
                                      ? Text(
                                          controller.driverUserModel.value.fullName.toString(),
                                          style: GoogleFonts.inter(
                                            color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        )
                                      : SizedBox(),
                              Visibility(
                                visible: controller.bookingModel.value.bookingStatus == BookingStatus.bookingAccepted &&
                                    controller.bookingModel.value.otp != null &&
                                    controller.bookingModel.value.otp!.isNotEmpty,
                                child: Row(
                                  children: controller.bookingModel.value.otp!
                                      .split('')
                                      .map(
                                        (digit) => Container(
                                          height: 24,
                                          width: 22,
                                          margin: EdgeInsets.symmetric(horizontal: 2),
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(
                                              color: AppThemData.grey500,
                                            ),
                                          ),
                                          child: Text(
                                            digit,
                                            style: GoogleFonts.inter(
                                              color: AppThemData.primary500,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ).paddingOnly(top: 8),
                              controller.bookingModel.value.bookingStatus != BookingStatus.bookingPlaced ||
                                      controller.bookingModel.value.bookingStatus != BookingStatus.driverAssigned
                                  ? Obx(() {
                                      return Container(
                                        margin: const EdgeInsets.only(top: 6),
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppThemData.primary50,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.access_time, size: 16, color: AppThemData.primary500),
                                            const SizedBox(width: 6),
                                            Text(
                                              "${controller.etaInMinutes.value} min",
                                              style: GoogleFonts.inter(
                                                color: AppThemData.primary500,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              "(${DateFormat.jm().format(
                                                DateTime.now().add(
                                                  Duration(minutes: controller.etaInMinutes.value),
                                                ),
                                              )})",
                                              style: GoogleFonts.inter(
                                                color: AppThemData.grey600,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    })
                                  : SizedBox(),
                            ],
                          ),
                        ),
                        if ((controller.bookingModel.value.bookingStatus ?? '') != BookingStatus.bookingPlaced &&
                            (controller.bookingModel.value.bookingStatus ?? '') != BookingStatus.driverAssigned &&
                            (controller.bookingModel.value.driverId ?? '').isNotEmpty)
                          Row(
                            children: [
                              InkWell(
                                  onTap: () {
                                    Get.to(ChatScreenView(
                                      receiverId: controller.driverUserModel.value.id ?? '',
                                    ));
                                  },
                                  child: SvgPicture.asset("assets/icon/ic_message.svg", height: 32)),
                              const SizedBox(width: 8),
                              InkWell(
                                  onTap: () {
                                    Constant().launchCall("${controller.driverUserModel.value.countryCode}${controller.driverUserModel.value.phoneNumber}");
                                  },
                                  child: SvgPicture.asset("assets/icon/ic_phone.svg", height: 32))
                            ],
                          )
                      ],
                    )
                  ],
                ),
              ),
            homeMapBottomSheet(context, controller)
          ],
        );
      },
    );
  }

  Widget homeMapBottomSheet(
    BuildContext context,
    HomeController controller,
  ) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Positioned.fill(
      child: DraggableScrollableSheet(
        initialChildSize: controller.hasActiveRide ? 0.35 : 0.6,
        minChildSize: controller.hasActiveRide ? 0.25 : 0.3,
        maxChildSize: controller.hasActiveRide ? 0.5 : 0.8,
        expand: false,
        builder: (context, scrollController) {
          return GetX(
            init: HomeController(),
            builder: (controller) {
              return Container(
                decoration: BoxDecoration(
                  color: themeChange.isDarkTheme() ? AppThemData.black : AppThemData.white,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                ),
                padding: const EdgeInsets.only(top: 10, left: 16, right: 16, bottom: 0),
                child: controller.isLoading.value
                    ? Constant.loader()
                    : Column(
                        children: [
                          Container(
                            width: 44,
                            height: 5,
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: ShapeDecoration(
                              color: themeChange.isDarkTheme() ? AppThemData.grey700 : AppThemData.grey200,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              controller: scrollController,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
                                    child: InkWell(
                                      onTap: () async {
                                        bool isRideActive = await FireStoreUtils.hasActiveRide();
                                        if (isRideActive) {
                                          showDialog(
                                              context: context,
                                              builder: (context) {
                                                return Dialog(
                                                  child: ActiveRideDialog(
                                                    themeChange: themeChange,
                                                  ),
                                                );
                                              });
                                        } else {
                                          Get.to(const SelectLocationView());
                                        }
                                      },
                                      child: Container(
                                        height: 56,
                                        padding: const EdgeInsets.all(16),
                                        decoration: ShapeDecoration(
                                          color: themeChange.isDarkTheme() ? AppThemData.black : AppThemData.white,
                                          shape: RoundedRectangleBorder(
                                            side: BorderSide(width: 1, color: themeChange.isDarkTheme() ? AppThemData.grey900 : AppThemData.grey50),
                                            borderRadius: BorderRadius.circular(100),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.search_rounded,
                                              color: themeChange.isDarkTheme() ? AppThemData.grey400 : AppThemData.grey500,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                "Where to?".tr,
                                                style: GoogleFonts.inter(
                                                  color: themeChange.isDarkTheme() ? AppThemData.grey400 : AppThemData.grey500,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  if ((controller.intercityPersonalDocuments.isNotEmpty && controller.intercityPersonalDocuments.first.isAvailable) ||
                                      (controller.intercitySharingDocuments.isNotEmpty && controller.intercitySharingDocuments.first.isAvailable) ||
                                      (controller.parcelDocuments.isNotEmpty && controller.parcelDocuments.first.isAvailable))
                                    SuggestionRow(controller: controller),
                                  SizedBox(height: 12),
                                  BannerView(),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
              );
            },
          );
        },
      ),
    );
  }
}

class SuggestionRow extends StatelessWidget {
  final HomeController controller;

  const SuggestionRow({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    final List<Widget> suggestions = _buildSuggestions(themeChange);

    if (suggestions.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Suggestions".tr,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
          ),
        ),
        const SizedBox(height: 12),
        _SuggestionGrid(
          items: suggestions,
          themeChange: themeChange,
        ),
      ],
    );
  }

  List<Widget> _buildSuggestions(DarkThemeProvider themeChange) {
    return [
      if (Constant.isCabAvailable)
        SuggestionWidget(
          themeChange: themeChange,
          title: "Cab".tr,
          gifPath: "assets/icon/gif_daily.gif",
          onClick: () {
            if (controller.userModel.value.activeRideId?.isNotEmpty == true) {
              controller.showActiveRideDialog(Get.context!, themeChange);
            } else {
              Get.to(const SelectLocationView());
            }
          },
        ),
      if (controller.intercityPersonalDocuments.first.isAvailable || controller.intercitySharingDocuments.first.isAvailable)
        SuggestionWidget(
          themeChange: themeChange,
          title: "Intercity".tr,
          gifPath: "assets/icon/gif_intercity.gif",
          onClick: () {
            if (controller.userModel.value.activeRideId?.isNotEmpty == true) {
              controller.showActiveRideDialog(Get.context!, themeChange);
            } else {
              Get.to(const StartIntercityView());
            }
          },
        ),
      if (controller.parcelDocuments.first.isAvailable)
        SuggestionWidget(
          themeChange: themeChange,
          title: "Parcel".tr,
          gifPath: "assets/icon/gif_parcel.gif",
          onClick: () {
            if (controller.userModel.value.activeRideId?.isNotEmpty == true) {
              controller.showActiveRideDialog(Get.context!, themeChange);
            } else {
              Get.to(const BookParcelView());
            }
          },
        ),
      if (Constant.isRentalAvailable)
        SuggestionWidget(
          themeChange: themeChange,
          title: "Rental".tr,
          gifPath: "assets/icon/gif_rental.png",
          onClick: () {
            if (controller.userModel.value.activeRideId?.isNotEmpty == true) {
              controller.showActiveRideDialog(Get.context!, themeChange);
            } else {
              Get.to(const RentalLocationView());
            }
          },
        ),
    ];
  }
}

class _SuggestionGrid extends StatelessWidget {
  final List<Widget> items;
  final DarkThemeProvider themeChange;

  const _SuggestionGrid({required this.items, required this.themeChange});

  @override
  Widget build(BuildContext context) {
    final bool isScrollable = items.length > 3;

    const double separatorWidth = 10;
    const double fixedHeight = 110;

    return SizedBox(
      height: fixedHeight,
      child: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final double availableWidth = constraints.maxWidth;
              final double itemWidth = isScrollable ? availableWidth / 3.2 : (availableWidth - (separatorWidth * (items.length - 1))) / items.length;
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: isScrollable ? const BouncingScrollPhysics() : const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(width: separatorWidth),
                itemBuilder: (_, index) {
                  return SizedBox(
                    width: itemWidth,
                    child: items[index],
                  );
                },
              );
            },
          ),

          /// Optional subtle right-edge fade (scroll hint)
          if (isScrollable)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: IgnorePointer(
                child: Container(
                  width: 18,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(topRight: Radius.circular(12), bottomRight: Radius.circular(12)),
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.transparent,
                        themeChange.isDarkTheme() ? AppThemData.grey900 : Theme.of(context).scaffoldBackgroundColor.withOpacity(0.2),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class SuggestionWidget extends StatelessWidget {
  const SuggestionWidget({
    super.key,
    required this.themeChange,
    required this.title,
    required this.gifPath,
    required this.onClick,
  });

  final DarkThemeProvider themeChange;
  final String title;
  final String gifPath;
  final VoidCallback onClick;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onClick,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: themeChange.isDarkTheme() ? AppThemData.black : AppThemData.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: themeChange.isDarkTheme() ? AppThemData.grey900 : AppThemData.grey50,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(gifPath, width: 45, height: 45),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BannerView extends StatelessWidget {
  BannerView({
    super.key,
  });

  HomeController controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: Responsive.height(24, context),
            child: PageView.builder(
              itemCount: controller.bannerList.length,
              controller: controller.pageController,
              onPageChanged: (value) {
                controller.curPage.value = value;
              },
              itemBuilder: (context, index) {
                return Container(
                  width: Responsive.width(100, context),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: ShapeDecoration(
                    image: DecorationImage(image: NetworkImage(controller.bannerList[index].image ?? ""), fit: BoxFit.cover),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Container(
                    width: Responsive.width(100, context),
                    padding: const EdgeInsets.fromLTRB(16, 16, 20, 16),
                    decoration: ShapeDecoration(
                      color: AppThemData.black.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.bannerList[index].bannerName ?? '',
                          style: GoogleFonts.inter(
                            color: AppThemData.grey50,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          width: Responsive.width(100, context),
                          margin: const EdgeInsets.only(top: 6, bottom: 6),
                          child: Text(
                            controller.bannerList[index].bannerDescription ?? '',
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              color: AppThemData.grey50,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Visibility(
                          visible: controller.bannerList[index].isOfferBanner ?? false,
                          child: Text(
                            controller.bannerList[index].offerText ?? '',
                            style: GoogleFonts.inter(
                              color: AppThemData.primary500,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Center(
            child: SizedBox(
              height: 8,
              child: ListView.builder(
                itemCount: controller.bannerList.length,
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return Obx(
                    () => Container(
                      margin: const EdgeInsets.only(right: 10),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: index == controller.curPage.value ? AppThemData.primary500 : AppThemData.grey200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ignore_for_file: deprecated_member_use

import 'package:driver/app/models/booking_model.dart';
import 'package:driver/app/models/intercity_model.dart';
import 'package:driver/app/models/parcel_model.dart';
import 'package:driver/constant/booking_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:driver/theme/app_them_data.dart';
import 'package:driver/theme/responsive.dart';
import 'package:driver/utils/dark_theme_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:timelines_plus/timelines_plus.dart';

class PickDropPointView extends StatelessWidget {
  final String pickUpAddress;
  final String dropAddress;
  final bool isDirectionIconShown;
  final Function()? onDirectionTap;
  final BookingModel? bookingModel;
  final IntercityModel? intercityModel;
  final ParcelModel? parcelModel;
  final List<String>? stopAddress;

  const PickDropPointView({
    super.key,
    required this.pickUpAddress,
    required this.dropAddress,
    this.isDirectionIconShown = false,
    this.onDirectionTap,
    this.bookingModel,
    this.intercityModel,
    this.parcelModel,
    this.stopAddress,
  });

  bool _shouldShowDirectionIcon() {
    if (!isDirectionIconShown) return false;

    if (bookingModel != null) {
      return bookingModel!.bookingStatus == BookingStatus.driverAssigned ||
          bookingModel!.bookingStatus == BookingStatus.bookingAccepted ||
          bookingModel!.bookingStatus == BookingStatus.bookingOngoing;
    }

    if (intercityModel != null) {
      return intercityModel!.bookingStatus == BookingStatus.bookingAccepted || intercityModel!.bookingStatus == BookingStatus.bookingOngoing;
    }

    if (parcelModel != null) {
      return parcelModel!.bookingStatus == BookingStatus.bookingAccepted || parcelModel!.bookingStatus == BookingStatus.bookingOngoing;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    final points = <Map<String, String>>[];
    points.add({"title": "Pickup Point", "address": pickUpAddress});
    if (stopAddress != null && stopAddress!.isNotEmpty) {
      for (int i = 0; i < stopAddress!.length; i++) {
        points.add({"title": "Stop ${i + 1}", "address": stopAddress![i]});
      }
    }
    points.add({"title": "Dropout Point", "address": dropAddress});

    return Container(
      width: Responsive.width(100, context),
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: themeChange.isDarkTheme() ? AppThemData.primary950 : AppThemData.primary50,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Timeline.tileBuilder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              theme: TimelineThemeData(
                nodePosition: 0,
                indicatorPosition: 0,
              ),
              builder: TimelineTileBuilder.connected(
                contentsAlign: ContentsAlign.basic,
                indicatorBuilder: (context, index) {
                  if (index == 0) {
                    return SvgPicture.asset("assets/icon/ic_pick_up.svg");
                  } else if (index == points.length - 1) {
                    return SvgPicture.asset("assets/icon/ic_drop_in.svg");
                  } else {
                    return SvgPicture.asset("assets/icon/ic_stop_icon.svg", height: 20, color: AppThemData.primary500); // 👈 Add stop icon
                  }
                },
                connectorBuilder: (context, index, connectorType) {
                  return DashedLineConnector(
                    color: themeChange.isDarkTheme() ? AppThemData.grey600 : AppThemData.grey300,
                  );
                },
                contentsBuilder: (context, index) {
                  final point = points[index];
                  return Container(
                    margin: EdgeInsets.fromLTRB(12, 0, 12, index == points.length - 1 ? 12 : 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          point["title"]!,
                          style: GoogleFonts.inter(
                            color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          point["address"] ?? "",
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  );
                },
                itemCount: points.length,
              ),
            ),
          ),
          if (_shouldShowDirectionIcon())
            Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                    onTap: onDirectionTap,
                    child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: themeChange.isDarkTheme() ? AppThemData.blue.withOpacity(.3) : AppThemData.blue.withOpacity(.1),
                          shape: BoxShape.circle,
                        ),
                        child: SvgPicture.asset(
                          "assets/icon/ic_location.svg",
                          height: 20,
                          color: AppThemData.blueLight07,
                        )))),
        ],
      ),
    );
  }
}

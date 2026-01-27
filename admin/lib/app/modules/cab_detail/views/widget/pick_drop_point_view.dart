import 'package:admin/app/utils/app_them_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:admin/app/utils/app_colors.dart';
import 'package:admin/app/utils/dark_theme_provider.dart';
import 'package:admin/widget/text_widget.dart';
import 'package:provider/provider.dart';
import 'package:timelines_plus/timelines_plus.dart';

class PickDropPointView extends StatelessWidget {
  final String pickUpAddress;
  final String dropAddress;
  final List<String>? stopAddress;

  const PickDropPointView({
    super.key,
    required this.pickUpAddress,
    required this.dropAddress,
    this.stopAddress,
  });

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
      width: MediaQuery.of(context).size.width * 100,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: themeChange.isDarkTheme() ? AppThemData.primary950 : AppThemData.primary50,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Timeline.tileBuilder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        theme: TimelineThemeData(
          nodePosition: 0,
          indicatorPosition: 0,
        ),
        builder: TimelineTileBuilder.connected(
          contentsAlign: ContentsAlign.basic,
          indicatorBuilder: (context, index) {
            if (index == 0) {
              return SvgPicture.asset("assets/icons/ic_pick_up.svg");
            } else if (index == points.length - 1) {
              return SvgPicture.asset("assets/icons/ic_drop_in.svg");
            } else {
              return SvgPicture.asset("assets/icons/ic_stop_icon.svg", height: 20, color: AppThemData.primary500); // 👈 Add stop icon
            }
          },
          connectorBuilder: (context, index, connectorType) {
            return DashedLineConnector(color: themeChange.isDarkTheme() ? AppThemData.greyShade50 : AppThemData.greyShade950);
          },
          contentsBuilder: (context, index) {
            final point = points[index];
            return Container(
              margin: EdgeInsets.fromLTRB(12, 0, 12, index == points.length - 1 ? 12 : 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextCustom(
                    title: point["title"]!,
                    fontSize: 16,
                    fontFamily: AppThemeData.medium,
                    // style: GoogleFonts.inter(
                    //   color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                    //
                    //   fontWeight: FontWeight.w500,
                    // ),
                  ),
                  TextCustom(
                    title: point["address"] ?? "",
                    fontSize: 14,
                    fontFamily: AppThemeData.regular,
                    // overflow: TextOverflow.ellipsis,
                    // style: GoogleFonts.inter(
                    //   color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                    //   fontWeight: FontWeight.w400,
                    // ),
                  ),
                ],
              ),
            );
          },
          itemCount: points.length,
        ),
      ),
    );
  }
}

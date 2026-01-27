import 'package:cached_network_image/cached_network_image.dart';
import 'package:driver/app/models/user_model.dart';
import 'package:driver/app/modules/home/controllers/home_controller.dart';
import 'package:driver/app/modules/home/views/widgets/chart_view.dart';
import 'package:driver/app/modules/home/views/widgets/new_ride_view.dart';
import 'package:driver/app/routes/app_pages.dart';
import 'package:driver/constant_widgets/star_rating.dart';
import 'package:driver/theme/app_them_data.dart';
import 'package:driver/utils/dark_theme_provider.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../../constant/constant.dart' show Constant;

class CabRidesWidget extends StatelessWidget {
  const CabRidesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: HomeController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: themeChange.isDarkTheme()
                ? AppThemData.black
                : AppThemData.grey25,
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    controller.isLocationLoading.value
                        ? SizedBox()
                        : Visibility(
                            visible: controller.isOnline.value,
                            child: controller.bookingModel.value.id == null ||
                                    controller.bookingModel.value.id!.isEmpty
                                ? SizedBox()
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        "New Ride".tr,
                                        style: GoogleFonts.inter(
                                          color: themeChange.isDarkTheme()
                                              ? AppThemData.grey25
                                              : AppThemData.grey950,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          height: 0.08,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      NewRideView(
                                        bookingModel:
                                            controller.bookingModel.value,
                                      ),
                                      const SizedBox(height: 4),
                                    ],
                                  ),
                          ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Total Rides".tr,
                      style: GoogleFonts.inter(
                        color: themeChange.isDarkTheme()
                            ? AppThemData.grey25
                            : AppThemData.grey950,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ChartView(themeChange: themeChange),
                    const SizedBox(height: 16),
                    controller.reviewList.isNotEmpty
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  InkWell(
                                    onTap: () {},
                                    child: Text(
                                      "Customer Reviews".tr,
                                      style: GoogleFonts.inter(
                                        color: themeChange.isDarkTheme()
                                            ? AppThemData.grey25
                                            : AppThemData.grey950,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        height: 0.08,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Get.toNamed(Routes.REVIEW_SCREEN);
                                    },
                                    child: Text(
                                      "View all".tr,
                                      style: GoogleFonts.inter(
                                        color: AppThemData.primary500,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                height: 164,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: controller.reviewList.length >= 5
                                      ? 5
                                      : controller.reviewList.length,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      width: 210,
                                      padding: const EdgeInsets.all(16),
                                      margin: const EdgeInsets.only(right: 16),
                                      decoration: ShapeDecoration(
                                        color: themeChange.isDarkTheme()
                                            ? controller.colorDark[index % 4]
                                            : controller.color[index % 4],
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          FutureBuilder<UserModel?>(
                                            future:
                                                FireStoreUtils.getUserProfile(
                                                    controller.reviewList[index]
                                                        .customerId
                                                        .toString()),
                                            builder: (BuildContext context,
                                                AsyncSnapshot<UserModel?>
                                                    snapshot) {
                                              switch (
                                                  snapshot.connectionState) {
                                                case ConnectionState.waiting:
                                                  return const SizedBox();
                                                default:
                                                  if (snapshot.hasError) {
                                                    return Container(
                                                      width: 50,
                                                      height: 50,
                                                      clipBehavior:
                                                          Clip.antiAlias,
                                                      decoration:
                                                          ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      200),
                                                        ),
                                                        color:
                                                            AppThemData.white,
                                                        image:
                                                            const DecorationImage(
                                                          image: NetworkImage(
                                                              Constant
                                                                  .profileConstant),
                                                          fit: BoxFit.fill,
                                                        ),
                                                      ),
                                                    );
                                                  } else {
                                                    UserModel? userModel =
                                                        snapshot.data;
                                                    return ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              60),
                                                      child: CachedNetworkImage(
                                                        height: 50,
                                                        width: 50,
                                                        fit: BoxFit.cover,
                                                        imageUrl: userModel!
                                                            .profilePic
                                                            .toString(),
                                                        errorWidget: (context,
                                                            url, error) {
                                                          return Container(
                                                            width: 50,
                                                            height: 50,
                                                            clipBehavior:
                                                                Clip.antiAlias,
                                                            decoration:
                                                                ShapeDecoration(
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            200),
                                                              ),
                                                              color: AppThemData
                                                                  .white,
                                                              image:
                                                                  const DecorationImage(
                                                                image: NetworkImage(
                                                                    Constant
                                                                        .profileConstant),
                                                                fit:
                                                                    BoxFit.fill,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    );
                                                  }
                                              }
                                            },
                                          ),
                                          FutureBuilder<UserModel?>(
                                            future:
                                                FireStoreUtils.getUserProfile(
                                                    controller.reviewList[index]
                                                        .customerId
                                                        .toString()),
                                            builder: (BuildContext context,
                                                AsyncSnapshot<UserModel?>
                                                    snapshot) {
                                              switch (
                                                  snapshot.connectionState) {
                                                case ConnectionState.waiting:
                                                  return const SizedBox();
                                                default:
                                                  if (snapshot.hasError) {
                                                    return Text(
                                                      'Error: ${snapshot.error}',
                                                    );
                                                  } else {
                                                    UserModel? userModel =
                                                        snapshot.data;
                                                    return Text(
                                                      userModel!.fullName
                                                          .toString(),
                                                      style: GoogleFonts.inter(
                                                        color: themeChange
                                                                .isDarkTheme()
                                                            ? AppThemData.grey25
                                                            : AppThemData
                                                                .grey950,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    );
                                                  }
                                              }
                                            },
                                          ),
                                          const SizedBox(height: 4),
                                          StarRating(
                                            onRatingChanged: (rating) {},
                                            color: AppThemData.warning500,
                                            starCount: 5,
                                            rating: 4,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            controller.reviewList[index].comment
                                                .toString(),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.inter(
                                              color: themeChange.isDarkTheme()
                                                  ? AppThemData.grey25
                                                  : AppThemData.grey950,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          )
                        : SizedBox(),
                  ],
                ),
              ),
            ),
          );
        });
  }
}

import 'package:driver/app/modules/referral_screen/controllers/referral_screen_controller.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/constant_widgets/round_shape_button.dart';
import 'package:driver/constant_widgets/show_toast_dialog.dart';
import 'package:driver/theme/app_them_data.dart';
import 'package:driver/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class ReferralScreenView extends GetView<ReferralScreenController> {
  const ReferralScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
      init: ReferralScreenController(),
      builder: (controller) {
        return Scaffold(
            backgroundColor: themeChange.isDarkTheme() ? AppThemData.black : AppThemData.white,
            body: controller.isLoading.value
                ? Constant.loader()
                : Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery
                  .of(context)
                  .padding
                  .bottom + 14),
              child: Column(
                children: [
                  controller.referralModel.value.referralCode == null
                      ? Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Your Refer Code is not Created.".tr,
                                style:
                                GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 24,
                          ),
                          RoundShapeButton(
                              title: "Create Refer Code".tr,
                              buttonColor: AppThemData.primary500,
                              buttonTextColor: AppThemData.black,
                              onTap: () async {
                                controller.createReferEarnCode();
                              },
                              size: Size(210, 48)),
                        ],
                      ))
                      : Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Refer others & earn credits".tr,
                            style:
                            GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black),
                          ),
                          Text(
                            "Invite friends to use our app and earn exclusive rewards for every successful referral. Share the benefits today!".tr,
                            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: AppThemData.grey500),
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          Center(
                              child: Image.asset(
                                "assets/icon/gif_refer.gif",
                                height: 150,
                                width: 150,
                              )),
                          SizedBox(
                            height: 16,
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: RoundShapeButton(
                                    title: "${controller.referralModel.value.referralCode}",
                                    buttonColor: AppThemData.primary500,
                                    buttonTextColor: AppThemData.black,
                                    onTap: () {},
                                    size: Size(0, 45),
                                  )),
                              const SizedBox(
                                width: 12,
                              ),
                              Expanded(
                                child: RoundShapeButton(
                                    title: "Tap To Copy".tr,
                                    buttonColor: AppThemData.warning03,
                                    buttonTextColor: AppThemData.black,
                                    onTap: () async {
                                      await Clipboard.setData(ClipboardData(text: "${controller.referralModel.value.referralCode}")).then(
                                            (value) => ShowToastDialog.showToast("Copied".tr),
                                      );
                                    },
                                    size: Size(0, 45)),
                              ),
                              const SizedBox(
                                height: 24,
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 24,
                          ),
                          Text(
                            "How it Works".tr,
                            style: GoogleFonts.quicksand(color: AppThemData.grey500, fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(
                            height: 24,
                          ),
                          commanWidget(
                              themeChange: themeChange,
                              title: "Refer Friends",
                              description: "Share your unique referral code with friends and family to invite them to book rides in the app.",
                              imageAsset: "assets/icon/ic_mail_send.png"),
                          commanWidget(
                            themeChange: themeChange,
                            title: "Earn Credits",
                            description: "Get app credits for every friend who signs up with your code. Use these credits for your future rides.",
                            imageAsset: "assets/icon/ic_gift.png",
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                  controller.referralModel.value.referralCode != null
                      ? Padding(
                    padding: EdgeInsets.fromLTRB(24, 10, 24, MediaQuery
                        .of(context)
                        .padding
                        .bottom),
                    child: RoundShapeButton(
                        title: "Refer Now".tr,
                        buttonColor: AppThemData.primary500,
                        buttonTextColor: AppThemData.black,
                        onTap: () async {
                          await SharePlus.instance.share(ShareParams(
                              text:
                              'MyTaxi \n\n🚕 Drive and earn with MyTaxi! \n\nUse my referral code ${controller.referralModel.value
                                  .referralCode} when you sign up as a driver and start earning with every ride. Join now!'
                                  .tr));
                        },
                        size: Size(210, 48)),
                  )
                      : SizedBox()
                ],
              ),
            ));
      },
    );
  }

  Padding commanWidget({required String imageAsset, required String title, required String description, themeChange}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppThemData.primary100,
            child: Image.asset(
              imageAsset,
            ),
          ),
          // SvgPicture.asset(imageAsset),
          const SizedBox(
            width: 16,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.tr,
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                Text(
                  description.tr,
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

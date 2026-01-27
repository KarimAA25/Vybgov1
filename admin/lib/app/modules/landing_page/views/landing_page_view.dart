import 'dart:developer';

import 'package:admin/app/components/custom_button.dart';
import 'package:admin/app/components/dialog_box.dart';
import 'package:admin/app/constant/constants.dart';
import 'package:admin/app/constant/show_toast.dart';
import 'package:admin/app/utils/app_colors.dart';
import 'package:admin/app/utils/app_them_data.dart';
import 'package:admin/app/utils/fire_store_utils.dart';
import 'package:admin/app/utils/responsive.dart';
import 'package:admin/widget/container_custom.dart';
import 'package:admin/widget/global_widgets.dart';
import 'package:admin/widget/text_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import '../../../routes/app_pages.dart';
import '../controllers/landing_page_controller.dart';

class LandingPageView extends GetView<LandingPageController> {
  const LandingPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX(
      init: LandingPageController(),
      builder: (controller) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ContainerCustom(
                child: Column(
                  children: [
                    ResponsiveWidget.isDesktop(context)
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              ResponsiveWidget.isDesktop(context)
                                  ? Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        TextCustom(title: controller.title.value, fontSize: 20, fontFamily: AppThemeData.bold),
                                        spaceH(height: 2),
                                        Row(children: [
                                          GestureDetector(
                                              onTap: () => Get.offAllNamed(Routes.DASHBOARD_SCREEN),
                                              child: TextCustom(title: 'Dashboard'.tr, fontSize: 14, fontFamily: AppThemeData.medium, color: AppThemData.greyShade500)),
                                          const TextCustom(title: ' / ', fontSize: 14, fontFamily: AppThemeData.medium, color: AppThemData.greyShade500),
                                          TextCustom(title: 'Settings'.tr, fontSize: 14, fontFamily: AppThemeData.medium, color: AppThemData.greyShade500),
                                          const TextCustom(title: ' / ', fontSize: 14, fontFamily: AppThemeData.medium, color: AppThemData.greyShade500),
                                          TextCustom(title: ' ${controller.title.value} ', fontSize: 14, fontFamily: AppThemeData.medium, color: AppThemData.primary500)
                                        ])
                                      ],
                                    )
                                  : TextCustom(title: ' ${controller.title.value} ', fontSize: 14, fontFamily: AppThemeData.medium, color: AppThemData.primaryBlack),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  IconButton(
                                    style: TextButton.styleFrom(backgroundColor: Colors.blueGrey),
                                    onPressed: () {
                                      controller.htmlEditorController.value.undo();
                                    },
                                    icon: const Icon(
                                      Icons.undo_outlined,
                                      color: AppThemData.greyShade500,
                                    ),
                                  ),
                                  spaceW(),
                                  IconButton(
                                      style: TextButton.styleFrom(backgroundColor: Colors.blueGrey),
                                      onPressed: () {
                                        controller.htmlEditorController.value.clear();
                                      },
                                      icon: const Icon(
                                        Icons.refresh,
                                        color: AppThemData.greyShade500,
                                      )),
                                  spaceW(),
                                  IconButton(
                                      style: TextButton.styleFrom(backgroundColor: Colors.blueGrey),
                                      onPressed: () {
                                        controller.htmlEditorController.value.toggleCodeView();
                                      },
                                      icon: const Icon(
                                        Icons.code,
                                        color: AppThemData.greyShade500,
                                      )),
                                  spaceW(),
                                  CustomButtonWidget(
                                    padding: const EdgeInsets.symmetric(horizontal: 22),
                                    buttonTitle: "Save",
                                    onPress: () async {
                                      if (Constant.isDemo) {
                                        DialogBox.demoDialogBox();
                                      } else {
                                        var txt = await controller.htmlEditorController.value.getText();
                                        if (txt.contains('src="data:')) {
                                          txt = '<text removed due to base-64 data, displaying the text could cause the app to crash>';
                                        }

                                        controller.landingPageData.value = txt;
                                        Constant.waitingLoader();
                                        await FireStoreUtils.setLandingPageData(controller.landingPageData.value);
                                        ShowToastDialog.successToast("Landing Page updated");
                                        Get.back();
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              ResponsiveWidget.isDesktop(context)
                                  ? Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        TextCustom(title: controller.title.value, fontSize: 20, fontFamily: AppThemeData.bold),
                                        spaceH(height: 2),
                                        Row(children: [
                                          GestureDetector(
                                              onTap: () => Get.offAllNamed(Routes.DASHBOARD_SCREEN),
                                              child: TextCustom(title: 'Dashboard'.tr, fontSize: 14, fontFamily: AppThemeData.medium, color: AppThemData.greyShade500)),
                                          const TextCustom(title: ' / ', fontSize: 14, fontFamily: AppThemeData.medium, color: AppThemData.greyShade500),
                                          TextCustom(title: 'Settings'.tr, fontSize: 14, fontFamily: AppThemeData.medium, color: AppThemData.greyShade500),
                                          const TextCustom(title: ' / ', fontSize: 14, fontFamily: AppThemeData.medium, color: AppThemData.greyShade500),
                                          TextCustom(title: ' ${controller.title.value} ', fontSize: 14, fontFamily: AppThemeData.medium, color: AppThemData.primary500)
                                        ])
                                      ],
                                    )
                                  : TextCustom(title: ' ${controller.title.value} ', fontSize: 14, fontFamily: AppThemeData.medium, color: AppThemData.primaryBlack),
                              spaceH(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  IconButton(
                                    style: TextButton.styleFrom(backgroundColor: Colors.blueGrey),
                                    onPressed: () {
                                      controller.htmlEditorController.value.undo();
                                    },
                                    icon: const Icon(
                                      Icons.undo_outlined,
                                      color: AppThemData.greyShade500,
                                    ),
                                  ),
                                  spaceW(),
                                  IconButton(
                                      style: TextButton.styleFrom(backgroundColor: Colors.blueGrey),
                                      onPressed: () {
                                        controller.htmlEditorController.value.clear();
                                      },
                                      icon: const Icon(
                                        Icons.refresh,
                                        color: AppThemData.greyShade500,
                                      )),
                                  spaceW(),
                                  IconButton(
                                      style: TextButton.styleFrom(backgroundColor: Colors.blueGrey),
                                      onPressed: () {
                                        controller.htmlEditorController.value.toggleCodeView();
                                      },
                                      icon: const Icon(
                                        Icons.code,
                                        color: AppThemData.greyShade500,
                                      )),
                                  spaceW(),
                                  CustomButtonWidget(
                                    padding: const EdgeInsets.symmetric(horizontal: 22),
                                    buttonTitle: "Save",
                                    onPress: () async {
                                      if (Constant.isDemo) {
                                        DialogBox.demoDialogBox();
                                      } else {
                                        var txt = await controller.htmlEditorController.value.getText();
                                        if (txt.contains('src="data:')) {
                                          txt = '<text removed due to base-64 data, displaying the text could cause the app to crash>';
                                        }

                                        controller.landingPageData.value = txt;
                                        Constant.waitingLoader();
                                        await FireStoreUtils.setLandingPageData(controller.landingPageData.value);
                                        ShowToastDialog.successToast("Landing Page updated");
                                        Get.back();
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                    spaceH(height: 20),
                    controller.isLoading.value
                        ? Constant.loader()
                        : SingleChildScrollView(
                            child: Container(
                              height: 0.6.sh,
                              decoration: BoxDecoration(
                                color: AppThemData.greyShade50,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Obx(
                                () => HtmlEditor(
                                  controller: controller.htmlEditorController.value,
                                  htmlEditorOptions: HtmlEditorOptions(
                                    hint: 'Your text here...'.tr,
                                    initialText: controller.landingPageData.value,
                                    shouldEnsureVisible: true,
                                  ),
                                  htmlToolbarOptions: HtmlToolbarOptions(
                                    toolbarPosition: ToolbarPosition.aboveEditor,
                                    //by default
                                    toolbarType: ToolbarType.nativeScrollable,
                                    defaultToolbarButtons: [
                                      FontButtons(),
                                      ColorButtons(),
                                      ParagraphButtons(
                                        caseConverter: false
                                      ),
                                      ListButtons(
                                        listStyles: false
                                      ),
                                      InsertButtons(
                                        audio: false,
                                        video: false,
                                        picture: false,
                                        link: true,
                                        table: false,
                                      ),
                                    ],
                                    //by default
                                    onButtonPressed: (ButtonType type, bool? status, Function? updateStatus) {
                                      return true;
                                    },
                                    onDropdownChanged: (DropdownType type, dynamic changed, Function(dynamic)? updateSelectedItem) {
                                      return true;
                                    },
                                    mediaLinkInsertInterceptor: (String url, InsertFileType type) {
                                      return true;
                                    },
                                  ),
                                  otherOptions: const OtherOptions(height: 500),
                                  callbacks: Callbacks(
                                      onBeforeCommand: (String? currentHtml) {},
                                      onChangeContent: (String? changed) {},
                                      onChangeCodeview: (String? changed) {},
                                      onChangeSelection: (EditorSettings settings) {},
                                      onDialogShown: () {},
                                      onEnter: () {},
                                      onFocus: () {},
                                      onBlur: () {},
                                      onBlurCodeview: () {},
                                      onInit: () {},
                                      onImageUploadError: (FileUpload? file, String? base64Str, UploadError error) {
                                        log(describeEnum(error));
                                        log(base64Str ?? '');
                                        if (file != null) {
                                          log(file.name.toString());
                                          log(file.size.toString());
                                          log(file.type.toString());
                                        }
                                      },
                                      onKeyDown: (int? keyCode) {
                                        log('$keyCode key downed');
                                        log('current character count: ${controller.htmlEditorController.value.characterCount}');
                                      },
                                      onKeyUp: (int? keyCode) {
                                        log('$keyCode key released');
                                      },
                                      onMouseDown: () {
                                        log('mouse downed');
                                      },
                                      onMouseUp: () {
                                        log('mouse released');
                                      },
                                      onNavigationRequestMobile: (String url) {
                                        log(url);
                                        return NavigationActionPolicy.ALLOW;
                                      },
                                      onPaste: () {
                                        log('pasted into editor');
                                      },
                                      onScroll: () {
                                        log('editor scrolled');
                                      }),
                                  plugins: [
                                    SummernoteAtMention(
                                        getSuggestionsMobile: (String value) {
                                          var mentions = <String>['test1', 'test2', 'test3'];
                                          return mentions.where((element) => element.contains(value)).toList();
                                        },
                                        mentionsWeb: ['test1', 'test2', 'test3'],
                                        onSelect: (String value) {
                                          log(value);
                                        }),
                                  ],
                                ),
                              ),
                            ),
                          ),
                    spaceH(),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}

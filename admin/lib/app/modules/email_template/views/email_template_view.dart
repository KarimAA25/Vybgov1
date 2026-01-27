// ignore_for_file: use_build_context_synchronously, must_be_immutable

import 'package:admin/app/components/custom_button.dart';
import 'package:admin/app/components/custom_text_form_field.dart';
import 'package:admin/app/components/dialog_box.dart';
import 'package:admin/app/components/menu_widget.dart';
import 'package:admin/app/constant/constants.dart';
import 'package:admin/app/constant/show_toast.dart';
import 'package:admin/app/models/email_template_model.dart';
import 'package:admin/app/utils/app_colors.dart';
import 'package:admin/app/utils/app_them_data.dart';
import 'package:admin/app/utils/dark_theme_provider.dart';
import 'package:admin/app/utils/fire_store_utils.dart';
import 'package:admin/app/utils/responsive.dart';
import 'package:admin/widget/common_ui.dart';
import 'package:admin/widget/container_custom.dart';
import 'package:admin/widget/global_widgets.dart';
import 'package:admin/widget/text_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:get/get.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';

import '../../../routes/app_pages.dart';
import '../controllers/email_template_controller.dart';

class EmailTemplateView extends GetView<EmailTemplateController> {
  const EmailTemplateView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return GetX<EmailTemplateController>(
      init: EmailTemplateController(),
      builder: (controller) {
        return Scaffold(
            backgroundColor: themeChange.isDarkTheme() ? AppThemData.greyShade950 : AppThemData.greyShade50,
            appBar: AppBar(
              elevation: 0.0,
              toolbarHeight: 70,
              automaticallyImplyLeading: false,
              backgroundColor: themeChange.isDarkTheme() ? AppThemData.primaryBlack : AppThemData.primaryWhite,
              leadingWidth: 200,
              leading: Builder(
                builder: (BuildContext context) {
                  return GestureDetector(
                    onTap: () {
                      if (!ResponsiveWidget.isDesktop(context)) {
                        Scaffold.of(context).openDrawer();
                      }
                    },
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: !ResponsiveWidget.isDesktop(context)
                          ? Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Icon(
                                Icons.menu,
                                size: 30,
                                color: themeChange.isDarkTheme() ? AppThemData.primary500 : AppThemData.primary500,
                              ),
                            )
                          : SizedBox(
                              height: 45,
                              child: InkWell(
                                onTap: () {
                                  Get.toNamed(Routes.DASHBOARD_SCREEN);
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      "assets/image/logo.png",
                                      height: 45,
                                      color: AppThemData.primary500,
                                    ),
                                    spaceW(),
                                    const TextCustom(
                                      title: 'My Taxi',
                                      color: AppThemData.primary500,
                                      fontSize: 30,
                                      fontFamily: AppThemeData.semiBold,
                                      fontWeight: FontWeight.w700,
                                    )
                                  ],
                                ),
                              ),
                            ),
                    ),
                  );
                },
              ),
              actions: [
                GestureDetector(
                  onTap: () {
                    if (themeChange.darkTheme == 1) {
                      themeChange.darkTheme = 0;
                    } else if (themeChange.darkTheme == 0) {
                      themeChange.darkTheme = 1;
                    } else if (themeChange.darkTheme == 2) {
                      themeChange.darkTheme = 0;
                    } else {
                      themeChange.darkTheme = 2;
                    }
                  },
                  child: themeChange.isDarkTheme()
                      ? SvgPicture.asset(
                          "assets/icons/ic_sun.svg",
                          color: AppThemData.yellow600,
                          height: 20,
                          width: 20,
                        )
                      : SvgPicture.asset(
                          "assets/icons/ic_moon.svg",
                          color: AppThemData.blue400,
                          height: 20,
                          width: 20,
                        ),
                ),
                spaceW(),
                const LanguagePopUp(),
                spaceW(),
                ProfilePopUp()
              ],
            ),
            drawer: Drawer(
              width: 270,
              backgroundColor: themeChange.isDarkTheme() ? AppThemData.primaryBlack : AppThemData.primaryWhite,
              child: const MenuWidget(),
            ),
            body: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (ResponsiveWidget.isDesktop(context)) ...{const MenuWidget()},
                Expanded(
                    child: Padding(
                  padding: paddingEdgeInsets(),
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ContainerCustom(
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    TextCustom(title: controller.title.value, fontSize: 20, fontFamily: AppThemeData.bold),
                                    spaceH(height: 2),
                                    Row(children: [
                                      GestureDetector(
                                          onTap: () => Get.offAllNamed(Routes.DASHBOARD_SCREEN),
                                          child: TextCustom(title: 'Dashboard'.tr, fontSize: 14, fontFamily: AppThemeData.medium, color: AppThemData.greyShade500)),
                                      const TextCustom(title: ' / ', fontSize: 14, fontFamily: AppThemeData.medium, color: AppThemData.greyShade500),
                                      TextCustom(title: ' ${controller.title.value} ', fontSize: 14, fontFamily: AppThemeData.medium, color: AppThemData.primary500)
                                    ])
                                  ]),
                                ],
                              ),
                              spaceH(height: 20),
                              controller.isLoading.value
                                  ? Constant.loader()
                                  : (controller.emailTemplatesList.isEmpty)
                                      ? const Center(
                                          child: TextCustom(
                                          title: "No Available Templates",
                                        ))
                                      : Align(
                                          alignment: Alignment.centerLeft,
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(12),
                                              child: DataTable(
                                                  horizontalMargin: 20,
                                                  columnSpacing: 30,
                                                  dataRowMaxHeight: 65,
                                                  headingRowHeight: 65,
                                                  border: TableBorder.all(
                                                    color: themeChange.isDarkTheme() ? AppThemData.greyShade800 : AppThemData.greyShade100,
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  headingRowColor:
                                                      MaterialStateColor.resolveWith((states) => themeChange.isDarkTheme() ? AppThemData.greyShade800 : AppThemData.greyShade100),
                                                  columns: [
                                                    CommonUI.dataColumnWidget(context, columnTitle: "Subject".tr, width: 150),
                                                    CommonUI.dataColumnWidget(context, columnTitle: "Type".tr, width: 150),
                                                    CommonUI.dataColumnWidget(context, columnTitle: "Status".tr, width: 100),
                                                    CommonUI.dataColumnWidget(context, columnTitle: "Actions".tr, width: 100),
                                                  ],
                                                  rows: controller.emailTemplatesList
                                                      .map((template) => DataRow(cells: [
                                                            DataCell(
                                                              Container(
                                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                                child: TextCustom(
                                                                  title: template.subject ?? "N/A",
                                                                ),
                                                              ),
                                                            ),
                                                            DataCell(
                                                              Container(
                                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                                child: TextCustom(
                                                                  title: template.type == "signup"
                                                                      ? "Sign up"
                                                                      : template.type == "wallet_topup"
                                                                          ? "Wallet Top-up"
                                                                          : template.type == "booking_completed"
                                                                              ? "Booking Completed"
                                                                              : template.type == "withdraw_request"
                                                                                  ? "Withdrawal Request"
                                                                                  : template.type == "withdraw_complete"
                                                                                      ? "Withdrawal Approved"
                                                                                      : "Refer & Earn",
                                                                ),
                                                              ),
                                                            ),
                                                            DataCell(
                                                              Transform.scale(
                                                                scale: 0.8,
                                                                child: CupertinoSwitch(
                                                                  activeTrackColor: AppThemData.primary500,
                                                                  value: template.status!,
                                                                  onChanged: (value) async {
                                                                    if (Constant.isDemo) {
                                                                      DialogBox.demoDialogBox();
                                                                    } else {
                                                                      template.status = value;
                                                                      await FireStoreUtils.updateEmailTemplate(template);

                                                                      controller.getData();
                                                                    }
                                                                  },
                                                                ),
                                                              ),
                                                            ),
                                                            DataCell(
                                                              InkWell(
                                                                onTap: () {
                                                                  controller.subjectController.value.text = template.subject ?? '';
                                                                  controller.htmlEditorController.value.setText(template.body ?? '');

                                                                  showDialog(
                                                                    context: context,
                                                                    builder: (context) => EmailTemplateDialog(
                                                                      template: template,
                                                                    ),
                                                                  );
                                                                },
                                                                child: SvgPicture.asset(
                                                                  "assets/icons/ic_edit.svg",
                                                                  color: AppThemData.greyShade400,
                                                                  height: 16,
                                                                  width: 16,
                                                                ),
                                                              ),
                                                            ),
                                                          ]))
                                                      .toList()),
                                            ),
                                          ),
                                        )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ))
              ],
            ));
      },
    );
  }
}

class EmailTemplateDialog extends StatelessWidget {
  EmailTemplateModel template;

  EmailTemplateDialog({super.key, required this.template});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return GetX(
      init: EmailTemplateController(),
      builder: (controller) {
        if (template.id != null && template.id!.isNotEmpty) {
          controller.subjectController.value.text = template.subject ?? '';
          controller.htmlEditorController.value.setText(template.body ?? '');
        }
        return Dialog(
          backgroundColor: themeChange.isDarkTheme() ? AppThemData.greyShade800 : AppThemData.greyShade50,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
          alignment: Alignment.topCenter,
          // title: const TextCustom(title: 'Item Categories', fontSize: 18),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 800,
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            child: IntrinsicHeight(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(8.0), topRight: Radius.circular(8.0)),
                            color: themeChange.isDarkTheme() ? AppThemData.greyShade900 : AppThemData.greyShade100,
                          ),
                          child: Row(
                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextCustom(title: controller.title.value, fontSize: 18).expand(),
                              10.width,
                              InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Icon(
                                  Icons.close,
                                  size: 25,
                                  color: themeChange.isDarkTheme() ? AppThemData.primaryWhite : AppThemData.primaryBlack,
                                ),
                              )
                            ],
                          )).expand(),
                    ],
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                          CustomTextFormField(title: "Subject".tr, hintText: "Enter Subject".tr, controller: controller.subjectController.value),
                          spaceH(),
                          Container(
                            height: 0.6.sh,
                            decoration: BoxDecoration(
                              color: AppThemData.greyShade50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: HtmlEditor(
                              controller: controller.htmlEditorController.value,
                              htmlEditorOptions: HtmlEditorOptions(hint: 'Your text here...'.tr, shouldEnsureVisible: true, initialText: template.body),
                              htmlToolbarOptions: HtmlToolbarOptions(
                                toolbarPosition: ToolbarPosition.aboveEditor,
                                //by default
                                toolbarType: ToolbarType.nativeScrollable,
                                //by default
                                onButtonPressed: (ButtonType type, bool? status, Function? updateStatus) {
                                  log("button '${describeEnum(type)}' pressed, the current selected status is $status");
                                  return true;
                                },
                                onDropdownChanged: (DropdownType type, dynamic changed, Function(dynamic)? updateSelectedItem) {
                                  log("dropdown '${describeEnum(type)}' changed to $changed");
                                  return true;
                                },
                                mediaLinkInsertInterceptor: (String url, InsertFileType type) {
                                  log(url);
                                  return true;
                                },
                              ),
                              otherOptions: const OtherOptions(height: 500),
                              callbacks: Callbacks(
                                  onBeforeCommand: (String? currentHtml) {},
                                  onChangeContent: (String? changed) {},
                                  onChangeCodeview: (String? changed) {},
                                  onChangeSelection: (EditorSettings settings) {},
                                  onDialogShown: () {
                                    log('dialog shown');
                                  },
                                  onEnter: () {
                                    log('enter/return pressed');
                                  },
                                  onFocus: () {
                                    log('editor focused');
                                  },
                                  onBlur: () {
                                    log('editor unfocused');
                                  },
                                  onBlurCodeview: () {
                                    log('codeview either focused or unfocused');
                                  },
                                  onInit: () {
                                    log('init');
                                  },
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
                          spaceH(height: 20),
                          Align(
                            alignment: AlignmentGeometry.centerRight,
                            child: CustomButtonWidget(
                              buttonTitle: "Save".tr,
                              onPress: () async {
                                if (Constant.isDemo) {
                                  DialogBox.demoDialogBox();
                                } else {
                                  ShowToastDialog.showLoader("Please wait..".tr);
                                  if (controller.subjectController.value.text.isEmpty) {
                                    ShowToastDialog.errorToast("Subject cannot be empty".tr);
                                    ShowToastDialog.closeLoader();
                                    return;
                                  }

                                  final updatedBody = await controller.htmlEditorController.value.getText();

                                  template.subject = controller.subjectController.value.text;
                                  template.body = updatedBody;

                                  bool success = await FireStoreUtils.updateEmailTemplate(template);

                                  if (success) {
                                    ShowToastDialog.successToast("Template Updated".tr);
                                    ShowToastDialog.closeLoader();
                                    controller.getData();
                                    Navigator.pop(context);
                                  } else {
                                    ShowToastDialog.errorToast("Failed to update template".tr);
                                  }
                                }
                              },
                            ),
                          )
                        ]),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:driver/app/models/chat_model/inbox_model.dart';
import 'package:driver/app/models/user_model.dart';
import 'package:driver/app/modules/chat_screen/views/chat_screen_view.dart';
import 'package:driver/app/modules/inbox_screen/controllers/inbox_screen_controller.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/utils/dark_theme_provider.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../theme/app_them_data.dart';

class InboxScreenView extends GetView<InboxScreenController> {
  const InboxScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
      init: InboxScreenController(),
      builder: (controller) {
        return Scaffold(
            backgroundColor: themeChange.isDarkTheme() ? AppThemData.black : AppThemData.white,
            // appBar: AppBarWithBorder(
            //   title: "All Chats".tr,
            //   bgColor: themeChange.isDarkTheme() ? AppThemData.black : AppThemData.white,
            // ),
            body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).padding.bottom + 10),
                child: controller.isLoading.value
                    ? Constant.loader()
                    : controller.inboxList.isEmpty
                        ? Constant.showEmptyView(message: "No Conversation Found".tr)
                        : ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: controller.inboxList.length,
                            itemBuilder: (context, index) {
                              InboxModel inbox = controller.inboxList[index];
                              return GestureDetector(
                                onTap: () async {
                                  await FireStoreUtils.getUserProfile(
                                    inbox.senderId == FireStoreUtils.getCurrentUid() ? inbox.receiverId.toString() : inbox.senderId.toString(),
                                  ).then(
                                    (value) {
                                      Get.to(ChatScreenView(
                                        receiverId: value!.id.toString(),
                                      ));
                                    },
                                  );
                                },
                                child: Container(
                                  margin: EdgeInsets.only(bottom: 12),
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: themeChange.isDarkTheme() ? AppThemData.grey900 : AppThemData.grey50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: FutureBuilder(
                                    future: FireStoreUtils.getUserProfile(
                                      inbox.senderId == FireStoreUtils.getCurrentUid() ? inbox.receiverId.toString() : inbox.senderId.toString(),
                                    ),
                                    builder: (context, snapshot) {
                                      switch (snapshot.connectionState) {
                                        case ConnectionState.waiting:
                                          return const SizedBox();
                                        default:
                                          if (snapshot.hasError) {
                                            return Text('Error: ${snapshot.error}');
                                          } else if (!snapshot.hasData || snapshot.data == null) {
                                            return const SizedBox();
                                          } else {
                                            UserModel userModel = snapshot.data!;
                                            return Row(
                                              children: [
                                                ClipRRect(
                                                  borderRadius: BorderRadius.circular(50),
                                                  child: CachedNetworkImage(
                                                    imageUrl: userModel.profilePic.toString(),
                                                    width: 48,
                                                    height: 48,
                                                    fit: BoxFit.fill,
                                                    placeholder: (context, url) => Constant.loader(),
                                                    errorWidget: (context, url, error) => Image.asset("assets/images/user_placeholder.png"),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Expanded(
                                                            child: Text(
                                                              userModel.fullName.toString(),
                                                              style: GoogleFonts.inter(
                                                                fontSize: 16,
                                                                fontWeight: FontWeight.w500,
                                                                color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black,
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(width: 12),
                                                          Text(
                                                            Constant.timeAgo(inbox.timestamp!),
                                                            style: GoogleFonts.inter(
                                                              fontSize: 12,
                                                              fontWeight: FontWeight.w500,
                                                              color: themeChange.isDarkTheme() ? AppThemData.grey300 : AppThemData.grey700,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Text(
                                                        inbox.lastMessage.toString(),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: GoogleFonts.inter(
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.w400,
                                                          color: themeChange.isDarkTheme() ? AppThemData.grey300 : AppThemData.grey700,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            );
                                          }
                                      }
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ));
      },
    );
  }
}

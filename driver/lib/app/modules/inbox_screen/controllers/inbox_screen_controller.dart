import 'dart:async';

import 'package:driver/app/models/chat_model/inbox_model.dart';
import 'package:driver/constant/collection_name.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:get/get.dart';

class InboxScreenController extends GetxController {
  RxBool isLoading = true.obs;
  RxList<InboxModel> inboxList = <InboxModel>[].obs;

  StreamSubscription? _inboxSub;

  @override
  void onInit() {
    super.onInit();
    listenInbox();
  }

  void listenInbox() {
    _inboxSub?.cancel();
    _inboxSub = FireStoreUtils.fireStore
        .collection(CollectionName.chat)
        .doc(FireStoreUtils.getCurrentUid())
        .collection("inbox")
        .orderBy("timestamp", descending: true)
        .snapshots()
        .listen((snapshot) {
      inboxList.value = snapshot.docs.map((doc) => InboxModel.fromJson(doc.data())).toList();
      isLoading.value = false;
    });
  }

  @override
  void onClose() {
    _inboxSub?.cancel();
    super.onClose();
  }
}

import 'package:driver/constant/collection_name.dart';
import 'package:get/get.dart';
import 'package:driver/app/models/documents_model.dart';
import 'package:driver/app/models/driver_user_model.dart';
import 'package:driver/app/models/verify_driver_model.dart';
import 'package:driver/utils/fire_store_utils.dart';

class VerifyDocumentsController extends GetxController {
  RxList<DocumentsModel> documentList = <DocumentsModel>[].obs;
  Rx<DriverUserModel> userModel = DriverUserModel().obs;
  RxBool isVerified = false.obs;

  @override
  void onInit() {
    getData();
    super.onInit();
  }

  Future<void> getData() async {
    documentList.clear();
    documentList.value = await FireStoreUtils.getDocumentList();
    FireStoreUtils.fireStore.collection(CollectionName.drivers).doc(FireStoreUtils.getCurrentUid()).snapshots().listen((snapShot) {
      if (snapShot.exists && snapShot.data() != null) {
        userModel.value = DriverUserModel.fromJson(snapShot.data()!);
      }
    });
  }

  bool checkUploadedData(String documentId) {
    List<VerifyDocument> doc = userModel.value.verifyDocument ?? [];
    int index = doc.indexWhere((element) => element.documentId == documentId);

    return index != -1;
  }

  bool checkVerifiedData(String documentId) {
    List<VerifyDocument> doc = userModel.value.verifyDocument ?? [];
    int index = doc.indexWhere((element) => element.documentId == documentId);
    if (index != -1) {
      return doc[index].isVerify ?? false;
    } else {
      return false;
    }
  }
}

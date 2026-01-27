// ignore_for_file: unnecessary_overrides

import 'dart:io';

// ignore_for_file: depend_on_referenced_packages
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:driver/app/models/documents_model.dart';
import 'package:driver/app/models/driver_user_model.dart';
import 'package:driver/app/models/verify_driver_model.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/constant_widgets/network_image_widget.dart';
import 'package:driver/constant_widgets/show_toast_dialog.dart';
import 'package:driver/theme/responsive.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:image_picker/image_picker.dart';

class UploadDocumentsController extends GetxController {
  RxBool isLoading = true.obs;
  TextEditingController nameController = TextEditingController();
  TextEditingController numberController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  PageController controller = PageController();
  RxInt pageIndex = 0.obs;

  final ImagePicker imagePicker = ImagePicker();

  Rx<VerifyDocument> verifyDocument = VerifyDocument(documentImage: ['', '']).obs;
  RxList<Widget> imageWidgetList = <Widget>[].obs;
  RxList<int> imageList = <int>[].obs;
  Rx<DriverUserModel> userModel = DriverUserModel().obs;
  Rx<DocumentsModel> document = DocumentsModel().obs;
  RxBool isUploaded = false.obs;

  @override
  void onInit() {
    getArgument();
    super.onInit();
  }

  void getArgument() {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      document.value = argumentData['document'];
      isUploaded.value = argumentData['isUploaded'];
      getUserData();
    }
    update();
  }

  Future<void> getUserData() async {
    userModel.value = await FireStoreUtils.getDriverUserProfile(FireStoreUtils.getCurrentUid()) ?? DriverUserModel();
    setData();
    isLoading.value = false;
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void setData() {
    imageWidgetList.clear();
    if (isUploaded.value) {
      int index = userModel.value.verifyDocument!.indexWhere((element) => element.documentId == document.value.id);
      if (index != -1) {
        for (var element in userModel.value.verifyDocument![index].documentImage) {
          imageList.add(userModel.value.verifyDocument![index].documentImage.indexOf(element));
          imageWidgetList.add(
            Center(
              child: NetworkImageWidget(
                imageUrl: element.toString(),
                height: 220,
                width: Responsive.width(100, Get.context!),
                borderRadius: 12,
                fit: BoxFit.cover,
              ),
            ),
          );
        }

        nameController.text = userModel.value.verifyDocument![index].name ?? '';
        numberController.text = userModel.value.verifyDocument![index].number ?? '';
        dobController.text = userModel.value.verifyDocument![index].dob ?? '';
      }
    }
  }

  Future<void> pickFile({
    required ImageSource source,
    required int index,
  }) async {
    try {
      XFile? image = await imagePicker.pickImage(source: source, imageQuality: 60);
      if (image == null) return;
      Get.back();
      Uint8List? compressedBytes = await FlutterImageCompress.compressWithFile(
        image.path,
        quality: 50,
      );
      File compressedFile = File(image.path);
      await compressedFile.writeAsBytes(compressedBytes!);
      List<dynamic> files = verifyDocument.value.documentImage;
      files.removeAt(index);
      files.insert(index, compressedFile.path);
      verifyDocument.value = VerifyDocument(documentImage: files);
    } on PlatformException {
      ShowToastDialog.showToast("Failed to pick".tr);
    }
  }

  Future<void> uploadDocument(DocumentsModel document) async {
    ShowToastDialog.showLoader("Please Wait..".tr);
    if (verifyDocument.value.documentImage.isNotEmpty) {
      for (int i = 0; i < verifyDocument.value.documentImage.length; i++) {
        if (verifyDocument.value.documentImage[i].isNotEmpty) {
          if (Constant.hasValidUrl(verifyDocument.value.documentImage[i].toString()) == false) {
            String image = await Constant.uploadDriverDocumentImageToFireStorage(
              File(verifyDocument.value.documentImage[i].toString()),
              "driver_documents/${document.id}/${FireStoreUtils.getCurrentUid()}",
              verifyDocument.value.documentImage[i].split('/').last,
            );
            verifyDocument.value.documentImage.removeAt(i);
            verifyDocument.value.documentImage.insert(i, image);
          }
        }
      }
    }
    verifyDocument.value.documentId = document.id;
    verifyDocument.value.name = nameController.text;
    verifyDocument.value.number = numberController.text;
    verifyDocument.value.dob = dobController.text;
    verifyDocument.value.isVerify = false;
    List<VerifyDocument> verifyDocumentList = userModel.value.verifyDocument ?? [];
    verifyDocumentList.add(verifyDocument.value);

    userModel.value.verifyDocument = verifyDocumentList;

    bool isUpdated = await FireStoreUtils.updateDriverUser(userModel.value);
    ShowToastDialog.closeLoader();
    if (isUpdated) {
      ShowToastDialog.showToast("Document_Verification".trParams({"documentverification": document.title.toString()})
          //"${document.title} updated, Please wait for verification."
          );
      getUserData();
      Get.back();
      update();
    } else {
      ShowToastDialog.showToast("Something went wrong, Please try again later.".tr);
      Get.back();
    }
  }
}

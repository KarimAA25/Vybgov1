// ignore_for_file: depend_on_referenced_packages
import 'dart:developer';

import 'package:admin/app/constant/collection_name.dart';
import 'package:admin/app/constant/constants.dart';
import 'package:admin/app/models/admin_model.dart';
import 'package:admin/app/routes/app_pages.dart';
import 'package:admin/app/utils/fire_store_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constant/show_toast.dart' show ShowToastDialog;

class LoginPageController extends GetxController {
  var isPasswordVisible = true.obs;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  RxString email = "".obs;
  RxString password = "".obs;

  @override
  void onInit() {
    getData();
    super.onInit();
    // _initializeData();
  }

  Future<void> checkAndLoginOrCreateAdmin() async {
    ShowToastDialog.showLoader("Please wait..".tr);

    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();

    try {
      // 1️⃣ Try normal login first (fast path)
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);

      // 2️⃣ Fetch only this admin's document (NOT the whole collection)
      final adminDoc = await FirebaseFirestore.instance.collection(CollectionName.admin).doc(userCredential.user!.uid).get();

      if (!adminDoc.exists) {
        // User exists in Auth but not in admin collection => unauthorized
        await FirebaseAuth.instance.signOut();
        ShowToastDialog.closeLoader();
        ShowToastDialog.errorToast("Admin not active or unauthorized.".tr);
        return;
      }

      Constant.isLogin = await FireStoreUtils.isLogin(); // or set directly if you want
      ShowToastDialog.closeLoader();
      ShowToastDialog.successToast("Logged in successfully!".tr);
      Get.offAllNamed(Routes.DASHBOARD_SCREEN);
    } on FirebaseAuthException catch (e) {
      // 3️⃣ Special case: user-not-found ⇒ maybe this is the FIRST admin
      log("+++++++++++++++++++> ${e.code}");
      if (e.code == 'user-not-found' || e.code == "invalid-credential") {
        final adminSnapshot = await FirebaseFirestore.instance.collection(CollectionName.admin).limit(1).get();

        if (adminSnapshot.docs.isEmpty) {
          try {
            UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
              email: email,
              password: password,
            );

            AdminModel adminModel = AdminModel(
              email: email,
              name: "",
              image: "",
              contactNumber: "",
              isDemo: false,
            );

            Constant.isDemoSet(adminModel);

            await FirebaseFirestore.instance.collection(CollectionName.admin).doc(userCredential.user!.uid).set(adminModel.toJson());

            ShowToastDialog.closeLoader();
            ShowToastDialog.successToast("Logged in successfully!".tr);
            Get.offAllNamed(Routes.DASHBOARD_SCREEN);
          } on FirebaseAuthException catch (createError) {
            ShowToastDialog.closeLoader();
            ShowToastDialog.errorToast(createError.message ?? "Failed to create admin.".tr);
          }
        } else {
          // There are admins already, so this email is truly invalid
          ShowToastDialog.closeLoader();
          ShowToastDialog.errorToast("No user found with this email.".tr);
        }
      } else {
        // 4️⃣ Other auth errors
        ShowToastDialog.closeLoader();
        String errorMessage;

        switch (e.code) {
          case 'invalid-email':
            errorMessage = 'The email address is invalid.'.tr;
            break;
          case 'user-disabled':
            errorMessage = 'This user account has been disabled.'.tr;
            break;
          case 'wrong-password':
            errorMessage = 'Incorrect password.'.tr;
            break;
          case 'email-already-in-use':
            errorMessage = 'This email is already registered.'.tr;
            break;
          case 'weak-password':
            errorMessage = 'Password should be at least 6 characters.'.tr;
            break;
          default:
            errorMessage = 'Login failed. Please try again.'.tr;
        }

        ShowToastDialog.errorToast(errorMessage);
      }
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.errorToast("Something went wrong. Please try again.".tr);
    }
  }

  Future<void> getData() async {
    // email.value = Constant.adminModel!.name.toString();
    // password.value = Constant.adminModel!.password.toString();
    await Constant.getCurrencyData();
    await Constant.getLanguageData();
  }
}

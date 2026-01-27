// ignore_for_file: unnecessary_overrides, invalid_return_type_for_catch_error

import 'dart:convert';
import 'dart:developer';

import 'package:crypto/crypto.dart';
import 'package:customer/app/models/user_model.dart';
import 'package:customer/app/modules/home/views/home_view.dart';
import 'package:customer/app/modules/signup/views/signup_view.dart';
import 'package:customer/app/modules/verify_otp/views/verify_otp_view.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant_widgets/show_toast_dialog.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class LoginController extends GetxController {
  TextEditingController countryCodeController = TextEditingController(text: Constant.countryCode);
  TextEditingController phoneNumberController = TextEditingController();
  Rx<GlobalKey<FormState>> formKey = GlobalKey<FormState>().obs;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {}

  Future<void> sendCode() async {
    try {
      ShowToastDialog.showLoader("Please wait".tr);
      await FirebaseAuth.instance
          .verifyPhoneNumber(
        phoneNumber: countryCodeController.value.text + phoneNumberController.value.text,
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException e) {
          debugPrint("FirebaseAuthException--->${e.message}");
          ShowToastDialog.closeLoader();
          if (e.code == 'invalid-phone-number') {
            ShowToastDialog.showToast("invalid_phone_number".tr);
          } else {
            ShowToastDialog.showToast(e.code);
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          ShowToastDialog.closeLoader();
          Get.to(const VerifyOtpView(), arguments: {
            "countryCode": countryCodeController.value.text,
            "phoneNumber": phoneNumberController.value.text,
            "verificationId": verificationId,
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      )
          .catchError((error) {
        debugPrint("catchError--->$error");
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast("multiple_time_request".tr);
      });
    } catch (e) {
      log("Error in Login ${e.toString()}");
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast("something went wrong!".tr);
    }
  }

  final GoogleSignIn googleSignIn = GoogleSignIn.instance;

  Future<void> initializeGoogleSignIn() async {
    await googleSignIn.initialize(
      serverClientId: '85844481125-n2c05btectk6tvr0d7ugm8i690a148nq.apps.googleusercontent.com',
    );
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      initializeGoogleSignIn();
      if (!googleSignIn.supportsAuthenticate()) {
        return null;
      }

      GoogleSignInAccount? googleSignInAccount = await googleSignIn.authenticate();
      final GoogleSignInAuthentication googleAuth = googleSignInAccount.authentication;
      final credential = GoogleAuthProvider.credential(idToken: googleAuth.idToken);

      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      log("Error in sign in with google : $e");
    }
    return null;
  }

  Future<Map<String, dynamic>?> signInWithApple() async {
    try {
      final rawNonce = generateNonce();
      final nonce = sha256ofString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(oauthCredential);
      return {
        "appleCredential": appleCredential,
        "userCredential": userCredential,
      };
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        debugPrint("User cancelled Apple Sign-In");
        // You can return a specific value or null here
      } else {
        debugPrint("Apple Sign-In failed: ${e.code} - ${e.message}");
      }
    } catch (e) {
      debugPrint("Unexpected error during Apple Sign-In: $e");
    }
    return null;
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> loginWithGoogle() async {
    ShowToastDialog.showLoader("Please wait".tr);
    await signInWithGoogle().then((value) {
      ShowToastDialog.closeLoader();
      if (value != null) {
        if (value.additionalUserInfo!.isNewUser) {
          UserModel userModel = UserModel();
          userModel.id = value.user!.uid;
          userModel.email = value.user!.email;
          userModel.fullName = value.user!.displayName;
          userModel.profilePic = value.user!.photoURL;
          userModel.loginType = Constant.googleLoginType;

          ShowToastDialog.closeLoader();
          Get.to(const SignupView(), arguments: {
            "userModel": userModel,
          });
        } else {
          FireStoreUtils.userExistOrNot(value.user!.uid).then((userExit) async {
            ShowToastDialog.closeLoader();
            if (userExit == true) {
              UserModel? userModel = await FireStoreUtils.getUserProfile(value.user!.uid);
              if (userModel != null) {
                if (userModel.isActive == true) {
                  Get.offAll(const HomeView());
                } else {
                  await FirebaseAuth.instance.signOut();
                  ShowToastDialog.showToast("user_disable_admin_contact".tr);
                }
              }
            } else {
              UserModel userModel = UserModel();
              userModel.id = value.user!.uid;
              userModel.email = value.user!.email;
              userModel.fullName = value.user!.displayName;
              userModel.profilePic = value.user!.photoURL;
              userModel.loginType = Constant.googleLoginType;

              Get.to(const SignupView(), arguments: {
                "userModel": userModel,
              });
            }
          });
        }
      }
    });
  }

  Future<void> loginWithApple() async {
    ShowToastDialog.showLoader("Please wait".tr);
    await signInWithApple().then((value) {
      ShowToastDialog.closeLoader();
      if (kDebugMode) {
        print("===> $value");
      }
      if (value != null) {
        Map<String, dynamic> map = value;
        AuthorizationCredentialAppleID appleCredential = map['appleCredential'];
        UserCredential userCredential = map['userCredential'];
        if (userCredential.additionalUserInfo!.isNewUser) {
          UserModel userModel = UserModel();
          userModel.id = userCredential.user!.uid;
          userModel.fullName = appleCredential.givenName ?? appleCredential.familyName ?? '';
          userModel.email = appleCredential.email ?? userCredential.user!.email ?? '';
          userModel.loginType = Constant.appleLoginType;

          ShowToastDialog.closeLoader();
          Get.to(const SignupView(), arguments: {
            "userModel": userModel,
          });
        } else {
          FireStoreUtils.userExistOrNot(userCredential.user!.uid).then((userExit) async {
            ShowToastDialog.closeLoader();

            if (userExit == true) {
              UserModel? userModel = await FireStoreUtils.getUserProfile(userCredential.user!.uid);
              if (userModel != null) {
                if (userModel.isActive == true) {
                  Get.offAll(const HomeView());
                } else {
                  await FirebaseAuth.instance.signOut();
                  ShowToastDialog.showToast("user_disable_admin_contact".tr);
                }
              }
            } else {
              UserModel userModel = UserModel();
              userModel.id = userCredential.user!.uid;
              userModel.fullName = appleCredential.givenName ?? appleCredential.familyName ?? '';
              userModel.email = appleCredential.email ?? userCredential.user!.email ?? '';
              userModel.loginType = Constant.appleLoginType;

              Get.to(const SignupView(), arguments: {
                "userModel": userModel,
              });
            }
          });
        }
      }
    }).onError((error, stackTrace) {
      log("===> $error");
    });
  }
}

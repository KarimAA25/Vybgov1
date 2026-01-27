// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as maths;

import 'package:customer/app/models/driver_user_model.dart';
import 'package:customer/app/models/emergency_number_model.dart';
import 'package:customer/app/models/location_lat_lng.dart';
import 'package:customer/app/models/payment_method_model.dart';
import 'package:customer/app/models/payment_model/stripe_failed_model.dart';
import 'package:customer/app/models/rental_booking_model.dart';
import 'package:customer/app/models/review_customer_model.dart';
import 'package:customer/app/models/sos_alerts_model.dart';
import 'package:customer/app/models/user_model.dart';
import 'package:customer/app/models/wallet_transaction_model.dart';
import 'package:customer/constant/booking_status.dart';
import 'package:customer/constant/collection_name.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/send_notification.dart';
import 'package:customer/constant_widgets/show_toast_dialog.dart';
import 'package:customer/extension/string_extensions.dart';
import 'package:customer/payments/flutter_wave/flutter_wave.dart';
import 'package:customer/payments/marcado_pago/mercado_pago_screen.dart';
import 'package:customer/payments/pay_fast/pay_fast_screen.dart';
import 'package:customer/payments/pay_stack/pay_stack_screen.dart';
import 'package:customer/payments/pay_stack/pay_stack_url_model.dart';
import 'package:customer/payments/pay_stack/paystack_url_generator.dart';
import 'package:customer/payments/paypal/PaypalPayment.dart';
import 'package:customer/theme/app_them_data.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mp_integration/mp_integration.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart' as razor_pay_flutter;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import '../../../../payments/midtrans/midtrans_payment_screen.dart';
import '../../../../payments/xendit/xendit_model.dart';
import '../../../../payments/xendit/xendit_payment_screen.dart';

class RentalRideDetailsController extends GetxController {
  RxBool isLoading = true.obs;
  Rx<UserModel> userModel = UserModel().obs;
  Rx<RentalBookingModel> rentalModel = RentalBookingModel().obs;
  RxList<ReviewModel> reviewList = <ReviewModel>[].obs;

  RxDouble extraKm = 0.0.obs;
  RxInt extraHours = 0.obs;

  RxString selectedPaymentMethod = "".obs;
  Rx<PaymentModel> paymentModel = PaymentModel().obs;
  razor_pay_flutter.Razorpay _razorpay = razor_pay_flutter.Razorpay();

  Rx<ReviewModel> driverToCustomerReview = ReviewModel().obs;
  Rx<ReviewModel> customerToDriverReview = ReviewModel().obs;

  RxList<String> selectedEmergencyContactIds = <String>[].obs;
  RxList<EmergencyContactModel> totalEmergencyContacts = <EmergencyContactModel>[].obs;
  Rx<EmergencyContactModel> contactModel = EmergencyContactModel().obs;
  Rx<SOSAlertsModel> sosAlertsModel = SOSAlertsModel().obs;
  RxBool canShowSOS = false.obs;

  @override
  void onInit() {
    getArguments();
    calculateExtraKmAndHours();
    super.onInit();
  }

  @override
  void onClose() {
    _razorpay.clear();
    super.onClose();
  }

  void getArguments() {
    dynamic arguments = Get.arguments;
    if (arguments != null) {
      rentalModel.value = arguments["rentalModel"];
      getBookingDetails();
      getEmergencyContacts();
      if (rentalModel.value.bookingStatus == BookingStatus.bookingOngoing) {
        checkSOSAvailability();
      }
    }
    isLoading.value = false;
  }

  Future<void> getBookingDetails() async {
    getReview();
    await FireStoreUtils().getPayment().then((value) {
      if (value != null) {
        paymentModel.value = value;
        if (paymentModel.value.strip!.isActive == true) {
          Stripe.publishableKey = paymentModel.value.strip!.clientPublishableKey.toString();
          Stripe.merchantIdentifier = 'MyTaxi';
          Stripe.instance.applySettings();
        }
        if (paymentModel.value.flutterWave!.isActive == true) {
          setRef();
        }
      }
    });
    FireStoreUtils.fireStore.collection(CollectionName.rentalRide).doc(rentalModel.value.id).snapshots().listen((value) {
      if (value.exists) {
        rentalModel.value = RentalBookingModel.fromJson(value.data()!);
        update();
      }
    });
    selectedPaymentMethod.value = rentalModel.value.paymentType.toString();
    await getProfileData();
  }

  Future<void> getProfileData() async {
    await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid()).then((value) {
      if (value != null) {
        userModel.value = value;
      }
    });
  }

  Future<void> getReview() async {
    final snapshot = await FirebaseFirestore.instance.collection(CollectionName.review).get();
    reviewList.value = snapshot.docs.map((doc) => ReviewModel.fromJson(doc.data())).toList();

    try {
      customerToDriverReview.value = reviewList.firstWhere((r) => r.bookingId == rentalModel.value.id && r.type == Constant.typeDriver);
    } catch (_) {
      customerToDriverReview.value = ReviewModel();
    }

    try {
      driverToCustomerReview.value = reviewList.firstWhere((r) => r.bookingId == rentalModel.value.id && r.type == Constant.typeCustomer);
    } catch (_) {
      driverToCustomerReview.value = ReviewModel();
    }
  }

  void calculateExtraKmAndHours() {
    try {
      // Get completed and current KM
      double completedKM = double.tryParse(rentalModel.value.completedKM ?? '0.0') ?? 0.0;
      double currentKM = double.tryParse(rentalModel.value.currentKM ?? '0.0') ?? 0.0;

      double includedDistance = double.tryParse(rentalModel.value.rentalPackage?.includedDistance ?? '0.0') ?? 0.0;
      double extraKmTemp = completedKM - currentKM;

      if (extraKmTemp > includedDistance) {
        double overKm = extraKmTemp - includedDistance;
        extraKm.value = overKm;
      } else {
        extraKm.value = 0;
      }

      // Hours calculation
      if (rentalModel.value.pickupTime != null) {
        DateTime pickupTime = rentalModel.value.pickupTime!.toDate();

        // Use dropTime if set, otherwise fall back to current time
        DateTime endTime;
        if (rentalModel.value.dropTime != null) {
          endTime = rentalModel.value.dropTime!.toDate();
        } else {
          endTime = DateTime.now();
        }

        Duration totalDuration = endTime.difference(pickupTime);

        double includedHours = double.tryParse(rentalModel.value.rentalPackage?.includedHours ?? '0') ?? 0.0;
        double usedHours = totalDuration.inMinutes / 60.0;

        if (usedHours > includedHours) {
          extraHours.value = (usedHours - includedHours).ceil();
        } else {
          extraHours.value = 0;
        }
      } else {
        extraHours.value = 0;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error calculating extra values for display: $e");
      }
      extraKm.value = 0;
      extraHours.value = 0;
    }
  }

  Future<void> completeOrder(String transactionId) async {
    bool isPaymentStatus = rentalModel.value.paymentStatus ?? false;
    ShowToastDialog.showLoader("Please wait".tr);

    rentalModel.value.paymentType = selectedPaymentMethod.value;
    if (rentalModel.value.paymentType == Constant.paymentModel!.cash!.name) {
      rentalModel.value.paymentStatus = selectedPaymentMethod.value == Constant.paymentModel!.cash!.name ? false : true;
    }

    //if payment type cash -------->send notification to driver
    WalletTransactionModel transactionModel = WalletTransactionModel(
        id: Constant.getUuid(),
        amount: Constant.calculateFinalRentalRideAmount(rentalModel.value).toString(),
        createdDate: Timestamp.now(),
        paymentType: selectedPaymentMethod.value,
        transactionId: transactionId,
        userId: rentalModel.value.driverId,
        isCredit: true,
        type: Constant.typeDriver,
        note: "Ride fee Credited ");

    await FireStoreUtils.setWalletTransaction(transactionModel).then((value) async {
      if (value == true) {
        await FireStoreUtils.updateOtherUserWallet(amount: Constant.calculateFinalRentalRideAmount(rentalModel.value).toString(), id: rentalModel.value.driverId!);
      }
    }).catchError((error) {
      log('========> error of set wallet Transaction $error');
    });

    if (Constant.adminCommission != null && Constant.adminCommission!.active == true && num.parse(Constant.adminCommission!.value!) > 0) {
      WalletTransactionModel adminCommissionWallet = WalletTransactionModel(
          id: Constant.getUuid(),
          amount:
              "${Constant.calculateAdminCommission(amount: (((double.parse(rentalModel.value.subTotal ?? '0.0')) + double.parse(rentalModel.value.extraKmCharge ?? '0.0') + double.parse(rentalModel.value.extraHourCharge ?? '0.0')) - (double.parse(rentalModel.value.discount ?? '0.0'))).toString(), adminCommission: rentalModel.value.adminCommission)}",
          createdDate: Timestamp.now(),
          paymentType: "Wallet",
          transactionId: rentalModel.value.id,
          isCredit: false,
          type: Constant.typeDriver,
          userId: rentalModel.value.driverId,
          note: "Admin commission Debited",
          adminCommission: rentalModel.value.adminCommission);

      await FireStoreUtils.setWalletTransaction(adminCommissionWallet).then((value) async {
        if (value == true) {
          await FireStoreUtils.updateOtherUserWallet(
              amount:
                  "-${Constant.calculateAdminCommission(amount: (((double.parse(rentalModel.value.subTotal ?? '0.0')) + double.parse(rentalModel.value.extraKmCharge ?? '0.0') + double.parse(rentalModel.value.extraHourCharge ?? '0.0')) - (double.parse(rentalModel.value.discount ?? '0.0'))).toString(), adminCommission: rentalModel.value.adminCommission)}",
              id: rentalModel.value.driverId!);
        }
      }).catchError((error) {
        log('=======> error of transcation 3333 $error');
      });
    }

    rentalModel.value.paymentStatus = isPaymentStatus;

    await FireStoreUtils.setRentalRide(rentalModel.value).then((value) {
      ShowToastDialog.closeLoader();
      // Get.offAllNamed(Routes.HOME);
    });
    log('====---444--> selecte payment status ${rentalModel.value.paymentStatus}');

    DriverUserModel? receiverUserModel = await FireStoreUtils.getDriverUserProfile(rentalModel.value.driverId.toString());
    Map<String, dynamic> playLoad = <String, dynamic>{"bookingId": rentalModel.value.id};
    await SendNotification.sendOneNotification(
        type: "order",
        token: receiverUserModel!.fcmToken.toString(),
        title: 'Payment Received',
        body: 'Payment Received for Ride #${rentalModel.value.id.toString().substring(0, 5)}',
        bookingId: rentalModel.value.id,
        driverId: rentalModel.value.driverId.toString(),
        senderId: FireStoreUtils.getCurrentUid(),
        payload: playLoad,
        isBooking: false);

    ShowToastDialog.closeLoader();
    Get.back();
    // Get.offAllNamed(Routes.HOME);
  }

  // ::::::::::::::::::::::::::::::::::::::::::::Wallet::::::::::::::::::::::::::::::::::::::::::::::::::::
  Future<void> walletPaymentMethod() async {
    ShowToastDialog.showLoader("Please wait".tr);

    WalletTransactionModel transactionModel = WalletTransactionModel(
        id: Constant.getUuid(),
        amount: Constant.calculateFinalRentalRideAmount(rentalModel.value).toString(),
        createdDate: Timestamp.now(),
        paymentType: selectedPaymentMethod.value,
        transactionId: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: FireStoreUtils.getCurrentUid(),
        isCredit: false,
        type: Constant.typeCustomer,
        note: "Ride fee Debited");

    await FireStoreUtils.setWalletTransaction(transactionModel).then((value) async {
      if (value == true) {
        await FireStoreUtils.updateUserWallet(amount: "-${Constant.calculateFinalRentalRideAmount(rentalModel.value).toString()}").then((value) async {
          await getProfileData();
          rentalModel.value.paymentStatus = true;
          await FireStoreUtils.setRentalRide(rentalModel.value);
        });
      }
    });
    ShowToastDialog.closeLoader();

    completeOrder(DateTime.now().millisecondsSinceEpoch.toString());
  }

  // ::::::::::::::::::::::::::::::::::::::::::::Stripe::::::::::::::::::::::::::::::::::::::::::::::::::::
  Future<void> stripeMakePayment({required String amount}) async {
    try {
      log(double.parse(amount).toStringAsFixed(0));
      try {
        Map<String, dynamic>? paymentIntentData = await createStripeIntent(amount: amount);
        if (paymentIntentData!.containsKey("error")) {
          Get.back();
          ShowToastDialog.showToast("Something went wrong, please contact admin.".tr);
        } else {
          await Stripe.instance.initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
                  paymentIntentClientSecret: paymentIntentData['client_secret'],
                  allowsDelayedPaymentMethods: false,
                  googlePay: const PaymentSheetGooglePay(
                    merchantCountryCode: 'US',
                    testEnv: true,
                    currencyCode: "USD",
                  ),
                  style: ThemeMode.system,
                  appearance: PaymentSheetAppearance(
                    colors: PaymentSheetAppearanceColors(
                      primary: AppThemData.primary500,
                    ),
                  ),
                  merchantDisplayName: 'MyTaxi'));
          displayStripePaymentSheet(amount: amount, client_secret: paymentIntentData['client_secret']);
        }
      } catch (e, s) {
        log("$e \n$s");
        ShowToastDialog.showToast("exception:$e \n$s");
      }
    } catch (e) {
      log('Existing in stripeMakePayment: $e');
    }
  }

  Future<void> displayStripePaymentSheet({required String amount, required String client_secret}) async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) async {
        ShowToastDialog.showToast("Payment successfully");
        await Stripe.instance.retrievePaymentIntent(client_secret).then(
          (value) {
            log('=================> Stripe  payment  ========> ${value.toJson()}');
            completeOrder(value.id);
          },
        );
      });
    } on StripeException catch (e) {
      var lo1 = jsonEncode(e);
      var lo2 = jsonDecode(lo1);
      StripePayFailedModel lom = StripePayFailedModel.fromJson(lo2);
      ShowToastDialog.showToast(lom.error.message);
    } catch (e) {
      ShowToastDialog.showToast(e.toString());
      log('Existing in displayStripePaymentSheet: $e');
    }
  }

  Future createStripeIntent({required String amount}) async {
    try {
      Map<String, dynamic> body = {
        'amount': ((double.parse(amount) * 100).round()).toString(),
        'currency': "USD",
        'payment_method_types[]': 'card',
        "description": "Strip Payment",
        "shipping[name]": userModel.value.fullName,
        "shipping[address][line1]": "510 Townsend St",
        "shipping[address][postal_code]": "98140",
        "shipping[address][city]": "San Francisco",
        "shipping[address][state]": "CA",
        "shipping[address][country]": "US",
      };
      log(paymentModel.value.strip!.stripeSecret.toString());
      var stripeSecret = paymentModel.value.strip!.stripeSecret;
      var response = await http.post(Uri.parse('https://api.stripe.com/v1/payment_intents'),
          body: body, headers: {'Authorization': 'Bearer $stripeSecret', 'Content-Type': 'application/x-www-form-urlencoded'});

      return jsonDecode(response.body);
    } catch (e) {
      log(e.toString());
    }
  }

  // ::::::::::::::::::::::::::::::::::::::::::::PayPal::::::::::::::::::::::::::::::::::::::::::::::::::::
  Future<void> payPalPayment({required String amount}) async {
    int finalAmount = amount.toInt();

    ShowToastDialog.closeLoader();
    await Get.to(() => PaypalPayment(
          onFinish: (result) {
            if (result != null) {
              Get.back();
              ShowToastDialog.showToast("Payment Successful".tr);
              rentalModel.value.paymentStatus = true;
              completeOrder(result['orderId']);
            } else {
              ShowToastDialog.showToast("Payment canceled or failed.".tr);
            }
          },
          price: finalAmount.toString(),
          currencyCode: "USD",
          title: "Payment for services",
          description: "Payment for Ride booking services",
        ));
  }

  // ::::::::::::::::::::::::::::::::::::::::::::Razor Pay::::::::::::::::::::::::::::::::::::::::::::::::::::
  Future<void> razorpayMakePayment({required String amount}) async {
    try {
      int finalAmount = amount.toInt();
      ShowToastDialog.showLoader("Please wait".tr);
      var options = {
        'key': paymentModel.value.razorpay!.razorpayKey,
        "razorPaySecret": paymentModel.value.razorpay!.razorpayKey,
        'amount': double.parse(finalAmount.toString()) * 100,
        "currency": "INR",
        'name': userModel.value.fullName,
        "isSandBoxEnabled": paymentModel.value.razorpay!.isSandbox,
        'external': {
          'wallets': ['paytm']
        },
        'send_sms_hash': true,
        'prefill': {'contact': userModel.value.phoneNumber, 'email': userModel.value.email},
      };

      _razorpay.open(options);
      _razorpay.on(razor_pay_flutter.Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
      _razorpay.on(razor_pay_flutter.Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
      _razorpay.on(razor_pay_flutter.Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    } catch (e) {
      log('Error in razorpayMakePayment: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    ShowToastDialog.showToast("Payment Successfully".tr);
    rentalModel.value.paymentStatus = true;
    completeOrder(response.paymentId ?? DateTime.now().millisecondsSinceEpoch.toString());
    log('Payment Success: ${response.paymentId}');
    _razorpay.clear();
    _razorpay = razor_pay_flutter.Razorpay();
    log('========@@=====------------==call razor pay');

    ShowToastDialog.closeLoader();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Payment failure logic
    log('Payment Error: ${response.code} - ${response.message}');
    ShowToastDialog.showToast('Payment failed. Please try again.'.tr);
    ShowToastDialog.closeLoader();
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // External wallet selection logic
    log('External Wallet: ${response.walletName}');
    ShowToastDialog.closeLoader();
  }

  // ::::::::::::::::::::::::::::::::::::::::::::FlutterWave::::::::::::::::::::::::::::::::::::::::::::::::::::
  Future<Null> flutterWaveInitiatePayment({required BuildContext context, required String amount}) async {
    int finalAmount = amount.toInt();

    final url = Uri.parse('https://api.flutterwave.com/v3/payments'.tr);
    final headers = {
      'Authorization': 'Bearer ${paymentModel.value.flutterWave!.secretKey}',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      "tx_ref": _ref,
      "amount": finalAmount,
      "currency": "USD",
      "redirect_url": '${paymentModel.value.flutterWave!.callBackUrl.toString()}/success',
      "payment_options": "ussd, card, barter, payattitude",
      "customer": {
        "email": userModel.value.email.toString(),
        "phonenumber": userModel.value.phoneNumber,
        "name": userModel.value.fullName!,
      },
      "customizations": {
        "title": "Payment for Services",
        "description": "Payment for Ride booking services",
      }
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      ShowToastDialog.closeLoader();
      await Get.to(FlutterWaveScreen(
        initialURl: data['data']['link'],
        callBackUrl: paymentModel.value.flutterWave!.callBackUrl.toString(),
      ))!
          .then((value) {
        if (value != null) {
          log(":::::::::::::::::::::::::::::::::::$value");
          if (value) {
            log(":::::::::::::::::::::::::::::::::::$data");
            ShowToastDialog.showToast("Payment Successful!!".tr);
            rentalModel.value.paymentStatus = true;

            completeOrder(_ref ?? '');
          } else {
            ShowToastDialog.showToast("Payment UnSuccessful!!".tr);
          }
        } else {
          ShowToastDialog.showToast("Payment UnSuccessful!!".tr);
        }
      });
    } else {
      return null;
    }
  }

  String? _ref;

  void setRef() {
    maths.Random numRef = maths.Random();
    int year = DateTime.now().year;
    int refNumber = numRef.nextInt(20000);
    if (Platform.isAndroid) {
      _ref = "AndroidRef$year$refNumber";
    } else if (Platform.isIOS) {
      _ref = "IOSRef$year$refNumber";
    }
  }

  // ::::::::::::::::::::::::::::::::::::::::::::PayStack::::::::::::::::::::::::::::::::::::::::::::::::::::

  Future<void> payStackPayment(String totalAmount) async {
    int finalAmount = totalAmount.toInt();

    await PayStackURLGen.payStackURLGen(
            amount: (double.parse(finalAmount.toString()) * 100).toString(),
            currency: "NGN",
            secretKey: paymentModel.value.payStack!.payStackSecret.toString(),
            userModel: userModel.value)
        .then((value) async {
      if (value != null) {
        PayStackUrlModel payStackModel = value;
        ShowToastDialog.closeLoader();

        await Get.to(PayStackScreen(
          secretKey: paymentModel.value.payStack!.payStackSecret.toString(),
          callBackUrl: paymentModel.value.payStack!.callBackUrl.toString(),
          initialURl: payStackModel.data.authorizationUrl,
          amount: finalAmount.toString(),
          reference: payStackModel.data.reference,
        ))!
            .then((value) {
          if (value) {
            ShowToastDialog.showToast("Payment Successful!!".tr);
            rentalModel.value.paymentStatus = true;

            completeOrder(DateTime.now().millisecondsSinceEpoch.toString());
          } else {
            ShowToastDialog.showToast("Payment UnSuccessful!!".tr);
          }
        });
      } else {
        ShowToastDialog.showToast("Something went wrong, please contact admin.".tr);
      }
    });
  }

  // ::::::::::::::::::::::::::::::::::::::::::::Mercado Pago::::::::::::::::::::::::::::::::::::::::::::::::::::
  void mercadoPagoMakePayment({required BuildContext context, required String amount}) {
    makePreference(amount).then((result) async {
      try {
        print("=======>mercadoPagoMakePayment");
        print(result);
        if (result.isNotEmpty) {
          log(result.toString());
          if (result['status'] == 200 || result['status'] == 201) {
            await Get.to(MercadoPagoScreen(
              initialURl: result['response']['init_point'],
              callBackUrl: "${paymentModel.value.mercadoPago!.callBackUrl}",
            ))!
                .then((value) {
              if (value == true) {
                ShowToastDialog.showToast("Payment Successful!".tr);
                completeOrder(DateTime.now().millisecondsSinceEpoch.toString());
              } else {
                ShowToastDialog.showToast("Payment failed!".tr);
              }
            });
          } else {
            ShowToastDialog.showToast("Error while transaction!".tr);
          }
        } else {
          ShowToastDialog.showToast("Error while transaction!".tr);
        }
      } catch (e) {
        ShowToastDialog.showToast("Something went wrong.".tr);
      }
    });
  }

  Future<Map<String, dynamic>> makePreference(String amount) async {
    final mp = MP.fromAccessToken(paymentModel.value.mercadoPago!.mercadoPagoAccessToken);
    var pref = {
      "items": [
        {"title": "Wallet TopUp", "quantity": 1, "unit_price": double.parse(amount)}
      ],
      "auto_return": "all",
      "back_urls": {
        "failure": "${paymentModel.value.mercadoPago!.callBackUrl}/failure",
        "pending": "${paymentModel.value.mercadoPago!.callBackUrl}/pending",
        "success": "${paymentModel.value.mercadoPago!.callBackUrl}/success"
      },
    };

    var result = await mp.createPreference(pref);
    return result;
  }

  // ::::::::::::::::::::::::::::::::::::::::::::Pay Fast::::::::::::::::::::::::::::::::::::::::::::::::::::

  void payFastPayment({required BuildContext context, required String amount}) {
    int finalAmount = amount.toInt();

    PayStackURLGen.getPayHTML(payFastSettingData: paymentModel.value.payFast!, amount: finalAmount.toString(), userModel: userModel.value).then((String? value) async {
      bool isDone = await Get.to(PayFastScreen(htmlData: value!, payFastSettingData: paymentModel.value.payFast!));
      if (isDone) {
        Get.back();
        ShowToastDialog.showToast("Payment successfully".tr);
        rentalModel.value.paymentStatus = true;
        completeOrder(DateTime.now().millisecondsSinceEpoch.toString());
      } else {
        Get.back();
        ShowToastDialog.showToast("Payment Failed".tr);
      }
    });
  }

  // :::::::::::::::::::::::::::::::::::::::::::: Xendit ::::::::::::::::::::::::::::::::::::::::::::::::::::
  Future<void> xenditPayment({required BuildContext context, required String amount}) async {
    await createXenditInvoice(amount: double.parse(amount)).then((value) {
      // ShowToastDialog.closeLoader();
      if (value != null) {
        Get.to(
          () => XenditPaymentScreen(
            apiKey: Constant.paymentModel!.xendit!.xenditSecretKey.toString(),
            transId: value.id,
            invoiceUrl: value.invoiceUrl,
          ),
        )!
            .then((value) {
          if (value == true) {
            Get.back();
            ShowToastDialog.showToast("Payment successfully".tr);
            rentalModel.value.paymentStatus = true;
            completeOrder(DateTime.now().millisecondsSinceEpoch.toString());
          } else {
            log("====>Payment Faild");
            // ShowToastDialog.showToast("Payment Unsuccessful!!".tr);
          }
        });
      }
    });
  }

  Future<XenditModel?> createXenditInvoice({required num amount}) async {
    const url = 'https://api.xendit.co/v2/invoices';

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': generateBasicAuthHeader(Constant.paymentModel!.xendit!.xenditSecretKey.toString()),
    };

    final body = jsonEncode({
      'external_id': const Uuid().v1(),
      'amount': amount,
      'payer_email': userModel.value.email.toString(),
      'description': 'Wallet Topup',
      'currency': 'IDR', // Change if needed
    });

    try {
      final response = await http.post(Uri.parse(url), headers: headers, body: body);

      log(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return XenditModel.fromJson(jsonDecode(response.body));
      } else {
        log("❌ Xendit Error: ${response.body}");
        return null;
      }
    } catch (e) {
      log("⚠️ Exception: $e");
      return null;
    }
  }

  String generateBasicAuthHeader(String apiKey) {
    String credentials = '$apiKey:';
    String base64Encoded = base64Encode(utf8.encode(credentials));
    return 'Basic $base64Encoded';
  }

// :::::::::::::::::::::::::::::::::::::::::::: MidTrans ::::::::::::::::::::::::::::::::::::::::::::::::::::

  Future<void> midtransPayment({required BuildContext context, required String amount}) async {
    final url = await createMidtransPaymentLink(
      orderId: 'order-${DateTime.now().millisecondsSinceEpoch}',
      amount: double.parse(amount),
      customerEmail: userModel.value.email.toString(),
    );

    if (url != null) {
      final result = await Get.to(() => MidtransPaymentScreen(paymentUrl: url));
      if (result == true) {
        Get.back();
        ShowToastDialog.showToast("Payment successfully".tr);
        rentalModel.value.paymentStatus = true;
        completeOrder(DateTime.now().millisecondsSinceEpoch.toString());
      } else {
        if (kDebugMode) {
          print("Payment Failed or Cancelled".tr);
        }
      }
    }
  }

  Future<String?> createMidtransPaymentLink({required String orderId, required double amount, required String customerEmail}) async {
    final String ordersId = orderId.isNotEmpty ? orderId : const Uuid().v1();

    final Uri url = Uri.parse('https://api.sandbox.midtrans.com/v1/payment-links'); // Use production URL for live

    final Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': generateBasicAuthHeader(Constant.paymentModel!.midtrans!.midtransSecretKey.toString()),
    };

    final Map<String, dynamic> body = {
      'transaction_details': {'order_id': ordersId, 'gross_amount': amount.toInt()},
      'item_details': [
        {'id': 'item-1', 'name': 'Sample Product', 'price': amount.toInt(), 'quantity': 1},
      ],
      'customer_details': {'first_name': 'John', 'last_name': 'Doe', 'email': customerEmail, 'phone': '081234567890'},
      'redirect_url': 'https://www.google.com?merchant_order_id=$ordersId',
      'usage_limit': 2,
    };

    final response = await http.post(url, headers: headers, body: jsonEncode(body));

    if (response.statusCode == 201 || response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return responseData['payment_url']; // ✅ Correct field
    } else {
      if (kDebugMode) {
        print('Error creating payment link: ${response.body}');
      }
      return null;
    }
  }

  Future<void> checkSOSAvailability() async {
    FirebaseFirestore.instance
        .collection(CollectionName.sosAlerts)
        .where('bookingId', isEqualTo: rentalModel.value.id)
        .where('userId', isEqualTo: FireStoreUtils.getCurrentUid())
        .where('type', isEqualTo: 'customer')
        .limit(1)
        .snapshots()
        .listen(
      (event) {
        canShowSOS.value = event.docs.isEmpty;
      },
    );
  }

  Future<void> callOnHelpline() async {
    try {
      ShowToastDialog.showLoader("Sending SOS...".tr);
      final Position position = await Geolocator.getCurrentPosition(locationSettings: LocationSettings(accuracy: LocationAccuracy.high));

      sosAlertsModel.value.id = Constant.getUuid();
      sosAlertsModel.value.userId = FireStoreUtils.getCurrentUid();
      sosAlertsModel.value.bookingId = rentalModel.value.id;
      sosAlertsModel.value.driverId = rentalModel.value.driverId;
      sosAlertsModel.value.createdAt = Timestamp.now();
      sosAlertsModel.value.location = LocationLatLng(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      sosAlertsModel.value.emergencyType = "call${Constant.sosAlertNumber}";
      sosAlertsModel.value.type = Constant.typeCustomer;
      sosAlertsModel.value.status = "pending";

      await FireStoreUtils.addSOSAlerts(sosAlertsModel.value);
      ShowToastDialog.closeLoader();

      final Uri uri = Uri(scheme: 'tel', path: Constant.sosAlertNumber);

      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast("Unable to initiate SOS".tr);
      log("call911 error: $e");
    }
  }

  void getEmergencyContacts() {
    FireStoreUtils.getEmergencyContacts((updatedList) {
      final uniquePersons = <String, EmergencyContactModel>{};

      for (final person in updatedList) {
        final id = person.id;
        if (id != null && id.isNotEmpty) {
          uniquePersons[id] = person;
        }
      }

      totalEmergencyContacts.value = uniquePersons.values.toList();

      update();
    });
  }

  Future<void> notifySelectedContacts() async {
    ShowToastDialog.showLoader("Please Wait..".tr);
    if (selectedEmergencyContactIds.isEmpty) {
      ShowToastDialog.showToast("Please select at least one contact".tr);
      ShowToastDialog.closeLoader();
      return;
    }
    try {
      final Position position = await Geolocator.getCurrentPosition(locationSettings: LocationSettings(accuracy: LocationAccuracy.high));
      final selectedContacts = totalEmergencyContacts.where((c) => selectedEmergencyContactIds.contains(c.id)).toList();

      sosAlertsModel.value.id = Constant.getUuid();
      sosAlertsModel.value.userId = FireStoreUtils.getCurrentUid();
      sosAlertsModel.value.bookingId = rentalModel.value.id;
      sosAlertsModel.value.driverId = rentalModel.value.driverId;
      sosAlertsModel.value.contactIds = selectedEmergencyContactIds;
      sosAlertsModel.value.createdAt = Timestamp.now();
      sosAlertsModel.value.location = LocationLatLng(latitude: position.latitude, longitude: position.longitude);
      sosAlertsModel.value.emergencyType = "contacts";
      sosAlertsModel.value.type = Constant.typeCustomer;
      sosAlertsModel.value.status = "pending";

      await FireStoreUtils.addSOSAlerts(sosAlertsModel.value).then(
        (value) {
          ShowToastDialog.closeLoader();
        },
      );
      final String message = "🚨 EMERGENCY ALERT – RENTAL RIDE 🚨\n\n"
          "This is an emergency during an active rental ride.\n"
          "Please provide immediate help.\n\n"
          "Booking ID: ${rentalModel.value.id}\n\n"
          "Current Location:\n"
          "https://maps.google.com/?q=${position.latitude},${position.longitude}";

      for (final contact in selectedContacts) {
        final phone = "${contact.countryCode}${contact.phoneNumber}".replaceAll(" ", "");

        final Uri smsUri = Uri(
          scheme: 'sms',
          path: phone,
          queryParameters: {'body': message},
        );

        if (await canLaunchUrl(smsUri)) {
          await launchUrl(
            smsUri,
            mode: LaunchMode.externalApplication,
          );
        }
      }
      Get.back();
      ShowToastDialog.showToast("Emergency contacts notified".tr);
    } catch (e) {
      log('Error notifying contacts: $e');
    }
  }
}

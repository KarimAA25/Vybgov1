// ignore_for_file: unnecessary_overrides, non_constant_identifier_names

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as maths;

// ignore_for_file: depend_on_referenced_packages
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/app/models/bank_detail_model.dart';
import 'package:driver/app/models/driver_user_model.dart';
import 'package:driver/app/models/payment_method_model.dart';
import 'package:driver/app/models/payment_model/stripe_failed_model.dart';
import 'package:driver/app/models/wallet_transaction_model.dart';
import 'package:driver/app/modules/home/controllers/home_controller.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/constant_widgets/show_toast_dialog.dart';
import 'package:driver/payments/flutter_wave/flutter_wave.dart';
import 'package:driver/payments/marcado_pago/mercado_pago_screen.dart';
import 'package:driver/payments/midtrans/midtrans_payment_screen.dart';
import 'package:driver/payments/pay_fast/pay_fast_screen.dart';
import 'package:driver/payments/pay_stack/pay_stack_screen.dart';
import 'package:driver/payments/pay_stack/pay_stack_url_model.dart';
import 'package:driver/payments/pay_stack/paystack_url_generator.dart';
import 'package:driver/payments/paypal/PaypalPayment.dart';
import 'package:driver/payments/xendit/xendit_model.dart';
import 'package:driver/payments/xendit/xendit_payment_screen.dart';
import 'package:driver/services/email_template_service.dart';
import 'package:driver/theme/app_them_data.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// import 'package:flutter_paypal_native/flutter_paypal_native.dart';
// import 'package:flutter_paypal_native/models/custom/currency_code.dart';
// import 'package:flutter_paypal_native/models/custom/environment.dart';
// import 'package:flutter_paypal_native/models/custom/order_callback.dart';
// import 'package:flutter_paypal_native/models/custom/purchase_unit.dart';
// import 'package:flutter_paypal_native/models/custom/user_action.dart';
// import 'package:flutter_paypal_native/str_helper.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

// import 'package:flutterwave_standard/flutterwave.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mp_integration/mp_integration.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart' as razor_pay_flutter;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../models/transaction_log_model.dart';

class MyWalletController extends GetxController {
  TextEditingController amountController = TextEditingController(text: "100");
  TextEditingController withdrawalAmountController = TextEditingController(text: "100");
  TextEditingController withdrawalNoteController = TextEditingController();
  Rx<PaymentModel> paymentModel = PaymentModel().obs;
  RxString selectedPaymentMethod = "".obs;
  razor_pay_flutter.Razorpay _razorpay = razor_pay_flutter.Razorpay();
  Rx<DriverUserModel> userModel = DriverUserModel().obs;
  Rx<BankDetailsModel> selectedBankMethod = BankDetailsModel().obs;
  RxList<WalletTransactionModel> walletTransactionList = <WalletTransactionModel>[].obs;
  RxList<BankDetailsModel> bankDetailsList = <BankDetailsModel>[].obs;
  RxInt selectedTabIndex = 0.obs;
  Rx<GlobalKey<FormState>> formKey = GlobalKey<FormState>().obs;

  Rx<TransactionLogModel> transactionLogModel = TransactionLogModel().obs;

  @override
  void onInit() {
    getPayments();
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    _razorpay.clear();
    super.onClose();
  }

  Future<void> getPayments() async {
    ShowToastDialog.showLoader("Please Wait..".tr);
    await FireStoreUtils().getPayment().then((value) {
      if (value != null) {
        paymentModel.value = value;
        if (paymentModel.value.strip!.isActive == true) {
          Stripe.publishableKey = paymentModel.value.strip!.clientPublishableKey.toString();
          Stripe.merchantIdentifier = 'MyTaxi';
          Stripe.instance.applySettings();
        }
        if (paymentModel.value.paypal!.isActive == true) {
          // initPayPal();
        }
        if (paymentModel.value.flutterWave!.isActive == true) {
          setRef();
        }
      }
    });
    await getWalletTransactions();
    await getProfileData();
    await getBankDetails();
    ShowToastDialog.closeLoader();
  }

  Future<void> getBankDetails() async {
    bankDetailsList.clear();
    final value = await FireStoreUtils.getBankDetailList(FireStoreUtils.getCurrentUid());
    bankDetailsList.addAll(value);
    if (bankDetailsList.isNotEmpty) selectedBankMethod.value = bankDetailsList[0];
  }

  Future<void> getWalletTransactions() async {
    walletTransactionList.value = await FireStoreUtils.getWalletTransaction();
  }

  Future<void> getProfileData() async {
    final value = await FireStoreUtils.getDriverUserProfile(FireStoreUtils.getCurrentUid());
    if (value != null) {
      userModel.value = value;
    }
  }

  Future<void> setTransactionLog({
    required String transactionId,
    dynamic transactionLog,
    required bool isCredit,
  }) async {
    log('============> selectedPaymentMethod.value ${selectedPaymentMethod.value}');

    transactionLogModel.value.amount = amountController.text;
    transactionLogModel.value.transactionId = transactionId;
    transactionLogModel.value.id = transactionId;
    transactionLogModel.value.transactionLog = transactionLog.toString();
    transactionLogModel.value.isCredit = isCredit;
    transactionLogModel.value.createdAt = Timestamp.now();
    transactionLogModel.value.userId = FireStoreUtils.getCurrentUid();
    transactionLogModel.value.paymentType = selectedPaymentMethod.value;
    transactionLogModel.value.type = 'wallet';

    await FireStoreUtils.setTransactionLog(transactionLogModel.value);
  }

  Future<void> completeOrder(String transactionId) async {
    log("====> 2");

    WalletTransactionModel transactionModel = WalletTransactionModel(
        id: Constant.getUuid(),
        amount: amountController.value.text,
        createdDate: Timestamp.now(),
        paymentType: selectedPaymentMethod.value,
        transactionId: transactionId,
        userId: FireStoreUtils.getCurrentUid(),
        isCredit: true,
        type: "driver",
        note: "Wallet Top up");
    ShowToastDialog.showLoader("Please Wait..".tr);
    await FireStoreUtils.setWalletTransaction(transactionModel).then((value) async {
      if (value == true) {
        await FireStoreUtils.updateDriverUserWallet(amount: amountController.value.text).then((value) async {
          await getProfileData();
          Constant.userModel = userModel.value;
          await getWalletTransactions();
        });
      }
    });
    ShowToastDialog.closeLoader();
    ShowToastDialog.showToast("Amount added in your wallet.".tr);

    HomeController homeController = Get.put(HomeController());
    await EmailTemplateService.sendEmail(
      type: 'wallet_topup',
      toEmail: userModel.value.email.toString(),
      variables: {
        'name': userModel.value.fullName.toString(),
        'amount': amountController.value.text,
        'balance': userModel.value.walletAmount.toString(),
      },
    );
    homeController.isLoading.value = false;
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
        ShowToastDialog.showToast("exception:$e \n$s");
      }
    } catch (e) {
      log('Existing in stripeMakePayment: $e');
    }
  }

  Future<void> displayStripePaymentSheet({required String amount, required String client_secret}) async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) async {
        ShowToastDialog.showToast("Payment successfully".tr);
        await Stripe.instance.retrievePaymentIntent(client_secret).then(
          (value) {
            log('=================> Stripe  payment  ========> ${value.toJson()}');
            completeOrder(value.id);
            setTransactionLog(isCredit: true, transactionId: value.id, transactionLog: value);
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
    ShowToastDialog.closeLoader();
    await Get.to(() => PaypalPayment(
          onFinish: (result) {
            if (result != null) {
              Get.back();
              ShowToastDialog.showToast("Payment Successful".tr);
              completeOrder(result['orderId']);
              setTransactionLog(isCredit: true, transactionId: result['orderId'], transactionLog: result);
            } else {
              ShowToastDialog.showToast("Payment canceled or failed.".tr);
            }
          },
          price: amount,
          currencyCode: "USD",
          title: "Add Money",
          description: "Add Balance in Wallet",
        ));
  }

  // ::::::::::::::::::::::::::::::::::::::::::::RazorPay::::::::::::::::::::::::::::::::::::::::::::::::::::

  Future<void> razorpayMakePayment({required String amount}) async {
    try {
      var options = {
        'key': paymentModel.value.razorpay!.razorpayKey,
        "razorPaySecret": paymentModel.value.razorpay!.razorpayKey,
        'amount': double.parse(amount) * 100,
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
      _razorpay.on(razor_pay_flutter.Razorpay.EVENT_PAYMENT_SUCCESS, (response) {
        log("====> 1");
        _handlePaymentSuccess(response);
      });
      _razorpay.on(razor_pay_flutter.Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
      _razorpay.on(razor_pay_flutter.Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    } catch (e) {
      log('Error in razorpayMakePayment: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Payment success logic
    ShowToastDialog.showToast("Payment Successfully".tr);
    log('Payment Success: ${response.paymentId}');
    ShowToastDialog.showToast("Payment Successfully".tr);
    log('=================> RazorPay  payFastPayment ========> ${response.paymentId}');
    completeOrder(response.paymentId ?? DateTime.now().millisecondsSinceEpoch.toString());
    setTransactionLog(
        isCredit: true,
        transactionId: response.paymentId.toString(),
        transactionLog: {response.paymentId, response.paymentId, response.data, response.orderId, response.signature});
    log('================> Payment Success: $response');
    log('================> Payment Success: ${response.data}');
    log('================> Payment Success: ${response.paymentId}');
    _razorpay.clear();
    _razorpay = razor_pay_flutter.Razorpay();
    ShowToastDialog.closeLoader();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Payment failure logic
    log('Payment Error: ${response.code} - ${response.message}');
    ShowToastDialog.showToast("Payment failed. Please try again.".tr);
    ShowToastDialog.closeLoader();
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // External wallet selection logic
    log('External Wallet: ${response.walletName}');
    ShowToastDialog.closeLoader();
  }

  // ::::::::::::::::::::::::::::::::::::::::::::FlutterWave::::::::::::::::::::::::::::::::::::::::::::::::::::
  Future<Null> flutterWaveInitiatePayment({required BuildContext context, required String amount}) async {
    final url = Uri.parse('https://api.flutterwave.com/v3/payments');
    final headers = {
      'Authorization': 'Bearer ${paymentModel.value.flutterWave!.secretKey}',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      "tx_ref": _ref,
      "amount": amount,
      "currency": "USD",
      "redirect_url": '${paymentModel.value.flutterWave!.callBackUrl}/success',
      "payment_options": "ussd, card, barter, payattitude",
      "customer": {
        "email": userModel.value.email.toString(),
        "phonenumber": userModel.value.phoneNumber,
        "name": userModel.value.fullName!,
      },
      "customizations": {
        "title": "Payment for Services",
        "description": "Payment for XYZ services",
      }
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      log('====================> flutter wave response.body11 ${response.body}');
      log('====================> flutter wave data $data');
      log('====================> flutter wave data ${data['data']}');
      ShowToastDialog.closeLoader();
      await Get.to(FlutterWaveScreen(initialURl: data['data']['link'], callBackUrl: "${paymentModel.value.mercadoPago!.callBackUrl}"))!.then((value) {
        if (value != null && value is Map<String, dynamic>) {
          log(":::::::::::::::::::::::::::::::::::$value");
          if (value["status"] == true) {
            log(":::::::::::::::::::::::::::::::::::$data");
            ShowToastDialog.showToast("Payment Successful!!".tr);
            log('=================> FlutterWaveScreen  payFastPayment ========> $value');
            log('=================> FlutterWaveScreen  tx_ref ========> ${value['tx_ref']}');
            log('=================> FlutterWaveScreen  response ========> ${value['response']}');
            log('=================> FlutterWaveScreen  transaction_id ========> ${value['transaction_id']}');
            completeOrder(_ref ?? '');
            setTransactionLog(isCredit: true, transactionId: value['transaction_id'], transactionLog: value);
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
    await PayStackURLGen.payStackURLGen(
            amount: (double.parse(totalAmount) * 100).toString(), currency: "ZAR", secretKey: paymentModel.value.payStack!.payStackSecret.toString(), userModel: userModel.value)
        .then((value) async {
      if (value != null) {
        PayStackUrlModel payStackModel = value;
        ShowToastDialog.closeLoader();
        await Get.to(PayStackScreen(
          secretKey: paymentModel.value.payStack!.payStackSecret.toString(),
          callBackUrl: "${paymentModel.value.payStack!.callBackUrl}",
          initialURl: payStackModel.data.authorizationUrl,
          amount: totalAmount,
          reference: payStackModel.data.reference,
        ))!
            .then((value) {
          if (value != null && value == true) {
            ShowToastDialog.showToast("Payment Successful!!".tr);
            completeOrder(value['transaction_id']);
            setTransactionLog(isCredit: true, transactionId: value['transaction_id'], transactionLog: value);
            // setTransactionLog(isCredit: true, transactionId: value['transaction_id'], transactionLog: value);
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
            Get.to(MercadoPagoScreen(
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
    log("==============>${paymentModel.value.mercadoPago!.callBackUrl}");
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
    PayStackURLGen.getPayHTML(payFastSettingData: paymentModel.value.payFast!, amount: amount.toString(), userModel: userModel.value).then((String? value) async {
      print("=======>payFastPayment");
      print(value);
      bool isDone = await Get.to(PayFastScreen(htmlData: value!, payFastSettingData: paymentModel.value.payFast!));
      if (isDone) {
        Get.back();
        ShowToastDialog.showToast("Payment successfully".tr);
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
            log("====>Payment success");
            // ShowToastDialog.showToast("Payment Successful!!".tr);
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
        if (kDebugMode) {
          print("Payment Success".tr);
        }
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
}

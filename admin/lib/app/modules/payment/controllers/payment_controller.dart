import 'dart:developer';

import 'package:admin/app/constant/show_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:admin/app/constant/constants.dart';
import 'package:admin/app/models/payment_method_model.dart';
import 'package:admin/app/utils/fire_store_utils.dart';

class PaymentController extends GetxController {
  // paypal
  Rx<TextEditingController> paypalNameController = TextEditingController().obs;
  Rx<TextEditingController> paypalClientKeyController = TextEditingController().obs;
  Rx<TextEditingController> paypalSecretKeyController = TextEditingController().obs;
  Rx<Status> isPaypalActive = Status.active.obs;
  Rx<Status> isPaypalSandBox = Status.active.obs;

  // payStack
  Rx<TextEditingController> payStackNameController = TextEditingController().obs;
  Rx<TextEditingController> payStackSecretKeyController = TextEditingController().obs;
  Rx<TextEditingController> payStackCallbackUrlController = TextEditingController().obs;
  Rx<Status> isPayStackActive = Status.active.obs;

  // razorpay
  Rx<TextEditingController> razorpayNameController = TextEditingController().obs;
  Rx<TextEditingController> razorpayKeyController = TextEditingController().obs;
  Rx<TextEditingController> razorpaySecretController = TextEditingController().obs;
  Rx<Status> isRazorpayActive = Status.active.obs;
  Rx<Status> isRazorPaySandBox = Status.active.obs;

  // stripe
  Rx<TextEditingController> stripeNameController = TextEditingController().obs;
  Rx<TextEditingController> clientPublishableKeyController = TextEditingController().obs;
  Rx<TextEditingController> stripeSecretKeyController = TextEditingController().obs;
  Rx<Status> isStripeActive = Status.active.obs;
  Rx<Status> isStripeSandBox = Status.active.obs;

  // mercadoPogo
  Rx<TextEditingController> mercadoPogoNameController = TextEditingController().obs;
  Rx<TextEditingController> mercadoPogoAccessTokenController = TextEditingController().obs;
  Rx<TextEditingController> mercadoPogoCallbackUrlController = TextEditingController().obs;
  Rx<Status> isMercadoPogoActive = Status.active.obs;

  // payFast
  Rx<TextEditingController> payFastNameController = TextEditingController().obs;
  Rx<TextEditingController> payFastMerchantKeyController = TextEditingController().obs;
  Rx<TextEditingController> payFastMerchantIDController = TextEditingController().obs;
  Rx<TextEditingController> payFastReturnUrlController = TextEditingController().obs;
  Rx<TextEditingController> payFastNotifyUrlController = TextEditingController().obs;
  Rx<TextEditingController> payFastCancelUrlController = TextEditingController().obs;
  Rx<Status> isPayFastSandBox = Status.active.obs;
  Rx<Status> isPayFastActive = Status.active.obs;

  // flutterWave
  Rx<TextEditingController> flutterWaveNameController = TextEditingController().obs;
  Rx<TextEditingController> flutterWavePublicKeyKeyController = TextEditingController().obs;
  Rx<TextEditingController> flutterWaveSecretKeyKeyController = TextEditingController().obs;
  Rx<TextEditingController> flutterWaveCallbackUrlController = TextEditingController().obs;
  Rx<Status> isFlutterWaveActive = Status.active.obs;
  Rx<Status> isFlutterWaveSandBox = Status.active.obs;

  //Midtrans
  Rx<TextEditingController> midTransNameController = TextEditingController().obs;
  Rx<TextEditingController> midTransIdController = TextEditingController().obs;
  Rx<TextEditingController> midTransClientKeyController = TextEditingController().obs;
  Rx<TextEditingController> midTransSecretKeyController = TextEditingController().obs;
  Rx<Status> isMidTransActive = Status.active.obs;
  Rx<Status> isMidTransSandBox = Status.active.obs;

  //Xendit
  Rx<TextEditingController> xenditNameController = TextEditingController().obs;
  Rx<TextEditingController> xenditSecretKeyController = TextEditingController().obs;
  Rx<Status> isXenditActive = Status.active.obs;
  Rx<Status> isXenditSandBox = Status.active.obs;

  //cash
  Rx<TextEditingController> cashNameController = TextEditingController().obs;
  Rx<Status> isCashActive = Status.active.obs;

  //wallet
  Rx<TextEditingController> walletNameController = TextEditingController().obs;
  Rx<Status> isWalletActive = Status.active.obs;

  Rx<PaymentModel> paymentModel = PaymentModel().obs;

  RxString title = "Payment".tr.obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() async {
    isLoading(true);
    await getPaymentData();
    isLoading(false);
    super.onInit();
  }

  Future<void> getPaymentData() async {
    await FireStoreUtils.getPayment().then((value) {
      if (value != null) {
        paymentModel.value = value;

        //Midtrans
        if (value.midtrans != null) {
          midTransNameController.value.text = paymentModel.value.midtrans!.name!;
          midTransClientKeyController.value.text = paymentModel.value.midtrans!.midtransClientKey!;
          midTransSecretKeyController.value.text = paymentModel.value.midtrans!.midtransSecretKey!;
          midTransIdController.value.text = paymentModel.value.midtrans!.midtransId!;
          isMidTransActive.value = paymentModel.value.midtrans!.isActive == true ? Status.active : Status.inactive;
          isMidTransSandBox.value = paymentModel.value.midtrans!.isSandbox == true ? Status.active : Status.inactive;
        }

        //Xendit
        if (value.xendit != null) {
          xenditNameController.value.text = paymentModel.value.xendit!.name!;
          xenditSecretKeyController.value.text = paymentModel.value.xendit!.xenditSecretKey!;
          isXenditActive.value = paymentModel.value.xendit!.isActive == true ? Status.active : Status.inactive;
          isXenditSandBox.value = paymentModel.value.xendit!.isSandbox == true ? Status.active : Status.inactive;
        }

        //paypal
        if (value.paypal != null) {
          paypalNameController.value.text = paymentModel.value.paypal!.name!;
          paypalClientKeyController.value.text = paymentModel.value.paypal!.paypalClient!;
          paypalSecretKeyController.value.text = paymentModel.value.paypal!.paypalSecret!;
          isPaypalActive.value = paymentModel.value.paypal!.isActive == true ? Status.active : Status.inactive;
          isPaypalSandBox.value = paymentModel.value.paypal!.isSandbox == true ? Status.active : Status.inactive;
        }
        //razorpay
        if (value.paypal != null) {
          razorpayNameController.value.text = paymentModel.value.razorpay!.name!;
          razorpayKeyController.value.text = paymentModel.value.razorpay!.razorpayKey!;
          razorpaySecretController.value.text = paymentModel.value.razorpay!.razorpaySecret!;
          isRazorpayActive.value = paymentModel.value.razorpay!.isActive == true ? Status.active : Status.inactive;
          isRazorPaySandBox.value = paymentModel.value.razorpay!.isSandbox == true ? Status.active : Status.inactive;
        }
        //stripe
        if (value.strip != null) {
          stripeNameController.value.text = paymentModel.value.strip!.name!;
          clientPublishableKeyController.value.text = paymentModel.value.strip!.clientPublishableKey!;
          stripeSecretKeyController.value.text = paymentModel.value.strip!.stripeSecret!;
          isStripeActive.value = paymentModel.value.strip!.isActive == true ? Status.active : Status.inactive;
          isStripeSandBox.value = paymentModel.value.strip!.isSandbox == true ? Status.active : Status.inactive;
        }

        //payStack
        if (value.payStack != null) {
          payStackNameController.value.text = paymentModel.value.payStack!.name!;
          payStackSecretKeyController.value.text = paymentModel.value.payStack!.payStackSecret!;
          payStackCallbackUrlController.value.text = paymentModel.value.payStack?.callBackUrl ?? "";
          isPayStackActive.value = paymentModel.value.payStack!.isActive == true ? Status.active : Status.inactive;
          // isPayStackSandBox.value = paymentModel.value.payStack!.isSandbox == true ? Status.active : Status.inactive;
        }

        //mercadoPogo
        if (value.mercadoPago != null) {
          mercadoPogoNameController.value.text = paymentModel.value.mercadoPago!.name!;
          mercadoPogoAccessTokenController.value.text = paymentModel.value.mercadoPago!.mercadoPagoAccessToken!;
          mercadoPogoCallbackUrlController.value.text = paymentModel.value.mercadoPago?.callBackUrl ?? "";
          isMercadoPogoActive.value = paymentModel.value.mercadoPago!.isActive == true ? Status.active : Status.inactive;
        }

        //payFast
        if (value.payFast != null) {
          payFastNameController.value.text = paymentModel.value.payFast!.name!;
          payFastMerchantKeyController.value.text = paymentModel.value.payFast!.merchantKey!;
          payFastMerchantIDController.value.text = paymentModel.value.payFast!.merchantId!;
          payFastReturnUrlController.value.text = paymentModel.value.payFast!.returnUrl!;
          payFastNotifyUrlController.value.text = paymentModel.value.payFast!.notifyUrl!;
          payFastCancelUrlController.value.text = paymentModel.value.payFast!.cancelUrl!;
          isPayFastActive.value = paymentModel.value.payFast!.isActive == true ? Status.active : Status.inactive;
          isPayFastSandBox.value = paymentModel.value.payFast!.isSandbox == true ? Status.active : Status.inactive;
        }

        //flutterWave
        if (value.flutterWave != null) {
          flutterWaveNameController.value.text = paymentModel.value.flutterWave!.name!;
          flutterWavePublicKeyKeyController.value.text = paymentModel.value.flutterWave!.publicKey!;
          flutterWaveSecretKeyKeyController.value.text = paymentModel.value.flutterWave!.secretKey!;
          // flutterWavePublicKeyKeyController.value.text = paymentModel.value.flutterWave!.flutterWaveKey!;
          flutterWaveCallbackUrlController.value.text = paymentModel.value.flutterWave?.callBackUrl ?? "";
          isFlutterWaveActive.value = paymentModel.value.flutterWave!.isActive == true ? Status.active : Status.inactive;
          isFlutterWaveSandBox.value = paymentModel.value.flutterWave!.isSandBox == true ? Status.active : Status.inactive;
        }

        //cash
        if (value.cash != null) {
          cashNameController.value.text = paymentModel.value.cash!.name!;
          isCashActive.value = paymentModel.value.cash!.isActive == true ? Status.active : Status.inactive;
        } else {
          log('No data of Cash');
        }

        //wallet
        if (value.wallet != null) {
          walletNameController.value.text = paymentModel.value.wallet!.name!;
          isWalletActive.value = paymentModel.value.wallet!.isActive == true ? Status.active : Status.inactive;
        }
      }
    });
  }

  Future savePayment() async {
    // PayPal
    if (paypalNameController.value.text.isEmpty) {
      return ShowToastDialog.errorToast("Please Add PayPal Name".tr);
    }

    //Midtrans
    else if (midTransNameController.value.text.isEmpty) {
      return ShowToastDialog.errorToast("Please Add MidTrans Name".tr);
    }

    //Xendit
    else if (xenditNameController.value.text.isEmpty) {
      return ShowToastDialog.errorToast("Please Add Xendit Name".tr);
    }

    // PayStack
    else if (payStackNameController.value.text.isEmpty) {
      return ShowToastDialog.errorToast("Please Add PayStack Name".tr);
    }

    // Razorpay (Eazopay)
    else if (razorpayNameController.value.text.isEmpty) {
      return ShowToastDialog.errorToast("Please Add Razorpay Name".tr);
    }

    // Stripe
    else if (stripeNameController.value.text.isEmpty) {
      return ShowToastDialog.errorToast("Please Add Stripe Name".tr);
    }

    // MercadoPago
    else if (mercadoPogoNameController.value.text.isEmpty) {
      return ShowToastDialog.errorToast("Please Add Mercado Pago Name".tr);
    }

    // PayFast
    else if (payFastNameController.value.text.isEmpty) {
      return ShowToastDialog.errorToast("Please Add PayFast Name".tr);
    }

    // FlutterWave
    else if (flutterWaveNameController.value.text.isEmpty) {
      return ShowToastDialog.errorToast("Please Add FlutterWave Name".tr);
    }

    // Cash
    else if (cashNameController.value.text.isEmpty) {
      return ShowToastDialog.errorToast("Please Add Cash Name".tr);
    }

    // Wallet
    else if (walletNameController.value.text.isEmpty) {
      return ShowToastDialog.errorToast("Please Add Wallet Name".tr);
    }

    // If all conditions are met, save the payment details
    else {
      Constant.waitingLoader();

      //Xendit
      paymentModel.value.xendit ??= Xendit();
      paymentModel.value.xendit!
        ..name = xenditNameController.value.text
        ..xenditSecretKey = xenditSecretKeyController.value.text
        ..isActive = isXenditActive.value == Status.active ? true : false
        ..isSandbox = isXenditSandBox.value == Status.active ? true : false;

      //MidTrans
      paymentModel.value.midtrans ??= Midtrans();
      paymentModel.value.midtrans!
        ..name = midTransNameController.value.text
        ..midtransClientKey = midTransClientKeyController.value.text
        ..midtransSecretKey = midTransSecretKeyController.value.text
        ..midtransId = midTransIdController.value.text
        ..isActive = isMidTransActive.value == Status.active ? true : false
        ..isSandbox = isMidTransSandBox.value == Status.active ? true : false;

      // PayPal
      paymentModel.value.paypal?.name = paypalNameController.value.text;
      paymentModel.value.paypal?.paypalClient = paypalClientKeyController.value.text;
      paymentModel.value.paypal?.paypalSecret = paypalSecretKeyController.value.text;
      paymentModel.value.paypal?.isActive = isPaypalActive.value == Status.active ? true : false;
      paymentModel.value.paypal?.isSandbox = isPaypalSandBox.value == Status.active ? true : false;

      // PayStack
      paymentModel.value.payStack?.name = payStackNameController.value.text;
      paymentModel.value.payStack?.payStackSecret = payStackSecretKeyController.value.text;
      paymentModel.value.payStack?.callBackUrl = payStackCallbackUrlController.value.text;
      paymentModel.value.payStack?.isActive = isPayStackActive.value == Status.active ? true : false;

      // Razorpay
      paymentModel.value.razorpay?.name = razorpayNameController.value.text;
      paymentModel.value.razorpay?.razorpayKey = razorpayKeyController.value.text;
      paymentModel.value.razorpay?.razorpaySecret = razorpaySecretController.value.text;
      paymentModel.value.razorpay?.isActive = isRazorpayActive.value == Status.active ? true : false;
      paymentModel.value.razorpay?.isSandbox = isRazorPaySandBox.value == Status.active ? true : false;

      // Stripe
      paymentModel.value.strip?.name = stripeNameController.value.text;
      paymentModel.value.strip?.clientPublishableKey = clientPublishableKeyController.value.text;
      paymentModel.value.strip?.stripeSecret = stripeSecretKeyController.value.text;
      paymentModel.value.strip?.isActive = isStripeActive.value == Status.active ? true : false;
      paymentModel.value.strip?.isSandbox = isStripeSandBox.value == Status.active ? true : false;

      // MercadoPago
      paymentModel.value.mercadoPago?.name = mercadoPogoNameController.value.text;
      paymentModel.value.mercadoPago?.mercadoPagoAccessToken = mercadoPogoAccessTokenController.value.text;
      paymentModel.value.mercadoPago?.callBackUrl = mercadoPogoCallbackUrlController.value.text;
      paymentModel.value.mercadoPago?.isActive = isMercadoPogoActive.value == Status.active ? true : false;

      // PayFast
      paymentModel.value.payFast?.name = payFastNameController.value.text;
      paymentModel.value.payFast?.merchantKey = payFastMerchantKeyController.value.text;
      paymentModel.value.payFast?.merchantId = payFastMerchantIDController.value.text;
      paymentModel.value.payFast?.returnUrl = payFastReturnUrlController.value.text;
      paymentModel.value.payFast?.notifyUrl = payFastNotifyUrlController.value.text;
      paymentModel.value.payFast?.cancelUrl = payFastCancelUrlController.value.text;
      paymentModel.value.payFast?.isActive = isPayFastActive.value == Status.active ? true : false;
      paymentModel.value.payFast?.isSandbox = isPayFastSandBox.value == Status.active ? true : false;

      // FlutterWave
      paymentModel.value.flutterWave?.name = flutterWaveNameController.value.text;
      paymentModel.value.flutterWave?.publicKey = flutterWavePublicKeyKeyController.value.text;
      paymentModel.value.flutterWave?.secretKey = flutterWaveSecretKeyKeyController.value.text;
      paymentModel.value.flutterWave?.callBackUrl = flutterWaveCallbackUrlController.value.text;
      paymentModel.value.flutterWave?.isActive = isFlutterWaveActive.value == Status.active ? true : false;
      paymentModel.value.flutterWave?.isSandBox = isFlutterWaveSandBox.value == Status.active ? true : false;

      // Cash
      paymentModel.value.cash?.name = cashNameController.value.text;
      paymentModel.value.cash?.isActive = isCashActive.value == Status.active ? true : false;

      // Wallet
      paymentModel.value.wallet?.name = walletNameController.value.text;
      paymentModel.value.wallet?.isActive = isWalletActive.value == Status.active ? true : false;

      // log details step by step
      log('PayPal: Name=${paymentModel.value.paypal?.name}, Client=${paymentModel.value.paypal?.paypalClient}, Secret=${paymentModel.value.paypal?.paypalSecret}, Active=${paymentModel.value.paypal?.isActive}, Sandbox=${paymentModel.value.paypal?.isSandbox}');
      log('PayStack: Name=${paymentModel.value.payStack?.name}, Secret=${paymentModel.value.payStack?.payStackSecret}, Active=${paymentModel.value.payStack?.isActive}');
      log('Razorpay: Name=${paymentModel.value.razorpay?.name}, Key=${paymentModel.value.razorpay?.razorpayKey}, Secret=${paymentModel.value.razorpay?.razorpaySecret}, Active=${paymentModel.value.razorpay?.isActive}, Sandbox=${paymentModel.value.razorpay?.isSandbox}');
      log('Stripe: Name=${paymentModel.value.strip?.name}, ClientPublishableKey=${paymentModel.value.strip?.clientPublishableKey}, Secret=${paymentModel.value.strip?.stripeSecret}, Active=${paymentModel.value.strip?.isActive}, Sandbox=${paymentModel.value.strip?.isSandbox}');
      log('MercadoPago: Name=${paymentModel.value.mercadoPago?.name}, AccessToken=${paymentModel.value.mercadoPago?.mercadoPagoAccessToken}, Active=${paymentModel.value.mercadoPago?.isActive}');
      log('PayFast: Name=${paymentModel.value.payFast?.name}, MerchantKey=${paymentModel.value.payFast?.merchantKey}, MerchantID=${paymentModel.value.payFast?.merchantId}, ReturnUrl=${paymentModel.value.payFast?.returnUrl}, NotifyUrl=${paymentModel.value.payFast?.notifyUrl}, CancelUrl=${paymentModel.value.payFast?.cancelUrl}, Active=${paymentModel.value.payFast?.isActive}, Sandbox=${paymentModel.value.payFast?.isSandbox}');
      log('FlutterWave: Name=${paymentModel.value.flutterWave?.name}, PublicKey=${paymentModel.value.flutterWave?.publicKey}, Active=${paymentModel.value.flutterWave?.isActive}, Sandbox=${paymentModel.value.flutterWave?.isSandBox}');
      log('Cash: Name=${paymentModel.value.cash?.name},cash active ${paymentModel.value.cash?.isActive} ');
      log('Wallet : Name=${paymentModel.value.wallet?.name},cash active ${paymentModel.value.wallet?.isActive} ');
      log('MidTrans: Name=${paymentModel.value.midtrans?.name}, MidTransSecret=${paymentModel.value.midtrans?.midtransSecretKey}, MidTransId=${paymentModel.value.midtrans?.midtransId}, MidTransClientKey=${paymentModel.value.midtrans?.midtransClientKey},Active=${paymentModel.value.midtrans?.isActive}, Sandbox=${paymentModel.value.midtrans?.isSandbox}');

      await FireStoreUtils.setPayment(paymentModel.value).then((value) {
        Get.back();
        ShowToastDialog.successToast("Payment status updated".tr);
      });
    }
  }
}

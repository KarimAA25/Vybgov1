import 'package:get/get.dart';

import '../modules/cab_ride_details/bindings/cab_ride_details_binding.dart';
import '../modules/cab_ride_details/views/cab_ride_details_view.dart';
import '../modules/cab_rides/bindings/cab_ride_binding.dart';
import '../modules/cab_rides/views/cab_ride_view.dart';
import '../modules/chat_screen/bindings/chat_screen_binding.dart';
import '../modules/chat_screen/views/chat_screen_view.dart';
import '../modules/coupon_screen/bindings/coupon_screen_binding.dart';
import '../modules/coupon_screen/views/coupon_screen_view.dart';
import '../modules/create_support_ticket/bindings/create_support_ticket_binding.dart';
import '../modules/create_support_ticket/views/create_support_ticket_view.dart';
import '../modules/edit_profile/bindings/edit_profile_binding.dart';
import '../modules/edit_profile/views/edit_profile_view.dart';
import '../modules/emergency_contacts/bindings/emergency_contacts_binding.dart';
import '../modules/emergency_contacts/views/emergency_contacts_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/html_view_screen/bindings/html_view_screen_binding.dart';
import '../modules/html_view_screen/views/html_view_screen_view.dart';
import '../modules/inbox_screen/bindings/inbox_screen_binding.dart';
import '../modules/inbox_screen/views/inbox_screen_view.dart';
import '../modules/intercity_rides/bindings/intercity_rides_binding.dart';
import '../modules/intercity_rides/views/intercity_rides_view.dart';
import '../modules/intro_screen/bindings/intro_screen_binding.dart';
import '../modules/intro_screen/views/intro_screen_view.dart';
import '../modules/language/bindings/language_binding.dart';
import '../modules/language/views/language_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/loyalty_point_screen/bindings/loyalty_point_screen_binding.dart';
import '../modules/loyalty_point_screen/views/loyalty_point_screen_view.dart';
import '../modules/my_wallet/bindings/my_wallet_binding.dart';
import '../modules/my_wallet/views/my_wallet_view.dart';
import '../modules/notification/bindings/notification_binding.dart';
import '../modules/notification/views/notification_view.dart';
import '../modules/parcel_rides/bindings/parcel_rides_binding.dart';
import '../modules/parcel_rides/views/parcel_rides_view.dart';
import '../modules/payment_method/bindings/payment_method_binding.dart';
import '../modules/payment_method/views/payment_method_view.dart';
import '../modules/permission/bindings/permission_binding.dart';
import '../modules/permission/views/permission_view.dart';
import '../modules/reason_for_cancel/bindings/reason_for_cancel_binding.dart';
import '../modules/reason_for_cancel/views/reason_for_cancel_view.dart';
import '../modules/reason_for_rental_cancel/bindings/rental_reason_for_cancel_binding.dart';
import '../modules/reason_for_rental_cancel/views/rental_reason_for_cancel_view.dart';
import '../modules/referral_screen/bindings/referral_screen_binding.dart';
import '../modules/referral_screen/views/referral_screen_view.dart';
import '../modules/rental_location/bindings/rental_location_binding.dart';
import '../modules/rental_location/views/rental_select_location_view.dart';
import '../modules/rental_ride_details/bindings/rental_ride_details_binding.dart';
import '../modules/rental_ride_details/views/rental_ride_details_view.dart';
import '../modules/rental_rides/bindings/rental_rides_bindings.dart';
import '../modules/rental_rides/views/rental_rides_view.dart';
import '../modules/review_screen/bindings/review_screen_binding.dart';
import '../modules/review_screen/views/review_screen_view.dart';
import '../modules/select_location/bindings/select_location_binding.dart';
import '../modules/select_location/views/select_location_view.dart';
import '../modules/signup/bindings/signup_binding.dart';
import '../modules/signup/views/signup_view.dart';
import '../modules/sos_request/bindings/sos_request_binding.dart';
import '../modules/sos_request/views/sos_request_view.dart';
import '../modules/splash_screen/bindings/splash_screen_binding.dart';
import '../modules/splash_screen/views/splash_screen_view.dart';
import '../modules/support_screen/bindings/support_screen_binding.dart';
import '../modules/support_screen/views/support_screen_view.dart';
import '../modules/support_ticket_details/bindings/support_ticket_details_binding.dart';
import '../modules/support_ticket_details/views/support_ticket_details_view.dart';
import '../modules/track_intercity_ride_screen/bindings/track_intercity_ride_screen_binding.dart';
import '../modules/track_intercity_ride_screen/views/track_intercity_ride_screen_view.dart';
import '../modules/track_parcel_ride_screen/bindings/track_parcel_ride_screen_binding.dart';
import '../modules/track_parcel_ride_screen/views/track_parcel_ride_screen_view.dart';
import '../modules/track_rental_ride_screen/bindings/track_rental_ride_screen_binding.dart';
import '../modules/track_rental_ride_screen/views/track_rental_ride_screen_view.dart';
import '../modules/track_ride_screen/bindings/track_ride_screen_binding.dart';
import '../modules/track_ride_screen/views/track_ride_screen_view.dart';
import '../modules/verify_otp/bindings/verify_otp_binding.dart';
import '../modules/verify_otp/views/verify_otp_view.dart';

// ignore_for_file: constant_identifier_names

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH_SCREEN;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.SPLASH_SCREEN,
      page: () => const SplashScreenView(),
      binding: SplashScreenBinding(),
    ),
    GetPage(
      name: _Paths.INTRO_SCREEN,
      page: () => const IntroScreenView(),
      binding: IntroScreenBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.VERIFY_OTP,
      page: () => const VerifyOtpView(),
      binding: VerifyOtpBinding(),
    ),
    GetPage(
      name: _Paths.SIGNUP,
      page: () => const SignupView(),
      binding: SignupBinding(),
    ),
    GetPage(
      name: _Paths.SELECT_LOCATION,
      page: () => const SelectLocationView(),
      binding: SelectLocationBinding(),
    ),
    GetPage(
      name: _Paths.COUPON_SCREEN,
      page: () => const CouponScreenView(),
      binding: CouponScreenBinding(),
    ),
    GetPage(
      name: _Paths.PAYMENT_METHOD,
      page: () => const PaymentMethodView(),
      binding: PaymentMethodBinding(),
    ),
    GetPage(
      name: _Paths.DAILY_RIDE,
      page: () => const CabRideView(),
      binding: CabRideBinding(),
    ),
    GetPage(
      name: _Paths.MY_RIDE_DETAILS,
      page: () => const CabRideDetailsView(),
      binding: CabRideDetailsBinding(),
    ),
    GetPage(
      name: _Paths.REASON_FOR_CANCEL,
      page: () => const ReasonForCancelView(),
      binding: ReasonForCancelBinding(),
    ),
    GetPage(
      name: _Paths.MY_WALLET,
      page: () => const MyWalletView(),
      binding: MyWalletBinding(),
    ),
    GetPage(
      name: _Paths.NOTIFICATION,
      page: () => const NotificationView(),
      binding: NotificationBinding(),
    ),
    GetPage(
      name: _Paths.EDIT_PROFILE,
      page: () => const EditProfileView(),
      binding: EditProfileBinding(),
    ),
    GetPage(
      name: _Paths.LANGUAGE,
      page: () => const LanguageView(),
      binding: LanguageBinding(),
    ),
    GetPage(
      name: _Paths.PERMISSION,
      page: () => const PermissionView(),
      binding: PermissionBinding(),
    ),
    GetPage(
      name: _Paths.HTML_VIEW_SCREEN,
      page: () => const HtmlViewScreenView(
        title: '',
        htmlData: '',
      ),
      binding: HtmlViewScreenBinding(),
    ),
    GetPage(
      name: _Paths.TRACK_RIDE_SCREEN,
      page: () => const TrackRideScreenView(),
      binding: TrackRideScreenBinding(),
    ),
    GetPage(
      name: _Paths.TRACK_INTERCITY_RIDE_SCREEN,
      page: () => const TrackInterCityRideScreenView(),
      binding: TrackInterCityRideScreenBinding(),
    ),
    GetPage(
      name: _Paths.TRACK_PARCEL_RIDE_SCREEN,
      page: () => const TrackParcelRideScreenView(),
      binding: TrackParcelRideScreenBinding(),
    ),
    GetPage(
      name: _Paths.CHAT_SCREEN,
      page: () => const ChatScreenView(
        receiverId: '',
      ),
      binding: ChatScreenBinding(),
    ),
    GetPage(
      name: _Paths.REVIEW_SCREEN,
      page: () => const ReviewScreenView(),
      binding: ReviewScreenBinding(),
    ),
    GetPage(
      name: _Paths.SUPPORT_SCREEN,
      page: () => const SupportScreenView(),
      binding: SupportScreenBinding(),
    ),
    GetPage(
      name: _Paths.CREATE_SUPPORT_TICKET,
      page: () => const CreateSupportTicketView(),
      binding: CreateSupportTicketBinding(),
    ),
    GetPage(
      name: _Paths.SUPPORT_TICKET_DETAILS,
      page: () => const SupportTicketDetailsView(),
      binding: SupportTicketDetailsBinding(),
    ),
    GetPage(
      name: _Paths.INTERCITY_RIDE,
      page: () => const InterCityRidesView(),
      binding: InterCityRidesBinding(),
    ),
    GetPage(
      name: _Paths.PARCEL_RIDE,
      page: () => const ParcelRidesView(),
      binding: ParcelRidesBinding(),
    ),
    GetPage(
      name: _Paths.RENTAL_LOCATION,
      page: () => const RentalLocationView(),
      binding: RentalLocationBinding(),
    ),
    GetPage(
      name: _Paths.RENTAL_RIDES,
      page: () => const RentalRidesView(),
      binding: RentalRidesBindings(),
    ),
    GetPage(
      name: _Paths.RENTAL_RIDE_DETAILS,
      page: () => const RentalRideDetailsView(),
      binding: RentalRideDetailsBinding(),
    ),
    GetPage(
      name: _Paths.REASON_FOR_RENTAL_CANCEL,
      page: () => const RentalReasonForCancelView(),
      binding: RentalReasonForCancelBinding(),
    ),
    GetPage(
      name: _Paths.TRACK_RENTAL_RIDE_SCREEN,
      page: () => const TrackRentalRideScreenView(),
      binding: TrackRentalRideScreenBinding(),
    ),
    GetPage(
      name: _Paths.REFERRAL_SCREEN,
      page: () => const ReferralScreenView(),
      binding: ReferralScreenBinding(),
    ),
    GetPage(
      name: _Paths.CHAT_INBOX,
      page: () => const InboxScreenView(),
      binding: InboxScreenBinding(),
    ),
    GetPage(
      name: _Paths.LOYALTY_POINT_SCREEN,
      page: () => const LoyaltyPointScreenView(),
      binding: LoyaltyPointScreenBinding(),
    ),
    GetPage(
      name: _Paths.EMERGENCY_CONTACTS,
      page: () => const EmergencyContactsView(),
      binding: EmergencyContactsBinding(),
    ),
    GetPage(
      name: _Paths.SOS_REQUEST,
      page: () => const SosRequestView(),
      binding: SosRequestBinding(),
    ),
  ];
}

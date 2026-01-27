import 'package:admin/app/modules/approved_drivers/bindings/approved_drivers_binding.dart';
import 'package:admin/app/modules/approved_drivers/views/approved_drivers_view.dart';
import 'package:get/get.dart';

import '../../auth_middleware.dart';
import '../modules/about_app/bindings/about_app_binding.dart';
import '../modules/about_app/views/about_app_view.dart';
import '../modules/add_notification/bindings/add_notification_binding.dart';
import '../modules/add_notification/views/add_notification_view.dart';
import '../modules/admin_profile/bindings/admin_profile_binding.dart';
import '../modules/admin_profile/views/admin_profile_view.dart';
import '../modules/app_settings/bindings/app_settings_binding.dart';
import '../modules/app_settings/views/app_settings_view.dart';
import '../modules/banner_screen/bindings/banner_screen_binding.dart';
import '../modules/banner_screen/views/banner_screen_view.dart';
import '../modules/business_model_setting/bindings/business_model_setting_binding.dart';
import '../modules/business_model_setting/views/business_model_setting_view.dart';
import '../modules/cab_bookings_screen/bindings/cab_bookings_binding.dart';
import '../modules/cab_bookings_screen/views/cab_booking_screen_view.dart';
import '../modules/cab_detail/bindings/cab_detail_binding.dart';
import '../modules/cab_detail/views/cab_detail_view.dart';
import '../modules/canceling_reason/bindings/canceling_reason_binding.dart';
import '../modules/canceling_reason/views/canceling_reason_view.dart';
import '../modules/contact_us/bindings/contact_us_binding.dart';
import '../modules/contact_us/views/contact_us_view.dart';
import '../modules/create_zone_screen/bindings/create_zone_screen_bindings.dart';
import '../modules/create_zone_screen/views/create_zone_screen_view.dart';
import '../modules/currency/bindings/currency_binding.dart';
import '../modules/currency/views/currency_view.dart';
import '../modules/customer_detail_screen/bindings/customer_detail_screen_binding.dart';
import '../modules/customer_detail_screen/views/customer_detail_screen_view.dart';
import '../modules/customers_screen/bindings/customers_screen_binding.dart';
import '../modules/customers_screen/views/customers_screen_view.dart';
import '../modules/dashboard_screen/bindings/dashboard_screen_binding.dart';
import '../modules/dashboard_screen/views/dashboard_screen_view.dart';
import '../modules/document_screen/bindings/document_screen_binding.dart';
import '../modules/document_screen/views/document_screen_view.dart';
import '../modules/driver_detail_screen/bindings/driver_detail_screen_binding.dart';
import '../modules/driver_detail_screen/views/driver_detail_screen_view.dart';
import '../modules/driver_screen/bindings/driver_screen_binding.dart';
import '../modules/driver_screen/views/driver_screen_view.dart';
import '../modules/email_template/bindings/email_template_binding.dart';
import '../modules/email_template/views/email_template_view.dart';
import '../modules/error_screen/bindings/error_screen_binding.dart';
import '../modules/error_screen/views/error_screen_view.dart';
import '../modules/general_setting/bindings/general_setting_binding.dart';
import '../modules/general_setting/views/general_setting_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/intercity_detail/bindings/intercity_detail_binding.dart';
import '../modules/intercity_detail/views/intercity_detail_view.dart';
import '../modules/intercity_service_screen/bindings/intercity_service_binding.dart';
import '../modules/intercity_service_screen/views/intercity_service_screen_view.dart';
import '../modules/interciyt_history_screen/bindings/intercity_history_screen_binding.dart';
import '../modules/interciyt_history_screen/views/intercity_history_screen_view.dart';
import '../modules/landing_page/bindings/landing_page_binding.dart';
import '../modules/landing_page/views/landing_page_view.dart';
import '../modules/language/bindings/language_binding.dart';
import '../modules/language/views/language_view.dart';
import '../modules/login_page/bindings/login_page_binding.dart';
import '../modules/login_page/views/login_page_view.dart';
import '../modules/map_settings/bindings/map_settings_binding.dart';
import '../modules/map_settings/views/map_settings_view.dart';
import '../modules/offers_screen/bindings/offers_screen_binding.dart';
import '../modules/offers_screen/views/offers_screen_view.dart';
import '../modules/onboarding_screen/bindings/onboarding_screen_binding.dart';
import '../modules/onboarding_screen/views/onboarding_screen_view.dart';
import '../modules/online_driver/bindings/online_driver_binding.dart';
import '../modules/online_driver/views/online_driver_view.dart';
import '../modules/parcel_detail/bindings/parcel_detail_binding.dart';
import '../modules/parcel_detail/views/parcel_detail_view.dart';
import '../modules/parcel_history_screen/bindings/parcel_history_screen_binding.dart';
import '../modules/parcel_history_screen/views/parcel_history_screen_view.dart';
import '../modules/payment/bindings/payment_binding.dart';
import '../modules/payment/views/payment_view.dart';
import '../modules/payout_request/bindings/payout_request_binding.dart';
import '../modules/payout_request/views/payout_request_view.dart';
import '../modules/privacy_policy/bindings/privacy_policy_binding.dart';
import '../modules/privacy_policy/views/privacy_policy_view.dart';
import '../modules/rental_ride_details/bindings/rental_ride_details_binding.dart';
import '../modules/rental_ride_details/views/rental_ride_details_view.dart';
import '../modules/rental_ride_screen/bindings/rental_ride_screen_binding.dart';
import '../modules/rental_ride_screen/views/rental_ride_screen_view.dart';
import '../modules/rental_screen/bindings/rental_package_screen_binding.dart';
import '../modules/rental_screen/views/rental_package_screen_view.dart';
import '../modules/setting_screen/bindings/setting_screen_binding.dart';
import '../modules/setting_screen/views/setting_screen_view.dart';
import '../modules/smtp_settings/bindings/smtp_settings_binding.dart';
import '../modules/smtp_settings/views/smtp_settings_view.dart';
import '../modules/sos_alerts/bindings/sos_alerts_binding.dart';
import '../modules/sos_alerts/views/sos_alerts_view.dart';
import '../modules/splash_screen/bindings/splash_screen_binding.dart';
import '../modules/splash_screen/views/splash_screen_view.dart';
import '../modules/subscription_history/bindings/subscription_history_binding.dart';
import '../modules/subscription_history/views/subscription_history_view.dart';
import '../modules/subscription_plan/bindings/subscription_plan_binding.dart';
import '../modules/subscription_plan/views/subscription_plan_view.dart';
import '../modules/support_reason/bindings/support_reason_binding.dart';
import '../modules/support_reason/views/support_reason_view.dart';
import '../modules/support_ticket_screen/bindings/support_ticket_screen_binding.dart';
import '../modules/support_ticket_screen/views/support_ticket_screen_view.dart';
import '../modules/tax/bindings/tax_binding.dart';
import '../modules/tax/views/tax_view.dart';
import '../modules/terms_Conditions/bindings/terms_conditions_binding.dart';
import '../modules/terms_Conditions/views/terms_conditions_view.dart';
import '../modules/vehicle_brand_screen/bindings/vehicle_brand_screen_binding.dart';
import '../modules/vehicle_brand_screen/views/vehicle_brand_screen_view.dart';
import '../modules/vehicle_model_screen/bindings/vehicle_model_screen_binding.dart';
import '../modules/vehicle_model_screen/views/vehicle_model_screen_view.dart';
import '../modules/vehicle_type_screen/bindings/vehicle_type_screen_binding.dart';
import '../modules/vehicle_type_screen/views/vehicle_type_screen_view.dart';
import '../modules/verify_driver_screen/bindings/verify_driver_screen_binding.dart';
import '../modules/verify_driver_screen/views/verify_driver_screen_view.dart';
import '../modules/zone_screen/bindings/zone_screen_bindings.dart';
import '../modules/zone_screen/views/zone_screen_view.dart';

// ignore_for_file: constant_identifier_names

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH_SCREEN;

  static final routes = [
    GetPage(
      name: _Paths.SPLASH_SCREEN,
      page: () => const SplashScreenView(),
      binding: SplashScreenBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: _Paths.LOGIN_PAGE,
      page: () => const LoginPageView(),
      binding: LoginPageBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
        name: _Paths.DASHBOARD_SCREEN, page: () => const DashboardScreenView(), binding: DashboardScreenBinding(), middlewares: [AuthMiddleware()], transition: Transition.fadeIn),
    GetPage(
        name: _Paths.CAB_BOOKING_SCREEN, page: () => const CabBookingScreenView(), binding: CabBookingsBinding(), middlewares: [AuthMiddleware()], transition: Transition.fadeIn),
    GetPage(
        name: _Paths.PARCEL_HISTORY_SCREEN,
        page: () => const ParcelHistoryScreenView(),
        binding: ParcelHistoryScreenBinding(),
        middlewares: [AuthMiddleware()],
        transition: Transition.fadeIn),
    GetPage(
        name: _Paths.INTERCITY_HISTORY_SCREEN,
        page: () => const InterCityHistoryScreenView(),
        binding: InterCityHistoryScreenBinding(),
        middlewares: [AuthMiddleware()],
        transition: Transition.fadeIn),
    GetPage(
        name: _Paths.CUSTOMERS_SCREEN, page: () => const CustomersScreenView(), binding: CustomersScreenBinding(), middlewares: [AuthMiddleware()], transition: Transition.fadeIn),
    GetPage(name: _Paths.DRIVER_SCREEN, page: () => const DriverScreenView(), binding: DriverScreenBinding(), transition: Transition.fadeIn),
    GetPage(
        name: _Paths.VERIFY_DRIVER_SCREEN,
        page: () => const VerifyDriverScreenView(),
        binding: VerifyDocumentScreenBinding(),
        middlewares: [AuthMiddleware()],
        transition: Transition.fadeIn),
    GetPage(name: _Paths.BANNER_SCREEN, page: () => const BannerScreenView(), binding: BannerScreenBinding(), transition: Transition.fadeIn),
    GetPage(name: _Paths.DOCUMENT_SCREEN, page: () => const DocumentScreenView(), binding: DocumentScreenBinding(), middlewares: [AuthMiddleware()], transition: Transition.fadeIn),
    GetPage(name: _Paths.OFFERS_SCREEN, page: () => const OffersScreenView(), binding: OffersScreenBinding(), transition: Transition.fadeIn),
    GetPage(
        name: _Paths.VEHICLE_BRAND_SCREEN,
        page: () => const VehicleBrandScreenView(),
        binding: VehicleBrandScreenBinding(),
        middlewares: [AuthMiddleware()],
        transition: Transition.fadeIn),
    GetPage(
        name: _Paths.VEHICLE_MODEL_SCREEN,
        page: () => const VehicleModelScreenView(),
        binding: VehicleModelScreenBinding(),
        middlewares: [AuthMiddleware()],
        transition: Transition.fadeIn),
    GetPage(
      name: _Paths.SETTING_SCREEN,
      page: () => const SettingScreenView(),
      binding: SettingScreenBinding(),
      transition: Transition.fadeIn,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.PAYOUT_REQUEST,
      page: () => const PayoutRequestView(),
      binding: PayoutRequestBinding(),
      transition: Transition.fadeIn,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.PAYMENT,
      page: () => const PaymentView(),
      binding: PaymentBinding(),
      transition: Transition.fadeIn,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.TAX,
      page: () => const TaxView(),
      binding: TaxBinding(),
      transition: Transition.fadeIn,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.CURRENCY,
      page: () => const CurrencyView(),
      binding: CurrencyBinding(),
      transition: Transition.fadeIn,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.APP_SETTINGS,
      page: () => const AppSettingsView(),
      binding: AppSettingsBinding(),
      transition: Transition.fadeIn,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.LANGUAGE,
      page: () => const LanguageView(),
      binding: LanguageBinding(),
      transition: Transition.fadeIn,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.ABOUT_APP,
      page: () => AboutAppView(),
      binding: AboutAppBinding(),
      transition: Transition.fadeIn,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.PRIVACY_POLICY,
      page: () => PrivacyPolicyView(),
      binding: PrivacyPolicyBinding(),
      transition: Transition.fadeIn,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.TERMS_CONDITIONS,
      page: () => TermsConditionsView(),
      binding: TermsConditionsBinding(),
      transition: Transition.fadeIn,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(name: _Paths.GENERAL_SETTING, page: () => const GeneralSettingView(), binding: GeneralSettingBinding(), middlewares: [AuthMiddleware()], transition: Transition.fadeIn),
    GetPage(
      name: _Paths.CONTACT_US,
      page: () => const ContactUsView(),
      binding: ContactUsBinding(),
      transition: Transition.fadeIn,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
        name: "${_Paths.CAB_DETAIL}/:bookingId", page: () => const CabDetailView(), binding: CabDetailBinding(), middlewares: [AuthMiddleware()], transition: Transition.fadeIn),
    GetPage(
        name: "${_Paths.PARCEL_DETAIL}/:parcelId",
        page: () => const ParcelDetailView(),
        binding: ParcelDetailBinding(),
        middlewares: [AuthMiddleware()],
        transition: Transition.fadeIn),
    GetPage(
        name: "${_Paths.INTERCITY_DETAIL}/:intercityId",
        page: () => const InterCityDetailView(),
        binding: InterCityDetailBinding(),
        middlewares: [AuthMiddleware()],
        transition: Transition.fadeIn),
    GetPage(
        name: _Paths.CANCELING_REASON, page: () => const CancelingReasonView(), binding: CancelingReasonBinding(), middlewares: [AuthMiddleware()], transition: Transition.fadeIn),
    GetPage(
      name: _Paths.ADMIN_PROFILE,
      page: () => const AdminProfileView(),
      binding: AdminProfileBinding(),
      transition: Transition.fadeIn,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
        name: _Paths.VEHICLE_TYPE_SCREEN,
        page: () => const VehicleTypeScreenView(),
        binding: VehicleTypeScreenBinding(),
        middlewares: [AuthMiddleware()],
        transition: Transition.fadeIn),
    GetPage(
      name: _Paths.ERROR_SCREEN,
      page: () => const ErrorScreenView(),
      binding: ErrorScreenBinding(),
      transition: Transition.fadeIn,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
        name: "${_Paths.CUSTOMER_DETAIL_SCREEN}/:userId",
        page: () => const CustomerDetailScreenView(),
        binding: CustomerDetailScreenBinding(),
        middlewares: [AuthMiddleware()],
        transition: Transition.fadeIn),
    GetPage(
        name: "${_Paths.DRIVER_DETAIL_SCREEN}/:driverId",
        page: () => const DriverDetailScreenView(),
        binding: DriverDetailScreenBinding(),
        middlewares: [AuthMiddleware()],
        transition: Transition.fadeIn),
    GetPage(
        name: _Paths.INTERCITY_SERVICE_SCREEN,
        page: () => const InterCityServiceScreenView(),
        binding: IntercityServiceScreenBinding(),
        middlewares: [AuthMiddleware()],
        transition: Transition.fadeIn),
    GetPage(
      name: _Paths.SUPPORT_REASON,
      page: () => const SupportReasonView(),
      binding: SupportReasonBinding(),
      transition: Transition.fadeIn,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
        name: _Paths.SUPPORT_TICKET_SCREEN,
        page: () => const SupportTicketScreenView(),
        binding: SupportTicketScreenBinding(),
        middlewares: [AuthMiddleware()],
        transition: Transition.fadeIn),
    GetPage(
        name: _Paths.SUBSCRIPTION_PLAN,
        page: () => const SubscriptionPlanView(),
        binding: SubscriptionPlanBinding(),
        middlewares: [AuthMiddleware()],
        transition: Transition.fadeIn),
    GetPage(
        name: _Paths.SUBSCRIPTION_HISTORY,
        page: () => const SubscriptionHistoryView(),
        binding: SubscriptionHistoryBinding(),
        middlewares: [AuthMiddleware()],
        transition: Transition.fadeIn),
    GetPage(
        name: _Paths.RENTAL_PACKAGE,
        page: () => const RentalPackageScreenView(),
        binding: RentalPackageScreenBinding(),
        middlewares: [AuthMiddleware()],
        transition: Transition.fadeIn),
    GetPage(
        name: _Paths.RENTAL_RIDE_SCREEN,
        page: () => const RentalRideScreenView(),
        binding: RentalRideScreenBinding(),
        middlewares: [AuthMiddleware()],
        transition: Transition.fadeIn),
    GetPage(
        name: "${_Paths.RENTAL_RIDE_DETAILS}/:rentalBookingId",
        page: () => const RentalRideDetailsView(),
        binding: RentalRideDetailsBinding(),
        middlewares: [AuthMiddleware()],
        transition: Transition.fadeIn),
    GetPage(
        name: _Paths.BUSINESS_MODEL_SETTING,
        page: () => const BusinessModelSettingView(),
        binding: BusinessModelSettingBinding(),
        middlewares: [AuthMiddleware()],
        transition: Transition.fadeIn),
    GetPage(
        name: _Paths.ON_BOARDING_SCREEN,
        page: () => const OnboardingScreenView(),
        binding: OnboardingScreenBinding(),
        middlewares: [AuthMiddleware()],
        transition: Transition.fadeIn),
    GetPage(
      name: _Paths.ZONE_SCREEN,
      page: () => const ZoneScreenView(),
      binding: ZoneScreenBindings(),
      transition: Transition.fadeIn,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.CREATE_ZONE_SCREEN,
      // Add mode
      page: () => const CreateZoneScreenView(),
      binding: CreateZoneScreenBindings(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: "${_Paths.CREATE_ZONE_SCREEN}/:zoneId",
      // Edit mode
      page: () => const CreateZoneScreenView(),
      binding: CreateZoneScreenBindings(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: _Paths.ADD_NOTIFICATION,
      page: () => const AddNotificationView(),
      binding: AddNotificationBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: _Paths.SMTP_SETTINGS,
      page: () => const SmtpSettingsView(),
      binding: SmtpSettingsBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: _Paths.EMAIL_TEMPLATE,
      page: () => const EmailTemplateView(),
      binding: EmailTemplateBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: _Paths.ONLINE_DRIVER,
      page: () => const OnlineDriverView(),
      binding: OnlineDriverBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: _Paths.LANDING_PAGE,
      page: () => const LandingPageView(),
      binding: LandingPageBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: _Paths.SOS_ALERTS,
      page: () => const SosAlertsView(),
      binding: SosAlertsBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: _Paths.MAP_SETTINGS,
      page: () => const MapSettingsView(),
      binding: MapSettingsBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: _Paths.APPROVED_DRIVERS,
      page: () => const ApprovedDriversView(),
      binding: ApprovedDriversBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),
  ];
}

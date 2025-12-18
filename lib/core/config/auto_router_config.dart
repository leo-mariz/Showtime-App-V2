import 'package:auto_route/auto_route.dart';
import 'package:app/core/config/auto_router_config.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen|Page,Route')
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => RouteType.material();

  @override
  List<AutoRoute> get routes => [
    // Authentication Routes
    AutoRoute(page: InitialRoute.page, path: '/', initial: true),
    AutoRoute(page: LoginRoute.page, path: '/login'),
    AutoRoute(page: RegisterRoute.page, path: '/register'),
    AutoRoute(page: ForgotPasswordRoute.page, path: '/forgot-password'),
    AutoRoute(page: EmailVerificationRoute.page, path: '/email-verification'),
    AutoRoute(page: OnboardingRoute.page, path: '/onboarding'),

    //Navigation Routes
    AutoRoute(page: NavigationRoute.page, path: '/home-page'),

    //Event Request and Contract Routes
    AutoRoute(page: RequestRoute.page, path: '/request'),
    AutoRoute(page: EventTypeSelectionRoute.page, path: '/event-type-selection'),
    AutoRoute(page: ClientEventDetailRoute.page, path: '/client-event-detail'),
    AutoRoute(page: ArtistEventDetailRoute.page, path: '/artist-event-detail'),

    //Artist Profile Routes
    AutoRoute(page: ArtistProfileRoute.page, path: '/artist-profile'),
    AutoRoute(page: ArtistAreaRoute.page, path: '/artist-area'),
    AutoRoute(page: RegisterDataAreaRoute.page, path: '/register-data-area'),
    AutoRoute(page: ProfessionalInfoRoute.page, path: '/professional-info'),
    AutoRoute(page: PresentationsRoute.page, path: '/presentations'),
    AutoRoute(page: AvailabilityRoute.page, path: '/availability'),

    //Artist Dashboard Routes

    //Profile Routes
    AutoRoute(page: PersonalInfoRoute.page, path: '/personal-info'),
    AutoRoute(page: AddressFormRoute.page, path: '/address-form'),
    AutoRoute(page: AddressesListRoute.page, path: '/addresses-list'),
    AutoRoute(page: LoginSecurityRoute.page, path: '/login-security'),
    AutoRoute(page: ChangePasswordRoute.page, path: '/change-password'),
    AutoRoute(page: LoginHistoryRoute.page, path: '/login-history'),
    AutoRoute(page: DeleteAccountRoute.page, path: '/delete-account'),
    

    //Terms and Privacy Routes
    AutoRoute(page: ArtistsTermsOfUseRoute.page, path: '/artists-terms-of-use'),
    AutoRoute(page: ClientTermsOfUseRoute.page, path: '/client-terms-of-use'),
    AutoRoute(page: TermsOfPrivacyRoute.page, path: '/terms-of-privacy'),

    //Support Routes
    AutoRoute(page: SupportRoute.page, path: '/support'),
    ];
  }
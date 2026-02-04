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
    AutoRoute(page: ArtistExploreRoute.page, path: '/artist-explore/:artistId'),
    AutoRoute(page: ArtistAreaRoute.page, path: '/artist-area'),
    AutoRoute(page: RegisterDataAreaRoute.page, path: '/register-data-area'),
    AutoRoute(page: ProfessionalInfoRoute.page, path: '/professional-info/:artistId'),
    AutoRoute(page: PresentationsRoute.page, path: '/presentations/:artistId'),
    AutoRoute(page: DocumentsRoute.page, path: '/documents/:artistId'),
    AutoRoute(page: BankAccountRoute.page, path: '/bank-account/:artistId'),

    // Ensemble (Conjuntos) Routes
    AutoRoute(page: EnsemblesListRoute.page, path: '/ensembles-list'),
    AutoRoute(page: EnsembleExploreRoute.page, path: '/ensemble-explore/:ensembleId'),
    AutoRoute(page: EnsembleAreaRoute.page, path: '/ensemble-area/:ensembleId'),
    AutoRoute(page: EnsembleMembersRoute.page, path: '/ensemble-members/:ensembleId'),
    AutoRoute(page: EnsemblePresentationsRoute.page, path: '/ensemble-presentations/:ensembleId'),
    AutoRoute(page: EnsembleProfessionalInfoRoute.page, path: '/ensemble-professional-info/:ensembleId'),
    AutoRoute(page: EnsembleAvailabilityCalendarRoute.page, path: '/ensemble-availability-calendar/:ensembleId'),
    AutoRoute(page: MemberDocumentsRoute.page, path: '/member-documents/:ensembleId/:memberId'),

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
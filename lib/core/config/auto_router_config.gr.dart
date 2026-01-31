// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:app/core/domain/addresses/address_info_entity.dart' as _i39;
import 'package:app/core/domain/artist/artist_individual/artist_entity.dart'
    as _i41;
import 'package:app/core/domain/contract/contract_entity.dart' as _i40;
import 'package:app/features/addresses/presentation/screens/address_form_page.dart'
    deferred as _i1;
import 'package:app/features/addresses/presentation/screens/addresses_list_page.dart'
    deferred as _i2;
import 'package:app/features/app_navigation/presentation/pages/navigation_page.dart'
    deferred as _i27;
import 'package:app/features/authentication/presentation/screens/check_email_verification_page.dart'
    deferred as _i13;
import 'package:app/features/authentication/presentation/screens/forgot_password_screen.dart'
    deferred as _i21;
import 'package:app/features/authentication/presentation/screens/initial_screen.dart'
    as _i22;
import 'package:app/features/authentication/presentation/screens/login_screen.dart'
    deferred as _i24;
import 'package:app/features/authentication/presentation/screens/onboarding_screen.dart'
    deferred as _i28;
import 'package:app/features/authentication/presentation/screens/register_screen.dart'
    deferred as _i33;
import 'package:app/features/contracts/presentation/screens/artists/artist_event_detail_screen.dart'
    deferred as _i4;
import 'package:app/features/contracts/presentation/screens/clients/client_event_detail_screen.dart'
    deferred as _i9;
import 'package:app/features/contracts/presentation/screens/clients/event_request/event_type_selection_screen.dart'
    deferred as _i20;
import 'package:app/features/contracts/presentation/screens/clients/event_request/request_screen.dart'
    deferred as _i34;
import 'package:app/features/ensemble/ensemble/presentation/screens/ensemble_area_screen.dart'
    deferred as _i14;
import 'package:app/features/ensemble/ensemble/presentation/screens/ensembles_list_screen.dart'
    deferred as _i19;
import 'package:app/features/ensemble/ensemble/presentation/screens/page_view/ensemble_explore_screen.dart'
    deferred as _i15;
import 'package:app/features/ensemble/ensemble/presentation/screens/presentations/ensemble_presentations_screen.dart'
    deferred as _i17;
import 'package:app/features/ensemble/ensemble/presentation/screens/professional_info/ensemble_professional_info_screen.dart'
    deferred as _i18;
import 'package:app/features/ensemble/member_documents/presentation/screens/documents_screen.dart'
    deferred as _i26;
import 'package:app/features/ensemble/members/presentation/screens/ensemble_members_screen.dart'
    deferred as _i16;
import 'package:app/features/profile/artist_bank_account/presentation/screens/bank_account_screen.dart'
    deferred as _i7;
import 'package:app/features/profile/artist_documents/presentation/screens/documents_screen.dart'
    deferred as _i12;
import 'package:app/features/profile/artists/presentation/screens/artist_area/artist_area_page.dart'
    deferred as _i3;
import 'package:app/features/profile/artists/presentation/screens/artist_area/presentations/presentations_screen.dart'
    deferred as _i30;
import 'package:app/features/profile/artists/presentation/screens/artist_area/professional_info/professional_info_screen.dart'
    deferred as _i31;
import 'package:app/features/profile/artists/presentation/screens/artist_explore_screen/artist_explore_screen.dart'
    deferred as _i5;
import 'package:app/features/profile/artists/presentation/screens/register_data/register_data_area_screen.dart'
    deferred as _i32;
import 'package:app/features/profile/shared/presentation/screens/login_security/delete_account/delete_account_page.dart'
    deferred as _i11;
import 'package:app/features/profile/shared/presentation/screens/login_security/login_history/login_history_page.dart'
    deferred as _i23;
import 'package:app/features/profile/shared/presentation/screens/login_security/login_security_page.dart'
    deferred as _i25;
import 'package:app/features/profile/shared/presentation/screens/login_security/password/change_password_page.dart'
    deferred as _i8;
import 'package:app/features/profile/shared/presentation/screens/personal_info/personal_info_page.dart'
    deferred as _i29;
import 'package:app/features/profile/shared/presentation/screens/terms/artist/artist_terms_of_use_page.dart'
    deferred as _i6;
import 'package:app/features/profile/shared/presentation/screens/terms/client/client_terms_of_use_page.dart'
    deferred as _i10;
import 'package:app/features/profile/shared/presentation/screens/terms/terms_of_privacy_page.dart'
    deferred as _i36;
import 'package:app/features/support/presentation/screens/support_page.dart'
    deferred as _i35;
import 'package:auto_route/auto_route.dart' as _i37;
import 'package:collection/collection.dart' as _i42;
import 'package:flutter/material.dart' as _i38;

/// generated route for
/// [_i1.AddressFormPage]
class AddressFormRoute extends _i37.PageRouteInfo<AddressFormRouteArgs> {
  AddressFormRoute({
    _i38.Key? key,
    _i39.AddressInfoEntity? existingAddress,
    List<_i37.PageRouteInfo>? children,
  }) : super(
         AddressFormRoute.name,
         args: AddressFormRouteArgs(key: key, existingAddress: existingAddress),
         initialChildren: children,
       );

  static const String name = 'AddressFormRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AddressFormRouteArgs>(
        orElse: () => const AddressFormRouteArgs(),
      );
      return _i37.DeferredWidget(
        _i1.loadLibrary,
        () => _i1.AddressFormPage(
          key: args.key,
          existingAddress: args.existingAddress,
        ),
      );
    },
  );
}

class AddressFormRouteArgs {
  const AddressFormRouteArgs({this.key, this.existingAddress});

  final _i38.Key? key;

  final _i39.AddressInfoEntity? existingAddress;

  @override
  String toString() {
    return 'AddressFormRouteArgs{key: $key, existingAddress: $existingAddress}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AddressFormRouteArgs) return false;
    return key == other.key && existingAddress == other.existingAddress;
  }

  @override
  int get hashCode => key.hashCode ^ existingAddress.hashCode;
}

/// generated route for
/// [_i2.AddressesListPage]
class AddressesListRoute extends _i37.PageRouteInfo<void> {
  const AddressesListRoute({List<_i37.PageRouteInfo>? children})
    : super(AddressesListRoute.name, initialChildren: children);

  static const String name = 'AddressesListRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      return _i37.DeferredWidget(
        _i2.loadLibrary,
        () => _i2.AddressesListPage(),
      );
    },
  );
}

/// generated route for
/// [_i3.ArtistAreaScreen]
class ArtistAreaRoute extends _i37.PageRouteInfo<void> {
  const ArtistAreaRoute({List<_i37.PageRouteInfo>? children})
    : super(ArtistAreaRoute.name, initialChildren: children);

  static const String name = 'ArtistAreaRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      return _i37.DeferredWidget(_i3.loadLibrary, () => _i3.ArtistAreaScreen());
    },
  );
}

/// generated route for
/// [_i4.ArtistEventDetailScreen]
class ArtistEventDetailRoute
    extends _i37.PageRouteInfo<ArtistEventDetailRouteArgs> {
  ArtistEventDetailRoute({
    _i38.Key? key,
    required _i40.ContractEntity contract,
    List<_i37.PageRouteInfo>? children,
  }) : super(
         ArtistEventDetailRoute.name,
         args: ArtistEventDetailRouteArgs(key: key, contract: contract),
         initialChildren: children,
       );

  static const String name = 'ArtistEventDetailRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ArtistEventDetailRouteArgs>();
      return _i37.DeferredWidget(
        _i4.loadLibrary,
        () =>
            _i4.ArtistEventDetailScreen(key: args.key, contract: args.contract),
      );
    },
  );
}

class ArtistEventDetailRouteArgs {
  const ArtistEventDetailRouteArgs({this.key, required this.contract});

  final _i38.Key? key;

  final _i40.ContractEntity contract;

  @override
  String toString() {
    return 'ArtistEventDetailRouteArgs{key: $key, contract: $contract}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ArtistEventDetailRouteArgs) return false;
    return key == other.key && contract == other.contract;
  }

  @override
  int get hashCode => key.hashCode ^ contract.hashCode;
}

/// generated route for
/// [_i5.ArtistExploreScreen]
class ArtistExploreRoute extends _i37.PageRouteInfo<ArtistExploreRouteArgs> {
  ArtistExploreRoute({
    _i38.Key? key,
    required _i41.ArtistEntity artist,
    bool isFavorite = false,
    bool viewOnly = false,
    DateTime? selectedDate,
    _i39.AddressInfoEntity? selectedAddress,
    List<_i37.PageRouteInfo>? children,
  }) : super(
         ArtistExploreRoute.name,
         args: ArtistExploreRouteArgs(
           key: key,
           artist: artist,
           isFavorite: isFavorite,
           viewOnly: viewOnly,
           selectedDate: selectedDate,
           selectedAddress: selectedAddress,
         ),
         initialChildren: children,
       );

  static const String name = 'ArtistExploreRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ArtistExploreRouteArgs>();
      return _i37.DeferredWidget(
        _i5.loadLibrary,
        () => _i5.ArtistExploreScreen(
          key: args.key,
          artist: args.artist,
          isFavorite: args.isFavorite,
          viewOnly: args.viewOnly,
          selectedDate: args.selectedDate,
          selectedAddress: args.selectedAddress,
        ),
      );
    },
  );
}

class ArtistExploreRouteArgs {
  const ArtistExploreRouteArgs({
    this.key,
    required this.artist,
    this.isFavorite = false,
    this.viewOnly = false,
    this.selectedDate,
    this.selectedAddress,
  });

  final _i38.Key? key;

  final _i41.ArtistEntity artist;

  final bool isFavorite;

  final bool viewOnly;

  final DateTime? selectedDate;

  final _i39.AddressInfoEntity? selectedAddress;

  @override
  String toString() {
    return 'ArtistExploreRouteArgs{key: $key, artist: $artist, isFavorite: $isFavorite, viewOnly: $viewOnly, selectedDate: $selectedDate, selectedAddress: $selectedAddress}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ArtistExploreRouteArgs) return false;
    return key == other.key &&
        artist == other.artist &&
        isFavorite == other.isFavorite &&
        viewOnly == other.viewOnly &&
        selectedDate == other.selectedDate &&
        selectedAddress == other.selectedAddress;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      artist.hashCode ^
      isFavorite.hashCode ^
      viewOnly.hashCode ^
      selectedDate.hashCode ^
      selectedAddress.hashCode;
}

/// generated route for
/// [_i6.ArtistsTermsOfUseScreen]
class ArtistsTermsOfUseRoute extends _i37.PageRouteInfo<void> {
  const ArtistsTermsOfUseRoute({List<_i37.PageRouteInfo>? children})
    : super(ArtistsTermsOfUseRoute.name, initialChildren: children);

  static const String name = 'ArtistsTermsOfUseRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      return _i37.DeferredWidget(
        _i6.loadLibrary,
        () => _i6.ArtistsTermsOfUseScreen(),
      );
    },
  );
}

/// generated route for
/// [_i7.BankAccountScreen]
class BankAccountRoute extends _i37.PageRouteInfo<void> {
  const BankAccountRoute({List<_i37.PageRouteInfo>? children})
    : super(BankAccountRoute.name, initialChildren: children);

  static const String name = 'BankAccountRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      return _i37.DeferredWidget(
        _i7.loadLibrary,
        () => _i7.BankAccountScreen(),
      );
    },
  );
}

/// generated route for
/// [_i8.ChangePasswordPage]
class ChangePasswordRoute extends _i37.PageRouteInfo<void> {
  const ChangePasswordRoute({List<_i37.PageRouteInfo>? children})
    : super(ChangePasswordRoute.name, initialChildren: children);

  static const String name = 'ChangePasswordRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      return _i37.DeferredWidget(
        _i8.loadLibrary,
        () => _i8.ChangePasswordPage(),
      );
    },
  );
}

/// generated route for
/// [_i9.ClientEventDetailScreen]
class ClientEventDetailRoute
    extends _i37.PageRouteInfo<ClientEventDetailRouteArgs> {
  ClientEventDetailRoute({
    _i38.Key? key,
    required _i40.ContractEntity contract,
    List<_i37.PageRouteInfo>? children,
  }) : super(
         ClientEventDetailRoute.name,
         args: ClientEventDetailRouteArgs(key: key, contract: contract),
         initialChildren: children,
       );

  static const String name = 'ClientEventDetailRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ClientEventDetailRouteArgs>();
      return _i37.DeferredWidget(
        _i9.loadLibrary,
        () =>
            _i9.ClientEventDetailScreen(key: args.key, contract: args.contract),
      );
    },
  );
}

class ClientEventDetailRouteArgs {
  const ClientEventDetailRouteArgs({this.key, required this.contract});

  final _i38.Key? key;

  final _i40.ContractEntity contract;

  @override
  String toString() {
    return 'ClientEventDetailRouteArgs{key: $key, contract: $contract}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ClientEventDetailRouteArgs) return false;
    return key == other.key && contract == other.contract;
  }

  @override
  int get hashCode => key.hashCode ^ contract.hashCode;
}

/// generated route for
/// [_i10.ClientTermsOfUseScreen]
class ClientTermsOfUseRoute extends _i37.PageRouteInfo<void> {
  const ClientTermsOfUseRoute({List<_i37.PageRouteInfo>? children})
    : super(ClientTermsOfUseRoute.name, initialChildren: children);

  static const String name = 'ClientTermsOfUseRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      return _i37.DeferredWidget(
        _i10.loadLibrary,
        () => _i10.ClientTermsOfUseScreen(),
      );
    },
  );
}

/// generated route for
/// [_i11.DeleteAccountPage]
class DeleteAccountRoute extends _i37.PageRouteInfo<void> {
  const DeleteAccountRoute({List<_i37.PageRouteInfo>? children})
    : super(DeleteAccountRoute.name, initialChildren: children);

  static const String name = 'DeleteAccountRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      return _i37.DeferredWidget(
        _i11.loadLibrary,
        () => _i11.DeleteAccountPage(),
      );
    },
  );
}

/// generated route for
/// [_i12.DocumentsScreen]
class DocumentsRoute extends _i37.PageRouteInfo<void> {
  const DocumentsRoute({List<_i37.PageRouteInfo>? children})
    : super(DocumentsRoute.name, initialChildren: children);

  static const String name = 'DocumentsRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      return _i37.DeferredWidget(
        _i12.loadLibrary,
        () => _i12.DocumentsScreen(),
      );
    },
  );
}

/// generated route for
/// [_i13.EmailVerificationPage]
class EmailVerificationRoute
    extends _i37.PageRouteInfo<EmailVerificationRouteArgs> {
  EmailVerificationRoute({
    _i38.Key? key,
    required String email,
    bool isChangeEmail = false,
    List<_i37.PageRouteInfo>? children,
  }) : super(
         EmailVerificationRoute.name,
         args: EmailVerificationRouteArgs(
           key: key,
           email: email,
           isChangeEmail: isChangeEmail,
         ),
         initialChildren: children,
       );

  static const String name = 'EmailVerificationRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<EmailVerificationRouteArgs>();
      return _i37.DeferredWidget(
        _i13.loadLibrary,
        () => _i13.EmailVerificationPage(
          key: args.key,
          email: args.email,
          isChangeEmail: args.isChangeEmail,
        ),
      );
    },
  );
}

class EmailVerificationRouteArgs {
  const EmailVerificationRouteArgs({
    this.key,
    required this.email,
    this.isChangeEmail = false,
  });

  final _i38.Key? key;

  final String email;

  final bool isChangeEmail;

  @override
  String toString() {
    return 'EmailVerificationRouteArgs{key: $key, email: $email, isChangeEmail: $isChangeEmail}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! EmailVerificationRouteArgs) return false;
    return key == other.key &&
        email == other.email &&
        isChangeEmail == other.isChangeEmail;
  }

  @override
  int get hashCode => key.hashCode ^ email.hashCode ^ isChangeEmail.hashCode;
}

/// generated route for
/// [_i14.EnsembleAreaScreen]
class EnsembleAreaRoute extends _i37.PageRouteInfo<EnsembleAreaRouteArgs> {
  EnsembleAreaRoute({
    _i38.Key? key,
    required String ensembleId,
    List<_i37.PageRouteInfo>? children,
  }) : super(
         EnsembleAreaRoute.name,
         args: EnsembleAreaRouteArgs(key: key, ensembleId: ensembleId),
         initialChildren: children,
       );

  static const String name = 'EnsembleAreaRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<EnsembleAreaRouteArgs>();
      return _i37.DeferredWidget(
        _i14.loadLibrary,
        () =>
            _i14.EnsembleAreaScreen(key: args.key, ensembleId: args.ensembleId),
      );
    },
  );
}

class EnsembleAreaRouteArgs {
  const EnsembleAreaRouteArgs({this.key, required this.ensembleId});

  final _i38.Key? key;

  final String ensembleId;

  @override
  String toString() {
    return 'EnsembleAreaRouteArgs{key: $key, ensembleId: $ensembleId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! EnsembleAreaRouteArgs) return false;
    return key == other.key && ensembleId == other.ensembleId;
  }

  @override
  int get hashCode => key.hashCode ^ ensembleId.hashCode;
}

/// generated route for
/// [_i15.EnsembleExploreScreen]
class EnsembleExploreRoute
    extends _i37.PageRouteInfo<EnsembleExploreRouteArgs> {
  EnsembleExploreRoute({
    _i38.Key? key,
    required String ensembleId,
    required _i41.ArtistEntity artist,
    bool isFavorite = false,
    bool viewOnly = false,
    DateTime? selectedDate,
    _i39.AddressInfoEntity? selectedAddress,
    List<_i37.PageRouteInfo>? children,
  }) : super(
         EnsembleExploreRoute.name,
         args: EnsembleExploreRouteArgs(
           key: key,
           ensembleId: ensembleId,
           artist: artist,
           isFavorite: isFavorite,
           viewOnly: viewOnly,
           selectedDate: selectedDate,
           selectedAddress: selectedAddress,
         ),
         initialChildren: children,
       );

  static const String name = 'EnsembleExploreRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<EnsembleExploreRouteArgs>();
      return _i37.DeferredWidget(
        _i15.loadLibrary,
        () => _i15.EnsembleExploreScreen(
          key: args.key,
          ensembleId: args.ensembleId,
          artist: args.artist,
          isFavorite: args.isFavorite,
          viewOnly: args.viewOnly,
          selectedDate: args.selectedDate,
          selectedAddress: args.selectedAddress,
        ),
      );
    },
  );
}

class EnsembleExploreRouteArgs {
  const EnsembleExploreRouteArgs({
    this.key,
    required this.ensembleId,
    required this.artist,
    this.isFavorite = false,
    this.viewOnly = false,
    this.selectedDate,
    this.selectedAddress,
  });

  final _i38.Key? key;

  final String ensembleId;

  final _i41.ArtistEntity artist;

  final bool isFavorite;

  final bool viewOnly;

  final DateTime? selectedDate;

  final _i39.AddressInfoEntity? selectedAddress;

  @override
  String toString() {
    return 'EnsembleExploreRouteArgs{key: $key, ensembleId: $ensembleId, artist: $artist, isFavorite: $isFavorite, viewOnly: $viewOnly, selectedDate: $selectedDate, selectedAddress: $selectedAddress}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! EnsembleExploreRouteArgs) return false;
    return key == other.key &&
        ensembleId == other.ensembleId &&
        artist == other.artist &&
        isFavorite == other.isFavorite &&
        viewOnly == other.viewOnly &&
        selectedDate == other.selectedDate &&
        selectedAddress == other.selectedAddress;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      ensembleId.hashCode ^
      artist.hashCode ^
      isFavorite.hashCode ^
      viewOnly.hashCode ^
      selectedDate.hashCode ^
      selectedAddress.hashCode;
}

/// generated route for
/// [_i16.EnsembleMembersScreen]
class EnsembleMembersRoute
    extends _i37.PageRouteInfo<EnsembleMembersRouteArgs> {
  EnsembleMembersRoute({
    _i38.Key? key,
    required String ensembleId,
    List<_i37.PageRouteInfo>? children,
  }) : super(
         EnsembleMembersRoute.name,
         args: EnsembleMembersRouteArgs(key: key, ensembleId: ensembleId),
         initialChildren: children,
       );

  static const String name = 'EnsembleMembersRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<EnsembleMembersRouteArgs>();
      return _i37.DeferredWidget(
        _i16.loadLibrary,
        () => _i16.EnsembleMembersScreen(
          key: args.key,
          ensembleId: args.ensembleId,
        ),
      );
    },
  );
}

class EnsembleMembersRouteArgs {
  const EnsembleMembersRouteArgs({this.key, required this.ensembleId});

  final _i38.Key? key;

  final String ensembleId;

  @override
  String toString() {
    return 'EnsembleMembersRouteArgs{key: $key, ensembleId: $ensembleId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! EnsembleMembersRouteArgs) return false;
    return key == other.key && ensembleId == other.ensembleId;
  }

  @override
  int get hashCode => key.hashCode ^ ensembleId.hashCode;
}

/// generated route for
/// [_i17.EnsemblePresentationsScreen]
class EnsemblePresentationsRoute
    extends _i37.PageRouteInfo<EnsemblePresentationsRouteArgs> {
  EnsemblePresentationsRoute({
    _i38.Key? key,
    String ensembleId = '',
    List<_i37.PageRouteInfo>? children,
  }) : super(
         EnsemblePresentationsRoute.name,
         args: EnsemblePresentationsRouteArgs(key: key, ensembleId: ensembleId),
         initialChildren: children,
       );

  static const String name = 'EnsemblePresentationsRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<EnsemblePresentationsRouteArgs>(
        orElse: () => const EnsemblePresentationsRouteArgs(),
      );
      return _i37.DeferredWidget(
        _i17.loadLibrary,
        () => _i17.EnsemblePresentationsScreen(
          key: args.key,
          ensembleId: args.ensembleId,
        ),
      );
    },
  );
}

class EnsemblePresentationsRouteArgs {
  const EnsemblePresentationsRouteArgs({this.key, this.ensembleId = ''});

  final _i38.Key? key;

  final String ensembleId;

  @override
  String toString() {
    return 'EnsemblePresentationsRouteArgs{key: $key, ensembleId: $ensembleId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! EnsemblePresentationsRouteArgs) return false;
    return key == other.key && ensembleId == other.ensembleId;
  }

  @override
  int get hashCode => key.hashCode ^ ensembleId.hashCode;
}

/// generated route for
/// [_i18.EnsembleProfessionalInfoScreen]
class EnsembleProfessionalInfoRoute extends _i37.PageRouteInfo<void> {
  const EnsembleProfessionalInfoRoute({List<_i37.PageRouteInfo>? children})
    : super(EnsembleProfessionalInfoRoute.name, initialChildren: children);

  static const String name = 'EnsembleProfessionalInfoRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      return _i37.DeferredWidget(
        _i18.loadLibrary,
        () => _i18.EnsembleProfessionalInfoScreen(),
      );
    },
  );
}

/// generated route for
/// [_i19.EnsemblesListScreen]
class EnsemblesListRoute extends _i37.PageRouteInfo<void> {
  const EnsemblesListRoute({List<_i37.PageRouteInfo>? children})
    : super(EnsemblesListRoute.name, initialChildren: children);

  static const String name = 'EnsemblesListRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      return _i37.DeferredWidget(
        _i19.loadLibrary,
        () => _i19.EnsemblesListScreen(),
      );
    },
  );
}

/// generated route for
/// [_i20.EventTypeSelectionScreen]
class EventTypeSelectionRoute
    extends _i37.PageRouteInfo<EventTypeSelectionRouteArgs> {
  EventTypeSelectionRoute({
    _i38.Key? key,
    required List<String> eventTypes,
    String? selectedEventType,
    required _i38.ValueChanged<String> onEventTypeSelected,
    List<_i37.PageRouteInfo>? children,
  }) : super(
         EventTypeSelectionRoute.name,
         args: EventTypeSelectionRouteArgs(
           key: key,
           eventTypes: eventTypes,
           selectedEventType: selectedEventType,
           onEventTypeSelected: onEventTypeSelected,
         ),
         initialChildren: children,
       );

  static const String name = 'EventTypeSelectionRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<EventTypeSelectionRouteArgs>();
      return _i37.DeferredWidget(
        _i20.loadLibrary,
        () => _i20.EventTypeSelectionScreen(
          key: args.key,
          eventTypes: args.eventTypes,
          selectedEventType: args.selectedEventType,
          onEventTypeSelected: args.onEventTypeSelected,
        ),
      );
    },
  );
}

class EventTypeSelectionRouteArgs {
  const EventTypeSelectionRouteArgs({
    this.key,
    required this.eventTypes,
    this.selectedEventType,
    required this.onEventTypeSelected,
  });

  final _i38.Key? key;

  final List<String> eventTypes;

  final String? selectedEventType;

  final _i38.ValueChanged<String> onEventTypeSelected;

  @override
  String toString() {
    return 'EventTypeSelectionRouteArgs{key: $key, eventTypes: $eventTypes, selectedEventType: $selectedEventType, onEventTypeSelected: $onEventTypeSelected}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! EventTypeSelectionRouteArgs) return false;
    return key == other.key &&
        const _i42.ListEquality<String>().equals(
          eventTypes,
          other.eventTypes,
        ) &&
        selectedEventType == other.selectedEventType &&
        onEventTypeSelected == other.onEventTypeSelected;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      const _i42.ListEquality<String>().hash(eventTypes) ^
      selectedEventType.hashCode ^
      onEventTypeSelected.hashCode;
}

/// generated route for
/// [_i21.ForgotPasswordScreen]
class ForgotPasswordRoute extends _i37.PageRouteInfo<void> {
  const ForgotPasswordRoute({List<_i37.PageRouteInfo>? children})
    : super(ForgotPasswordRoute.name, initialChildren: children);

  static const String name = 'ForgotPasswordRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      return _i37.DeferredWidget(
        _i21.loadLibrary,
        () => _i21.ForgotPasswordScreen(),
      );
    },
  );
}

/// generated route for
/// [_i22.InitialScreen]
class InitialRoute extends _i37.PageRouteInfo<void> {
  const InitialRoute({List<_i37.PageRouteInfo>? children})
    : super(InitialRoute.name, initialChildren: children);

  static const String name = 'InitialRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      return const _i22.InitialScreen();
    },
  );
}

/// generated route for
/// [_i23.LoginHistoryPage]
class LoginHistoryRoute extends _i37.PageRouteInfo<void> {
  const LoginHistoryRoute({List<_i37.PageRouteInfo>? children})
    : super(LoginHistoryRoute.name, initialChildren: children);

  static const String name = 'LoginHistoryRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      return _i37.DeferredWidget(
        _i23.loadLibrary,
        () => _i23.LoginHistoryPage(),
      );
    },
  );
}

/// generated route for
/// [_i24.LoginScreen]
class LoginRoute extends _i37.PageRouteInfo<void> {
  const LoginRoute({List<_i37.PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      return _i37.DeferredWidget(_i24.loadLibrary, () => _i24.LoginScreen());
    },
  );
}

/// generated route for
/// [_i25.LoginSecurityPage]
class LoginSecurityRoute extends _i37.PageRouteInfo<void> {
  const LoginSecurityRoute({List<_i37.PageRouteInfo>? children})
    : super(LoginSecurityRoute.name, initialChildren: children);

  static const String name = 'LoginSecurityRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      return _i37.DeferredWidget(
        _i25.loadLibrary,
        () => _i25.LoginSecurityPage(),
      );
    },
  );
}

/// generated route for
/// [_i26.MemberDocumentsScreen]
class MemberDocumentsRoute extends _i37.PageRouteInfo<void> {
  const MemberDocumentsRoute({List<_i37.PageRouteInfo>? children})
    : super(MemberDocumentsRoute.name, initialChildren: children);

  static const String name = 'MemberDocumentsRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      return _i37.DeferredWidget(
        _i26.loadLibrary,
        () => _i26.MemberDocumentsScreen(),
      );
    },
  );
}

/// generated route for
/// [_i27.NavigationPage]
class NavigationRoute extends _i37.PageRouteInfo<NavigationRouteArgs> {
  NavigationRoute({
    _i38.Key? key,
    bool isArtist = false,
    List<_i37.PageRouteInfo>? children,
  }) : super(
         NavigationRoute.name,
         args: NavigationRouteArgs(key: key, isArtist: isArtist),
         initialChildren: children,
       );

  static const String name = 'NavigationRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<NavigationRouteArgs>(
        orElse: () => const NavigationRouteArgs(),
      );
      return _i37.DeferredWidget(
        _i27.loadLibrary,
        () => _i27.NavigationPage(key: args.key, isArtist: args.isArtist),
      );
    },
  );
}

class NavigationRouteArgs {
  const NavigationRouteArgs({this.key, this.isArtist = false});

  final _i38.Key? key;

  final bool isArtist;

  @override
  String toString() {
    return 'NavigationRouteArgs{key: $key, isArtist: $isArtist}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! NavigationRouteArgs) return false;
    return key == other.key && isArtist == other.isArtist;
  }

  @override
  int get hashCode => key.hashCode ^ isArtist.hashCode;
}

/// generated route for
/// [_i28.OnboardingScreen]
class OnboardingRoute extends _i37.PageRouteInfo<OnboardingRouteArgs> {
  OnboardingRoute({
    _i38.Key? key,
    required String email,
    List<_i37.PageRouteInfo>? children,
  }) : super(
         OnboardingRoute.name,
         args: OnboardingRouteArgs(key: key, email: email),
         initialChildren: children,
       );

  static const String name = 'OnboardingRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<OnboardingRouteArgs>();
      return _i37.DeferredWidget(
        _i28.loadLibrary,
        () => _i28.OnboardingScreen(key: args.key, email: args.email),
      );
    },
  );
}

class OnboardingRouteArgs {
  const OnboardingRouteArgs({this.key, required this.email});

  final _i38.Key? key;

  final String email;

  @override
  String toString() {
    return 'OnboardingRouteArgs{key: $key, email: $email}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OnboardingRouteArgs) return false;
    return key == other.key && email == other.email;
  }

  @override
  int get hashCode => key.hashCode ^ email.hashCode;
}

/// generated route for
/// [_i29.PersonalInfoPage]
class PersonalInfoRoute extends _i37.PageRouteInfo<void> {
  const PersonalInfoRoute({List<_i37.PageRouteInfo>? children})
    : super(PersonalInfoRoute.name, initialChildren: children);

  static const String name = 'PersonalInfoRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      return _i37.DeferredWidget(
        _i29.loadLibrary,
        () => _i29.PersonalInfoPage(),
      );
    },
  );
}

/// generated route for
/// [_i30.PresentationsScreen]
class PresentationsRoute extends _i37.PageRouteInfo<void> {
  const PresentationsRoute({List<_i37.PageRouteInfo>? children})
    : super(PresentationsRoute.name, initialChildren: children);

  static const String name = 'PresentationsRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      return _i37.DeferredWidget(
        _i30.loadLibrary,
        () => _i30.PresentationsScreen(),
      );
    },
  );
}

/// generated route for
/// [_i31.ProfessionalInfoScreen]
class ProfessionalInfoRoute extends _i37.PageRouteInfo<void> {
  const ProfessionalInfoRoute({List<_i37.PageRouteInfo>? children})
    : super(ProfessionalInfoRoute.name, initialChildren: children);

  static const String name = 'ProfessionalInfoRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      return _i37.DeferredWidget(
        _i31.loadLibrary,
        () => _i31.ProfessionalInfoScreen(),
      );
    },
  );
}

/// generated route for
/// [_i32.RegisterDataAreaScreen]
class RegisterDataAreaRoute extends _i37.PageRouteInfo<void> {
  const RegisterDataAreaRoute({List<_i37.PageRouteInfo>? children})
    : super(RegisterDataAreaRoute.name, initialChildren: children);

  static const String name = 'RegisterDataAreaRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      return _i37.DeferredWidget(
        _i32.loadLibrary,
        () => _i32.RegisterDataAreaScreen(),
      );
    },
  );
}

/// generated route for
/// [_i33.RegisterScreen]
class RegisterRoute extends _i37.PageRouteInfo<void> {
  const RegisterRoute({List<_i37.PageRouteInfo>? children})
    : super(RegisterRoute.name, initialChildren: children);

  static const String name = 'RegisterRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      return _i37.DeferredWidget(_i33.loadLibrary, () => _i33.RegisterScreen());
    },
  );
}

/// generated route for
/// [_i34.RequestScreen]
class RequestRoute extends _i37.PageRouteInfo<RequestRouteArgs> {
  RequestRoute({
    _i38.Key? key,
    required DateTime selectedDate,
    required _i39.AddressInfoEntity selectedAddress,
    required _i41.ArtistEntity artist,
    List<_i37.PageRouteInfo>? children,
  }) : super(
         RequestRoute.name,
         args: RequestRouteArgs(
           key: key,
           selectedDate: selectedDate,
           selectedAddress: selectedAddress,
           artist: artist,
         ),
         initialChildren: children,
       );

  static const String name = 'RequestRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<RequestRouteArgs>();
      return _i37.DeferredWidget(
        _i34.loadLibrary,
        () => _i34.RequestScreen(
          key: args.key,
          selectedDate: args.selectedDate,
          selectedAddress: args.selectedAddress,
          artist: args.artist,
        ),
      );
    },
  );
}

class RequestRouteArgs {
  const RequestRouteArgs({
    this.key,
    required this.selectedDate,
    required this.selectedAddress,
    required this.artist,
  });

  final _i38.Key? key;

  final DateTime selectedDate;

  final _i39.AddressInfoEntity selectedAddress;

  final _i41.ArtistEntity artist;

  @override
  String toString() {
    return 'RequestRouteArgs{key: $key, selectedDate: $selectedDate, selectedAddress: $selectedAddress, artist: $artist}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! RequestRouteArgs) return false;
    return key == other.key &&
        selectedDate == other.selectedDate &&
        selectedAddress == other.selectedAddress &&
        artist == other.artist;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      selectedDate.hashCode ^
      selectedAddress.hashCode ^
      artist.hashCode;
}

/// generated route for
/// [_i35.SupportPage]
class SupportRoute extends _i37.PageRouteInfo<SupportRouteArgs> {
  SupportRoute({
    _i38.Key? key,
    _i40.ContractEntity? contract,
    List<_i37.PageRouteInfo>? children,
  }) : super(
         SupportRoute.name,
         args: SupportRouteArgs(key: key, contract: contract),
         initialChildren: children,
       );

  static const String name = 'SupportRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SupportRouteArgs>(
        orElse: () => const SupportRouteArgs(),
      );
      return _i37.DeferredWidget(
        _i35.loadLibrary,
        () => _i35.SupportPage(key: args.key, contract: args.contract),
      );
    },
  );
}

class SupportRouteArgs {
  const SupportRouteArgs({this.key, this.contract});

  final _i38.Key? key;

  final _i40.ContractEntity? contract;

  @override
  String toString() {
    return 'SupportRouteArgs{key: $key, contract: $contract}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SupportRouteArgs) return false;
    return key == other.key && contract == other.contract;
  }

  @override
  int get hashCode => key.hashCode ^ contract.hashCode;
}

/// generated route for
/// [_i36.TermsOfPrivacyScreen]
class TermsOfPrivacyRoute extends _i37.PageRouteInfo<void> {
  const TermsOfPrivacyRoute({List<_i37.PageRouteInfo>? children})
    : super(TermsOfPrivacyRoute.name, initialChildren: children);

  static const String name = 'TermsOfPrivacyRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      return _i37.DeferredWidget(
        _i36.loadLibrary,
        () => _i36.TermsOfPrivacyScreen(),
      );
    },
  );
}

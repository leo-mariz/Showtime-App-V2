import 'package:app/features/authentication/domain/usecases/get_user_uid.dart';
import 'package:app/features/profile/artists/domain/usecases/get_artist_usecase.dart';
import 'package:app/features/profile/artists/domain/usecases/update_artist_usecase.dart';
import 'package:app/features/profile/artists/domain/usecases/update_artist_profile_picture_usecase.dart';
import 'package:app/features/profile/artists/domain/usecases/update_artist_name_usecase.dart';
import 'package:app/features/profile/artists/domain/usecases/update_artist_professional_info_usecase.dart';
import 'package:app/features/profile/artists/domain/usecases/update_artist_agreement_usecase.dart';
import 'package:app/features/profile/artists/domain/usecases/check_artist_name_exists_usecase.dart';
import 'package:app/features/profile/artists/presentation/bloc/events/artists_events.dart';
import 'package:app/features/profile/artists/presentation/bloc/states/artists_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ArtistsBloc extends Bloc<ArtistsEvent, ArtistsState> {
  final GetArtistUseCase getArtistUseCase;
  final UpdateArtistUseCase updateArtistUseCase;
  final UpdateArtistProfilePictureUseCase updateArtistProfilePictureUseCase;
  final UpdateArtistNameUseCase updateArtistNameUseCase;
  final UpdateArtistProfessionalInfoUseCase updateArtistProfessionalInfoUseCase;
  final UpdateArtistAgreementUseCase updateArtistAgreementUseCase;
  final CheckArtistNameExistsUseCase checkArtistNameExistsUseCase;
  final GetUserUidUseCase getUserUidUseCase;

  ArtistsBloc({
    required this.getArtistUseCase,
    required this.updateArtistUseCase,
    required this.updateArtistProfilePictureUseCase,
    required this.updateArtistNameUseCase,
    required this.updateArtistProfessionalInfoUseCase,
    required this.updateArtistAgreementUseCase,
    required this.checkArtistNameExistsUseCase,
    required this.getUserUidUseCase,
  }) : super(ArtistsInitial()) {
    on<GetArtistEvent>(_onGetArtistEvent);
    on<UpdateArtistEvent>(_onUpdateArtistEvent);
    on<UpdateArtistProfilePictureEvent>(_onUpdateArtistProfilePictureEvent);
    on<UpdateArtistNameEvent>(_onUpdateArtistNameEvent);
    on<UpdateArtistProfessionalInfoEvent>(_onUpdateArtistProfessionalInfoEvent);
    on<UpdateArtistAgreementEvent>(_onUpdateArtistAgreementEvent);
    on<CheckArtistNameExistsEvent>(_onCheckArtistNameExistsEvent);
  }

  // ==================== HELPERS ====================

  Future<String?> _getCurrentUserId() async {
    final result = await getUserUidUseCase.call();
    return result.fold(
      (_) => null,
      (uid) => uid,
    );
  }

  // ==================== GET ARTIST ====================

  Future<void> _onGetArtistEvent(
    GetArtistEvent event,
    Emitter<ArtistsState> emit,
  ) async {
    emit(GetArtistLoading());

    final uid = await _getCurrentUserId();

    final result = await getArtistUseCase.call(uid!);

    result.fold(
      (failure) {
        emit(GetArtistFailure(error: failure.message));
        emit(ArtistsInitial());
      },
      (artist) {
        emit(GetArtistSuccess(artist: artist));
      },
    );
  }

  // ==================== UPDATE ARTIST ====================

  Future<void> _onUpdateArtistEvent(
    UpdateArtistEvent event,
    Emitter<ArtistsState> emit,
  ) async {
    emit(UpdateArtistLoading());

    final uid = await _getCurrentUserId();

    final result = await updateArtistUseCase.call(uid!, event.artist);

    result.fold(
      (failure) {
        emit(UpdateArtistFailure(error: failure.message));
        emit(ArtistsInitial());
      },
      (_) {
        emit(UpdateArtistSuccess());
        emit(ArtistsInitial());
      },
    );
  }

  // ==================== UPDATE ARTIST PROFILE PICTURE ====================

  Future<void> _onUpdateArtistProfilePictureEvent(
    UpdateArtistProfilePictureEvent event,
    Emitter<ArtistsState> emit,
  ) async {
    emit(UpdateArtistProfilePictureLoading());

    final uid = await _getCurrentUserId();

    final result = await updateArtistProfilePictureUseCase.call(
      uid!,
      event.localFilePath,
    );

    result.fold(
      (failure) {
        emit(UpdateArtistProfilePictureFailure(error: failure.message));
        emit(ArtistsInitial());
      },
      (_) {
        emit(UpdateArtistProfilePictureSuccess());
        emit(ArtistsInitial());
      },
    );
  }

  // ==================== UPDATE ARTIST NAME ====================

  Future<void> _onUpdateArtistNameEvent(
    UpdateArtistNameEvent event,
    Emitter<ArtistsState> emit,
  ) async {
    emit(UpdateArtistNameLoading());

    final uid = await _getCurrentUserId();

    final result = await updateArtistNameUseCase.call(
      uid!,
      event.artistName,
    );

    result.fold(
      (failure) {
        emit(UpdateArtistNameFailure(error: failure.message));
        emit(ArtistsInitial());
      },
      (_) {
        emit(UpdateArtistNameSuccess());
        emit(ArtistsInitial());
      },
    );
  }

  // ==================== UPDATE ARTIST PROFESSIONAL INFO ====================

  Future<void> _onUpdateArtistProfessionalInfoEvent(
    UpdateArtistProfessionalInfoEvent event,
    Emitter<ArtistsState> emit,
  ) async {
    emit(UpdateArtistProfessionalInfoLoading());

    final uid = await _getCurrentUserId();

    final result = await updateArtistProfessionalInfoUseCase.call(
      uid!,
      event.professionalInfo,
    );

    result.fold(
      (failure) {
        emit(UpdateArtistProfessionalInfoFailure(error: failure.message));
        emit(ArtistsInitial());
      },
      (_) {
        emit(UpdateArtistProfessionalInfoSuccess());
        emit(ArtistsInitial());
      },
    );
  }

  // ==================== UPDATE ARTIST AGREEMENT ====================

  Future<void> _onUpdateArtistAgreementEvent(
    UpdateArtistAgreementEvent event,
    Emitter<ArtistsState> emit,
  ) async {
    emit(UpdateArtistAgreementLoading());

    final uid = await _getCurrentUserId();

    final result = await updateArtistAgreementUseCase.call(
      uid!,
      event.agreedToTerms,
    );

    result.fold(
      (failure) {
        emit(UpdateArtistAgreementFailure(error: failure.message));
        emit(ArtistsInitial());
      },
      (_) {
        emit(UpdateArtistAgreementSuccess());
        emit(ArtistsInitial());
      },
    );
  }

  // ==================== CHECK ARTIST NAME EXISTS ====================

  Future<void> _onCheckArtistNameExistsEvent(
    CheckArtistNameExistsEvent event,
    Emitter<ArtistsState> emit,
  ) async {
    emit(CheckArtistNameExistsLoading(artistName: event.artistName));

    final result = await checkArtistNameExistsUseCase.call(event.artistName);

    result.fold(
      (failure) {
        emit(CheckArtistNameExistsFailure(
          artistName: event.artistName,
          error: failure.message,
        ));
        emit(ArtistsInitial());
      },
      (exists) {
        emit(CheckArtistNameExistsSuccess(
          artistName: event.artistName,
          exists: exists,
        ));
        emit(ArtistsInitial());
      },
    );
  }
}


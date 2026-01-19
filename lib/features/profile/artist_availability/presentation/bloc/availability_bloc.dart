import 'package:app/features/authentication/domain/usecases/get_user_uid.dart';
import 'package:app/features/profile/artist_availability/domain/usecases/get_availability_usecase.dart';
import 'package:app/features/profile/artist_availability/domain/usecases/create_availability_usecase.dart';
import 'package:app/features/profile/artist_availability/domain/usecases/update_availability_usecase.dart';
import 'package:app/features/profile/artist_availability/domain/usecases/delete_availability_usecase.dart';
import 'package:app/features/profile/artist_availability/presentation/bloc/events/availability_events.dart';
import 'package:app/features/profile/artist_availability/presentation/bloc/states/availability_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// BLoC para gerenciar disponibilidade
class AvailabilityBloc extends Bloc<AvailabilityEvent, AvailabilityState> {
  final GetAvailabilityUseCase getAvailabilityUseCase;
  final CreateAvailabilityUseCase createAvailabilityUseCase;
  final UpdateAvailabilityUseCase updateAvailabilityUseCase;
  final DeleteAvailabilityUseCase deleteAvailabilityUseCase;
  final GetUserUidUseCase getUserUidUseCase;

  AvailabilityBloc({
    required this.getAvailabilityUseCase,
    required this.createAvailabilityUseCase,
    required this.updateAvailabilityUseCase,
    required this.deleteAvailabilityUseCase,
    required this.getUserUidUseCase,
  }) : super(AvailabilityInitialState()) {
    on<GetAvailabilityEvent>(_onGetAvailability);
    on<CreateAvailabilityEvent>(_onCreateAvailability);
    on<UpdateAvailabilityEvent>(_onUpdateAvailability);
    on<DeleteAvailabilityEvent>(_onDeleteAvailability);
    on<ResetAvailabilityStateEvent>(_onResetState);
  }

  /// Busca o ID do usuário atual
  Future<String?> _getCurrentUserId() async {
    final result = await getUserUidUseCase.call();
    return result.fold(
      (_) => null,
      (uid) => uid,
    );
  }

  /// Handler para buscar disponibilidades
  Future<void> _onGetAvailability(
    GetAvailabilityEvent event,
    Emitter<AvailabilityState> emit,
  ) async {
    emit(AvailabilityLoadingState(message: 'Carregando disponibilidades...'));

    final artistId = await _getCurrentUserId();
    if (artistId == null) {
      emit(AvailabilityErrorState(message: 'Usuário não autenticado'));
      return;
    }

    final result = await getAvailabilityUseCase(artistId, event.dto);

    result.fold(
      (failure) => emit(AvailabilityErrorState(message: failure.message)),
      (days) => emit(AvailabilityLoadedState(days: days)),
    );
  }

  /// Handler para criar disponibilidade
  Future<void> _onCreateAvailability(
    CreateAvailabilityEvent event,
    Emitter<AvailabilityState> emit,
  ) async {
    emit(AvailabilityLoadingState(message: 'Criando disponibilidade...'));

    final artistId = await _getCurrentUserId();
    if (artistId == null) {
      emit(AvailabilityErrorState(message: 'Usuário não autenticado'));
      return;
    }

    final result = await createAvailabilityUseCase(artistId, event.dto);

    result.fold(
      (failure) => emit(AvailabilityErrorState(message: failure.message)),
      (day) => emit(AvailabilityCreatedState(day: day)),
    );
  }

  /// Handler para atualizar disponibilidade
  Future<void> _onUpdateAvailability(
    UpdateAvailabilityEvent event,
    Emitter<AvailabilityState> emit,
  ) async {
    emit(AvailabilityLoadingState(message: 'Atualizando disponibilidade...'));

    final artistId = await _getCurrentUserId();
    if (artistId == null) {
      emit(AvailabilityErrorState(message: 'Usuário não autenticado'));
      return;
    }

    final result = await updateAvailabilityUseCase(artistId, event.dto);

    result.fold(
      (failure) => emit(AvailabilityErrorState(message: failure.message)),
      (day) => emit(AvailabilityUpdatedState(day: day)),
    );
  }

  /// Handler para deletar disponibilidade
  Future<void> _onDeleteAvailability(
    DeleteAvailabilityEvent event,
    Emitter<AvailabilityState> emit,
  ) async {
    emit(AvailabilityLoadingState(message: 'Removendo disponibilidade...'));

    final artistId = await _getCurrentUserId();
    if (artistId == null) {
      emit(AvailabilityErrorState(message: 'Usuário não autenticado'));
      return;
    }

    final result = await deleteAvailabilityUseCase(artistId, event.dto);

    result.fold(
      (failure) => emit(AvailabilityErrorState(message: failure.message)),
      (_) => emit(AvailabilityDeletedState()),
    );
  }

  /// Handler para resetar estado
  void _onResetState(
    ResetAvailabilityStateEvent event,
    Emitter<AvailabilityState> emit,
  ) {
    emit(AvailabilityInitialState());
  }
}

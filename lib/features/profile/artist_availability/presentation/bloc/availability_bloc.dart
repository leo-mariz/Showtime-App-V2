import 'package:app/features/authentication/domain/usecases/get_user_uid.dart';
import 'package:app/features/profile/artist_availability/domain/usecases/add_time_slot_usecase.dart';
import 'package:app/features/profile/artist_availability/domain/usecases/delete_time_slot_usecase.dart';
import 'package:app/features/profile/artist_availability/domain/usecases/get_all_availabilities_usecase.dart';
import 'package:app/features/profile/artist_availability/domain/usecases/get_availability_by_date_usecase.dart';
import 'package:app/features/profile/artist_availability/domain/usecases/toggle_availability_status_usecase.dart';
import 'package:app/features/profile/artist_availability/domain/usecases/update_address_and_radius_usecase.dart';
import 'package:app/features/profile/artist_availability/domain/usecases/update_time_slot_usecase.dart';
import 'package:app/features/profile/artist_availability/presentation/bloc/events/availability_events.dart';
import 'package:app/features/profile/artist_availability/presentation/bloc/states/availability_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// BLoC para gerenciar disponibilidade do artista
/// 
/// Gerencia todas as operações relacionadas à disponibilidade:
/// - Consulta (GetAll, GetByDate)
/// - Toggle de status (ativar/desativar)
/// - Endereço e raio
/// - Slots de horário (Add, Update, Delete)
class AvailabilityBloc extends Bloc<AvailabilityEvent, AvailabilityState> {
  // Use Cases
  final GetAllAvailabilitiesUseCase getAllAvailabilities;
  final GetAvailabilityByDateUseCase getAvailabilityByDate;
  final ToggleAvailabilityStatusUseCase toggleAvailabilityStatus;
  final UpdateAddressAndRadiusUseCase updateAddressRadius;
  final AddTimeSlotUseCase addTimeSlot;
  final UpdateTimeSlotUseCase updateTimeSlot;
  final DeleteTimeSlotUseCase deleteTimeSlot;
  
  // Authentication
  final GetUserUidUseCase getUserUidUseCase;

  AvailabilityBloc({
    required this.getAllAvailabilities,
    required this.getAvailabilityByDate,
    required this.toggleAvailabilityStatus,
    required this.updateAddressRadius,
    required this.addTimeSlot,
    required this.updateTimeSlot,
    required this.deleteTimeSlot,
    required this.getUserUidUseCase,
  }) : super(AvailabilityInitialState()) {
    // Registrar handlers
    on<GetAllAvailabilitiesEvent>(_onGetAllAvailabilities);
    on<GetAvailabilityByDateEvent>(_onGetAvailabilityByDate);
    on<ToggleAvailabilityStatusEvent>(_onToggleAvailabilityStatus);
    on<UpdateAddressRadiusEvent>(_onUpdateAddressRadius);
    on<AddTimeSlotEvent>(_onAddTimeSlot);
    on<UpdateTimeSlotEvent>(_onUpdateTimeSlot);
    on<DeleteTimeSlotEvent>(_onDeleteTimeSlot);
    on<ResetAvailabilityEvent>(_onReset);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Helper: Obter ID do usuário atual
  // ══════════════════════════════════════════════════════════════════════════

  Future<String?> _getCurrentUserId() async {
    final result = await getUserUidUseCase();
    return result.fold(
      (failure) => null,
      (uid) => uid,
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Handlers de Consulta
  // ══════════════════════════════════════════════════════════════════════════

  /// Handler para buscar todas as disponibilidades
  Future<void> _onGetAllAvailabilities(
    GetAllAvailabilitiesEvent event,
    Emitter<AvailabilityState> emit,
  ) async {
    emit(AvailabilityLoadingState(message: 'Carregando disponibilidades...'));

    final artistId = await _getCurrentUserId();
    if (artistId == null) {
      emit(AvailabilityErrorState(message: 'Usuário não autenticado'));
      return;
    }

    final result = await getAllAvailabilities(artistId, event.forceRemote);

    result.fold(
      (failure) => emit(AvailabilityErrorState(message: failure.message)),
      (days) => emit(AllAvailabilitiesLoadedState(days: days)),
    );
  }

  /// Handler para buscar disponibilidade de um dia
  Future<void> _onGetAvailabilityByDate(
    GetAvailabilityByDateEvent event,
    Emitter<AvailabilityState> emit,
  ) async {
    emit(AvailabilityLoadingState(message: 'Buscando disponibilidade...'));

    final artistId = await _getCurrentUserId();
    if (artistId == null) {
      emit(AvailabilityErrorState(message: 'Usuário não autenticado'));
      return;
    }

    final result = await getAvailabilityByDate(artistId, event.dto);

    result.fold(
      (failure) => emit(AvailabilityErrorState(message: failure.message)),
      (day) => emit(AvailabilityDayLoadedState(day: day)),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Handlers de Disponibilidade do Dia
  // ══════════════════════════════════════════════════════════════════════════

  /// Handler para ativar/desativar disponibilidade
  Future<void> _onToggleAvailabilityStatus(
    ToggleAvailabilityStatusEvent event,
    Emitter<AvailabilityState> emit,
  ) async {
    emit(AvailabilityLoadingState(message: 'Atualizando status...'));

    final artistId = await _getCurrentUserId();
    if (artistId == null) {
      emit(AvailabilityErrorState(message: 'Usuário não autenticado'));
      return;
    }

    final result = await toggleAvailabilityStatus(artistId, event.dto);

    result.fold(
      (failure) => emit(AvailabilityErrorState(message: failure.message)),
      (day) => emit(AvailabilityDayUpdatedState(
        day: day,
        message: event.dto.isActive
            ? 'Disponibilidade ativada'
            : 'Disponibilidade desativada',
      )),
    );
  }

  /// Handler para atualizar endereço e raio
  Future<void> _onUpdateAddressRadius(
    UpdateAddressRadiusEvent event,
    Emitter<AvailabilityState> emit,
  ) async {
    emit(AvailabilityLoadingState(message: 'Atualizando endereço...'));

    final artistId = await _getCurrentUserId();
    if (artistId == null) {
      emit(AvailabilityErrorState(message: 'Usuário não autenticado'));
      return;
    }

    final result = await updateAddressRadius(artistId, event.dto);

    result.fold(
      (failure) => emit(AvailabilityErrorState(message: failure.message)),
      (day) => emit(AvailabilityDayUpdatedState(
        day: day,
        message: 'Endereço e raio atualizados',
      )),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Handlers de Slots
  // ══════════════════════════════════════════════════════════════════════════

  /// Handler para adicionar slot
  Future<void> _onAddTimeSlot(
    AddTimeSlotEvent event,
    Emitter<AvailabilityState> emit,
  ) async {
    emit(AvailabilityLoadingState(message: 'Adicionando horário...'));

    final artistId = await _getCurrentUserId();
    if (artistId == null) {
      emit(AvailabilityErrorState(message: 'Usuário não autenticado'));
      return;
    }

    final result = await addTimeSlot(artistId, event.dto);

    result.fold(
      (failure) => emit(AvailabilityErrorState(message: failure.message)),
      (day) => emit(TimeSlotAddedState(day: day)),
    );
  }

  /// Handler para atualizar slot
  Future<void> _onUpdateTimeSlot(
    UpdateTimeSlotEvent event,
    Emitter<AvailabilityState> emit,
  ) async {
    emit(AvailabilityLoadingState(message: 'Atualizando horário...'));

    final artistId = await _getCurrentUserId();
    if (artistId == null) {
      emit(AvailabilityErrorState(message: 'Usuário não autenticado'));
      return;
    }

    final result = await updateTimeSlot(artistId, event.dto);

    result.fold(
      (failure) => emit(AvailabilityErrorState(message: failure.message)),
      (day) => emit(TimeSlotUpdatedState(day: day)),
    );
  }

  /// Handler para deletar slot
  Future<void> _onDeleteTimeSlot(
    DeleteTimeSlotEvent event,
    Emitter<AvailabilityState> emit,
  ) async {
    emit(AvailabilityLoadingState(message: 'Removendo horário...'));

    final artistId = await _getCurrentUserId();
    if (artistId == null) {
      emit(AvailabilityErrorState(message: 'Usuário não autenticado'));
      return;
    }

    final result = await deleteTimeSlot(artistId, event.dto);

    result.fold(
      (failure) => emit(AvailabilityErrorState(message: failure.message)),
      (day) => emit(TimeSlotDeletedState(day: day)),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Handler de Controle
  // ══════════════════════════════════════════════════════════════════════════

  /// Handler para resetar estado
  void _onReset(
    ResetAvailabilityEvent event,
    Emitter<AvailabilityState> emit,
  ) {
    emit(AvailabilityInitialState());
  }
}

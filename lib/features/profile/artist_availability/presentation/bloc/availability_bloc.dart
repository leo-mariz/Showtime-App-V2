import 'package:app/features/authentication/domain/usecases/get_user_uid.dart';
import 'package:app/features/profile/artist_availability/domain/usecases/day/add_time_slot_usecase.dart';
import 'package:app/features/profile/artist_availability/domain/usecases/day/delete_time_slot_usecase.dart';
import 'package:app/features/profile/artist_availability/domain/usecases/get_all_availabilities_usecase.dart';
import 'package:app/features/profile/artist_availability/domain/usecases/day/get_availability_by_date_usecase.dart';
import 'package:app/features/profile/artist_availability/domain/usecases/day/toggle_availability_status_usecase.dart';
import 'package:app/features/profile/artist_availability/domain/usecases/day/update_address_and_radius_usecase.dart';
import 'package:app/features/profile/artist_availability/domain/usecases/day/update_time_slot_usecase.dart';
import 'package:app/features/profile/artist_availability/domain/usecases/period/close_period_usecase.dart';
import 'package:app/features/profile/artist_availability/domain/usecases/period/open_period_usecase.dart';
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
/// - Períodos (Open, Close)
class AvailabilityBloc extends Bloc<AvailabilityEvent, AvailabilityState> {
  // Use Cases
  final GetAllAvailabilitiesUseCase getAllAvailabilities;
  final GetAvailabilityByDateUseCase getAvailabilityByDate;
  final ToggleAvailabilityStatusUseCase toggleAvailabilityStatus;
  final UpdateAddressAndRadiusUseCase updateAddressRadius;
  final AddTimeSlotUseCase addTimeSlot;
  final UpdateTimeSlotUseCase updateTimeSlot;
  final DeleteTimeSlotUseCase deleteTimeSlot;
  final OpenPeriodUseCase openPeriod;
  final ClosePeriodUseCase closePeriod;
  
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
    required this.openPeriod,
    required this.closePeriod,
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
    on<OpenPeriodEvent>(_onOpenPeriod);
    on<ClosePeriodEvent>(_onClosePeriod);
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
    print('[AvailabilityBloc] 🔄 Iniciando GetAllAvailabilities. forceRemote: ${event.forceRemote}');
    emit(GetAllAvailabilitiesLoadingState(message: 'Carregando disponibilidades...'));

    final artistId = await _getCurrentUserId();
    if (artistId == null) {
      print('[AvailabilityBloc] ❌ Usuário não autenticado');
      emit(GetAllAvailabilitiesErrorState(message: 'Usuário não autenticado'));
      emit(AvailabilityInitialState());
      return;
    }

    print('[AvailabilityBloc] 🔍 Buscando disponibilidades. ArtistId: $artistId');
    final result = await getAllAvailabilities(artistId, event.forceRemote);

    result.fold(
      (failure) {
        print('[AvailabilityBloc] ❌ Erro ao buscar disponibilidades: ${failure.message}');
        print('[AvailabilityBloc] ❌ Tipo de erro: ${failure.runtimeType}');
        emit(GetAllAvailabilitiesErrorState(message: failure.message));
        emit(AvailabilityInitialState());
      },
      (days) {
        print('[AvailabilityBloc] ✅ Disponibilidades carregadas. Total de dias: ${days.length}');
        emit(AllAvailabilitiesLoadedState(days: days));
      },
    );
  }

  /// Handler para buscar disponibilidade de um dia
  Future<void> _onGetAvailabilityByDate(
    GetAvailabilityByDateEvent event,
    Emitter<AvailabilityState> emit,
  ) async {
    emit(GetAvailabilityByDateLoadingState());

    final artistId = await _getCurrentUserId();
    if (artistId == null) {
      emit(GetAvailabilityByDateErrorState(message: 'Usuário não autenticado'));
      emit(AvailabilityInitialState());
      return;
    }

    final result = await getAvailabilityByDate(artistId, event.dto);

    result.fold(
      (failure) {
        emit(GetAvailabilityByDateErrorState(message: failure.message));
        emit(AvailabilityInitialState());
      },
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
    emit(ToggleAvailabilityStatusLoadingState());

    final artistId = await _getCurrentUserId();
    if (artistId == null) {
      emit(ToggleAvailabilityStatusErrorState(message: 'Usuário não autenticado'));
      emit(AvailabilityInitialState());
      return;
    }

    final result = await toggleAvailabilityStatus(artistId, event.dto);

    result.fold(
      (failure) {
        emit(ToggleAvailabilityStatusErrorState(message: failure.message));
        emit(AvailabilityInitialState());
      },
      (_) {
        final message = event.dto.isActive
            ? 'Disponibilidade ativada com sucesso'
            : 'Disponibilidade desativada com sucesso';
        emit(ToggleAvailabilityStatusSuccessState(message: message));
        emit(AvailabilityInitialState());
      },
    );
  }

  /// Handler para atualizar endereço e raio
  Future<void> _onUpdateAddressRadius(
    UpdateAddressRadiusEvent event,
    Emitter<AvailabilityState> emit,
  ) async {
    emit(UpdateAddressRadiusLoadingState());

    final artistId = await _getCurrentUserId();
    if (artistId == null) {
      emit(UpdateAddressRadiusErrorState(message: 'Usuário não autenticado'));
      emit(AvailabilityInitialState());
      return;
    }

    final result = await updateAddressRadius(artistId, event.dto);

    result.fold(
      (failure) {
        emit(UpdateAddressRadiusErrorState(message: failure.message));
        emit(AvailabilityInitialState());
      },
      (_) {
        emit(UpdateAddressRadiusSuccessState(
          message: 'Endereço e raio atualizados com sucesso',
        ));
        emit(AvailabilityInitialState());
      },
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
    emit(AddTimeSlotLoadingState());

    final artistId = await _getCurrentUserId();
    if (artistId == null) {
      emit(AddTimeSlotErrorState(message: 'Usuário não autenticado'));
      emit(AvailabilityInitialState());
      return;
    }

    final result = await addTimeSlot(artistId, event.dto);

    result.fold(
      (failure) {
        emit(AddTimeSlotErrorState(message: failure.message));
        emit(AvailabilityInitialState());
      },
      (addTimeSlotResult) {
        if (addTimeSlotResult.hasOverlapSlots) {
          final overlapsCount = addTimeSlotResult.totalOverlapsCount;
          emit(AddTimeSlotErrorState(
            message: 'Este horário se sobrepõe a $overlapsCount slot(s) existente(s).',
          ));
        } else {
          emit(AddTimeSlotSuccessState(
            message: 'Horário adicionado com sucesso',
          ));
        }
        emit(AvailabilityInitialState());
      },
    );
  }

  /// Handler para atualizar slot
  Future<void> _onUpdateTimeSlot(
    UpdateTimeSlotEvent event,
    Emitter<AvailabilityState> emit,
  ) async {
    emit(UpdateTimeSlotLoadingState());

    final artistId = await _getCurrentUserId();
    if (artistId == null) {
      emit(UpdateTimeSlotErrorState(message: 'Usuário não autenticado'));
      emit(AvailabilityInitialState());
      return;
    }

    final result = await updateTimeSlot(artistId, event.dto);

    result.fold(
      (failure) {
        emit(UpdateTimeSlotErrorState(message: failure.message));
        emit(AvailabilityInitialState());
      },
      (updateTimeSlotResult) {
        if (updateTimeSlotResult.hasOverlapSlots) {
          final overlapsCount = updateTimeSlotResult.totalOverlapsCount;
          emit(UpdateTimeSlotErrorState(
            message: 'Este horário se sobrepõe a $overlapsCount slot(s) existente(s).',
          ));
        } else {
          emit(UpdateTimeSlotSuccessState(
            message: 'Horário atualizado com sucesso',
          ));
        }
        emit(AvailabilityInitialState());
      },
    );
  }

  /// Handler para deletar slot
  Future<void> _onDeleteTimeSlot(
    DeleteTimeSlotEvent event,
    Emitter<AvailabilityState> emit,
  ) async {
    emit(DeleteTimeSlotLoadingState());

    final artistId = await _getCurrentUserId();
    if (artistId == null) {
      emit(DeleteTimeSlotErrorState(message: 'Usuário não autenticado'));
      emit(AvailabilityInitialState());
      return;
    }

    final result = await deleteTimeSlot(artistId, event.dto);

    result.fold(
      (failure) {
        emit(DeleteTimeSlotErrorState(message: failure.message));
        emit(AvailabilityInitialState());
      },
      (_) {
        emit(DeleteTimeSlotSuccessState(
          message: 'Horário removido com sucesso',
        ));
        emit(AvailabilityInitialState());
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Handlers de Períodos
  // ══════════════════════════════════════════════════════════════════════════

  /// Handler para abrir período de disponibilidade
  Future<void> _onOpenPeriod(
    OpenPeriodEvent event,
    Emitter<AvailabilityState> emit,
  ) async {
    emit(OpenPeriodLoadingState(
      message: 'Criando disponibilidades para o período...',
    ));

    final artistId = await _getCurrentUserId();
    if (artistId == null) {
      emit(OpenPeriodErrorState(message: 'Usuário não autenticado'));
      emit(AvailabilityInitialState());
      return;
    }

    final result = await openPeriod(artistId, event.dto);

    result.fold(
      (failure) {
        emit(OpenPeriodErrorState(message: failure.message));
        emit(AvailabilityInitialState());
      },
      (openPeriodResult) {
        final daysCount = openPeriodResult.daysCreatedCount;
        String message = 'Período aberto com sucesso! $daysCount dia(s) criado(s).';
        
        if (openPeriodResult.hasOverlapSlots) {
          final overlapsCount = openPeriodResult.totalOverlapsCount;
          final daysWithOverlaps = openPeriodResult.daysWithOverlapsCount;
          message += ' $overlapsCount slot(s) com sobreposição em $daysWithOverlaps dia(s) não foram adicionados.';
        }
        
        emit(OpenPeriodSuccessState(message: message));
        emit(AvailabilityInitialState());
      },
    );
  }

  /// Handler para fechar/bloquear período de disponibilidade
  Future<void> _onClosePeriod(
    ClosePeriodEvent event,
    Emitter<AvailabilityState> emit,
  ) async {
    emit(ClosePeriodLoadingState(
      message: 'Bloqueando período de disponibilidade...',
    ));

    final artistId = await _getCurrentUserId();
    if (artistId == null) {
      emit(ClosePeriodErrorState(message: 'Usuário não autenticado'));
      emit(AvailabilityInitialState());
      return;
    }

    print('[AvailabilityBloc] 🚀 Iniciando closePeriod. ArtistId: $artistId');
    print('[AvailabilityBloc] 📅 Período: ${event.dto.startDate} até ${event.dto.endDate}');
    print('[AvailabilityBloc] ⏰ Horário: ${event.dto.formattedStartTime} - ${event.dto.formattedEndTime}');
    
    final result = await closePeriod(artistId, event.dto);

    result.fold(
      (failure) {
        print('[AvailabilityBloc] ❌ Erro no closePeriod: ${failure.message}');
        print('[AvailabilityBloc] ❌ Tipo de erro: ${failure.runtimeType}');
        emit(ClosePeriodErrorState(message: failure.message));
        emit(AvailabilityInitialState());
      },
      (updatedDays) {
        print('[AvailabilityBloc] ✅ closePeriod concluído. Dias atualizados: ${updatedDays.length}');
        final daysCount = updatedDays.length;
        emit(ClosePeriodSuccessState(
          message: 'Período bloqueado com sucesso! $daysCount dia(s) atualizado(s).',
        ));
        emit(AvailabilityInitialState());
      },
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

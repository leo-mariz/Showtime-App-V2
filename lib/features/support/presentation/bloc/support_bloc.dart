import 'package:app/features/authentication/domain/usecases/get_user_uid.dart';
import 'package:app/features/support/domain/usecases/send_support_message_usecase.dart';
import 'package:app/features/support/presentation/bloc/events/support_events.dart';
import 'package:app/features/support/presentation/bloc/states/support_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SupportBloc extends Bloc<SupportEvent, SupportState> {
  final SendSupportMessageUseCase sendSupportMessageUseCase;
  final GetUserUidUseCase getUserUidUseCase;

  SupportBloc({
    required this.sendSupportMessageUseCase,
    required this.getUserUidUseCase,
  }) : super(SupportInitial()) {
    on<SendSupportMessageEvent>(_onSendSupportMessage);
  }

  Future<void> _onSendSupportMessage(
    SendSupportMessageEvent event,
    Emitter<SupportState> emit,
  ) async {
    emit(SendSupportMessageLoading());
    final uidResult = await getUserUidUseCase.call();
    final userId = uidResult.fold((_) => null, (id) => id);
    if (userId == null || userId.isEmpty) {
      emit(SendSupportMessageFailure(error: 'Usuário não autenticado'));
      emit(SupportInitial());
      return;
    }
    final input = SendSupportMessageInput(
      userId: userId,
      name: event.name,
      userEmail: event.userEmail,
      subject: event.subject,
      message: event.message,
      contractId: event.contractId,
    );
    final result = await sendSupportMessageUseCase.call(input);
    result.fold(
      (failure) {
        emit(SendSupportMessageFailure(error: failure.message));
        emit(SupportInitial());
      },
      (request) {
        emit(SendSupportMessageSuccess(request: request));
        emit(SupportInitial());
      },
    );
  }
}

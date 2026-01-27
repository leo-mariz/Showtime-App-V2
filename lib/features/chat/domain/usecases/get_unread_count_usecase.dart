import 'package:app/core/errors/failure.dart';
import 'package:app/features/chat/domain/repositories/chat_repository.dart';

/// Use case para obter o contador de mensagens não lidas
/// 
/// Retorna um Stream para atualização em tempo real
/// Usado para exibir badge no BottomNavBar
class GetUnreadCountUseCase {
  final IChatRepository repository;

  GetUnreadCountUseCase({required this.repository});

  /// Retorna stream do contador total de mensagens não lidas
  /// 
  /// [userId] - UID do usuário
  /// 
  /// Retorna Stream<int> que emite o total de não lidas
  /// Lança [ValidationFailure] se userId inválido
  Stream<int> call({
    required String userId,
  }) {
    // Validar userId
    if (userId.isEmpty) {
      throw const ValidationFailure(
        'ID do usuário não pode ser vazio',
      );
    }

    // Retornar stream
    return repository.getUnreadCountStream(userId);
  }
}

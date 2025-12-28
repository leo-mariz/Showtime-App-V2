import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/profile/clients/domain/usecases/get_client_usecase.dart';
import 'package:app/features/profile/clients/domain/usecases/update_client_usecase.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Atualizar preferências do cliente
/// 
/// RESPONSABILIDADES:
/// - Validar UID do cliente
/// - Validar lista de preferências
/// - Buscar cliente atual (do cache se disponível)
/// - Atualizar apenas o campo preferences
/// - Salvar atualização
class UpdateClientPreferencesUseCase {
  final GetClientUseCase getClientUseCase;
  final UpdateClientUseCase updateClientUseCase;

  UpdateClientPreferencesUseCase({
    required this.getClientUseCase,
    required this.updateClientUseCase,
  });

  Future<Either<Failure, void>> call(String uid, List<String> preferences) async {
    try {
      // Validar UID
      if (uid.isEmpty) {
        return const Left(ValidationFailure('UID do cliente não pode ser vazio'));
      }

      // Buscar cliente atual (cache-first)
      final getResult = await getClientUseCase(uid);
      
      return getResult.fold(
        (failure) => Left(failure),
        (currentClient) async {
          // Criar nova entidade com apenas preferences atualizado
          final updatedClient = currentClient.copyWith(
            preferences: preferences,
          );

          // Atualizar cliente
          return await updateClientUseCase(uid, updatedClient);
        },
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}

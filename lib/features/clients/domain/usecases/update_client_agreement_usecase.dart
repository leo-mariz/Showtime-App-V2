import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/clients/domain/usecases/get_client_usecase.dart';
import 'package:app/features/clients/domain/usecases/update_client_usecase.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Atualizar acordo de termos de uso do cliente
/// 
/// RESPONSABILIDADES:
/// - Validar UID do cliente
/// - Buscar cliente atual (do cache se disponível)
/// - Atualizar apenas o campo agreedToClientTermsOfUse
/// - Salvar atualização
class UpdateClientAgreementUseCase {
  final GetClientUseCase getClientUseCase;
  final UpdateClientUseCase updateClientUseCase;

  UpdateClientAgreementUseCase({
    required this.getClientUseCase,
    required this.updateClientUseCase,
  });

  Future<Either<Failure, void>> call(String uid, bool agreedToTerms) async {
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
          // Criar nova entidade com apenas agreedToClientTermsOfUse atualizado
          final updatedClient = currentClient.copyWith(
            agreedToClientTermsOfUse: agreedToTerms,
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


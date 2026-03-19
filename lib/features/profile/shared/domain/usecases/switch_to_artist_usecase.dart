import 'package:app/core/domain/artist/artist_individual/artist_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/authentication/domain/usecases/get_user_uid.dart';
import 'package:app/features/artists/artists/domain/usecases/get_artist_usecase.dart';
import 'package:app/features/contracts/domain/usecases/clear_contracts_cache_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

/// UseCase: Verificar se o usuário pode trocar para perfil de artista
/// 
/// RESPONSABILIDADES:
/// - Obter UID do usuário logado
/// - Verificar se perfil de artista já existe
/// - Retornar resultado indicando se perfil existe ou não
class SwitchToArtistUseCase {
  final GetUserUidUseCase getUserUidUseCase;
  final GetArtistUseCase getArtistUseCase;
  final ClearContractsCacheUseCase clearContractsCacheUseCase;

  SwitchToArtistUseCase({
    required this.getUserUidUseCase,
    required this.getArtistUseCase,
    required this.clearContractsCacheUseCase,
  });

  Future<Either<Failure, bool>> call() async {
    try {
      if (kDebugMode) {
        debugPrint('🔄 [SwitchToArtistUseCase] Iniciando verificação de perfil artista');
      }

      // 0. Limpar cache de contratos
      await clearContractsCacheUseCase.call();

      // 1. Obter UID do usuário
      final uidResult = await getUserUidUseCase.call();
      final uid = uidResult.fold(
        (failure) => null as String?,
        (id) => id,
      );
      if (uid == null || uid.isEmpty) {
        if (kDebugMode) debugPrint('🔴 [SwitchToArtistUseCase] UID vazio ou nulo');
        return uidResult.fold(
          (failure) => Left(failure),
          (_) => const Left(ValidationFailure('UID do usuário não encontrado')),
        );
      }

      if (kDebugMode) {
        debugPrint('🔄 [SwitchToArtistUseCase] Buscando artista uid=$uid');
      }
      // 2. Verificar se artista já existe
      final artistResult = await getArtistUseCase.call(uid);

      return artistResult.fold(
        (failure) {
          if (kDebugMode) {
            debugPrint('🔴 [SwitchToArtistUseCase] getArtist falhou: ${failure.runtimeType} - ${failure.message}');
          }
          return Left(failure);
        },
        (artist) {
          final profileExists = artist != ArtistEntity() && artist.uid != null;
          if (kDebugMode) {
            debugPrint('🟢 [SwitchToArtistUseCase] getArtist ok, profileExists=$profileExists');
          }
          return Right(profileExists);
        },
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('🔴 [SwitchToArtistUseCase] Exceção: $e');
        debugPrint('🔴 [SwitchToArtistUseCase] stackTrace: $stackTrace');
      }
      return Left(ErrorHandler.handle(e));
    }
  }
}


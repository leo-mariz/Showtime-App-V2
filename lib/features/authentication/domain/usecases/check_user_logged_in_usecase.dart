import 'package:app/core/domain/artist/artist_individual/artist_entity.dart';
import 'package:app/core/domain/client/client_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/core/services/auth_service.dart';
import 'package:app/features/authentication/domain/repositories/auth_repository.dart';
import 'package:app/features/profile/artists/domain/repositories/artists_repository.dart';
import 'package:app/features/profile/clients/domain/repositories/clients_repository.dart';
import 'package:dartz/dartz.dart';

/// Modelo de resposta do UseCase
class UserLoggedInResponse {
  final bool isLoggedIn;
  final bool isArtist;

  UserLoggedInResponse({
    required this.isLoggedIn,
    required this.isArtist,
  });
}

/// UseCase: Verificar se usuário está logado
/// 
/// RESPONSABILIDADES:
/// - Verificar se há sessão ativa no Firebase Auth
/// - Determinar tipo de perfil (Artist ou Client)
/// - Limpar cache se não houver perfil válido
class CheckUserLoggedInUseCase {
  final IAuthRepository authRepository;
  final IAuthServices authServices;
  final IClientsRepository clientsRepository;
  final IArtistsRepository artistsRepository;

  CheckUserLoggedInUseCase({
    required this.authRepository,
    required this.authServices,
    required this.clientsRepository,
    required this.artistsRepository,
  });

  Future<Either<Failure, UserLoggedInResponse>> call() async {
    try {
      // 1. Verificar sessão no Firebase Auth
      final isLoggedIn = await authServices.isUserLoggedIn();

      if (!isLoggedIn) {
        return Right(UserLoggedInResponse(
          isLoggedIn: false,
          isArtist: false,
        ));
      }

      // 2. Obter UID do usuário
      final uidResult = await authRepository.getUserUid();
      final uid = uidResult.fold(
        (failure) => throw failure,
        (uid) => uid,
      );

      if (uid == null || uid.isEmpty) {
        return const Left(AuthFailure('UID do usuário não encontrado'));
      }

      // 3. Verificar tipo de perfil (Artist ou Client)
      final artistResult = await artistsRepository.getArtist(uid);
      final artist = artistResult.fold(
        (failure) => throw failure,
        (artist) => artist,
      );

      if (artist != ArtistEntity()) {
        return Right(UserLoggedInResponse(
          isLoggedIn: true,
          isArtist: true,
        ));
      }

      final clientResult = await clientsRepository.getClient(uid);
      final client = clientResult.fold(
        (failure) => throw failure,
        (client) => client,
      );

      if (client != ClientEntity()) {
        return Right(UserLoggedInResponse(
          isLoggedIn: true,
          isArtist: false,
        ));
      }

      // 4. Nenhum perfil encontrado - limpar cache
      await authRepository.clearCache();
      
      return const Left(IncompleteDataFailure(
        'Usuário não possui perfil completo',
      ));
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}


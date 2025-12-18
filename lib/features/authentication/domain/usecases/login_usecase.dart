import 'package:app/core/domain/artist/artist_individual/artist_entity.dart';
import 'package:app/core/domain/client/client_entity.dart';
import 'package:app/core/domain/user/cnpj/cnpj_user_entity.dart';
import 'package:app/core/domain/user/cpf/cpf_user_entity.dart';
import 'package:app/core/domain/user/user_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/core/services/auth_service.dart';
import 'package:app/features/authentication/domain/repositories/users_repository.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Login de usuário
/// 
/// RESPONSABILIDADES:
/// - Validar credenciais
/// - Autenticar no Firebase Auth
/// - Verificar se email foi verificado
/// - Carregar dados do usuário
/// - Verificar se dados estão completos
/// - Salvar dados no cache
class LoginUseCase {
  final IAuthRepository repository;
  final IAuthServices authServices;

  LoginUseCase({
    required this.repository,
    required this.authServices,
  });

  Future<Either<Failure, void>> call(UserEntity user) async {
    try {
      final email = user.email;
      final password = user.password;
      final isArtist = user.isArtist ?? false;

      // 1. Validar dados
      if (email.isEmpty) {
        return const Left(ValidationFailure('Email não pode ser vazio'));
      }

      if (password == null || password.isEmpty) {
        return const Left(ValidationFailure('Senha não pode ser vazia'));
      }

      // 2. Autenticar no Firebase Auth
      final authResult = await authServices.loginUser(email, password);
      
      if (authResult.user == null) {
        return const Left(AuthFailure('Credenciais inválidas'));
      }

      final uid = authResult.user!.uid;

      // 3. Verificar se email foi verificado
      final isEmailVerified = await authServices.isEmailVerified();
      
      if (!isEmailVerified) {
        return const Left(IncompleteDataFailure(
          'Email não verificado',
          missingFields: ['emailVerification'],
        ));
      }

      // 4. Carregar dados do usuário
      final userResult = await repository.getUserData(uid);
      final userEntity = userResult.fold(
        (failure) => throw failure,
        (user) => user,
      );

      // 5. Verificar se possui CPF ou CNPJ
      var isCnpj = false;
      if (userEntity.cpfUser != null && userEntity.cpfUser != CpfUserEntity()) {
        isCnpj = false;
      } else if (userEntity.cnpjUser != null && userEntity.cnpjUser != CnpjUserEntity()) {
        isCnpj = true;
      } else {
        return const Left(IncompleteDataFailure(
          'Usuário não possui informações de CPF ou CNPJ',
          missingFields: ['cpfUser', 'cnpjUser'],
        ));
      }

      // 6. Carregar e validar perfil (Artist ou Client)
      if (isArtist) {
        final artistResult = await repository.getArtistData(uid);
        final artist = artistResult.fold(
          (failure) => throw failure,
          (artist) => artist,
        );

        if (artist == ArtistEntity()) {
          return const Left(IncompleteDataFailure(
            'Usuário não possui perfil de artista',
            missingFields: ['artistProfile'],
          ));
        }
      } else {
        final clientResult = await repository.getClientData(uid);
        final client = clientResult.fold(
          (failure) => throw failure,
          (client) => client,
        );

        if (client == ClientEntity()) {
          return const Left(IncompleteDataFailure(
            'Usuário não possui perfil de cliente',
            missingFields: ['clientProfile'],
          ));
        }
      }

      // 7. Atualizar cache com dados completos
      final updatedUser = userEntity.copyWith(
        uid: uid,
        isArtist: isArtist,
        isCnpj: isCnpj,
        isEmailVerified: isEmailVerified,
      );

      final updateResult = await repository.setUserData(updatedUser);
      updateResult.fold(
        (failure) => throw failure,
        (_) => null,
      );

      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}


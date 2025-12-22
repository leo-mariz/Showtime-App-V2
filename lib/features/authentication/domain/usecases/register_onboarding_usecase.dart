import 'package:app/core/domain/artist/artist_individual/incomplete_sections/incomplete_sections_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/core/services/auth_service.dart';
import 'package:app/features/authentication/domain/entities/register_entity.dart';
import 'package:app/features/authentication/domain/repositories/users_repository.dart';
import 'package:app/features/authentication/domain/usecases/send_welcome_email_usecase.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Completar cadastro com dados do onboarding
/// 
/// RESPONSABILIDADES:
/// - Validar dados do onboarding
/// - Verificar se CPF/CNPJ já existe
/// - Salvar dados CPF/CNPJ
/// - Criar perfil Artist ou Client
/// - Calcular seções incompletas (Artist)
/// - Enviar email de boas-vindas
class RegisterOnboardingUseCase {
  final IAuthRepository repository;
  final IAuthServices authServices;
  final SendWelcomeEmailUsecase sendWelcomeEmailUsecase;

  RegisterOnboardingUseCase({
    required this.repository,
    required this.authServices,
    required this.sendWelcomeEmailUsecase,
  });

  Future<Either<Failure, void>> call(RegisterEntity register) async {
    try {
      final user = register.user;
      final isArtist = user.isArtist ?? false;
      final isCnpj = user.isCnpj ?? false;

      // 1. Obter UID do usuário autenticado
      // Primeiro tenta buscar do Firebase Auth (mais confiável após login)
      String? uid = await authServices.getUserUid();
      
      // Se não encontrar no Firebase Auth, tenta buscar do cache
      if (uid == null || uid.isEmpty) {
        final uidResult = await repository.getUserUid();
        uid = uidResult.fold(
          (failure) => null,
          (cachedUid) => cachedUid,
        );
      }

      if (uid == null || uid.isEmpty) {
        return const Left(AuthFailure('Usuário não autenticado'));
      }

      // 2. Validar e salvar dados CPF/CNPJ
      if (isCnpj) {
        final cnpjUser = user.cnpjUser;
        if (cnpjUser == null) {
          return const Left(ValidationFailure('Dados CNPJ não fornecidos'));
        }

        // Verificar se CNPJ já existe
        final cnpjExistsResult = await repository.cnpjExists(cnpjUser.cnpj ?? '');
        final cnpjExists = cnpjExistsResult.fold(
          (failure) => throw failure,
          (exists) => exists,
        );

        if (cnpjExists) {
          return const Left(ValidationFailure('CNPJ já cadastrado'));
        }

        final saveCnpjResult = await repository.setCnpjUserInfo(uid, cnpjUser);
        saveCnpjResult.fold(
          (failure) => throw failure,
          (_) => null,
        );
      } else {
        final cpfUser = user.cpfUser;
        if (cpfUser == null) {
          return const Left(ValidationFailure('Dados CPF não fornecidos'));
        }

        // Verificar se CPF já existe
        final cpfExistsResult = await repository.cpfExists(cpfUser.cpf ?? '');
        final cpfExists = cpfExistsResult.fold(
          (failure) => throw failure,
          (exists) => exists,
        );

        if (cpfExists) {
          return const Left(ValidationFailure('CPF já cadastrado'));
        }

        final saveCpfResult = await repository.setCpfUserInfo(uid, cpfUser);
        saveCpfResult.fold(
          (failure) => throw failure,
          (_) => null,
        );
      }

      // 3. Criar perfil Artist ou Client
      if (isArtist) {
        var artist = register.artist;

        // Calcular seções incompletas
        final incompleteSections = UserIncompleteSectionsEntity.verify(
          artist: artist,
          documents: [],
        );
        
        artist = artist.copyWith(
          uid: uid,
          hasIncompleteSections: incompleteSections.hasIncompleteSections,
          incompleteSections: incompleteSections.getGroupedIncompleteSections(),
        );

        // Definir artistName se não fornecido
        if (artist.artistName == null || artist.artistName!.isEmpty) {
          final artistName = isCnpj
              ? user.cnpjUser?.fantasyName ?? ''
              : '${user.cpfUser?.firstName ?? ''} ${user.cpfUser?.lastName ?? ''}'.trim();
          
          artist = artist.copyWith(artistName: artistName);
        }

        final saveArtistResult = await repository.setArtistData(uid, artist);
        saveArtistResult.fold(
          (failure) => throw failure,
          (_) => null,
        );
      } else {
        var client = register.client;
        client = client.copyWith(uid: uid);

        final saveClientResult = await repository.setClientData(uid, client);
        saveClientResult.fold(
          (failure) => throw failure,
          (_) => null,
        );
      }

      // 4. Atualizar dados do usuário
      final isEmailVerified = await authServices.isEmailVerified();
      final userToUpdate = user.copyWith(
        uid: uid,
        isEmailVerified: isEmailVerified,
      );

      final updateUserResult = await repository.setUserData(userToUpdate);
      updateUserResult.fold(
        (failure) => throw failure,
        (_) => null,
      );

      // 5. Enviar email de boas-vindas
      await sendWelcomeEmailUsecase.call(user);

      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}


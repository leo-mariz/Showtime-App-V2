import 'package:app/core/domain/user/user_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/core/services/auth_service.dart';
import 'package:app/features/authentication/domain/repositories/users_repository.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Registrar usuário com email e senha
/// 
/// RESPONSABILIDADES:
/// - Validar dados de entrada
/// - Verificar se email já existe
/// - Criar conta no Firebase Auth
/// - Salvar dados iniciais no Firestore
/// - Enviar email de verificação
class RegisterEmailPasswordUseCase {
  final IAuthRepository repository;
  final IAuthServices authServices;

  RegisterEmailPasswordUseCase({
    required this.repository,
    required this.authServices,
  });

  Future<Either<Failure, String>> call(UserEntity user) async {
    try {
      // 1. Validar dados
      final email = user.email;
      final password = user.password;

      if (email.isEmpty) {
        return const Left(ValidationFailure('Email não pode ser vazio'));
      }

      if (password == null || password.isEmpty) {
        return const Left(ValidationFailure('Senha não pode ser vazia'));
      }

      if (password.length < 6) {
        return const Left(ValidationFailure('Senha deve ter no mínimo 6 caracteres'));
      }

      // 2. Verificar se email já existe
      final emailExistsResult = await repository.emailExists(email);
      final emailExists = emailExistsResult.fold(
        (failure) => throw failure,
        (exists) => exists,
      );

      if (emailExists) {
        return const Left(ValidationFailure('Email já cadastrado'));
      }

      // 3. Criar conta no Firebase Auth
      final authResult = await authServices.registerEmailAndPassword(email, password);
      
      if (authResult.user == null) {
        return const Left(AuthFailure('Erro ao criar conta'));
      }

      final uid = authResult.user!.uid;

      // 4. Enviar email de verificação
      await authServices.sendEmailVerification();

      // 5. Salvar dados iniciais no Firestore
      final userToSave = UserEntity(
        uid: uid,
        email: email,
        isEmailVerified: false,
      );

      final saveResult = await repository.setUserData(userToSave);
      
      return saveResult.fold(
        (failure) => Left(failure),
        (_) => Right(uid),
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}


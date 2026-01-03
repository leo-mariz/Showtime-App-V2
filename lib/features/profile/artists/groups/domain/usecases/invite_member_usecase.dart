// import 'package:app/core/errors/error_handler.dart';
// import 'package:app/core/errors/failure.dart';
// import 'package:app/features/profile/artists/groups/domain/repositories/groups_repository.dart';
// import 'package:dartz/dartz.dart';

// /// UseCase: Convidar membro para o grupo
// /// 
// /// RESPONSABILIDADES:
// /// - Validar UID do grupo
// /// - Validar email do membro
// /// - Adicionar email à lista de convites do grupo
// /// 
// /// NOTA: Requer implementação do método inviteMember no IGroupsRepository
// class InviteMemberUseCase {
//   final IGroupsRepository repository;

//   InviteMemberUseCase({
//     required this.repository,
//   });

//   Future<Either<Failure, void>> call(
//     String groupUid,
//     String email,
//   ) async {
//     try {
//       // Validar UID do grupo
//       if (groupUid.isEmpty) {
//         return const Left(ValidationFailure('UID do grupo não pode ser vazio'));
//       }

//       // Validar email
//       if (email.isEmpty) {
//         return const Left(ValidationFailure('Email não pode ser vazio'));
//       }

//       // Validar formato básico de email
//       final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
//       if (!emailRegex.hasMatch(email)) {
//         return const Left(ValidationFailure('Email inválido'));
//       }


//       return result.fold(
//         (failure) => Left(failure),
//         (_) => const Right(null),
//       );
//     } catch (e) {
//       return Left(ErrorHandler.handle(e));
//     }
//   }
// }


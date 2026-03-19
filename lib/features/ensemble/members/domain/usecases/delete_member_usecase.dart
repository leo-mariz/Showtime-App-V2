// import 'package:app/core/errors/error_handler.dart';
// import 'package:app/core/errors/failure.dart';
// import 'package:app/features/ensemble/ensemble/domain/usecases/get_ensemble_usecase.dart';
// import 'package:app/features/ensemble/ensemble/domain/usecases/update_ensemble_members_usecase.dart';
// import 'package:app/features/ensemble/members/domain/repositories/members_repository.dart';
// import 'package:app/features/ensemble/members/domain/usecases/get_member_usecase.dart';
// import 'package:dartz/dartz.dart';

// /// Use case: remover um integrante.
// /// Antes de deletar o documento do membro, remove-o da lista de membros
// /// de todos os conjuntos em [EnsembleMemberEntity.ensembleIds].
// class DeleteMemberUseCase {
//   final IMembersRepository repository;
//   final GetMemberUseCase getMemberUseCase;
//   final GetEnsembleUseCase getEnsembleUseCase;
//   final UpdateEnsembleMembersUseCase updateEnsembleMembersUseCase;

//   DeleteMemberUseCase({
//     required this.repository,
//     required this.getMemberUseCase,
//     required this.getEnsembleUseCase,
//     required this.updateEnsembleMembersUseCase,
//   });

//   Future<Either<Failure, void>> call(
//     String artistId,
//     String memberId,
//   ) async {
//     try {
//       if (artistId.isEmpty) {
//         return const Left(ValidationFailure('artistId é obrigatório'));
//       }
//       if (memberId.isEmpty) {
//         return const Left(ValidationFailure('memberId é obrigatório'));
//       }

//       final getMemberResult = await getMemberUseCase.call(
//         artistId,
//         memberId,
//         forceRemote: true,
//       );
//       return await getMemberResult.fold(
//         (failure) async {
//           return Left(failure);
//         },
//         (member) async {
//           if (member == null) {
//             return const Left(NotFoundFailure('Integrante não encontrado'));
//           }

//           final ensembleIds = member.ensembleIds;

//           if (ensembleIds?.isNotEmpty ?? false) {
//             for (final ensembleId in ensembleIds ?? []) {
//               final getEnsembleResult =
//                   await getEnsembleUseCase.call(artistId, ensembleId);
//               final Either<Failure, void> updatedResult =
//                   await getEnsembleResult.fold(
//                 (failure) {
//                   return Future.value(Left<Failure, void>(failure));
//                 },
//                 (ensemble) async {
//                   if (ensemble == null) {
//                     return const Right(null);
//                   }
//                   final currentMembers = ensemble.members ?? [];
//                   final newMembers =
//                       currentMembers.where((m) => m.memberId != memberId).toList();
//                   final result = await updateEnsembleMembersUseCase.call(
//                     artistId,
//                     ensembleId,
//                     newMembers,
//                   );
//                   return result;
//                 },
//               );
//               final didFail = updatedResult.fold((_) => true, (_) => false);
//               if (didFail) {
//                 return updatedResult;
//               }
//             }
//           }
//           return await repository.delete(
//             artistId: artistId,
//             memberId: memberId,
//           );
//         },
//       );
//     } catch (e) {
//       return Left(ErrorHandler.handle(e));
//     }
//   }
// }

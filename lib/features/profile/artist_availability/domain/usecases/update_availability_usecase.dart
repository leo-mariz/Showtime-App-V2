import 'package:app/core/domain/artist/availability_calendar_entitys/availability_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/profile/artist_availability/domain/repositories/availability_repository.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Atualizar disponibilidade existente
/// 
/// RESPONSABILIDADES:
/// - Validar ID da disponibilidade
/// - Calcular Geohash do endereço (se endereço foi alterado)
/// - Atualizar disponibilidade no repositório
class UpdateAvailabilityUseCase {
  final IAvailabilityRepository repository;

  UpdateAvailabilityUseCase({
    required this.repository,
  });

  Future<Either<Failure, void>> call({
    required String artistId,
    required AvailabilityEntity updatedAvailability,
  }) async {
    try {
      // Valida se tem ID
      if (updatedAvailability.id == null || updatedAvailability.id!.isEmpty) {
        return const Left(ValidationFailure('ID da disponibilidade é obrigatório para atualização'));
      }
      
      // Salva a availability atualizada
      return await repository.updateAvailability(artistId, updatedAvailability);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}


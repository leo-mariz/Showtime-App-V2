import 'package:app/core/domain/contract/contract_entity.dart';
import 'package:app/core/enums/contract_status_enum.dart';
import 'package:app/features/artists/artist_dashboard/domain/entities/next_show_entity.dart';

/// UseCase: Calcular o próximo show do artista
/// 
/// RESPONSABILIDADES:
/// - Filtrar contratos pagos com data futura
/// - Ordenar por data
/// - Retornar o próximo show (mais próximo)
/// - Formatar dados para exibição
class CalculateNextShowUseCase {
  const CalculateNextShowUseCase();

  NextShowEntity? call(List<ContractEntity> contracts) {
    final now = DateTime.now();
    
    // Filtrar contratos pagos com data futura
    final upcomingPaidContracts = contracts.where((contract) {
      // Verificar se o contrato está pago
      if (contract.status != ContractStatusEnum.paid) return false;
      
      // Verificar se a data do evento é futura (comparar apenas data, sem hora)
      final eventDate = DateTime(
        contract.date.year,
        contract.date.month,
        contract.date.day,
      );
      final today = DateTime(now.year, now.month, now.day);
      
      return eventDate.isAfter(today) || eventDate.isAtSameMomentAs(today);
    }).toList();

    if (upcomingPaidContracts.isEmpty) return null;

    // Ordenar por data (mais próximo primeiro)
    upcomingPaidContracts.sort((a, b) => a.date.compareTo(b.date));

    // Pegar o primeiro (mais próximo)
    final nextContract = upcomingPaidContracts.first;

    // Formatar título (nome do tipo de evento)
    final title = nextContract.eventType?.name ?? 'Show';

    // Nome do cliente/anfitrião
    final clientName = nextContract.nameClient ?? 'Cliente';

    // Formatar localização (bairro - cidade)
    final locationParts = <String>[];
    if (nextContract.address.district != null && 
        nextContract.address.district!.isNotEmpty) {
      locationParts.add(nextContract.address.district!);
    }
    if (nextContract.address.city != null && 
        nextContract.address.city!.isNotEmpty) {
      locationParts.add(nextContract.address.city!);
    }
    final location = locationParts.isNotEmpty 
        ? locationParts.join(' - ')
        : 'Localização não informada';

    return NextShowEntity(
      contractUid: nextContract.uid ?? '',
      title: title,
      clientName: clientName,
      date: nextContract.date,
      time: nextContract.time,
      location: location,
      duration: nextContract.duration.toString(),
    );
  }
}

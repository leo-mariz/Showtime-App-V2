import 'package:app/core/domain/contract/contract_entity.dart';
import 'package:intl/intl.dart';

/// Extensão para formatação e exibição de prazos de aceitação de contratos
extension ContractDeadlineExtension on ContractEntity {
  /// Retorna uma string formatada com o prazo restante para aceitar
  /// Exemplos: "Você tem até 14:30 para aceitar", "Prazo expira em 2h 15min", "Prazo expirado"
  String? get formattedAcceptDeadline {
    if (acceptDeadline == null || !isPending) return null;
    
    final now = DateTime.now();
    
    // Se expirado
    if (now.isAfter(acceptDeadline!)) {
      return 'Prazo expirado';
    }
    
    final remaining = acceptDeadline!.difference(now);
    
    // Se falta menos de 1 hora, mostrar em minutos
    if (remaining.inHours < 1) {
      final minutes = remaining.inMinutes;
      if (minutes <= 0) {
        return 'Prazo expirado';
      }
      return 'Prazo expira em ${minutes}min';
    }
    
    // Se falta menos de 24 horas, mostrar horas e minutos
    if (remaining.inHours < 24) {
      final hours = remaining.inHours;
      final minutes = remaining.inMinutes % 60;
      if (minutes > 0) {
        return 'Prazo expira em ${hours}h ${minutes}min';
      }
      return 'Prazo expira em ${hours}h';
    }
    
    // Se falta mais de 24 horas, mostrar data e hora
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    return 'Você tem até ${dateFormat.format(acceptDeadline!)} para aceitar';
  }
  
  /// Retorna uma string curta com o prazo (para badges/indicadores)
  /// Exemplos: "2h 15min", "45min", "Expirado"
  String? get shortDeadlineText {
    if (acceptDeadline == null || !isPending) return null;
    
    final now = DateTime.now();
    
    // Se expirado
    if (now.isAfter(acceptDeadline!)) {
      return 'Expirado';
    }
    
    final remaining = acceptDeadline!.difference(now);
    
    // Se falta menos de 1 hora, mostrar em minutos
    if (remaining.inHours < 1) {
      final minutes = remaining.inMinutes;
      if (minutes <= 0) {
        return 'Expirado';
      }
      return '${minutes}min';
    }
    
    // Se falta menos de 24 horas, mostrar horas e minutos
    if (remaining.inHours < 24) {
      final hours = remaining.inHours;
      final minutes = remaining.inMinutes % 60;
      if (minutes > 0) {
        return '${hours}h ${minutes}min';
      }
      return '${hours}h';
    }
    
    // Se falta mais de 24 horas, mostrar apenas data
    final dateFormat = DateFormat('dd/MM HH:mm');
    return dateFormat.format(acceptDeadline!);
  }
  
  /// Retorna true se o prazo está próximo do vencimento (menos de 30 minutos)
  bool get isDeadlineNear {
    if (acceptDeadline == null || !isPending) return false;
    final remaining = remainingTimeToAccept;
    if (remaining == null) return false;
    return remaining.inMinutes < 30;
  }
  
  /// Retorna true se o prazo está crítico (menos de 10 minutos)
  bool get isDeadlineCritical {
    if (acceptDeadline == null || !isPending) return false;
    final remaining = remainingTimeToAccept;
    if (remaining == null) return false;
    return remaining.inMinutes < 10;
  }

  /// Texto para exibição ao cliente: data/hora limite em que o artista pode aceitar
  /// Ex: "O artista tem até 14/02 às 14:30 para responder"
  String? get formattedAcceptDeadlineForClient {
    if (acceptDeadline == null || !isPending) return null;
    final dateFormat = DateFormat("dd/MM 'às' HH:mm");
    return 'O artista tem até ${dateFormat.format(acceptDeadline!)} para responder';
  }
}

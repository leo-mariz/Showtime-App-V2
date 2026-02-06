import 'package:app/core/domain/contract/contract_entity.dart';
import 'package:intl/intl.dart';

/// Extensão para formatação e exibição de prazos de aceitação de contratos
extension ContractDeadlineExtension on ContractEntity {
  /// Retorna uma string formatada com o prazo restante para aceitar
  /// Exemplos: "Você tem até 14:30 para aceitar", "Prazo expira em 2h 15min", "Prazo expirado"
  String? get formattedAcceptDeadline {
    if (acceptDeadline == null || !isPending) return null;
    final nowUtc = DateTime.now().toUtc();
    final deadlineUtc = acceptDeadline!.isUtc ? acceptDeadline! : DateTime.utc(acceptDeadline!.year, acceptDeadline!.month, acceptDeadline!.day, acceptDeadline!.hour, acceptDeadline!.minute, acceptDeadline!.second, acceptDeadline!.millisecond);

    if (nowUtc.isAfter(deadlineUtc)) return 'Prazo expirado';
    final remaining = deadlineUtc.difference(nowUtc);
    
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
    
    // Se falta mais de 24 horas, mostrar data e hora (em horário local do usuário)
    final toShow = acceptDeadline!.isUtc ? acceptDeadline!.toLocal() : acceptDeadline!;
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    return 'Você tem até ${dateFormat.format(toShow)} para aceitar';
  }

  /// Retorna uma string curta com o prazo (para badges/indicadores)
  String? get shortDeadlineText {
    if (acceptDeadline == null || !isPending) return null;
    final nowUtc = DateTime.now().toUtc();
    final deadlineUtc = acceptDeadline!.isUtc ? acceptDeadline! : DateTime.utc(acceptDeadline!.year, acceptDeadline!.month, acceptDeadline!.day, acceptDeadline!.hour, acceptDeadline!.minute, acceptDeadline!.second, acceptDeadline!.millisecond);
    if (nowUtc.isAfter(deadlineUtc)) return 'Expirado';
    final remaining = deadlineUtc.difference(nowUtc);
    
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
    
    final toShow = acceptDeadline!.isUtc ? acceptDeadline!.toLocal() : acceptDeadline!;
    final dateFormat = DateFormat('dd/MM HH:mm');
    return dateFormat.format(toShow);
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

  /// Texto para exibição ao cliente: data/hora limite em que o artista pode aceitar (horário local)
  String? get formattedAcceptDeadlineForClient {
    if (acceptDeadline == null || !isPending) return null;
    final toShow = acceptDeadline!.isUtc ? acceptDeadline!.toLocal() : acceptDeadline!;
    final dateFormat = DateFormat("dd/MM 'às' HH:mm");
    return 'O artista tem até ${dateFormat.format(toShow)} para responder';
  }

  // ---------- Prazo de pagamento (anfitrião) ----------

  static DateTime? _paymentDeadlineUtc(ContractEntity c) {
    if (c.paymentDueDate == null || !c.isPaymentPending) return null;
    final d = c.paymentDueDate!;
    return d.isUtc ? d : DateTime.utc(d.year, d.month, d.day, d.hour, d.minute, d.second, d.millisecond);
  }

  /// Texto formatado do prazo para o anfitrião pagar
  String? get formattedPaymentDeadline {
    final deadlineUtc = _paymentDeadlineUtc(this);
    if (deadlineUtc == null) return null;
    final nowUtc = DateTime.now().toUtc();
    if (nowUtc.isAfter(deadlineUtc)) return 'Prazo de pagamento expirado';
    final remaining = deadlineUtc.difference(nowUtc);
    if (remaining.inHours < 1) {
      final minutes = remaining.inMinutes;
      if (minutes <= 0) return 'Prazo de pagamento expirado';
      return 'Pagamento expira em ${minutes}min';
    }
    if (remaining.inHours < 24) {
      final hours = remaining.inHours;
      final minutes = remaining.inMinutes % 60;
      if (minutes > 0) return 'Pagamento expira em ${hours}h ${minutes}min';
      return 'Pagamento expira em ${hours}h';
    }
    final toShow = paymentDueDate!.isUtc ? paymentDueDate!.toLocal() : paymentDueDate!;
    return 'Você tem até ${DateFormat('dd/MM/yyyy HH:mm').format(toShow)} para pagar';
  }

  /// Texto curto do prazo de pagamento (badges)
  String? get shortPaymentDeadlineText {
    final deadlineUtc = _paymentDeadlineUtc(this);
    if (deadlineUtc == null) return null;
    final nowUtc = DateTime.now().toUtc();
    if (nowUtc.isAfter(deadlineUtc)) return 'Expirado';
    final remaining = deadlineUtc.difference(nowUtc);
    if (remaining.inHours < 1) {
      final minutes = remaining.inMinutes;
      if (minutes <= 0) return 'Expirado';
      return '${minutes}min';
    }
    if (remaining.inHours < 24) {
      final hours = remaining.inHours;
      final minutes = remaining.inMinutes % 60;
      if (minutes > 0) return '${hours}h ${minutes}min';
      return '${hours}h';
    }
    final toShow = paymentDueDate!.isUtc ? paymentDueDate!.toLocal() : paymentDueDate!;
    return DateFormat('dd/MM HH:mm').format(toShow);
  }

  bool get isPaymentDeadlineNear {
    if (paymentDueDate == null || !isPaymentPending) return false;
    final remaining = remainingTimeToPay;
    return remaining != null && remaining.inMinutes < 30;
  }

  bool get isPaymentDeadlineCritical {
    if (paymentDueDate == null || !isPaymentPending) return false;
    final remaining = remainingTimeToPay;
    return remaining != null && remaining.inMinutes < 10;
  }

  /// Para o artista: texto com prazo que o anfitrião tem para pagar
  String? get formattedPaymentDeadlineForArtist {
    if (paymentDueDate == null || !isPaymentPending) return null;
    final toShow = paymentDueDate!.isUtc ? paymentDueDate!.toLocal() : paymentDueDate!;
    final dateFormat = DateFormat("dd/MM 'às' HH:mm");
    return 'O anfitrião tem até ${dateFormat.format(toShow)} para pagar';
  }
}

import 'package:dart_mappable/dart_mappable.dart';

part 'suspended_entity.mapper.dart';

/// Snapshot de uma suspensão aplicada ao usuário.
/// Usado em [UserEntity.suspensionHistory] para o painel visualizar histórico antes de banir.
@MappableClass()
class SuspendedEntity with SuspendedEntityMappable {
  /// Quando a suspensão foi aplicada.
  final DateTime? suspendedAt;
  /// Até quando a suspensão vale.
  final DateTime? suspendedUntil;
  /// Id do motivo (ex.: lista applists).
  final String? reason;
  /// Observações opcionais da aplicação.
  final String? notes;
  /// UID do admin que aplicou.
  final String? appliedByUid;

  const SuspendedEntity({
    this.suspendedAt,
    this.suspendedUntil,
    this.reason,
    this.notes,
    this.appliedByUid,
  });
}

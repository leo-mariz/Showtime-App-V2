enum DocumentStatusEnum {
  pending(0, 'Não enviado'),
  analysis(1, 'Em análise'),
  approved(2, 'Aprovado'),
  rejected(3, 'Rejeitado');

  final int value;
  final String label;

  const DocumentStatusEnum(this.value, this.label);

  static DocumentStatusEnum fromValue(int value) {
    return DocumentStatusEnum.values.firstWhere(
      (status) => status.value == value,
      orElse: () => DocumentStatusEnum.pending,
    );
  }
}


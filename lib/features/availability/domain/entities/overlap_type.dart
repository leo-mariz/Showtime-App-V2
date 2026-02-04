/// Tipo de sobreposição entre dois slots de horário
/// 
/// Define como um novo slot se sobrepõe a um slot existente,
/// permitindo resolução automática inteligente.
enum OverlapType {
  /// O novo slot sobrepõe o INÍCIO do slot existente
  /// 
  /// **Exemplo:**
  /// ```
  /// Novo slot:      [13:00 ████████████ 19:00]
  /// Slot existente:        [16:00 ████████████ 20:00]
  ///                         ↑↑↑ Sobrepõe início
  /// ```
  /// 
  /// **Resolução:**
  /// - Ajustar slot existente para começar após o novo
  /// - Slot existente: 16:00-20:00 → 19:00-20:00
  partialBefore,

  /// O novo slot sobrepõe o FINAL do slot existente
  /// 
  /// **Exemplo:**
  /// ```
  /// Novo slot:              [13:00 ████████████ 19:00]
  /// Slot existente: [10:00 ████████████ 15:00]
  ///                              ↑↑↑ Sobrepõe final
  /// ```
  /// 
  /// **Resolução:**
  /// - Ajustar slot existente para terminar antes do novo
  /// - Slot existente: 10:00-15:00 → 10:00-13:00
  partialAfter,

  /// O slot existente CONTÉM completamente o novo slot
  /// 
  /// **Exemplo:**
  /// ```
  /// Novo slot:        [13:00 ████ 19:00]
  /// Slot existente: [10:00 ████████████████ 22:00]
  ///                    ↑↑↑           ↑↑↑ Contém
  /// ```
  /// 
  /// **Resolução:**
  /// - Dividir slot existente em dois
  /// - Slot existente: 10:00-22:00 → 10:00-13:00 + 19:00-22:00
  contains,

  /// O novo slot CONTÉM completamente o slot existente
  /// 
  /// **Exemplo:**
  /// ```
  /// Novo slot:      [10:00 ████████████████ 22:00]
  /// Slot existente:   [13:00 ████ 19:00]
  ///                    ↑↑↑        ↑↑↑ Contido
  /// ```
  /// 
  /// **Resolução:**
  /// - Remover slot existente completamente
  /// - Slot existente será deletado
  contained,

  /// Sobreposição exata (mesmos horários)
  /// 
  /// **Exemplo:**
  /// ```
  /// Novo slot:      [13:00 ████████████ 19:00]
  /// Slot existente: [13:00 ████████████ 19:00]
  ///                  ↑↑↑               ↑↑↑ Exatos
  /// ```
  /// 
  /// **Resolução:**
  /// - Substituir slot existente pelo novo (ou apenas atualizar valor)
  exact,
}

/// Extensão para adicionar métodos úteis ao OverlapType
extension OverlapTypeExtension on OverlapType {
  /// Descrição amigável do tipo de sobreposição
  String get description {
    return switch (this) {
      OverlapType.partialBefore => 
        'Sobrepõe o início do slot existente',
      OverlapType.partialAfter => 
        'Sobrepõe o final do slot existente',
      OverlapType.contains => 
        'Está completamente dentro do slot existente',
      OverlapType.contained => 
        'Contém completamente o slot existente',
      OverlapType.exact => 
        'Tem os mesmos horários do slot existente',
    };
  }

  /// Ação de resolução sugerida
  String get resolutionAction {
    return switch (this) {
      OverlapType.partialBefore => 
        'Ajustar início do slot existente',
      OverlapType.partialAfter => 
        'Ajustar final do slot existente',
      OverlapType.contains => 
        'Dividir slot existente em dois',
      OverlapType.contained => 
        'Remover slot existente',
      OverlapType.exact => 
        'Substituir slot existente',
    };
  }

  /// Ícone representativo (para UI)
  String get icon {
    return switch (this) {
      OverlapType.partialBefore => '◀─',
      OverlapType.partialAfter => '─▶',
      OverlapType.contains => '◀─▶',
      OverlapType.contained => '✕',
      OverlapType.exact => '=',
    };
  }

  /// Se verdadeiro, a resolução requer criar novos slots
  bool get requiresSplit {
    return this == OverlapType.contains;
  }

  /// Se verdadeiro, a resolução requer deletar slots
  bool get requiresDeletion {
    return this == OverlapType.contained;
  }

  /// Se verdadeiro, a resolução requer atualizar horários
  bool get requiresAdjustment {
    return this == OverlapType.partialBefore || 
           this == OverlapType.partialAfter ||
           this == OverlapType.exact;
  }
}

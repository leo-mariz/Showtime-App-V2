/// Antecedência mínima fixa do app para eventos no mesmo dia (1h30).
/// Usada no explorar para não mostrar artista/conjunto quando, para "hoje",
/// não houver pelo menos 1h30 de janela bookável à frente (alinhado à tela de request).
const int sameDayMinimumLeadTimeMinutes = 90;

/// Helper para filtragem por antecedência mínima de solicitação.
///
/// Usado no explorar (artistas e conjuntos) para garantir que o dia
/// selecionado pelo anfitrião respeite a preferência do artista/conjunto
/// de ser solicitado com X horas/dias de antecedência.
///
/// Exemplo: hoje 10/fev, anfitrião busca artista para 11/fev. Artista
/// tem antecedência mínima de 48h. A diferença 11/fev - 10/fev é 1 dia
/// (1440 min) < 48h (2880 min) → artista não deve aparecer na busca.
bool respectsMinimumEarliness(
  DateTime selectedDate,
  int? requestMinimumEarlinessMinutes, {
  DateTime? referenceDate,
}) {
  final minMinutes = requestMinimumEarlinessMinutes ?? 0;
  if (minMinutes <= 0) return true;

  final ref = referenceDate ?? DateTime.now();
  final refStart = DateTime(ref.year, ref.month, ref.day);
  final selectedStart = DateTime(
    selectedDate.year,
    selectedDate.month,
    selectedDate.day,
  );
  final diffMinutes = selectedStart.difference(refStart).inMinutes;
  return diffMinutes >= minMinutes;
}

/// Retorna o primeiro momento em que uma solicitação pode ser feita
/// (agora + antecedência mínima em minutos).
/// Ex.: 17:34 hoje + 12h → 05:34 de amanhã.
DateTime slotCutoffDateTime(
  int? requestMinimumEarlinessMinutes, {
  DateTime? referenceDate,
}) {
  final minMinutes = requestMinimumEarlinessMinutes ?? 0;
  final ref = referenceDate ?? DateTime.now();
  return ref.add(Duration(minutes: minMinutes));
}

/// Verifica se um slot (dia + horário de início no formato "HH:mm")
/// está no ou após o [cutoff]. Usado no calendário para só mostrar
/// dias que tenham pelo menos um slot disponível a partir do cutoff.
bool isSlotAtOrAfterCutoff(
  DateTime day,
  String startTimeHHmm,
  DateTime cutoff,
) {
  final parts = startTimeHHmm.split(':');
  if (parts.length < 2) return false;
  final hour = int.tryParse(parts[0]) ?? 0;
  final minute = int.tryParse(parts[1]) ?? 0;
  final slotStart = DateTime(
    day.year,
    day.month,
    day.day,
    hour,
    minute,
  );
  return !slotStart.isBefore(cutoff);
}

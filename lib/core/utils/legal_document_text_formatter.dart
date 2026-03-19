/// Formata texto jurídico vindo do Firestore em uma única linha para exibição com quebras.
///
/// Insere quebras de linha antes de:
/// - Subseções no padrão `1.1.`, `2.10.`, etc. (dois grupos numéricos + ponto final)
/// - Seções principais no padrão `1. `, `2. ` … `99. ` seguido de texto (não confunde com `1.1.`)
/// - Separadores `---` isolados
///
/// Não altera textos que já estão bem quebrados (evita duplicar linhas vazias onde o padrão
/// não se aplica).
String formatLegalDocumentForDisplay(String raw) {
  var s = raw.replaceAll('\r\n', '\n').trim();
  if (s.isEmpty) return s;

  // Separadores horizontais comuns nos termos
  s = s.replaceAll(RegExp(r'\s*---\s*'), '\n\n---\n\n');

  // Subseções: "…texto. 1.1. Coleta" → quebra antes de 1.1.
  // Exige caractere não-espaço antes do bloco de espaços + marcador (evita match no início órfão).
  s = s.replaceAllMapped(
    RegExp(r'(?<=\S)\s+(\d{1,2}\.\d{1,2}\.)'),
    (m) => '\n${m[1]}',
  );

  // Seções principais: "…vigente. 2. Uso das" → quebra antes de 2.
  // O marcador deve ser N dígitos + ". " (espaço); o próximo caractere deve iniciar o título
  // (letra latina com acentos comuns ou abre-parênteses/aspas).
  s = s.replaceAllMapped(
    RegExp(
      r'(?<=\S)\s+([1-9]\d{0,2}\.\s+)(?=[A-Za-zÀ-ÿ\u00C0-\u024F\(„«"])',
      unicode: true,
    ),
    (m) => '\n${m[1]}',
  );

  // Compacta excesso de linhas em branco
  s = s.replaceAll(RegExp(r'\n{3,}'), '\n\n');

  return s.trim();
}

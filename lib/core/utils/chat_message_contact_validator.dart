/// Validação de conteúdo de mensagem de chat para bloquear compartilhamento
/// de informações de contato (telefone, email, redes sociais, etc.).
///
/// Use em use cases de envio de mensagem e na UI para feedback consistente.
/// Retorna [containsDisallowedContactInfo] = true quando a mensagem deve ser bloqueada.

/// Chave/mensagem retornada quando a validação falha por conter informações de contato.
/// A UI pode comparar [Failure.message] com esta constante para exibir o snackbar específico.
const String kChatContactInfoValidationMessage =
    'Informações de contato não permitidas';

/// Retorna [true] se [message] contiver conteúdo que não é permitido
/// (telefone, WhatsApp, email, redes sociais, expressões como "me liga", "me add", etc.,
/// ou mensagem contendo somente números).
/// Use antes de enviar a mensagem; se true, bloqueie o envio e mostre o erro ao usuário.
bool containsDisallowedContactInfo(String message) {
  if (message.trim().isEmpty) return false;

  // Bloquear mensagens que contêm apenas números (e espaços), ex.: "21", "9", "87", "1 2 3"
  final withoutSpaces = message.trim().replaceAll(RegExp(r'\s+'), '');
  if (withoutSpaces.isNotEmpty && RegExp(r'^\d+$').hasMatch(withoutSpaces)) {
    return true;
  }

  final normalizedMessage =
      message.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
  final cleanMessage = normalizedMessage.replaceAll(
    RegExp(r'[*\-_.()[\]{}|\\/:;,<>+=~`^]'),
    '',
  );

  final phoneRegex = RegExp(
    r'(\(?\d{2}\)?\s?)?\d{4,5}[-.\s*_]?\d{4}|'
    r'\d{10,11}|'
    r'\+55\s?\(?\d{2}\)?\s?\d{4,5}[-.\s*_]?\d{4}|'
    r'nove\s?\d|oito\s?\d|sete\s?\d|seis\s?\d',
    caseSensitive: false,
  );
  final emailRegex = RegExp(
    r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b|'
    r'[A-Za-z0-9._%+-]+\s?@\s?[A-Za-z0-9.-]+\s?\.\s?[A-Z|a-z]{2,}|'
    r'[A-Za-z0-9._%+-]+\s?\(arroba\)\s?[A-Za-z0-9.-]+\s?\(ponto\)\s?[A-Z|a-z]{2,}',
    caseSensitive: false,
  );
  final contactKeywords = RegExp(
    r'\b(whats?app|zap|telefone|celular|contato|fone|numero|email|e-mail|'
    r'gmail|hotmail|outlook|yahoo|ig|instagram|face|facebook|'
    r'ligue|liga|chama|chama no|me\s?add|add\s?ai|'
    r'meu\s?(numero|fone|whats|zap)|'
    r'(numero|fone|whats|zap)\s?(do|da|meu|minha)|'
    r'passa\s?(teu|seu|o)\s?(numero|fone|whats|zap)|'
    r'me\s?manda\s?(teu|seu|o)\s?(numero|fone|whats|zap))\b',
    caseSensitive: false,
  );
  final suspiciousNumbers = RegExp(
    r'\d[\s*.\-_]*\d[\s*.\-_]*\d[\s*.\-_]*\d[\s*.\-_]*\d[\s*.\-_]*\d[\s*.\-_]*\d[\s*.\-_]*\d',
  );

  return phoneRegex.hasMatch(message) ||
      phoneRegex.hasMatch(cleanMessage) ||
      emailRegex.hasMatch(message) ||
      contactKeywords.hasMatch(normalizedMessage) ||
      suspiciousNumbers.hasMatch(message);
}

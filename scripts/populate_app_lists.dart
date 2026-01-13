// app/scripts/populate_app_lists.dart
import 'dart:io';
import 'dart:convert';
import 'package:dart_firebase_admin/dart_firebase_admin.dart';
import 'package:dart_firebase_admin/firestore.dart';

/// Script para popular as listas estáticas do app no Firestore
/// 
/// Executar com: dart run scripts/populate_app_lists.dart
/// 
/// IMPORTANTE: Você precisa de uma chave de conta de serviço do Firebase.
/// 1. Vá no Firebase Console > Configurações do Projeto > Contas de Serviço
/// 2. Clique em "Gerar nova chave privada"
/// 3. Salve o arquivo JSON como 'serviceAccountKey.json' na raiz do projeto app/
/// 4. OU defina a variável de ambiente GOOGLE_APPLICATION_CREDENTIALS
Future<void> main() async {
  print('🚀 Iniciando população das listas do app...\n');

  // Inicializar Firebase Admin
  // Opção 1: Usar arquivo de chave de conta de serviço
  final serviceAccountPath = Platform.environment['GOOGLE_APPLICATION_CREDENTIALS'] ?? 
                              'serviceAccountKey.json';
  
  FirebaseAdminApp app;
  try {
    if (!File(serviceAccountPath).existsSync()) {
      print('❌ Arquivo de chave de conta de serviço não encontrado: $serviceAccountPath');
      print('');
      print('📝 Para resolver:');
      print('   1. Vá no Firebase Console > Configurações do Projeto > Contas de Serviço');
      print('   2. Clique em "Gerar nova chave privada"');
      print('   3. Salve o arquivo JSON como "serviceAccountKey.json" na raiz do projeto app/');
      print('   OU defina a variável de ambiente GOOGLE_APPLICATION_CREDENTIALS');
      exit(1);
    }
    
    // Usar arquivo de chave de conta de serviço
    // Ler o projectId do arquivo JSON para usar como nome do app
    final serviceAccountFile = File(serviceAccountPath);
    final serviceAccountContent = await serviceAccountFile.readAsString();
    final serviceAccountJson = jsonDecode(serviceAccountContent) as Map<String, dynamic>;
    final projectId = serviceAccountJson['project_id'] as String? ?? 'showtime-v2-homolog';
    
    app = FirebaseAdminApp.initializeApp(
      projectId,
      Credential.fromServiceAccount(serviceAccountFile),
    );
    
    print('✅ Firebase inicializado com sucesso!');
    print('   Project ID: ${app.projectId}\n');
  } catch (e) {
    print('❌ Erro ao inicializar Firebase: $e');
    print('');
    print('📝 Verifique se:');
    print('   1. O arquivo serviceAccountKey.json existe e está no caminho correto');
    print('   2. O arquivo contém credenciais válidas do Firebase');
    print('   3. A conta de serviço tem permissões para escrever no Firestore');
    exit(1);
  }

  // Inicializar Firestore
  final firestore = Firestore(app);

  try {
    // 1. Popular Talentos
    // print('📝 Populando lista de Talentos...');
    // await _populateTalents(firestore);
    // print('✅ Talentos populados com sucesso!\n');

    // // 2. Popular Tipos de Evento
    // print('📝 Populando lista de Tipos de Evento...');
    // await _populateEventTypes(firestore);
    // print('✅ Tipos de Evento populados com sucesso!\n');

    // // 3. Popular Assuntos de Suporte
    // print('📝 Populando lista de Assuntos de Suporte...');
    // await _populateSupportSubjects(firestore);
    // print('✅ Assuntos de Suporte populados com sucesso!\n');

    // // 4. Popular Palavras-chave
    // print('📝 Populando lista de Palavras-chave...');
    await _populateKeywords(firestore);
    print('✅ Palavras-chave populadas com sucesso!\n');

    print('🎉 Todas as listas foram populadas com sucesso!');
  } catch (e, stackTrace) {
    print('❌ Erro ao popular listas: $e');
    print('Stack trace: $stackTrace');
    exit(1);
  }
}

/// Popula a lista de talentos de artistas
Future<void> _populateTalents(Firestore firestore) async {
  const talents = [
    'Cantor(a)',
    'Chorinho/Cavaquinho',
    'Contador(a) História Infantil',
    'Dançarino(a) Forró',
    'Dançarino(a) Frevo',
    'Dançarino(a) Lambada',
    'Dançarino(a) Tango',
    'DJ',
    'Dupla Sertaneja',
    'Embaixadinhas',
    'Engolidor(a) espada ',
    'Engolidor(a) fogo ',
    'Estátua Viva',
    'Flautista',
    'Gaitista',
    'Harpista',
    'Hipnose cômica',
    'Mágico',
    'Malabarista',
    'Mimico',
    'Palhaço(a)',
    'Percussionista',
    'Personagens',
    'Pianista/Tecladista',
    'Pole Dance',
    'Presença Famosos',
    'Repentista',
    'Sambista',
    'Sanfoneiro(a)',
    'Saxofonista',
    'Seresteiro(a)',
    'Sombra',
    'Soprano',
    'Sósias',
    'Stand Up',
    'Teatro Infantil',
    'Tenor',
    'Trompetista',
    'Valsa 15 anos',
    'Ventriloquo',
    'Violinista',
    'Violoncelista',
    'Banda/Conjunto',
    'Baterista',
    'Stand Up - Humor',
    'Stand Up - Poesia',
  ];

  final collectionRef = firestore
      .collection('AppLists')
      .doc('talents')
      .collection('items');

  // Limpar documentos existentes (opcional - descomente se quiser limpar)
  // final existingDocs = await collectionRef.get();
  // for (var doc in existingDocs.docs) {
  //   await doc.reference.delete();
  // }

  int order = 0;

  for (final talent in talents) {
    final docRef = collectionRef.doc();
    final now = DateTime.now();
    await docRef.set({
      'name': talent.trim(),
      'description': null,
      'order': order++,
      'isActive': true,
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
    });
  }

  print('   ✓ ${talents.length} talentos adicionados');
}

/// Popula a lista de tipos de evento
Future<void> _populateEventTypes(Firestore firestore) async {
  const eventTypes = [
    'Casamento',
    'Festa de Aniversário',
    'Festa de 15 Anos',
    'Festa de Aniversário Infantil',
    'Bodas',
    'Festa de Formatura',
    'Evento Corporativo',
    'Confraternização',
    'Festa ao Ar Livre',
    'Show Musical',
    'Apresentação Artística',
    'Festival',
    'Evento Cultural',
    'Evento Religioso',
    'Inauguração',
    'Lançamento de Produto',
    'Workshop/Curso',
    'Ensaio Fotográfico',
    'Evento de Networking',
    'Happy Hour',
    'Festa Junina',
    'Carnaval',
    'Natal/Ano Novo',
    'Dia das Crianças',
    'Dia das Mães',
    'Dia dos Pais',
    'São João',
    'Halloween',
    'Festa Temática',
    'Roda de Samba',
    'Forró Pé de Serra',
    'Baile de Debutantes',
    'Chá de Bebê',
    'Chá de Panela',
    'Despedida de Solteiro(a)',
    'Aniversário de Empresa',
    'Evento Esportivo',
    'Feira/Congresso',
    'Seminário',
    'Coquetel',
  ];

  final collectionRef = firestore
      .collection('AppLists')
      .doc('eventTypes')
      .collection('items');

  // Limpar documentos existentes (opcional - descomente se quiser limpar)
  // final existingDocs = await collectionRef.get();
  // for (var doc in existingDocs.docs) {
  //   await doc.reference.delete();
  // }

  int order = 0;

  for (final eventType in eventTypes) {
    final docRef = collectionRef.doc();
    final now = DateTime.now();
    await docRef.set({
      'name': eventType.trim(),
      'description': null,
      'order': order++,
      'isActive': true,
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
    });
  }

  print('   ✓ ${eventTypes.length} tipos de evento adicionados');
}

/// Popula a lista de assuntos de suporte
Future<void> _populateSupportSubjects(Firestore firestore) async {
  const supportSubjects = [
    'Problemas com Contrato',
    'Pagamento',
    'Cancelamento',
    'Atraso do Artista',
    'Problemas Técnicos',
    'Dúvidas sobre Agendamento',
    'Problemas com Perfil',
    'Relatar Problema',
    'Sugestões',
    'Outros',
  ];

  final collectionRef = firestore
      .collection('AppLists')
      .doc('supportSubjects')
      .collection('items');

  // Limpar documentos existentes (opcional - descomente se quiser limpar)
  // final existingDocs = await collectionRef.get();
  // for (var doc in existingDocs.docs) {
  //   await doc.reference.delete();
  // }

  int order = 0;

  for (final subject in supportSubjects) {
    final docRef = collectionRef.doc();
    final now = DateTime.now();
    await docRef.set({
      'name': subject.trim(),
      'description': null,
      'order': order++,
      'isActive': true,
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
    });
  }

  print('   ✓ ${supportSubjects.length} assuntos de suporte adicionados');
}

/// Popula a lista de palavras chaves
Future<void> _populateKeywords(Firestore firestore) async {
  const keywords = [
    'música',
    'dança',
    'canto',
    'show',
    'palco',
    'artista',
    'ator',
    'atriz',
    'teatro',
    'cinema',
    'filme',
    'drama',
    'comédia',
    'ópera',
    'balé',
    'jazz',
    'rock',
    'pop',
    'samba',
    'bossa',
    'funk',
    'rap',
    'blues',
    'soul',
    'reggae',
    'gospel',
    'sertanejo',
    'forró',
    'pagode',
    'MPB',
    'violão',
    'guitarra',
    'piano',
    'bateria',
    'baixo',
    'saxofone',
    'trompete',
    'flauta',
    'violino',
    'cello',
    'acordeon',
    'pandeiro',
    'tambor',
    'cavaquinho',
    'ukulele',
    'harpa',
    'órgão',
    'sintetizador',
    'microfone',
    'amplificador',
    'cenário',
    'iluminação',
    'som',
    'mixagem',
    'gravação',
    'estúdio',
    'ensaio',
    'apresentação',
    'performance',
    'espetáculo',
    'concerto',
    'festival',
    'turnê',
    'público',
    'plateia',
    'palmas',
    'bis',
    'repertório',
    'letra',
    'melodia',
    'harmonia',
    'ritmo',
    'acorde',
    'tom',
    'escala',
    'partitura',
    'nota',
    'compasso',
    'tempo',
    'maestro',
    'diretor',
    'coreógrafo',
    'produtor',
    'técnico',
    'manager',
    'agente',
    'contrato',
    'ingresso',
    'bilheteria',
    'camarim',
    'bastidores',
    'cortina',
    'figurino',
    'maquiagem',
    'caracterização',
    'expressão',
    'atuação',
    'roteiro',
    'elenco',
    'personagem',
    'cena',
    'ato',
    'monólogo',
    'diálogo',
    'solilóquio',
    'protagonista',
    'antagonista',
    'coadjuvante',
    'figurante',
    'dublagem',
    'narração',
    'locução',
    'voz',
    'timbre',
    'tessitura',
    'vibrato',
    'falsete',
    'agudo',
    'grave',
    'médio',
    'soprano',
    'tenor',
    'barítono',
    'contralto',
    'mezzosoprano',
    'coral',
    'coro',
    'solo',
    'dueto',
    'trio',
    'quarteto',
    'orquestra',
    'banda',
    'grupo',
    'conjunto',
    'formação',
    'instrumentista',
    'vocalista',
    'compositor',
    'arranjador',
    'letrista',
    'autor',
    'intérprete',
    'executante',
    'solista',
    'regente',
    'ensaiador',
    'preparador',
    'coach',
    'professor',
    'instrutor',
    'mentor',
    'discípulo',
    'conservatório',
    'academia',
    'atelier',
    'oficina',
    'workshop',
    'masterclass',
    'técnica',
    'método',
    'estilo',
    'gênero',
    'modalidade',
    'vertente',
    'tendência',
    'movimento',
    'corrente',
    'vanguarda',
    'tradição',
    'clássico',
    'moderno',
    'contemporâneo',
    'experimental',
    'alternativo',
    'underground',
    'mainstream',
    'indie',
    'autoral',
    'cover',
    'versão',
  ];

  final collectionRef = firestore
      .collection('AppLists')
      .doc('keywords')
      .collection('items');

  // Limpar documentos existentes (opcional - descomente se quiser limpar)
  // final existingDocs = await collectionRef.get();
  // for (var doc in existingDocs.docs) {
  //   await doc.reference.delete();
  // }

  int order = 0;

  for (final keyword in keywords) {
    final docRef = collectionRef.doc();
    final now = DateTime.now();
    await docRef.set({
      'name': keyword.trim(),
      'description': null,
      'order': order++,
      'isActive': true,
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
    });
  }

  print('   ✓ ${keywords.length} palavras-chave adicionadas');
}
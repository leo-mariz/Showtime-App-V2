// app/scripts/seed_firestore.dart
import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'package:dart_firebase_admin/dart_firebase_admin.dart';
import 'package:dart_firebase_admin/firestore.dart';
import 'package:dart_geohash/dart_geohash.dart';

/// Script para popular o Firestore com dados mockados
/// 
/// Cria 100 artistas e 5 disponibilidades para cada um
/// 
/// Executar com: dart run scripts/seed_firestore.dart
/// 
/// IMPORTANTE: Você precisa de uma chave de conta de serviço do Firebase.
/// 1. Vá no Firebase Console > Configurações do Projeto > Contas de Serviço
/// 2. Clique em "Gerar nova chave privada"
/// 3. Salve o arquivo JSON como 'serviceAccountKey.json' na raiz do projeto app/
/// 4. OU defina a variável de ambiente GOOGLE_APPLICATION_CREDENTIALS
Future<void> main() async {
  print('🔥 Inicializando Firebase Admin SDK...');
  
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
      projectId, // Usar o projectId como nome do app para evitar confusão
      Credential.fromServiceAccount(serviceAccountFile),
    );
    
    // Verificar se o projectId está correto
    print('✅ Firebase inicializado com sucesso!');
    print('   Project ID: ${app.projectId}');
  } catch (e) {
    print('❌ Erro ao inicializar Firebase: $e');
    print('');
    print('📝 Verifique se:');
    print('   1. O arquivo serviceAccountKey.json existe e está no caminho correto');
    print('   2. O arquivo contém credenciais válidas do Firebase');
    print('   3. A conta de serviço tem permissões para escrever no Firestore');
    exit(1);
  }

  // Inicializar Firestore (o projectId vem automaticamente do app)
  final firestore = Firestore(app);
  final random = Random();
  final geoHasher = GeoHasher();

  // Lista de nomes de artistas mais realistas e diversos
  final artistNames = [
    'João Silva', 'Maria Santos', 'Pedro Oliveira', 'Ana Costa', 'Carlos Souza',
    'Juliana Ferreira', 'Rafael Almeida', 'Fernanda Lima', 'Bruno Martins', 'Camila Rocha',
    'Lucas Pereira', 'Beatriz Gomes', 'Thiago Rodrigues', 'Isabela Araújo', 'Gabriel Barbosa',
    'Larissa Nunes', 'Felipe Castro', 'Mariana Dias', 'Rodrigo Monteiro', 'Amanda Ribeiro',
    'Gustavo Carvalho', 'Patrícia Moura', 'Diego Freitas', 'Renata Lopes', 'André Mendes',
    'Vanessa Teixeira', 'Ricardo Campos', 'Tatiana Ramos', 'Marcelo Azevedo', 'Priscila Cardoso',
    'Leandro Farias', 'Daniela Moreira', 'Henrique Barros', 'Cristina Machado', 'Vinicius Pires',
    'Banda Rock SP', 'DJ Eletrônica', 'Trio Sertanejo', 'Dupla MPB', 'Grupo Samba',
    'Orquestra Jazz', 'Banda Blues', 'Grupo Pagode', 'Banda Forró', 'Coral Gospel',
    'Solo Acústico', 'Dupla Romântica', 'Trio Instrumental', 'Quarteto Bossa', 'Quinteto Jazz',
    'Banda Cover', 'DJ House', 'MC Rap', 'Cantor Sertanejo', 'Vocalista Pop',
    'Guitarrista Solo', 'Pianista Clássico', 'Violonista MPB', 'Baterista Rock', 'Saxofonista Jazz',
    'Cantora Gospel', 'Banda Indie', 'Grupo Reggae', 'Dupla Country', 'Trio Folk',
    'Banda Metal', 'DJ Trap', 'MC Funk', 'Cantor Romântico', 'Vocalista Soul',
    'Banda Alternativa', 'Grupo Acústico', 'Dupla Pop Rock', 'Trio Eletrônico', 'Quarteto Samba',
    'Banda Festa', 'DJ Baile', 'Grupo Seresta', 'Dupla Serenata', 'Trio Seresta',
    'Banda Casamento', 'DJ Eventos', 'Grupo Aniversário', 'Dupla Confraternização', 'Trio Corporativo',
    'Banda Show', 'DJ Clube', 'Grupo Bar', 'Dupla Restaurante', 'Trio Hotel',
    'Banda Teatro', 'DJ Festival', 'Grupo Praça', 'Dupla Parque', 'Trio Shopping',
    'Banda Rua', 'DJ Rooftop', 'Grupo Terraço', 'Dupla Varanda', 'Trio Quintal',
    'Banda Estúdio', 'DJ Estúdio', 'Grupo Gravação', 'Dupla Produção', 'Trio Mixagem',
  ];
  
  // Gêneros disponíveis
  final genres = [
    'Rock', 'Pop', 'Sertanejo', 'MPB', 'Funk', 'Rap', 'Jazz', 
    'Blues', 'Eletrônica', 'Samba', 'Pagode', 'Forró', 'Gospel',
    'Reggae', 'Indie', 'Alternativa', 'Metal', 'Country', 'Folk', 'Soul'
  ];

  // Especialidades
  final specialties = [
    'Cantor', 'Banda', 'DJ', 'Instrumentista', 'Compositor', 
    'Produtor Musical', 'Músico Solo', 'Dupla', 'Trio', 'Grupo',
    'Orquestra', 'Coral', 'Quarteto', 'Quinteto'
  ];

  // Lista de endereços reais de São Paulo (12 endereços reais)
  final realAddresses = [
    {
      'title': 'Avenida Paulista',
      'street': 'Avenida Paulista',
      'number': '1578',
      'district': 'Bela Vista',
      'city': 'São Paulo',
      'state': 'SP',
      'zipCode': '01310-200',
      'latitude': -23.5614,
      'longitude': -46.6560,
    },
    {
      'title': 'Rua Augusta',
      'street': 'Rua Augusta',
      'number': '1234',
      'district': 'Consolação',
      'city': 'São Paulo',
      'state': 'SP',
      'zipCode': '01305-100',
      'latitude': -23.5505,
      'longitude': -46.6586,
    },
    {
      'title': 'Vila Madalena',
      'street': 'Rua Harmonia',
      'number': '567',
      'district': 'Vila Madalena',
      'city': 'São Paulo',
      'state': 'SP',
      'zipCode': '05435-000',
      'latitude': -23.5462,
      'longitude': -46.6912,
    },
    {
      'title': 'Pinheiros',
      'street': 'Rua dos Pinheiros',
      'number': '890',
      'district': 'Pinheiros',
      'city': 'São Paulo',
      'state': 'SP',
      'zipCode': '05422-001',
      'latitude': -23.5671,
      'longitude': -46.6915,
    },
    {
      'title': 'Itaim Bibi',
      'street': 'Rua Bandeira Paulista',
      'number': '456',
      'district': 'Itaim Bibi',
      'city': 'São Paulo',
      'state': 'SP',
      'zipCode': '04532-001',
      'latitude': -23.5925,
      'longitude': -46.6889,
    },
    {
      'title': 'Jardins',
      'street': 'Alameda Santos',
      'number': '2100',
      'district': 'Jardim Paulista',
      'city': 'São Paulo',
      'state': 'SP',
      'zipCode': '01418-000',
      'latitude': -23.5705,
      'longitude': -46.6608,
    },
    {
      'title': 'Vila Olímpia',
      'street': 'Rua Funchal',
      'number': '340',
      'district': 'Vila Olímpia',
      'city': 'São Paulo',
      'state': 'SP',
      'zipCode': '04551-060',
      'latitude': -23.5922,
      'longitude': -46.6881,
    },
    {
      'title': 'Moema',
      'street': 'Avenida Ibirapuera',
      'number': '2900',
      'district': 'Moema',
      'city': 'São Paulo',
      'state': 'SP',
      'zipCode': '04029-200',
      'latitude': -23.6000,
      'longitude': -46.6600,
    },
    {
      'title': 'Brooklin',
      'street': 'Avenida Santo Amaro',
      'number': '3500',
      'district': 'Brooklin',
      'city': 'São Paulo',
      'state': 'SP',
      'zipCode': '04556-001',
      'latitude': -23.6150,
      'longitude': -46.6800,
    },
    {
      'title': 'Liberdade',
      'street': 'Rua Galvão Bueno',
      'number': '500',
      'district': 'Liberdade',
      'city': 'São Paulo',
      'state': 'SP',
      'zipCode': '01506-000',
      'latitude': -23.5596,
      'longitude': -46.6333,
    },
    {
      'title': 'Bela Vista',
      'street': 'Rua Augusta',
      'number': '2000',
      'district': 'Bela Vista',
      'city': 'São Paulo',
      'state': 'SP',
      'zipCode': '01305-100',
      'latitude': -23.5505,
      'longitude': -46.6586,
    },
    {
      'title': 'Consolação',
      'street': 'Rua da Consolação',
      'number': '1500',
      'district': 'Consolação',
      'city': 'São Paulo',
      'state': 'SP',
      'zipCode': '01302-000',
      'latitude': -23.5450,
      'longitude': -46.6500,
    },
  ];

  print('📝 Criando ${artistNames.length} artistas com disponibilidades diversas...');
  print('   - Usando ${realAddresses.length} endereços reais de São Paulo');
  print('   - Cada artista terá entre 3 e 7 disponibilidades');
  print('   - ~35% das disponibilidades terão horários bloqueados');

  // Processar em batches para não sobrecarregar
  const batchSize = 10;
  final totalBatches = (artistNames.length / batchSize).ceil();
  int totalArtists = 0;
  int totalAvailabilities = 0;

  for (int batch = 0; batch < totalBatches; batch++) {
    int artistsInBatch = 0;
    int availabilitiesInBatch = 0;

    for (int i = 0; i < batchSize; i++) {
      final artistIndex = batch * batchSize + i;
      if (artistIndex >= artistNames.length) break;

      final artistId = 'artist_${artistIndex.toString().padLeft(3, '0')}';
      final artistName = artistNames[artistIndex];

      // Selecionar gêneros e especialidades aleatórias
      final selectedGenres = genres.sublist(0, random.nextInt(4) + 2);
      final selectedSpecialties = [specialties[random.nextInt(specialties.length)]];

      // Criar professionalInfo (objeto aninhado dentro do documento do artista)
      final professionalInfo = {
        'genrePreferences': selectedGenres,
        'specialty': selectedSpecialties,
        'bio': 'Artista profissional com experiência em shows e eventos. Especializado em ${selectedSpecialties.first} com foco em ${selectedGenres.join(", ")}.',
        'hourlyRate': random.nextDouble() * 500 + 100, // 100 a 600
        'minimumShowDuration': random.nextInt(60) + 30, // 30 a 90 minutos
      };

      // Criar dados do artista (com professionalInfo aninhado)
      final artistData = {
        'artistName': artistName,
        'approved': true,
        'isActive': true,
        'agreedToArtistTermsOfUse': true,
        'dateRegistered': DateTime.now().toIso8601String(),
        'rating': random.nextDouble() * 5, // 0 a 5
        'finalizedContracts': random.nextInt(100),
        'hasIncompleteSections': false,
        'isOnAnyGroup': false,
        'professionalInfo': professionalInfo, // Objeto aninhado, não subcoleção
      };

      // Criar documento do artista
      final artistRef = firestore.collection('Artists').doc(artistId);
      await artistRef.set(artistData);
      artistsInBatch++;

      // Criar entre 3 e 7 disponibilidades para cada artista (mais diversidade)
      final numAvailabilities = 3 + random.nextInt(5); // 3 a 7 disponibilidades
      
      for (int j = 0; j < numAvailabilities; j++) {
        // Selecionar um endereço real aleatório (reutilizar)
        final selectedAddress = Map<String, dynamic>.from(
          realAddresses[random.nextInt(realAddresses.length)]
        );
        final lat = selectedAddress['latitude'] as double;
        final lon = selectedAddress['longitude'] as double;
        final geohash = geoHasher.encode(lat, lon, precision: 7);
        
        // Adicionar geohash e isPrimary ao endereço
        selectedAddress['geohash'] = geohash;
        selectedAddress['isPrimary'] = j == 0;

        // Gerar datas mais diversas:
        // 30% começam no passado (até 30 dias atrás), 70% começam hoje ou no futuro
        final daysOffset = random.nextDouble() < 0.3 
            ? -random.nextInt(30) // Passado
            : random.nextInt(60); // Futuro (até 60 dias)
        final dataInicio = DateTime.now().add(Duration(days: daysOffset));
        final dataFim = dataInicio.add(Duration(days: random.nextInt(180) + 30));

        // Horários mais diversos: manhã (8-12h), tarde (14-18h), noite (19-23h)
        int horaInicio;
        int horaFim;
        final periodo = random.nextInt(3); // 0=manhã, 1=tarde, 2=noite
        
        if (periodo == 0) {
          // Manhã: 8h às 12h
          horaInicio = 8 + random.nextInt(4);
          horaFim = horaInicio + random.nextInt(3) + 2; // 2-4h depois
        } else if (periodo == 1) {
          // Tarde: 14h às 18h
          horaInicio = 14 + random.nextInt(4);
          horaFim = horaInicio + random.nextInt(3) + 2; // 2-4h depois
        } else {
          // Noite: 19h às 23h
          horaInicio = 19 + random.nextInt(4);
          horaFim = horaInicio + random.nextInt(3) + 1; // 1-3h depois (não passa da meia-noite)
          if (horaFim > 23) horaFim = 23;
        }
        
        final minutoInicio = random.nextDouble() < 0.7 ? 0 : 30; // 70% começam em hora cheia
        final minutoFim = random.nextDouble() < 0.7 ? 0 : 30;

        // Dias da semana mais diversos
        final diasDaSemana = ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU'];
        final numDias = random.nextInt(5) + 1; // 1 a 5 dias
        final diasSelecionados = List.generate(
          numDias,
          (_) => diasDaSemana[random.nextInt(diasDaSemana.length)],
        ).toSet().toList();
        
        // Se só tem 1 dia, garantir que não seja vazio
        if (diasSelecionados.isEmpty) {
          diasSelecionados.add(diasDaSemana[random.nextInt(diasDaSemana.length)]);
        }

        // Criar horários bloqueados para 30-40% das disponibilidades
        List<Map<String, dynamic>> blockedSlots = [];
        if (random.nextDouble() < 0.35) { // 35% têm bloqueios
          final numBlocked = random.nextInt(3) + 1; // 1 a 3 bloqueios
          for (int k = 0; k < numBlocked; k++) {
            // Bloquear uma data aleatória dentro do período da disponibilidade
            final blockedDate = dataInicio.add(Duration(days: random.nextInt(dataFim.difference(dataInicio).inDays)));
            final blockedStartHour = horaInicio + random.nextInt(horaFim - horaInicio);
            final blockedEndHour = blockedStartHour + random.nextInt(2) + 1; // 1-2h bloqueadas
            
            blockedSlots.add({
              'date': blockedDate.toIso8601String().split('T')[0], // Apenas a data (YYYY-MM-DD)
              'startTime': '${blockedStartHour.toString().padLeft(2, '0')}:00',
              'endTime': '${blockedEndHour.toString().padLeft(2, '0')}:00',
              'reason': random.nextDouble() < 0.5 ? 'Show agendado' : 'Indisponível',
            });
          }
        }

        // Criar disponibilidade
        final availabilityData = {
          'dataInicio': dataInicio.toIso8601String(),
          'dataFim': dataFim.toIso8601String(),
          'horarioInicio': '${horaInicio.toString().padLeft(2, '0')}:${minutoInicio.toString().padLeft(2, '0')}',
          'horarioFim': '${horaFim.toString().padLeft(2, '0')}:${minutoFim.toString().padLeft(2, '0')}',
          'diasDaSemana': diasSelecionados,
          'valorShow': random.nextDouble() * 2000 + 200, // 200 a 2200 (mais diversidade)
          'endereco': selectedAddress,
          'raioAtuacao': random.nextDouble() * 80 + 5, // 5 a 85 km
          'repetir': random.nextDouble() < 0.6, // 60% repetem
          'blockedSlots': blockedSlots,
        };

        final availabilityRef = artistRef.collection('Availability').doc('availability_${j.toString().padLeft(2, '0')}');
        await availabilityRef.set(availabilityData);
        availabilitiesInBatch++;
      }
    }

    totalArtists += artistsInBatch;
    totalAvailabilities += availabilitiesInBatch;
    
    print('✅ Batch ${batch + 1}/$totalBatches concluído: $artistsInBatch artistas e $availabilitiesInBatch disponibilidades criadas');
  }

  print('\n🎉 Seed concluído!');
  print('📊 Estatísticas:');
  print('   - Artistas criados: $totalArtists');
  print('   - Disponibilidades criadas: $totalAvailabilities');
  print('   - Total de documentos: ${totalArtists + totalAvailabilities}');
}
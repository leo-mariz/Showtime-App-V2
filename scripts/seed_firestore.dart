// app/scripts/seed_firestore.dart
import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'package:dart_firebase_admin/dart_firebase_admin.dart';
import 'package:dart_firebase_admin/firestore.dart';
import 'package:dart_geohash/dart_geohash.dart';

/// Script para popular o Firestore com dados mockados
/// 
/// Cria 50 artistas e 3 disponibilidades para cada um
/// Todas as disponibilidades são de hoje até 30/01
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

  // Lista de 50 nomes de artistas
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

  // 5 endereços específicos: 2 no Rio (Leblon e Barra) e 3 em São Paulo (Itaim Bibi, Santo Amaro, Morumbi)
  // IMPORTANTE: Usar as chaves corretas que o AddressInfoEntity mapper espera:
  // - zipCode -> cep
  // - street -> logradouro
  // - district -> bairro
  // - city -> localidade
  // - state -> uf
  final realAddresses = [
    // Rio de Janeiro - Leblon
    {
      'title': 'Leblon',
      'logradouro': 'Rua Dias Ferreira',
      'number': '256',
      'bairro': 'Leblon',
      'localidade': 'Rio de Janeiro',
      'uf': 'RJ',
      'cep': '22431-050',
      'latitude': -22.9831,
      'longitude': -43.2235,
    },
    // Rio de Janeiro - Barra da Tijuca
    {
      'title': 'Barra da Tijuca',
      'logradouro': 'Avenida das Américas',
      'number': '3500',
      'bairro': 'Barra da Tijuca',
      'localidade': 'Rio de Janeiro',
      'uf': 'RJ',
      'cep': '22640-102',
      'latitude': -23.0103,
      'longitude': -43.3647,
    },
    // São Paulo - Itaim Bibi
    {
      'title': 'Itaim Bibi',
      'logradouro': 'Rua Bandeira Paulista',
      'number': '456',
      'bairro': 'Itaim Bibi',
      'localidade': 'São Paulo',
      'uf': 'SP',
      'cep': '04532-001',
      'latitude': -23.5925,
      'longitude': -46.6889,
    },
    // São Paulo - Santo Amaro
    {
      'title': 'Santo Amaro',
      'logradouro': 'Avenida Santo Amaro',
      'number': '3500',
      'bairro': 'Santo Amaro',
      'localidade': 'São Paulo',
      'uf': 'SP',
      'cep': '04745-001',
      'latitude': -23.6485,
      'longitude': -46.7083,
    },
    // São Paulo - Morumbi
    {
      'title': 'Morumbi',
      'logradouro': 'Avenida Morumbi',
      'number': '8000',
      'bairro': 'Morumbi',
      'localidade': 'São Paulo',
      'uf': 'SP',
      'cep': '05652-000',
      'latitude': -23.6208,
      'longitude': -46.7216,
    },
  ];

  // Data de término: 30/01/2026
  final dataFim = DateTime(2026, 1, 30);
  final dataInicio = DateTime.now();
  
  print('📝 Criando ${artistNames.length} artistas com 3 disponibilidades cada...');
  print('   - Usando ${realAddresses.length} endereços: 2 no Rio (Leblon, Barra) e 3 em SP (Itaim Bibi, Santo Amaro, Morumbi)');
  print('   - Todas as disponibilidades de ${dataInicio.day}/${dataInicio.month}/${dataInicio.year} até 30/01/2026');
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
        'uid': artistId, // Adicionar uid ao documento
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

      // Criar exatamente 3 disponibilidades para cada artista
      const numAvailabilities = 3;
      
      for (int j = 0; j < numAvailabilities; j++) {
        // Selecionar um endereço real aleatório (reutilizar)
        final selectedAddress = Map<String, dynamic>.from(
          realAddresses[random.nextInt(realAddresses.length)]
        );
        final lat = selectedAddress['latitude'] as double;
        final lon = selectedAddress['longitude'] as double;
        // Usar precisão 5 (~4.9km) para armazenar no banco
        // Para busca com raio de 40km, usar precisão 4 no getRange
        final geohash = geoHasher.encode(lat, lon, precision: 5);
        
        // Adicionar geohash e isPrimary ao endereço
        // IMPORTANTE: Manter as chaves corretas do mapper (cep, logradouro, bairro, localidade, uf)
        selectedAddress['geohash'] = geohash;
        selectedAddress['isPrimary'] = j == 0;

        // Todas as disponibilidades de hoje até 30/01/2026
        // dataInicio: hoje (pode ser hoje ou alguns dias à frente, mas dentro do range)
        // dataFim: 30/01/2026
        final disponibilidadeDataInicio = dataInicio.add(Duration(days: random.nextInt(5))); // Hoje até 5 dias à frente
        final disponibilidadeDataFim = dataFim; // Sempre 30/01/2026

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
            final diasDisponiveis = disponibilidadeDataFim.difference(disponibilidadeDataInicio).inDays;
            if (diasDisponiveis > 0) {
              final blockedDate = disponibilidadeDataInicio.add(Duration(days: random.nextInt(diasDisponiveis)));
              // Garantir que temos espaço para o bloqueio dentro do horário disponível
              if (horaFim > horaInicio) {
                final blockedStartHour = horaInicio + random.nextInt(horaFim - horaInicio);
                // Garantir que o bloqueio não ultrapassa o horário fim nem a meia-noite
                final maxBlockedEndHour = horaFim < 23 ? horaFim : 23;
                final blockedEndHour = blockedStartHour + random.nextInt(maxBlockedEndHour - blockedStartHour) + 1;
                if (blockedEndHour <= maxBlockedEndHour && blockedEndHour > blockedStartHour) {
              
                  blockedSlots.add({
                    'date': blockedDate.toIso8601String().split('T')[0], // Apenas a data (YYYY-MM-DD)
                    'startTime': '${blockedStartHour.toString().padLeft(2, '0')}:00',
                    'endTime': '${blockedEndHour.toString().padLeft(2, '0')}:00',
                    'reason': random.nextDouble() < 0.5 ? 'Show agendado' : 'Indisponível',
                  });
                }
              }
            }
          }
        }

        // Criar disponibilidade
        final availabilityData = {
          'dataInicio': disponibilidadeDataInicio.toIso8601String(),
          'dataFim': disponibilidadeDataFim.toIso8601String(),
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
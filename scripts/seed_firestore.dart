// app/scripts/seed_firestore.dart
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:app/firebase_options.dart';
import 'package:app/core/utils/geohash_helper.dart';

/// Script para popular o Firestore com dados mockados
/// 
/// Cria 100 artistas e 5 disponibilidades para cada um
/// 
/// Executar com: dart run scripts/seed_firestore.dart
Future<void> main() async {
  print('🔥 Inicializando Firebase...');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firestore = FirebaseFirestore.instance;
  final random = Random();

  // Lista de nomes de artistas mockados
  final artistNames = List.generate(100, (i) => 'Artista ${i + 1}');
  
  // Gêneros disponíveis
  final genres = [
    'Rock', 'Pop', 'Sertanejo', 'MPB', 'Funk', 'Rap', 'Jazz', 
    'Blues', 'Eletrônica', 'Samba', 'Pagode', 'Forró', 'Gospel'
  ];

  // Especialidades
  final specialties = [
    'Cantor', 'Banda', 'DJ', 'Instrumentista', 'Compositor', 
    'Produtor Musical', 'Músico Solo'
  ];

  // Coordenadas de São Paulo (centro) para gerar endereços próximos
  const baseLat = -23.5505;
  const baseLon = -46.6333;

  print('📝 Criando 100 artistas com 5 disponibilidades cada...');

  // Processar em batches para não sobrecarregar
  const batchSize = 10;
  int totalArtists = 0;
  int totalAvailabilities = 0;

  for (int batch = 0; batch < 10; batch++) {
    final batchWrite = firestore.batch();
    int batchCount = 0;

    for (int i = 0; i < batchSize; i++) {
      final artistIndex = batch * batchSize + i;
      if (artistIndex >= 100) break;

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
        'dateRegistered': Timestamp.now(),
        'rating': random.nextDouble() * 5, // 0 a 5
        'finalizedContracts': random.nextInt(100),
        'hasIncompleteSections': false,
        'isOnAnyGroup': false,
        'professionalInfo': professionalInfo, // Objeto aninhado, não subcoleção
      };

      // Criar documento do artista
      final artistRef = firestore.collection('Artists').doc(artistId);
      batchWrite.set(artistRef, artistData);

      // Criar 5 disponibilidades para cada artista
      for (int j = 0; j < 5; j++) {
        // Gerar coordenadas aleatórias próximas a São Paulo (±0.5 graus)
        final lat = baseLat + (random.nextDouble() - 0.5) * 1.0;
        final lon = baseLon + (random.nextDouble() - 0.5) * 1.0;
        final geohash = GeohashHelper.encode(lat, lon);

        // Gerar datas: início hoje, fim em até 6 meses
        final dataInicio = DateTime.now();
        final dataFim = dataInicio.add(Duration(days: random.nextInt(180) + 30));

        // Horários aleatórios entre 14h e 23h
        final horaInicio = 14 + random.nextInt(6); // 14-19h
        final minutoInicio = random.nextBool() ? 0 : 30;
        final horaFim = horaInicio + random.nextInt(4) + 2; // 2-5h depois
        final minutoFim = random.nextBool() ? 0 : 30;

        // Dias da semana aleatórios
        final diasDaSemana = ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU'];
        final diasSelecionados = List.generate(
          random.nextInt(4) + 2, // 2 a 5 dias
          (_) => diasDaSemana[random.nextInt(diasDaSemana.length)],
        ).toSet().toList();

        // Criar endereço mockado
        final endereco = {
          'title': 'Endereço ${j + 1}',
          'zipCode': '${random.nextInt(90000) + 10000}-${random.nextInt(900) + 100}',
          'street': 'Rua ${artistName} ${j + 1}',
          'number': '${random.nextInt(9999) + 1}',
          'district': 'Bairro ${j + 1}',
          'city': 'São Paulo',
          'state': 'SP',
          'latitude': lat,
          'longitude': lon,
          'geohash': geohash,
          'isPrimary': j == 0,
        };

        // Criar disponibilidade
        final availabilityData = {
          'dataInicio': Timestamp.fromDate(dataInicio),
          'dataFim': Timestamp.fromDate(dataFim),
          'horarioInicio': '${horaInicio.toString().padLeft(2, '0')}:${minutoInicio.toString().padLeft(2, '0')}',
          'horarioFim': '${horaFim.toString().padLeft(2, '0')}:${minutoFim.toString().padLeft(2, '0')}',
          'diasDaSemana': diasSelecionados,
          'valorShow': random.nextDouble() * 500 + 100, // 100 a 600
          'endereco': endereco,
          'raioAtuacao': random.nextDouble() * 50 + 10, // 10 a 60 km
          'repetir': random.nextBool(),
          'blockedSlots': [], // Sem bloqueios por padrão
        };

        final availabilityRef = artistRef
            .collection('Availability')
            .doc('availability_${j.toString().padLeft(2, '0')}');
        batchWrite.set(availabilityRef, availabilityData);
        batchCount++;
      }

      batchCount++;
    }

    // Executar batch
    await batchWrite.commit();
    totalArtists += batchCount;
    totalAvailabilities += batchCount * 5;
    
    print('✅ Batch ${batch + 1}/10 concluído: ${batchCount} artistas criados');
  }

  print('\n🎉 Seed concluído!');
  print('📊 Estatísticas:');
  print('   - Artistas criados: $totalArtists');
  print('   - Disponibilidades criadas: $totalAvailabilities');
  print('   - Total de documentos: ${totalArtists + totalAvailabilities}');
}


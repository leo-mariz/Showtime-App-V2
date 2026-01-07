import 'package:app/core/domain/artist/artist_individual/artist_entity.dart';
import 'package:app/core/domain/artist/availability_calendar_entitys/availability_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/exceptions.dart';
import 'package:app/features/explore/domain/entities/artist_with_availabilities_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Interface do DataSource remoto (Firestore) para Explore
/// Responsável APENAS por operações de busca no Firestore para explorar
/// 
/// REGRAS:
/// - Lança exceções tipadas (ServerException, NetworkException, etc)
/// - NÃO faz validações de negócio
/// - NÃO faz verificações de lógica
/// - Focado em queries otimizadas para explorar artistas
/// - Feature completamente independente (não reutiliza outras features)
abstract class IExploreRemoteDataSource {
  /// Busca todos os artistas aprovados e ativos
  /// Usado para explorar (não para perfil)
  /// Retorna lista vazia se não existir nenhum
  /// Lança [ServerException] em caso de erro
  Future<List<ArtistEntity>> getActiveApprovedArtists();
  
  /// Busca disponibilidades de um artista específico
  /// Usado para explorar (não para perfil)
  /// Retorna lista vazia se não existir nenhuma
  /// Lança [ServerException] em caso de erro
  /// Lança [ValidationException] se artistId estiver vazio
  Future<List<AvailabilityEntity>> getArtistAvailabilities(String artistId);
  
  /// Busca disponibilidades de um artista com filtros otimizados
  /// Usado para explorar com filtros de data e geohash
  /// 
  /// [artistId]: ID do artista
  /// [selectedDate]: Data selecionada para filtrar (opcional)
  /// [minGeohash]: Geohash mínimo para filtro geográfico (opcional)
  /// [maxGeohash]: Geohash máximo para filtro geográfico (opcional)
  /// 
  /// Retorna lista vazia se não existir nenhuma disponibilidade que atenda aos filtros
  /// Lança [ServerException] em caso de erro
  /// Lança [ValidationException] se artistId estiver vazio
  Future<List<AvailabilityEntity>> getArtistAvailabilitiesFiltered(
    String artistId, {
    DateTime? selectedDate,
    String? minGeohash,
    String? maxGeohash,
  });
}

/// Implementação do DataSource remoto usando Firestore
class ExploreRemoteDataSourceImpl implements IExploreRemoteDataSource {
  final FirebaseFirestore firestore;

  // ==================== FIRESTORE FIELD KEYS (Constantes) ====================
  /// Chave do campo 'approved' no documento do artista
  static const String _firestoreFieldApproved = 'approved';
  
  /// Chave do campo 'isActive' no documento do artista
  static const String _firestoreFieldIsActive = 'isActive';
  
  /// Chave do campo 'dataInicio' no documento de disponibilidade
  static const String _firestoreFieldDataInicio = 'dataInicio';
  
  /// Chave do campo 'dataFim' no documento de disponibilidade
  static const String _firestoreFieldDataFim = 'dataFim';
  
  /// Chave do campo 'endereco.geohash' no documento de disponibilidade (campo aninhado)
  static const String _firestoreFieldEnderecoGeohash = 'endereco.geohash';

  ExploreRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<ArtistEntity>> getActiveApprovedArtists() async {
    try {
      final artistsCollectionRef = ArtistWithAvailabilitiesEntityReference
          .artistsCollectionReference(firestore);

      // Query otimizada para explorar: apenas artistas aprovados e ativos
      final querySnapshot = await artistsCollectionRef
          .where(_firestoreFieldApproved, isEqualTo: true)
          .where(_firestoreFieldIsActive, isEqualTo: true)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return [];
      }

      return querySnapshot.docs.map((doc) {
        final artistMap = doc.data() as Map<String, dynamic>;
        final artist = ArtistEntityMapper.fromMap(artistMap);
        return artist.copyWith(uid: doc.id);
      }).toList();
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao buscar artistas aprovados e ativos no Firestore: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw ServerException(
        'Erro inesperado ao buscar artistas para explorar',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<AvailabilityEntity>> getArtistAvailabilities(String artistId) async {
    try {
      if (artistId.isEmpty) {
        throw const ValidationException(
          'ID do artista não pode ser vazio',
        );
      }

      final collectionReference = ArtistWithAvailabilitiesEntityReference
          .artistAvailabilitiesCollectionReference(firestore, artistId);
      
      final querySnapshot = await collectionReference.get();
      
      if (querySnapshot.docs.isEmpty) {
        return [];
      }

      return querySnapshot.docs
          .map((doc) {
            final availabilityMap = doc.data() as Map<String, dynamic>;
            final availability = AvailabilityEntityMapper.fromMap(availabilityMap);
            return availability.copyWith(id: doc.id);
          })
          .toList();
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao buscar disponibilidades no Firestore: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      if (e is ValidationException) rethrow;
      
      throw ServerException(
        'Erro inesperado ao buscar disponibilidades para explorar',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<AvailabilityEntity>> getArtistAvailabilitiesFiltered(
    String artistId, {
    DateTime? selectedDate,
    String? minGeohash,
    String? maxGeohash,
  }) async {
    try {
      if (artistId.isEmpty) {
        throw const ValidationException(
          'ID do artista não pode ser vazio',
        );
      }

      print('🔷 [REMOTE_DS] getArtistAvailabilitiesFiltered - Iniciando query');
      print('🔷 [REMOTE_DS] Parâmetros recebidos:');
      print('   - artistId: $artistId');
      print('   - selectedDate: $selectedDate');
      print('   - minGeohash: $minGeohash');
      print('   - maxGeohash: $maxGeohash');

      final collectionReference = ArtistWithAvailabilitiesEntityReference
          .artistAvailabilitiesCollectionReference(firestore, artistId);
      
      // DEBUG: Verificar total de documentos na coleção (sem filtros)
      final allDocsSnapshot = await collectionReference.limit(5).get();
      print('🔷 [REMOTE_DS] Total de documentos na coleção (amostra de 5): ${allDocsSnapshot.docs.length}');
      if (allDocsSnapshot.docs.isNotEmpty) {
        final sampleDoc = allDocsSnapshot.docs.first;
        final sampleData = sampleDoc.data() as Map<String, dynamic>;
        print('🔷 [REMOTE_DS] Exemplo de documento (ID: ${sampleDoc.id}):');
        print('   - dataInicio: ${sampleData[_firestoreFieldDataInicio]} (tipo: ${sampleData[_firestoreFieldDataInicio].runtimeType})');
        print('   - dataFim: ${sampleData[_firestoreFieldDataFim]} (tipo: ${sampleData[_firestoreFieldDataFim].runtimeType})');
        if (sampleData['endereco'] is Map) {
          print('   - endereco.geohash: ${(sampleData['endereco'] as Map)['geohash']}');
        }
      }
      
      // Construir query com filtros
      Query query = collectionReference;
      
      // Filtro 1: Por data (se fornecido)
      // NOTA: As datas estão sendo salvas como String no Firestore, não como Timestamp
      // Por isso, não podemos usar filtros de data diretamente na query do Firestore
      // A filtragem por data será feita no cliente após buscar os documentos
      // Por enquanto, vamos buscar todas as disponibilidades e filtrar no cliente
      if (selectedDate != null) {
        print('🔷 [REMOTE_DS] Data selecionada: $selectedDate');
        print('🔷 [REMOTE_DS] NOTA: Datas estão como String no Firestore, filtro será aplicado no cliente');
        // Não adicionar filtros de data aqui - será filtrado no cliente
      }
      
      // Filtro 2: Por Geohash (se fornecido)
      if (minGeohash != null && 
          minGeohash.isNotEmpty && 
          maxGeohash != null && 
          maxGeohash.isNotEmpty) {
        print('🔷 [REMOTE_DS] Adicionando filtros de geohash:');
        print('   - endereco.geohash >= $minGeohash');
        print('   - endereco.geohash <= $maxGeohash');
        
        query = query
          .where(
            _firestoreFieldEnderecoGeohash,
            isGreaterThanOrEqualTo: minGeohash,
          )
          .where(
            _firestoreFieldEnderecoGeohash,
            isLessThanOrEqualTo: maxGeohash,
          );
      }
      
      print('🔷 [REMOTE_DS] Executando query no Firestore...');
      final querySnapshot = await query.get();
      print('🔷 [REMOTE_DS] Query executada! Total de documentos encontrados: ${querySnapshot.docs.length}');
      
      if (querySnapshot.docs.isEmpty) {
        print('🔷 [REMOTE_DS] Nenhum documento encontrado - retornando lista vazia');
        return [];
      }

      print('🔷 [REMOTE_DS] Processando ${querySnapshot.docs.length} documentos...');
      final availabilities = <AvailabilityEntity>[];
      
      for (final doc in querySnapshot.docs) {
        try {
          final availabilityMap = doc.data() as Map<String, dynamic>;
          print('🔷 [REMOTE_DS] Processando documento ${doc.id}');
          
          // Converter datas para DateTime (o mapper espera DateTime, não Timestamp ou String)
          // O Firestore pode retornar datas como String ISO ou Timestamp
          final dataInicioRaw = availabilityMap[_firestoreFieldDataInicio];
          final dataFimRaw = availabilityMap[_firestoreFieldDataFim];
          
          // Converter para DateTime
          DateTime? dataInicioDateTime;
          if (dataInicioRaw is String) {
            print('   - Convertendo dataInicio de String para DateTime: $dataInicioRaw');
            dataInicioDateTime = DateTime.parse(dataInicioRaw);
          } else if (dataInicioRaw is Timestamp) {
            print('   - Convertendo dataInicio de Timestamp para DateTime: ${dataInicioRaw.toDate()}');
            dataInicioDateTime = dataInicioRaw.toDate();
          }
          
          DateTime? dataFimDateTime;
          if (dataFimRaw is String) {
            print('   - Convertendo dataFim de String para DateTime: $dataFimRaw');
            dataFimDateTime = DateTime.parse(dataFimRaw);
          } else if (dataFimRaw is Timestamp) {
            print('   - Convertendo dataFim de Timestamp para DateTime: ${dataFimRaw.toDate()}');
            dataFimDateTime = dataFimRaw.toDate();
          }
          
          // Atualizar o mapa com DateTime
          if (dataInicioDateTime != null) {
            availabilityMap[_firestoreFieldDataInicio] = dataInicioDateTime;
          }
          if (dataFimDateTime != null) {
            availabilityMap[_firestoreFieldDataFim] = dataFimDateTime;
          }
          
          final enderecoRaw = availabilityMap['endereco'];
          if (enderecoRaw is Map) {
            print('   - endereco.geohash: ${enderecoRaw['geohash']}');
          }
          
          print('   - Tentando converter para AvailabilityEntity...');
          final availability = AvailabilityEntityMapper.fromMap(availabilityMap);
          print('   - ✅ AvailabilityEntity criada com sucesso!');
          availabilities.add(availability.copyWith(id: doc.id));
        } catch (e, stackTrace) {
          print('   - 🔴 ERRO ao processar documento ${doc.id}: $e');
          print('   - StackTrace: $stackTrace');
          // Continuar processando outros documentos mesmo se um falhar
        }
      }
      
      print('🔷 [REMOTE_DS] Retornando ${availabilities.length} disponibilidades');
      return availabilities;
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao buscar disponibilidades filtradas no Firestore: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      if (e is ValidationException) rethrow;
      
      print('🔴 [REMOTE_DS] Erro capturado: $e');
      print('🔴 [REMOTE_DS] StackTrace: $stackTrace');
      
      throw ServerException(
        'Erro inesperado ao buscar disponibilidades filtradas para explorar: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}


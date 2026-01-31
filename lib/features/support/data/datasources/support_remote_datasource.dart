import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/exceptions.dart';
import 'package:app/features/support/domain/entities/support_request_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Chaves do documento no Firestore (coleção SupportRequests).
abstract class SupportRequestKeys {
  static const String userId = 'userId';
  static const String name = 'name';
  static const String userEmail = 'userEmail';
  static const String subject = 'subject';
  static const String message = 'message';
  static const String protocolNumber = 'protocolNumber';
  static const String createdAt = 'createdAt';
  static const String status = 'status';
  static const String contractId = 'contractId';
}

/// Interface do DataSource remoto para solicitações de atendimento.
/// Persiste no Firestore (coleção SupportRequests).
abstract class ISupportRemoteDataSource {
  /// Salva a solicitação e retorna a entidade com id e protocolNumber.
  Future<SupportRequestEntity> save(SupportRequestEntity request);
}

/// Implementação usando Firestore.
/// Coleção: SupportRequests (documentos com id auto-gerado).
class SupportRemoteDataSourceImpl implements ISupportRemoteDataSource {
  final FirebaseFirestore firestore;

  static const String _collection = 'SupportRequests';

  SupportRemoteDataSourceImpl({required this.firestore});

  @override
  Future<SupportRequestEntity> save(SupportRequestEntity request) async {
    try {
      final ref = firestore.collection(_collection);
      final now = DateTime.now();
      final protocolNumber = now.millisecondsSinceEpoch.toString().substring(5);
      final data = request.toMap()
        ..remove('id')
        ..[SupportRequestKeys.createdAt] = now
        ..[SupportRequestKeys.protocolNumber] = protocolNumber
        ..[SupportRequestKeys.status] = request.status ?? 'pending';

      final docRef = await ref.add(data);
      final snapshot = await docRef.get();
      final raw = snapshot.data();
      if (raw == null) {
        throw const ServerException('Solicitação criada mas dados não encontrados');
      }
      final rawMap = raw;
      final createdAtValue = rawMap[SupportRequestKeys.createdAt];
      final DateTime? createdAt = createdAtValue is Timestamp
          ? createdAtValue.toDate()
          : (createdAtValue is DateTime ? createdAtValue : now);
      final map = <String, dynamic>{
        'id': docRef.id,
        'userId': rawMap[SupportRequestKeys.userId],
        'name': rawMap[SupportRequestKeys.name],
        'userEmail': rawMap[SupportRequestKeys.userEmail],
        'subject': rawMap[SupportRequestKeys.subject],
        'message': rawMap[SupportRequestKeys.message],
        'protocolNumber': protocolNumber,
        'createdAt': createdAt,
        'status': rawMap[SupportRequestKeys.status],
        if (rawMap[SupportRequestKeys.contractId] != null)
          SupportRequestKeys.contractId: rawMap[SupportRequestKeys.contractId],
      };
      return SupportRequestEntityMapper.fromMap(map);
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao registrar solicitação: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}

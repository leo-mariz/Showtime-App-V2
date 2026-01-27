import 'package:equatable/equatable.dart';

/// DTO para criação de chat
/// 
/// Agrupa todos os dados necessários para criar um chat
/// Facilita validação e manutenção
class CreateChatInputDto extends Equatable {
  final String contractId;
  final String clientId;
  final String artistId;
  final String clientName;
  final String artistName;
  final String? clientPhoto;
  final String? artistPhoto;

  const CreateChatInputDto({
    required this.contractId,
    required this.clientId,
    required this.artistId,
    required this.clientName,
    required this.artistName,
    this.clientPhoto,
    this.artistPhoto,
  });

  @override
  List<Object?> get props => [
        contractId,
        clientId,
        artistId,
        clientName,
        artistName,
        clientPhoto,
        artistPhoto,
      ];

  /// Cria cópia com valores atualizados
  CreateChatInputDto copyWith({
    String? contractId,
    String? clientId,
    String? artistId,
    String? clientName,
    String? artistName,
    String? clientPhoto,
    String? artistPhoto,
  }) {
    return CreateChatInputDto(
      contractId: contractId ?? this.contractId,
      clientId: clientId ?? this.clientId,
      artistId: artistId ?? this.artistId,
      clientName: clientName ?? this.clientName,
      artistName: artistName ?? this.artistName,
      clientPhoto: clientPhoto ?? this.clientPhoto,
      artistPhoto: artistPhoto ?? this.artistPhoto,
    );
  }
}

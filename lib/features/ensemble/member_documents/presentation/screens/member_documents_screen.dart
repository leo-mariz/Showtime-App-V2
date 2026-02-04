import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/domain/artist/artist_individual/documents/documents_entity.dart';
import 'package:app/core/domain/ensemble/member_documents/member_document_entity.dart';
import 'package:app/core/enums/document_type_enum.dart';
import 'package:app/core/shared/extensions/context_notification_extension.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/core/shared/widgets/circular_progress_indicator.dart';
import 'package:app/features/artists/artist_documents/presentation/widgets/document_card.dart';
import 'package:app/features/artists/artist_documents/presentation/widgets/document_modals.dart';
import 'package:app/features/ensemble/ensemble/presentation/bloc/ensemble_bloc.dart';
import 'package:app/features/ensemble/ensemble/presentation/bloc/events/ensemble_events.dart';
import 'package:app/features/ensemble/member_documents/presentation/bloc/events/member_documents_events.dart';
import 'package:app/features/ensemble/member_documents/presentation/bloc/member_documents_bloc.dart';
import 'package:app/features/ensemble/member_documents/presentation/bloc/states/member_documents_states.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage(deferredLoading: true)
class MemberDocumentsScreen extends StatefulWidget {
  final String ensembleId;
  final String memberId;

  const MemberDocumentsScreen({
    super.key,
    required this.ensembleId,
    required this.memberId,
  });

  @override
  State<MemberDocumentsScreen> createState() => _MemberDocumentsScreenState();
}

class _MemberDocumentsScreenState extends State<MemberDocumentsScreen> {
  Map<DocumentTypeEnum, DocumentsEntity> _documentsMap = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getDocuments();
    });
  }

  void _getDocuments() {
    context.read<MemberDocumentsBloc>().add(
          GetAllMemberDocumentsEvent(
            ensembleId: widget.ensembleId,
            memberId: widget.memberId,
          ),
        );
  }

  DocumentsEntity _getDocumentByType(DocumentTypeEnum type) {
    return _documentsMap[type] ??
        DocumentsEntity(
          documentType: type.name,
          documentOption: '',
          url: '',
          status: 0,
        );
  }

  static String _toMemberDocumentType(String documentType) {
    if (documentType == DocumentTypeEnum.identity.name) return MemberDocumentType.identity;
    if (documentType == DocumentTypeEnum.antecedents.name) return MemberDocumentType.antecedents;
    return documentType.toLowerCase();
  }

  void _handleSaveDocument(DocumentsEntity document, String? localFilePath) {
    final memberDoc = MemberDocumentEntity(
      artistId: '',
      ensembleId: widget.ensembleId,
      memberId: widget.memberId,
      documentType: _toMemberDocumentType(document.documentType),
      status: document.status,
      url: document.url,
    );
    context.read<MemberDocumentsBloc>().add(
          SaveMemberDocumentEvent(
            document: memberDoc,
            localFilePath: localFilePath,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocListener<MemberDocumentsBloc, MemberDocumentsState>(
      listener: (context, state) {
        if (state is GetAllMemberDocumentsSuccess) {
          setState(() {
            _documentsMap = {
              for (var doc in state.documents)
                (doc.documentType == MemberDocumentType.identity
                    ? DocumentTypeEnum.identity
                    : DocumentTypeEnum.antecedents): DocumentsEntity(
                  documentType: doc.documentType == MemberDocumentType.identity
                      ? DocumentTypeEnum.identity.name
                      : DocumentTypeEnum.antecedents.name,
                  documentOption: '',
                  url: doc.url ?? '',
                  status: doc.status,
                )
            };
          });
        } else if (state is GetAllMemberDocumentsFailure) {
          context.showError(state.error);
        } else if (state is SaveMemberDocumentSuccess) {
          context.showSuccess('Documento salvo com sucesso!');
          _getDocuments();
          // Atualiza o ensemble no bloc (sync já atualizou cache) para a UI refletir incompleteSections.
          if (mounted) {
            context.read<EnsembleBloc>().add(
              GetEnsembleByIdEvent(ensembleId: widget.ensembleId, forceRefresh: true),
            );
          }
        } else if (state is SaveMemberDocumentFailure) {
          context.showError(state.error);
        }
      },
      child: BlocBuilder<MemberDocumentsBloc, MemberDocumentsState>(
        builder: (context, state) {
          final isLoading = state is GetAllMemberDocumentsLoading ||
              state is SaveMemberDocumentLoading;

          return BasePage(
            showAppBar: true,
            appBarTitle: 'Documentos',
            showAppBarBackButton: true,
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              behavior: HitTestBehavior.opaque,
              child: isLoading
                  ? const Center(child: CustomLoadingIndicator())
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Envie seus documentos para verificação da conta.',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          DSSizedBoxSpacing.vertical(24),
                          DocumentCard(
                            title: 'Identidade',
                            document: _getDocumentByType(DocumentTypeEnum.identity),
                            onTap: () => _showIdentityModal(),
                          ),
                          DSSizedBoxSpacing.vertical(8),
                          DocumentCard(
                            title: 'Certidão de Antecedentes',
                            document: _getDocumentByType(DocumentTypeEnum.antecedents),
                            onTap: () => _showAntecedentsModal(),
                          ),
                          DSSizedBoxSpacing.vertical(24),
                        ],
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }

  void _showIdentityModal() {
    final document = _getDocumentByType(DocumentTypeEnum.identity);
    DocumentModals.showIdentityModal(
      context: context,
      document: document,
      onSave: (updatedDocument, localFilePath) {
        _handleSaveDocument(updatedDocument, localFilePath);
      },
    );
  }

  void _showAntecedentsModal() {
    final document = _getDocumentByType(DocumentTypeEnum.antecedents);
    DocumentModals.showAntecedentsModal(
      context: context,
      document: document,
      onSave: (updatedDocument, localFilePath) {
        _handleSaveDocument(updatedDocument, localFilePath);
      },
    );
  }
}

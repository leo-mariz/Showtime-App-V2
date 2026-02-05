import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/domain/artist/artist_individual/documents/documents_entity.dart';
import 'package:app/core/enums/document_type_enum.dart';
import 'package:app/core/shared/extensions/context_notification_extension.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/core/shared/widgets/circular_progress_indicator.dart';
import 'package:app/features/artists/artist_documents/presentation/bloc/documents_bloc.dart';
import 'package:app/features/artists/artist_documents/presentation/bloc/events/documents_events.dart';
import 'package:app/features/artists/artist_documents/presentation/bloc/states/documents_states.dart';
import 'package:app/features/artists/artist_documents/presentation/widgets/document_card.dart';
import 'package:app/features/artists/artist_documents/presentation/widgets/document_modals.dart';
import 'package:app/features/artists/artists/presentation/bloc/artists_bloc.dart';
import 'package:app/features/artists/artists/presentation/bloc/events/artists_events.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage(deferredLoading: true)
class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  // Map para armazenar documentos por tipo
  Map<DocumentTypeEnum, DocumentsEntity> _documentsMap = {};

  @override
  void initState() {
    super.initState();
    // Buscar documentos ao inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getDocuments();
    });
  }

  _getDocuments() {
    final documentsBloc = context.read<DocumentsBloc>();
    documentsBloc.add(GetDocumentsEvent());
  }

  DocumentsEntity _getDocumentByType(DocumentTypeEnum type) {
    final document = _documentsMap[type] ??
        DocumentsEntity(
          documentType: type.name,
          documentOption: '',
          url: '',
          status: 0,
        );
    return document;
  }

  /// Dispara o envio e aguarda o resultado. Retorna true em sucesso, false em falha.
  Future<bool> _handleSaveDocument(DocumentsEntity document, String? localFilePath) async {
    final bloc = context.read<DocumentsBloc>();
    bloc.add(SetDocumentEvent(
      document: document,
      localFilePath: localFilePath,
    ));
    final result = await bloc.stream
        .where((s) => s is SetDocumentSuccess || s is SetDocumentFailure)
        .first;
    return result is SetDocumentSuccess;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocListener<DocumentsBloc, DocumentsState>(
      listener: (context, state) {
        if (state is GetDocumentsSuccess) {
          // Atualizar map com documentos recebidos
          setState(() {
            _documentsMap = {
              for (var doc in state.documents)
                DocumentTypeEnum.values.firstWhere(
                  (e) => e.name == doc.documentType,
                  orElse: () => DocumentTypeEnum.identity,
                ): doc
            };
          });
        } else if (state is GetDocumentsFailure) {
          context.showError(state.error);
        } else if (state is SetDocumentSuccess) {
          context.showSuccess('Documento salvo com sucesso!');
          // Buscar documentos atualizados após salvar
          context.read<DocumentsBloc>().add(GetDocumentsEvent());
          // Atualiza o artista no bloc para a UI refletir incompleteSections (Firestore já atualizou).
          if (mounted) {
            context.read<ArtistsBloc>().add(GetArtistEvent());
          }
        } else if (state is SetDocumentFailure) {
          context.showError(state.error);
        }
      },
      child: BlocBuilder<DocumentsBloc, DocumentsState>(
        builder: (context, state) {
          final isLoading = state is GetDocumentsLoading;

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
                        
                        // Identidade
                        DocumentCard(
                          title: 'Identidade',
                          document: _getDocumentByType(DocumentTypeEnum.identity),
                          onTap: () => _showIdentityModal(),
                        ),
                        DSSizedBoxSpacing.vertical(8),
                        
                        // Comprovante de Residência
                        DocumentCard(
                          title: 'Comprovante de Residência',
                          document: _getDocumentByType(DocumentTypeEnum.residence),
                          onTap: () => _showResidenceModal(),
                        ),
                        DSSizedBoxSpacing.vertical(8),
                        
                        // Currículo
                        DocumentCard(
                          title: 'Currículo',
                          document: _getDocumentByType(DocumentTypeEnum.curriculum),
                          onTap: () => _showCurriculumModal(),
                        ),
                        DSSizedBoxSpacing.vertical(8),
                        
                        // Certidão de Antecedentes
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
      onSave: _handleSaveDocument,
    );
  }

  void _showResidenceModal() {
    final document = _getDocumentByType(DocumentTypeEnum.residence);
    DocumentModals.showResidenceModal(
      context: context,
      document: document,
      onSave: _handleSaveDocument,
    );
  }

  void _showCurriculumModal() {
    final document = _getDocumentByType(DocumentTypeEnum.curriculum);
    DocumentModals.showCurriculumModal(
      context: context,
      document: document,
      onSave: _handleSaveDocument,
    );
  }

  void _showAntecedentsModal() {
    final document = _getDocumentByType(DocumentTypeEnum.antecedents);
    DocumentModals.showAntecedentsModal(
      context: context,
      document: document,
      onSave: _handleSaveDocument,
    );
  }
}

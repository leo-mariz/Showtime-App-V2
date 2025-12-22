import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/domain/artist/artist_individual/documents/documents_entity.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/features/profile/presentation/widgets/documents/document_card.dart';
import 'package:app/features/profile/presentation/widgets/documents/document_modals.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage(deferredLoading: true)
class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  // TODO: Substituir por dados reais do artista (Bloc/Repository)
  DocumentsEntity identityDocument = DocumentsEntity(
    documentType: 'Identity',
    documentOption: '',
    url: '',
    status: 0,
  );
  DocumentsEntity residenceDocument = DocumentsEntity(
    documentType: 'Residence',
    documentOption: '',
    url: '',
    status: 0,
  );
  DocumentsEntity curriculumDocument = DocumentsEntity(
    documentType: 'Curriculum',
    documentOption: '',
    url: '',
    status: 0,
  );
  DocumentsEntity antecedentsDocument = DocumentsEntity(
    documentType: 'Antecedents',
    documentOption: '',
    url: '',
    status: 0,
  );

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BasePage(
      showAppBar: true,
      appBarTitle: 'Documentos',
      showAppBarBackButton: true,
      child: SingleChildScrollView(
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
              document: identityDocument,
              onTap: () => _showIdentityModal(),
            ),
            DSSizedBoxSpacing.vertical(8),
            
            // Comprovante de Residência
            DocumentCard(
              title: 'Comprovante de Residência',
              document: residenceDocument,
              onTap: () => _showResidenceModal(),
            ),
            DSSizedBoxSpacing.vertical(8),
            
            // Currículo
            DocumentCard(
              title: 'Currículo',
              document: curriculumDocument,
              onTap: () => _showCurriculumModal(),
            ),
            DSSizedBoxSpacing.vertical(8),
            
            // Certidão de Antecedentes
            DocumentCard(
              title: 'Certidão de Antecedentes',
              document: antecedentsDocument,
              onTap: () => _showAntecedentsModal(),
            ),
            DSSizedBoxSpacing.vertical(24),
          ],
        ),
      ),
    );
  }

  void _showIdentityModal() {
    DocumentModals.showIdentityModal(
      context: context,
      document: identityDocument,
      onSave: (document) {
        setState(() {
          identityDocument = document;
        });
      },
    );
  }

  void _showResidenceModal() {
    DocumentModals.showResidenceModal(
      context: context,
      document: residenceDocument,
      onSave: (document) {
        setState(() {
          residenceDocument = document;
        });
      },
    );
  }

  void _showCurriculumModal() {
    DocumentModals.showCurriculumModal(
      context: context,
      document: curriculumDocument,
      onSave: (document) {
        setState(() {
          curriculumDocument = document;
        });
      },
    );
  }

  void _showAntecedentsModal() {
    DocumentModals.showAntecedentsModal(
      context: context,
      document: antecedentsDocument,
      onSave: (document) {
        setState(() {
          antecedentsDocument = document;
        });
      },
    );
  }
}


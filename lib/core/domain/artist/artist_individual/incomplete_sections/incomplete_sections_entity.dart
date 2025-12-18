import 'package:app/core/domain/addresses/address_info_entity.dart';
import 'package:app/core/domain/artist/artist_individual/artist_entity.dart';
import 'package:app/core/domain/artist/artist_individual/documents/documents_entity.dart';
import 'package:app/core/domain/artist/bank_account_entity/bank_account_entity.dart';
import 'package:app/core/domain/artist/professional_info_entity/professional_info_entity.dart';
import 'package:dart_mappable/dart_mappable.dart';
part 'incomplete_sections_entity.mapper.dart';

@MappableClass()
class UserIncompleteSectionsEntity with UserIncompleteSectionsEntityMappable{
  bool hasIncompleteSections;
  bool incompleteRegisterData;
  bool incompleteArtistArea;
  bool incompleteProfessionalInfo;
  bool incompleteBankAccount;
  bool incompleteDocuments;
  bool incompletePresentationMedias;
  bool incompleteProfilePicture;
  bool incompleteMainAddress;

  UserIncompleteSectionsEntity._({
    required this.hasIncompleteSections,
    required this.incompleteRegisterData,
    required this.incompleteArtistArea,
    required this.incompleteProfessionalInfo,
    required this.incompleteBankAccount,
    required this.incompleteDocuments,
    required this.incompletePresentationMedias,
    required this.incompleteProfilePicture,
    this.incompleteMainAddress = false,
  });

  factory UserIncompleteSectionsEntity.verify({
    required ArtistEntity artist,
    required List<DocumentsEntity>? documents,
    List<AddressInfoEntity>? mainAddress,
  }) {
    // Verifica dados de registro
    final bool incompleteMainAddress = _verifyMainAddress(mainAddress);
    final bool incompleteDocuments = _verifyDocuments(documents);
    final bool incompleteBankAccount = _verifyBankAccount(artist.bankAccount);
    final bool incompleteProfilePicture = artist.profilePicture?.isEmpty ?? true;

    final bool incompleteRegister = incompleteDocuments || 
                                   incompleteBankAccount || 
                                   incompleteProfilePicture;

    // Verifica área do artista
    final bool incompleteProfessional = _verifyProfessionalInfo(artist.professionalInfo);
    final bool incompletePresentationMedias = _verifyPresentationMedias(artist);

    final bool incompleteArtist = incompleteProfessional || 
                                 incompletePresentationMedias
                                 ;

    return UserIncompleteSectionsEntity._(
      hasIncompleteSections: incompleteRegister || incompleteArtist,
      incompleteRegisterData: incompleteRegister,
      incompleteArtistArea: incompleteArtist,
      incompleteProfessionalInfo: incompleteProfessional,
      incompleteBankAccount: incompleteBankAccount,
      incompleteDocuments: incompleteDocuments,
      incompletePresentationMedias: incompletePresentationMedias,
      incompleteProfilePicture: incompleteProfilePicture,
      incompleteMainAddress: incompleteMainAddress,
    );
  }

  static bool _verifyDocuments(List<DocumentsEntity>? documents) {
    if (documents == null) return true;
    final docTypes = DocumentsEntityOptions.documentTypes();
    for (var docType in docTypes) {
      final doc = documents.firstWhere((doc) => doc.documentType == docType, orElse: () => DocumentsEntity(documentType: docType, status: 0));
      if (doc.status == 0) {
        return true;
      }
    }
    return false;
  }

  static bool _verifyMainAddress(List<AddressInfoEntity>? addresses) {
    if (addresses == null) return true;
    final mainAddress = addresses.firstWhere((address) => address.isPrimary == true, orElse: () => AddressInfoEntity(zipCode: ''));
    if (mainAddress == AddressInfoEntity(zipCode: '')) return true;
    return false;
  }

  static bool _verifyBankAccount(BankAccountEntity? bankAccount) {
    if (bankAccount == null) return true;

    if (bankAccount.fullName != null && bankAccount.cpfOrCnpj != null) {
      if (bankAccount.pixType != null 
        && bankAccount.pixKey != null
        && bankAccount.pixType!.isNotEmpty
        && bankAccount.pixKey!.isNotEmpty) {
        return false;
      }

      if (bankAccount.bankName != null &&
          bankAccount.agency != null &&
          bankAccount.accountNumber != null &&
          bankAccount.accountType != null) {
        return false;
      }
    }
    return true;
  }

  static bool _verifyProfessionalInfo(ProfessionalInfoEntity? professionalInfo) {
    if (professionalInfo == null) return true;
    
    return professionalInfo.specialty == null ||
           professionalInfo.genrePreferences == null ||
           professionalInfo.minimumShowDuration == null ||
           professionalInfo.bio == null;
  }

  static bool _verifyPresentationMedias(ArtistEntity artist) {
    return artist.presentationMedias == null ||
           artist.presentationMedias?.isEmpty == true;
  }


  // Método para obter seções incompletas agrupadas
  Map<String, List<String>> getGroupedIncompleteSections() {
    final Map<String, List<String>> grouped = {};
    
    if (incompleteBankAccount || incompleteDocuments || incompleteProfilePicture) {
      incompleteRegisterData = true;
    } else {
      incompleteRegisterData = false;
    }

    if (incompleteProfessionalInfo || incompletePresentationMedias || incompleteMainAddress) {
      incompleteArtistArea = true;
    } else {
      incompleteArtistArea = false;
    }

    if (incompleteRegisterData) {
      final registerSections = <String>[];
      if (incompleteDocuments) registerSections.add('Documentos');
      if (incompleteBankAccount) registerSections.add('Dados bancários');
      if (incompleteProfilePicture) registerSections.add('Foto de perfil');
      grouped['Dados de Registro'] = registerSections;
    }
    
    if (incompleteArtistArea) {
      final artistSections = <String>[];
      if (incompleteProfessionalInfo) artistSections.add('Informações profissionais');
      if (incompletePresentationMedias) artistSections.add('Mídia de apresentação');
      if (incompleteMainAddress) artistSections.add('Endereço principal');
      grouped['Área do Artista'] = artistSections;
    }

    return grouped;
  }
}
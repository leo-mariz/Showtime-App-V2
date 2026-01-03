import 'package:app/core/domain/artist/artist_groups/group_entity.dart';
import 'package:app/core/domain/artist/artist_groups/group_member_entity.dart';
// import 'package:app/core/domain/artist/bank_account_entity/bank_account_entity.dart';
import 'package:app/core/domain/artist/professional_info_entity/professional_info_entity.dart';
import 'package:dart_mappable/dart_mappable.dart';
part 'group_incomplete_sections_entity.mapper.dart';

@MappableClass()
class GroupIncompleteSectionsEntity with GroupIncompleteSectionsEntityMappable{
  bool hasIncompleteSections;
  bool incompleteProfilePicture;
  bool incompleteGroupName;
  bool incompleteProfessionalInfo;
  bool incompletePresentationMedias;
  bool incompleteMembersApproval;

  GroupIncompleteSectionsEntity._({
    required this.hasIncompleteSections,
    required this.incompleteProfilePicture,
    required this.incompleteGroupName,
    required this.incompleteProfessionalInfo,
    required this.incompletePresentationMedias,
    required this.incompleteMembersApproval,
  });

  factory GroupIncompleteSectionsEntity.verify({
    required GroupEntity group,
  }) {
    final bool incompleteProfilePicture = group.profilePicture == null || group.profilePicture!.isEmpty;
    final bool incompleteGroupName = group.groupName == null || group.groupName!.isEmpty;
    final bool incompleteProfessionalInfo = _verifyProfessionalInfo(group.professionalInfo);
    final bool incompletePresentationMedias = _verifyPresentationMedias(group.presentationMedias);
      final bool incompleteMembersApproval = _verifyMembersApproval(group.members);

    final bool hasIncompleteSections =
      incompleteProfilePicture ||
      incompleteGroupName ||
      incompleteProfessionalInfo ||
      incompletePresentationMedias ||
      incompleteMembersApproval;

    return GroupIncompleteSectionsEntity._(
      hasIncompleteSections: hasIncompleteSections,
      incompleteProfilePicture: incompleteProfilePicture,
      incompleteGroupName: incompleteGroupName,
      incompleteProfessionalInfo: incompleteProfessionalInfo,
      incompletePresentationMedias: incompletePresentationMedias,
      incompleteMembersApproval: incompleteMembersApproval,
    );
  }

  static bool _verifyProfessionalInfo(ProfessionalInfoEntity? professionalInfo) {
    if (professionalInfo == null) return true;
    return professionalInfo.specialty == null ||
           professionalInfo.genrePreferences == null ||
           professionalInfo.minimumShowDuration == null ||
           professionalInfo.bio == null;
  }

  static bool _verifyPresentationMedias(Map<String, String>? presentationMedias) {
    return presentationMedias == null || presentationMedias.isEmpty;
  }

  // static bool _verifyBankAccount(BankAccountEntity? bankAccount) {
  //   if (bankAccount == null) return true;
  //   if (bankAccount.fullName != null && bankAccount.cpfOrCnpj != null) {
  //     if (bankAccount.pixType != null &&
  //         bankAccount.pixKey != null &&
  //         bankAccount.pixType!.isNotEmpty &&
  //         bankAccount.pixKey!.isNotEmpty) {
  //       return false;
  //     }
  //     if (bankAccount.bankName != null &&
  //         bankAccount.agency != null &&
  //         bankAccount.accountNumber != null &&
  //         bankAccount.accountType != null) {
  //       return false;
  //     }
  //   }
  //   return true;
  // }

  static bool _verifyMembersApproval(List<GroupMemberEntity>? members) {
    if (members == null || members.isEmpty) return true;
    return members.any((member) => member.inviteStatus == 1 && member.isApproved != true);
  }

  // Método para obter seções incompletas agrupadas
  Map<String, List<String>> getGroupedIncompleteSections() {
    final Map<String, List<String>> grouped = {};
    final groupSections = <String>[];

    if (incompleteProfilePicture) groupSections.add('Foto de perfil');
    if (incompleteGroupName) groupSections.add('Nome do grupo');
    if (incompleteProfessionalInfo) groupSections.add('Informações profissionais');
    if (incompletePresentationMedias) groupSections.add('Mídias de apresentação');
    if (incompleteMembersApproval) groupSections.add('Aprovação dos membros');

    if (groupSections.isNotEmpty) {
      grouped['Seções do Grupo'] = groupSections;
    }
    return grouped;
  }
} 
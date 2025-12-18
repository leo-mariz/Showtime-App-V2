
import 'package:dart_mappable/dart_mappable.dart';
part 'group_member_entity.mapper.dart';

@MappableClass()
class GroupMemberEntity with GroupMemberEntityMappable {
  final String? artistUid;
  bool isApproved;
  int inviteStatus;
  bool isAdmin;
  

  GroupMemberEntity({
    this.artistUid,
    this.inviteStatus = 0,
    this.isAdmin = false,
    this.isApproved = false,
  });
}




  

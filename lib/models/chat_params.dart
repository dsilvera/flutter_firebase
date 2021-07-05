import 'package:flutter_firebase/models/user.dart';

class ChatParams{
  final String userUid;
  final AppUserData peer;

  ChatParams(this.userUid, this.peer);

  String getChatGroupId() {
    if (userUid.hashCode <= peer.uid.hashCode) {
      return '$userUid-${peer.uid}';
    } else {
      return '${peer.uid}-$userUid';
    }
  }
}
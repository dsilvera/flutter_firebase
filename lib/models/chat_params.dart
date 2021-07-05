import 'package:flutter_firebase/models/user.dart';

class ChatParams {
  final String userUid;
  final AppUserData peer;

  ChatParams(this.userUid, this.peer);
}

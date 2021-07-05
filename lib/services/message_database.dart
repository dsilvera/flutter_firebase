import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_firebase/models/message.dart';

class MessageDatabaseService {
  final CollectionReference<Map<String, dynamic>> userCollection =
  FirebaseFirestore.instance.collection("users");


  List<Message> _messageListFromSnapshot(QuerySnapshot<Map<String, dynamic>> snapshot) {
    return snapshot.docs.map((doc) {
      return _messageFromSnapshot(doc);
    }).toList();
  }

  Message _messageFromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    var data = snapshot.data();
    if (data == null) throw Exception("message not found");
    return Message(
        idFrom: data['idFrom'],
        idTo: data['idTo'],
        timestamp: data['timestamp'],
        content: data['content'],
        type: data['type']
    );
  }

  Stream<List<Message>> getMessages(String groupChatId, int limit) {
    return FirebaseFirestore.instance
        .collection('messages')
        .doc(groupChatId)
        .collection(groupChatId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots().map(_messageListFromSnapshot);
  }


  void onSendMessage(String groupChatId, Message message) {
    var documentReference = FirebaseFirestore.instance
        .collection('messages')
        .doc(groupChatId)
        .collection(groupChatId)
        .doc(DateTime
        .now()
        .millisecondsSinceEpoch
        .toString());

    FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.set(
        documentReference,
        {
          'idFrom': message.idFrom,
          'idTo': message.idTo,
          'timestamp': message.timestamp,
          'content': message.content,
          'type': message.type
        },
      );
    });
  }
}

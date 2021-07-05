import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase/common/loading.dart';
import 'package:flutter_firebase/models/chat_params.dart';
import 'package:flutter_firebase/models/message.dart';
import 'package:flutter_firebase/services/message_database.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'item_message.dart';

class ChatScreen extends StatelessWidget {
  final ChatParams chatParams;

  const ChatScreen({Key? key, required this.chatParams}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.blueGrey,
          elevation: 0.0,
          title: Text('Chat with ' + chatParams.peer.name)),
      body: Chat(chatParams: chatParams),
    );
  }
}

class Chat extends StatefulWidget {
  Chat({Key? key, required this.chatParams}) : super(key: key);
  final ChatParams chatParams;

  @override
  ChatState createState() => ChatState(chatParams: chatParams);
}

class ChatState extends State<Chat> {
  ChatState({Key? key, required this.chatParams});

  final ChatParams chatParams;
  final MessageDatabaseService messageService = MessageDatabaseService();

  int _limit = 20;
  int _limitIncrement = 20;
  String groupChatId = "";
  bool isLoading = false;

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();

  _scrollListener() {
    if (listScrollController.offset >= listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange) {
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    listScrollController.addListener(_scrollListener);

    if (chatParams.userUid.hashCode <= chatParams.peer.uid.hashCode) {
      groupChatId = '${chatParams.userUid}-${chatParams.peer.uid}';
    } else {
      groupChatId = '${chatParams.peer.uid}-${chatParams.userUid}';
    }
  }

  Future getImage() async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile? pickedFile = await imagePicker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
        setState(() {
          isLoading = true;
        });
        uploadFile(pickedFile);
      }
  }

  Future uploadFile(PickedFile file) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString() + ".jpeg";
    try {
      Reference reference = FirebaseStorage.instance.ref().child(fileName);
      final metadata = SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'picked-file-path': file.path});

      TaskSnapshot snapshot;
      if (kIsWeb) {
        snapshot =  await reference.putData(await file.readAsBytes(), metadata);
      } else {
        snapshot = await reference.putFile(File(file.path), metadata);
      }

      String imageUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        isLoading = false;
        onSendMessage(imageUrl, 1);
      });
    } on Exception catch (e) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  void onSendMessage(String content, int type) {
    if (content.trim() != '') {
      textEditingController.clear();
      messageService.onSendMessage(
          groupChatId,
          Message(
              idFrom: chatParams.userUid,
              idTo: chatParams.peer.uid,
              timestamp: DateTime.now().millisecondsSinceEpoch.toString(),
              content: content,
              type: type));
      listScrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      Fluttertoast.showToast(
          msg: 'Nothing to send', backgroundColor: Colors.black, textColor: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Column(
          children: <Widget>[
            buildListMessage(),
            buildInput(),
          ],
        ),
        isLoading ? Loading() : Container()
      ],
    );
  }

  Widget buildListMessage() {
    return Flexible(
        child: StreamBuilder<List<Message>>(
            stream: messageService.getMessages(groupChatId, _limit),
            builder: (BuildContext context, AsyncSnapshot<List<Message>> snapshot) {
              if (snapshot.hasData) {
                List<Message> listMessage = snapshot.data?? List.from([]);
                return ListView.builder(
                  padding: EdgeInsets.all(10.0),
                  itemBuilder: (context, index) => MessageItem(
                      message: listMessage[index],
                      userId: chatParams.userUid,
                      isLastMessage: isLastMessage(index, listMessage)),
                  itemCount: listMessage.length,
                  reverse: true,
                  controller: listScrollController,
                );
              } else {
                return Center(child: Loading());
              }
            }));
  }

  Widget buildInput() {
    return Container(
      child: Row(
        children: <Widget>[
          // Button send image
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1.0),
              child: IconButton(
                icon: Icon(Icons.image),
                onPressed: getImage,
                color: Colors.blueGrey,
              ),
            ),
            color: Colors.white,
          ),
          // Edit text
          Flexible(
            child: Container(
              child: TextField(
                onSubmitted: (value) {
                  onSendMessage(textEditingController.text, 0);
                },
                style: TextStyle(color: Colors.blueGrey, fontSize: 15.0),
                controller: textEditingController,
                decoration: InputDecoration.collapsed(
                  hintText: 'Your message...',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ),

          // Button send message
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                icon: Icon(Icons.send),
                onPressed: () => onSendMessage(textEditingController.text, 0),
                color: Colors.blueGrey,
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 50.0,
      decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.black, width: 0.5)), color: Colors.white),
    );
  }

  bool isLastMessage(int index, List<Message> listMessage) {
    if (index == 0) return true;
    if (listMessage[index].idFrom != listMessage[index - 1].idFrom) return true;
    return false;
  }
}

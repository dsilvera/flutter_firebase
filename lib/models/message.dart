class Message {
  final String idFrom;
  final String idTo;
  final String timestamp;
  final String content;
  // type: 0 = text, 1 = image
  final int type;

  Message(
      {required this.idFrom,
      required this.idTo,
      required this.timestamp,
      required this.content,
      required this.type});
}

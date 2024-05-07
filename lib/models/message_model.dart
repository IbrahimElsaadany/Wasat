class MessageModel{
  final String receiverID, text;
  final DateTime sendTime;
  MessageModel(final Map<String,dynamic> json):
  receiverID = json["receiver_id"], text = json["text"],
  sendTime = DateTime.fromMillisecondsSinceEpoch(json["send_time"].millisecondsSinceEpoch);
  Map<String, dynamic> toMap()
  => <String,dynamic>{
    "receiver_id": receiverID,
    "text": text,
    "send_time": sendTime
  };
}
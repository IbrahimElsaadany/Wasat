import "package:flutter_bloc/flutter_bloc.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "../../../models/message_model.dart";
import "../../../network/remote.dart";
import "states.dart";
class ChatCubit extends Cubit<ChatStates>{
  bool enableSend = true;
  List<MessageModel>? messages;
  ChatCubit(): super(ChatInitialState());
  void init(
    final String userID,
    final String receiverID
  ){
    FirebaseFirestore.instance.collection("users").
    doc(userID).collection("chats").doc(receiverID).collection("messages")
    .snapshots().listen((final QuerySnapshot<Map<String, dynamic>> event){
      messages = event.docs.where((final QueryDocumentSnapshot<Map<String, dynamic>> e) => e.data().isNotEmpty)
      .map((final QueryDocumentSnapshot<Map<String, dynamic>> e) => MessageModel(e.data())).toList()
      ..sort((final MessageModel current, final MessageModel prev)=>prev.sendTime.compareTo(current.sendTime));
      emit(ChatGetSuccessState());
    });
  }
  void sendMessage({
    required final String userID,
    required final String receiverID,
    required final String text,
    required final DateTime sendTime,
    required final String token,
    required final String userToken,
    required final String userName
  }) async{
    enableSend = false;
    emit(ChatSendingState());
    try{
      FirebaseFirestore.instance.runTransaction((final Transaction transaction)async{
        final DocumentReference<Map<String, dynamic>> senderDoc = await
        FirebaseFirestore.instance.collection("users").
        doc(userID).collection("chats").doc(receiverID).collection("messages").add({});
        final DocumentReference<Map<String, dynamic>> receiverDoc = await
        FirebaseFirestore.instance.collection("users").
        doc(receiverID).collection("chats").doc(userID).collection("messages").add({});
        transaction.set(senderDoc, {
          "receiver_id": receiverID,
          "text": text,
          "send_time": sendTime
        });
        transaction.set(receiverDoc, {
          "receiver_id": receiverID,
          "text": text,
          "send_time": sendTime
        });
      },
      timeout: const Duration(seconds: 5),
      maxAttempts: 1,
    ).timeout(const Duration(seconds: 5),onTimeout: (){
      enableSend = true;
      emit(ChatSendErrorState());
    }).then((final Object? value){
      if(userToken != token)
        DioHelper.dio.post(
          "send",
          data: <String,dynamic>{
            "to": token,
            "notification":{
              "title": userName,
              "body": text,
            },
            "priority": "high",
            "data": <String,dynamic>{
              "receiver_id": userID
            }
          }
        );
      enableSend = true;
      emit(ChatSendSuccessState());
    });
    }catch(e){
      enableSend = true;
      emit(ChatSendErrorState());
    }
  }
}
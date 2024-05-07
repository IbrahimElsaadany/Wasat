import "dart:typed_data";
import "package:firebase_messaging/firebase_messaging.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_storage/firebase_storage.dart";
import "package:image_picker/image_picker.dart";
import "../../../models/post_model.dart";
import "../../../models/user_model.dart";
import "../../../network/remote.dart";
import "states.dart";
class SocialCubit extends Cubit<SocialStates>{
  int currentScreen = 0, notiCount = 0;
  List<RemoteMessage> notifications = [];
  bool isUpdating = false;
  Uint8List? newImage, newCover;
  UserModel? userModel;
  Map<String,PostModel>? posts;
  Map<String, UserModel> users = {};
  String? commentValue;
  SocialCubit():super(SocialInitialState());
  Map<String, UserModel> usersSearchList = {};
  String _token = '';
  Future<void> init()async{
    final FirebaseMessaging messaging = FirebaseMessaging.instance;
    messaging.requestPermission().then((final NotificationSettings settings) {
      if(settings.authorizationStatus == AuthorizationStatus.authorized)
        messaging.getToken().then((final String? token) {
          if(token!=null){
            _token = token;
            FirebaseFirestore.instance.collection("users").doc(
              FirebaseAuth.instance.currentUser!.uid
            ).update({"token": _token});
          } 
        });
    });
    users.clear();
    try{
      FirebaseFirestore.instance.collection("users").get()
      .then((final QuerySnapshot<Map<String, dynamic>> value){
        for(final QueryDocumentSnapshot userDoc in value.docs)
          users[userDoc.id] = UserModel(userDoc.data() as Map<String,dynamic>);
        userModel = users[FirebaseAuth.instance.currentUser!.uid];
        emit(SocialGetAllUsersState());
        if(_token.isNotEmpty){
          FirebaseMessaging.onMessageOpenedApp.listen((final RemoteMessage message){
            if(message.data["receiver_id"]!=null)
              emit(SocialGetInitialMessage(
                userToken: _token,
                receiverID: message.data["receiver_id"],
                receiverModel: users[message.data["receiver_id"]]!,
                receiverName: message.notification!.title!
              ));
          });
          FirebaseMessaging.instance.getInitialMessage()
          .then((final RemoteMessage? message){
            if(message?.data["receiver_id"]!=null){
              emit(SocialGetInitialMessage(
                userToken: _token,
                receiverID: message!.data["receiver_id"],
                receiverModel: users[message.data["receiver_id"]]!,
                receiverName: message.notification!.title!
              ));
            }
          });
          FirebaseMessaging.onMessage.listen((final RemoteMessage message) {
            if(message.data["receiver_id"]==null || notifications.isEmpty || notifications.isNotEmpty && notifications[0].data["receiver_id"] != message.data["receiver_id"]){
              notifications.insert(0, message);
              notiCount++;
              emit(SocialChangeNotificationsState());
            }
          });
        }
      });
      await refresh();
    }catch(e) {emit(SocialErrorState("An error happened!"));}
  }
  Future<void> refresh(){
    return FirebaseFirestore.instance.collection("posts").orderBy("date", descending: true).get()
    ..then((final QuerySnapshot<Map<String,dynamic>> value){
      posts = {};
      for(final QueryDocumentSnapshot<Map<String,dynamic>> postDoc in value.docs){
        posts![postDoc.id] = PostModel(postDoc.data());
      }
      emit(SocialGetPostsSuccessState());
    })..catchError((final e)=>emit(SocialErrorState(e.code)));
  }
  void likeUnlike(final String postID){
    userModel!.likedPosts.contains(postID)?
      userModel!.likedPosts.remove(postID):userModel!.likedPosts.add(postID);
    posts![postID]!.likes += userModel!.likedPosts.contains(postID)? 1:-1;
    emit(SocialLoadingState());
    final DocumentReference<Map<String, dynamic>> userDoc = FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser?.uid);
    final DocumentReference<Map<String, dynamic>> postDoc = FirebaseFirestore.instance.collection("posts").doc(postID);
    FirebaseFirestore.instance.runTransaction((final Transaction transaction)async{
      transaction.update(userDoc, {"liked_posts": userModel!.likedPosts})
      .update(postDoc, {"likes": posts![postID]!.likes});
    }).then((final Object? value) => emit(SocialLikeSuccessState()))
    .catchError((final e){
      userModel!.likedPosts.contains(postID)?
        userModel!.likedPosts.remove(postID):userModel!.likedPosts.add(postID);
      posts![postID]!.likes += userModel!.likedPosts.contains(postID)? 1:-1;
      emit(SocialErrorState());
    });
  }
  void comment({
    required final String postID,
    required final String authorID,
    required final String text,
  }) {
    FirebaseFirestore.instance.collection("posts").doc(postID).update(
      {"comments": FieldValue.arrayUnion(<Map<String, String>>[<String,String>{"author": authorID, "text": text}])}
    ).then((final void value){
      posts![postID]!.comments.insert(0, CommentModel(<String,String>{"author": authorID, "text": text}));
      if(_token != users[posts![postID]!.authorID]!.token)
        DioHelper.dio.post(
          "send",
          data: <String,dynamic>{
            "to": users[posts![postID]!.authorID]!.token,
            "notification":{
              "title": userModel!.name,
              "body": "${userModel!.name} commented on your post.",
            },
            "priority": "high",
            "data": <String,dynamic>{
              "post_id": postID
            }
          }
        );
      emit(PostCommentSuccessState());
    }).catchError((e)=>emit(SocialErrorState()));
  }
  void uploadImage(int i){
    ImagePicker().pickImage(
      source: ImageSource.values[i],
      imageQuality: 40
    ).then((final XFile? img)async{
      if(img!=null) newImage = await img.readAsBytes();
      emit(ProfileChangeImageState());
    }).catchError((final e){});
  }
  void uploadCover(){
    ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 40
    ).then((final XFile? img)async{
      if(img!=null) newCover = await img.readAsBytes();
      emit(ProfileChangeImageState());
    }).catchError((final e){});
  }
  void updateSettings({
    required final String name,
    required final String phone,
  }){
    isUpdating = true;
    emit(SettingsUpdatingState());
    Future.wait([
      if(newImage!=null) FirebaseStorage.instance.ref(
        "users/${FirebaseAuth.instance.currentUser!.uid}_image"
      ).putData(newImage!),
      if(newCover!=null) FirebaseStorage.instance.ref(
        "users/${FirebaseAuth.instance.currentUser!.uid}_cover"
      ).putData(newCover!)
    ]).then((final List<TaskSnapshot> val)async{
      FirebaseFirestore.instance.collection("users").doc(
        FirebaseAuth.instance.currentUser!.uid
      ).set({
        "name": name,
        "phone": phone,
        if(newImage!=null)
        "image": await FirebaseStorage.instance.ref("users/${FirebaseAuth.instance.currentUser!.uid}_image").getDownloadURL(),
        if(newCover!=null)
        "cover": await FirebaseStorage.instance.ref("users/${FirebaseAuth.instance.currentUser!.uid}_cover").getDownloadURL(),
      }, SetOptions(merge: true));
    }).then((value){
      isUpdating = false;
      emit(SettingsSuccessState());
    }).catchError((final e){
      isUpdating = false;
      emit(SocialErrorState());
    });
  }
  void search(final String word){
    usersSearchList = {};
    users.forEach((final String key, final UserModel value) {
      if(key!=FirebaseAuth.instance.currentUser!.uid && value.name.contains(word)) usersSearchList.addAll({key: value});
    });
    emit(SearchSuccessState());
  }
  void changeScreen(int i){
    currentScreen = i;
    emit(SocialChangeScreenState());
  }
  void clearNotiCount(){
    notiCount=0;
    emit(SocialChangeNotificationsState());
  }
}
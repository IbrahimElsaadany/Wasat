import "dart:typed_data";
import "package:firebase_storage/firebase_storage.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:image_picker/image_picker.dart";
import "states.dart";
class PostCubit extends Cubit<PostStates>{
  Uint8List? imageAsBytes;
  bool isLoading = false;
  PostCubit():super(PostInitialState());
  void post(final String text){
    if(text !='' || imageAsBytes!=null){
      isLoading = true;
      emit(PostLoadingState());
      final DateTime currentTime = DateTime.now();
      if(imageAsBytes!=null){
        FirebaseStorage.instance.ref("posts_images").child(currentTime.toString()).putData(imageAsBytes!)
        .then((final TaskSnapshot p0)async{
          _postText(
            text: text,
            currentTime: currentTime,
            url: await p0.ref.getDownloadURL()
          );
        }).catchError((final e){
          isLoading = false;
          emit(PostErrorState(e.code));
        });
      }
      else _postText(text: text, currentTime: currentTime);
    }
  }
  void _postText({
    required final String text,
    required final DateTime currentTime,
    final String? url
  })
  =>FirebaseFirestore.instance.collection("posts").add({
    "author_id": FirebaseAuth.instance.currentUser!.uid,
    "date": currentTime,
    "text": text==''?null:text,
    "image": url,
    "likes": 0,
    "comments": []
  }).then((final DocumentReference<Map<String,dynamic>> post){
    isLoading = false;
    emit(PostSuccessState());
  }).catchError((final e){
    isLoading = false;
    emit(PostErrorState(e.code));
  });
  void uploadImage(int i){
    ImagePicker().pickImage(
      source: ImageSource.values[i],
      imageQuality: 40
    ).then((final XFile? img)async{
      if(img!=null) imageAsBytes = await img.readAsBytes();
      emit(PostChangeImageState());
    }).catchError((final e){});
  }
  void cancelImage(){
    imageAsBytes = null;
    emit(PostChangeImageState());
  }
}
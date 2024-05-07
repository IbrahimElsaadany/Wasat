import "package:flutter_bloc/flutter_bloc.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "states.dart";
class RegisterCubit extends Cubit<RegisterStates>{
  bool isObscure = true, isLoading = false;
  RegisterCubit():super(RegisterInitialState());
  void changeVisibility(){
    isObscure = !isObscure;
    emit(RegisterChangeVisibilityState());
  }
  void register({
    required final String name,
    required final String email,
    required final String phone,
    required final String password
  }){
    isLoading = true;
    emit(RegisterLoadingState());
    FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password
    ).then((final UserCredential credential){
      FirebaseFirestore.instance.collection("users").doc(
        credential.user!.uid
      ).set({
        "name": name,
        "email": email,
        "phone": phone,
        "friends": [],
        "following": [],
        "liked_posts": [],
        "token": ''
      }).then((final void value)=> emit(RegisterSuccessState()));
    }).catchError((e){
      isLoading = false;
      emit(RegisterErrorState(e.code));
    });
  }
}
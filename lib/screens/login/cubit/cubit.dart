import "package:flutter/foundation.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:google_sign_in/google_sign_in.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "states.dart";
class LoginCubit extends Cubit<LoginStates>{
  bool isObscure = true, isLoading=false;
  LoginCubit():super(LoginInitialState());
  void changeVisibility(){
    isObscure = !isObscure;
    emit(LoginChangeVisibilityState());
  }
  void login({
    required final String email,
    required final String password
  }){
    isLoading=true;
    emit(LoginLoadingState());
    FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password
    ).then((final UserCredential credential)=> emit(LoginSuccessState(credential.user!.emailVerified)))
    .catchError((final e) {
      isLoading = false;
      emit(LoginErrorState(e.code));
    });
  }
  void signInWithGoogle()async{
    if(kIsWeb){
      GoogleAuthProvider authProvider = GoogleAuthProvider(); 
      FirebaseAuth.instance.signInWithPopup(authProvider).then((final UserCredential userCredential){
        if(userCredential.additionalUserInfo!.isNewUser)
          FirebaseFirestore.instance.collection("users").doc(
          userCredential.user?.uid
        ).set({
          "name": userCredential.user?.displayName,
          "email": userCredential.user?.email,
          "phone": userCredential.user?.phoneNumber,
          "friends": [],
          "following": [],
          "liked_posts": [],
          "token": ''
        }).then((final void value) => emit(LoginSuccessState(true)));
        else emit(LoginSuccessState(true));
      }).catchError((final e) => emit(LoginErrorState(e.code))); 
    }else{
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken
      );
      FirebaseAuth.instance.signInWithCredential(credential).then((final UserCredential userCredential){
        if(userCredential.additionalUserInfo!.isNewUser)
          FirebaseFirestore.instance.collection("users").doc(
          userCredential.user?.uid
        ).set({
          "name": userCredential.user?.displayName,
          "email": userCredential.user?.email,
          "phone": userCredential.user?.phoneNumber,
          "friends": [],
          "following": [],
          "liked_posts": [],
          "token": ''
        }).then((final void value) => emit(LoginSuccessState(true)));
        else emit(LoginSuccessState(true));
      }).catchError((final e)=>emit(LoginErrorState(e.code)));
    }
  }
}
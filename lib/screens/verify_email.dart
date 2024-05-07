import "dart:async" show Timer;
import 'package:flutter/material.dart';
import "package:firebase_auth/firebase_auth.dart";
import "package:fluttertoast/fluttertoast.dart";
import "../shared/functions.dart";
class VerifyEmail extends StatelessWidget {
  const VerifyEmail({super.key});

  @override
  Scaffold build(final BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: FirebaseAuth.instance.currentUser!.sendEmailVerification()..then((value){
          Timer.periodic(const Duration(seconds: 2), (final Timer timer)async{
            await FirebaseAuth.instance.currentUser?.reload();
            if(FirebaseAuth.instance.currentUser!.emailVerified){
              Fluttertoast.showToast(
                msg: "Your email has been verified successfully.",
                backgroundColor: Theme.of(context).primaryColor
              );
              Navigator.pushReplacementNamed(context, "/");
              timer.cancel();
            }
          });
        }),
        builder: (context, final AsyncSnapshot<void> sendState) {
          return Center(
            child: sendState.connectionState == ConnectionState.waiting? const CircularProgressIndicator():
            Card(
              elevation: 12.0,
              shape: const RoundedRectangleBorder(side: BorderSide(color: Colors.grey)),
              surfaceTintColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 15.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/verify_email.png",
                      height:  getDimension(context, 0.25),
                    ),
                    const Text(
                      "A verification link has been sent\nto your email address.\n Check it now to continue!",
                      textAlign: TextAlign.center,
                    )
                  ],
                ),
              ),
            )
          );
        }
      )
    );
  }
}
import 'package:flutter/material.dart';
import "package:flutter_bloc/flutter_bloc.dart";
import "package:fluttertoast/fluttertoast.dart";
import "../../shared/functions.dart";
import "cubit/cubit.dart";
import "cubit/states.dart";
class Login extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController(),
    _passwordController = TextEditingController();
  Login({super.key});
  @override
  Stack build(BuildContext context) => Stack(
    alignment: Alignment.topRight,
    children: [
      Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width*0.9,
              height: MediaQuery.of(context).size.height*0.7,
              padding: const EdgeInsets.all(15.0),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(.1),
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(color: Theme.of(context).primaryColor)
              ),
              child: BlocProvider<LoginCubit>(
                create: (final BuildContext context) => LoginCubit(),
                child: BlocConsumer<LoginCubit,LoginStates>(
                  listener: (final BuildContext context,final LoginStates state){
                    if(state is LoginSuccessState){
                      Fluttertoast.showToast(
                        msg: "You're signed in successfully.",
                        backgroundColor: Theme.of(context).primaryColor,
                      );
                      Navigator.pushReplacementNamed(context, state.isVerified? "/": "verify_email");
                    }
                    else if(state is LoginErrorState)
                      Fluttertoast.showToast(
                        msg: state.error?.splitAndCapitalize()??"Unexpected error happened!",
                        backgroundColor: Colors.red
                      );
                  },
                  builder: (final BuildContext context, final LoginStates state) {
                    final LoginCubit cubit = BlocProvider.of<LoginCubit>(context);
                    return Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Login now to communicate with friends!",
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.03),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: "Email Address",
                              prefixIcon: const Icon(Icons.email_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                            validator: (final String? val)
                            =>RegExp(r"^([\w-\.\w-]+)+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(val!)? null:
                              "Invalid email address!"
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.02),
                          TextFormField(
                            controller: _passwordController,
                            keyboardType: TextInputType.visiblePassword,
                            obscureText: cubit.isObscure,
                            decoration: InputDecoration(
                              labelText: "Password",
                              suffixIcon: IconButton(
                                icon: Icon(cubit.isObscure? Icons.visibility_outlined:Icons.visibility_off_outlined),
                                onPressed: ()=>cubit.changeVisibility()
                              ),
                              prefixIcon: const Icon(Icons.lock_outline),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0)
                              ),
                            ),
                            validator: (final String? val)
                            =>val!.length>5? null:
                              "Passowrd must contain 6 characters or more."
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.02),
                          cubit.isLoading?
                            const CircularProgressIndicator():
                            ElevatedButton(
                              child: const Text("LOGIN"),
                              onPressed: (){
                                if(_formKey.currentState!.validate()){
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  cubit.login(
                                    email: _emailController.text,
                                    password: _passwordController.text
                                  );
                                }
                              },
                            ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Don't have an account?"),
                              TextButton(
                                child: const Text("Register now"),
                                onPressed: ()=>Navigator.pushNamed(context,"register"),
                              )
                            ],
                          ),
                          OutlinedButton.icon(
                            label: const Text("Sign in with Google"),
                            icon: Image.asset(
                              "assets/images/google.png",
                              height: MediaQuery.of(context).size.height*0.05,
                            ),
                            onPressed: ()=>cubit.signInWithGoogle()
                          )
                        ],
                      ),
                    );
                  }
                ),
              ),
            ),
          )
        )
      ),
      Container(
        width: MediaQuery.of(context).size.width*0.2,
        height: MediaQuery.of(context).size.height*0.1,      
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(MediaQuery.of(context).size.width*0.3)
          )
        ),
      ),
      Align(
        alignment: Alignment.bottomLeft,
        child: Container(
          width: MediaQuery.of(context).size.width*0.4,
          height: MediaQuery.of(context).size.height*0.2,      
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(MediaQuery.of(context).size.width*0.7)
            )
          ),
        ),
      ),
    ],
  );
}
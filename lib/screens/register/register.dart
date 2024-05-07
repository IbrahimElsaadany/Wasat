import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import "package:fluttertoast/fluttertoast.dart";
import "../../shared/functions.dart";
import 'cubit/cubit.dart';
import 'cubit/states.dart';

class Register extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController(),
    _emailController = TextEditingController(), _passwordController = TextEditingController(),
    _phoneController = TextEditingController();
  Register({super.key});
  @override
  Stack build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        Scaffold(
          appBar: AppBar(),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(2.0),
              physics:const ScrollPhysics(),
              child: Container(
                width: MediaQuery.of(context).size.width*0.9,
                height: MediaQuery.of(context).size.height*0.85,
                padding: const EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(.1),
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(color: Theme.of(context).primaryColor)
                ),
                child: BlocProvider<RegisterCubit>(
                  create: (final BuildContext context)=>RegisterCubit(),
                  child: BlocConsumer<RegisterCubit, RegisterStates>(
                    listener: (final BuildContext context,final RegisterStates state){
                      if(state is RegisterSuccessState){
                        Fluttertoast.showToast(
                          msg: "Registeration done successfully.",
                          backgroundColor: Theme.of(context).primaryColor,
                          toastLength: Toast.LENGTH_SHORT
                        );
                        Navigator.pushReplacementNamed(context,"verify_email");
                      }
                      else if(state is RegisterErrorState)
                        Fluttertoast.showToast(
                          msg: state.error?.splitAndCapitalize()??"Unexpected error happened!",
                          backgroundColor: Colors.red
                        );
                    },
                    builder: (final BuildContext context, final RegisterStates state) {
                    final RegisterCubit cubit = BlocProvider.of<RegisterCubit>(context);
                      return Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Register now to join WASAT community!",
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            SizedBox(height: MediaQuery.of(context).size.height*0.03),
                            TextFormField(
                              controller: _nameController,
                              keyboardType: TextInputType.name,
                              decoration: InputDecoration(
                                labelText: "Name",
                                prefixIcon: const Icon(Icons.person_outline),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0)
                                ),
                              ),
                              validator: (final String? val)=>val!.isNotEmpty?null:"Name can't be empty.",
                            ),
                            SizedBox(height: MediaQuery.of(context).size.height*0.02),
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
                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                labelText: "Phone Number",
                                prefixIcon: const Icon(Icons.phone_android_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                              ),
                              validator: (final String? val)
                              =>RegExp(r"^\+?\d{6,}$").hasMatch(val!)? null:
                                "Number must contain at least 6 digits and can't include spaces and special characters."
                            ),
                            SizedBox(height: MediaQuery.of(context).size.height*0.02),
                            cubit.isLoading?
                              const CircularProgressIndicator():
                              ElevatedButton(
                                child: const Text("REGISTER"),
                                onPressed: (){
                                  if(_formKey.currentState!.validate()){
                                    FocusManager.instance.primaryFocus?.unfocus();
                                    cubit.register(
                                      name: _nameController.text,
                                      email: _emailController.text,
                                      phone: _phoneController.text,
                                      password: _passwordController.text
                                    );
                                  }
                                },
                              ),
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
          width: MediaQuery.of(context).size.width*0.3,
          height: MediaQuery.of(context).size.height*0.15,      
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(MediaQuery.of(context).size.width*0.3)
            )
          ),
        ),
      ],
    );
  }
}
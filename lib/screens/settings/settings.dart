import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:fluttertoast/fluttertoast.dart";
import "../../shared/functions.dart";
import "../social/cubit/cubit.dart";
import "../social/cubit/states.dart";
class Settings extends StatelessWidget{
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController(),
    _phoneController = TextEditingController();
  final SocialCubit _cubit;
  Settings({
    super.key,
    required final SocialCubit cubit,
  }): _cubit = cubit;
  @override
  Widget build(final BuildContext context) {
    _nameController.text = _cubit.userModel!.name;
    _phoneController.text = _cubit.userModel!.phone;
    return BlocProvider<SocialCubit>.value(
    value: _cubit,
    child: BlocConsumer<SocialCubit,SocialStates>(
      listener: (final BuildContext context, final SocialStates state){
        if(state is SettingsSuccessState){
          Navigator.pushNamedAndRemoveUntil(
            context,
            "/",
            (final Route<dynamic> predicate)=> false
          );
          Fluttertoast.showToast(
            msg: "Updating profile done successfully.",
            backgroundColor: Theme.of(context).primaryColor,
            toastLength: Toast.LENGTH_SHORT
          );
        }
        else if(state is SocialErrorState)
          Fluttertoast.showToast(
            msg: state.error?.splitAndCapitalize()??"Unexpected error happened!",
            backgroundColor: Colors.red
          );
      },
      builder: (final BuildContext context, final SocialStates state) => Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            automaticallyImplyLeading: false,
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              physics: const BouncingScrollPhysics(),
              children: <Widget>[
                SizedBox(
                  height: getDimension(context, 0.23),
                  child: Stack(
                    children: <Widget>[
                      _cubit.newCover==null?
                      Image.network(
                        _cubit.userModel!.cover,
                        width: double.infinity,
                        height: getDimension(context, 0.15),
                        fit: BoxFit.cover
                      ):Image.memory(
                        _cubit.newCover!,
                        width: double.infinity,
                        height: getDimension(context, 0.27),
                        fit: BoxFit.cover
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: const CircleAvatar(
                            child: Icon(Icons.add_photo_alternate_outlined)
                          ),
                          onPressed: ()=>_cubit.uploadCover(),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                CircleAvatar(
                                  radius: getDimension(context, 0.058, isRadius: true),
                                  child: _cubit.newImage == null?
                                  CircleAvatar(
                                    radius: getDimension(context, 0.055, isRadius: true),
                                    backgroundImage: NetworkImage(
                                      _cubit.userModel!.image
                                    ),
                                  ):CircleAvatar(
                                    radius: getDimension(context, 0.08, isRadius: true),
                                    backgroundImage: MemoryImage(_cubit.newImage!),
                                  ),
                                ),
                                IconButton(
                                  icon: const CircleAvatar(
                                    child: Icon(Icons.add_a_photo_outlined)
                                  ),
                                  onPressed: () {
                                    if(kIsWeb) _cubit.uploadImage(1);
                                    else _scaffoldKey.currentState!.showBottomSheet(
                                      (final BuildContext context) => Row(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          Expanded(
                                            child: InkWell(
                                              child: Icon(Icons.photo_camera_outlined, color: Theme.of(context).colorScheme.onPrimary),
                                              onTap: (){
                                                Navigator.pop(context);
                                                _cubit.uploadImage(0);
                                              }
                                            ),
                                          ),
                                          const VerticalDivider(width: 0.0),
                                          Expanded(
                                            child: InkWell(
                                              child: Icon(Icons.photo_outlined, color: Theme.of(context).colorScheme.onPrimary),
                                              onTap: (){
                                                Navigator.pop(context);
                                                _cubit.uploadImage(1);
                                              }
                                            ),
                                          ),
                                        ],
                                      ),
                                      constraints: const BoxConstraints.expand(height: 60.0),
                                      elevation: 25.0,
                                      backgroundColor: Theme.of(context).primaryColor,
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 5.0),
                            Text(
                              _cubit.userModel!.name,
                              style: Theme.of(context).textTheme.titleMedium
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 15.0,),
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
                _cubit.isUpdating?
                  const CircularProgressIndicator():
                  ElevatedButton(
                    child: const Text("UPDATE PROFILE"),
                    onPressed: (){
                      if(_formKey.currentState!.validate()){
                        FocusManager.instance.primaryFocus?.unfocus();
                        _cubit.updateSettings(
                          name: _nameController.text,
                          phone: _phoneController.text,
                        );
                      }
                    },
                  ),
                SizedBox(height: MediaQuery.of(context).size.height*0.01),
                OutlinedButton(
                  child: const Text("CANCEL"),
                  onPressed: () {
                    _cubit.newImage = _cubit.newCover = null;
                    Navigator.pop(context);
                  }
                ),
                SizedBox(height: MediaQuery.of(context).size.height*0.01),
              ],
            ),
          )
        )
      
    ),
  );
  }
}
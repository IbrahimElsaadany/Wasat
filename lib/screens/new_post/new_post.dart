import "package:flutter/foundation.dart";
import 'package:flutter/material.dart';
import "package:fluttertoast/fluttertoast.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "../../../shared/functions.dart";
import "cubit/cubit.dart";
import "cubit/states.dart";
class NewPost extends StatelessWidget {
  NewPost({super.key});
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _textController = TextEditingController();
  @override
  Scaffold build(final BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("New Post"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: BlocProvider<PostCubit>(
          create: (final BuildContext context)=>PostCubit(),
          child: BlocConsumer<PostCubit, PostStates>(
            listener: (final BuildContext context, final PostStates state){
              if(state is PostLoadingState){
                FocusManager.instance.primaryFocus?.unfocus();
                showDialog(
                  context: context,
                  builder: (final BuildContext context)=>const AlertDialog(
                    title: Text("Posting...", textAlign: TextAlign.start),
                    content: LinearProgressIndicator(),
                  ),
                  barrierDismissible: false
                );
              }
              else if(state is PostErrorState){
                Fluttertoast.showToast(msg: state.error.splitAndCapitalize(), backgroundColor: Colors.red);
                Navigator.pop(context);
              }
              else if(state is PostSuccessState){
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  "/",
                  (final Route<dynamic> route) => false
                );
              }
            },
            builder: (final BuildContext context, final PostStates state){
              final PostCubit cubit = BlocProvider.of<PostCubit>(context);
              return Column(
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        TextField(
                          controller: _textController,
                          maxLines: null,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "What do you think?",
                          )
                        ),
                        if(cubit.imageAsBytes!=null) Stack(
                          alignment: Alignment.topRight,
                          children: [
                            Image.memory(
                              cubit.imageAsBytes!, width: double.infinity,
                              fit: BoxFit.cover
                            ),
                            IconButton(
                              color: Colors.black.withOpacity(.75),
                              icon: const Icon(Icons.cancel),
                              onPressed: ()=>cubit.cancelImage(),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add_a_photo_outlined),
                        onPressed: () {
                          if(kIsWeb) cubit.uploadImage(1);
                          else
                          _scaffoldKey.currentState!.showBottomSheet(
                            (final BuildContext context) => Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: InkWell(
                                    child: Icon(Icons.photo_camera_outlined, color: Theme.of(context).colorScheme.onPrimary),
                                    onTap: (){
                                      Navigator.pop(context);
                                      cubit.uploadImage(0);
                                    }
                                  ),
                                ),
                                const VerticalDivider(width: 0.0),
                                Expanded(
                                  child: InkWell(
                                    child: Icon(Icons.photo_outlined, color: Theme.of(context).colorScheme.onPrimary),
                                    onTap: (){
                                      Navigator.pop(context);
                                      cubit.uploadImage(1);
                                    }
                                  ),
                                ),
                              ],
                            ),
                            constraints: const BoxConstraints.expand(height: 60.0),
                            elevation: 25.0,
                            backgroundColor: Theme.of(context).primaryColor,
                          );
                        }
                      ),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.post_add_outlined),
                          label: const Text("POST"),
                          onPressed: ()=>cubit.post(_textController.text),
                        ),
                      )
                    ],
                  )
                ],
              );
            }
          ),
        ),
      )
    );
  }
}
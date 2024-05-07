import "package:flutter/material.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:intl/intl.dart" show DateFormat;
import "package:font_awesome_flutter/font_awesome_flutter.dart";
import "package:wasat/screens/social/cubit/states.dart";
import "../screens/social/cubit/cubit.dart";
import "../models/user_model.dart";
import "../models/post_model.dart";
class PostWidget extends StatelessWidget{
  final PostModel _postModel;
  final String _postID;
  final UserModel _userModel;
  final SocialCubit _cubit;
  final bool? _isDialog;
  PostWidget({
    super.key,
    required final PostModel postModel,
    required final String postID,
    required final UserModel userModel,
    required final SocialCubit cubit,
    final bool? isDialog
  }): _postModel = postModel, _postID = postID,
      _userModel = userModel, _cubit = cubit, _isDialog = isDialog;
  final TextEditingController _commentController = TextEditingController();
  @override
  Card build(final BuildContext context)
  => Card(
    margin: _isDialog == null? EdgeInsets.zero: EdgeInsets.all(
      MediaQuery.of(context).size.width*0.05
    ),
    elevation: 5.0,
    shape: RoundedRectangleBorder(
      side: const BorderSide(color: Colors.grey),
      borderRadius: BorderRadius.circular(12.0)
    ),
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: BlocProvider.value(
        value: _cubit,
        child: BlocBuilder<SocialCubit,SocialStates>(
          builder: (final BuildContext context, final SocialStates state) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: <Widget>[
                    CircleAvatar(
                      backgroundImage: NetworkImage(_cubit.users[_postModel.authorID]!.image),
                      radius: 25.0,
                    ),
                    const SizedBox(width: 12.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_cubit.users[_postModel.authorID]!.name),
                        Text(
                          "${DateFormat.yMd().format(_postModel.date)} at ${DateFormat.jm().format(_postModel.date)}",
                          style: Theme.of(context).textTheme.titleSmall
                        )
                      ],
                    ),
                  ],
                ),
                const Divider(),
                if(_postModel.text!='') SelectableText(_postModel.text),
                if(_postModel.text!='' && _postModel.image!=null) const SizedBox(height: 5.0),
                if(_postModel.image!=null) Image.network(
                  _postModel.image!,
                  width: double.infinity,
                  fit: BoxFit.cover
                ),
                Row(
                  children: <Widget>[
                    IconButton(
                      iconSize: 18.0,
                      icon: FaIcon(_userModel.likedPosts.contains(_postID)? FontAwesomeIcons.solidThumbsUp: FontAwesomeIcons.thumbsUp),
                      onPressed: ()=>_cubit.likeUnlike(_postID)
                    ),
                    Text(
                      _postModel.likes.toString(),
                      style: Theme.of(context).textTheme.titleSmall
                    ),
                    const Spacer(),
                    const FaIcon(FontAwesomeIcons.comment, size: 18.0, color: Colors.grey),
                    Text(
                      " ${_cubit.posts![_postID]!.comments.length} comments ",
                      style: Theme.of(context).textTheme.titleSmall,
                    )
                  ],
                ),
                const Divider(),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(_userModel.image),
                      radius: 16.0,
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: BlocListener<SocialCubit,SocialStates>(
                        listener: (final BuildContext context, final SocialStates state){
                          if(state is PostCommentSuccessState){
                            FocusManager.instance.primaryFocus?.unfocus();
                            _commentController.clear();
                          }
                        },
                        child: TextField(
                          controller: _commentController,
                          style: const TextStyle(fontSize: 14.0),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Type a comment...",
                            suffixIcon: IconButton(
                              iconSize: 20.0,
                              icon: Icon(
                                Icons.send_outlined, color: Theme.of(context).primaryColor),
                              onPressed: (){
                                if(_commentController.text.isNotEmpty)
                                  _cubit.comment(
                                    postID: _postID,
                                    authorID: FirebaseAuth.instance.currentUser!.uid,
                                    text: _commentController.text
                                  );
                              }
                            )
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if(_cubit.posts![_postID]!.comments.isNotEmpty)
                ...List.generate(
                  _cubit.posts![_postID]!.comments.length,
                  (final int i)=>
                  Column(
                    children: <Widget>[
                    const Divider(),
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(_cubit.users[_cubit.posts![_postID]!.comments[i].authorID]!.image),
                          radius: 16.0
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _cubit.users[_cubit.posts![_postID]!.comments[i].authorID]!.name,
                                style: Theme.of(context).textTheme.bodySmall
                              ),
                              Text(
                                _cubit.posts![_postID]!.comments[i].text,
                                style: Theme.of(context).textTheme.bodySmall
                              ),
            
                            ],
                          ),
                        ),
                      ],
                    )],
                  )
                )
              ]
            )
        ),
      )
    )
  );
}
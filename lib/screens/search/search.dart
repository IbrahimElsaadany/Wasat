import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:font_awesome_flutter/font_awesome_flutter.dart";
import "package:wasat/models/user_model.dart";
import "package:wasat/screens/chat/chat.dart";
import "../profile_page/profile.dart";
import "../social/cubit/cubit.dart";
import "../social/cubit/states.dart";
class Search extends StatelessWidget{
  final SocialCubit _cubit;
  final TextEditingController _searchController = TextEditingController();
  Search(
    final SocialCubit cubit,
    {super.key}
  ): _cubit = cubit;
  @override
  Scaffold build(final BuildContext context)
  =>Scaffold(
    appBar: AppBar(),
    body: BlocProvider<SocialCubit>.value(
      value: _cubit,
      child: BlocBuilder<SocialCubit, SocialStates>(
        builder: (final BuildContext context, final SocialStates state) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  style: const TextStyle(fontSize: 12.0),
                  onSubmitted: (final String val)=>_cubit.search(val),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0)
                    ),
                    suffixIcon: const Icon(Icons.search),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.only(top: 10.0),
                    separatorBuilder: (final BuildContext context, final int i)=>const Divider(),
                    itemCount: _cubit.usersSearchList.length,
                    itemBuilder: (final BuildContext context, final int i) {
                      final MapEntry<String,UserModel> userItem = _cubit.usersSearchList.entries.toList()[i];
                      return InkWell(
                        borderRadius: BorderRadius.circular(12.0),
                        onTap: ()=>Navigator.push(context, MaterialPageRoute(
                          builder: (final BuildContext context)=>Profile(
                            cubit: _cubit,
                            userID: userItem.key
                          )
                        )),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 32.0,
                                backgroundImage: NetworkImage(
                                  userItem.value.image
                                ),
                              ),
                              const SizedBox(width: 10.0),
                              Expanded(
                                child: Text(
                                  userItem.value.name,
                                  style: const TextStyle(
                                    fontSize: 18.0
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                icon: const FaIcon(FontAwesomeIcons.message),
                                onPressed: ()=>Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (final BuildContext context)
                                    =>ChatScreen(
                                      userID: FirebaseAuth.instance.currentUser!.uid,
                                      userToken: _cubit.userModel!.token,
                                      receiverID: userItem.key,
                                      userName: userItem.value.name,
                                      receiverModel: userItem.value
                                    )
                                  )
                                )
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          );
        }
      ),
    )
  );
}
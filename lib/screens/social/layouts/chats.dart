import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../chat/chat.dart';
import '../cubit/cubit.dart';
Widget chats(final BuildContext context, final SocialCubit cubit) {
  final List<String> chats = cubit.users.keys.toList()..remove(FirebaseAuth.instance.currentUser!.uid);
  return cubit.posts == null || cubit.userModel == null? const Center(child: CircularProgressIndicator()):
  ListView.separated(
    padding: const EdgeInsets.symmetric(
      horizontal: 10.0,
    ),
    separatorBuilder: (final BuildContext context, final int i)=>const Divider(),
    itemCount: cubit.users.length - 1,
    itemBuilder: (final BuildContext context, final int i)
    => InkWell(
      borderRadius: BorderRadius.circular(12.0),
      onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (final BuildContext context)=>ChatScreen(
          userToken: cubit.userModel!.token,
          userID: FirebaseAuth.instance.currentUser!.uid,
          receiverID: chats[i],
          receiverModel: cubit.users[chats[i]]!,
          userName: cubit.userModel!.name,
        )
      )),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25.0,
              backgroundImage: NetworkImage(
                cubit.users[chats[i]]!.image
              ),
            ),
            const SizedBox(width: 10.0),
            Text(
              cubit.users[chats[i]]!.name,
              style: const TextStyle(
                fontSize: 16.0
              )
            )
          ],
        ),
      ),
    ),
  );
}
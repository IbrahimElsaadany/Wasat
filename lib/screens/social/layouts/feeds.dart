import "package:flutter/material.dart";
import "../cubit/cubit.dart";
import "../../../shared/components.dart";
Widget feeds(final BuildContext context, final SocialCubit cubit)
=> cubit.posts == null || cubit.userModel == null?
const Center(child: CircularProgressIndicator()):
RefreshIndicator(
  onRefresh: cubit.refresh,
  child: ListView(
    padding: const EdgeInsets.symmetric(horizontal: 10.0),
    physics: const AlwaysScrollableScrollPhysics(
      parent: BouncingScrollPhysics()
    ),
    children: [
      const SizedBox(height: 10.0),
      ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(40.0),
          bottomRight: Radius.circular(40.0)
        ),
        child: Image.asset(
          "assets/images/cover.png",
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
      const SizedBox(height: 15.0,),
      if(cubit.posts!.isNotEmpty)
        ...List.generate(cubit.posts!.length, (final int i)
        => Column(
          children: [
            PostWidget(
              cubit: cubit,
              postModel: cubit.posts!.entries.toList()[i].value,
              postID: cubit.posts!.entries.toList()[i].key,
              userModel: cubit.userModel!
            ),
            const SizedBox(height: 30.0,),
          ],
        ))
      else Center(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 50.0),
            const Icon(Icons.post_add, size:60.0, color: Colors.grey),
            Text(
              "No posts here.\n Why not add one?",textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall
            )
          ],
        )
      ),
      const SizedBox(height: 40.0)
    ],
  ),
);
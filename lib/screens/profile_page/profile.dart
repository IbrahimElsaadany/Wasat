import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "../../models/post_model.dart";
import "../../shared/components.dart";
import "../../shared/functions.dart";
import "../social/cubit/cubit.dart";
import "../social/cubit/states.dart";
class Profile extends StatelessWidget{
  final SocialCubit _cubit;
  final String _userID;
  const Profile({
    super.key,
    required final SocialCubit cubit,
    required final String userID,
  }): _cubit = cubit, _userID = userID;
  @override
  BlocProvider<SocialCubit> build(final BuildContext context)
  => BlocProvider<SocialCubit>.value(
    value: _cubit,
    child: BlocBuilder<SocialCubit,SocialStates>(
      builder: (final BuildContext context, final SocialStates state) => Scaffold(
          appBar: AppBar(),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            physics: const BouncingScrollPhysics(),
            children: <Widget>[
              SizedBox(
                height: getDimension(context, 0.23),
                child: Stack(
                  children: <Widget>[
                    Image.network(
                      _cubit.users[_userID]!.cover,
                      width: double.infinity,
                      height: getDimension(context, 0.15),
                      fit: BoxFit.cover
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                              radius: getDimension(context, 0.058, isRadius: true),
                            child: CircleAvatar(
                              radius: getDimension(context, 0.055, isRadius: true),
                              backgroundImage: NetworkImage(
                                _cubit.users[_userID]!.image
                              ),
                            ),
                          ),
                          const SizedBox(height: 5.0),
                          Text(
                            _cubit.users[_userID]!.name,
                            style: Theme.of(context).textTheme.titleMedium
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 15.0),
              if(_cubit.posts!.isNotEmpty) ..._getProfilePosts()
              else Center(
                child: Column(
                  children: <Widget>[
                    const SizedBox(height: 50.0),
                    const Icon(Icons.post_add, size:60.0, color: Colors.grey),
                    Text(
                      "No posts yet!",textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleSmall
                    )
                  ],
                )
              )
            ],
          )
        )    
    ),
  );
  List<Column> _getProfilePosts(){
    final Iterable<MapEntry<String,PostModel>> profilePosts = _cubit.posts!.entries.where((final MapEntry<String, PostModel> element) => element.value.authorID == _userID);
    return List<Column>.generate(
      profilePosts.length,
      (final int i)=> Column(
        children: [
          PostWidget(
            cubit: _cubit,
            postModel: profilePosts.toList()[i].value,
            postID: _cubit.posts!.entries.toList()[i].key,
            userModel: _cubit.userModel!
          ),
          const SizedBox(height: 15.0,),
        ],
      )
    );
  }
}
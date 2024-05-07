import "package:firebase_messaging/firebase_messaging.dart";
import 'package:flutter/material.dart';
import "package:flutter_bloc/flutter_bloc.dart";
import "package:font_awesome_flutter/font_awesome_flutter.dart";
import "package:firebase_auth/firebase_auth.dart";
import "../../shared/components.dart";
import "../../shared/theme_cubit/cubit.dart";
import "../chat/chat.dart";
import "layouts/feeds.dart";
import "layouts/chats.dart";
import "../profile_page/profile.dart";
import "../search/search.dart";
import "../settings/settings.dart";
import "cubit/cubit.dart";
import "cubit/states.dart";
class Social extends StatelessWidget {
  Social({super.key});
  final List<Widget Function(BuildContext, SocialCubit)> _screens = [feeds, chats];
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (final BuildContext context)=>SocialCubit()..init(),
      child: BlocConsumer<SocialCubit,SocialStates>(
        listener: (final BuildContext context, final SocialStates state){
          if(state is SocialGetInitialMessage) Navigator.push(
            context,
            MaterialPageRoute(
              builder: (final BuildContext context)=>ChatScreen(
                userToken: state.userToken,
                receiverID: state.receiverID,
                receiverModel: state.receiverModel,
                userID: FirebaseAuth.instance.currentUser!.uid,
                userName: state.receiverName,
              )
            )
          );
        },
        builder: (final BuildContext context, final SocialStates state) {
          final SocialCubit cubit = BlocProvider.of<SocialCubit>(context);
          return Scaffold(
            appBar: AppBar(
              elevation: 5.0,
              shadowColor: Colors.black,
              title: Text(
                cubit.currentScreen==0? "New Feeds": "Chats",
                style: Theme.of(context).textTheme.titleLarge
              ),
              actions: [
                InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {
                    cubit.clearNotiCount();
                    showDialog(
                      context: context,
                      builder: (final BuildContext context)=>AlertDialog(
                        title: Text(
                          "Notifications",
                          style: Theme.of(context).textTheme.titleLarge
                        ),
                        content: SizedBox(
                          height: MediaQuery.of(context).size.height*0.7,
                          width: MediaQuery.of(context).size.width*0.3,
                          child: cubit.notifications.isEmpty?
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                const Icon(
                                  Icons.notifications_paused_outlined,
                                  size: 60.0,
                                  color: Colors.grey
                                ),
                                Text(
                                  "No incoming notifications!",
                                  style: Theme.of(context).textTheme.titleSmall
                                )
                              ],
                            ),
                          ): ListView.separated(
                            itemCount: cubit.notifications.length,
                            itemBuilder: (final BuildContext context, final int i){
                              final RemoteMessage notif = cubit.notifications[i];
                              if(notif.data["receiver_id"]!=null)
                                return InkWell(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: RichText(
                                      text: TextSpan(
                                        text: notif.notification!.title,
                                        style: TextStyle(color: Theme.of(context).primaryColor),
                                        children: <TextSpan>[
                                          TextSpan(
                                            text: " sent you a message.",
                                            style: Theme.of(context).textTheme.bodyMedium
                                          )
                                        ]
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.pop(context);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (final BuildContext context)=>ChatScreen(
                                          userToken: cubit.userModel!.token,
                                          receiverID: notif.data["receiver_id"],
                                          receiverModel: cubit.users[notif.data["receiver_id"]]!,
                                          userID: FirebaseAuth.instance.currentUser!.uid,
                                          userName: notif.notification!.title!,
                                        )
                                      )
                                    );
                                  }
                                );
                              return InkWell(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child:  RichText(
                                    text: TextSpan(
                                      text: notif.notification!.title,
                                      style: TextStyle(color: Theme.of(context).primaryColor),
                                      children: <TextSpan>[
                                        TextSpan(
                                          text: " commented on your post.",
                                          style: Theme.of(context).textTheme.bodyMedium
                                        )
                                      ]
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (final BuildContext context)
                                    =>FutureBuilder(
                                      future: cubit.refresh(),
                                      builder: (final BuildContext context, final AsyncSnapshot snapshot) {
                                        if(snapshot.connectionState == ConnectionState.waiting)
                                          return const Center(child: CircularProgressIndicator());
                                        else if(snapshot.connectionState == ConnectionState.done)
                                          return PostWidget(
                                            postModel: cubit.posts![notif.data["post_id"]]!,
                                            postID: notif.data["post_id"],
                                            userModel: cubit.userModel!,
                                            cubit: cubit,
                                            isDialog: true,
                                          );
                                        return Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            const Icon(
                                              Icons.error_outline,
                                              size: 60.0,
                                              color: Colors.grey
                                            ),
                                            Text(
                                              "An error happened",
                                              style: Theme.of(context).textTheme.titleSmall
                                            )
                                          ],
                                        );
                                      }
                                    ),
                                  );
                                }
                              );
                            },
                            separatorBuilder: (final BuildContext context, final int i)=>const Divider(),
                          )
                        ),
                      )
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Icon(
                          Icons.notifications_outlined,
                          color: Theme.of(context).primaryColor,
                        ),
                        CircleAvatar(
                          backgroundColor: cubit.notiCount==0? Colors.transparent: Colors.red,
                          radius: 7.0,
                          child: Text(
                            cubit.notiCount>0 && cubit.notiCount<10? '${cubit.notiCount}':'',
                            style: const TextStyle(fontSize: 9.0),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search_outlined),
                  onPressed: ()=>Navigator.push(context, MaterialPageRoute(
                    builder: (final BuildContext context)=> Search(cubit)
                  ))
                )
              ],
            ),
            drawer: NavigationDrawer(
              children: [
                if(cubit.userModel == null) const LinearProgressIndicator()
                else ...[
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      UserAccountsDrawerHeader(
                        currentAccountPicture: CircleAvatar(
                          backgroundImage: NetworkImage(cubit.userModel!.image)
                        ),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(cubit.userModel!.cover)
                          ),
                        ),
                        accountName: Text(cubit.userModel!.name),
                        accountEmail: Text(cubit.userModel!.email),
                      ),
                      IconButton(
                        icon: const CircleAvatar(
                          child: Icon(Icons.brightness_4_outlined)
                        ),
                        onPressed: ()=>BlocProvider.of<ThemeCubit>(context).changeTheme(),
                      )
                    ],
                  ),
                  ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: const Text("Profile"),
                    onTap: ()=>Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (final BuildContext context)=>Profile(
                          cubit: cubit,
                          userID: FirebaseAuth.instance.currentUser!.uid,
                        )
                      )
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings_outlined),
                    title: const Text("Settings"),
                    onTap: ()=>Navigator.push(
                      context, MaterialPageRoute(builder: (final BuildContext context)
                      =>Settings(cubit: cubit)
                      )
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout_outlined),
                    title: const Text("Log out"),
                    onTap: ()=>FirebaseAuth.instance.signOut().then((value){
                      Navigator.pushReplacementNamed(context, "login");
                    }),
                  ),
                ]
              ]
            ),
            body: _screens[cubit.currentScreen](context, cubit),
            floatingActionButton: MediaQuery.of(context).viewInsets.bottom==0.0 && cubit.currentScreen == 0?
            FloatingActionButton(
              onPressed: ()=>Navigator.pushNamed(context, "/new_post"),
              heroTag: null,
              child: const FaIcon(FontAwesomeIcons.pencil)
            ): null,
            bottomNavigationBar: BottomNavigationBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              currentIndex: cubit.currentScreen,
              onTap: (final int i)=>cubit.changeScreen(i),
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  label: "Home"
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.chat_bubble_rounded),
                  label: "Chats"
                ),
              ]
            )
          );
        }
      ),
    );
  }
}
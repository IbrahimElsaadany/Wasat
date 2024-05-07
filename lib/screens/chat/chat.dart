import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../models/message_model.dart';
import '../../models/user_model.dart';
import 'cubit/cubit.dart';
import 'cubit/states.dart';
class ChatScreen extends StatelessWidget {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final String _userID, _userToken, _receiverID, _userName;
  final UserModel _receiverModel;
  ChatScreen({
    super.key,
    required final String userID,
    required final String receiverID,
    required final String userToken,
    required final String userName,
    required final UserModel receiverModel,
  }):
  _userID = userID, _receiverID = receiverID, _userToken = userToken,
   _receiverModel = receiverModel, _userName = userName;
  @override
  Scaffold build(BuildContext context)
  => Scaffold(
    appBar: AppBar(
      titleSpacing: 0.0,
      title: Row(
        children: <Widget>[
          CircleAvatar(
            backgroundImage: NetworkImage(_receiverModel.image),
          ),
          const SizedBox(width: 10.0),
          Text(
            _receiverModel.name,
            style: const TextStyle(fontSize: 18.0)
          )
        ]
      )
    ),
    body: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: BlocProvider<ChatCubit>(
        create: (final BuildContext context) => ChatCubit()..init(_userID, _receiverID),
        child: BlocConsumer<ChatCubit,ChatStates>(
          listener: (final BuildContext context, final ChatStates state){
            if(state is ChatSendSuccessState) _textController.clear();
            else if(state is ChatSendErrorState) Fluttertoast.showToast(
              msg: "An error happened!\nCheck your internet connection and try again.",
              backgroundColor: Colors.red
            );
          },
          builder: (final BuildContext context, final ChatStates state) {
            final ChatCubit cubit = BlocProvider.of<ChatCubit>(context);
            return cubit.messages == null?
            const Center(child: CircularProgressIndicator()):
            Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    reverse: true,
                    controller: _scrollController,
                    itemCount: cubit.messages!.length,
                    itemBuilder: (final BuildContext context, final int i)
                    => _buildMessageItem(context, cubit.messages![i]),
                    separatorBuilder: (final BuildContext context, final int i)=> const SizedBox(height: 5.0)
                  ),
                ),
                const SizedBox(height: 10.0,),
                TextField(
                  enabled: cubit.enableSend,
                  controller: _textController,
                  maxLines: 4,
                  minLines: 1,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(8.0),
                    hintText: "Type your message here ...",
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.send),
                      color: Theme.of(context).primaryColor,
                      onPressed: ()=>cubit.sendMessage(
                        userID: _userID,
                        receiverID: _receiverID,
                        text: _textController.text,
                        sendTime: DateTime.now(),
                        token: _receiverModel.token,
                        userToken: _userToken,
                        userName: _userName
                      )
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0)
                    )
                  )
                )
              ],
            );
          }
        )
      ),
    )
  );
  Align _buildMessageItem(final BuildContext context, final MessageModel message)
  => message.receiverID == _userID?
  Align(
    alignment: AlignmentDirectional.centerStart,
    child: Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(.2),
        borderRadius: const BorderRadiusDirectional.only(
          bottomEnd: Radius.circular(15.0),
          topStart: Radius.circular(15.0),
          topEnd: Radius.circular(15.0),
        )
      ),
      child: Text(message.text),
    ),
  ):
  Align(
    alignment: AlignmentDirectional.centerEnd,
    child: Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(.25),
        borderRadius: const BorderRadiusDirectional.only(
          bottomStart: Radius.circular(15.0),
          topStart: Radius.circular(15.0),
          topEnd: Radius.circular(15.0),
        )
      ),
      child: Text(message.text),
    ),
  );
}
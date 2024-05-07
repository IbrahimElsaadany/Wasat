abstract class ChatStates{}
class ChatInitialState extends ChatStates{}
class ChatSendingState extends ChatStates{}
class ChatSendErrorState extends ChatStates{}
class ChatSendSuccessState extends ChatStates{}
class ChatGetSuccessState extends ChatStates{}
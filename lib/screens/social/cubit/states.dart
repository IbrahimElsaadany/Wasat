import '../../../models/user_model.dart';

abstract class SocialStates{}
class SocialInitialState extends SocialStates{}
class SocialLoadingState extends SocialStates{}
class SocialGetUserSuccessState extends SocialStates{}
class SocialGetPostsSuccessState extends SocialStates{}
class SocialGetAllUsersState extends SocialStates{}
class SocialErrorState extends SocialStates{
  final String? error;
  SocialErrorState([this.error]);
}
class SocialLikeSuccessState extends SocialStates{}
class PostCommentSuccessState extends SocialStates{}
class SocialChangeLayoutState extends SocialStates{}
class ProfileChangeImageState extends SocialStates{}
class SettingsUpdatingState extends SocialStates{}
class SettingsSuccessState extends SocialStates{}
class SettingsErrorState extends SocialStates{
  final String? error;
  SettingsErrorState([this.error]);
}
class SearchSuccessState extends SocialStates{}
class SocialChangeScreenState extends SocialStates{}
class SocialGetInitialMessage extends SocialStates{
  final String receiverID, receiverName, userToken;
  final UserModel receiverModel;
  SocialGetInitialMessage({
    required this.userToken,
    required this.receiverID,
    required this.receiverModel,
    required this.receiverName,
  });
}
class SocialChangeNotificationsState extends SocialStates{}
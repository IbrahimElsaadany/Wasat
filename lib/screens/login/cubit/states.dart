abstract class LoginStates{}
class LoginInitialState extends LoginStates{}
class LoginChangeVisibilityState extends LoginStates{}
class LoginLoadingState extends LoginStates{}
class LoginSuccessState extends LoginStates{
  final bool isVerified;
  LoginSuccessState(this.isVerified);
}
class LoginErrorState extends LoginStates{
  final String? error;
  LoginErrorState([this.error]);
}
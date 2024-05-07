abstract class PostStates{}
class PostInitialState extends PostStates{}
class PostChangeImageState extends PostStates{}
class PostErrorState extends PostStates{
  final String error;
  PostErrorState(this.error);
}
class PostSuccessState extends PostStates{}
class PostLoadingState extends PostStates{
  PostLoadingState();
}
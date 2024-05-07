class PostModel{
  final String authorID, text;
  final DateTime date;
  final String? image;
  int likes;
  List<CommentModel> comments = [];
  PostModel(final Map<String,dynamic> json):
  authorID = json["author_id"], date = DateTime.fromMillisecondsSinceEpoch(json["date"].millisecondsSinceEpoch),
  text = json["text"]??'', image = json["image"],
  likes=json["likes"]{
    for(final Map<String,dynamic> commentJson in json["comments"])
      comments.insert(0, CommentModel(commentJson));
  }
}
class CommentModel{
  final String authorID;
  final String text;
  CommentModel(final Map<String,dynamic> json):
  authorID = json["author"],
  text = json["text"]; 
}
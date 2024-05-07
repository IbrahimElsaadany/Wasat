class UserModel{
  final String name, email, phone, token, image, cover;
  final List likedPosts;
  UserModel(final Map<String,dynamic> json):
  name = json["name"], email = json["email"],
  phone = json["phone"]??'',
  token = json["token"],
  image = json["image"]??"https://t4.ftcdn.net/jpg/00/64/67/27/360_F_64672736_U5kpdGs9keUll8CRQ3p3YaEv2M6qkVY5.jpg",
  cover = json["cover"]??"https://img.freepik.com/free-vector/worldwide-connection-blue-background-illustration-vector_53876-76824.jpg?t=st=1714851433~exp=1714855033~hmac=4b66622eb2a50224b740df12961fa114dfd9797d151a6693dcc6983ee21c95f5&w=740",
  likedPosts = json["liked_posts"];
}
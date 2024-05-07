import "package:dio/dio.dart";
abstract class DioHelper{
  static late final Dio dio;
  static void init()=>dio=Dio(BaseOptions(
    baseUrl:"https://fcm.googleapis.com/fcm/",
    receiveDataWhenStatusError:true,
    headers: {
      "Content-Type": "application/json",
      "Authorization": "key=AAAAzS9hoSY:APA91bFJVwUnSan3AEYaWmfVMeuy68RdwpIaVln_fbKdY5ZCepUL2m-yRurvTmTanc2_MLNmDsuZ3qi_9Ibjjb3bEXpEv89zFOSke8Ggz6MuwmLu1FF8GuKz00B7OQQCa1WlIAVByzuC"
    },
    validateStatus: (_)=>true
  ));
}
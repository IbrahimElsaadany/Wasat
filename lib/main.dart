import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:flutter/foundation.dart";
import "package:firebase_core/firebase_core.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "firebase_options.dart";
import "network/local.dart";
import "network/remote.dart";
import "screens/on_boarding.dart";
import "screens/login/login.dart";
import "screens/register/register.dart";
import "screens/verify_email.dart";
import "screens/social/social.dart";
import 'screens/new_post/new_post.dart';
import "shared/theme_cubit/cubit.dart";
import "shared/theme_cubit/states.dart";
void main()async{
  DioHelper.init();
  WidgetsFlutterBinding.ensureInitialized();
  await CacheHelper.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  runApp(const MyApp());
}
class MyApp extends StatelessWidget{
  const MyApp({super.key});
  @override
  Widget build(final BuildContext context)
  => BlocProvider<ThemeCubit>(
    create: (final BuildContext context)=>ThemeCubit(),
    child: BlocBuilder<ThemeCubit,ThemeStates>(
      builder: (final BuildContext context, final ThemeStates state)
      => MaterialApp(
          theme: _getTheme(
            false,
            background: Colors.white,
            primary: const Color.fromARGB(255, 33, 118, 187),
            onPrimary: Colors.white
          ),
          darkTheme: _getTheme(
            true,
            background: Colors.grey[850]!,
            primary: Colors.teal,
            onPrimary: Colors.white
          ),
          initialRoute: _start(),
          routes: <String, Widget Function(BuildContext)>{
            "on_boarding": (final BuildContext context) => OnBoarding(),
            "login": (final BuildContext context) => Login(),
            "register": (final BuildContext context) => Register(),
            "verify_email": (final BuildContext context)=>const VerifyEmail(),
            "/": (final BuildContext context)=>Social(),
            "/new_post": (final BuildContext context)=>NewPost(),
          },
          themeMode: BlocProvider.of<ThemeCubit>(context).nightMode? ThemeMode.dark: ThemeMode.light
        )
    ),
  );
  ThemeData _getTheme(
    final bool isNight,
  {
    required final Color background,
    required final Color primary,
    required final Color onPrimary,
  })
  =>ThemeData(
    fontFamily: "Slab",
    scaffoldBackgroundColor: background,
    appBarTheme: AppBarTheme(color: background),
    primaryColor: primary,
    textTheme: TextTheme(
      titleLarge: TextStyle(
        color: primary
      ),
      titleSmall: const TextStyle(
        color: Colors.grey
      )
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        minimumSize: const Size(double.infinity,40),
      )
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 40.0),
      )
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: primary,
      )
    ),
    dividerTheme: const DividerThemeData(
      color: Colors.grey
    ),
    colorScheme: (isNight? ColorScheme.dark: ColorScheme.light)(
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primary,
      surfaceTint: onPrimary,
    )
  );
  String _start(){
    if(!kIsWeb && CacheHelper.prefs.getBool("on_boarding") == null)
      return "on_boarding";
    else if(FirebaseAuth.instance.currentUser == null || !FirebaseAuth.instance.currentUser!.emailVerified)
      return "login";
    return "/";
  }
}
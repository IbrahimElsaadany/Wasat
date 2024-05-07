import "package:flutter_bloc/flutter_bloc.dart";
import "package:wasat/shared/theme_cubit/states.dart";
import "../../network/local.dart";
class ThemeCubit extends Cubit<ThemeStates>{
  bool nightMode = CacheHelper.prefs.getBool("night")??false;
  ThemeCubit():super(ThemeInitialState());
  void changeTheme(){
    CacheHelper.prefs.setBool("night", nightMode=!nightMode);
    emit(ThemeChangeState());
  }
}
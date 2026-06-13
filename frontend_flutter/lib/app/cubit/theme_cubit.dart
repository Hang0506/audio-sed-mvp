import 'package:flutter_bloc/flutter_bloc.dart';

enum ThemeModeType { light, dark }

class ThemeCubit extends Cubit<ThemeModeType> {
  ThemeCubit() : super(ThemeModeType.light);

  void toggleTheme() {
    emit(state == ThemeModeType.light ? ThemeModeType.dark : ThemeModeType.light);
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier with ChangeNotifier {
  ThemeNotifier();

  bool _isDarkMode = false;
  set isDarkMode(bool value) {
    _isDarkMode = value;
    _currentThemeData = themeList[value ? 1 : 0];
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('isDarkMode', value);
    });
    notifyListeners();
  }

  bool get isDarkMode => _isDarkMode;

  ThemeData _currentThemeData = themeList[0];
  ThemeData get currentThemeData => _currentThemeData;
}

// light theme
// dark theme
List<ThemeData> themeList = [
  ThemeData(
    platform: TargetPlatform.iOS,
    fontFamily: 'Manrope',
    brightness: Brightness.light,
    primaryColor: Color(0xFFFFCB00),
    primaryColorDark: Color(0xFFEDA200),
    accentColor: Color(0xFF54D2D2),
    scaffoldBackgroundColor: Color(0xFF072448),
    canvasColor: Color(0xFFDEE0E6),
    cardColor: Color(0xFFEDEFF5),
    textTheme: textTheme.merge(lightThemeText),
    toggleableActiveColor: Color(0xFFFFCB00),
  ),
  ThemeData(
    platform: TargetPlatform.iOS,
    fontFamily: 'Manrope',
    brightness: Brightness.dark,
    primaryColor: Color(0xFF54D2D2),
    primaryColorDark: Color(0xFFFFCB00),
    accentColor: Color(0xFFFFCB00),
    scaffoldBackgroundColor: Color(0xFF021124),
    canvasColor: Color(0xFF0F1824),
    cardColor: Color(0xFF262F3B),
    appBarTheme: AppBarTheme(
      color: Color(0xFF54D2D2),
    ),
    textTheme: textTheme.merge(darkThemeText),
    toggleableActiveColor: Color(0xFFFFCB00),
  ),
];

TextTheme textTheme = const TextTheme(
  display4: const TextStyle(
    fontSize: 64,
    fontWeight: FontWeight.w700,
  ),
  display3: const TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w700,
  ),
  display2: const TextStyle(
    fontSize: 28,
    //fontWeight: FontWeight.w500,
  ),
  display1: const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
  ),
  headline: const TextStyle(
    fontSize: 22,
  ),
  subhead: const TextStyle(
    fontSize: 18,
    //fontWeight: FontWeight.w500,
  ),
  title: const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
  ),
  subtitle: const TextStyle(
    fontSize: 16,
    //fontWeight: FontWeight.w500,
  ),
  body2: const TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
  ),
  body1: const TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
  ),
);

const TextTheme lightThemeText = TextTheme(
  display4: TextStyle(
    color: Colors.black87,
  ),
  display3: TextStyle(
    color: Colors.black87,
  ),
  display2: TextStyle(
    color: Colors.black87,
  ),
  display1: TextStyle(
    color: Colors.black87,
  ),
);

const TextTheme darkThemeText = TextTheme(
  display4: TextStyle(
    color: Colors.white,
  ),
  display3: TextStyle(
    color: Colors.white,
  ),
  display2: TextStyle(
    color: Colors.white,
  ),
  display1: TextStyle(
    color: Colors.white,
  ),
);

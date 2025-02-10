import 'package:flutter/material.dart';

abstract mixin class DefaultTheme {
  ThemeData get light => ThemeData(
        scaffoldBackgroundColor: Colors.black,
        textTheme: const TextTheme(
          bodySmall: TextStyle(
            fontFamily: 'NotoSans',
            color: Colors.white,
            fontSize: 18,
          ),
          titleLarge: TextStyle(
            fontFamily: 'Geist',
            fontWeight: FontWeight.bold,
            letterSpacing: 0.1,
            fontSize: 24,
          ),
        ),
      );

  ThemeData get dark => ThemeData(
        scaffoldBackgroundColor: Colors.black,
        textTheme: const TextTheme(
          bodySmall: TextStyle(
            fontFamily: 'Geist',
            color: Colors.white,
            fontSize: 18,
          ),
          titleLarge: TextStyle(
            fontFamily: 'Geist',
            fontWeight: FontWeight.bold,
            letterSpacing: 0.1,
            fontSize: 24,
          ),
        ),
      );
}

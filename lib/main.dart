import 'package:flutter/material.dart';
import 'package:namer_app/views/home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            colorScheme: ColorScheme(
                brightness: Brightness.dark,
                primary: Color(0xffffd700),
                onPrimary: Color(0xffffffff),
                secondary: Color(0xffffffff),
                onSecondary: Color(0xffa0a0a0),
                error: Color(0xffff2c2c),
                onError: Color(0xffffffff),
                surface: Color(0xfff0f0f0),
                onSurface: Color(0xffffffff)
            ),
            textTheme: const TextTheme(
                displayLarge: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.normal,
                    color: Color(0xffa8a8a8)
                ),
                displayMedium: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: Color.fromARGB(255, 168, 168, 168)
                ),
                displaySmall: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff888888)
                )
            ),
            iconTheme: const IconThemeData(
              size: 24,
              color: Color(0xffa0a0a0),
            ),
            appBarTheme: const AppBarTheme(
              toolbarHeight: 60,
              titleTextStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500
              )
            )
        ),
        home: const HomePage(),
        routes: {
          '/home': (context) => const HomePage()
        });
  }
}

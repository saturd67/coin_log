import 'package:coin_log/services/DatabaseService.dart';
import 'package:flutter/material.dart';
import 'package:coin_log/views/app_frame/app_frame.dart';
import 'package:logging/logging.dart';

void main() async {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.loggerName}: ${record.message}');
  });

  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService().database;
  // await DatabaseService().listTables(db);
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
                primary: Color(0xff27ae60),
                onPrimary: Color(0xffffffff),
                secondary: Color(0xffffffff),
                onSecondary: Color(0xffb4b4b4),
                tertiary: Color(0xffe6e6e6),
                onTertiary: Color(0xffa0a0a0),
                error: Color(0xffff2c2c),
                onError: Color(0xffffffff),
                surface: Color(0xfff0f0f0),
                onSurface: Color(0xffffffff),
            ),
            textTheme: const TextTheme(
                displayLarge: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.normal,
                    color: Color(0xff3b3b3b)
                ),
                displayMedium: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: Color(0xff3b3b3b)
                ),
                displaySmall: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff3b3b3b)
                ),
                bodyLarge: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.normal,
                    color: Color(0xff14181b)
                ),
                bodyMedium: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: Color(0xff14181b)
                ),
                bodySmall: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.normal,
                    color: Color(0xff14181b)
                ),
            ),
            iconTheme: const IconThemeData(
              size: 30,
              color: Color(0xff27ae60),
            ),
            inputDecorationTheme: const InputDecorationTheme(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Color(0xffffffff),
              hintStyle: TextStyle(color: Color(0xff3b3b3b))
            ),
            appBarTheme: const AppBarTheme(
              elevation: 2,
              toolbarHeight: 60,
              centerTitle: true,
              titleTextStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold
              )
            ),
            dividerTheme: DividerThemeData(
                thickness: 1,
                color: Color(0xffe0e3e7),
            ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xff50a55e),
              foregroundColor: Color(0xffffffff),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6)
              )
            )
          )
        ),
        home: const AppFramePage(),
        routes: {
          '/home': (context) => const AppFramePage()
        },);
        // navigatorObservers: [routeObserver],
  }
}

extension CustomColorScheme on ColorScheme {
  Color get success => const Color(0xff3DC13C);
  Color get danger => const Color(0xffff2c2c);
}


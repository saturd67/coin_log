import 'package:coin_log/services/DatabaseService.dart';
import 'package:flutter/material.dart';
import 'package:coin_log/views/AppFrame/AppFrame.dart';
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
                primary: Color(0xff00e68e),
                onPrimary: Color(0xffffffff),
                secondary: Color(0xffffffff),
                onSecondary: Color(0xffa0a0a0),
                tertiary: Color(0xffe6e6e6),
                onTertiary: Color(0xffa0a0a0),
                error: Color(0xffff2c2c),
                onError: Color(0xffffffff),
                surface: Color(0xfff0f0f0),
                onSurface: Color(0xffffffff),
            ),
            textTheme: const TextTheme(
                displayLarge: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.normal,
                    color: Color(0xffa8a8a8)
                ),
                displayMedium: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: Color(0xff888888)
                ),
                displaySmall: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff888888)
                ),
                bodyLarge: TextStyle(
                    fontSize: 20,
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
                    fontWeight: FontWeight.bold,
                    color: Color(0xff14181b)
                ),
            ),
            iconTheme: const IconThemeData(
              size: 24,
              color: Color(0xffa0a0a0),
            ),
            inputDecorationTheme: const InputDecorationTheme(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Color(0xffffffff),
              hintStyle: TextStyle(color: Color(0xff888888))
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
            )
        ),
        home: const AppFramePage(),
        routes: {
          '/home': (context) => const AppFramePage()
        });
  }
}

extension CustomColorScheme on ColorScheme {
  Color get success => const Color(0xff249689);
}


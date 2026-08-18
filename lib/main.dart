import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'database/todo_database.dart';
import 'provider/todo_provider.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final database = TodoDatabase();

  await database.init();

  runApp(
    ChangeNotifierProvider(
      create: (_) {
        final provider = TodoProvider();

        provider.loadTodos();

        return provider;
      },

      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TodoProvider>(
      builder: (context, provider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,

          title: 'Todo Provider App',

          themeMode: provider.themeMode,

          // =========================
          // LIGHT THEME
          // =========================

          theme: ThemeData(
            useMaterial3: true,

            brightness: Brightness.light,

            colorScheme:
            ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.light,
            ),

            appBarTheme:
            const AppBarTheme(
              centerTitle: true,
            ),
          ),

          // =========================
          // DARK THEME
          // =========================

          darkTheme: ThemeData(
            useMaterial3: true,

            brightness: Brightness.dark,

            colorScheme:
            ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.dark,
            ),

            appBarTheme:
            const AppBarTheme(
              centerTitle: true,
            ),
          ),

          home: const HomeScreen(),
        );
      },
    );
  }
}
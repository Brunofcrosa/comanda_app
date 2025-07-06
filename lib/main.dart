import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_comandas_app/servicos/database/banco_dados.dart';
import 'package:flutter_comandas_app/pages/login/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await BancoDados.instancia.database;
  await initializeDateFormatting('pt_BR', null);
  runApp(const ComandasApp());
}

class ComandasApp extends StatelessWidget {
  const ComandasApp({super.key});

  static const Color primaryCustomColor = Color(0xFF1976D2);
  static const Color secondaryTextColor = Color(0xFF333333);
  static const Color tertiaryGreyColor = Color.fromARGB(255, 221, 221, 221);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFD32F2F);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App de Comandas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.light().copyWith(
          primary: primaryCustomColor,
          secondary: primaryCustomColor,
          surface: Colors.white,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: secondaryTextColor,
          error: errorColor,
          onError: Colors.white,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryCustomColor,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 4,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryCustomColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(vertical: 15),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            elevation: 5,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: primaryCustomColor),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: primaryCustomColor, width: 2),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: tertiaryGreyColor),
          ),
          prefixIconColor: primaryCustomColor,
          labelStyle: const TextStyle(color: primaryCustomColor),
          hintStyle: const TextStyle(color: tertiaryGreyColor),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: primaryCustomColor,
          foregroundColor: Colors.white,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: primaryCustomColor,
          unselectedItemColor: secondaryTextColor,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
        ),
        textTheme: TextTheme(
          displayLarge: TextStyle(color: secondaryTextColor),
          displayMedium: TextStyle(color: secondaryTextColor),
          displaySmall: TextStyle(color: secondaryTextColor),
          headlineLarge: TextStyle(color: secondaryTextColor),
          headlineMedium: TextStyle(color: secondaryTextColor),
          headlineSmall: TextStyle(color: secondaryTextColor),
          titleLarge: TextStyle(color: secondaryTextColor),
          titleMedium: TextStyle(color: secondaryTextColor),
          titleSmall: TextStyle(color: secondaryTextColor),
          bodyLarge: TextStyle(color: secondaryTextColor),
          bodyMedium: TextStyle(color: secondaryTextColor),
          bodySmall: TextStyle(color: secondaryTextColor),
          labelLarge: TextStyle(color: secondaryTextColor),
          labelMedium: TextStyle(color: secondaryTextColor),
          labelSmall: TextStyle(color: secondaryTextColor),
        ),
      ),
      home: const LoginPage(),
    );
  }
}

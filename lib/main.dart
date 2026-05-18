import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/app_provider.dart';
import 'screens/home_screen.dart';
import 'screens/pacientes_screen.dart';
import 'screens/detalle_paciente_screen.dart';
import 'screens/pila_screen.dart';
import 'screens/cola_screen.dart';
import 'screens/lista_screen.dart';
import 'screens/arbol_screen.dart';
import 'screens/hash_screen.dart';
import 'screens/grafo_screen.dart';
import 'screens/analisis_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: const LaboratorioApp(),
    ),
  );
}

class LaboratorioApp extends StatelessWidget {
  const LaboratorioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Laboratorio Clínico',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0),
          primary: const Color(0xFF1565C0),
          secondary: const Color(0xFF00897B),
          background: const Color(0xFFF5F7FF),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7FF),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/pacientes': (context) => const PacientesScreen(),
        '/detalle-paciente': (context) => const DetallePacienteScreen(),
        '/pila': (context) => const PilaScreen(),
        '/cola': (context) => const ColaScreen(),
        '/lista': (context) => const ListaScreen(),
        '/arbol': (context) => const ArbolScreen(),
        '/hash': (context) => const HashScreen(),
        '/grafo': (context) => const GrafoScreen(),
        '/analisis': (context) => const AnalisisScreen(),
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'screens/home_planner_screen.dart';
import 'services/routing_engine.dart';
import 'services/database_repository.dart';

final getIt = GetIt.instance;
const bool isDemoMode = true;

void setupLocator() {
  if (isDemoMode) {
    getIt.registerLazySingleton<RoutingEngine>(() => MockRoutingEngine());
    getIt.registerLazySingleton<DatabaseRepository>(() => MockDatabaseRepository());
  } else {
    getIt.registerLazySingleton<RoutingEngine>(() => RealRoutingEngine());
    getIt.registerLazySingleton<DatabaseRepository>(() => SupabaseDatabaseRepository());
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Failed to load .env file: $e");
  }
  setupLocator();
  runApp(const TrempApp());
}

class TrempApp extends StatelessWidget {
  const TrempApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'סבתוש - מסלולי טרמפים',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('he', 'IL'),
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E3192)),
        useMaterial3: true,
        textTheme: GoogleFonts.rubikTextTheme(Theme.of(context).textTheme),
      ),
      home: const HomePlannerScreen(),
    );
  }
}

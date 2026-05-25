import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'presentation/system_design/core/app_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'data/services/telemetry_service.dart';
import 'presentation/screens/home_planner_screen.dart';
import 'data/services/routing_engine.dart';
import 'data/repositories/database_repository.dart';

final getIt = GetIt.instance;
const bool isDemoMode = false;

void setupLocator() {
  if (isDemoMode) {
    getIt.registerLazySingleton<RoutingEngine>(() => RealRoutingEngine());
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
    
    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];
    
    if (supabaseUrl != null && supabaseAnonKey != null) {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
    }
  } catch (e) {
    debugPrint("Failed to load .env file or initialize Supabase: $e");
  }
  setupLocator();
  
  final sentryDsn = dotenv.env['SENTRY_DSN'] ?? '';
  if (sentryDsn.isNotEmpty) {
    await TelemetryService.init(() async {
      runApp(const ProviderScope(child: TrempApp()));
    }, sentryDsn);
  } else {
    runApp(const ProviderScope(child: TrempApp()));
  }
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
      theme: AppTheme.lightTheme,
      home: const HomePlannerScreen(),
    );
  }
}

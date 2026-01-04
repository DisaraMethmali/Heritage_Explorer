// lib/main.dart (COMPLETE WITH ALL ROUTES AND PROVIDERS)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/admin_dashboard.dart';
import 'screens/memory_test_screen.dart';
import 'screens/chat_history_screen.dart';
import 'screens/test_history_screen.dart';
import 'screens/preferences_screen.dart';
import 'screens/admin_reports_screen.dart';
import 'screens/main_scaffold.dart';

// Providers
import 'providers/chat_provider.dart';
import 'providers/user_provider.dart';
import 'providers/metrics_provider.dart';
import 'providers/auth_provider.dart';

// Services
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // AuthProvider for authentication
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        // Provide ApiService first
        Provider<ApiService>(create: (_) => ApiService()),

        // ChatProvider requires ApiService, so we inject it
        ChangeNotifierProvider<ChatProvider>(
          create: (context) => ChatProvider(apiService: context.read<ApiService>()),
        ),

        // Other providers
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => MetricsProvider()),
      ],
      child: MaterialApp(
        title: 'Heritage Explorer',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1565C0),
            brightness: Brightness.light,
          ),
          cardTheme: const CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1565C0),
            brightness: Brightness.dark,
          ),
          cardTheme: const CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        ),
        themeMode: ThemeMode.system,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/home': (context) => const HomeScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/admin': (context) => const AdminDashboard(),
          '/memory-test': (context) => const MemoryTestScreen(),
          '/chat-history': (context) => const ChatHistoryScreen(),
          '/test-history': (context) => const TestHistoryScreen(),
          '/preferences': (context) => const PreferencesScreen(),
          '/admin-reports': (context) => const AdminReportsScreen(),
        },
      ),
    );
  }
}

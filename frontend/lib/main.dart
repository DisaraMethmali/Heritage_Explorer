// lib/main.dart (cleaned and fixed)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';

// Admin screens
import 'screens/admin_dashboard.dart';         // ✅ Only import once
import 'screens/admin_reports_screen.dart';   // ✅ Only import once

// Other screens
import 'screens/memory_test_screen.dart';
import 'screens/chat_history_screen.dart';
import 'screens/test_history_screen.dart';
import 'screens/preferences_screen.dart';

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
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        Provider<ApiService>(create: (_) => ApiService()),
        ChangeNotifierProvider<ChatProvider>(
          create: (context) => ChatProvider(apiService: context.read<ApiService>()),
        ),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => MetricsProvider()),
      ],
      child: MaterialApp(
        title: 'Heritage Explorer',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1565C0),
            brightness: Brightness.dark,
          ),
        ),
        themeMode: ThemeMode.system,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/home': (context) => const HomeScreen(),
          '/profile': (context) => ProfileScreen(), // removed const
          '/memory-test': (context) => const MemoryTestScreen(),
          '/chat-history': (context) => const ChatHistoryScreen(),
          '/test-history': (context) => const TestHistoryScreen(),
          '/preferences': (context) => const PreferencesScreen(),
          '/admin': (context) => AdminDashboard(),       // removed const
          '/admin-reports': (context) => AdminReportsScreen(), // removed const
        },
      ),
    );
  }
}

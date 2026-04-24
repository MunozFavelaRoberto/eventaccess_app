import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:eventaccess_app/services/theme_provider.dart';
import 'package:eventaccess_app/services/data_provider.dart';
import 'package:eventaccess_app/services/api_service.dart';
import 'package:eventaccess_app/services/auth_service.dart';
import 'package:eventaccess_app/screens/login_screen.dart';
import 'package:eventaccess_app/screens/home_screen.dart';
import 'package:eventaccess_app/screens/profile_screen.dart';
import 'package:eventaccess_app/screens/event_tickets_screen.dart';
import 'package:eventaccess_app/screens/ticket_detail_screen.dart';
import 'package:eventaccess_app/utils/app_routes.dart';

Future<void> main() async {
  // Para SharedPreferences antes runApp
  WidgetsFlutterBinding.ensureInitialized();
  final themeProvider = ThemeProvider();
  await themeProvider.loadTheme();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<ApiService>(create: (_) => ApiService()),
        ChangeNotifierProvider<DataProvider>(
          create: (context) => DataProvider(
            authService: Provider.of<AuthService>(context, listen: false),
            apiService: Provider.of<ApiService>(context, listen: false),
          ),
        ),
      ],
      child: const EventAccessApp(),
    ),
  );
}

// Nav global para push rutas fuera del árbol
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();
const MethodChannel _screenChannel = MethodChannel(
  'com.example.eventaccess_app/screen',
);

class EventAccessApp extends StatelessWidget {
  const EventAccessApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDark;

    return MaterialApp(
      title: 'Event Access',
      navigatorKey: appNavigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      builder: (context, child) {
        return LockWrapper(child: child ?? const SizedBox.shrink());
      },
      home: const CheckAuthScreen(),
      routes: {
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.home: (context) => const HomeScreen(),
        AppRoutes.profile: (context) => const ProfileScreen(),
        AppRoutes.eventTickets: (context) => const EventTicketsScreen(),
        AppRoutes.ticketDetail: (context) => const TicketDetailScreen(),
      },
    );
  }
}

class LockWrapper extends StatefulWidget {
  final Widget child;
  const LockWrapper({required this.child, super.key});

  @override
  State<LockWrapper> createState() => _LockWrapperState();
}

class _LockWrapperState extends State<LockWrapper> with WidgetsBindingObserver {
  bool _wasPaused = false;
  DateTime? _pausedAt;
  bool _screenWasLocked = false;
  static const Duration _maxIdleForQuickUnlock = Duration(minutes: 5);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _screenChannel.setMethodCallHandler((call) async {
      if (call.method == 'screenEvent') {
        final String event = call.arguments as String? ?? '';
        if (event == 'off') {
          _pausedAt = DateTime.now();
          _wasPaused = true;
          _screenWasLocked = true;
        }
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _wasPaused = true;
      _pausedAt = DateTime.now();
    }

    if (state == AppLifecycleState.resumed) {
      if (_wasPaused) {
        final now = DateTime.now();
        final diff = _pausedAt == null
            ? Duration.zero
            : now.difference(_pausedAt!);
        final longPause = diff > _maxIdleForQuickUnlock;
        if (longPause || _screenWasLocked) {
          _tryLockIfNeeded(true);
        }
        _screenWasLocked = false;
      }
      _wasPaused = false;
    }
  }

  Future<void> _tryLockIfNeeded(bool longPause) async {
    // Biometric check removed
  }

  @override
  Widget build(BuildContext context) {
    // Chequear estado auth
    final dataProvider = context.watch<DataProvider>();

    // Solo mostrar 'No Autorizado' después de:
    // 1. Intento fetch datos usuario (hasAttemptedFetch)
    // 2. Y servidor rechazó explícitamente
    if (dataProvider.hasAttemptedFetch && dataProvider.isUnauthorized) {
      return _buildUnauthorizedScreen(context, dataProvider);
    }

    return widget.child;
  }

  Widget _buildUnauthorizedScreen(
    BuildContext context,
    DataProvider dataProvider,
  ) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Center(
        child: Text(
          'NO AUTORIZADO',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.red.shade700,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}

class CheckAuthScreen extends StatefulWidget {
  const CheckAuthScreen({super.key});

  @override
  State<CheckAuthScreen> createState() => _CheckAuthScreenState();
}

class _CheckAuthScreenState extends State<CheckAuthScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final bool loggedIn = await authService.isLoggedIn();

    if (!mounted) return;

    if (loggedIn) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator(color: Colors.green)),
    );
  }
}

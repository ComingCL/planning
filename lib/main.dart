import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/tasks_page.dart';
import 'pages/calendar_page.dart';
import 'pages/stats_page.dart';
import 'pages/profile_page.dart';
import 'services/auth_api_service.dart';
import 'models/user.dart';
import 'models/login_response.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PlanningApp());
}

enum UserMode {
  local,      // User chose to use app without login
  loggedIn,   // User is authenticated
  undecided   // User hasn't made a choice yet (first launch)
}

class AuthState extends ChangeNotifier {
  final AuthApiService _authApiService = AuthApiService();

  bool _loggedIn = false;
  UserMode _userMode = UserMode.undecided;
  User? _currentUser;

  bool get loggedIn => _loggedIn;
  UserMode get userMode => _userMode;
  bool get hasChosenMode => _userMode != UserMode.undecided;
  bool get isLocalMode => _userMode == UserMode.local;
  bool get isLoggedIn => _userMode == UserMode.loggedIn;
  User? get currentUser => _currentUser;

  AuthState() {
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();

    // Check if user has valid tokens
    final hasValidToken = await _authApiService.isLoggedIn();
    if (hasValidToken) {
      _loggedIn = true;
      _userMode = UserMode.loggedIn;
      _currentUser = await _authApiService.getStoredUser();
    } else {
      // Check for local mode preference
      final modeString = prefs.getString('userMode');
      if (modeString != null) {
        _userMode = UserMode.values.firstWhere(
          (e) => e.toString() == modeString,
          orElse: () => UserMode.undecided,
        );
      }
      _loggedIn = false;
    }

    notifyListeners();
  }

  Future<void> chooseLocalMode() async {
    _userMode = UserMode.local;
    _loggedIn = false;
    _currentUser = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userMode', UserMode.local.toString());
  }

  // Login with LoginResponse from AuthApiService
  Future<void> loginWithResponse(LoginResponse response) async {
    _loggedIn = true;
    _userMode = UserMode.loggedIn;
    _currentUser = response.user;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userMode', UserMode.loggedIn.toString());
  }

  // Legacy login method (for compatibility)
  Future<void> login() async {
    _loggedIn = true;
    _userMode = UserMode.loggedIn;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userMode', UserMode.loggedIn.toString());
  }

  Future<void> logout() async {
    // Call API logout
    await _authApiService.logout();

    _loggedIn = false;
    _userMode = UserMode.undecided;
    _currentUser = null;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userMode', UserMode.undecided.toString());
  }

  // Update user profile
  void updateUser(User user) {
    _currentUser = user;
    notifyListeners();
  }
}

class MainShell extends StatefulWidget {
  final int initialIndex;
  const MainShell({super.key, required this.initialIndex});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _currentIndex;
  final List<Widget> _pages = const [
    HomePage(),
    CalendarPage(),
    StatsPage(),
    ProfilePage(),
  ];

  final List<String> _paths = const [
    '/home',
    '/calendar',
    '/stats',
    '/profile',
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTap(int index) {
    setState(() => _currentIndex = index);
    if (context.mounted) {
      context.go(_paths[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTap,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '首页',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: '日历',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: '统计',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
    );
  }
}

class PlanningApp extends StatelessWidget {
  const PlanningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthState(),
      child: Builder(builder: (context) {
        final auth = context.watch<AuthState>();
        final router = GoRouter(
          initialLocation: auth.hasChosenMode ? '/home' : '/login',
          refreshListenable: auth,
          routes: [
            GoRoute(
              path: '/login',
              builder: (context, state) => LoginPage(
                onLoggedIn: () => auth.login(),
                onLocalMode: () => auth.chooseLocalMode(),
              ),
            ),
            GoRoute(
              path: '/home',
              builder: (context, state) => const MainShell(initialIndex: 0),
            ),
            GoRoute(
              path: '/calendar',
              builder: (context, state) => const MainShell(initialIndex: 1),
            ),
            GoRoute(
              path: '/stats',
              builder: (context, state) => const MainShell(initialIndex: 2),
            ),
            GoRoute(
              path: '/profile',
              builder: (context, state) => const MainShell(initialIndex: 3),
            ),
            GoRoute(
              path: '/tasks',
              builder: (context, state) => const TasksPage(),
            ),
          ],
          redirect: (context, state) {
            final loggingIn = state.matchedLocation == '/login';

            // Allow access if user has chosen a mode (either local or logged in)
            if (auth.hasChosenMode && !loggingIn) {
              return null; // Allow navigation to any page
            }

            // Redirect to login if user hasn't chosen a mode
            if (!auth.hasChosenMode && !loggingIn) {
              return '/login';
            }

            // If already chose a mode and trying to access login, redirect to home
            if (auth.hasChosenMode && loggingIn) {
              return '/home';
            }

            return null;
          },
        );

        return MaterialApp.router(
          title: 'Planning App',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFFF8FAFC),
          ),
          routerConfig: router,
        );
      }),
    );
  }
}
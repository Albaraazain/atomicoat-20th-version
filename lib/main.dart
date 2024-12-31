import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:logger/logger.dart';
import 'core/auth/services/auth_service.dart';
import 'core/services/navigation_service.dart';
import 'core/auth/providers/auth_provider.dart';
import 'core/config/app_config.dart';
import 'core/config/route_config.dart';
import 'core/config/theme_config.dart';
import 'core/config/provider_config.dart';
import 'core/auth/screens/login_screen.dart';
import 'features/dashboard/screens/machine_dashboard_screen.dart';
import 'features/process/providers/process_provider.dart';
import 'features/experiments/providers/experiment_provider.dart';
import 'features/recipes/providers/recipe_provider.dart';
import 'widgets/app_drawer.dart';

final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 5,
    lineLength: 50,
    colors: true,
    printEmojis: true,
    printTime: true,
  ),
);

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  try {
    logger.i('Starting application initialization');
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    final authService = AuthService();
    final navigationService = NavigationService();
    final themeConfig = ThemeConfig();
    final routeConfig = RouteConfig();
    final providerConfig = ProviderConfig();

    final appConfig = AppConfig(
      themeConfig: themeConfig,
      routeConfig: routeConfig,
      providerConfig: providerConfig,
      navigationService: navigationService,
    );

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider(authService)),
          ChangeNotifierProvider(create: (_) => ProcessProvider()),
          ChangeNotifierProvider(create: (_) => ExperimentProvider()),
          ChangeNotifierProvider(create: (_) => RecipeProvider()),
          Provider<AppConfig>.value(value: appConfig),
        ],
        child: MyApp(appConfig: appConfig),
      ),
    );
  } catch (e, stackTrace) {
    logger.e('Failed to initialize application', error: e, stackTrace: stackTrace);
    rethrow;
  }
}

class MyApp extends StatelessWidget {
  final AppConfig appConfig;
  final _logger = logger;

  MyApp({Key? key, required this.appConfig}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ALD Machine Control',
      theme: ThemeConfig.teslaTheme,
      themeMode: ThemeMode.dark,
      navigatorKey: navigatorKey,
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          if (authProvider.isLoading) {
            return _buildLoadingScreen();
          }

          if (authProvider.isAuthenticated) {
            if (!authProvider.isApproved()) {
              return _buildPendingApprovalScreen();
            }
            return _buildAuthenticatedScreen();
          } else {
            return LoginScreen();
          }
        },
      ),
      routes: RouteConfig.routes,
      onGenerateRoute: RouteConfig.generateRoute,
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildAuthenticatedScreen() {
    return Scaffold(
      appBar: AppBar(
        title: Text('ALD Control System'),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // TODO: Show notifications
            },
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // TODO: Show settings
            },
          ),
        ],
      ),
      body: MachineDashboard(),
      drawer: AppDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          navigatorKey.currentState?.pushNamed(RouteConfig.processMonitoringRoute);
        },
        child: Icon(Icons.play_arrow),
        tooltip: 'Start New Process',
      ),
    );
  }

  Widget _buildPendingApprovalScreen() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.hourglass_empty, size: 64, color: Colors.orange),
            SizedBox(height: 16),
            Text(
              'Pending Approval',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Your account is pending administrator approval.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final authProvider = Provider.of<AuthProvider>(
                  navigatorKey.currentContext!,
                  listen: false,
                );
                await authProvider.signOut();
              },
              child: Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'core/util/app_theme.dart';
import 'features/auth/presentation/bloc/auth_provider.dart';
import 'features/auth/presentation/pages/pin_login_page.dart';
import 'features/auth/presentation/pages/pin_setup_page.dart';
import 'features/notes/data/models/note_model_adapter.dart';
import 'features/notes/presentation/bloc/notes_provider.dart';
import 'features/notes/presentation/pages/notes_list_page.dart';
import 'app/di/injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register adapters
  if (!Hive.isAdapterRegistered(0)) {
    // Using 0 as the typeId for NoteModel
    Hive.registerAdapter(NoteModelAdapter());
  }

  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => di.sl<AuthProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<NotesProvider>()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp(
            title: 'Secure Notes',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode:
                authProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Defer auth check to didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      // Use Future.microtask to avoid calling setState during build
      Future.microtask(() {
        if (mounted) {
          Provider.of<AuthProvider>(context, listen: false).checkAuthStatus();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    switch (authProvider.status) {
      case AuthStatus.authenticated:
        return const NotesListPage();
      case AuthStatus.unauthenticated:
        return const PinLoginPage();
      case AuthStatus.firstLaunch:
        return const PinSetupPage();
      case AuthStatus.loading:
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      case AuthStatus.error:
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 60),
                const SizedBox(height: 16),
                Text(
                  'Error: ${authProvider.errorMessage}',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    authProvider.checkAuthStatus();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      default:
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/auth_provider.dart';
import 'providers/property_provider.dart';
import 'providers/message_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/location_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/notification_provider.dart';

// Écrans
import 'screens/home/home_screen.dart';
import 'screens/search/search_screen.dart';
import 'screens/favorites/favorites_screen.dart';
import 'screens/property/property_detail_screen.dart';
import 'screens/messages/chat_screen.dart';
import 'screens/messages/conversations_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/map/improved_map_screen.dart';
import 'screens/property/add_property_screen.dart';
import 'screens/onboarding/language_selection_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/profile/edit_profile_screen.dart';
import 'screens/profile/my_properties_screen.dart';
import 'screens/help/help_screen.dart';

void main() {
  runApp(const ImmobilierApp());
}

class ImmobilierApp extends StatelessWidget {
  const ImmobilierApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PropertyProvider()),
        ChangeNotifierProvider(create: (_) => MessageProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProvider, localeProvider, child) {
          return MaterialApp(
            title: 'Immobilier App',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.themeMode,
            locale: localeProvider.locale,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', 'US'),
              Locale('fr', 'FR'),
              Locale('ar', 'SA'),
              Locale('it', 'IT'),
              Locale('de', 'DE'),
              Locale('es', 'ES'),
              Locale('pt', 'PT'),
            ],
            home: const AppInitializer(),
            routes: {
              '/home': (ctx) => const HomeScreen(),
              '/onboarding': (ctx) => const LanguageSelectionScreen(),
              '/search': (ctx) => const SearchScreen(),
              '/favorites': (ctx) => const FavoritesScreen(),
              '/profile': (ctx) => const ProfileScreen(),
              '/settings': (ctx) => const SettingsScreen(),
              '/edit-profile': (ctx) => const EditProfileScreen(),
              '/map': (ctx) => const ImprovedMapScreen(),
              '/add-property': (ctx) => const AddPropertyScreen(),
              '/conversations': (ctx) => const ConversationsScreen(),
              '/my-properties': (ctx) => const MyPropertiesScreen(),
              '/help': (ctx) => const HelpScreen(),
            },
            onGenerateRoute: (settings) {
              if (settings.name == '/property-detail') {
                final id = settings.arguments as String?;
                return MaterialPageRoute(
                  builder: (ctx) => PropertyDetailScreen(propertyId: id ?? ''),
                );
              }

              if (settings.name == '/chat') {
                final args = settings.arguments as Map<String, dynamic>?;
                if (args != null) {
                  return MaterialPageRoute(
                    builder: (ctx) => ChatScreen(
                      userId: args['userId'] as String,
                      userName: args['userName'] as String,
                      userAvatar: args['userAvatar'] as String?,
                    ),
                  );
                }
              }

              return null;
            },
          );
        },
      ),
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({Key? key}) : super(key: key);

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      setState(() {
        _hasError = false;
        _errorMessage = '';
      });

      // 1. Initialize auth provider first (this loads the token from storage)
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.initialize();

      // 2. Initialize property provider
      final propertyProvider =
          Provider.of<PropertyProvider>(context, listen: false);
      await propertyProvider.initialize();

      // 3. Initialize message provider
      final messageProvider =
          Provider.of<MessageProvider>(context, listen: false);
      await messageProvider.initialize();

      if (!mounted) return;

      // 4. Check authentication status
      if (authProvider.isAuthenticated) {
        // User is logged in, go to home
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        // Not authenticated, check if onboarding was completed
        final prefs = await SharedPreferences.getInstance();
        final onboardingComplete =
            prefs.getBool('onboarding_complete') ?? false;

        if (mounted) {
          if (onboardingComplete) {
            Navigator.of(context).pushReplacementNamed('/home');
          } else {
            Navigator.of(context).pushReplacementNamed('/onboarding');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Erreur d\'initialisation: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _initialize,
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              SizedBox(height: 24),
              Text(
                'Initialisation...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/property_provider.dart';
import 'providers/message_provider.dart';

// Écrans
import 'screens/home/home_screen.dart';
import 'screens/search/search_screen.dart';
import 'screens/favorites/favorites_screen.dart';
import 'screens/property/property_detail_screen.dart';
import 'screens/messages/chat_screen.dart';
import 'screens/messages/conversations_screen.dart'; // ✅ Ajouté
import 'screens/profile/profile_screen.dart';
import 'screens/map/map_screen.dart';
import 'screens/property/add_property_screen.dart';

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
      ],
      child: MaterialApp(
        title: 'Immobilier App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (ctx) => const HomeScreen(),
          '/search': (ctx) => const SearchScreen(),
          '/favorites': (ctx) => const FavoritesScreen(),
          '/profile': (ctx) => const ProfileScreen(),
          '/map': (ctx) => const MapScreen(),
          '/add-property': (ctx) => const AddPropertyScreen(),
          '/conversations': (ctx) => const ConversationsScreen(), // ✅ Ajouté
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
      ),
    );
  }
}

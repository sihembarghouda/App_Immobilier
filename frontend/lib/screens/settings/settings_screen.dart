import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../about/about_developers_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedLanguage = 'fr';
  bool _notifyNewProperties = true;
  bool _notifyMessages = true;
  bool _notifyFavorites = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('language') ?? 'fr';
      _notifyNewProperties = prefs.getBool('notify_properties') ?? true;
      _notifyMessages = prefs.getBool('notify_messages') ?? true;
      _notifyFavorites = prefs.getBool('notify_favorites') ?? false;
    });
  }

  Future<void> _saveToggle(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _changeLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);
    setState(() {
      _selectedLanguage = lang;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(lang == 'fr'
              ? 'Langue changée en Français'
              : 'Language changed to English'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          // Appearance Section
          _buildSectionHeader('Apparence'),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return Column(
                children: [
                  RadioListTile<ThemeMode>(
                    title: const Text('Clair'),
                    subtitle: const Text('Thème lumineux'),
                    value: ThemeMode.light,
                    groupValue: themeProvider.themeMode,
                    secondary: const Icon(Icons.light_mode),
                    onChanged: (value) {
                      if (value != null) {
                        themeProvider.setThemeMode(value);
                      }
                    },
                  ),
                  RadioListTile<ThemeMode>(
                    title: const Text('Sombre'),
                    subtitle: const Text('Thème sombre'),
                    value: ThemeMode.dark,
                    groupValue: themeProvider.themeMode,
                    secondary: const Icon(Icons.dark_mode),
                    onChanged: (value) {
                      if (value != null) {
                        themeProvider.setThemeMode(value);
                      }
                    },
                  ),
                  RadioListTile<ThemeMode>(
                    title: const Text('Système'),
                    subtitle: const Text('Suivre les paramètres du système'),
                    value: ThemeMode.system,
                    groupValue: themeProvider.themeMode,
                    secondary: const Icon(Icons.settings_brightness),
                    onChanged: (value) {
                      if (value != null) {
                        themeProvider.setThemeMode(value);
                      }
                    },
                  ),
                ],
              );
            },
          ),

          const Divider(height: 32),

          // Language Section
          _buildSectionHeader('Langue'),
          RadioListTile<String>(
            title: const Text('Français'),
            subtitle: const Text('French'),
            value: 'fr',
            groupValue: _selectedLanguage,
            secondary: const Text('🇫🇷', style: TextStyle(fontSize: 24)),
            onChanged: (value) {
              if (value != null) {
                _changeLanguage(value);
              }
            },
          ),
          RadioListTile<String>(
            title: const Text('English'),
            subtitle: const Text('Anglais'),
            value: 'en',
            groupValue: _selectedLanguage,
            secondary: const Text('🇬🇧', style: TextStyle(fontSize: 24)),
            onChanged: (value) {
              if (value != null) {
                _changeLanguage(value);
              }
            },
          ),

          const Divider(height: 32),

          // Notifications Section
          _buildSectionHeader('Notifications'),
          SwitchListTile(
            title: const Text('Nouvelles propriétés'),
            subtitle: const Text(
                'Recevoir des notifications pour les nouvelles annonces'),
            secondary: const Icon(Icons.home_work),
            value: _notifyNewProperties,
            onChanged: (value) {
              setState(() => _notifyNewProperties = value);
              _saveToggle('notify_properties', value);
            },
          ),
          SwitchListTile(
            title: const Text('Messages'),
            subtitle: const Text(
                'Recevoir des notifications pour les nouveaux messages'),
            secondary: const Icon(Icons.message),
            value: _notifyMessages,
            onChanged: (value) {
              setState(() => _notifyMessages = value);
              _saveToggle('notify_messages', value);
            },
          ),
          SwitchListTile(
            title: const Text('Favoris'),
            subtitle: const Text(
                'Recevoir des notifications pour les changements de prix'),
            secondary: const Icon(Icons.favorite),
            value: _notifyFavorites,
            onChanged: (value) {
              setState(() => _notifyFavorites = value);
              _saveToggle('notify_favorites', value);
            },
          ),

          const Divider(height: 32),

          // Account Section
          _buildSectionHeader('Compte'),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Confidentialité'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fonctionnalité bientôt disponible'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Sécurité'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fonctionnalité bientôt disponible'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),

          const Divider(height: 32),

          // About Section
          _buildSectionHeader('À propos'),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Version'),
            subtitle: const Text('1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.group),
            title: const Text('L\'équipe de développement'),
            subtitle: const Text('Développé par 5 développeurs'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AboutDevelopersScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Conditions d\'utilisation'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fonctionnalité bientôt disponible'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Aide et support'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fonctionnalité bientôt disponible'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),

          const SizedBox(height: 32),

          // Logout Button
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                if (!authProvider.isAuthenticated) {
                  return const SizedBox.shrink();
                }

                return ElevatedButton.icon(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Déconnexion'),
                        content: const Text(
                            'Voulez-vous vraiment vous déconnecter ?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Annuler'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text('Déconnexion'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true && mounted) {
                      authProvider.logout();
                      Navigator.of(context).pushReplacementNamed('/home');
                    }
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Se déconnecter'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).primaryColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

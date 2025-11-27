import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../providers/locale_provider.dart';
import '../../utils/translations.dart';
import 'country_selection_screen.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({Key? key}) : super(key: key);

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String _selectedLanguage = 'Français';

  final Map<String, Map<String, String>> _languages = {
    'Français': {'code': 'fr', 'country': 'FR'},
    'English': {'code': 'en', 'country': 'US'},
    'Italiano': {'code': 'it', 'country': 'IT'},
    'Deutsch': {'code': 'de', 'country': 'DE'},
    'Español': {'code': 'es', 'country': 'ES'},
    'Português': {'code': 'pt', 'country': 'PT'},
    'العربية': {'code': 'ar', 'country': 'SA'},
  };

  Future<void> _continue() async {
    final langInfo = _languages[_selectedLanguage]!;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', langInfo['code']!);

    // Update locale provider
    if (mounted) {
      final localeProvider =
          Provider.of<LocaleProvider>(context, listen: false);
      await localeProvider
          .setLocale(Locale(langInfo['code']!, langInfo['country']));

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const CountrySelectionScreen()),
      );
    }
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'select_language'.tr(context),
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ..._languages.keys.map((language) => ListTile(
                    title: Text(language),
                    trailing: _selectedLanguage == language
                        ? const Icon(Icons.check, color: Colors.blue)
                        : null,
                    onTap: () async {
                      setState(() => _selectedLanguage = language);
                      // Update locale immediately
                      final langInfo = _languages[language]!;
                      final localeProvider =
                          Provider.of<LocaleProvider>(context, listen: false);
                      await localeProvider.setLocale(
                          Locale(langInfo['code']!, langInfo['country']));
                      Navigator.pop(dialogContext);
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      const SizedBox(height: 60),
                      Container(
                        height: 180,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF2E7D32).withOpacity(0.3),
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.villa,
                                    size: 60, color: Colors.white),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'HomeFinder',
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.5,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 10,
                                      color: Colors.black26,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Find Your Dream Home',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.9),
                                  fontWeight: FontWeight.w300,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 50),
                      Text(
                        'welcome_message'.tr(context),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'select_language_message'.tr(context),
                        textAlign: TextAlign.center,
                        style:
                            const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 40),
                      InkWell(
                        onTap: _showLanguageDialog,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'language'.tr(context),
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.black54),
                              ),
                              Text(
                                _selectedLanguage,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _continue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'continue'.tr(context),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

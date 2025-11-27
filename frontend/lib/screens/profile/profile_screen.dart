import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import '../../providers/auth_provider.dart';
import '../../screens/services/api_service.dart';
import '../../utils/translations.dart';
import '../../utils/role_helper.dart';
import '../../widgets/role_protected_widget.dart';
import './settings_pages.dart';
import '../about/about_developers_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _showLoginForm = true; // true = login, false = register
  final ImagePicker _picker = ImagePicker();
  final ApiService _apiService = ApiService();

  Future<void> _pickImage(AuthProvider authProvider) async {
    try {
      print('📸 Starting image picker...');
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 40,
      );

      if (image != null && mounted) {
        print('✅ Image selected: ${image.path}');

        // Show loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Téléchargement de la photo...'),
            duration: Duration(seconds: 10),
          ),
        );

        try {
          // Upload image to server
          print('⬆️  Uploading image...');
          String imageUrl;

          if (kIsWeb) {
            // For web, convert to base64
            final bytes = await image.readAsBytes();
            final base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';
            imageUrl = await _apiService.uploadImage(base64Image);
          } else {
            // For mobile, use file path
            imageUrl = await _apiService.uploadImage(image.path);
          }

          print('✅ Image uploaded: $imageUrl');

          // Update user profile with new avatar
          print('💾 Updating profile...');
          final success = await authProvider.updateProfile(
            authProvider.user!.name,
            authProvider.user!.phone ?? '',
            avatar: imageUrl,
          );

          if (mounted) {
            ScaffoldMessenger.of(context).clearSnackBars();
            if (success) {
              print('✅ Profile updated successfully');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Photo mise à jour avec succès!'),
                  backgroundColor: Colors.green,
                ),
              );
            } else {
              print('❌ Profile update failed: ${authProvider.error}');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(authProvider.error ?? 'Erreur de mise à jour'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        } catch (uploadError) {
          print('❌ Upload/Update error: $uploadError');
          if (mounted) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erreur: ${uploadError.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        print('❌ No image selected');
      }
    } catch (e) {
      print('❌ Image picker error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Si l'utilisateur n'est pas connecté, afficher le formulaire
        if (!authProvider.isAuthenticated || authProvider.user == null) {
          return Scaffold(
            appBar: AppBar(
              title: Text(_showLoginForm
                  ? 'login'.tr(context)
                  : 'register'.tr(context)),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: _showLoginForm
                    ? _buildLoginForm(authProvider)
                    : _buildRegisterForm(authProvider),
              ),
            ),
          );
        }

        // Si l'utilisateur est connecté, afficher le profil
        final user = authProvider.user!;

        return Scaffold(
          appBar: AppBar(title: const Text('Mon Profil')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              GestureDetector(
                onTap: () => _pickImage(authProvider),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    _buildAvatar(context, user),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                user.name,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                user.email,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 12),
              // Role Badge
              Center(
                child: RoleBadge(
                  role: user.role,
                  showLabel: true,
                ),
              ),
              const SizedBox(height: 32),

              // Profile Options Section
              _buildSectionTitle(context, 'Mon Compte'),
              _buildMenuTile(
                context,
                icon: Icons.person_outline,
                title: 'Modifier le profil',
                subtitle: 'Nom, téléphone, photo',
                onTap: () {
                  Navigator.of(context).pushNamed('/edit-profile');
                },
              ),
              // Role change option removed as per requirement
              _buildMenuTile(
                context,
                icon: Icons.home_work_outlined,
                title: 'Mes annonces',
                subtitle: 'Gérer mes propriétés',
                onTap: () {
                  Navigator.of(context).pushNamed('/my-properties');
                },
              ),

              const SizedBox(height: 16),
              _buildSectionTitle(context, 'Paramètres'),
              _buildMenuTile(
                context,
                icon: Icons.lock_outline,
                title: 'Confidentialité',
                subtitle: 'Politique de confidentialité',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PrivacyPolicyScreen(),
                    ),
                  );
                },
              ),
              _buildMenuTile(
                context,
                icon: Icons.security,
                title: 'Sécurité',
                subtitle: 'Mot de passe et sécurité',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SecurityScreen(),
                    ),
                  );
                },
              ),
              _buildMenuTile(
                context,
                icon: Icons.description_outlined,
                title: 'Conditions d\'utilisation',
                subtitle: 'Termes et conditions',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TermsScreen(),
                    ),
                  );
                },
              ),
              _buildMenuTile(
                context,
                icon: Icons.help_outline,
                title: 'Aide et Support',
                subtitle: 'FAQ et contact',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HelpSupportScreen(),
                    ),
                  );
                },
              ),
              _buildMenuTile(
                context,
                icon: Icons.group,
                title: 'L\'équipe de développement',
                subtitle: 'Développé par 5 développeurs',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AboutDevelopersScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Déconnexion'),
                      content:
                          const Text('Voulez-vous vraiment vous déconnecter ?'),
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
                          child: const Text('Déconnecter'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true && context.mounted) {
                    await authProvider.logout();
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text('Se déconnecter'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Formulaire de connexion
  Widget _buildLoginForm(AuthProvider authProvider) {
    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    bool obscurePassword = true;

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 40),
          Icon(
            Icons.home_work,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Bienvenue !',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Connectez-vous pour continuer',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 40),

          // Email
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre email';
              }
              if (!value.contains('@')) {
                return 'Email invalide';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Password
          StatefulBuilder(
            builder: (context, setState) => TextFormField(
              controller: passwordController,
              obscureText: obscurePassword,
              decoration: InputDecoration(
                labelText: 'Mot de passe',
                prefixIcon: const Icon(Icons.lock_outlined),
                suffixIcon: IconButton(
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () {
                    setState(() {
                      obscurePassword = !obscurePassword;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer votre mot de passe';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 24),

          // Login Button
          ElevatedButton(
            onPressed: authProvider.isLoading
                ? null
                : () async {
                    if (formKey.currentState!.validate()) {
                      final success = await authProvider.login(
                        emailController.text.trim(),
                        passwordController.text,
                      );

                      if (!success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Email ou mot de passe incorrect'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: authProvider.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Se connecter',
                    style: TextStyle(fontSize: 16),
                  ),
          ),
          const SizedBox(height: 16),

          // Register Link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Pas de compte ?',
                style: TextStyle(color: Colors.grey[600]),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _showLoginForm = false;
                  });
                },
                child: const Text('Inscrivez-vous'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Formulaire d'inscription
  Widget _buildRegisterForm(AuthProvider authProvider) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool obscurePassword = true;
    bool obscureConfirmPassword = true;
    String selectedRole = UserRole.visiteur; // Default role

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          Text(
            'Créer un compte',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Rejoignez-nous dès maintenant',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),

          // Role Selection
          StatefulBuilder(
            builder: (context, setState) => Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Je suis un:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildRoleCard(
                          icon: Icons.search,
                          title: 'Visiteur',
                          description: 'Explorer les propriétés',
                          value: UserRole.visiteur,
                          selectedRole: selectedRole,
                          onTap: () =>
                              setState(() => selectedRole = UserRole.visiteur),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildRoleCard(
                          icon: Icons.shopping_cart,
                          title: 'Acheteur',
                          description: 'Chercher à acheter/louer',
                          value: UserRole.acheteur,
                          selectedRole: selectedRole,
                          onTap: () =>
                              setState(() => selectedRole = UserRole.acheteur),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: SizedBox(
                      width: double.infinity,
                      child: _buildRoleCard(
                        icon: Icons.sell,
                        title: 'Vendeur',
                        description: 'Publier des annonces',
                        value: UserRole.vendeur,
                        selectedRole: selectedRole,
                        onTap: () =>
                            setState(() => selectedRole = UserRole.vendeur),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Name
          TextFormField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'Nom complet',
              prefixIcon: const Icon(Icons.person_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre nom';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Email
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre email';
              }
              if (!value.contains('@')) {
                return 'Email invalide';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Phone (optional)
          TextFormField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Téléphone (optionnel)',
              prefixIcon: const Icon(Icons.phone_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Password
          StatefulBuilder(
            builder: (context, setState) => TextFormField(
              controller: passwordController,
              obscureText: obscurePassword,
              decoration: InputDecoration(
                labelText: 'Mot de passe',
                prefixIcon: const Icon(Icons.lock_outlined),
                suffixIcon: IconButton(
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () {
                    setState(() {
                      obscurePassword = !obscurePassword;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer un mot de passe';
                }
                if (value.length < 6) {
                  return 'Le mot de passe doit contenir au moins 6 caractères';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),

          // Confirm Password
          StatefulBuilder(
            builder: (context, setState) => TextFormField(
              controller: confirmPasswordController,
              obscureText: obscureConfirmPassword,
              decoration: InputDecoration(
                labelText: 'Confirmer le mot de passe',
                prefixIcon: const Icon(Icons.lock_outlined),
                suffixIcon: IconButton(
                  icon: Icon(
                    obscureConfirmPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () {
                    setState(() {
                      obscureConfirmPassword = !obscureConfirmPassword;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez confirmer votre mot de passe';
                }
                if (value != passwordController.text) {
                  return 'Les mots de passe ne correspondent pas';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 24),

          // Register Button
          ElevatedButton(
            onPressed: authProvider.isLoading
                ? null
                : () async {
                    if (formKey.currentState!.validate()) {
                      final success = await authProvider.register(
                        nameController.text.trim(),
                        emailController.text.trim(),
                        passwordController.text,
                        selectedRole,
                        phone: phoneController.text.trim().isNotEmpty
                            ? phoneController.text.trim()
                            : null,
                      );

                      if (!success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(authProvider.error ??
                                'Erreur lors de l\'inscription'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: authProvider.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'S\'inscrire',
                    style: TextStyle(fontSize: 16),
                  ),
          ),
          const SizedBox(height: 16),

          // Login Link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Déjà un compte ?',
                style: TextStyle(color: Colors.grey[600]),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _showLoginForm = true;
                  });
                },
                child: const Text('Connectez-vous'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard({
    required IconData icon,
    required String title,
    required String description,
    required String value,
    required String selectedRole,
    required VoidCallback onTap,
  }) {
    final isSelected = selectedRole == value;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.shade600,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(height: 8),
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
      ),
    );
  }

  Widget _buildMenuTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).primaryColor,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, user) {
    final hasAvatar = user.avatar != null && user.avatar!.isNotEmpty;

    return CircleAvatar(
      radius: 50,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      backgroundImage: hasAvatar ? NetworkImage(user.avatar!) : null,
      onBackgroundImageError: hasAvatar
          ? (exception, stackTrace) {
              print('❌ Error loading avatar: $exception');
            }
          : null,
      child: !hasAvatar
          ? Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            )
          : null,
    );
  }
}

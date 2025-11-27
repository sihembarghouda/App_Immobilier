import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

// Privacy Policy Screen
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confidentialité'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              context,
              title: '1. Collecte des données',
              content:
                  'Nous collectons les informations que vous nous fournissez lors de l\'inscription, notamment votre nom, email, et numéro de téléphone. Ces données sont essentielles pour vous fournir nos services.',
            ),
            _buildSection(
              context,
              title: '2. Utilisation des données',
              content:
                  'Vos données personnelles sont utilisées pour:\n• Gérer votre compte utilisateur\n• Vous permettre de publier et consulter des annonces immobilières\n• Faciliter la communication entre acheteurs et vendeurs\n• Améliorer nos services',
            ),
            _buildSection(
              context,
              title: '3. Protection des données',
              content:
                  'Nous mettons en œuvre des mesures de sécurité techniques et organisationnelles appropriées pour protéger vos données personnelles contre tout accès, modification, divulgation ou destruction non autorisés.',
            ),
            _buildSection(
              context,
              title: '4. Partage des données',
              content:
                  'Nous ne vendons, ne louons ni ne partageons vos informations personnelles avec des tiers, sauf dans les cas suivants:\n• Avec votre consentement explicite\n• Pour respecter des obligations légales\n• Pour protéger nos droits et notre sécurité',
            ),
            _buildSection(
              context,
              title: '5. Vos droits',
              content:
                  'Vous avez le droit de:\n• Accéder à vos données personnelles\n• Rectifier vos données\n• Supprimer votre compte\n• Retirer votre consentement à tout moment\n\nPour exercer ces droits, contactez-nous via la section "Aide et Support".',
            ),
            _buildSection(
              context,
              title: '6. Cookies',
              content:
                  'Nous utilisons des cookies pour améliorer votre expérience utilisateur et analyser l\'utilisation de notre plateforme.',
            ),
            _buildSection(
              context,
              title: '7. Modifications',
              content:
                  'Nous pouvons mettre à jour cette politique de confidentialité. Les modifications seront publiées sur cette page avec une date de mise à jour.',
            ),
            const SizedBox(height: 16),
            Text(
              'Dernière mise à jour: ${DateTime.now().toString().split(' ')[0]}',
              style: TextStyle(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context,
      {required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.6,
                ),
          ),
        ],
      ),
    );
  }
}

// Security Screen
class SecurityScreen extends StatelessWidget {
  const SecurityScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sécurité'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildInfoCard(
            context,
            icon: Icons.lock_outline,
            title: 'Sécurité du compte',
            description:
                'Votre compte est protégé par un mot de passe crypté. Nous vous recommandons d\'utiliser un mot de passe fort et unique.',
          ),
          _buildSecurityOption(
            context,
            icon: Icons.key,
            title: 'Changer le mot de passe',
            subtitle: 'Mettez à jour votre mot de passe régulièrement',
            onTap: () {
              _showChangePasswordDialog(context);
            },
          ),
          _buildSecurityOption(
            context,
            icon: Icons.verified_user,
            title: 'Authentification à deux facteurs',
            subtitle: 'Bientôt disponible',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fonctionnalité bientôt disponible'),
                ),
              );
            },
            trailing: const Chip(
              label: Text('Bientôt', style: TextStyle(fontSize: 10)),
              backgroundColor: Colors.orange,
              labelStyle: TextStyle(color: Colors.white),
            ),
          ),
          _buildSecurityOption(
            context,
            icon: Icons.devices,
            title: 'Appareils connectés',
            subtitle: 'Gérer les sessions actives',
            onTap: () {
              _showDevicesDialog(context);
            },
          ),
          _buildInfoCard(
            context,
            icon: Icons.shield,
            title: 'Nos mesures de sécurité',
            description:
                '• Cryptage des données sensibles\n• Connexions HTTPS sécurisées\n• Surveillance continue de la sécurité\n• Mises à jour régulières de sécurité',
          ),
          _buildSecurityOption(
            context,
            icon: Icons.delete_forever,
            title: 'Supprimer le compte',
            subtitle: 'Suppression définitive de toutes vos données',
            isDestructive: true,
            onTap: () {
              _showDeleteAccountDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context,
      {required IconData icon,
      required String title,
      required String description}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.blue[700], size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.blue[900],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.blue[800],
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
    bool isDestructive = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? Colors.red : Theme.of(context).primaryColor,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDestructive ? Colors.red : null,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: trailing ?? const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Changer le mot de passe'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Ancien mot de passe',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Nouveau mot de passe',
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirmer le mot de passe',
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement password change
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fonctionnalité bientôt disponible'),
                ),
              );
            },
            child: const Text('Changer'),
          ),
        ],
      ),
    );
  }

  void _showDevicesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Appareils connectés'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.computer),
              title: const Text('Appareil actuel'),
              subtitle: Text(
                  'Dernière activité: ${DateTime.now().toString().split(' ')[0]}'),
              trailing: const Chip(
                label: Text('Actif', style: TextStyle(fontSize: 10)),
                backgroundColor: Colors.green,
                labelStyle: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le compte'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer définitivement votre compte? Cette action est irréversible et toutes vos données seront perdues.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              try {
                // Call delete account API
                final authProvider =
                    Provider.of<AuthProvider>(context, listen: false);
                final response = await authProvider.deleteAccount();

                if (response) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Compte supprimé avec succès'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  // Logout and navigate to login
                  await authProvider.logout();
                  Navigator.of(context).pushReplacementNamed('/login');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Erreur lors de la suppression du compte'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erreur: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}

// Terms and Conditions Screen
class TermsScreen extends StatelessWidget {
  const TermsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conditions d\'utilisation'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Conditions Générales d\'Utilisation',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            _buildTerm(
              context,
              number: '1',
              title: 'Acceptation des conditions',
              content:
                  'En utilisant cette plateforme, vous acceptez d\'être lié par les présentes conditions d\'utilisation. Si vous n\'acceptez pas ces conditions, veuillez ne pas utiliser nos services.',
            ),
            _buildTerm(
              context,
              number: '2',
              title: 'Description des services',
              content:
                  'Notre plateforme permet aux utilisateurs de publier, rechercher et consulter des annonces immobilières. Nous facilitons la communication entre acheteurs, vendeurs et locataires.',
            ),
            _buildTerm(
              context,
              number: '3',
              title: 'Inscription et compte',
              content:
                  'Vous devez créer un compte pour utiliser certaines fonctionnalités. Vous êtes responsable de maintenir la confidentialité de votre mot de passe et de toutes les activités sur votre compte.',
            ),
            _buildTerm(
              context,
              number: '4',
              title: 'Contenu utilisateur',
              content:
                  'Vous êtes entièrement responsable du contenu que vous publiez. Vous garantissez que:\n• Vous détenez les droits sur le contenu publié\n• Le contenu est exact et non trompeur\n• Le contenu respecte les lois en vigueur\n• Le contenu ne porte pas atteinte aux droits de tiers',
            ),
            _buildTerm(
              context,
              number: '5',
              title: 'Interdictions',
              content:
                  'Il est interdit de:\n• Publier de fausses annonces\n• Harceler ou menacer d\'autres utilisateurs\n• Utiliser la plateforme à des fins illégales\n• Tenter de contourner les mesures de sécurité\n• Collecter des données sans autorisation',
            ),
            _buildTerm(
              context,
              number: '6',
              title: 'Propriété intellectuelle',
              content:
                  'Tous les droits de propriété intellectuelle sur la plateforme appartiennent à nous ou à nos concédants de licence. Vous ne pouvez pas copier, modifier ou distribuer notre contenu sans autorisation.',
            ),
            _buildTerm(
              context,
              number: '7',
              title: 'Limitation de responsabilité',
              content:
                  'Nous ne sommes pas responsables des transactions entre utilisateurs. Nous ne garantissons pas l\'exactitude des annonces. Les utilisateurs doivent faire preuve de diligence raisonnable.',
            ),
            _buildTerm(
              context,
              number: '8',
              title: 'Résiliation',
              content:
                  'Nous nous réservons le droit de suspendre ou de résilier votre compte en cas de violation des présentes conditions.',
            ),
            _buildTerm(
              context,
              number: '9',
              title: 'Modifications',
              content:
                  'Nous pouvons modifier ces conditions à tout moment. Les modifications prendront effet dès leur publication sur la plateforme.',
            ),
            _buildTerm(
              context,
              number: '10',
              title: 'Contact',
              content:
                  'Pour toute question concernant ces conditions, veuillez nous contacter via la section "Aide et Support".',
            ),
            const SizedBox(height: 24),
            Text(
              'Dernière mise à jour: ${DateTime.now().toString().split(' ')[0]}',
              style: TextStyle(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTerm(BuildContext context,
      {required String number,
      required String title,
      required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  number,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      content,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            height: 1.6,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Help and Support Screen
class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aide et Support'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(
                    Icons.help_outline,
                    size: 64,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Comment pouvons-nous vous aider?',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Questions Fréquentes',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          _buildFAQItem(
            context,
            question: 'Comment publier une annonce?',
            answer:
                'Pour publier une annonce, connectez-vous avec un compte vendeur, puis accédez à l\'onglet "Publier". Remplissez le formulaire avec les détails de votre propriété et soumettez.',
          ),
          _buildFAQItem(
            context,
            question: 'Comment contacter un vendeur?',
            answer:
                'Cliquez sur le bouton "Contacter" dans le détail d\'une propriété. Cela ouvrira une conversation avec le propriétaire dans l\'onglet Messages.',
          ),
          _buildFAQItem(
            context,
            question: 'Comment modifier mon profil?',
            answer:
                'Accédez à l\'onglet Profil, puis cliquez sur "Modifier le profil". Vous pouvez modifier votre nom, téléphone et photo de profil.',
          ),
          _buildFAQItem(
            context,
            question: 'Comment ajouter une propriété aux favoris?',
            answer:
                'Cliquez sur l\'icône cœur sur une propriété pour l\'ajouter à vos favoris. Vous pouvez retrouver vos favoris dans l\'onglet dédié.',
          ),
          const SizedBox(height: 24),
          Text(
            'Nous Contacter',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          _buildContactOption(
            context,
            icon: Icons.email,
            title: 'Email',
            value: 'rayenchraiet2000@gmail.com',
            onTap: () {
              // TODO: Open email client
            },
          ),
          _buildContactOption(
            context,
            icon: Icons.phone,
            title: 'Téléphone',
            value: '+216 94599198',
            onTap: () {
              // TODO: Open phone dialer
            },
          ),
          _buildContactOption(
            context,
            icon: Icons.chat_bubble_outline,
            title: 'Chat en direct',
            value: 'Disponible 9h-18h',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fonctionnalité bientôt disponible'),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Card(
            color: Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(Icons.feedback_outlined,
                      color: Colors.blue[700], size: 32),
                  const SizedBox(height: 12),
                  Text(
                    'Envoyez-nous vos commentaires',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Votre avis compte! Aidez-nous à améliorer l\'application.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.blue[800]),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      _showFeedbackDialog(context);
                    },
                    icon: const Icon(Icons.send),
                    label: const Text('Envoyer un commentaire'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(BuildContext context,
      {required String question, required String answer}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              answer,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(value),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    final feedbackController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vos commentaires'),
        content: TextField(
          controller: feedbackController,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Partagez vos suggestions ou signalez un problème...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Merci pour vos commentaires!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }
}

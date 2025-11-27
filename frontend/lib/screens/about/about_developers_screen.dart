import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;

class AboutDevelopersScreen extends StatefulWidget {
  const AboutDevelopersScreen({Key? key}) : super(key: key);

  @override
  State<AboutDevelopersScreen> createState() => _AboutDevelopersScreenState();
}

class _AboutDevelopersScreenState extends State<AboutDevelopersScreen>
    with TickerProviderStateMixin {
  final List<AnimationController> _rotationControllers = [];
  final List<Animation<double>> _rotationAnimations = [];

  @override
  void initState() {
    super.initState();
    // Create animation controllers for each developer
    for (int i = 0; i < 5; i++) {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 800),
        vsync: this,
      );
      _rotationControllers.add(controller);
      _rotationAnimations.add(
        Tween<double>(begin: 0, end: 2 * math.pi).animate(
          CurvedAnimation(parent: controller, curve: Curves.easeInOut),
        ),
      );
    }
  }

  @override
  void dispose() {
    for (var controller in _rotationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _rotateAvatar(int index) {
    _rotationControllers[index].forward(from: 0);
  }

  static final List<Map<String, dynamic>> developers = [
    {
      'name': 'Rayen Chraiet',
      'role': 'Lead Developer & Project Manager',
      'email': 'rayenchraiet2000@gmail.com',
      'phone': '+216 94599198',
      'linkedin': 'https://www.linkedin.com/in/rayen-chraiet-16b671337/',
      'github': 'https://github.com/chraietrayen',
      'avatar': 'assets/images/dev1.jpg',
      'color': Colors.blue,
    },
    {
      'name': 'Sihem Barghouda',
      'role': 'Lead Developer & Frontend Developer',
      'email': 'sihembarghouda93@gmail.com',
      'phone': '+216 XX XXX XXX',
      'linkedin': 'in/syhembarghouda',
      'github': 'https://github.com/sihembarghouda',
      'avatar': 'assets/images/dev2.jpg',
      'color': Colors.green,
    },
    {
      'name': 'Zeineb Khaled',
      'role': 'Lead Developer & Backend Developer',
      'email': 'khaledzeineb81@gmail.com',
      'phone': '+216 XX XXX XXX',
      'linkedin': 'https://linkedin.com/in/zeinebkhaled',
      'github': 'https://github.com/KhaledZeineb',
      'avatar': 'assets/images/dev3.jpg',
      'color': Colors.purple,
    },
    {
      'name': 'Eya Ben Slama',
      'role': 'Lead Developer & UI/UX Designer',
      'email': 'benslama.eya.benslama@gmail.com',
      'phone': '+216 XX XXX XXX',
      'linkedin': 'https://linkedin.com/in/eyabenslama',
      'github': 'https://github.com/eyabenslama',
      'avatar': 'assets/images/dev4.jpg',
      'color': Colors.orange,
    },
    {
      'name': 'Rim Ayari',
      'role': 'Lead Developer & QA Engineer & DevOps',
      'email': 'Ayarirym71@gmail.com',
      'phone': '+216 XX XXX XXX',
      'linkedin': 'https://linkedin.com/in/rimayari',
      'github': 'https://github.com/rimayari',
      'avatar': 'assets/images/dev5.jpg',
      'color': Colors.pink,
    },
  ];

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showContactOptions(BuildContext context, Map<String, dynamic> dev) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.transparent,
                child: dev['avatar'] != null
                    ? ClipOval(
                        child: Image.asset(
                          dev['avatar'],
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: dev['color'].withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  dev['name'].substring(0, 1),
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: dev['color'],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: dev['color'].withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            dev['name'].substring(0, 1),
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: dev['color'],
                            ),
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 12),
              Text(
                dev['name'],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                dev['role'],
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.email, color: Colors.blue),
                title: const Text('Email'),
                subtitle: Text(dev['email']),
                onTap: () => _launchUrl('mailto:${dev['email']}'),
              ),
              ListTile(
                leading: const Icon(Icons.phone, color: Colors.green),
                title: const Text('Téléphone'),
                subtitle: Text(dev['phone']),
                onTap: () => _launchUrl('tel:${dev['phone']}'),
              ),
              ListTile(
                leading: Icon(Icons.work, color: Colors.blue[700]),
                title: const Text('LinkedIn'),
                onTap: () => _launchUrl(dev['linkedin']),
              ),
              ListTile(
                leading: const Icon(Icons.code, color: Colors.black87),
                title: const Text('GitHub'),
                onTap: () => _launchUrl(dev['github']),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('L\'équipe de développement'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.group_outlined,
                    size: 64,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'ImmoTunisie',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Développé par une équipe de 5 développeurs passionnés',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Notre Équipe',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: developers.length,
              itemBuilder: (context, index) {
                final dev = developers[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    onTap: () => _showContactOptions(context, dev),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => _rotateAvatar(index),
                            child: AnimatedBuilder(
                              animation: _rotationAnimations[index],
                              builder: (context, child) {
                                return Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.identity()
                                    ..rotateY(_rotationAnimations[index].value),
                                  child: Hero(
                                    tag: 'dev_$index',
                                    child: CircleAvatar(
                                      radius: 32,
                                      backgroundColor: Colors.transparent,
                                      child: dev['avatar'] != null
                                          ? ClipOval(
                                              child: Image.asset(
                                                dev['avatar'],
                                                width: 64,
                                                height: 64,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return Container(
                                                    width: 64,
                                                    height: 64,
                                                    decoration: BoxDecoration(
                                                      color: dev['color']
                                                          .withOpacity(0.1),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        dev['name']
                                                            .substring(0, 1),
                                                        style: TextStyle(
                                                          fontSize: 28,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: dev['color'],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            )
                                          : Container(
                                              width: 64,
                                              height: 64,
                                              decoration: BoxDecoration(
                                                color: dev['color']
                                                    .withOpacity(0.1),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Center(
                                                child: Text(
                                                  dev['name'].substring(0, 1),
                                                  style: TextStyle(
                                                    fontSize: 28,
                                                    fontWeight: FontWeight.bold,
                                                    color: dev['color'],
                                                  ),
                                                ),
                                              ),
                                            ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dev['name'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  dev['role'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.email,
                                      size: 16,
                                      color: Colors.grey[500],
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        dev['email'],
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    '© 2025 ImmoTunisie',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tous droits réservés',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
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
}

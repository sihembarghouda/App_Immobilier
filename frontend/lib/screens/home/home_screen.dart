// screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/property_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../models/property.dart';
import '../widgets/property_card.dart';
import '../widgets/shimmer_loading.dart';
import '../../utils/translations.dart';
import '../../utils/role_helper.dart';
import '../../widgets/ai_assistant_dialog.dart';
import '../notifications/notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  double _selectedRadius = 5.0; // Default 5km
  String? _selectedPropertyType; // null means all types
  String? _selectedTransactionType; // null means all

  final List<Map<String, dynamic>> _propertyTypeFilters = [
    {'labelKey': 'all', 'icon': Icons.home, 'value': null},
    {'labelKey': 'house', 'icon': Icons.house, 'value': 'house'},
    {'labelKey': 'apartment', 'icon': Icons.apartment, 'value': 'apartment'},
    {'labelKey': 'villa', 'icon': Icons.villa, 'value': 'villa'},
    {'labelKey': 'studio', 'icon': Icons.meeting_room, 'value': 'studio'},
  ];

  final List<Map<String, String?>> _transactionFilters = [
    {'labelKey': 'all', 'value': null},
    {'labelKey': 'sale', 'value': 'sale'},
    {'labelKey': 'rent', 'value': 'rent'},
  ];

  @override
  void initState() {
    super.initState();
    // Fetch properties on init
    Future.microtask(() async {
      final propertyProvider =
          Provider.of<PropertyProvider>(context, listen: false);
      final locationProvider =
          Provider.of<LocationProvider>(context, listen: false);

      // Initialize provider
      await propertyProvider.initialize();

      // Request location if not already set
      if (!locationProvider.hasLocation) {
        await locationProvider.getCurrentLocation();
      }

      propertyProvider.fetchProperties();
    });
  }

  void _onItemTapped(int index) {
    // Navigate for non-home tabs
    switch (index) {
      case 0:
        // Already on home
        setState(() {
          _selectedIndex = 0;
        });
        break;
      case 1:
        Navigator.of(context).pushNamed('/search');
        break;
      case 2:
        Navigator.of(context).pushNamed('/add-property');
        break;
      case 3:
        Navigator.of(context).pushNamed('/conversations');
        break;
      case 4:
        Navigator.of(context).pushNamed('/favorites');
        break;
      case 5:
        Navigator.of(context).pushNamed('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('home'.tr(context)),
        actions: [
          IconButton(
            icon: const Icon(Icons.map_outlined),
            onPressed: () {
              Navigator.of(context).pushNamed('/map');
            },
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const NotificationsScreen(),
                    ),
                  );
                },
              ),
              Consumer<NotificationProvider>(
                builder: (context, notificationProvider, _) {
                  final unreadCount = notificationProvider.unreadCount;
                  if (unreadCount == 0) return const SizedBox();

                  return Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        unreadCount > 99 ? '99+' : unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.smart_toy_outlined),
              tooltip: 'Assistant IA',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const AIAssistantDialog(),
                );
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Property Type Filters
          SizedBox(
            height: 60,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: _propertyTypeFilters.map((filter) {
                final isSelected = _selectedPropertyType == filter['value'];

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          filter['icon'] as IconData,
                          size: 18,
                          color: isSelected ? Colors.white : Colors.grey[700],
                        ),
                        const SizedBox(width: 6),
                        Text((filter['labelKey'] as String).tr(context)),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedPropertyType = filter['value'] as String?;
                      });
                    },
                    selectedColor: Colors.blue,
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[700],
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // Transaction Type Filters
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              children: _transactionFilters.map((filter) {
                final isSelected = _selectedTransactionType == filter['value'];

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(filter['labelKey']!.tr(context)),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedTransactionType = filter['value'];
                      });
                    },
                    selectedColor: Colors.green,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[700],
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // Distance Filter
          Consumer<LocationProvider>(
            builder: (context, locationProvider, _) {
              if (!locationProvider.hasLocation) return const SizedBox.shrink();

              return Container(
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Rayon de recherche',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        Text(
                          '${_selectedRadius.toStringAsFixed(0)} km',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _selectedRadius,
                      min: 1,
                      max: 50,
                      divisions: 49,
                      label: '${_selectedRadius.toStringAsFixed(0)} km',
                      onChanged: (value) {
                        setState(() {
                          _selectedRadius = value;
                        });
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          // Properties List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await Provider.of<PropertyProvider>(context, listen: false)
                    .fetchProperties();
              },
              child: Consumer2<PropertyProvider, LocationProvider>(
                builder: (context, propertyProvider, locationProvider, _) {
                  if (propertyProvider.isLoading &&
                      propertyProvider.properties.isEmpty) {
                    return const ShimmerListView();
                  }

                  if (propertyProvider.error != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 64, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(
                            'Erreur: ${propertyProvider.error}',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              propertyProvider.fetchProperties();
                            },
                            child: const Text('Réessayer'),
                          ),
                        ],
                      ),
                    );
                  }

                  // Filter by location if available
                  List<Property> displayProperties =
                      propertyProvider.properties;

                  if (locationProvider.hasLocation) {
                    displayProperties = propertyProvider.getPropertiesNearby(
                      locationProvider.latitude!,
                      locationProvider.longitude!,
                      _selectedRadius,
                    );
                  }

                  // Apply property type filter
                  if (_selectedPropertyType != null) {
                    displayProperties = displayProperties
                        .where((p) => p.type == _selectedPropertyType)
                        .toList();
                  }

                  // Apply transaction type filter
                  if (_selectedTransactionType != null) {
                    displayProperties = displayProperties
                        .where((p) =>
                            p.transactionType == _selectedTransactionType)
                        .toList();
                  }

                  if (displayProperties.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            locationProvider.hasLocation
                                ? 'Aucune propriété trouvée dans ce rayon'
                                : 'Aucune propriété disponible',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          if (locationProvider.hasLocation) ...[
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _selectedRadius = 50;
                                });
                              },
                              child: const Text('Augmenter le rayon'),
                            ),
                          ],
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: displayProperties.length,
                    itemBuilder: (context, index) {
                      final property = displayProperties[index];
                      return PropertyCard(
                        property: property,
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            '/property-detail',
                            arguments: property.id,
                          );
                        },
                        onFavorite: () async {
                          final authProvider =
                              Provider.of<AuthProvider>(context, listen: false);

                          if (!authProvider.isAuthenticated) {
                            // Show login dialog
                            final shouldLogin = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Connexion requise'),
                                content: const Text(
                                    'Vous devez être connecté pour ajouter aux favoris'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Annuler'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('Se connecter'),
                                  ),
                                ],
                              ),
                            );

                            if (shouldLogin == true && mounted) {
                              Navigator.of(context).pushNamed('/profile');
                            }
                            return;
                          }

                          // Ensure provider is initialized
                          await propertyProvider.initialize();

                          try {
                            await propertyProvider.toggleFavorite(property.id);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    property.isFavorite
                                        ? 'Retiré des favoris'
                                        : 'Ajouté aux favoris',
                                  ),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            }
                          } catch (e) {
                            print('❌ Favorite toggle error: $e');
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Erreur: ${e.toString()}'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(context),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Recherche',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            activeIcon: Icon(Icons.add_circle),
            label: 'Publier',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message_outlined),
            activeIcon: Icon(Icons.message),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            activeIcon: Icon(Icons.favorite),
            label: 'Favoris',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  /// Construit le FloatingActionButton selon le rôle de l'utilisateur
  Widget? _buildFloatingActionButton(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userRole = authProvider.user?.role;

    // Si vendeur: Bouton pour créer une propriété
    if (UserRole.canCreateProperty(userRole)) {
      return FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushNamed('/create-property');
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        icon: const Icon(Icons.add_home),
        label: const Text('Ajouter'),
        heroTag: 'create_property',
      );
    }

    // Pour tous: Assistant IA
    return FloatingActionButton.extended(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => const AIAssistantDialog(),
        );
      },
      backgroundColor: Theme.of(context).colorScheme.secondary,
      icon: const Icon(Icons.smart_toy),
      label: const Text('Assistant IA'),
      heroTag: 'ai_assistant',
    );
  }
}

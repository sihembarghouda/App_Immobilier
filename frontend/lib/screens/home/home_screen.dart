// screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/property_provider.dart';
import '../widgets/property_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Fetch properties on init
    Future.microtask(() {
      Provider.of<PropertyProvider>(context, listen: false).fetchProperties();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        // Already on home
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
        title: const Text('Immobilier'),
        actions: [
          IconButton(
            icon: const Icon(Icons.map_outlined),
            onPressed: () {
              Navigator.of(context).pushNamed('/map');
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Show notifications
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Provider.of<PropertyProvider>(context, listen: false)
              .fetchProperties();
        },
        child: Consumer<PropertyProvider>(
          builder: (context, propertyProvider, _) {
            if (propertyProvider.isLoading &&
                propertyProvider.properties.isEmpty) {
              return const Center(child: CircularProgressIndicator());
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

            if (propertyProvider.properties.isEmpty) {
              return const Center(
                child: Text('Aucune propriété disponible'),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: propertyProvider.properties.length,
              itemBuilder: (context, index) {
                final property = propertyProvider.properties[index];
                return PropertyCard(
                  property: property,
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      '/property-detail',
                      arguments: property.id,
                    );
                  },
                  onFavorite: () {
                    propertyProvider.toggleFavorite(property.id);
                  },
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
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
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/property_provider.dart';
import '../widgets/property_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes Favoris')),
      body: Consumer<PropertyProvider>(
        builder: (context, propertyProvider, _) {
          final favorites = propertyProvider.favoriteProperties;

          if (favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border,
                      size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun favori pour le moment',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final property = favorites[index];
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
    );
  }
}

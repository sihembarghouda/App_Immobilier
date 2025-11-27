import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/property_provider.dart';
import '../../providers/auth_provider.dart';
import '../property/property_detail_screen.dart';
import '../property/edit_property_screen.dart';

class MyPropertiesScreen extends StatefulWidget {
  const MyPropertiesScreen({Key? key}) : super(key: key);

  @override
  State<MyPropertiesScreen> createState() => _MyPropertiesScreenState();
}

class _MyPropertiesScreenState extends State<MyPropertiesScreen> {
  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  Future<void> _loadProperties() async {
    final propertyProvider =
        Provider.of<PropertyProvider>(context, listen: false);
    await propertyProvider.fetchProperties();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final propertyProvider = Provider.of<PropertyProvider>(context);

    // Filter properties owned by current user
    final myProperties = propertyProvider.properties
        .where((p) => p.ownerId == authProvider.user?.id.toString())
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes annonces'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed('/add-property');
            },
          ),
        ],
      ),
      body: propertyProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : myProperties.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.home_work_outlined,
                        size: 100,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucune annonce',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Publiez votre première annonce',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[500],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pushNamed('/add-property');
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Publier une annonce'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadProperties,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: myProperties.length,
                    itemBuilder: (context, index) {
                      final property = myProperties[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PropertyDetailScreen(
                                    propertyId: property.id),
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Property Image with Actions
                              Stack(
                                children: [
                                  AspectRatio(
                                    aspectRatio: 16 / 9,
                                    child: property.images.isNotEmpty
                                        ? Image.network(
                                            property.images[0],
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Container(
                                                color: Colors.grey[300],
                                                child: const Icon(
                                                  Icons.home_work,
                                                  size: 50,
                                                  color: Colors.grey,
                                                ),
                                              );
                                            },
                                          )
                                        : Container(
                                            color: Colors.grey[300],
                                            child: const Icon(
                                              Icons.home,
                                              size: 50,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                  // Action buttons
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Row(
                                      children: [
                                        IconButton.filled(
                                          onPressed: () {
                                            _editProperty(property);
                                          },
                                          icon: const Icon(Icons.edit),
                                          style: IconButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                            foregroundColor: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton.filled(
                                          onPressed: () {
                                            _confirmDelete(property);
                                          },
                                          icon: const Icon(Icons.delete),
                                          style: IconButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              // Property Details
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      property.title,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      property.city,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Chip(
                                          label: Text(
                                            property.transactionType == 'sale'
                                                ? 'Vente'
                                                : 'Location',
                                          ),
                                          backgroundColor:
                                              Theme.of(context).primaryColor,
                                          labelStyle: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Chip(
                                          label: Text(property.type),
                                          backgroundColor: Colors.grey[200],
                                          labelStyle: const TextStyle(
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${property.price.toStringAsFixed(0)} DT',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  void _editProperty(property) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPropertyScreen(property: property),
      ),
    );

    // Reload properties if edit was successful
    if (result == true && mounted) {
      await _loadProperties();
    }
  }

  void _confirmDelete(property) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
            'Voulez-vous vraiment supprimer "${property.title}" ?\n\nCette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _deleteProperty(property.id);
    }
  }

  Future<void> _deleteProperty(String propertyId) async {
    try {
      final propertyProvider =
          Provider.of<PropertyProvider>(context, listen: false);

      // Show loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Suppression en cours...'),
          duration: Duration(seconds: 2),
        ),
      );

      await propertyProvider.deleteProperty(propertyId);

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Annonce supprimée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        await _loadProperties();
      }
    } catch (e) {
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
}

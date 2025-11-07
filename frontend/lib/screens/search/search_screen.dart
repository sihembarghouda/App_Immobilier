// screens/search/search_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/property_provider.dart';
import '../widgets/property_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _cityController = TextEditingController();
  String? _selectedType;
  String? _selectedTransactionType;
  double _minPrice = 0;
  double _maxPrice = 1000000;
  int _minRooms = 1;

  final List<String> _propertyTypes = [
    'Tous',
    'apartment',
    'house',
    'villa',
    'studio',
  ];

  final List<String> _transactionTypes = [
    'Tous',
    'sale',
    'rent',
  ];

  String _getPropertyTypeLabel(String type) {
    switch (type) {
      case 'apartment':
        return 'Appartement';
      case 'house':
        return 'Maison';
      case 'villa':
        return 'Villa';
      case 'studio':
        return 'Studio';
      case 'Tous':
        return 'Tous';
      default:
        return type;
    }
  }

  String _getTransactionTypeLabel(String type) {
    switch (type) {
      case 'sale':
        return 'Vente';
      case 'rent':
        return 'Location';
      case 'Tous':
        return 'Tous';
      default:
        return type;
    }
  }

  void _search() {
    final propertyProvider =
        Provider.of<PropertyProvider>(context, listen: false);
    propertyProvider.searchProperties(
      city: _cityController.text.isEmpty ? null : _cityController.text,
      type: _selectedType == 'Tous' ? null : _selectedType,
      transactionType:
          _selectedTransactionType == 'Tous' ? null : _selectedTransactionType,
      minPrice: _minPrice,
      maxPrice: _maxPrice,
      minRooms: _minRooms,
    );
  }

  void _resetFilters() {
    setState(() {
      _cityController.clear();
      _selectedType = null;
      _selectedTransactionType = null;
      _minPrice = 0;
      _maxPrice = 1000000;
      _minRooms = 1;
    });
    Provider.of<PropertyProvider>(context, listen: false).fetchProperties();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recherche'),
        actions: [
          TextButton(
            onPressed: _resetFilters,
            child: const Text('Réinitialiser'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters Section
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // City Search
                  TextField(
                    controller: _cityController,
                    decoration: InputDecoration(
                      labelText: 'Ville',
                      hintText: 'Ex: Tunis, Sousse, Sfax...',
                      prefixIcon: const Icon(Icons.location_city),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Property Type
                  const Text(
                    'Type de bien',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _propertyTypes.map((type) {
                      final isSelected = _selectedType == type ||
                          (_selectedType == null && type == 'Tous');
                      return ChoiceChip(
                        label: Text(_getPropertyTypeLabel(type)),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedType = type == 'Tous' ? null : type;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Transaction Type
                  const Text(
                    'Type de transaction',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _transactionTypes.map((type) {
                      final isSelected = _selectedTransactionType == type ||
                          (_selectedTransactionType == null && type == 'Tous');
                      return ChoiceChip(
                        label: Text(_getTransactionTypeLabel(type)),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedTransactionType =
                                type == 'Tous' ? null : type;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Price Range
                  const Text(
                    'Fourchette de prix',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'Min',
                            suffixText: 'TND',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              _minPrice = double.tryParse(value) ?? 0;
                            });
                          },
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text('-'),
                      ),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'Max',
                            suffixText: 'TND',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              _maxPrice = double.tryParse(value) ?? 1000000;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Number of Rooms
                  const Text(
                    'Nombre de pièces minimum',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: _minRooms.toDouble(),
                          min: 1,
                          max: 10,
                          divisions: 9,
                          label: '$_minRooms pièces',
                          onChanged: (value) {
                            setState(() {
                              _minRooms = value.toInt();
                            });
                          },
                        ),
                      ),
                      Text(
                        '$_minRooms',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Search Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _search,
                      icon: const Icon(Icons.search),
                      label: const Text('Rechercher'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Divider(height: 1),

          // Results Section
          Expanded(
            flex: 3,
            child: Consumer<PropertyProvider>(
              builder: (context, propertyProvider, _) {
                if (propertyProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (propertyProvider.properties.isEmpty) {
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
                          'Aucun résultat trouvé',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        '${propertyProvider.properties.length} résultat(s) trouvé(s)',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
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
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }
}

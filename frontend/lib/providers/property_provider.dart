import 'package:flutter/material.dart';
import '../models/property.dart';

class PropertyProvider with ChangeNotifier {
  List<Property> _properties = [];
  final List<Property> _favoriteProperties = [];
  bool _isLoading = false;
  String? _error;

  List<Property> get properties => _properties;
  List<Property> get favoriteProperties => _favoriteProperties;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch all properties
  Future<void> fetchProperties() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: Call API
      // Mock data for now
      await Future.delayed(const Duration(seconds: 1));
      
      _properties = _getMockProperties();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Search properties with filters
  Future<void> searchProperties({
    String? city,
    String? type,
    String? transactionType,
    double? minPrice,
    double? maxPrice,
    int? minRooms,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Call API with filters
      await Future.delayed(const Duration(seconds: 1));
      
      _properties = _getMockProperties().where((property) {
        if (city != null && !property.city.toLowerCase().contains(city.toLowerCase())) {
          return false;
        }
        if (type != null && property.type != type) {
          return false;
        }
        if (transactionType != null && property.transactionType != transactionType) {
          return false;
        }
        if (minPrice != null && property.price < minPrice) {
          return false;
        }
        if (maxPrice != null && property.price > maxPrice) {
          return false;
        }
        if (minRooms != null && property.rooms < minRooms) {
          return false;
        }
        return true;
      }).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get property by ID
  Property? getPropertyById(String id) {
    try {
      return _properties.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  // Toggle favorite
  Future<void> toggleFavorite(String propertyId) async {
    final index = _properties.indexWhere((p) => p.id == propertyId);
    if (index != -1) {
      _properties[index] = _properties[index].copyWith(
        isFavorite: !_properties[index].isFavorite,
      );

      if (_properties[index].isFavorite) {
        _favoriteProperties.add(_properties[index]);
      } else {
        _favoriteProperties.removeWhere((p) => p.id == propertyId);
      }

      notifyListeners();
      
      // TODO: Call API to save favorite
    }
  }

  // Add new property
  Future<bool> addProperty(Property property) async {
    try {
      // TODO: Call API
      await Future.delayed(const Duration(seconds: 2));
      
      _properties.insert(0, property);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  // Mock data generator
  List<Property> _getMockProperties() {
    return [
      Property(
        id: '1',
        title: 'Appartement moderne avec vue mer',
        description: 'Bel appartement de 120m² avec vue imprenable sur la mer. Cuisine équipée, climatisation, parking.',
        type: 'apartment',
        transactionType: 'sale',
        price: 250000,
        surface: 120,
        rooms: 4,
        bedrooms: 3,
        bathrooms: 2,
        address: 'Avenue Habib Bourguiba',
        city: 'Tunis',
        latitude: 36.8065,
        longitude: 10.1815,
        images: [
          'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267',
          'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2',
        ],
        ownerId: '1',
        ownerName: 'Ahmed Ben Ali',
        ownerPhone: '+216 98 123 456',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Property(
        id: '2',
        title: 'Villa luxueuse avec piscine',
        description: 'Magnifique villa de 350m² avec jardin et piscine. 5 chambres, garage double.',
        type: 'villa',
        transactionType: 'sale',
        price: 850000,
        surface: 350,
        rooms: 7,
        bedrooms: 5,
        bathrooms: 3,
        address: 'Les Berges du Lac',
        city: 'Tunis',
        latitude: 36.8358,
        longitude: 10.2578,
        images: [
          'https://images.unsplash.com/photo-1613490493576-7fde63acd811',
        ],
        ownerId: '2',
        ownerName: 'Fatma Trabelsi',
        ownerPhone: '+216 22 987 654',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Property(
        id: '3',
        title: 'Studio meublé centre ville',
        description: 'Studio de 45m² entièrement meublé, idéal pour étudiant ou jeune professionnel.',
        type: 'studio',
        transactionType: 'rent',
        price: 800,
        surface: 45,
        rooms: 1,
        bedrooms: 1,
        bathrooms: 1,
        address: 'Rue de Marseille',
        city: 'Tunis',
        latitude: 36.8019,
        longitude: 10.1868,
        images: [
          'https://www.shutterstock.com/image-illustration/studio-room-interior-lounge-zone-260nw-2645425827.jpg',
        ],
        ownerId: '3',
        ownerName: 'Mohamed Saidi',
        ownerPhone: '+216 55 444 333',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }
}
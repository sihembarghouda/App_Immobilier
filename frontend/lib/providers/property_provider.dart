import 'package:flutter/material.dart';
import '../models/property.dart';
import '../core/services/api_service.dart';
import 'dart:math' as math;

class PropertyProvider with ChangeNotifier {
  List<Property> _properties = [];
  final List<Property> _favoriteProperties = [];
  bool _isLoading = false;
  String? _error;
  ApiService? _apiService;

  List<Property> get properties => _properties;
  List<Property> get favoriteProperties => _favoriteProperties;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize API service (call once)
  Future<void> initialize() async {
    _apiService ??= await ApiService.getInstance();
  }

  Future<ApiService> _ensureApiService() async {
    _apiService ??= await ApiService.getInstance();
    return _apiService!;
  }

  // Fetch all properties
  Future<void> fetchProperties() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final api = await _ensureApiService();
      final fetchedProperties = await api.getProperties();
      _properties = fetchedProperties;

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
      final api = await _ensureApiService();
      final fetchedProperties = await api.getProperties(
        city: city,
        type: type,
        transactionType: transactionType,
        minPrice: minPrice,
        maxPrice: maxPrice,
        minRooms: minRooms,
      );
      _properties = fetchedProperties;

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
    try {
      final api = await _ensureApiService();
      final index = _properties.indexWhere((p) => p.id == propertyId);
      if (index != -1) {
        final isFavorite = _properties[index].isFavorite;

        if (isFavorite) {
          await api.removeFavorite(propertyId);
        } else {
          await api.addFavorite(propertyId);
        }

        _properties[index] = _properties[index].copyWith(
          isFavorite: !isFavorite,
        );

        if (_properties[index].isFavorite) {
          _favoriteProperties.add(_properties[index]);
        } else {
          _favoriteProperties.removeWhere((p) => p.id == propertyId);
        }

        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Add new property
  Future<bool> addProperty(Property property) async {
    try {
      final api = await _ensureApiService();
      await api.createProperty(property);
      await fetchProperties(); // Refresh the list
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  // Delete property
  Future<bool> deleteProperty(String propertyId) async {
    try {
      final api = await _ensureApiService();
      await api.deleteProperty(propertyId);
      _properties.removeWhere((p) => p.id == propertyId);
      _favoriteProperties.removeWhere((p) => p.id == propertyId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Update property
  Future<bool> updateProperty(String id, Property property) async {
    try {
      final api = await _ensureApiService();
      await api.updateProperty(id, property);
      await fetchProperties(); // Refresh the list
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  // Fetch favorites
  Future<void> fetchFavorites() async {
    try {
      final api = await _ensureApiService();
      final favorites = await api.getFavorites();
      _favoriteProperties.clear();
      _favoriteProperties.addAll(favorites);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Filter properties by distance from user location
  List<Property> getPropertiesNearby(
      double userLat, double userLng, double radiusKm) {
    return _properties.where((property) {
      double distance = _calculateDistance(
        userLat,
        userLng,
        property.latitude,
        property.longitude,
      );
      return distance <= radiusKm;
    }).toList();
  }

  // Calculate distance between two points in km
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // km

    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);

    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    double distance = earthRadius * c;

    return distance;
  }

  double _degreesToRadians(double degrees) {
    return degrees * math.pi / 180;
  }
}

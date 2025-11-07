// lib/screens/services/api_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/constants.dart';
import '../../models/property.dart';
import '../../models/user.dart';

class ApiService {
  final String baseUrl;
  String? _token;

  ApiService({this.baseUrl = AppConstants.apiBaseUrl});

  // Set authentication token
  void setToken(String token) {
    _token = token;
  }

  // Get headers with authentication
  Map<String, String> _getHeaders() {
    final headers = {
      'Content-Type': 'application/json',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  // ========== Authentication APIs ==========

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${AppConstants.loginEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Login failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }

  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${AppConstants.registerEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Registration failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Registration error: $e');
    }
  }

  Future<User> getCurrentUser() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return User.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to get user data');
      }
    } catch (e) {
      throw Exception('Get user error: $e');
    }
  }

  // ========== Property APIs ==========

  Future<List<Property>> getProperties({
    String? city,
    String? type,
    String? transactionType,
    double? minPrice,
    double? maxPrice,
    int? minRooms,
  }) async {
    try {
      // Build query parameters
      final queryParams = <String, String>{};
      if (city != null) queryParams['city'] = city;
      if (type != null) queryParams['type'] = type;
      if (transactionType != null) {
        queryParams['transaction_type'] = transactionType;
      }
      if (minPrice != null) queryParams['min_price'] = minPrice.toString();
      if (maxPrice != null) queryParams['max_price'] = maxPrice.toString();
      if (minRooms != null) queryParams['min_rooms'] = minRooms.toString();

      final uri = Uri.parse('$baseUrl${AppConstants.propertiesEndpoint}')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: _getHeaders());

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Property.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load properties');
      }
    } catch (e) {
      throw Exception('Get properties error: $e');
    }
  }

  Future<Property> getPropertyById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${AppConstants.propertiesEndpoint}/$id'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return Property.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load property');
      }
    } catch (e) {
      throw Exception('Get property error: $e');
    }
  }

  Future<Property> createProperty(Property property) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${AppConstants.propertiesEndpoint}'),
        headers: _getHeaders(),
        body: json.encode(property.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Property.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create property');
      }
    } catch (e) {
      throw Exception('Create property error: $e');
    }
  }

  Future<void> updateProperty(String id, Property property) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl${AppConstants.propertiesEndpoint}/$id'),
        headers: _getHeaders(),
        body: json.encode(property.toJson()),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update property');
      }
    } catch (e) {
      throw Exception('Update property error: $e');
    }
  }

  Future<void> deleteProperty(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl${AppConstants.propertiesEndpoint}/$id'),
        headers: _getHeaders(),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete property');
      }
    } catch (e) {
      throw Exception('Delete property error: $e');
    }
  }

  // ========== Favorites APIs ==========

  Future<List<Property>> getFavorites() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${AppConstants.favoritesEndpoint}'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Property.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load favorites');
      }
    } catch (e) {
      throw Exception('Get favorites error: $e');
    }
  }

  Future<void> addFavorite(String propertyId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${AppConstants.favoritesEndpoint}'),
        headers: _getHeaders(),
        body: json.encode({'property_id': propertyId}),
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Failed to add favorite');
      }
    } catch (e) {
      throw Exception('Add favorite error: $e');
    }
  }

  Future<void> removeFavorite(String propertyId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl${AppConstants.favoritesEndpoint}/$propertyId'),
        headers: _getHeaders(),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to remove favorite');
      }
    } catch (e) {
      throw Exception('Remove favorite error: $e');
    }
  }

  // ========== Upload Image ==========

  Future<String> uploadImage(String imagePath) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/upload'),
      );

      request.headers.addAll(_getHeaders());
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));

      var response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = await response.stream.bytesToString();
        final data = json.decode(responseData);
        return data['url']; // URL de l'image uploadée
      } else {
        throw Exception('Failed to upload image');
      }
    } catch (e) {
      throw Exception('Upload image error: $e');
    }
  }

  // ========== Messaging APIs ==========

  Future<List<dynamic>> getConversations() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${AppConstants.messagesEndpoint}/conversations'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load conversations');
      }
    } catch (e) {
      throw Exception('Get conversations error: $e');
    }
  }

  Future<List<dynamic>> getMessages(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${AppConstants.messagesEndpoint}/$userId'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load messages');
      }
    } catch (e) {
      throw Exception('Get messages error: $e');
    }
  }

  Future<Map<String, dynamic>> sendMessage(
    String receiverId,
    String content, {
    String? propertyId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${AppConstants.messagesEndpoint}'),
        headers: _getHeaders(),
        body: json.encode({
          'receiver_id': receiverId,
          'content': content,
          'property_id': propertyId,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to send message');
      }
    } catch (e) {
      throw Exception('Send message error: $e');
    }
  }

  Future<void> markMessagesAsRead(String userId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl${AppConstants.messagesEndpoint}/$userId/read'),
        headers: _getHeaders(),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to mark messages as read');
      }
    } catch (e) {
      throw Exception('Mark as read error: $e');
    }
  }
}

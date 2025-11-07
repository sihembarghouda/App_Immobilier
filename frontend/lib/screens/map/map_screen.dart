// screens/map/map_screen.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
// using flutter_map for all platforms to avoid depending on google_maps_flutter
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latLng;

import '../../providers/property_provider.dart';
import '../../models/property.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // controller removed (not using Google Maps); use flutter_map markers
  List<Marker> _markers = [];
  Property? _selectedProperty;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!kIsWeb) _loadMarkers();
    });
  }

  void _loadMarkers() {
    final propertyProvider =
        Provider.of<PropertyProvider>(context, listen: false);
    final properties = propertyProvider.properties;
    setState(() {
      _markers = properties.map((property) {
        return Marker(
          point: latLng.LatLng(property.latitude, property.longitude),
          width: 40,
          height: 40,
          // flutter_map Marker uses `child` in this project version
          child: GestureDetector(
            onTap: () => setState(() => _selectedProperty = property),
            child: Icon(
              Icons.location_on,
              color: property.transactionType == 'sale'
                  ? Colors.blue
                  : Colors.green,
              size: 36,
            ),
          ),
        );
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final defaultLocation = latLng.LatLng(36.8065, 10.1815);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carte'),
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: defaultLocation,
              initialZoom: 12,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
              ),
              MarkerLayer(markers: _markers),
            ],
          ),
          if (_selectedProperty != null) _buildPropertyCard(context),
        ],
      ),
    );
  }

  // Web-specific helper removed; using flutter_map in build for all platforms.

  Widget _buildPropertyCard(BuildContext context) {
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  _selectedProperty!.images.isNotEmpty
                      ? _selectedProperty!.images.first
                      : 'https://via.placeholder.com/80',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedProperty!.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _selectedProperty!.city,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    Text(
                      '${_selectedProperty!.price} TND',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    '/property-detail',
                    arguments: _selectedProperty!.id,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // No map controller to dispose when using flutter_map
    super.dispose();
  }
}

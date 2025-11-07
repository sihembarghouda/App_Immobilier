// widgets/property_card.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/property.dart';
import 'package:intl/intl.dart';

class PropertyCard extends StatelessWidget {
  final Property property;
  final VoidCallback onTap;
  final VoidCallback onFavorite;

  const PropertyCard({
    super.key,
    required this.property,
    required this.onTap,
    required this.onFavorite,
  });

  String _formatPrice(double price) {
    final formatter = NumberFormat('#,##0', 'fr_FR');
    return formatter.format(price);
  }

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
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: property.images.isNotEmpty
                      ? property.images.first
                      : 'https://via.placeholder.com/400x250',
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Icon(Icons.error),
                  ),
                ),
                // Transaction Type Badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: property.transactionType == 'sale'
                          ? Colors.blue
                          : Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getTransactionTypeLabel(property.transactionType),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Favorite Button
                Positioned(
                  top: 12,
                  right: 12,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: Icon(
                        property.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: property.isFavorite ? Colors.red : Colors.grey,
                      ),
                      onPressed: onFavorite,
                    ),
                  ),
                ),
              ],
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    property.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Location
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${property.city}, ${property.address}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Property Details
                  Row(
                    children: [
                      _buildDetailChip(
                        Icons.square_foot,
                        '${property.surface.toInt()}m²',
                      ),
                      const SizedBox(width: 8),
                      _buildDetailChip(
                        Icons.bed_outlined,
                        '${property.bedrooms} ch',
                      ),
                      const SizedBox(width: 8),
                      _buildDetailChip(
                        Icons.bathtub_outlined,
                        '${property.bathrooms} sdb',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  // Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Prix',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_formatPrice(property.price)} TND${property.transactionType == 'rent' ? '/mois' : ''}',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      Chip(
                        label: Text(_getPropertyTypeLabel(property.type)),
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[700]),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}

// screens/property/edit_property_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import '../../providers/property_provider.dart';
import '../../providers/auth_provider.dart';
import '../../screens/services/api_service.dart';
import '../../models/property.dart';

class EditPropertyScreen extends StatefulWidget {
  final Property property;

  const EditPropertyScreen({super.key, required this.property});

  @override
  State<EditPropertyScreen> createState() => _EditPropertyScreenState();
}

class _EditPropertyScreenState extends State<EditPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _surfaceController;
  late TextEditingController _roomsController;
  late TextEditingController _bedroomsController;
  late TextEditingController _bathroomsController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  final ApiService _apiService = ApiService();

  late String _selectedType;
  late String _selectedTransactionType;
  List<XFile> _newImages = [];
  List<String> _existingImageUrls = [];
  bool _isLoading = false;
  late double _latitude;
  late double _longitude;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing property data
    _titleController = TextEditingController(text: widget.property.title);
    _descriptionController =
        TextEditingController(text: widget.property.description);
    _priceController =
        TextEditingController(text: widget.property.price.toString());
    _surfaceController =
        TextEditingController(text: widget.property.surface.toString());
    _roomsController =
        TextEditingController(text: widget.property.rooms.toString());
    _bedroomsController =
        TextEditingController(text: widget.property.bedrooms.toString());
    _bathroomsController =
        TextEditingController(text: widget.property.bathrooms.toString());
    _addressController = TextEditingController(text: widget.property.address);
    _cityController = TextEditingController(text: widget.property.city);

    _selectedType = widget.property.type;
    _selectedTransactionType = widget.property.transactionType;
    _latitude = widget.property.latitude;
    _longitude = widget.property.longitude;
    _existingImageUrls = List.from(widget.property.images);

    // Sync token from auth provider to api service
    Future.microtask(() {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.token != null) {
        _apiService.setToken(authProvider.token!);
        print('✅ Token synced to API service in edit_property_screen');
      }
    });
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage(
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 50,
    );

    setState(() {
      _newImages = images;
    });
  }

  void _removeExistingImage(int index) {
    setState(() {
      _existingImageUrls.removeAt(index);
    });
  }

  Future<void> _updateProperty() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // Get current user
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (authProvider.user == null) {
          throw Exception('Utilisateur non connecté');
        }

        // Start with existing images that weren't removed
        List<String> imageUrls = List.from(_existingImageUrls);

        // Upload new images if any selected
        if (_newImages.isNotEmpty) {
          print('📸 Uploading ${_newImages.length} new images...');

          for (var i = 0; i < _newImages.length; i++) {
            try {
              final image = _newImages[i];
              String imageUrl;

              if (kIsWeb) {
                // For web, convert to base64
                final bytes = await image.readAsBytes();
                final base64Image =
                    'data:image/jpeg;base64,${base64Encode(bytes)}';
                imageUrl = await _apiService.uploadImage(base64Image);
              } else {
                // For mobile, use file path
                imageUrl = await _apiService.uploadImage(image.path);
              }

              imageUrls.add(imageUrl);
              print('✅ New image ${i + 1}/${_newImages.length} uploaded');
            } catch (e) {
              print('❌ Failed to upload image ${i + 1}: $e');
            }
          }
        }

        // Ensure at least one image
        if (imageUrls.isEmpty) {
          imageUrls.add(''); // Empty string triggers errorWidget
        }

        final updatedProperty = Property(
          id: widget.property.id,
          title: _titleController.text,
          description: _descriptionController.text,
          type: _selectedType,
          transactionType: _selectedTransactionType,
          price: double.parse(_priceController.text),
          surface: double.parse(_surfaceController.text),
          rooms: int.parse(_roomsController.text),
          bedrooms: int.parse(_bedroomsController.text),
          bathrooms: int.parse(_bathroomsController.text),
          address: _addressController.text,
          city: _cityController.text,
          latitude: _latitude,
          longitude: _longitude,
          images: imageUrls,
          ownerId: widget.property.ownerId,
          ownerName: widget.property.ownerName,
          ownerPhone: widget.property.ownerPhone,
          createdAt: widget.property.createdAt,
        );

        final success =
            await Provider.of<PropertyProvider>(context, listen: false)
                .updateProperty(widget.property.id, updatedProperty);

        if (mounted) {
          setState(() => _isLoading = false);

          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Annonce mise à jour avec succès!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop(true); // Return true to indicate success
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Erreur lors de la mise à jour'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        print('❌ Update property error: $e');
        if (mounted) {
          setState(() => _isLoading = false);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier l\'annonce'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Supprimer l\'annonce'),
                  content: const Text(
                      'Êtes-vous sûr de vouloir supprimer cette annonce ?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Annuler'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Supprimer'),
                    ),
                  ],
                ),
              );

              if (confirm == true && mounted) {
                final success =
                    await Provider.of<PropertyProvider>(context, listen: false)
                        .deleteProperty(widget.property.id);

                if (mounted) {
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Annonce supprimée'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.of(context).pop(true);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Erreur lors de la suppression'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Existing images preview
            if (_existingImageUrls.isNotEmpty) ...[
              const Text(
                'Photos actuelles',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _existingImageUrls.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: NetworkImage(_existingImageUrls[index]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 12,
                          child: GestureDetector(
                            onTap: () => _removeExistingImage(index),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],

            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Titre de l\'annonce',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Champ requis' : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Champ requis' : null,
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Type de bien',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                    value: 'apartment', child: Text('Appartement')),
                DropdownMenuItem(value: 'house', child: Text('Maison')),
                DropdownMenuItem(value: 'villa', child: Text('Villa')),
                DropdownMenuItem(value: 'studio', child: Text('Studio')),
              ],
              onChanged: (value) => setState(() => _selectedType = value!),
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _selectedTransactionType,
              decoration: const InputDecoration(
                labelText: 'Type de transaction',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'sale', child: Text('Vente')),
                DropdownMenuItem(value: 'rent', child: Text('Location')),
              ],
              onChanged: (value) =>
                  setState(() => _selectedTransactionType = value!),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Prix (TND)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Champ requis' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _surfaceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Surface (m²)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Champ requis' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _roomsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Pièces',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Champ requis' : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _bedroomsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Chambres',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Champ requis' : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _bathroomsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'SDB',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Champ requis' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Adresse',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Champ requis' : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: 'Ville',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Champ requis' : null,
            ),
            const SizedBox(height: 16),

            OutlinedButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.add_photo_alternate),
              label: Text(_newImages.isEmpty
                  ? 'Ajouter des photos'
                  : '${_newImages.length} nouvelle(s) photo(s)'),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _isLoading ? null : _updateProperty,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Mettre à jour l\'annonce'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _surfaceController.dispose();
    _roomsController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/property_provider.dart';
import '../../models/property.dart';

class AddPropertyScreen extends StatefulWidget {
  const AddPropertyScreen({super.key});

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _surfaceController = TextEditingController();
  final _roomsController = TextEditingController();
  final _bedroomsController = TextEditingController();
  final _bathroomsController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  
  String _selectedType = 'apartment';
  String _selectedTransactionType = 'sale';
  List<String> _selectedImages = [];
  bool _isLoading = false;

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    
    setState(() {
      _selectedImages = images.map((image) => image.path).toList();
    });
  }

  Future<void> _submitProperty() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final property = Property(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
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
        latitude: 36.8065, // Mock coordinates
        longitude: 10.1815,
        images: _selectedImages.isEmpty 
          ? ['https://via.placeholder.com/400'] 
          : _selectedImages,
        ownerId: '1',
        ownerName: 'John Doe',
        ownerPhone: '+216 98 123 456',
        createdAt: DateTime.now(),
      );

      final success = await Provider.of<PropertyProvider>(context, listen: false)
          .addProperty(property);

      setState(() => _isLoading = false);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Annonce publiée avec succès!')),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Publier une annonce')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
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
              initialValue: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Type de bien',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'apartment', child: Text('Appartement')),
                DropdownMenuItem(value: 'house', child: Text('Maison')),
                DropdownMenuItem(value: 'villa', child: Text('Villa')),
                DropdownMenuItem(value: 'studio', child: Text('Studio')),
              ],
              onChanged: (value) => setState(() => _selectedType = value!),
            ),
            const SizedBox(height: 16),
            
            DropdownButtonFormField<String>(
              initialValue: _selectedTransactionType,
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
              icon: const Icon(Icons.image),
              label: Text(_selectedImages.isEmpty 
                ? 'Ajouter des photos' 
                : '${_selectedImages.length} photo(s) sélectionnée(s)'),
            ),
            const SizedBox(height: 24),
            
            ElevatedButton(
              onPressed: _isLoading ? null : _submitProperty,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                ? const CircularProgressIndicator()
                : const Text('Publier l\'annonce'),
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
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

class FoundObjectForm extends StatefulWidget {
  @override
  _FoundObjectFormState createState() => _FoundObjectFormState();
}

class _FoundObjectFormState extends State<FoundObjectForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _rewardAmountController = TextEditingController();
  final TextEditingController _rewardMessageController =
      TextEditingController();

  String? _selectedCategory;
  String? _selectedReward = 'No'; // Inicializamos con "No"
  List<File> _images = [];
  List<String> _locationSuggestions = [];

  final List<String> _categories = [
    'Documentos',
    'Electrónicos',
    'Ropa',
    'Objetos personales',
  ];

  final List<String> _rewards = ['No', 'Sí'];

  final ImagePicker _picker = ImagePicker();

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('¡Éxito!'),
          content: Text('El objeto se ha registrado correctamente.'),
          backgroundColor: Colors.teal[50],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          actions: [
            TextButton(
              child: Text('OK', style: TextStyle(color: Colors.teal)),
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
                // Limpia el formulario
                _formKey.currentState!.reset();
                setState(() {
                  _titleController.clear();
                  _descriptionController.clear();
                  _locationController.clear();
                  _rewardAmountController.clear();
                  _rewardMessageController.clear();
                  _selectedCategory = null;
                  _selectedReward = 'No';
                  _images.clear();
                  _locationSuggestions.clear();
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrar Objeto Encontrado'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title field
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Título',
                    prefixIcon: Icon(Icons.title),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.teal[50],
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese un título';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Description field
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Descripción',
                    prefixIcon: Icon(Icons.description),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.teal[50],
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese una descripción';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Category dropdown
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Categoría',
                    prefixIcon: Icon(Icons.category),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.teal[50],
                  ),
                  items: _categories
                      .map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Por favor seleccione una categoría';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Reward dropdown
                DropdownButtonFormField<String>(
                  value: _selectedReward,
                  decoration: InputDecoration(
                    labelText: 'Recompensa',
                    prefixIcon: Icon(Icons.card_giftcard),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.teal[50],
                  ),
                  items: _rewards
                      .map((reward) => DropdownMenuItem(
                            value: reward,
                            child: Text(reward),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedReward = value;
                      if (value == 'No') {
                        _rewardAmountController.clear();
                        _rewardMessageController.clear();
                      }
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Por favor indique si hay recompensa';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Campos condicionales de recompensa
                if (_selectedReward == 'Sí') ...[
                  TextFormField(
                    controller: _rewardAmountController,
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Monto de Recompensa',
                      prefixIcon: Icon(Icons.attach_money),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.teal[50],
                    ),
                    validator: (value) {
                      if (_selectedReward == 'Sí') {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese el monto de la recompensa';
                        }
                        try {
                          double amount = double.parse(value);
                          if (amount <= 0) {
                            return 'El monto debe ser mayor a 0';
                          }
                        } catch (e) {
                          return 'Por favor ingrese un monto válido';
                        }
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _rewardMessageController,
                    maxLength: 500,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Mensaje de Recompensa',
                      prefixIcon: Icon(Icons.message),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.teal[50],
                    ),
                    validator: (value) {
                      if (_selectedReward == 'Sí') {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese un mensaje para la recompensa';
                        }
                        if (value.length > 500) {
                          return 'El mensaje no puede exceder los 500 caracteres';
                        }
                      }
                      return null;
                    },
                  ),
                ],

                // Location field with suggestions
                TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    labelText: 'Ubicación',
                    prefixIcon: Icon(Icons.location_on),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.my_location),
                      onPressed: _selectCurrentLocation,
                    ),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.teal[50],
                  ),
                  onChanged: _fetchLocationSuggestions,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese una ubicación';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 8),

                // Suggestions List
                if (_locationSuggestions.isNotEmpty)
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: _locationSuggestions.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_locationSuggestions[index]),
                        onTap: () {
                          setState(() {
                            _locationController.text =
                                _locationSuggestions[index];
                            _locationSuggestions.clear();
                          });
                        },
                      );
                    },
                  ),
                SizedBox(height: 16),

                // Images upload
                Text('Agregar imágenes (máximo 3):'),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ..._images.map((file) {
                      return Stack(
                        children: [
                          Image.file(
                            file,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: IconButton(
                              icon: Icon(Icons.close, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _images.remove(file);
                                });
                              },
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                    if (_images.length < 3)
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 100,
                          height: 100,
                          color: Colors.teal[50],
                          child: Icon(Icons.add_a_photo),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 16),

                // Submit button
                Center(
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding:
                          EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    child: Text('Registrar', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _images.add(File(pickedFile.path));
      });
    }
  }

  Future<void> _selectCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final response = await http.get(Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _locationController.text = data['display_name'];
        });
      }
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Future<void> _fetchLocationSuggestions(String query) async {
    if (query.length < 3) return;

    try {
      final response = await http.get(Uri.parse(
          'https://nominatim.openstreetmap.org/search?format=json&q=$query'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _locationSuggestions = data
              .take(5)
              .map((item) => item['display_name'].toString())
              .toList();
        });
      }
    } catch (e) {
      print('Error fetching location suggestions: $e');
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Aquí puedes agregar la lógica para enviar el formulario
      print('Form submitted');
      print('Title: ${_titleController.text}');
      print('Description: ${_descriptionController.text}');
      print('Category: $_selectedCategory');
      print('Reward: $_selectedReward');
      if (_selectedReward == 'Sí') {
        print('Reward Amount: ${_rewardAmountController.text}');
        print('Reward Message: ${_rewardMessageController.text}');
      }
      print('Location: ${_locationController.text}');
      print('Number of images: ${_images.length}');

      // Mostrar diálogo de éxito
      _showSuccessDialog();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _rewardAmountController.dispose();
    _rewardMessageController.dispose();
    super.dispose();
  }
}

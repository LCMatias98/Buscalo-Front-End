import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';

class FoundObjectForm extends StatefulWidget {
  @override
  _FoundObjectFormState createState() => _FoundObjectFormState();
}

class _FoundObjectFormState extends State<FoundObjectForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  String? _selectedCategory;
  String? _selectedReward;

  List<String> _locationSuggestions = [];

  final List<String> _categories = [
    'Documentos',
    'Electrónicos',
    'Ropa',
    'Objetos personales',
  ];
  final List<String> _rewards = ['No', 'Sí'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrar Objeto Encontrado',
            style: TextStyle(color: Colors.white)),
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

                // Location field with suggestions
                TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    labelText: 'Ubicación',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.my_location),
                      onPressed: _selectCurrentLocation,
                    ),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.teal[50],
                  ),
                  onChanged: (value) => _fetchLocationSuggestions(value),
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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final formData = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'category': _selectedCategory,
        'reward': _selectedReward,
        'location': _locationController.text,
      };

      // TODO: Send formData to the backend

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Formulario enviado con éxito')),
      );
    }
  }

  Future<void> _fetchLocationSuggestions(String query) async {
    if (query.isEmpty) {
      setState(() {
        _locationSuggestions.clear();
      });
      return;
    }

    final url =
        'https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&accept-language=es';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        setState(() {
          _locationSuggestions =
              data.map((item) => item['display_name'] as String).toList();
        });
      }
    } catch (e) {
      print('Error fetching location suggestions: $e');
    }
  }

  Future<void> _selectCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verifica si los servicios de ubicación están habilitados
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Los servicios de ubicación están deshabilitados.')),
      );
      return;
    }

    // Verifica los permisos de ubicación
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Permiso de ubicación denegado.')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Permiso de ubicación permanentemente denegado.')),
      );
      return;
    }

    try {
      // Obtén la ubicación actual
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // Primero guarda las coordenadas
      setState(() {
        _locationController.text =
            '${position.latitude}, ${position.longitude}';
      });

      // Luego obtén la dirección
      await _getAddressFromCoordinates(position.latitude, position.longitude);
    } catch (e) {
      print('Error obteniendo la ubicación: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al obtener la ubicación actual.')),
      );
    }
  }

  Future<void> _getAddressFromCoordinates(
      double latitude, double longitude) async {
    final url =
        'https://nominatim.openstreetmap.org/reverse?lat=$latitude&lon=$longitude&format=json&addressdetails=1&accept-language=es';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept-Language': 'es'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Respuesta JSON: $data');

        if (data['address'] != null) {
          final address = data['address'];
          String formattedAddress = '';

          // Primero tomamos la calle y altura
          final street = address['road'] ?? '';
          final number = address['house_number'] ?? '';

          // Si tenemos calle y/o altura, las ponemos primero
          if (street.isNotEmpty || number.isNotEmpty) {
            formattedAddress = '${street} ${number}'.trim();
          }

          // Agregamos el resto de la información relevante
          final suburb = address['suburb'] ?? '';
          final city = address['city'] ?? '';
          final state = address['state'] ?? '';
          final postcode = address['postcode'] ?? '';

          // Solo agregamos las partes que existan
          if (suburb.isNotEmpty) formattedAddress += ', $suburb';
          if (city.isNotEmpty) formattedAddress += ', $city';
          if (state.isNotEmpty) formattedAddress += ', $state';
          if (postcode.isNotEmpty) formattedAddress += ', $postcode';

          setState(() {
            _locationController.text = formattedAddress;
          });
        }
      }
    } catch (e) {
      print('Error obteniendo la dirección: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al obtener la dirección.')),
      );
    }
  }
}

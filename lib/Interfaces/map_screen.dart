import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();

  LatLng _center = LatLng(-34.61315, -58.37723); // Gran Buenos Aires (CABA)

  void _searchLocation() async {
    try {
      String query = _searchController.text;
      if (query.isEmpty) return;

      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        final newLocation =
            LatLng(locations[0].latitude, locations[0].longitude);
        setState(() {
          _center = newLocation;
        });
        _mapController.move(_center, 15.0); // Mover el mapa y acercar el zoom
      }
    } catch (e) {
      print('Error buscando dirección: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo encontrar la dirección')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscalo'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Buscar dirección',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _searchLocation,
                  child: const Text('Buscar'),
                ),
              ],
            ),
          ),
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: _center,
                zoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                  userAgentPackageName: 'com.buscalo.app',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

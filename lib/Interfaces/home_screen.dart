import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'menu_widget.dart';
import 'notification_icon.dart';
import 'found_object_form.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1; // Por defecto "Buscar"
  int _notificationCount = 3; // Simulación de notificaciones

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscalo'),
        actions: [
          NotificationIcon(notificationCount: _notificationCount),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: MenuWidget(
        selectedIndex: _selectedIndex,
        onItemSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return Center(child: Text('Chat'));
      case 1:
        return FlutterMap(
          options: MapOptions(
            center: LatLng(-34.6083, -58.3712), // Gran Buenos Aires
            zoom: 10.0,
          ),
          children: [
            TileLayer(
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: ['a', 'b', 'c'],
              userAgentPackageName: 'com.buscalo.app',
            ),
          ],
        );
      case 2:
        return FoundObjectForm(); // Mostrar el formulario aquí
      case 3:
        return Center(child: Text('Mi Perfil'));
      default:
        return Center(child: Text('Opción no encontrada'));
    }
  }
}

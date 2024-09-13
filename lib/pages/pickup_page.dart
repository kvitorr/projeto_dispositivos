import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PickupPage extends StatefulWidget {
  @override
  _PickupPageState createState() => _PickupPageState();
}

class _PickupPageState extends State<PickupPage> {
  late GoogleMapController _mapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Selecione o Local de Entrega'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(-23.5505, -46.6333), // São Paulo como localização inicial
          zoom: 12,
        ),
        onMapCreated: (controller) {
          _mapController = controller;
        },
      ),
    );
  }
}

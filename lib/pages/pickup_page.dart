import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SelectPickupLocationPage extends StatefulWidget {
  @override
  _SelectPickupLocationPageState createState() => _SelectPickupLocationPageState();
}

class _SelectPickupLocationPageState extends State<SelectPickupLocationPage> {
  late GoogleMapController mapController;

  final LatLng _pickupPoint1 = LatLng(-23.550520, -46.633308); // Ponto 1
  final LatLng _pickupPoint2 = LatLng(-23.551520, -46.634308); // Ponto 2
  LatLng? _selectedPoint;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _selectPickupLocation(LatLng point) {
    setState(() {
      _selectedPoint = point;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Selecione o Local de Retirada'),
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _pickupPoint1,
                zoom: 15.0,
              ),
              markers: {
                Marker(
                  markerId: MarkerId('pickup1'),
                  position: _pickupPoint1,
                  onTap: () => _selectPickupLocation(_pickupPoint1),
                ),
                Marker(
                  markerId: MarkerId('pickup2'),
                  position: _pickupPoint2,
                  onTap: () => _selectPickupLocation(_pickupPoint2),
                ),
              },
            ),
          ),
          if (_selectedPoint != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  // Adicione a lógica para salvar o pedido com o local de retirada selecionado
                  Navigator.pop(context, _selectedPoint);
                },
                child: Text('Confirmar Local de Retirada'),
              ),
            ),
        ],
      ),
    );
  }
}

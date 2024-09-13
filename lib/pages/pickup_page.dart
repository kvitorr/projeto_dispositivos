import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SelectPickupLocationPage extends StatefulWidget {
  @override
  _SelectPickupLocationPageState createState() => _SelectPickupLocationPageState();
}

class _SelectPickupLocationPageState extends State<SelectPickupLocationPage> {
  late GoogleMapController mapController;
  final LatLng _pickupPoint1 = const LatLng(-5.0884538, -42.815725); // Ponto 1
  final LatLng _pickupPoint2 = const LatLng(-5.1022707, -42.813062); // Ponto 2

  final String _pickupName1 = "Snacks Central"; // Nome do ponto 1
  final String _pickupName2 = "Snacks Sul"; // Nome do ponto 2

  LatLng? _selectedPoint;
  String? _selectedLocationName;

  @override
  void initState() {
    super.initState();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _selectPickupLocation(LatLng point, String locationName) {
    setState(() {
      _selectedPoint = point;
      _selectedLocationName = locationName;
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
              myLocationEnabled: false,
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _pickupPoint1,
                zoom: 15.0,
              ),
              markers: {
                Marker(
                  markerId: MarkerId('pickup1'),
                  position: _pickupPoint1,
                  onTap: () => _selectPickupLocation(_pickupPoint1, _pickupName1),
                ),
                Marker(
                  markerId: MarkerId('pickup2'),
                  position: _pickupPoint2,
                  onTap: () => _selectPickupLocation(_pickupPoint2, _pickupName2),
                ),
              },
            ),
          ),
          if (_selectedPoint != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('Local Selecionado: $_selectedLocationName'), // Nome exibido
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, {
                        'location': _selectedPoint,
                        'name': _selectedLocationName,
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Color(0xFFBF0603), // Cor de fundo do botão
                      foregroundColor: Colors.white, // Cor do texto do botão
                    ),
                    child: Text('Finalizar Pedido'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
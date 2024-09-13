import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class SelectPickupLocationPage extends StatefulWidget {
  @override
  _SelectPickupLocationPageState createState() => _SelectPickupLocationPageState();
}

class _SelectPickupLocationPageState extends State<SelectPickupLocationPage> {
  late GoogleMapController mapController;
  final LatLng _pickupPoint1 = const LatLng(-23.550520, -46.633308); // Ponto 1
  final LatLng _pickupPoint2 = const LatLng(-23.551520, -46.634308); // Ponto 2
  LatLng? _selectedPoint;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  void _requestLocationPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      // A permissão foi concedida
    } else if (status.isDenied || status.isPermanentlyDenied) {
      // A permissão foi negada
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('A permissão de localização é necessária para continuar.')),
      );
    }
  }

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

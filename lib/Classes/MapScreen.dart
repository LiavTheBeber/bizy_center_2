import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  final LatLng initialPosition;

  const MapScreen({required this.initialPosition, Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  late Marker _marker;

  @override
  void initState() {
    super.initState();
    _marker = Marker(
      markerId: MarkerId('initial_marker'),
      position: widget.initialPosition,
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: _onMapCreated,
      zoomControlsEnabled: false, // Disable zoom controls
      myLocationEnabled: false, // Disable location button
      scrollGesturesEnabled: false, // Disable scroll gestures
      rotateGesturesEnabled: false, // Disable rotate gestures
      tiltGesturesEnabled: false, // Disable tilt gestures
      initialCameraPosition: CameraPosition(
        target: widget.initialPosition,
        zoom: 24.0,
      ),
      markers: {_marker},
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:location/location.dart';
//
// class TrackDeliveryScreen extends StatefulWidget {
//   const TrackDeliveryScreen({Key? key}) : super(key: key);
//
//   @override
//   State<TrackDeliveryScreen> createState() => _TrackDeliveryScreenState();
// }
//
// class _TrackDeliveryScreenState extends State<TrackDeliveryScreen> {
//   GoogleMapController? mapController;
//   final Location _location = Location();
//   final Set<Marker> _markers = {};
//   LatLng? _currentLocation;
//   // Example delivery guy location (you'll need to replace this with real-time data)
//   final LatLng _deliveryGuyLocation = const LatLng(37.42796133580664, -122.085749655962);
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeLocation();
//     _markers.add(
//       Marker(
//         markerId: const MarkerId('deliveryGuy'),
//         position: _deliveryGuyLocation,
//         infoWindow: const InfoWindow(title: 'Delivery Partner'),
//       ),
//     );
//   }
//
//   Future<void> _initializeLocation() async {
//     try {
//       final hasPermission = await _checkLocationPermission();
//       if (hasPermission) {
//         final locationData = await _location.getLocation();
//         setState(() {
//           _currentLocation = LatLng(locationData.latitude!, locationData.longitude!);
//           _markers.add(
//             Marker(
//               markerId: const MarkerId('currentLocation'),
//               position: _currentLocation!,
//               infoWindow: const InfoWindow(title: 'Your Location'),
//             ),
//           );
//         });
//       }
//     } catch (e) {
//       print('Error getting location: $e');
//     }
//   }
//
//   Future<bool> _checkLocationPermission() async {
//     bool serviceEnabled;
//     PermissionStatus permissionGranted;
//
//     serviceEnabled = await _location.serviceEnabled();
//     if (!serviceEnabled) {
//       serviceEnabled = await _location.requestService();
//       if (!serviceEnabled) {
//         return false;
//       }
//     }
//
//     permissionGranted = await _location.hasPermission();
//     if (permissionGranted == PermissionStatus.denied) {
//       permissionGranted = await _location.requestPermission();
//       if (permissionGranted != PermissionStatus.granted) {
//         return false;
//       }
//     }
//
//     return true;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Track Delivery'),
//       ),
//       body: GoogleMap(
//         onMapCreated: (GoogleMapController controller) {
//           mapController = controller;
//         },
//         initialCameraPosition: CameraPosition(
//           target: _currentLocation ?? _deliveryGuyLocation,
//           zoom: 15,
//         ),
//         markers: _markers,
//         myLocationEnabled: true,
//         myLocationButtonEnabled: true,
//         mapType: MapType.normal,
//         zoomControlsEnabled: true,
//       ),
//     );
//   }
// }

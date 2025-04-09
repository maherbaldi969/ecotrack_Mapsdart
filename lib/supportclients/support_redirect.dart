import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'support_style.dart';

class SupportRedirect extends StatefulWidget {
  const SupportRedirect({super.key});

  @override
  State<SupportRedirect> createState() => _SupportRedirectState();
}

class _SupportRedirectState extends State<SupportRedirect> {
  late GoogleMapController mapController;
  final LatLng _center = const LatLng(36.8065, 10.1815); // Coordonnées Tunis

  final Set<Marker> _markers = {
    Marker(
      markerId: MarkerId('partner1'),
      position: LatLng(36.8065, 10.1815),
      infoWindow: InfoWindow(
        title: 'Partenaire Tunis',
        snippet: 'Ouvert 24/7 - Assistance touristique',
      ),
    ),
    // Ajouter d'autres marqueurs selon les partenaires
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Partenaires locaux', style: merriweatherBold),
        backgroundColor: vertPrimaire,
        foregroundColor: blanc,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Trouvez un partenaire près de vous',
              style: merriweatherNormal.copyWith(fontSize: 16),
            ),
          ),
          Expanded(
            child: GoogleMap(
              onMapCreated: (controller) {
                setState(() {
                  mapController = controller;
                });
              },
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 11.0,
              ),
              markers: _markers,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: boutonVert,
              onPressed: () {
                // Intégrer l'appel téléphonique ici
              },
              child: Text('Contacter un partenaire', style: merriweatherBold),
            ),
          ),
        ],
      ),
    );
  }
}

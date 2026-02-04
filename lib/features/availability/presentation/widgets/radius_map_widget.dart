import 'package:app/core/domain/addresses/address_info_entity.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Widget para exibir um mapa com círculo representando o raio de atuação
class RadiusMapWidget extends StatefulWidget {
  final AddressInfoEntity address;
  final double radiusKm;
  final ValueChanged<double>? onRadiusChanged;

  const RadiusMapWidget({
    super.key,
    required this.address,
    required this.radiusKm,
    this.onRadiusChanged,
  });

  @override
  State<RadiusMapWidget> createState() => _RadiusMapWidgetState();
}

class _RadiusMapWidgetState extends State<RadiusMapWidget> {
  GoogleMapController? _mapController;
  double _currentRadius = 0;

  @override
  void initState() {
    super.initState();
    _currentRadius = widget.radiusKm;
  }

  @override
  void didUpdateWidget(RadiusMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.radiusKm != widget.radiusKm) {
      setState(() {
        _currentRadius = widget.radiusKm;
      });
      _updateCamera();
    }
    if ((oldWidget.address.latitude ?? -23.5505) != (widget.address.latitude ?? -23.5505) ||
        (oldWidget.address.longitude ?? -46.6333) != (widget.address.longitude ?? -46.6333)) {
      _updateCamera();
    }
  }

  void _updateCamera() {
    if (_mapController != null) {
      final centerLat = widget.address.latitude ?? -23.5505;
      final centerLng = widget.address.longitude ?? -46.6333;
      final center = LatLng(centerLat, centerLng);
      
      // Calcula o zoom baseado no raio (quanto maior o raio, menor o zoom)
      // Fórmula aproximada: zoom menor para raios maiores
      double zoom = 13.0;
      if (_currentRadius > 0) {
        // Ajusta o zoom para que o círculo fique visível
        if (_currentRadius < 5) {
          zoom = 13.0;
        } else if (_currentRadius < 10) {
          zoom = 12.0;
        } else if (_currentRadius < 20) {
          zoom = 11.0;
        } else if (_currentRadius < 50) {
          zoom = 10.0;
        } else {
          zoom = 9.0;
        }
      }

      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(center, zoom),
      );
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  // Converte raio em km para metros (Google Maps usa metros)
  double _radiusInMeters() {
    return _currentRadius * 1000;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final centerLat = widget.address.latitude ?? -23.5505;
    final centerLng = widget.address.longitude ?? -46.6333;

    return Container(
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(centerLat, centerLng),
            zoom: 13.0,
          ),
          onMapCreated: (controller) {
            _mapController = controller;
            _updateCamera();
          },
          markers: {
            Marker(
              markerId: const MarkerId('address'),
              position: LatLng(centerLat, centerLng),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueBlue,
              ),
            ),
          },
          circles: {
            Circle(
              circleId: const CircleId('radius'),
              center: LatLng(centerLat, centerLng),
              radius: _radiusInMeters(),
              fillColor: colorScheme.onPrimaryContainer.withOpacity(0.2),
              strokeColor: colorScheme.onPrimaryContainer,
              strokeWidth: 2,
            ),
          },
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
        ),
      ),
    );
  }
}


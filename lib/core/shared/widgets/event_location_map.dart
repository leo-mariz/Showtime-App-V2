import 'dart:math';
import 'package:app/core/domain/addresses/address_info_entity.dart';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Widget para exibir um mapa com a localização de um evento
class EventLocationMap extends StatefulWidget {
  final AddressInfoEntity address;
  final double? height;
  final bool showExactLocation; // true = localização exata, false = localização aproximada
  final String? seed; // Seed para gerar localização aleatória consistente (opcional)

  const EventLocationMap({
    super.key,
    required this.address,
    this.height,
    this.showExactLocation = true,
    this.seed, // Se fornecido, garante que a localização aleatória seja sempre a mesma
  });

  @override
  State<EventLocationMap> createState() => _EventLocationMapState();
}

class _EventLocationMapState extends State<EventLocationMap> {
  GoogleMapController? _mapController;
  bool _isMapStyleLoaded = false;
  late final LatLng _displayLocation; // Localização a ser exibida (pode ser aproximada)

  @override
  void initState() {
    super.initState();
    _displayLocation = _calculateDisplayLocation();
    _loadMapStyle();
  }

  /// Calcula a localização a ser exibida no mapa
  /// Se showExactLocation for false, gera uma localização aleatória dentro de 300m
  LatLng _calculateDisplayLocation() {
    final realLat = widget.address.latitude ?? -23.5505;
    final realLng = widget.address.longitude ?? -46.6333;

    if (widget.showExactLocation) {
      // Mostrar localização exata
      return LatLng(realLat, realLng);
    }

    // Gerar localização aleatória dentro de 300m de raio
    return _generateRandomLocationNearby(realLat, realLng, radiusMeters: 200);
  }

  /// Gera uma localização aleatória dentro de um raio específico (em metros)
  /// 
  /// [centerLat]: Latitude do centro
  /// [centerLng]: Longitude do centro
  /// [radiusMeters]: Raio máximo em metros (padrão: 300m)
  LatLng _generateRandomLocationNearby(
    double centerLat,
    double centerLng, {
    double radiusMeters = 300,
  }) {
    // Usar seed se fornecido para garantir localização consistente
    final random = widget.seed != null 
        ? Random(widget.seed!.hashCode) 
        : Random();
    
    // Gerar ângulo aleatório (0 a 2π)
    final angle = random.nextDouble() * 2 * pi;
    
    // Gerar distância aleatória entre 0 e radiusMeters (em metros)
    final distance = random.nextDouble() * radiusMeters;
    
    // Converter distância em metros para graus
    // 1 grau de latitude ≈ 111km = 111000m
    // 1 grau de longitude ≈ 111km * cos(latitude) ≈ 111000m * cos(latitude)
    final latOffset = distance / 111000.0;
    final lngOffset = distance / (111000.0 * cos(centerLat * pi / 180));
    
    // Calcular nova posição
    final newLat = centerLat + (latOffset * sin(angle));
    final newLng = centerLng + (lngOffset * cos(angle));
    
    return LatLng(newLat, newLng);
  }

  Future<void> _loadMapStyle() async {
    if (_isMapStyleLoaded) return;
    
    try {
      final String mapStyle = await rootBundle.loadString('assets/map_style.json');
      _isMapStyleLoaded = true;
      
      // Aplicar estilo quando o mapa for criado
      if (_mapController != null) {
        _mapController!.setMapStyle(mapStyle);
      }
    } catch (e) {
      // Se não conseguir carregar o estilo, continua sem estilo customizado
      debugPrint('Erro ao carregar estilo do mapa: $e');
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_isMapStyleLoaded) {
      _loadMapStyle();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final height = widget.height ?? 200.0;

    // Verificar se temos coordenadas válidas
    if (widget.address.latitude == null || widget.address.longitude == null) {
      return Container(
        height: DSSize.height(height),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(DSSize.width(12)),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_off_rounded,
                size: DSSize.width(48),
                color: colorScheme.onSurfaceVariant.withOpacity(0.5),
              ),
              SizedBox(height: DSSize.height(8)),
              Text(
                'Localização não disponível',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: DSSize.height(height),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DSSize.width(12)),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(DSSize.width(12)),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _displayLocation,
            zoom: widget.showExactLocation ? 15.0 : 14.0, // Zoom um pouco menor quando aproximado
          ),
          onMapCreated: _onMapCreated,
          markers: {
            if (widget.showExactLocation)
            Marker(
              markerId: const MarkerId('event_location'),
              position: _displayLocation,
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueRed, // Vermelho para marcar o evento
              ),
            ),
          },
          // Mostrar círculo de privacidade quando não mostrar localização exata
          circles: widget.showExactLocation
              ? {}
              : {
                  Circle(
                    circleId: const CircleId('privacy_radius'),
                    center: _displayLocation,
                    radius: 300, // 200 metros de raio
                    fillColor: colorScheme.onPrimaryContainer.withOpacity(0.15),
                    strokeColor: colorScheme.onPrimaryContainer.withOpacity(0.4),
                    strokeWidth: 2,
                  ),
                },
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          compassEnabled: false,
          rotateGesturesEnabled: false,
          scrollGesturesEnabled: true,
          tiltGesturesEnabled: false,
          zoomGesturesEnabled: true,
        ),
      ),
    );
  }
}


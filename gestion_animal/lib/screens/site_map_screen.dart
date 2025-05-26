import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:gestion_animal/models/site.dart';
class SiteMapScreen extends StatefulWidget {
  final List sites;
  const SiteMapScreen({Key? key, required this.sites}) : super(key: key);
  @override
  SiteMapScreenState createState() => SiteMapScreenState();
}
class SiteMapScreenState extends State {
  late MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }
  @override
  Widget build(BuildContext context) {
    // Calculer le centre de la carte en fonction des sites
    LatLng center;
    if (widget.sites.isEmpty) {
      // Coordonnées par défaut (Paris)
      center = const LatLng(48.8566, 2.3522);
    } else {
      // Calculer le centre des sites
      double sumLat = 0;
      double sumLng = 0;
      for (var site in widget.sites) {
        sumLat += site.latitude;
        sumLng += site.longitude;
      }
      center = LatLng(sumLat / widget.sites.length, sumLng / widget.sites.length);
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carte des sites'),
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          center: center,
          zoom: 10.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.flutter_anim_app',
          ),
          MarkerLayer(
            markers: widget.sites.map((site) {
              return Marker(
                width: 80.0,
                height: 80.0,
                point: LatLng(site.latitude, site.longitude),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: site.status.toLowerCase() == 'complet' ? Colors.green : Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 30.0,
                      ),
                    ),
                    Text(
                      'Site #${site.id}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12.0,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'zoomIn',
            onPressed: () {
              _mapController.move(_mapController.center, _mapController.zoom + 1);
            },
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'zoomOut',
            onPressed: () {
              _mapController.move(_mapController.center, _mapController.zoom - 1);
            },
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}

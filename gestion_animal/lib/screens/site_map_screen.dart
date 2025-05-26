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
            userAgentPackageName: 'com.example.gestion_animal',
          ),
          MarkerLayer(
            markers: widget.sites.map((site) {
              return Marker(
                width: 80.0,
                height: 80.0,
                point: LatLng(site.latitude, site.longitude),
                builder: (ctx) => GestureDetector(
                  onTap: () {
                    _showSiteInfo(site);
                  },
                  child: Container(
                    child: Icon(
                      Icons.location_on,
                      color: _getStatusColor(site.status),
                      size: 40.0,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _mapController.move(center, 10.0);
        },
        child: const Icon(Icons.center_focus_strong),
      ),
    );
  }
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'vide':
        return Colors.grey;
      case 'occupé':
        return Colors.green;
      case 'maintenance':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }
  void _showSiteInfo(Site site) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Informations du site'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Latitude: ${site.latitude}'),
            Text('Longitude: ${site.longitude}'),
            Text('Statut: ${site.status}'),
            if (site.notes != null && site.notes!.isNotEmpty)
              Text('Notes: ${site.notes}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}
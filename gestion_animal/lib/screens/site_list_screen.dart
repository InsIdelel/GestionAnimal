import 'package:flutter/material.dart';
import 'package:gestion_animal/models/flock.dart';
import 'package:gestion_animal/models/site.dart';
import 'package:gestion_animal/screens/site_form_screen.dart';
import 'package:gestion_animal/screens/site_map_screen.dart';
import 'package:gestion_animal/screens/visit_list_screen.dart';
import 'package:gestion_animal/services/site_service.dart';

class SiteListScreen extends StatefulWidget {
  final Flock flock;
  final List<Site> initialSites;

  const SiteListScreen({
    Key? key,
    required this.flock,
    required this.initialSites,
  }) : super(key: key);

  @override
  SiteListScreenState createState() => SiteListScreenState();
}

class SiteListScreenState extends State<SiteListScreen> {
  late List<Site> _sites;
  final SiteService _siteService = SiteService();
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _sites = widget.initialSites;
  }

  Future<void> _refreshSites() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final siteList = await _siteService.getSitesByFlock(widget.flock.id!);
      setState(() {
        _sites = siteList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _navigateToSiteForm({Site? site}) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SiteFormScreen(
          flock: widget.flock,
          site: site,
        ),
      ),
    );

    if (result == true) {
      _refreshSites();
    }
  }

  void _navigateToVisitList(Site site) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VisitListScreen(site: site),
      ),
    );
  }

  void _navigateToSiteMap() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SiteMapScreen(sites: _sites),
      ),
    );
  }

  void _confirmDeleteSite(Site site) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le site'),
        content: Text('Êtes-vous sûr de vouloir supprimer ce site ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              setState(() {
                _isLoading = true;
              });

              try {
                final success = await _siteService.deleteSite(site.id!);
                if (mounted) {
                  if (success) {
                    _refreshSites();
                  } else {
                    setState(() {
                      _error = 'Erreur lors de la suppression du site';
                      _isLoading = false;
                    });
                  }
                }
              } catch (e) {
                if (mounted) {
                  setState(() {
                    _error = e.toString();
                    _isLoading = false;
                  });
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  String _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'vide':
        return 'Gris';
      case 'occupé':
        return 'Vert';
      case 'maintenance':
        return 'Orange';
      default:
        return 'Inconnu';
    }
  }

  Color _getStatusColorValue(String status) {
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Erreur: $_error',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshSites,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          if (_sites.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: _navigateToSiteMap,
                icon: const Icon(Icons.map),
                label: const Text('Voir la carte'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
            ),
          Expanded(
            child: _sites.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Aucun site trouvé',
                          style: TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _navigateToSiteForm(),
                          child: const Text('Ajouter un site'),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _refreshSites,
                    child: ListView.builder(
                      itemCount: _sites.length,
                      itemBuilder: (context, index) {
                        final site = _sites[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            title: Text(
                              'Site #${index + 1}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Latitude: ${site.latitude}'),
                                Text('Longitude: ${site.longitude}'),
                                Text('Statut: ${site.status} (${_getStatusColor(site.status)})'),
                                if (site.notes != null && site.notes!.isNotEmpty)
                                  Text('Notes: ${site.notes}'),
                              ],
                            ),
                            leading: CircleAvatar(
                              backgroundColor: _getStatusColorValue(site.status),
                              child: const Icon(Icons.location_on, color: Colors.white),
                            ),
                            trailing: PopupMenuButton(
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'visits',
                                  child: Row(
                                    children: [
                                      Icon(Icons.visibility, size: 18),
                                      SizedBox(width: 8),
                                      Text('Visites'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, size: 18),
                                      SizedBox(width: 8),
                                      Text('Modifier'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, size: 18, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text('Supprimer', style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                ),
                              ],
                              onSelected: (value) {
                                if (value == 'visits') {
                                  _navigateToVisitList(site);
                                } else if (value == 'edit') {
                                  _navigateToSiteForm(site: site);
                                } else if (value == 'delete') {
                                  _confirmDeleteSite(site);
                                }
                              },
                            ),
                            onTap: () => _navigateToVisitList(site),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToSiteForm(),
        tooltip: 'Ajouter un site',
        child: const Icon(Icons.add),
      ),
    );
  }
}


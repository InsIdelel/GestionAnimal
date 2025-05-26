import 'package:flutter/material.dart';
import 'package:gestion_animal/models/flock.dart';
import 'package:gestion_animal/models/sheep.dart';
import 'package:gestion_animal/screens/sheep_form_screen.dart';
import 'package:gestion_animal/services/sheep_service.dart';
class SheepListScreen extends StatefulWidget {
  final Flock flock;
  final List initialSheep;
  const SheepListScreen({
    Key? key,
    required this.flock,
    required this.initialSheep,
  }) : super(key: key);
  @override
  SheepListScreenState createState() => SheepListScreenState();
}
class SheepListScreenState extends State {
  late List _sheep;
  final SheepService _sheepService = SheepService();
  bool _isLoading = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    _sheep = widget.initialSheep;
  }
  Future _refreshSheep() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final sheepList = await _sheepService.getSheepByFlock(widget.flock.id!);
      setState(() {
        _sheep = sheepList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }
  void _navigateToSheepForm({Sheep? sheep}) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SheepFormScreen(
          flock: widget.flock,
          sheep: sheep,
        ),
      ),
    );
    if (result == true) {
      _refreshSheep();
    }
  }
  void _confirmDeleteSheep(Sheep sheep) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le mouton'),
        content: Text('Êtes-vous sûr de vouloir supprimer le mouton "${sheep.idBoucle}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              setState(() => _isLoading = true);

              try {
                final success = await _sheepService.deleteSheep(sheep.idBoucle);
                if (success) {
                  _refreshSheep();
                } else {
                  setState(() {
                    _error = 'Échec de la suppression du mouton.';
                    _isLoading = false;
                  });
                }
              } catch (e) {
                setState(() {
                  _error = e.toString();
                  _isLoading = false;
                });
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
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
              onPressed: _refreshSheep,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }
    if (_sheep.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Aucun mouton trouvé',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _navigateToSheepForm(),
              child: const Text('Ajouter un mouton'),
            ),
          ],
        ),
      );
    }
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshSheep,
        child: ListView.builder(
          itemCount: _sheep.length,
          itemBuilder: (context, index) {
            final sheep = _sheep[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(
                  'ID: ${sheep.idBoucle}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Race: ${sheep.race} | Sexe: ${sheep.sexe} | Âge: ${sheep.age} ans'),
                leading: CircleAvatar(
                  backgroundColor: _getColorFromString(sheep.couleur),
                  child: const Icon(Icons.pets, color: Colors.white),
                ),
                trailing: PopupMenuButton(
                  itemBuilder: (context) => [
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
                    if (value == 'edit') {
                      _navigateToSheepForm(sheep: sheep);
                    } else if (value == 'delete') {
                      _confirmDeleteSheep(sheep);
                    }
                  },
                ),
                onTap: () => _navigateToSheepForm(sheep: sheep),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToSheepForm(),
        tooltip: 'Ajouter un mouton',
        child: const Icon(Icons.add),
      ),
    );
  }
  Color _getColorFromString(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'blanc':
        return Colors.white;
      case 'noir':
        return Colors.black;
      case 'marron':
      case 'brun':
        return Colors.brown;
      case 'gris':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }
}

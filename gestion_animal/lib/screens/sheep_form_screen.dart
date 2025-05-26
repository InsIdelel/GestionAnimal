import 'package:flutter/material.dart';
import 'package:gestion_animal/models/flock.dart';
import 'package:gestion_animal/models/sheep.dart';
import 'package:gestion_animal/services/sheep_service.dart';
class SheepFormScreen extends StatefulWidget {
  final Flock flock;
  final Sheep? sheep;
  const SheepFormScreen({
    Key? key,
    required this.flock,
    this.sheep,
  }) : super(key: key);
  @override
  SheepFormScreenState createState() => SheepFormScreenState();
}
class SheepFormScreenState extends State {
  final _formKey = GlobalKey();
  final _idBoucleController = TextEditingController();
  final _ageController = TextEditingController();

  String _race = 'Mérinos';
  String _sexe = 'Femelle';
  String _couleur = 'Blanc';

  bool _isLoading = false;
  String? _error;
  bool _isEditing = false;
  final List _races = ['Mérinos', 'Suffolk', 'Texel', 'Lacaune', 'Romanov', 'Autre'];
  final List _sexes = ['Mâle', 'Femelle'];
  final List _couleurs = ['Blanc', 'Noir', 'Marron', 'Gris'];
  @override
  void initState() {
    super.initState();
    _isEditing = widget.sheep != null;

    if (_isEditing) {
      _idBoucleController.text = widget.sheep!.idBoucle;
      _ageController.text = widget.sheep!.age.toString();
      _race = widget.sheep!.race;
      _sexe = widget.sheep!.sexe;
      _couleur = widget.sheep!.couleur;
    }
  }
  @override
  void dispose() {
    _idBoucleController.dispose();
    _ageController.dispose();
    super.dispose();
  }
  Future _saveSheep() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      try {
        final sheepService = SheepService();
        final sheep = Sheep(
          idBoucle: _idBoucleController.text.trim(),
          race: _race,
          sexe: _sexe,
          age: int.parse(_ageController.text.trim()),
          couleur: _couleur,
          flockId: widget.flock.id!,
        );
        bool success;
        if (_isEditing) {
          final updatedSheep = await sheepService.updateSheep(sheep);
          success = updatedSheep != null;
        } else {
          final newSheep = await sheepService.createSheep(sheep);
          success = newSheep != null;
        }
        if (success && mounted) {
          Navigator.of(context).pop(true);
        } else {
          setState(() {
            _error = 'Échec de l\'enregistrement du mouton.';
            _isLoading = false;
          });
        }
      } catch (e) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifier le mouton' : 'Ajouter un mouton'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _idBoucleController,
                  decoration: const InputDecoration(
                    labelText: 'ID Boucle',
                    border: OutlineInputBorder(),
                    helperText: 'Identifiant unique du mouton',
                  ),
                  enabled: !_isEditing, // Désactiver la modification de l'ID en mode édition
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un ID';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField(
                  value: _race,
                  decoration: const InputDecoration(
                    labelText: 'Race',
                    border: OutlineInputBorder(),
                  ),
                  items: _races.map((race) {
                    return DropdownMenuItem(
                      value: race,
                      child: Text(race),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _race = value;
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez sélectionner une race';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField(
                  value: _sexe,
                  decoration: const InputDecoration(
                    labelText: 'Sexe',
                    border: OutlineInputBorder(),
                  ),
                  items: _sexes.map((sexe) {
                    return DropdownMenuItem(
                      value: sexe,
                      child: Text(sexe),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _sexe = value;
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez sélectionner un sexe';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ageController,
                  decoration: const InputDecoration(
                    labelText: 'Âge (années)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un âge';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Veuillez entrer un nombre valide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField(
                  value: _couleur,
                  decoration: const InputDecoration(
                    labelText: 'Couleur',
                    border: OutlineInputBorder(),
                  ),
                  items: _couleurs.map((couleur) {
                    return DropdownMenuItem(
                      value: couleur,
                      child: Text(couleur),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _couleur = value;
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez sélectionner une couleur';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveSheep,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : Text(_isEditing ? 'Enregistrer' : 'Ajouter'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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

class SheepFormScreenState extends State<SheepFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idBoucleController = TextEditingController();
  final _ageController = TextEditingController();
  
  String _race = 'Mérinos';
  String _sexe = 'Femelle';
  String _couleur = 'Blanc';
  
  bool _isLoading = false;
  String? _error;
  bool _isEditing = false;

  final SheepService _sheepService = SheepService();

  final List<String> _races = ['Mérinos', 'Suffolk', 'Texel', 'Romanov', 'Lacaune', 'Autre'];
  final List<String> _sexes = ['Mâle', 'Femelle'];
  final List<String> _couleurs = ['Blanc', 'Noir', 'Marron', 'Tacheté', 'Autre'];

  @override
  void initState() {
    super.initState();
    if (widget.sheep != null) {
      _isEditing = true;
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

  Future<void> _saveSheep() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      try {
        final sheep = Sheep(
          id: _isEditing ? widget.sheep!.id : null,
          idBoucle: _idBoucleController.text.trim(),
          age: int.parse(_ageController.text.trim()),
          race: _race,
          sexe: _sexe,
          couleur: _couleur,
          flockId: widget.flock.id!,
        );

        bool success;
        if (_isEditing) {
          success = await _sheepService.updateSheep(sheep);
        } else {
          success = await _sheepService.createSheep(sheep);
        }

        if (mounted) {
          if (success) {
            Navigator.of(context).pop(true);
          } else {
            setState(() {
              _error = 'Erreur lors de l\'enregistrement du mouton';
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifier le mouton' : 'Ajouter un mouton'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    TextFormField(
                      controller: _idBoucleController,
                      decoration: const InputDecoration(
                        labelText: 'ID Boucle',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer l\'ID de la boucle';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _ageController,
                      decoration: const InputDecoration(
                        labelText: 'Âge (en mois)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer l\'âge';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Veuillez entrer un nombre valide';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
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
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
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
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
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
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _saveSheep,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        _isEditing ? 'Enregistrer les modifications' : 'Ajouter le mouton',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}


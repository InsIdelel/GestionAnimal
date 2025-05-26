import 'package:flutter/material.dart';
import 'package:gestion_animal/models/flock.dart';
import 'package:gestion_animal/models/site.dart';
import 'package:gestion_animal/services/site_service.dart';
class SiteFormScreen extends StatefulWidget {
  final Flock flock;
  final Site? site;
  const SiteFormScreen({
    Key? key,
    required this.flock,
    this.site,
  }) : super(key: key);
  @override
  SiteFormScreenState createState() => SiteFormScreenState();
}
class SiteFormScreenState extends State {
  final _formKey = GlobalKey();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _notesController = TextEditingController();

  String _status = 'vide';

  bool _isLoading = false;
  String? _error;
  bool _isEditing = false;
  final List _statusOptions = ['vide', 'complet'];
  @override
  void initState() {
    super.initState();
    _isEditing = widget.site != null;

    if (_isEditing) {
      _latitudeController.text = widget.site!.latitude.toString();
      _longitudeController.text = widget.site!.longitude.toString();
      _notesController.text = widget.site!.notes ?? '';
      _status = widget.site!.status;
    }
  }
  @override
  void dispose() {
    _latitudeController.dispose();
    _longitudeController.dispose();
    _notesController.dispose();
    super.dispose();
  }
  Future _saveSite() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      try {
        final siteService = SiteService();
        final site = Site(
          id: _isEditing ? widget.site!.id : null,
          status: _status,
          notes: _notesController.text.isEmpty ? null : _notesController.text.trim(),
          latitude: double.parse(_latitudeController.text.trim()),
          longitude: double.parse(_longitudeController.text.trim()),
          flockId: widget.flock.id!,
        );
        bool success;
        if (_isEditing) {
          final updatedSite = await siteService.updateSite(site);
          success = updatedSite != null;
        } else {
          final newSite = await siteService.createSite(site);
          success = newSite != null;
        }
        if (success && mounted) {
          Navigator.of(context).pop(true);
        } else {
          setState(() {
            _error = 'Échec de l\'enregistrement du site.';
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
        title: Text(_isEditing ? 'Modifier le site' : 'Ajouter un site'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField(
                  value: _status,
                  decoration: const InputDecoration(
                    labelText: 'Statut',
                    border: OutlineInputBorder(),
                  ),
                  items: _statusOptions.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _status = value;
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez sélectionner un statut';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _latitudeController,
                  decoration: const InputDecoration(
                    labelText: 'Latitude',
                    border: OutlineInputBorder(),
                    helperText: 'Ex: 48.8566',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer une latitude';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Veuillez entrer un nombre valide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _longitudeController,
                  decoration: const InputDecoration(
                    labelText: 'Longitude',
                    border: OutlineInputBorder(),
                    helperText: 'Ex: 2.3522',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer une longitude';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Veuillez entrer un nombre valide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optionnel)',
                    border: OutlineInputBorder(),
                    helperText: 'Informations supplémentaires sur le site',
                  ),
                  maxLines: 3,
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
                  onPressed: _isLoading ? null : _saveSite,
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
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
  final SiteService _siteService = SiteService();
  final List _statuses = ['vide', 'occupé', 'maintenance'];
  @override
  void initState() {
    super.initState();
    if (widget.site != null) {
      _isEditing = true;
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
        final site = Site(
          id: _isEditing ? widget.site!.id : null,
          latitude: double.parse(_latitudeController.text.trim()),
          longitude: double.parse(_longitudeController.text.trim()),
          notes: _notesController.text.trim(),
          status: _status,
          flockId: widget.flock.id!,
        );
        bool success;
        if (_isEditing) {
          success = await _siteService.updateSite(site);
        } else {
          success = await _siteService.createSite(site);
        }
        if (mounted) {
          if (success) {
            Navigator.of(context).pop(true);
          } else {
            setState(() {
              _error = 'Erreur lors de l\'enregistrement du site';
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
        title: Text(_isEditing ? 'Modifier le site' : 'Ajouter un site'),
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
                controller: _latitudeController,
                decoration: const InputDecoration(
                  labelText: 'Latitude',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer la latitude';
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
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer la longitude';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Veuillez entrer un nombre valide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField(
                value: _status,
                decoration: const InputDecoration(
                  labelText: 'Statut',
                  border: OutlineInputBorder(),
                ),
                items: _statuses.map((status) {
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
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveSite,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  _isEditing ? 'Enregistrer les modifications' : 'Ajouter le site',
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
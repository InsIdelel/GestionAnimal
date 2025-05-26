import 'package:flutter/material.dart';
import 'package:gestion_animal/models/site.dart';
import 'package:gestion_animal/models/visit.dart';
import 'package:gestion_animal/services/visit_service.dart';
import 'package:intl/intl.dart';
class VisitFormScreen extends StatefulWidget {
  final Site site;
  final Visit? visit;
  const VisitFormScreen({
    Key? key,
    required this.site,
    this.visit,
  }) : super(key: key);
  @override
  VisitFormScreenState createState() => VisitFormScreenState();
}
class VisitFormScreenState extends State {
  final _formKey = GlobalKey();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();

  bool _isLoading = false;
  String? _error;
  bool _isEditing = false;
  @override
  void initState() {
    super.initState();
    _isEditing = widget.visit != null;

    if (_isEditing) {
      _selectedDate = widget.visit!.date;
      _notesController.text = widget.visit!.notes ?? '';
    }
  }
  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
  Future _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
  Future _saveVisit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      try {
        final visitService = VisitService();
        final visit = Visit(
          id: _isEditing ? widget.visit!.id : null,
          date: _selectedDate,
          notes: _notesController.text.isEmpty ? null : _notesController.text.trim(),
          siteId: widget.site.id!,
        );
        bool success;
        if (_isEditing) {
          final updatedVisit = await visitService.updateVisit(visit);
          success = updatedVisit != null;
        } else {
          final newVisit = await visitService.createVisit(visit);
          success = newVisit != null;
        }
        if (success && mounted) {
          Navigator.of(context).pop(true);
        } else {
          setState(() {
            _error = 'Échec de l\'enregistrement de la visite.';
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
        title: Text(_isEditing ? 'Modifier la visite' : 'Ajouter une visite'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Date de la visite',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                DateFormat('dd/MM/yyyy').format(_selectedDate),
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () => _selectDate(context),
                              child: const Text('Choisir une date'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optionnel)',
                    border: OutlineInputBorder(),
                    helperText: 'Observations, actions réalisées, etc.',
                  ),
                  maxLines: 5,
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
                  onPressed: _isLoading ? null : _saveVisit,
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
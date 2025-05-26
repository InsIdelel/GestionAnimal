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

class VisitFormScreenState extends State<VisitFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  
  bool _isLoading = false;
  String? _error;
  bool _isEditing = false;

  final VisitService _visitService = VisitService();
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    if (widget.visit != null) {
      _isEditing = true;
      _selectedDate = widget.visit!.date;
      _notesController.text = widget.visit!.notes ?? '';
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveVisit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      try {
        final visit = Visit(
          id: _isEditing ? widget.visit!.id : null,
          date: _selectedDate,
          notes: _notesController.text.trim(),
          siteId: widget.site.id!,
        );

        bool success;
        if (_isEditing) {
          success = await _visitService.updateVisit(visit);
        } else {
          success = await _visitService.createVisit(visit);
        }

        if (mounted) {
          if (success) {
            Navigator.of(context).pop(true);
          } else {
            setState(() {
              _error = 'Erreur lors de l\'enregistrement de la visite';
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
        title: Text(_isEditing ? 'Modifier la visite' : 'Ajouter une visite'),
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
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date de visite',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(_dateFormat.format(_selectedDate)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 5,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _saveVisit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        _isEditing ? 'Enregistrer les modifications' : 'Ajouter la visite',
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


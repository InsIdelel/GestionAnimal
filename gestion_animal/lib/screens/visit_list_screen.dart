import 'package:flutter/material.dart';
import 'package:gestion_animal/models/site.dart';
import 'package:gestion_animal/models/visit.dart';
import 'package:gestion_animal/screens/visit_form_screen.dart';
import 'package:gestion_animal/services/visit_service.dart';
import 'package:intl/intl.dart';
class VisitListScreen extends StatefulWidget {
  final Site site;
  const VisitListScreen({Key? key, required this.site}) : super(key: key);
  @override
  VisitListScreenState createState() => VisitListScreenState();
}
class VisitListScreenState extends State {
  final VisitService _visitService = VisitService();
  List _visits = [];
  bool _isLoading = true;
  String? _error;
  @override
  void initState() {
    super.initState();
    _loadVisits();
  }
  Future _loadVisits() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final visits = await _visitService.getVisitsBySite(widget.site.id!);
      setState(() {
        _visits = visits;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }
  void _navigateToVisitForm({Visit? visit}) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VisitFormScreen(
          site: widget.site,
          visit: visit,
        ),
      ),
    );
    if (result == true) {
      _loadVisits();
    }
  }
  void _confirmDeleteVisit(Visit visit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la visite'),
        content: Text('Êtes-vous sûr de vouloir supprimer cette visite du ${DateFormat('dd/MM/yyyy').format(visit.date)} ?'),
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
                final success = await _visitService.deleteVisit(visit.id!);
                if (success) {
                  _loadVisits();
                } else {
                  setState(() {
                    _error = 'Échec de la suppression de la visite.';
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Visites du site #${widget.site.id}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
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
              onPressed: _loadVisits,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      )
          : _visits.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Aucune visite trouvée',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _navigateToVisitForm(),
              child: const Text('Ajouter une visite'),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadVisits,
        child: ListView.builder(
          itemCount: _visits.length,
          itemBuilder: (context, index) {
            final visit = _visits[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(
                  'Visite du ${DateFormat('dd/MM/yyyy').format(visit.date)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: visit.notes != null && visit.notes!.isNotEmpty
                    ? Text('Notes: ${visit.notes}')
                    : null,
                leading: const CircleAvatar(
                  child: Icon(Icons.calendar_today),
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
                      _navigateToVisitForm(visit: visit);
                    } else if (value == 'delete') {
                      _confirmDeleteVisit(visit);
                    }
                  },
                ),
                onTap: () => _navigateToVisitForm(visit: visit),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToVisitForm(),
        tooltip: 'Ajouter une visite',
        child: const Icon(Icons.add),
      ),
    );
  }
}

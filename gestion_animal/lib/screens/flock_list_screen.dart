import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestion_animal/models/flock.dart';
import 'package:gestion_animal/providers/flock_provider.dart';
import 'package:gestion_animal/screens/flock_detail_screen.dart';

class FlockListScreen extends StatefulWidget {
  const FlockListScreen({Key? key}) : super(key: key);

  @override
  FlockListScreenState createState() => FlockListScreenState();
}

class FlockListScreenState extends State<FlockListScreen> {
  final _formKey = GlobalKey<FormState>();
  final _flockNameController = TextEditingController();
  bool _isAddingFlock = false;

  @override
  void dispose() {
    _flockNameController.dispose();
    super.dispose();
  }

  void _showAddFlockDialog() {
    setState(() {
      _isAddingFlock = true;
      _flockNameController.clear();
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un troupeau'),
        content: Form(
          key: _formKey,
          child: TextFormField(
            controller: _flockNameController,
            decoration: const InputDecoration(
              labelText: 'Nom du troupeau',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer un nom';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _isAddingFlock = false;
              });
            },
            child: const Text('Annuler'),
          ),
          Consumer<FlockProvider>(
            builder: (context, flockProvider, child) {
              return ElevatedButton(
                onPressed: flockProvider.isLoading
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          final success = await flockProvider.createFlock(
                            _flockNameController.text.trim(),
                          );
                          if (mounted) {
                            Navigator.of(context).pop();
                            setState(() {
                              _isAddingFlock = false;
                            });
                            if (!success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Erreur lors de la création du troupeau'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        }
                      },
                child: flockProvider.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Ajouter'),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showEditFlockDialog(Flock flock) {
    _flockNameController.text = flock.nom;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier le troupeau'),
        content: Form(
          key: _formKey,
          child: TextFormField(
            controller: _flockNameController,
            decoration: const InputDecoration(
              labelText: 'Nom du troupeau',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer un nom';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Annuler'),
          ),
          Consumer<FlockProvider>(
            builder: (context, flockProvider, child) {
              return ElevatedButton(
                onPressed: flockProvider.isLoading
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          final success = await flockProvider.updateFlock(
                            flock.id!,
                            _flockNameController.text.trim(),
                          );
                          if (mounted) {
                            Navigator.of(context).pop();
                            if (!success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Erreur lors de la modification du troupeau'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        }
                      },
                child: flockProvider.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Enregistrer'),
              );
            },
          ),
        ],
      ),
    );
  }

  void _confirmDeleteFlock(Flock flock) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le troupeau'),
        content: Text('Êtes-vous sûr de vouloir supprimer le troupeau "${flock.nom}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          Consumer<FlockProvider>(
            builder: (context, flockProvider, child) {
              return ElevatedButton(
                onPressed: flockProvider.isLoading
                    ? null
                    : () async {
                        final success = await flockProvider.deleteFlock(flock.id!);
                        if (mounted) {
                          Navigator.of(context).pop();
                          if (!success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Erreur lors de la suppression du troupeau'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: flockProvider.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Supprimer'),
              );
            },
          ),
        ],
      ),
    );
  }

  void _navigateToFlockDetail(Flock flock) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FlockDetailScreen(flock: flock),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<FlockProvider>(
        builder: (context, flockProvider, child) {
          if (flockProvider.isLoading && !_isAddingFlock) {
            return const Center(child: CircularProgressIndicator());
          }

          if (flockProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Erreur: ${flockProvider.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => flockProvider.loadFlocks(),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          if (flockProvider.flocks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Aucun troupeau trouvé',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _showAddFlockDialog,
                    child: const Text('Ajouter un troupeau'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => flockProvider.loadFlocks(),
            child: ListView.builder(
              itemCount: flockProvider.flocks.length,
              itemBuilder: (context, index) {
                final flock = flockProvider.flocks[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(
                      flock.nom,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
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
                          _showEditFlockDialog(flock);
                        } else if (value == 'delete') {
                          _confirmDeleteFlock(flock);
                        }
                      },
                    ),
                    onTap: () => _navigateToFlockDetail(flock),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddFlockDialog,
        tooltip: 'Ajouter un troupeau',
        child: const Icon(Icons.add),
      ),
    );
  }
}


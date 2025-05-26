import 'package:flutter/material.dart';
import 'package:gestion_animal/models/flock.dart';
import 'package:gestion_animal/services/flock_service.dart';
class FlockProvider extends ChangeNotifier {
  final FlockService _flockService;
  List _flocks = [];
  Flock? _selectedFlock;
  bool _isLoading = false;
  String? _error;
  FlockProvider({FlockService? flockService}) : _flockService = flockService ?? FlockService();
  List get flocks => _flocks;
  Flock? get selectedFlock => _selectedFlock;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Future loadFlocks() async {
    _isLoading = true;
    notifyListeners();
    try {
      _flocks = await _flockService.getFlocks();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future selectFlock(int id) async {
    _isLoading = true;
    notifyListeners();
    try {
      _selectedFlock = await _flockService.getFlock(id);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future createFlock(String nom) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final newFlock = await _flockService.createFlock(nom);
      if (newFlock != null) {
        _flocks.add(newFlock);
        notifyListeners();
        return true;
      } else {
        _error = 'Échec de la création du troupeau.';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future updateFlock(int id, String nom) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final updatedFlock = await _flockService.updateFlock(id, nom);
      if (updatedFlock != null) {
        final index = _flocks.indexWhere((flock) => flock.id == id);
        if (index != -1) {
          _flocks[index] = updatedFlock;
        }
        if (_selectedFlock?.id == id) {
          _selectedFlock = updatedFlock;
        }
        notifyListeners();
        return true;
      } else {
        _error = 'Échec de la mise à jour du troupeau.';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future deleteFlock(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final success = await _flockService.deleteFlock(id);
      if (success) {
        _flocks.removeWhere((flock) => flock.id == id);
        if (_selectedFlock?.id == id) {
          _selectedFlock = null;
        }
        notifyListeners();
        return true;
      } else {
        _error = 'Échec de la suppression du troupeau.';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
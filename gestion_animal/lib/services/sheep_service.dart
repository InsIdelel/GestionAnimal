import 'package:gestion_animal/models/sheep.dart';
import 'package:gestion_animal/services/api_service.dart';

class SheepService {
  final ApiService _apiService;
  
  SheepService({ApiService? apiService}) : _apiService = apiService ?? ApiService();
  
  Future<List<Sheep>> getSheepByFlock(int flockId) async {
    try {
      final response = await _apiService.get('/sheep/?flock_id=$flockId');
      return (response as List).map((data) => Sheep.fromJson(data)).toList();
    } catch (e) {
      print('Get sheep error: $e');
      return [];
    }
  }
  
  Future<Sheep?> getSheep(String idBoucle) async {
    try {
      final response = await _apiService.get('/sheep/$idBoucle');
      return Sheep.fromJson(response);
    } catch (e) {
      print('Get sheep error: $e');
      return null;
    }
  }
  
  Future<bool> createSheep(Sheep sheep) async {
    try {
      await _apiService.post('/sheep/', sheep.toJson());
      return true;
    } catch (e) {
      print('Create sheep error: $e');
      return false;
    }
  }
  
  Future<bool> updateSheep(Sheep sheep) async {
    try {
      await _apiService.put('/sheep/${sheep.id}', sheep.toJson());
      return true;
    } catch (e) {
      print('Update sheep error: $e');
      return false;
    }
  }
  
  Future<bool> deleteSheep(int id) async {
    try {
      await _apiService.delete('/sheep/$id');
      return true;
    } catch (e) {
      print('Delete sheep error: $e');
      return false;
    }
  }
}


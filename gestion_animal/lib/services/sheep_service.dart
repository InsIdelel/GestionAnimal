import 'package:gestion_animal/models/sheep.dart';
import 'package:gestion_animal/services/api_service.dart';
class SheepService {
  final ApiService _apiService;

  SheepService({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  Future getSheepByFlock(int flockId) async {
    try {
      final response = await _apiService.get('/sheep/?flock_id=$flockId');
      return (response as List).map((data) => Sheep.fromJson(data)).toList();
    } catch (e) {
      print('Get sheep error: $e');
      return [];
    }
  }

  Future getSheep(String idBoucle) async {
    try {
      final response = await _apiService.get('/sheep/$idBoucle');
      return Sheep.fromJson(response);
    } catch (e) {
      print('Get sheep error: $e');
      return null;
    }
  }

  Future createSheep(Sheep sheep) async {
    try {
      await _apiService.post('/sheep/', sheep.toJson());
      return true;
    } catch (e) {
      print('Create sheep error: $e');
      return false;
    }
  }

  Future updateSheep(Sheep sheep) async {
    try {
      await _apiService.put('/sheep/${sheep.idBoucle}', sheep.toJson());
      return true;
    } catch (e) {
      print('Update sheep error: $e');
      return false;
    }
  }

  Future deleteSheep(int id) async {
    try {
      await _apiService.delete('/sheep/$id');
      return true;
    } catch (e) {
      print('Delete sheep error: $e');
      return false;
    }
  }
}
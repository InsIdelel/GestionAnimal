import 'package:gestion_animal/models/visit.dart';
import 'package:gestion_animal/services/api_service.dart';

class VisitService {
  final ApiService _apiService;
  
  VisitService({ApiService? apiService}) : _apiService = apiService ?? ApiService();
  
  Future<List<Visit>> getVisitsBySite(int siteId) async {
    try {
      final response = await _apiService.get('/visits/?site_id=$siteId');
      return (response as List).map((data) => Visit.fromJson(data)).toList();
    } catch (e) {
      print('Get visits error: $e');
      return [];
    }
  }
  
  Future<Visit?> getVisit(int id) async {
    try {
      final response = await _apiService.get('/visits/$id');
      return Visit.fromJson(response);
    } catch (e) {
      print('Get visit error: $e');
      return null;
    }
  }
  
  Future<bool> createVisit(Visit visit) async {
    try {
      await _apiService.post('/visits/', visit.toJson());
      return true;
    } catch (e) {
      print('Create visit error: $e');
      return false;
    }
  }
  
  Future<bool> updateVisit(Visit visit) async {
    try {
      await _apiService.put('/visits/${visit.id}', visit.toJson());
      return true;
    } catch (e) {
      print('Update visit error: $e');
      return false;
    }
  }
  
  Future<bool> deleteVisit(int id) async {
    try {
      await _apiService.delete('/visits/$id');
      return true;
    } catch (e) {
      print('Delete visit error: $e');
      return false;
    }
  }
}


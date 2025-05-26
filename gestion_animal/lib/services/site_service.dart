import 'package:gestion_animal/models/site.dart';
import 'package:gestion_animal/services/api_service.dart';

class SiteService {
  final ApiService _apiService;
  
  SiteService({ApiService? apiService}) : _apiService = apiService ?? ApiService();
  
  Future<List<Site>> getSitesByFlock(int flockId) async {
    try {
      final response = await _apiService.get('/sites/?flock_id=$flockId');
      return (response as List).map((data) => Site.fromJson(data)).toList();
    } catch (e) {
      print('Get sites error: $e');
      return [];
    }
  }
  
  Future<Site?> getSite(int id) async {
    try {
      final response = await _apiService.get('/sites/$id');
      return Site.fromJson(response);
    } catch (e) {
      print('Get site error: $e');
      return null;
    }
  }
  
  Future<bool> createSite(Site site) async {
    try {
      await _apiService.post('/sites/', site.toJson());
      return true;
    } catch (e) {
      print('Create site error: $e');
      return false;
    }
  }
  
  Future<bool> updateSite(Site site) async {
    try {
      await _apiService.put('/sites/${site.id}', site.toJson());
      return true;
    } catch (e) {
      print('Update site error: $e');
      return false;
    }
  }
  
  Future<bool> deleteSite(int id) async {
    try {
      await _apiService.delete('/sites/$id');
      return true;
    } catch (e) {
      print('Delete site error: $e');
      return false;
    }
  }
}


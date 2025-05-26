import 'package:flutter/material.dart';
import 'package:gestion_animal/models/flock.dart';
import 'package:gestion_animal/models/sheep.dart';
import 'package:gestion_animal/models/site.dart';
import 'package:gestion_animal/screens/sheep_list_screen.dart';
import 'package:gestion_animal/screens/site_list_screen.dart';
import 'package:gestion_animal/services/sheep_service.dart';
import 'package:gestion_animal/services/site_service.dart';

class FlockDetailScreen extends StatefulWidget {
  final Flock flock;
  
  const FlockDetailScreen({Key? key, required this.flock}) : super(key: key);
  
  @override
  FlockDetailScreenState createState() => FlockDetailScreenState();
}

class FlockDetailScreenState extends State<FlockDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final SheepService _sheepService = SheepService();
  final SiteService _siteService = SiteService();
  
  List<Sheep> _sheep = [];
  List<Site> _sites = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final sheepList = await _sheepService.getSheepByFlock(widget.flock.id!);
      final siteList = await _siteService.getSitesByFlock(widget.flock.id!);
      
      setState(() {
        _sheep = sheepList;
        _sites = siteList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.flock.nom),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Moutons', icon: Icon(Icons.pets)),
            Tab(text: 'Sites', icon: Icon(Icons.location_on)),
          ],
        ),
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
                        onPressed: _loadData,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    SheepListScreen(flock: widget.flock, initialSheep: _sheep),
                    SiteListScreen(flock: widget.flock, initialSites: _sites),
                  ],
                ),
    );
  }
}


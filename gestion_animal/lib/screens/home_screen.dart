import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestion_animal/providers/auth_provider.dart';
import 'package:gestion_animal/providers/flock_provider.dart';
import 'package:gestion_animal/screens/flock_list_screen.dart';
import 'package:gestion_animal/screens/login_screen.dart';
import 'package:gestion_animal/screens/profile_screen.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  HomeScreenState createState() => HomeScreenState();
}
class HomeScreenState extends State {
  int _selectedIndex = 0;
  final List _screens = [
    const FlockListScreen(),
    const ProfileScreen(),
  ];
  @override
  void initState() {
    super.initState();
    // Charger les troupeaux au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of(context, listen: false).loadFlocks();
    });
  }
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  Future _logout() async {
    final authProvider = Provider.of(context, listen: false);
    await authProvider.logout();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of(context);
    final user = authProvider.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion de Troupeaux'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Déconnexion',
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.pets),
            label: 'Troupeaux',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        onTap: _onItemTapped,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(user?.name ?? 'Utilisateur'),
              accountEmail: Text(user?.email ?? ''),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'U',
                  style: const TextStyle(fontSize: 24.0),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.pets),
              title: const Text('Troupeaux'),
              selected: _selectedIndex == 0,
              onTap: () {
                _onItemTapped(0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profil'),
              selected: _selectedIndex == 1,
              onTap: () {
                _onItemTapped(1);
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Déconnexion'),
              onTap: () {
                Navigator.pop(context);
                _logout();
              },
            ),
          ],
        ),
      ),
    );
  }
}
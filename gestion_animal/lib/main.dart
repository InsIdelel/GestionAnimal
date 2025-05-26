import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gestion_animal/providers/auth_provider.dart';
import 'package:gestion_animal/providers/flock_provider.dart';
import 'package:gestion_animal/screens/login_screen.dart';
import 'package:gestion_animal/screens/home_screen.dart';
import 'package:gestion_animal/screens/register_screen.dart';
void main() async {
  // Charger les variables d'environnement
  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FlockProvider()),
      ],
      child: MaterialApp(
        title: 'Gestion de Troupeaux',
        theme: ThemeData(
          primarySwatch: Colors.green,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          useMaterial3: true,
        ),
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const HomeScreen(),
        },
      ),
    );
  }
}
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);
  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}
class _AuthWrapperState extends State {
  @override
  void initState() {
    super.initState();
    // Vérifier l'état d'authentification au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of(context, listen: false).checkAuthStatus();
    });
  }
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of(context);
    // Afficher un indicateur de chargement pendant la vérification
    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    // Rediriger vers l'écran approprié en fonction de l'état d'authentification
    if (authProvider.isAuthenticated) {
      return const HomeScreen();
    } else {
      return const LoginScreen();
    }
  }
}

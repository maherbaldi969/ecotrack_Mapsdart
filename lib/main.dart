import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Partenaire/partner_offers_screen.dart';
import 'screens/itinerary_list_screen.dart';
import 'navigationetsuivi/Maps.dart';
import 'navigationetsuivi/itineraire_suivi.dart';
import 'screens/itinerary_detail_screen.dart';
import 'screens/favorites_screen.dart';
import 'models/itinerary.dart';
import 'models/favorites_manager.dart';
import 'navigationetsuivi/itinéraires_WordPress.dart';
import 'screens/écran_desuivi.dart';
import 'screens/history.dart';
import 'screens/Badge.dart';
import 'chat/chat_list_screen.dart';
import 'explore/explore.dart';
import 'personnalisation/personalisation_home.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'navigationetsuivi/alerts/alert_service.dart';
import 'navigationetsuivi/alerts/weather_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ecotrack/screen/points1.dart';
import 'evaluation/evaluation_screen.dart';
import 'evaluation/evaluation_service.dart';
import 'evaluation/notification_service.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'supportclients/support_home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  tz_data.initializeTimeZones();
  await NotificationService.initialize();

  // Initialisation des notifications
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  final InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => FavoritesManager()),
        Provider(create: (context) => WeatherService()), // Ajoutez cette ligne
        Provider(
            create: (context) =>
                AlertService(FlutterLocalNotificationsPlugin())),
        Provider(
            create: (context) => AlertService(flutterLocalNotificationsPlugin)),
        Provider(create: (context) => EvaluationService()),

        // Ajoutez d'autres providers ici si nécessaire
      ],
      child: const EcoTrackApp(),
    ),
  );
}

enum AppTheme {
  light,
  dark,
  balanced,
  shadow,
}

class EcoTrackApp extends StatefulWidget {
  const EcoTrackApp({super.key});

  @override
  _EcoTrackAppState createState() => _EcoTrackAppState();
}

class _EcoTrackAppState extends State<EcoTrackApp> {
  AppTheme _currentTheme = AppTheme.light;
  // Removed the unused _weatherService field
  void _applyTheme(AppTheme theme) {
    setState(() {
      _currentTheme = theme;
    });
  }

  ThemeData _getThemeData() {
    switch (_currentTheme) {
      case AppTheme.light:
        return ThemeData(
          primaryColor: const Color(0xFF80C000),
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: AppBarTheme(
            backgroundColor: const Color(0xFF80C000),
            titleTextStyle: GoogleFonts.merriweatherTextTheme()
                .titleLarge
                ?.copyWith(color: Colors.black),
          ),
          textTheme: GoogleFonts.merriweatherTextTheme(),
          useMaterial3: true,
        );
      case AppTheme.dark:
        return ThemeData.dark().copyWith(
          primaryColor: const Color(0xFF80C000),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.black,
            titleTextStyle: GoogleFonts.merriweatherTextTheme()
                .titleLarge
                ?.copyWith(color: Colors.white),
          ),
          textTheme: GoogleFonts.merriweatherTextTheme(),
        );
      case AppTheme.balanced:
        return ThemeData(
          primaryColor: const Color(0xFF80C000),
          scaffoldBackgroundColor: Colors.grey[200],
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.grey[800],
            titleTextStyle: GoogleFonts.merriweatherTextTheme()
                .titleLarge
                ?.copyWith(color: Colors.white),
          ),
          textTheme: GoogleFonts.merriweatherTextTheme(),
          useMaterial3: true,
        );
      case AppTheme.shadow:
        return ThemeData(
          primaryColor: const Color(0xFF80C000),
          scaffoldBackgroundColor: Colors.grey[900],
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.grey[900],
            titleTextStyle: GoogleFonts.merriweatherTextTheme()
                .titleLarge
                ?.copyWith(color: Colors.white),
          ),
          textTheme: GoogleFonts.merriweatherTextTheme(),
          useMaterial3: true,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoTrack',
      debugShowCheckedModeBanner: false,
      theme: _getThemeData(),
      initialRoute: '/',
      routes: {
        '/': (context) => const MyHomePage(title: 'EcoTrack'),
        '/itineraries': (context) => ItineraryListScreen(),
        '/map': (context) => MapsPage(),
        '/maps': (context) => MapsPage1(),
        '/favorites': (context) => FavoritesScreen(),
        '/downloaded-itineraries': (context) => DownloadedItinerariesPage(),
        '/tracking': (context) => TrackingScreen(),
        '/history': (context) => HistoriqueRandonneesPage(),
        '/guide': (context) => ChatListScreen(),
        '/explore': (context) => Explore(),
        '/mapage': (context) => FitnessApp(),
        '/custom-program': (context) => PersonalisationHome(),
        '/badage': (context) => BadgeScreen(),
        '/support': (context) =>
            SupportHome(), // Nouvelle route pour le support client
        '/evaluation': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          return EvaluationScreen(
            visiteId: args?['visiteId'] ?? 'default',
            guideId: args?['guideId'] ?? 'default',
            userId: args?['userId'] ?? 'default',
            guideName: args?['guideName'],
            visiteDate: args?['visitDate'],
          );
        },
        '/partenaire': (context) => PartnerOffersScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/itineraryDetail') {
          final itinerary = settings.arguments as Itinerary;
          return MaterialPageRoute(
            builder: (context) => ItineraryDetailScreen(itinerary: itinerary),
          );
        }
        return null;
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex =
      0; // Index de l'élément sélectionné dans la barre de navigation

  // Liste des écrans correspondants aux éléments de la barre de navigation
  final List<Widget> _pages = [
    const MyHomePageContent(title: 'EcoTrack'), // Accueil
    MapsPage(), // Carte
    Explore(), // Explore
    ChatListScreen(), // Chat
    FitnessApp(), // Ma page (par exemple, les favoris)
  ];

  // Méthode pour mettre à jour l'index sélectionné
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final weatherService =
          Provider.of<WeatherService>(context, listen: false);
      // Coordonnées pour Tabarka (nord-ouest de la Tunisie)
      weatherService.fetchWeather(36.9544, 8.7580);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Center(
            child: Text(
              widget.title,
              style: GoogleFonts.merriweather(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          actions: [
            PopupMenuButton<AppTheme>(
              onSelected: (value) {
                final state =
                    context.findAncestorStateOfType<_EcoTrackAppState>();
                state?._applyTheme(value);
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: AppTheme.light,
                  child: Text("Thème Clair"),
                ),
                const PopupMenuItem(
                  value: AppTheme.dark,
                  child: Text("Thème Sombre"),
                ),
                const PopupMenuItem(
                  value: AppTheme.balanced,
                  child: Text("Thème Équilibré"),
                ),
                const PopupMenuItem(
                  value: AppTheme.shadow,
                  child: Text("Thème Ombre"),
                ),
              ],
            ),
          ],
        ),
        drawer: _buildDrawer(context),
        body: _pages[_selectedIndex], // Afficher la page correspondante
        bottomNavigationBar: CurvedNavigationBar(
          backgroundColor: Colors.white, // Adjust this based on your theme
          color: const Color(0xFF80C000), // Navigation bar color
          buttonBackgroundColor: Colors.white, // Button highlight color
          animationDuration: const Duration(milliseconds: 300),
          index: _selectedIndex, // Keep track of the selected index
          items: const <Widget>[
            Icon(Icons.home, size: 30, color: Colors.black),
            Icon(Icons.map, size: 30, color: Colors.black),
            Icon(Icons.explore, size: 30, color: Colors.black),
            Icon(Icons.chat, size: 30, color: Colors.black),
            Icon(Icons.person, size: 30, color: Colors.black),
          ],
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ));
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text("maherbaldi",
                style: GoogleFonts.merriweather(color: Colors.black)),
            accountEmail: Text("maherbaldi@gmail.com",
                style: GoogleFonts.merriweather(color: Colors.black)),
            currentAccountPicture: ClipOval(
              child: Image.asset("assets/images/intinaire.jpeg",
                  fit: BoxFit.cover),
            ),
            decoration: const BoxDecoration(color: Color(0xFF80C000)),
          ),
          _buildDrawerItem(Icons.favorite, "Favoris", '/favorites', context),
          _buildDrawerItem(
              Icons.directions, "Itinéraires", '/itineraries', context),
          _buildDrawerItem(Icons.cloud, "Météo", '/tracking', context),
          _buildDrawerItem(Icons.assignment, "Créer un programme",
              '/custom-program', context),
          _buildDrawerItem(Icons.assignment, "Badage", '/badage', context),
          _buildDrawerItem(
              Icons.star, "Évaluer un guide", '/evaluation', context),
          _buildDrawerItem(Icons.help, "Support client", '/support', context),
          _buildDrawerItem(
              Icons.handshake, "Partenaire", '/partenaire', context),
          const Divider(),
          _buildDrawerItem(
              Icons.notifications, "Notifications", '/Not', context),
          _buildDrawerItem(Icons.settings, "Paramètres", '', context),
          _buildDrawerItem(Icons.history, "Historique", '/history', context),
        ],
      ),
    );
  }

  ListTile _buildDrawerItem(
      IconData icon, String title, String route, BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title, style: GoogleFonts.merriweather()),
      onTap: () {
        Navigator.pop(context);
        if (route.isNotEmpty) Navigator.pushNamed(context, route);
      },
    );
  }
}

class MyHomePageContent extends StatelessWidget {
  const MyHomePageContent({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            "assets/images/intinaire.jpeg",
            fit: BoxFit.cover,
          ),
        ),
        Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'EcoTrack : Explorez la nature, même hors ligne ! 🌿📍 Randonnées, guides et itinéraires écoresponsables à portée de main🌿📍',
              textAlign: TextAlign.center,
              style: GoogleFonts.merriweather(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 50,
          left: 0,
          right: 0,
          child: Center(),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'weather_service.dart';
import 'weather_style.dart';
import 'safety_tips.dart';
import 'emergency_contacts.dart';

class WeatherAlertScreen extends StatefulWidget {
  const WeatherAlertScreen({super.key});

  @override
  State<WeatherAlertScreen> createState() => _WeatherAlertScreenState();
}

class _WeatherAlertScreenState extends State<WeatherAlertScreen> {
  late WeatherService _weatherService;

  @override
  void initState() {
    super.initState();
    _weatherService = WeatherService();
    _weatherService.fetchWeatherAlerts(36.8, 10.1); // Coordonnées par défaut (Tunis)
  }

  @override
  void dispose() {
    _weatherService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alertes Météo', style: merriweatherBold),
        backgroundColor: vertPrimaire,
        foregroundColor: blanc,
      ),
      body: StreamBuilder<Map<String, dynamic>>(
        stream: _weatherService.weatherAlerts,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _buildErrorState();
          }

          if (!snapshot.hasData) {
            return _buildLoadingState();
          }

          final alerts = snapshot.data!;
          return _buildAlertList(alerts);
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: vertPrimaire),
          const SizedBox(height: 16),
          Text('Chargement des alertes...', style: merriweatherNormal),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text('Erreur de connexion', style: merriweatherBold),
          const SizedBox(height: 8),
          Text('Vérifiez votre connexion internet', style: merriweatherNormal),
        ],
      ),
    );
  }

  Widget _buildAlertList(Map<String, dynamic> alerts) {
    return ListView.builder(
      itemCount: alerts.length,
      itemBuilder: (context, index) {
        final alert = alerts.values.elementAt(index);
        return Card(
          margin: const EdgeInsets.all(8),
          color: _getAlertColor(alert['severity']),
          child: ListTile(
            leading: _getAlertIcon(alert['severity']),
            title: Text(alert['title'], style: merriweatherBold.copyWith(color: blanc)),
            subtitle: Text(alert['description'], style: merriweatherNormal.copyWith(color: blanc)),
            trailing: Icon(Icons.chevron_right, color: blanc),
            onTap: () => _showAlertDetails(alert),
          ),
        );
      },
    );
  }

  Color _getAlertColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'extreme':
        return Colors.red;
      case 'severe':
        return Colors.orange;
      default:
        return Colors.yellow[700]!;
    }
  }

  Icon _getAlertIcon(String severity) {
    switch (severity.toLowerCase()) {
      case 'extreme':
        return Icon(Icons.warning_amber, color: blanc);
      case 'severe':
        return Icon(Icons.warning, color: blanc);
      default:
        return Icon(Icons.info_outline, color: blanc);
    }
  }

  void _showAlertDetails(Map<String, dynamic> alert) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(alert['title'], style: merriweatherBold.copyWith(fontSize: 20)),
              const SizedBox(height: 16),
              Text(alert['description'], style: merriweatherNormal),
              const SizedBox(height: 24),
              SafetyTips(alert: alert),
              const SizedBox(height: 16),
              EmergencyContacts(alert: alert),
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    try {
      // D'abord essayer de charger depuis le cache
      final cachedAlerts = await _weatherService.getOfflineAlerts();
      if (cachedAlerts.isNotEmpty) {
        if (mounted) {
          setState(() {});
        }
      }

      // Puis essayer de rafraîchir depuis l'API
      await _weatherService.fetchWeatherAlerts(
          36.8, 10.1); // Coordonnées par défaut (Tunis)
    } catch (e) {
      debugPrint('Erreur de chargement des alertes: $e');
    }
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
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _weatherService.weatherAlerts,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _buildErrorState();
          }

          if (!snapshot.hasData) {
            return _buildLoadingState();
          }
          
          if (snapshot.data!.isEmpty) {
            return _buildNoAlertsState();
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
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: vertPrimaire),
            onPressed: _loadAlerts,
            child: Text('Réessayer', style: merriweatherBold.copyWith(color: blanc)),
          ),
        ],
      ),
    );
  }

  Widget _buildNoAlertsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 48, color: vertPrimaire),
          const SizedBox(height: 16),
          Text('Aucune alerte active', style: merriweatherBold),
          const SizedBox(height: 8),
          Text('Tout semble calme pour le moment', style: merriweatherNormal),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: vertPrimaire),
            onPressed: _loadAlerts,
            child: Text('Rafraîchir', style: merriweatherBold.copyWith(color: blanc)),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertList(List<Map<String, dynamic>> alerts) {
    return ListView.builder(
      itemCount: alerts.length,
      itemBuilder: (context, index) {
        final alert = alerts[index];
        final severity = alert['severity']?.toString().toLowerCase() ?? '';
        final effective = alert['effective'] ?? '';
        final expires = alert['expires'] ?? '';
        
        return Card(
          margin: const EdgeInsets.all(8),
          color: _getAlertColor(severity),
          child: InkWell(
            onTap: () => _showAlertDetails(alert),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _getAlertIcon(severity),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          alert['title'] ?? 'Alerte météo',
                          style: merriweatherBold.copyWith(
                            color: blanc,
                            fontSize: 18
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    alert['description'] ?? '',
                    style: merriweatherNormal.copyWith(color: blanc),
                  ),
                  const SizedBox(height: 12),
                  if (effective.isNotEmpty || expires.isNotEmpty)
                    Row(
                      children: [
                        if (effective.isNotEmpty)
                          Text(
                            'Début: ${_formatDateTime(effective)}',
                            style: merriweatherNormal.copyWith(
                              color: blanc,
                              fontSize: 12
                            ),
                          ),
                        if (expires.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: Text(
                              'Fin: ${_formatDateTime(expires)}',
                              style: merriweatherNormal.copyWith(
                                color: blanc,
                                fontSize: 12
                              ),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDateTime(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return DateFormat('dd/MM HH:mm').format(dateTime);
    } catch (e) {
      return dateTimeStr;
    }
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
              Text(alert['title'],
                  style: merriweatherBold.copyWith(fontSize: 20)),
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

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'weather_style.dart';

class EmergencyContacts extends StatelessWidget {
  final Map<String, dynamic> alert;

  const EmergencyContacts({super.key, required this.alert});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Contacts d\'urgence', style: merriweatherBold.copyWith(fontSize: 18)),
        const SizedBox(height: 8),
        _buildContactItem('Police', '197', Icons.local_police),
        _buildContactItem('Protection Civile', '198', Icons.medical_services),
        _buildContactItem('SAMU', '190', Icons.emergency),
        if (alert['severity']?.toString().toLowerCase() == 'extreme')
          _buildContactItem('Météo Nationale', '1535', Icons.warning),
      ],
    );
  }

  Widget _buildContactItem(String name, String number, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: vertPrimaire),
      title: Text(name, style: merriweatherBold),
      subtitle: Text(number, style: merriweatherNormal),
      trailing: IconButton(
        icon: Icon(Icons.phone, color: vertPrimaire),
        onPressed: () => _launchPhoneCall(number),
      ),
    );
  }

  Future<void> _launchPhoneCall(String number) async {
    try {
      final uri = Uri.parse('tel:$number');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (e) {
      debugPrint('Erreur lors de l\'appel: $e');
    }
  }
}

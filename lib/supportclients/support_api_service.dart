import 'dart:convert';
import 'package:http/http.dart' as http;
import 'support_ticket.dart';

class SupportApiService {
  static const String baseUrl = 'http://192.168.112.51:3000/api/support';

  Future<List<SupportTicket>> fetchTickets() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => SupportTicket.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load tickets');
    }
  }

  Future<SupportTicket> fetchTicketById(String id) async {
    final response = await http.get(Uri.parse('\$baseUrl/\$id'));
    if (response.statusCode == 200) {
      return SupportTicket.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load ticket');
    }
  }

  Future<bool> createTicket(SupportTicket ticket) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(ticket.toJson()),
    );
    return response.statusCode == 201;
  }

  Future<bool> updateTicket(SupportTicket ticket) async {
    final response = await http.put(
      Uri.parse('\$baseUrl/\${ticket.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(ticket.toJson()),
    );
    return response.statusCode == 200;
  }

  Future<bool> deleteTicket(String id) async {
    final response = await http.delete(Uri.parse('\$baseUrl/\$id'));
    return response.statusCode == 200;
  }
}

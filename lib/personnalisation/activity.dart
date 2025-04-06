// activity.dart
import 'package:flutter/material.dart';

class Activity {
  final String id;
  final String name;
  final int duration;
  final String category;
  final String iconCode;
  final String description;
  final double price;

  Activity({
    required this.name,
    required this.duration,
    this.id = '',
    this.category = 'Autre',
    this.iconCode = 'e3c9', // Icons.place par défaut
    this.description = '',
    this.price = 0.0,
  });

  IconData get icon => IconData(
    int.parse(iconCode, radix: 16),
    fontFamily: 'MaterialIcons',
  );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'duration': duration,
      'category': category,
      'iconCode': iconCode,
      'description': description,
      'price': price,
    };
  }

  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      duration: map['duration'] ?? 0,
      category: map['category'] ?? 'Autre',
      iconCode: map['iconCode'] ?? 'e3c9',
      description: map['description'] ?? '',
      price: map['price']?.toDouble() ?? 0.0,
    );
  }
}
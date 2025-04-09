import 'package:flutter/material.dart';

class Activity {
  final String id;
  final String name;
  final String description;
  final double price;
  final double duration;
  final List<String> tags;
  final String imageUrl;
  final String location;
  final TimeOfDay? startTime;
  final String category;
  final IconData icon;

  const Activity({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.duration,
    required this.tags,
    required this.imageUrl,
    required this.location,
    required this.category,
    required this.icon,
    this.startTime,
  });

  Activity copyWith({
    TimeOfDay? startTime,
    String? category,
    IconData? icon,
  }) {
    return Activity(
      id: id,
      name: name,
      description: description,
      price: price,
      duration: duration,
      tags: tags,
      imageUrl: imageUrl,
      location: location,
      startTime: startTime ?? this.startTime,
      category: category ?? this.category,
      icon: icon ?? this.icon,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'duration': duration,
      'tags': tags,
      'imageUrl': imageUrl,
      'location': location,
      'startTime': startTime?.toString(),
      'category': category,
      'icon': icon.codePoint,
    };
  }

  static Activity fromMap(Map<String, dynamic> map) {
    return Activity(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      price: map['price'],
      duration: map['duration'],
      tags: List<String>.from(map['tags']),
      imageUrl: map['imageUrl'],
      location: map['location'],
      startTime: map['startTime'] != null 
          ? TimeOfDay.fromDateTime(DateTime.parse(map['startTime']))
          : null,
      category: map['category'],
      icon: IconData(map['icon'], fontFamily: 'MaterialIcons'),
    );
  }
}

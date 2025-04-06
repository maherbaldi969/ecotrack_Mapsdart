class Location {
  final String name;
  final double lat;
  final double lng;
  final String? type;
  final String? description;

  Location({
    required this.name,
    required this.lat,
    required this.lng,
    this.type,
    this.description,
  });
}

class Accommodation extends Location {
  final String? contact;
  final double? rating;

  Accommodation({
    required String name,
    required double lat,
    required double lng,
    this.contact,
    this.rating,
    String? description,
  }) : super(name: name, lat: lat, lng: lng, description: description);
}

class Guide extends Location {
  final String? phone;
  final List<String>? languages;

  Guide({
    required String name,
    required double lat,
    required double lng,
    this.phone,
    this.languages,
    String? description,
  }) : super(name: name, lat: lat, lng: lng, description: description);
}

class Hike extends Location {
  final double? distance;
  final String? duration;
  final double? altitude;

  Hike({
    required String name,
    required double lat,
    required double lng,
    this.distance,
    this.duration,
    this.altitude,
    String? description,
  }) : super(name: name, lat: lat, lng: lng, description: description);
}

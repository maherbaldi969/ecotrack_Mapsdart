import 'package:flutter/material.dart';
import 'activity.dart';

class Transport {
  final Activity from;
  final Activity to;
  final Duration duration;
  final double distance; // en km
  final String mode; // 'walking', 'driving', 'public'

  const Transport({
    required this.from,
    required this.to,
    required this.duration,
    required this.distance,
    required this.mode,
  });

  String get formattedDuration {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}min';
    }
    return '${duration.inMinutes}min';
  }

  String get description {
    return 'Trajet $mode: $distance km ($formattedDuration)';
  }

  Map<String, dynamic> toMap() {
    return {
      'from': from.toMap(),
      'to': to.toMap(),
      'duration': duration.inMinutes,
      'distance': distance,
      'mode': mode,
    };
  }

  static Transport fromMap(Map<String, dynamic> map) {
    return Transport(
      from: Activity.fromMap(map['from']),
      to: Activity.fromMap(map['to']),
      duration: Duration(minutes: map['duration']),
      distance: map['distance'],
      mode: map['mode'],
    );
  }
}

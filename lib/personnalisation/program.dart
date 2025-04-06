import 'activity.dart';
import 'package:intl/intl.dart';

class Program {
  final String id;
  final String name;
  final List<Activity> activities;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isFavorite;

  Program({
    String? id,
    required this.name,
    required this.activities,
    DateTime? createdAt,
    this.updatedAt,
    this.isFavorite = false,
  }) :
        id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt = createdAt ?? DateTime.now();

  // Calcul de la durée totale
  int totalDuration() => activities.fold(0, (sum, activity) => sum + activity.duration);

  // Calcul du prix total
  double totalPrice() => activities.fold(0.0, (sum, activity) => sum + activity.price);

  // Vérification des contraintes
  bool meetsConstraints({
    required int maxDuration,
    required double maxBudget,
    List<String>? preferredCategories,
  }) {
    return totalDuration() <= maxDuration &&
        totalPrice() <= maxBudget &&
        (preferredCategories == null ||
            preferredCategories.isEmpty ||
            activities.every((a) => preferredCategories.contains(a.category)));
  }

  // Méthodes de tri
  void sortByCategory() => activities.sort((a, b) => a.category.compareTo(b.category));
  void sortByDuration({bool ascending = true}) =>
      activities.sort((a, b) => ascending
          ? a.duration.compareTo(b.duration)
          : b.duration.compareTo(a.duration));
  void sortByPrice({bool ascending = true}) =>
      activities.sort((a, b) => ascending
          ? a.price.compareTo(b.price)
          : b.price.compareTo(a.price));

  // Conversion en Map
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'activities': activities.map((a) => a.toMap()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'isFavorite': isFavorite,
  };

  // Construction à partir d'une Map
  factory Program.fromMap(Map<String, dynamic> map) => Program(
    id: map['id']?.toString(),
    name: map['name']?.toString() ?? '',
    activities: (map['activities'] as List<dynamic>?)
        ?.map((a) => Activity.fromMap(a))
        .toList() ?? <Activity>[],
    createdAt: map['createdAt'] != null
        ? DateTime.parse(map['createdAt'].toString())
        : null,
    updatedAt: map['updatedAt'] != null
        ? DateTime.parse(map['updatedAt'].toString())
        : null,
    isFavorite: map['isFavorite'] as bool? ?? false,
  );

  // Copie avec modifications
  Program copyWith({
    String? name,
    List<Activity>? activities,
    bool? isFavorite,
  }) => Program(
    id: id,
    name: name ?? this.name,
    activities: activities ?? List.from(this.activities),
    createdAt: createdAt,
    updatedAt: DateTime.now(),
    isFavorite: isFavorite ?? this.isFavorite,
  );

  // Formattage des dates
  String get formattedCreatedAt => DateFormat('dd/MM/yyyy HH:mm').format(createdAt);
  String get formattedUpdatedAt => updatedAt != null
      ? DateFormat('dd/MM/yyyy HH:mm').format(updatedAt!)
      : 'Jamais modifié';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Program &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Program "$name" (${activities.length} activités, '
      '${totalDuration()}h, ${totalPrice().toStringAsFixed(2)}€)';
}
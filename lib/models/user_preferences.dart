import 'package:flutter/material.dart';

class UserPreferences extends ChangeNotifier {
  List<String> interestTags;
  double maxBudget;
  double availableTime;
  TimeOfDay preferredStartTime;
  TimeOfDay preferredEndTime;

  UserPreferences({
    List<String>? interestTags,
    double? maxBudget, 
    double? availableTime,
    TimeOfDay? preferredStartTime,
    TimeOfDay? preferredEndTime,
  }) : interestTags = interestTags ?? ['nature', 'culture'],
       maxBudget = maxBudget ?? 50.0,
       availableTime = availableTime ?? 4.0,
       preferredStartTime = preferredStartTime ?? TimeOfDay(hour: 9, minute: 0),
       preferredEndTime = preferredEndTime ?? TimeOfDay(hour: 18, minute: 0);

  void updatePreferences({
    List<String>? interestTags,
    double? maxBudget,
    double? availableTime,
    TimeOfDay? preferredStartTime,
    TimeOfDay? preferredEndTime,
  }) {
    this.interestTags = interestTags ?? this.interestTags;
    this.maxBudget = maxBudget ?? this.maxBudget;
    this.availableTime = availableTime ?? this.availableTime;
    this.preferredStartTime = preferredStartTime ?? this.preferredStartTime;
    this.preferredEndTime = preferredEndTime ?? this.preferredEndTime;
    notifyListeners();
  }
}

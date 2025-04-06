import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'program.dart';
import 'activity.dart';

class StorageService {
  // Sauvegarder un programme
  static Future<void> saveProgram(Program program) async {
    final prefs = await SharedPreferences.getInstance();

    // Récupérer les programmes déjà sauvegardés
    List<Program> programs = await loadPrograms();

    // Ajouter le nouveau programme à la liste
    programs.add(program);

    // Convertir la liste des programmes en JSON
    String programsJson = json.encode(programs.map((e) => e.toMap()).toList());

    // Sauvegarder dans shared_preferences
    await prefs.setString('saved_programs', programsJson);
  }

  // Charger les programmes sauvegardés
  static Future<List<Program>> loadPrograms() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedProgramsJson = prefs.getString('saved_programs');

    if (savedProgramsJson != null) {
      // Convertir les données JSON en liste de programmes
      List<dynamic> programsList = json.decode(savedProgramsJson);
      return programsList.map((programJson) => Program.fromMap(programJson)).toList();
    }

    return [];
  }

  // Sauvegarder une activité (par exemple pour une session en cours)
  static Future<void> saveActivity(Activity activity) async {
    final prefs = await SharedPreferences.getInstance();

    // Récupérer les activités sauvegardées
    List<Activity> activities = await loadActivities();

    // Ajouter la nouvelle activité à la liste
    activities.add(activity);

    // Convertir la liste des activités en JSON
    String activitiesJson = json.encode(activities.map((e) => e.toMap()).toList());

    // Sauvegarder dans shared_preferences
    await prefs.setString('saved_activities', activitiesJson);
  }

  // Charger les activités sauvegardées
  static Future<List<Activity>> loadActivities() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedActivitiesJson = prefs.getString('saved_activities');

    if (savedActivitiesJson != null) {
      // Convertir les données JSON en liste d'activités
      List<dynamic> activitiesList = json.decode(savedActivitiesJson);
      return activitiesList.map((activityJson) => Activity.fromMap(activityJson)).toList();
    }

    return [];
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'program.dart';
import 'storage_service.dart';
import 'activity.dart';


class FinalizeProgramPage extends StatefulWidget {
  final Program program;
  const FinalizeProgramPage(this.program, {Key? key}) : super(key: key);

  @override
  _FinalizeProgramPageState createState() => _FinalizeProgramPageState();
}

class _FinalizeProgramPageState extends State<FinalizeProgramPage> {
  late List<ActivitySchedule> _scheduledActivities;

  @override
  void initState() {
    super.initState();
    _scheduledActivities = _generateDefaultSchedule();
  }

  List<ActivitySchedule> _generateDefaultSchedule() {
    DateTime currentTime = DateTime.now().add(const Duration(hours: 1));
    List<ActivitySchedule> schedules = [];

    for (var activity in widget.program.activities) {
      final endTime = currentTime.add(Duration(hours: activity.duration));
      schedules.add(ActivitySchedule(
        activity: activity,
        startTime: currentTime,
        endTime: endTime,
      ));
      currentTime = endTime.add(const Duration(minutes: 30));
    }

    return schedules;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Finalisation du programme",
          style: GoogleFonts.merriweather(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Votre programme :",
              style: GoogleFonts.merriweather(
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                widget.program.name,
                style: GoogleFonts.merriweather(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildSummary(),
            const SizedBox(height: 20),
            Text(
              "Activités incluses :",
              style: GoogleFonts.merriweather(
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(child: _buildActivitiesList()),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () => _saveProgram(context),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30.0, vertical: 15.0),
                  child: Text(
                    "Enregistrer le programme",
                    style: GoogleFonts.merriweather(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF80C000),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  elevation: 5,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitiesList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.program.activities.length,
      itemBuilder: (context, index) {
        final activity = widget.program.activities[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 5),
          child: ListTile(
            leading: Icon(activity.icon, color: const Color(0xFF80C000)),
            title: Text(activity.name, style: GoogleFonts.merriweather()),
            subtitle: Text(
              '${activity.duration}h • ${activity.category} • €${activity.price.toStringAsFixed(2)}',
              style: GoogleFonts.merriweather(color: Colors.grey.shade600),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.schedule, color: Color(0xFF80C000)),
              onPressed: () => _scheduleSingleActivity(activity),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummary() {
    final totalDuration = widget.program.totalDuration();
    final totalPrice = widget.program.totalPrice();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Durée totale:', style: GoogleFonts.merriweather()),
                Text('$totalDuration heures',
                    style: GoogleFonts.merriweather(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Coût total:', style: GoogleFonts.merriweather()),
                Text('€${totalPrice.toStringAsFixed(2)}',
                    style: GoogleFonts.merriweather(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _showSchedule(_scheduledActivities, editable: true),
              child: const Text('Planifier les activités'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF80C000),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveProgram(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enregistrer le programme',
              style: GoogleFonts.merriweather()),
          content: Text('Voulez-vous aussi réserver les activités maintenant ?',
              style: GoogleFonts.merriweather()),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _actuallySaveProgram();
              },
              child: Text('Enregistrer seulement',
                  style: GoogleFonts.merriweather()),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _actuallySaveProgram();
                _showBookingOptions();
              },
              child: Text('Enregistrer et réserver',
                  style: GoogleFonts.merriweather(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF80C000),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _actuallySaveProgram() async {
    await StorageService.saveProgram(widget.program);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Programme enregistré avec succès',
            style: GoogleFonts.merriweather()),
        backgroundColor: const Color(0xFF80C000),
      ),
    );

    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    Navigator.pop(context);
  }

  void _showBookingOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Options de réservation',
                style: GoogleFonts.merriweather(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.calendar_today, color: Color(0xFF80C000)),
                title: Text('Réserver toutes les activités',
                    style: GoogleFonts.merriweather()),
                onTap: () {
                  Navigator.pop(context);
                  _bookAllActivities();
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_view_day, color: Color(0xFF80C000)),
                title: Text('Choisir les activités à réserver',
                    style: GoogleFonts.merriweather()),
                onTap: () {
                  Navigator.pop(context);
                  _selectActivitiesToBook();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _bookAllActivities() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Toutes les activités ont été réservées',
            style: GoogleFonts.merriweather()),
        backgroundColor: const Color(0xFF80C000),
      ),
    );
  }

  void _selectActivitiesToBook() {
    final selectedActivities = <Activity>{};

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Sélection des activités',
                  style: GoogleFonts.merriweather()),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.program.activities.length,
                  itemBuilder: (context, index) {
                    final activity = widget.program.activities[index];
                    return CheckboxListTile(
                      title: Text(activity.name,
                          style: GoogleFonts.merriweather()),
                      subtitle: Text('${activity.duration}h • €${activity.price.toStringAsFixed(2)}',
                          style: GoogleFonts.merriweather(color: Colors.grey)),
                      value: selectedActivities.contains(activity),
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            selectedActivities.add(activity);
                          } else {
                            selectedActivities.remove(activity);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Annuler', style: GoogleFonts.merriweather()),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _bookSelectedActivities(selectedActivities.toList());
                  },
                  child: Text('Confirmer',
                      style: GoogleFonts.merriweather(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF80C000),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _bookSelectedActivities(List<Activity> activities) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          activities.isEmpty
              ? 'Aucune activité sélectionnée'
              : '${activities.length} activité(s) réservée(s)',
          style: GoogleFonts.merriweather(),
        ),
        backgroundColor: const Color(0xFF80C000),
      ),
    );
  }

  void _scheduleActivities() {
    _scheduledActivities = _generateDefaultSchedule();
    _showSchedule(_scheduledActivities, editable: true);
  }

  void _scheduleSingleActivity(Activity activity) {
    final schedule = ActivitySchedule(
      activity: activity,
      startTime: DateTime.now().add(const Duration(hours: 1)),
      endTime: DateTime.now().add(Duration(hours: 1 + activity.duration)),
    );
    _showSchedule([schedule], editable: true);
  }

  void _showSchedule(List<ActivitySchedule> schedules, {bool editable = false}) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Planning proposé',
                  style: GoogleFonts.merriweather(fontWeight: FontWeight.bold)),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: schedules.length,
                  itemBuilder: (context, index) {
                    final item = schedules[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      child: ListTile(
                        leading: Icon(item.activity.icon, color: const Color(0xFF80C000)),
                        title: Text(item.activity.name,
                            style: GoogleFonts.merriweather()),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${DateFormat.Hm().format(item.startTime)} - ${DateFormat.Hm().format(item.endTime)}',
                              style: GoogleFonts.merriweather(color: Colors.grey.shade600),
                            ),
                            if (editable) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Durée: ${item.activity.duration}h',
                                style: GoogleFonts.merriweather(fontSize: 12),
                              ),
                            ],
                          ],
                        ),
                        trailing: editable
                            ? IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () => _editScheduleTime(setState, schedules, index),
                        )
                            : null,
                      ),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(editable ? 'Annuler' : 'Fermer',
                      style: GoogleFonts.merriweather()),
                ),
                if (editable)
                  ElevatedButton(
                    onPressed: () {
                      if (schedules == _scheduledActivities) {
                        _scheduledActivities = List.from(schedules);
                      }
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Planning enregistré',
                              style: GoogleFonts.merriweather()),
                          backgroundColor: const Color(0xFF80C000),
                        ),
                      );
                    },
                    child: Text('Confirmer',
                        style: GoogleFonts.merriweather(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF80C000),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  void _editScheduleTime(
      StateSetter setState, List<ActivitySchedule> schedules, int index) {
    final item = schedules[index];
    final initialTime = TimeOfDay.fromDateTime(item.startTime);

    showTimePicker(
      context: context,
      initialTime: initialTime,
    ).then((newTime) {
      if (newTime != null) {
        setState(() {
          final newStartTime = DateTime(
            item.startTime.year,
            item.startTime.month,
            item.startTime.day,
            newTime.hour,
            newTime.minute,
          );
          final duration = item.endTime.difference(item.startTime);
          schedules[index] = ActivitySchedule(
            activity: item.activity,
            startTime: newStartTime,
            endTime: newStartTime.add(duration),
          );
        });
      }
    });
  }
}

class ActivitySchedule {
  final Activity activity;
  final DateTime startTime;
  final DateTime endTime;

  ActivitySchedule({
    required this.activity,
    required this.startTime,
    required this.endTime,
  });
}
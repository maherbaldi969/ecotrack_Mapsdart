import 'package:flutter/material.dart';
import '../models/progModels.dart';
import 'detail_silver.dart';
import 'info.dart';
import '../services/tours_service.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class details extends StatelessWidget {
  const details({super.key, required this.Progs});
  final progModels Progs;

  Future<void> downloadMap(BuildContext context) async {
    final ToursService toursService = ToursService();
    try {
      final bytes = await toursService.downloadTourMap(Progs.title); // Using title as id substitute
      final dir = await getApplicationDocumentsDirectory();
      final file = File('\${dir.path}/tour_map_\${Progs.title}.pdf');
      await file.writeAsBytes(bytes);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Carte téléchargée: \${file.path}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du téléchargement de la carte')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    try {
      return Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverPersistentHeader(
              delegate: DetailSliverDelegate(
                Progs: Progs,
                expandedHeight: 360,
                roundedContainerHeight: 30,
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  ProgInfo(Progs),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, '/guideDetails', arguments: Progs.title);
                          },
                          icon: Icon(Icons.group),
                          label: Text('Voir guides'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF80C000),
                            foregroundColor: Colors.white,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => downloadMap(context),
                          icon: Icon(Icons.download),
                          label: Text('Télécharger la carte'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF80C000),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      return Scaffold(
        body: Center(
          child: Text(
            'Une erreur est survenue',
            style: TextStyle(color: Color(0xFF80C000)),
          ),
        ),
      );
    }
  }
}

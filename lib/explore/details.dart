import 'package:flutter/material.dart';
import '../models/progModels.dart';
import 'detail_silver.dart';
import 'info.dart';
class details extends StatelessWidget {
  const details({super.key,required this.Progs});
  final progModels Progs;


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
              child: ProgInfo(Progs),
            )
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
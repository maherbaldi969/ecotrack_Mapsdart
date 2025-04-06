import 'package:flutter/material.dart';
import '../models/progModels.dart';
import 'package:readmore/readmore.dart';

class DescriptionSection extends StatelessWidget {
  final progModels Progs;
  const DescriptionSection(this.Progs, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: ReadMoreText(
        Progs.description,
        trimLines: 2,
        colorClickableText: const Color(0xFF80C000),
        trimMode: TrimMode.Line,
        trimCollapsedText: 'Plus',
        trimExpandedText: 'Moins',
        style: TextStyle(
          color: Colors.grey.withOpacity(0.7),
          height: 1.5,
        ),
      ),
    );
  }
}

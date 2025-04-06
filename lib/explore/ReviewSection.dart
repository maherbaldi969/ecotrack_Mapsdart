
import 'package:ecotrack/explore/selectGuide.dart';
import 'package:flutter/material.dart';
import '../models/progModels.dart';

class ReviewSection extends StatelessWidget {
  final progModels Progs;
  const ReviewSection(this.Progs, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Notation et évaluation',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'view',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Progs.review.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 48,
                ),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 25,
                        color: Colors.amber,
                      ),
                      const Icon(
                        Icons.star,
                        size: 25,
                        color: Colors.amber,
                      ),
                      const Icon(
                        Icons.star,
                        size: 25,
                        color: Colors.amber,
                      ),
                      const Icon(
                        Icons.star,
                        size: 25,
                        color: Colors.amber,
                      ),
                      Icon(Icons.star,
                          size: 25, color: Colors.grey.withOpacity(0.3)),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${Progs.review.toString()} avis',
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 5),
          SizedBox(
            width: double.maxFinite,
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFF80C000),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => SelectGuidePage(),
                    ),
                    );
                  },
                  child: const Text(
                    'Sélectionner le guide',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],),
          ),
        ],
      ),
    );
  }
}

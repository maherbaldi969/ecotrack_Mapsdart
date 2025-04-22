import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/tour.dart';
import '../services/tours_service.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class GuideReviewsPage extends StatefulWidget {
  final Tour tour;
  const GuideReviewsPage(this.tour, {super.key});

  @override
  State<GuideReviewsPage> createState() => _GuideReviewsPageState();
}

class _GuideReviewsPageState extends State<GuideReviewsPage> {
  bool _isMounted = true;
  bool isLoading = true;
  String? errorMessage;
  List<dynamic> guides = [];
  List<dynamic> reviews = [];
  bool isLoadingReviews = false;
  String? reviewsErrorMessage;

  final ToursService toursService = ToursService();

  @override
  void initState() {
    super.initState();
    fetchGuides();
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  Future<void> fetchGuides() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final fetchedGuides =
          await toursService.getTourGuides(widget.tour.id.toString());
      if (!_isMounted) return;
      setState(() {
        guides = fetchedGuides;
        isLoading = false;
      });
    } catch (e) {
      if (!_isMounted) return;
      setState(() {
        errorMessage = "Erreur lors du chargement des guides.";
        isLoading = false;
      });
    }
  }

  Future<void> downloadReviews() async {
    setState(() {
      isLoadingReviews = true;
      reviewsErrorMessage = null;
    });
    try {
      final fetchedReviews =
          await toursService.getTourReviews(widget.tour.id.toString());
      if (!_isMounted) return;
      setState(() {
        reviews = fetchedReviews;
        isLoadingReviews = false;
      });
    } catch (e) {
      if (!_isMounted) return;
      setState(() {
        reviewsErrorMessage = "Erreur lors du chargement des avis.";
        isLoadingReviews = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF80C000),
        foregroundColor: Colors.white,
        title: Text('Guides associés',
            style: GoogleFonts.merriweather(color: Colors.white)),
        centerTitle: false,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Text(
                    errorMessage!,
                    style: GoogleFonts.merriweather(color: Color(0xFF80C000)),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.separated(
                          itemCount: guides.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final guide = guides[index];
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  )
                                ],
                                border: Border.all(
                                  color: const Color(0xFF80C000),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    guide['display_name'] ?? 'Nom inconnu',
                                    style: GoogleFonts.merriweather(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Langue(s) parlée(s): ${guide['meta']?['langue'] ?? 'N/A'}',
                                    style: GoogleFonts.poppins(
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    'Expérience: ${guide['meta']?['experience'] ?? 'N/A'} ans',
                                    style: GoogleFonts.poppins(
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  if (reviews.isNotEmpty)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Avis:',
                                          style: GoogleFonts.merriweather(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF80C000),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        ...reviews
                                            .where((review) =>
                                                review['comment_author'] ==
                                                guide['display_name'])
                                            .map((review) => Container(
                                                  margin: const EdgeInsets.only(
                                                      bottom: 8),
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[100],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    border: Border.all(
                                                        color: Colors
                                                            .grey.shade300),
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        review['comment_content'] ??
                                                            '',
                                                        style:
                                                            GoogleFonts.poppins(
                                                          color: Colors.black87,
                                                        ),
                                                      ),
                                                      if (review[
                                                              'comment_date'] !=
                                                          null)
                                                        Text(
                                                          review[
                                                              'comment_date'],
                                                          style: GoogleFonts
                                                              .poppins(
                                                            color:
                                                                Colors.black54,
                                                            fontStyle: FontStyle
                                                                .italic,
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ))
                                            .toList(),
                                      ],
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      if (isLoadingReviews)
                        const Center(child: CircularProgressIndicator()),
                      if (reviewsErrorMessage != null)
                        Center(
                          child: Text(
                            reviewsErrorMessage!,
                            style: GoogleFonts.merriweather(
                              color: const Color(0xFF80C000),
                            ),
                          ),
                        ),
                      if (reviews.isNotEmpty)
                        Container(
                          height: 300,
                          child: ListView.separated(
                            itemCount: reviews.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final review = reviews[index];
                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    )
                                  ],
                                  border: Border.all(
                                    color: const Color(0xFF80C000),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      review['comment_author'] ??
                                          'Auteur inconnu',
                                      style: GoogleFonts.merriweather(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      review['comment_content'] ?? '',
                                      style: GoogleFonts.poppins(
                                        color: Colors.black87,
                                      ),
                                    ),
                                    if (review['comment_date'] != null)
                                      Text(
                                        review['comment_date'],
                                        style: GoogleFonts.poppins(
                                          color: Colors.black54,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF80C000),
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: downloadReviews,
                        icon: const Icon(Icons.download, color: Colors.white),
                        label: Text(
                          'Afficher les avis',
                          style: GoogleFonts.merriweather(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

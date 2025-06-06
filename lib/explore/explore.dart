import 'details.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'filtrer.dart';
import '../services/tours_service.dart';
import '../models/tour.dart';

const vert = Color(0xFF80C000);
const gris = Color(0xFF8B8787);

class Explore extends StatefulWidget {
  @override
  _ExploreState createState() => _ExploreState();
}

class _ExploreState extends State<Explore> {
  bool _isLoading = false;
  String? _errorMessage;
  List<Tour> _tours = [];

  final ToursService toursService = ToursService();

  @override
  void initState() {
    super.initState();
    _loadTours();
  }

  Future<void> _loadTours() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final toursData = await toursService.getAllTours();
      // Removed print statements for production code
      final tours = toursData.map<Tour>((map) => Tour.fromMap(map)).toList();
      setState(() {
        _tours = tours;
      });
    } catch (e) {
      // Removed print statements for production code
      setState(() {
        _errorMessage =
            "Erreur lors du chargement des tours. Veuillez vérifier votre connexion internet et réessayer.";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _openFilterDialog() async {
    final result = await showGeneralDialog(
      barrierDismissible: true,
      barrierLabel: "Filtrer",
      context: context,
      pageBuilder: (context, _, __) => Dialog(
        insetPadding: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FilterModal(),
            ),
          ),
        ),
      ),
    );
    if (result != null && result is List<dynamic>) {
      setState(() {
        _tours = result.map<Tour>((map) => Tour.fromMap(map)).toList();
      });
    } else {
      _loadTours();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: MyAppBar(),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    SearchSection(),
                    Container(
                      padding: EdgeInsets.all(10),
                      color: Colors.white,
                      child: Column(
                        children: [
                          Container(
                            height: 50,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${_tours.length} Tours',
                                    style: GoogleFonts.poppins(
                                        color: Color(0xFF80C000),
                                        fontSize: 15)),
                                Row(
                                  children: [
                                    Text('Filtrer ',
                                        style: GoogleFonts.poppins(
                                            color: Color(0xFF80C000),
                                            fontSize: 15)),
                                    IconButton(
                                      onPressed: _openFilterDialog,
                                      icon: Icon(
                                        Icons.filter_list_outlined,
                                        color: vert,
                                        size: 25,
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                          _tours.isEmpty
                              ? Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Text(
                                    'Aucun résultat',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.grey),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: _tours.length,
                                  itemBuilder: (context, index) {
                                    final tour = _tours[index];
                                    final imagePath =
                                        'assets/images/prog${(index % 4) + 1}.jpg';
                                    return ProgCard(tour, imagePath: imagePath);
                                  },
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(50);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        "Explorer un Programme",
        style: GoogleFonts.merriweather(
          fontSize: 18,
          color: const Color(0xFF80C000),
        ),
      ),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
    );
  }
}

class SearchSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      color: Colors.grey[200],
      padding: EdgeInsets.fromLTRB(10, 25, 10, 10),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(left: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        blurRadius: 4,
                        offset: Offset(0, 4),
                      )
                    ],
                  ),
                  height: 50,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Tunisie',
                      hintStyle: TextStyle(color: Colors.black54),
                      contentPadding: EdgeInsets.all(10),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      blurRadius: 4,
                      offset: Offset(0, 4),
                    )
                  ],
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                ),
                child: ElevatedButton(
                  onPressed: () {},
                  child: Icon(Icons.search, size: 25),
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    backgroundColor: vert,
                    padding: EdgeInsets.all(10),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}

class ProgCard extends StatelessWidget {
  final Tour tour;
  final String imagePath;

  const ProgCard(this.tour, {required this.imagePath, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final title = tour.title;
    final place = tour.locationPoint;

    return GestureDetector(
      onTap: () {
        try {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Details(Progs: tour),
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Erreur: impossible d'ouvrir les détails")),
          );
        }
      },
      child: Container(
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(
            Radius.circular(18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              spreadRadius: 4,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
                color: Colors.grey[200],
              ),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Icon(Icons.schedule, color: vert, size: 16.0),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Durée: ${tour.duration.toString()} h',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w400,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.price_check, color: vert, size: 16.0),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${tour.price.toString()} TND',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w400,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(10, 3, 10, 0),
              child: Row(
                children: [
                  Row(
                    children: List.generate(4, (index) {
                      return Icon(Icons.star_rate, color: vert, size: 14);
                    })
                      ..add(Icon(Icons.star_border, color: vert, size: 14)),
                  ),
                  SizedBox(width: 20),
                  Text(
                    '0 reviews',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
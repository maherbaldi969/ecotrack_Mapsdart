import 'details.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'filtrer.dart';
import '../models/progModels.dart';

const vert = Color(0xFF80C000);
const gris = Color(0xFF8B8787);

class Explore extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: MyAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SearchSection(),
            ProgSection(),
          ],
        ),
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
        style:  GoogleFonts.merriweather(fontSize: 18 , color: const Color(0xFF80C000),),
      ),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
    );}
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

class ProgSection extends StatelessWidget {
  final List<progModels> progs = progModels.Progs();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      color: Colors.white,
      child: Column(
        children: [
          Container(
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('550 Programmes',
                    style: GoogleFonts.poppins(
                        color: Color(0xFF80C000), fontSize: 15)),
                Row(
                  children: [
                    Text('Filtrer ',
                        style: GoogleFonts.poppins(
                            color: Color(0xFF80C000), fontSize: 15)),
                    IconButton(
                        onPressed: () {
                          showGeneralDialog(
                            barrierDismissible: true,
                            barrierLabel: "Sign In",
                            context: context,
                            pageBuilder: (context, _, __) => Center(
                              child: Container(
                                height: 620,
                                margin: EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(40)),
                                ),
                                child: Scaffold(
                                  backgroundColor: Colors.transparent,
                                  body: Column(
                                    children: [
                                      FilterModal(),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.filter_list_outlined,
                          color: vert,
                          size: 25,
                        ))
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: progs.map((Progs) {
              return ProgCard(Progs);
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class ProgCard extends StatelessWidget {
  final progModels progData;
  ProgCard(this.progData);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => details(Progs: progData),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.all(10),
        height: 230,
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
          children: [
            Container(
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
                image: DecorationImage(
                  image: AssetImage(progData.Picture),
                  fit: BoxFit.cover,
                ),
              ),

              child: Stack(
                children: [
                  Positioned(
                    top: 5,
                    right: -15,
                    child: MaterialButton(
                      color: Colors.white,
                      shape: CircleBorder(),
                      onPressed: () {},
                      child: Icon(
                        Icons.favorite_outline_rounded,
                        color: Color(0xFF80C000),
                        size: 20,
                      ),
                    ),
                  )
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: Text(
                progData.title,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    progData.place,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.place, color: vert, size: 16.0),
                      Text(
                        '${progData.distance} km to city',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w400,
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
                    '${progData.review} reviews',
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
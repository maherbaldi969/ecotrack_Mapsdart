import 'tour.dart';

class ProgModels {
  String title;
  String place;
  num distance;
  num review;
  String picture;
  List<String> images;
  String description;
  //pour le guide
  String nom;
  String icon;
  String experience;
  String langues ;
  num avis ;


  ProgModels(
      this.title,
      this.place,
      this.distance,
      this.review,
      this.picture,
      this.images,
      this.description,
      this.nom,
      this.icon,
      this.experience,
      this.langues ,
      this.avis ,

      );

  Tour toTour() {
    return Tour(
      id: 0,
      wpPostId: 0,
      title: title,
      description: description,
      locationPoint: place,
      duration: distance.toInt(),
      price: '',
      postTitle: title,
      postContent: description,
    );
  }

  static List<ProgModels> progs() {
    return [
      ProgModels(
        'Djabel Sarj',
        'Seliana',
         2,
         36,
         'images/prog1.jpg',
        [
          'images/prog1.jpg',
          'images/prog2.jpg',
          'images/prog3.jpg',
        ],
         'Le djebel Serj est situé à vingt kilomètres au sud-est de Siliana et à soixante kilomètres au'
         ' nord-ouest de Kairouan, au milieu de la dorsale, à mi-chemin entre Oueslatia et Bargou. '
         'Il mesure environ cinq kilomètres de large sur vingt kilomètres de long.',
        'Mohamed',
        'images/user.png',
        '5 ans',
        'Francais , anglais',
          5,

      ),
      ProgModels(
         'Aïn Draham',
        'Jendouba',
         23,
         19,
         'images/prog2.jpg',
        [
          'images/prog1.jpg',
          'images/prog2.jpg',
          'images/prog3.jpg',
        ],
          'Le djebel Serj est situé à vingt kilomètres au sud-est de Siliana et à soixante kilomètres au'
          ' nord-ouest de Kairouan, au milieu de la dorsale, à mi-chemin entre Oueslatia et Bargou. '
          'Il mesure environ cinq kilomètres de large sur vingt kilomètres de long.',
        'Amin',
        'images/user.png',
        '3 ans',
        'Français , anglais',
          3,


      ),ProgModels(
        'Ichkeul National Park',
        'Bizerte',
         8,
         25,
         'images/prog3.jpg',
        [
          'images/prog1.jpg',
          'images/prog2.jpg',
          'images/prog3.jpg',
        ],
        'Le djebel Serj est situé à vingt kilomètres au sud-est de Siliana et à soixante kilomètres au'
        ' nord-ouest de Kairouan, au milieu de la dorsale, à mi-chemin entre Oueslatia et Bargou. '
        'Il mesure environ cinq kilomètres de large sur vingt kilomètres de long.',
        'Fathi',
        'images/user.png',
        '6 ans',
        'Allemand , arabic',
          4,

      ),ProgModels(
        'Hammam Zouakra',
        'Seliana',
         2,
         36,
        'images/prog4.jpg',
        [
          'images/prog1.jpg',
          'images/prog2.jpg',
          'images/prog3.jpg',
        ],
          'Le djebel Serj est situé à vingt kilomètres au sud-est de Siliana et à soixante kilomètres au'
          ' nord-ouest de Kairouan, au milieu de la dorsale, à mi-chemin entre Oueslatia et Bargou. '
          'Il mesure environ cinq kilomètres de large sur vingt kilomètres de long.',
        'Hicham',
        'images/user.png',
        '2 ans',
        'Français, espagnol',
          3,
      ),
    ];
  }
}

class progModels {
  String title;
  String place;
  num distance;
  num review;
  String Picture;
  List<String> images;
  String description;
  //pour le guide
  String nom;
  String icon;
  String experience;
  String langues ;
  num avis ;


  progModels(
      this.title,
      this.place,
      this.distance,
      this.review,
      this.Picture,
      this.images,
      this.description,
      this.nom,
      this.icon,
      this.experience,
      this.langues ,
      this.avis ,

      );

  static List<progModels> Progs() {
    return [
      progModels(
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
      progModels(
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


      ),progModels(
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

      ),progModels(
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

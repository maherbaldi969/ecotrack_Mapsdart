import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_sequence_animator/image_sequence_animator.dart';
import 'package:provider/provider.dart';
import '../widget/constant.dart';
import '../provider/pageNotifier.dart';
import '2.dart';
import '3.dart';

import '../provider/botton_nav_bar.dart';
import '1.dart';

void main() => runApp(FitnessApp());

class FitnessApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<BottonNavBar>(create: (_) => BottonNavBar()),
        ChangeNotifierProvider<PageNotifier>(create: (_) => PageNotifier()),
      ],
      child: MaterialApp(
        builder: (ctx, child) {
          ScreenUtil.init(ctx, designSize: const Size(390, 844));
          return Theme(
            data: ThemeData(
                primarySwatch: Colors.blue,
                textTheme: GoogleFonts.montserratTextTheme().copyWith()),
            child: const FitnessHomePage(),
          );
        },
      ),
    );
  }
}

class FitnessHomePage extends StatefulWidget {
  const FitnessHomePage({Key? key}) : super(key: key);

  @override
  _FitnessHomePageState createState() => _FitnessHomePageState();
}

class _FitnessHomePageState extends State<FitnessHomePage> {
  late PageController _pageController;
  ImageSequenceAnimatorState? offlineImageSequenceAnimator;
  bool _disposed = false;
  late PageNotifier _pageNotifier;

  void onOfflineReadyToPlay(ImageSequenceAnimatorState imageSequenceAnimator) {
    if (_disposed) return;
    offlineImageSequenceAnimator = imageSequenceAnimator;
    imageSequenceAnimator.setIsLooping(true);
  }

  void onOfflinePlaying(ImageSequenceAnimatorState imageSequenceAnimator) {
    if (_disposed || !mounted) return;
    scheduleMicrotask(() {
      if (!_disposed && mounted) {
        setState(() {});
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_disposed && mounted) {
        _pageController.addListener(_handlePageChanged);
      }
    });
  }

  void _handlePageChanged() {
    if (_disposed || !mounted) return;
    final page = _pageController.page;
    if (page != null) {
      _pageNotifier.listener(page);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pageNotifier = Provider.of<PageNotifier>(context, listen: false);
    _precacheImages();
  }

  void _precacheImages() async {
    for (int i = 0; i <= 38; i++) {
      String path = "assets/walking-animtaion/frame_00";
      if (i / 10 < 1) {
        path += "0$i.png";
      } else {
        path += "$i.png";
      }
      if (!_disposed && mounted) {
        await precacheImage(AssetImage(path), context);
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _pageController.removeListener(_handlePageChanged);
    _pageController.dispose();
    super.dispose();
  }

  List<Widget> screens = const [FristScreen(), SecondScreen(), ThreeScreen()];
  List<Widget> topLeftStats = const [
    UserStats(),
    TopLeftStat2(),
    SizedBox(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Consumer<PageNotifier>(
        builder: (context, provider, _) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragEnd: (details) {
              if (_disposed || !mounted) return;

              if (details.primaryVelocity! > 0) {
                if (_pageController.page! > 0) {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              } else if (details.primaryVelocity! < 0) {
                if (_pageController.page! < screens.length - 1) {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              }
            },
            child: Stack(
              children: [
                SizedBox(height: 1.sh, width: 1.sw),
                PageView.builder(
                  controller: _pageController,
                  itemCount: screens.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        screens[index],
                        Positioned(
                          left: 20.sp,
                          top: MediaQuery.of(context).viewPadding.top + 20.h,
                          child: CubeWidget(
                            index: index,
                            pageNotifier: provider.page,
                            child: topLeftStats[index],
                          ),
                        ),
                      ],
                    );
                  },
                ),
                Consumer<PageNotifier>(builder: (context, provider, _) {
                  int index = provider.page.floor();
                  final t = (provider.page.floor() - provider.page);
                  Offset s1 = Offset(40.w, 50.h);
                  Offset s2 = Offset(0.w, 60.h);
                  Offset s3 = Offset(0.w, 180.h);

                  Size manScale1 = Size(400.w, 500.h);
                  Size manScale2 = Size(650.w, 700.h);

                  return Stack(
                    children: [
                      SizedBox(height: 1.sh, width: 1.sw),
                      Transform.translate(
                        offset: index == 2
                            ? Offset(
                            lerpDouble(s3.dx, s2.dx, t.abs()) ?? s2.dx,
                            lerpDouble(s3.dy, s2.dy, t.abs()) ?? s2.dy)
                            : index == 1
                            ? Offset(
                            lerpDouble(s2.dx, s3.dx, t.abs()) ?? s3.dx,
                            lerpDouble(s2.dy, s3.dy, t.abs()) ?? s3.dy)
                            : Offset(
                            lerpDouble(s1.dx, s2.dx, t.abs()) ?? s2.dx,
                            lerpDouble(s1.dy, s2.dy, t.abs()) ?? s2.dy),
                        child: SizedBox(
                          height: index == 2
                              ? manScale2.height
                              : index == 1
                              ? lerpDouble(manScale1.height, manScale2.height, t.abs()) ?? manScale1.height
                              : manScale1.height,
                          width: index == 2
                              ? manScale2.width
                              : index == 1
                              ? lerpDouble(manScale1.width, manScale2.width, t.abs()) ?? manScale1.width
                              : manScale1.width,
                          child: ImageSequenceAnimator(
                            "assets/walking-animtaion",
                            "frame_",
                            0,  // Start from frame 0 instead of 1
                            4,
                            "png",
                            38,  // Total 39 frames (0-38)
                            key: const Key("man-walking"),
                            fps: 30,
                            onReadyToPlay: onOfflineReadyToPlay,
                            onPlaying: onOfflinePlaying,
                          ),
                        ),
                      ),
                      provider.page > 1
                          ? Transform.translate(
                        offset: index == 2
                            ? const Offset(0, 0)
                            : Offset(lerpDouble(1.sw, 0, t.abs()) ?? 0, 0),
                        child: const ThreeScreen(),
                      )
                          : const SizedBox(),
                    ],
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}

class CubeWidget extends StatelessWidget {
  final int index;
  final double pageNotifier;
  final Widget child;

  const CubeWidget({
    Key? key,
    required this.index,
    required this.pageNotifier,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isLeaving = (index - pageNotifier) <= 0;
    final t = (index - pageNotifier);
    final rotationY = lerpDouble(0, 90, t) ?? 0;
    final opacity = (lerpDouble(1, 0, t.abs())?.clamp(0.0, 1.0).toDouble()) ?? 1.0;
    final transform = Matrix4.identity();
    transform.setEntry(3, 2, 0.003);
    transform.rotateY(-degToRad(rotationY));
    return Transform(
      alignment: !isLeaving ? Alignment.centerRight : Alignment.centerLeft,
      transform: transform,
      child: Opacity(opacity: opacity, child: child),
    );
  }
}

double degToRad(num deg) => deg * (pi / 180.0);
double radToDeg(num rad) => rad * (180.0 / pi);
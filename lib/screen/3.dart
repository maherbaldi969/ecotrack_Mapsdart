import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../widget/constant.dart'; // Adjusted import path
import 'points1.dart'; // Adjusted import path
import '../provider/pageNotifier.dart'; // Adjusted import path

class ThreeScreen extends StatefulWidget {
  const ThreeScreen({super.key});

  @override
  State<ThreeScreen> createState() => _ThreeScreenState();
}

class _ThreeScreenState extends State<ThreeScreen> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomPaint(
          painter: HolePainter(),
          child: SizedBox(
            width: 1.sw,
            height: 1.sh,
          ),
        ),
        Positioned(
          left: 20.sp,
          top: MediaQuery.of(context).viewPadding.top + 20.h,
          child: Consumer<PageNotifier>(builder: (context, provider, _) {
            return CubeWidget(
              index: provider.page.ceil(),
              pageNotifier: provider.page,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Profil",
                    style: TextStyle(
                        fontSize: 24.sp,
                        color: textColor,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Nom : Randonneur",
                    style: TextStyle(fontSize: 29.sp, color: textColor),
                  ),
                  Text(
                    "Âge : 25 ans",
                    style:
                    TextStyle(fontSize: 16.sp, color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }),
        ),
        Positioned(
          left: 20.w,
          right: 20.w,
          bottom: 20.h,
          child: Column(
            children: [
              Text(
                "Objectifs Quotidiens",
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 1.h,
              ),
              const ProfileStats(
                iconPath: "assets/icons/fire.svg",
                bgColor: ring1Color,
                text1: "Distance",
                text2: "10 km",
              ),
              SizedBox(
                height: 1.h,
              ),
              const ProfileStats(
                iconPath: "assets/icons/steps.svg",
                bgColor: ring2Color,
                text1: "Dénivelé",
                text2: "500 m",
              ),
              SizedBox(
                height: 1.h,
              ),
              const ProfileStats(
                iconPath: "assets/icons/moon.svg",
                bgColor: ring3Color,
                text1: "Durée",
                text2: "4 heures",
              )
            ],
          ),
        )
      ],
    );
  }
}

class ProfileStats extends StatelessWidget {
  const ProfileStats({
    super.key,
    this.iconPath,
    required this.text1,
    required this.text2,
    required this.bgColor,
  });
  final iconPath;
  final Color bgColor;
  final String text1;
  final String text2;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.h,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: bgColor, borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.r),
        child: Row(
          children: [
            SvgPicture.asset(
              iconPath,
              width: 22.r,
              color: Colors.white,
            ),
            SizedBox(
              width: 20.w,
            ),
            Text(
              text1,
              style: TextStyle(color: Colors.grey.shade100, fontSize: 18.sp),
            ),
            const Spacer(),
            Text(
              text2,
              style: TextStyle(color: Colors.white, fontSize: 20.sp),
            )
          ],
        ),
      ),
    );
  }
}

class HolePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    paint.color = Colors.white;
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()
          ..addRRect(
              RRect.fromLTRBR(0, 0, 1.sw, 1.sh, const Radius.circular(10))),
        Path()
          ..addOval(Rect.fromCircle(
              center: Offset(1.sw * 0.5, 1.sh * 0.35), radius: 1.sw * 0.35))
          ..close(),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

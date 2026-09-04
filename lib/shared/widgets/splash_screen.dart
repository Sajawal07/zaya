import 'package:flutter/material.dart';

/// Custom branded splash — shows [splash.png] full-bleed (logo/text already on the image).
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  static const String imageAsset = 'assets/images/splash.png';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFFAF5F0),
      body: SizedBox.expand(
        child: Image(
          image: AssetImage(imageAsset),
          fit: BoxFit.cover,
          alignment: Alignment.center,
          filterQuality: FilterQuality.high,
          gaplessPlayback: true,
        ),
      ),
    );
  }
}

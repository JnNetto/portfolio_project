import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AppLottie extends StatelessWidget {
  final String asset;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Animation<double>? controller;

  const AppLottie({
    super.key,
    required this.asset,
    this.width,
    this.height,
    this.fit = BoxFit.fill,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      asset,
      width: width,
      height: height,
      fit: fit,
      controller: controller,
      repeat: true,
      frameRate: const FrameRate(30),
      renderCache: RenderCache.raster,
      backgroundLoading: true,
      addRepaintBoundary: true,
      filterQuality: FilterQuality.low,
    );
  }
}

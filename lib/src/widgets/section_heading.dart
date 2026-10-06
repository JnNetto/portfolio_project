import 'package:flutter/material.dart';
import 'package:portfolio/src/utils/app_fonts.dart';
import 'package:portfolio/src/utils/colors.dart';

/// Cabeçalho comum às seções: etiqueta numerada na cor de destaque (no
/// mesmo tom do "PORTFOLIO / MOBILE + WEB" do topo), título e subtítulo.
class SectionHeading extends StatelessWidget {
  final String index;
  final String eyebrow;
  final String title;
  final String? subtitle;

  const SectionHeading({
    super.key,
    required this.index,
    required this.eyebrow,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final wide = width > 720;

    return Padding(
      padding: EdgeInsets.only(bottom: wide ? 48 : 32),
      child: Semantics(
        header: true,
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  index,
                  style: TextStyle(
                    color: ColorsApp.accent(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                Container(
                  width: 28,
                  height: 1.5,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  color: ColorsApp.accent(context),
                ),
                Text(
                  eyebrow.toUpperCase(),
                  style: TextStyle(
                    color: ColorsApp.accent(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 3.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppFonts.aBeeZee(
                textStyle: TextStyle(
                  fontSize: wide ? 56 : 36,
                  height: 1.05,
                  fontWeight: FontWeight.w700,
                  letterSpacing: wide ? -1.6 : -0.8,
                  color: ColorsApp.letters(context),
                ),
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 14),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ColorsApp.muted(context),
                    fontSize: wide ? 16 : 14,
                    height: 1.55,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

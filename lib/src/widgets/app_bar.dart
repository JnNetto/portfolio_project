import 'package:flutter/material.dart';
import 'package:portfolio/src/utils/app_fonts.dart';

import '../utils/colors.dart';

PreferredSizeWidget appBarCustom(BoxConstraints constraints, List<Widget> list,
    Widget drawer, VoidCallback toggleTheme, BuildContext context) {
  return AppBar(
    toolbarHeight: 72,
    backgroundColor: ColorsApp.appbar(context),
    surfaceTintColor: Colors.transparent,
    shadowColor: ColorsApp.shadowColor(context),
    elevation: 0,
    scrolledUnderElevation: 0,
    // Os links só cabem ao lado do título a partir de ~860px; abaixo disso,
    // menu lateral. O FittedBox evita overflow em larguras transitórias
    // (ex.: janela sendo redimensionada).
    actions: [
      FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: constraints.maxWidth > 860 ? list : [drawer],
        ),
      ),
    ],
    title: FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: TitleAppBar(
        constraints: constraints,
        toggleTheme: toggleTheme,
      ),
    ),
  );
}

class TitleAppBar extends StatelessWidget {
  final VoidCallback toggleTheme;
  const TitleAppBar({
    super.key,
    required this.constraints,
    required this.toggleTheme,
  });

  final BoxConstraints constraints;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          left: constraints.maxWidth > 1050
              ? 24
              : constraints.maxWidth * 0.02),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'JnNetto',
            style: AppFonts.poppins(
              textStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 22,
                letterSpacing: -0.4,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: Theme.of(context).brightness == Brightness.dark
                ? 'Ativar tema claro'
                : 'Ativar tema escuro',
            onPressed: toggleTheme,
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.dark_mode
                  : Icons.light_mode,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

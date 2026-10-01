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
    actions: constraints.maxWidth > 480 ? list : [drawer],
    title: TitleAppBar(
      constraints: constraints,
      toggleTheme: toggleTheme,
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

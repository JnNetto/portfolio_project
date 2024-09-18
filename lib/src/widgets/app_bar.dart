import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/colors.dart';

PreferredSizeWidget appBarCustom(BoxConstraints constraints, List<Widget> list,
    Widget drawer, VoidCallback toggleTheme, BuildContext context) {
  return AppBar(
    toolbarHeight: constraints.maxHeight * .1,
    backgroundColor: ColorsApp.appbar(context),
    shadowColor: ColorsApp.shadowColor(context),
    elevation: 40,
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
              ? constraints.maxWidth * 0.15
              : constraints.maxWidth * 0.05),
      child: Row(
        children: [
          Text("JnNetto",
              style: GoogleFonts.poppins(
                textStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 40),
              )),
          SizedBox(
            width: constraints.maxWidth * 0.01,
          ),
          IconButton(
            onPressed: toggleTheme,
            icon: Icon(
                Theme.of(context).brightness == Brightness.dark
                    ? Icons.dark_mode
                    : Icons.light_mode,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.white),
          ),
        ],
      ),
    );
  }
}

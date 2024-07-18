import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/colors.dart';

PreferredSizeWidget appBarCustom(
    BoxConstraints constraints, List<Widget> list, Widget drawer) {
  return AppBar(
    toolbarHeight: constraints.maxHeight * .1,
    backgroundColor: ColorsApp.appbar,
    shadowColor: ColorsApp.shadowColor,
    elevation: 40,
    actions: constraints.maxWidth > 480 ? list : [drawer],
    title: TitleAppBar(constraints: constraints),
  );
}

class TitleAppBar extends StatelessWidget {
  const TitleAppBar({
    super.key,
    required this.constraints,
  });

  final BoxConstraints constraints;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          left: constraints.maxWidth > 480
              ? constraints.maxWidth * 0.15
              : constraints.maxWidth * 0.05),
      child: Text("JnNetto",
          style: GoogleFonts.poppins(
            textStyle: TextStyle(
                color: ColorsApp.letters,
                fontWeight: FontWeight.bold,
                fontSize: 40),
          )),
    );
  }
}

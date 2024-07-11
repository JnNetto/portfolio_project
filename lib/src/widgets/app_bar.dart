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
    actions: constraints.maxWidth > 1050 ? list : [drawer],
    title: Padding(
      padding: EdgeInsets.only(left: constraints.maxWidth * 0.15),
      child: Text("JnNetto",
          style: GoogleFonts.poppins(
            textStyle: TextStyle(
                color: ColorsApp.letters,
                fontWeight: FontWeight.bold,
                fontSize: 40),
          )),
    ),
  );
}

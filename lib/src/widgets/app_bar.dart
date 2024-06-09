import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/colors.dart';

PreferredSizeWidget appBarCustom(BoxConstraints constraints) {
  return AppBar(
    toolbarHeight: constraints.maxHeight * .1,
    backgroundColor: ColorsApp.appbar,
    shadowColor: ColorsApp.shadowColor,
    elevation: 40,
    title: Padding(
      padding: EdgeInsets.only(left: constraints.maxWidth * 0.05),
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

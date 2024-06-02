import 'package:flutter/material.dart';
import 'package:portfolio/src/utils/colors.dart';
import 'package:portfolio/src/widgets/app_bar.dart';

import '../widgets/initial_info.dart';

class Home extends StatefulWidget {
  Home({
    super.key,
  });
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          appBar: appBarCustom(constraints),
          body: Container(
            color: ColorsApp.background,
            child: Padding(
              padding: EdgeInsets.only(top: 40),
              child: Column(
                children: [
                  initialInfo(constraints),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

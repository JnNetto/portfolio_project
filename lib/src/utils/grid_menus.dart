import 'package:flutter/material.dart';

class GridMenus extends StatelessWidget {
  final List<Widget> contentLine1;
  final List<Widget> contentLine2;

  const GridMenus(
      {super.key, required this.contentLine1, required this.contentLine2});

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Wrap(children: [...contentLine1]),
          const SizedBox(
            height: 40,
          ),
          Wrap(children: [...contentLine2])
        ]);
  }
}

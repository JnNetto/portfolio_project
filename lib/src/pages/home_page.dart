import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:portfolio/src/utils/colors.dart';
import 'package:portfolio/src/widgets/app_bar.dart';
import 'package:portfolio/src/widgets/initial_info.dart';
import 'package:portfolio/src/controllers/home_controller.dart';

import '../widgets/about_me.dart';
import '../widgets/attributes.dart';
import '../widgets/projects.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final HomeController _controller = HomeController();
  late Future<Map<String, dynamic>> _info;

  @override
  void initState() {
    super.initState();
    _info = _controller.fetchInfo();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
            appBar: appBarCustom(constraints),
            body: connection(_info, constraints));
      },
    );
  }
}

Widget connection(
    Future<Map<String, dynamic>> info, BoxConstraints constraints) {
  return Container(
    color: ColorsApp.background,
    child: FutureBuilder<Map<String, dynamic>>(
      future: info,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}',
              style: GoogleFonts.aBeeZee(
                  textStyle:
                      TextStyle(fontSize: 50, color: ColorsApp.letters)));
        } else if (snapshot.hasData) {
          return Padding(
            padding:
                EdgeInsets.only(top: constraints.maxWidth > 1050 ? 40 : 30),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  initialInfo(constraints, data: snapshot.data!),
                  SizedBox(
                    height: constraints.maxWidth > 1050 ? 40 : 90,
                  ),
                  aboutMe(constraints, data: snapshot.data!),
                  SizedBox(
                    height: constraints.maxWidth > 1050 ? 40 : 100,
                  ),
                  projects(constraints, data: snapshot.data!),
                  SizedBox(
                    height: constraints.maxWidth > 1050 ? 40 : 100,
                  ),
                  Attributes(constraints: constraints, data: snapshot.data!),
                  SizedBox(
                    height: constraints.maxWidth > 1050 ? 40 : 100,
                  ),
                ],
              ),
            ),
          );
        } else {
          return const Text('No data available');
        }
      },
    ),
  );
}

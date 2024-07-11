import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:portfolio/src/utils/colors.dart';
import 'package:portfolio/src/widgets/app_bar.dart';
import 'package:portfolio/src/widgets/initial_info.dart';
import 'package:portfolio/src/controllers/home_controller.dart';

import '../utils/section_scroller.dart';
import '../widgets/about_me.dart';
import '../widgets/attributes.dart';
import '../widgets/contact.dart';
import '../widgets/projects.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final HomeController _controller = HomeController();
  late Future<Map<String, dynamic>> _info;
  final SectionScroller _sectionScroller = SectionScroller();

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
            appBar: appBarCustom(
                constraints,
                _sectionScroller.buildAppBarButtons(constraints),
                _sectionScroller.buildAppBarDrawer(context)),
            body: connection(_info, constraints, _sectionScroller));
      },
    );
  }
}

Widget connection(Future<Map<String, dynamic>> info, BoxConstraints constraints,
    SectionScroller scroller) {
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
                  Container(
                      key: scroller.initialInfoKey,
                      child: initialInfo(constraints, data: snapshot.data!)),
                  SizedBox(height: constraints.maxWidth > 1050 ? 40 : 90),
                  Container(
                      key: scroller.aboutMeKey,
                      child: aboutMe(constraints, data: snapshot.data!)),
                  SizedBox(height: constraints.maxWidth > 1050 ? 40 : 100),
                  Container(
                      key: scroller.projectsKey,
                      child: projects(constraints, data: snapshot.data!)),
                  SizedBox(height: constraints.maxWidth > 1050 ? 100 : 100),
                  Container(
                      key: scroller.attributesKey,
                      child: Attributes(
                          constraints: constraints, data: snapshot.data!)),
                  SizedBox(height: constraints.maxWidth > 1050 ? 150 : 100),
                  Container(
                      key: scroller.contactKey,
                      child:
                          contact(constraints, context, data: snapshot.data!)),
                  SizedBox(height: constraints.maxWidth > 1050 ? 100 : 50),
                  Text(
                      "© 2024 / João Antônio Gomes / Todos os direitos reservados",
                      style: GoogleFonts.aBeeZee(
                          textStyle: TextStyle(
                              fontSize: constraints.maxWidth > 1050 ? 20 : 12,
                              color: ColorsApp.letters))),
                  SizedBox(
                    height: constraints.maxWidth > 1050 ? 25 : 25,
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

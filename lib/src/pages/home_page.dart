import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:portfolio/src/utils/colors.dart';
import 'package:portfolio/src/widgets/app_bar.dart';
import 'package:portfolio/src/widgets/initial_info.dart';
import 'package:portfolio/src/controllers/home_controller.dart';
import 'package:portfolio/src/utils/section_scroller.dart';
import 'package:portfolio/src/widgets/about_me.dart';
import 'package:portfolio/src/widgets/attributes.dart';
import 'package:portfolio/src/widgets/contact.dart';
import 'package:portfolio/src/widgets/projects.dart';

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
            _sectionScroller.buildAppBarDrawer(context),
          ),
          body: BodyContent(
            info: _info,
            constraints: constraints,
            sectionScroller: _sectionScroller,
          ),
        );
      },
    );
  }
}

class BodyContent extends StatelessWidget {
  final Future<Map<String, dynamic>> info;
  final BoxConstraints constraints;
  final SectionScroller sectionScroller;

  const BodyContent({
    super.key,
    required this.info,
    required this.constraints,
    required this.sectionScroller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorsApp.background,
      child: FutureBuilder<Map<String, dynamic>>(
        future: info,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: GoogleFonts.aBeeZee(
                  textStyle: TextStyle(fontSize: 50, color: ColorsApp.letters),
                ),
              ),
            );
          } else if (snapshot.hasData) {
            return ContentSections(
              constraints: constraints,
              data: snapshot.data!,
              sectionScroller: sectionScroller,
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}

class ContentSections extends StatelessWidget {
  final BoxConstraints constraints;
  final Map<String, dynamic> data;
  final SectionScroller sectionScroller;

  const ContentSections({
    super.key,
    required this.constraints,
    required this.data,
    required this.sectionScroller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: constraints.maxWidth > 480 ? 40 : 30),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Section(
              key: sectionScroller.initialInfoKey,
              child: InitialInfo(constraints: constraints, data: data),
            ),
            SizedBox(height: constraints.maxWidth > 480 ? 40 : 90),
            Section(
              key: sectionScroller.aboutMeKey,
              child: AboutMe(constraints: constraints, data: data),
            ),
            SizedBox(height: constraints.maxWidth > 480 ? 40 : 100),
            Section(
              key: sectionScroller.projectsKey,
              child: Projects(constraints: constraints, data: data),
            ),
            SizedBox(height: constraints.maxWidth > 480 ? 100 : 100),
            Section(
              key: sectionScroller.attributesKey,
              child: Attributes(
                constraints: constraints,
                data: data,
                attributeKey: sectionScroller.attributesKey,
              ),
            ),
            SizedBox(height: constraints.maxWidth > 480 ? 150 : 100),
            Section(
              key: sectionScroller.contactKey,
              child: Contact(
                  constraints: constraints, context: context, data: data),
            ),
            SizedBox(height: constraints.maxWidth > 480 ? 100 : 50),
            Footer(constraints: constraints),
          ],
        ),
      ),
    );
  }
}

class Section extends StatelessWidget {
  final Widget child;
  const Section({required Key key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(child: child);
  }
}

class Footer extends StatelessWidget {
  final BoxConstraints constraints;
  const Footer({super.key, required this.constraints});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "© 2024 / João Antônio Gomes / Todos os direitos reservados",
          style: GoogleFonts.aBeeZee(
            textStyle: TextStyle(
              fontSize: constraints.maxWidth > 480 ? 20 : 12,
              color: ColorsApp.letters,
            ),
          ),
        ),
        const SizedBox(height: 25),
      ],
    );
  }
}

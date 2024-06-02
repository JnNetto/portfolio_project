import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:portfolio/src/utils/colors.dart';
import 'package:portfolio/src/widgets/app_bar.dart';
import 'package:portfolio/src/widgets/initial_info.dart';
import 'package:portfolio/src/controllers/home_controller.dart';

class Home extends StatefulWidget {
  Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final HomeController _controller = HomeController();
  late Future<Map<String, dynamic>> _info;

  @override
  void initState() {
    super.initState();
    _info = _controller.fetchInitialInfo();
  }

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
                  FutureBuilder<Map<String, dynamic>>(
                    future: _info,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}',
                            style: GoogleFonts.aBeeZee(
                                textStyle: TextStyle(
                                    fontSize: 50, color: ColorsApp.letters)));
                      } else if (snapshot.hasData) {
                        return initialInfo(constraints, data: snapshot.data!);
                      } else {
                        return const Text('No data available');
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

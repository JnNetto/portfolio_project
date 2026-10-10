import 'package:flutter/material.dart';
import 'package:portfolio/src/controllers/home_controller.dart';
import 'package:portfolio/src/utils/app_fonts.dart';
import 'package:portfolio/src/utils/colors.dart';
import 'package:portfolio/src/utils/section_scroller.dart';
import 'package:portfolio/src/widgets/app_bar.dart';
import 'package:portfolio/src/widgets/attributes.dart';
import 'package:portfolio/src/widgets/contact.dart';
import 'package:portfolio/src/widgets/droplets/site_droplets.dart';
import 'package:portfolio/src/widgets/initial_info.dart';
import 'package:portfolio/src/widgets/laya_command_bar.dart';
import 'package:portfolio/src/widgets/projects.dart';

class Home extends StatefulWidget {
  final VoidCallback toggleTheme;

  const Home({super.key, required this.toggleTheme});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final HomeController _controller = HomeController();
  late Future<Map<String, dynamic>> _info;
  final SectionScroller _sectionScroller = SectionScroller();
  final FocusNode _commandFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _info = _controller.fetchInfo();
  }

  @override
  void dispose() {
    _commandFocus.dispose();
    super.dispose();
  }

  PortfolioActions get _actions => PortfolioActions(
        goHome: () =>
            _sectionScroller.scrollToSection(_sectionScroller.initialInfoKey),
        goAbout: () =>
            _sectionScroller.scrollToSection(_sectionScroller.aboutMeKey),
        goProjects: () =>
            _sectionScroller.scrollToSection(_sectionScroller.projectsKey),
        goSkills: () =>
            _sectionScroller.scrollToSection(_sectionScroller.attributesKey),
        goContact: () =>
            _sectionScroller.scrollToSection(_sectionScroller.contactKey),
        toggleTheme: widget.toggleTheme,
      );

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: commandBarShortcuts(),
      child: Actions(
        actions: {
          OpenCommandBarIntent: CallbackAction<OpenCommandBarIntent>(
            onInvoke: (_) {
              _commandFocus.requestFocus();
              return null;
            },
          ),
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Scaffold(
              backgroundColor: ColorsApp.background(context),
              appBar: appBarCustom(
                  constraints,
                  _sectionScroller.buildAppBarButtons(constraints, context),
                  _sectionScroller.buildAppBarDrawer(context),
                  widget.toggleTheme,
                  context),
              body: Stack(
                children: [
                  SiteDroplets(
                    child: BodyContent(
                      info: _info,
                      constraints: constraints,
                      sectionScroller: _sectionScroller,
                      actions: _actions,
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 20,
                    child: Listener(
                      behavior: HitTestBehavior.deferToChild,
                      child: Center(
                        child: SizedBox(
                          width: (constraints.maxWidth - 32).clamp(0.0, 560.0),
                          child: LayaCommandBar(
                            actions: _actions,
                            focusNode: _commandFocus,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class BodyContent extends StatelessWidget {
  final Future<Map<String, dynamic>> info;
  final BoxConstraints constraints;
  final SectionScroller sectionScroller;
  final PortfolioActions actions;

  const BodyContent({
    super.key,
    required this.info,
    required this.constraints,
    required this.sectionScroller,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    // Fundo transparente: a cor vem do Scaffold e as gotas de trás
    // (SiteDroplets) aparecem entre o fundo e o conteúdo.
    return SizedBox.expand(
      child: FutureBuilder<Map<String, dynamic>>(
        future: info,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child:
                  CircularProgressIndicator(color: ColorsApp.accent(context)),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: AppFonts.aBeeZee(
                  textStyle: TextStyle(
                      fontSize: 24, color: ColorsApp.letters(context)),
                ),
              ),
            );
          } else if (snapshot.hasData) {
            return ContentSections(
              constraints: constraints,
              data: snapshot.data!,
              sectionScroller: sectionScroller,
              actions: actions,
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
  final PortfolioActions actions;

  const ContentSections({
    super.key,
    required this.constraints,
    required this.data,
    required this.sectionScroller,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: constraints.maxWidth > 480 ? 16 : 8),
      child: SingleChildScrollView(
        // Espaço no fim da rolagem para o footer não ficar sob a barra da Laya.
        padding: const EdgeInsets.only(bottom: 140),
        child: Column(
          children: [
            RepaintBoundary(
                child: KeyedSubtree(
              key: sectionScroller.initialInfoKey,
              child: InitialInfo(
                constraints: constraints,
                data: data,
                onViewProjects: actions.goProjects,
                onContact: actions.goContact,
                aboutKey: sectionScroller.aboutMeKey,
              ),
            )),
            SizedBox(height: constraints.maxWidth > 480 ? 40 : 80),
            RepaintBoundary(
                child: KeyedSubtree(
              key: sectionScroller.projectsKey,
              child: Projects(constraints: constraints, data: data),
            )),
            SizedBox(height: constraints.maxWidth > 480 ? 80 : 80),
            RepaintBoundary(
                child: KeyedSubtree(
              key: sectionScroller.attributesKey,
              child: Attributes(
                constraints: constraints,
                data: data,
                attributeKey: sectionScroller.attributesKey,
              ),
            )),
            SizedBox(height: constraints.maxWidth > 480 ? 120 : 80),
            RepaintBoundary(
                child: KeyedSubtree(
              key: sectionScroller.contactKey,
              child: Contact(constraints: constraints, data: data),
            )),
            SizedBox(height: constraints.maxWidth > 480 ? 80 : 40),
            Footer(constraints: constraints),
          ],
        ),
      ),
    );
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
          '© 2026 / João Antônio Gomes / Todos os direitos reservados',
          style: AppFonts.aBeeZee(
            textStyle: TextStyle(
              fontSize: constraints.maxWidth > 480 ? 16 : 12,
              color: ColorsApp.muted(context),
            ),
          ),
        ),
        const SizedBox(height: 25),
      ],
    );
  }
}

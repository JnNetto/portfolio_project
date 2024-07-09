import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/colors.dart';

Widget contact(BoxConstraints constraints, BuildContext context,
    {required Map<String, dynamic> data}) {
  if (constraints.maxWidth > 1050) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: constraints.maxWidth > 1050 ? 200 : 56),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("|| Contato ||",
              style: GoogleFonts.aBeeZee(
                  textStyle: TextStyle(
                      fontSize: constraints.maxWidth > 1050 ? 50 : 40,
                      color: ColorsApp.letters))),
          SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              EmailForm(
                constraints: constraints,
              ),
              SizedBox(width: 30),
              email(constraints)
            ],
          )
        ],
      ),
    );
  } else {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: constraints.maxWidth > 1050 ? 50 : 56),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("|| Contato ||",
              style: GoogleFonts.aBeeZee(
                  textStyle: TextStyle(
                      fontSize: constraints.maxWidth > 1050 ? 50 : 40,
                      color: ColorsApp.letters))),
          SizedBox(height: 32),
          EmailForm(
            constraints: constraints,
          ),
          SizedBox(height: 25),
          email(constraints)
        ],
      ),
    );
  }
}

Widget email(BoxConstraints constraints) {
  return Column(
    children: [
      Text(
        "Email para contato:",
        style: GoogleFonts.aBeeZee(
            textStyle: TextStyle(
                fontSize: constraints.maxWidth > 1050 ? 30 : 20,
                color: ColorsApp.letters)),
      ),
      Text(
        "jagomes694@gmail.com",
        style: GoogleFonts.aBeeZee(
            textStyle: TextStyle(
                fontSize: constraints.maxWidth > 1050 ? 18 : 14,
                color: ColorsApp.letters)),
      ),
      Text(
        "Adicione nas redes",
        style: GoogleFonts.aBeeZee(
            textStyle: TextStyle(
                fontSize: constraints.maxWidth > 1050 ? 18 : 14,
                color: ColorsApp.letters)),
      )
    ],
  );
}

class EmailForm extends StatefulWidget {
  final BoxConstraints constraints;

  const EmailForm({super.key, required this.constraints});

  @override
  // ignore: library_private_types_in_public_api
  _EmailFormState createState() => _EmailFormState();
}

class _EmailFormState extends State<EmailForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _senderEmailController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      hintStyle: TextStyle(color: ColorsApp.letters),
      labelText: label,
      labelStyle: TextStyle(
          color: ColorsApp.letters,
          fontSize: widget.constraints.maxWidth > 1050 ? 16 : 11),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: ColorsApp.color4, width: 2.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: ColorsApp.color4, width: 2.0),
      ),
    );
  }

  Future<void> _sendMessage() async {
    if (_formKey.currentState!.validate()) {
      final String subject = _subjectController.text;
      final String emailText = _emailTextController.text;
      final String name = _nameController.text;

      final String mailtoUrl =
          'mailto:jagomes694@gmail.com?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent('$emailText\n\nFrom: $name')}';

      // ignore: deprecated_member_use
      if (await canLaunch(mailtoUrl)) {
        await launchUrl(Uri.parse(mailtoUrl));
      } else {
        showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Erro ao enviar email"),
            content: const Text("Não foi possível abrir o cliente de email."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          SizedBox(
            height: widget.constraints.maxWidth > 1050 ? 35 : 25,
            width: widget.constraints.maxWidth > 1050 ? 600 : 300,
            child: TextFormField(
              style: TextStyle(color: ColorsApp.letters),
              controller: _senderEmailController,
              decoration: _inputDecoration("Email do remetente"),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira o email do remetente';
                }
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                  return 'Por favor, insira um email válido';
                }
                return null;
              },
            ),
          ),
          SizedBox(height: 16),
          SizedBox(
            height: widget.constraints.maxWidth > 1050 ? 35 : 25,
            width: widget.constraints.maxWidth > 1050 ? 600 : 300,
            child: TextFormField(
              style: TextStyle(color: ColorsApp.letters),
              controller: _subjectController,
              decoration: _inputDecoration("Assunto"),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira o assunto';
                }
                return null;
              },
            ),
          ),
          SizedBox(height: 16),
          SizedBox(
            width: widget.constraints.maxWidth > 1050 ? 600 : 300,
            child: TextFormField(
              style: TextStyle(color: ColorsApp.letters),
              controller: _emailTextController,
              decoration: _inputDecoration("Texto do email"),
              maxLines: 6,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira o texto do email';
                }
                return null;
              },
            ),
          ),
          SizedBox(height: 16),
          SizedBox(
            height: widget.constraints.maxWidth > 1050 ? 35 : 25,
            width: widget.constraints.maxWidth > 1050 ? 600 : 300,
            child: TextFormField(
              style: TextStyle(color: ColorsApp.letters),
              controller: _nameController,
              decoration: _inputDecoration("Nome"),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira o seu nome';
                }
                return null;
              },
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            style: ButtonStyle(
              fixedSize: MaterialStateProperty.all<Size>(Size(
                  widget.constraints.maxWidth > 1050 ? 600 : 300,
                  widget.constraints.maxWidth > 1050 ? 35 : 18)),
              backgroundColor:
                  MaterialStateProperty.all<Color>(Colors.transparent),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0.0),
                  side: BorderSide(color: ColorsApp.color4, width: 2.0),
                ),
              ),
              elevation: MaterialStateProperty.all<double>(0),
            ),
            onPressed: _sendMessage,
            child: Text(
              'Enviar mensagem',
              style: TextStyle(color: ColorsApp.letters),
            ),
          ),
        ],
      ),
    );
  }
}

        //     if (value == null || value.isEmpty) {
        //       return 'Por favor, insira o assunto';
        //     }

        //     if (value == null || value.isEmpty) {
        //       return 'Por favor, insira o seu nome';
        //     }

        //     if (value == null || value.isEmpty) {
        //       return 'Por favor, insira o texto do email';
        //     }

              // if (value == null || value.isEmpty) {
              //   return 'Por favor, insira o email do remetente';
              // }
              // if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
              //   return 'Por favor, insira um email válido';
              // }
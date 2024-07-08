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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("|| Contato ||",
            style: GoogleFonts.aBeeZee(
                textStyle: TextStyle(
                    fontSize: constraints.maxWidth > 1050 ? 50 : 40,
                    color: ColorsApp.letters))),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            EmailForm(),
            Container(
              color: Colors.blue,
            )
          ],
        )
      ],
    );
  } else {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("|| Contato ||",
            style: GoogleFonts.aBeeZee(
                textStyle: TextStyle(
                    fontSize: constraints.maxWidth > 1050 ? 50 : 40,
                    color: ColorsApp.letters))),
        EmailForm(),
        Container(
          color: Colors.blue,
        )
      ],
    );
  }
}

class EmailForm extends StatefulWidget {
  @override
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
      labelStyle: TextStyle(color: ColorsApp.letters),
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
      final String senderEmail = _senderEmailController.text;
      final String subject = _subjectController.text;
      final String emailText = _emailTextController.text;
      final String name = _nameController.text;

      final String mailtoUrl =
          'mailto:jagomes694@gmail.com?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent('$emailText\n\nFrom: $name')}';

      if (await canLaunch(mailtoUrl)) {
        await launchUrl(Uri.parse(mailtoUrl));
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Erro ao enviar email"),
            content: Text("Não foi possível abrir o cliente de email."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
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
            width: 300,
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
            width: 300,
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
            width: 300,
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
            width: 300,
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
              style: TextStyle(color: ColorsApp.color4),
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
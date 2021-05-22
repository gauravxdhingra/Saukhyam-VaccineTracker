import 'package:flutter/material.dart';

class AlertSetConfirmationPage extends StatefulWidget {
  const AlertSetConfirmationPage({Key? key}) : super(key: key);
  static const routeName = "alert_set_confirmation_page";

  @override
  _AlertSetConfirmationPageState createState() =>
      _AlertSetConfirmationPageState();
}

class _AlertSetConfirmationPageState extends State<AlertSetConfirmationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: [Text("We'll Notify You Once Vaccines Are Available!")],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:bq_version/Custom Widgets/NavBar.dart';

class Completed extends StatelessWidget {
  static const Color _themePrimary = Color(0xFFDC143C); // theme primary

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: _themePrimary,
          automaticallyImplyLeading: false,
          elevation: 0,
        ),
        body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(child: Container()),
              NavBar(),
            ]));
  }
}

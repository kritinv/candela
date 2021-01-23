import 'package:flutter/material.dart';
import 'package:bq_version/Custom Widgets/NavBar.dart';

class NotificationsScreen extends StatelessWidget {
  static const Color _themePrimary = Color(0xFFDC143C); // theme primary
  final body = NotificationsBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: _themePrimary,
          elevation: 0,
        ),
        body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(child: body),
              NavBar(),
            ]));
  }
}

class NotificationsBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        ListTile(
          title: Container(
            height: 100,
            child: Row(children: <Widget>[
              SizedBox(width: 5),
              Icon(
                Icons.star,
                color: Colors.yellow,
                size: 80,
              ),
              SizedBox(width: 20),
              Text("5 Users left ratings on your profile")
            ]),
          ),
        ),
        ListTile(
          title: Container(
            height: 100,
            child: Row(children: <Widget>[
              SizedBox(width: 5),
              Icon(
                Icons.person_add_alt_1_sharp,
                color: Colors.blue,
                size: 80,
              ),
              SizedBox(width: 20),
              Text("5 Users left ratings on your profile")
            ]),
          ),
        ),
        ListTile(
          leading: Icon(Icons.person_add),
          title: Text("5 Users left ratings on your profile"),
        ),
        ListTile(
          leading: Icon(Icons.person_add),
          title: Text("5 Users left ratings on your profile"),
        ),
        ListTile(
          leading: Icon(Icons.person_add),
          title: Text("5 Users left ratings on your profile"),
        )
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'Custom Widgets/NavBar.dart';
import 'Custom Widgets/RatingBar.dart';
import 'package:overlay_screen/overlay_screen.dart';

class ProfilePage extends StatefulWidget {
  final String imageURL;
  final String firstName;
  final String lastName;
  final String headline;
  final RatingBar ratingBar;
  final double rating;
  final Color color;

  ProfilePage(
      {@required this.imageURL,
      @required this.firstName,
      @required this.lastName,
      @required this.headline,
      @required this.ratingBar,
      @required this.rating,
      @required this.color});

  static const Color _themePrimary = Color(0xFFDC143C);
  static const Color _themeLight = Colors.white;
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    OverlayScreen().saveScreens({
      'TimeSlots': CustomOverlayScreen(
        backgroundColor: Colors.transparent,
        content: Dialog(
          child: Container(
            width: width * 3 / 2,
            height: height * 3 / 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FlatButton(
                  child: Text("Confirm Meeting"),
                  onPressed: () {
                    OverlayScreen().pop();
                  },
                )
              ],
            ),
          ),
        ),
      ),
    });

    // profile page content part
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ProfilePage._themePrimary,
        elevation: 0,
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.center, children: <
          Widget>[
        Expanded(
          child: Container(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                SizedBox(height: 40),
                CircleAvatar(
                  backgroundImage: NetworkImage(widget.imageURL),
                  radius: 80,
                ),
                SizedBox(height: 15),
                Text("@username", style: TextStyle(color: Colors.grey[700])),
                SizedBox(height: 15),
                Text(widget.firstName + " " + widget.lastName,
                    style: TextStyle(fontSize: 25)),
                SizedBox(height: 10),
                Text(widget.headline,
                    style: TextStyle(fontSize: 15, color: Colors.grey[700])),
                SizedBox(height: 15),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 50),
                  child: Text(
                      "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis lacinia volutpat urna, non aliquam mi dictum vel. Vestibulum pretium id lacus at lobortis.",
                      style: TextStyle(fontSize: 15),
                      textAlign: TextAlign.left),
                ),
                SizedBox(height: 15),
                Divider(thickness: 2, color: Colors.red[300]),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Rating:",
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(width: 5),
                    widget.ratingBar,
                    SizedBox(width: 5),
                    CircleAvatar(
                      backgroundColor: widget.color,
                      radius: 30,
                      child: CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.white,
                          child: Text(widget.rating.toString(),
                              style: TextStyle(color: Colors.black))),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                FlatButton(
                  onPressed: () {
                    OverlayScreen().show(
                      context,
                      identifier: "TimeSlots",
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 40,
                    margin: EdgeInsets.symmetric(horizontal: 50),
                    child: Center(
                      child: Text(
                        "Meetings (21)",
                        style: TextStyle(color: ProfilePage._themeLight),
                      ),
                    ),
                    color: ProfilePage._themePrimary,
                  ),
                ),
              ])),
        ),
        NavBar(),
      ]),
    );
  }
}

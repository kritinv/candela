import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Custom Widgets/NavBar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'HomeMeeting.dart';
import 'Favorite.dart';

////////////////////////////////////////////////////////////////////////////////
// HOME PAGE

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color _themePrimary = Color(0xFFDC143C);
  double height;
  double width;
  Widget body = HomeMeeting();
  String status;

  Future<String> getStatus() async {
    await FirebaseFirestore.instance
        .collection("user")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        print(documentSnapshot.data()["status"]);
        status = documentSnapshot.data()["status"];
      }
    });
    return "done";
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return FutureBuilder<String>(
      future: getStatus(),
      builder: (BuildContext context, AsyncSnapshot<String> status) {
        if (status.hasError) {
          print(status.hasError);
          return Center(child: Text('No Upcoming Meetings'));
        }

        if (status.connectionState == ConnectionState.waiting) {
          print(status.connectionState);
          return Container();
        }
        return DefaultTabController(
          length: 3,
          child: Scaffold(
              appBar: AppBar(
                backgroundColor: _themePrimary,
                automaticallyImplyLeading: false,
                elevation: 0,
                bottom: TabBar(
                  indicatorColor: Colors.transparent,
                  tabs: [
                    Tab(text: 'Mentor'),
                    Tab(text: 'Mentee'),
                    Tab(text: "Favorite"),
                  ],
                ),
              ),
              body: Column(
                children: [
                  Expanded(
                    child: TabBarView(
                      children: [
                        HomeMeeting(height: height, width: width),
                        (this.status == 'normal')
                            ? Center(
                                child: Text("you are not a consultant"),
                              )
                            : HomeMeeting(height: height, width: width),
                        HomeFavorite(),
                      ],
                    ),
                  ),
                  NavBar(),
                ],
              )),
        );
      },
    );
  }
}

////////////////////////////////////////////////////////////////////////////////
// CUSTOM WIDGET LOADING FOR SEARCH SCREEN

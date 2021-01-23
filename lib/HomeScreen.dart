import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Custom Widgets/NavBar.dart';
import 'Custom Widgets/RatingBar.dart';
import 'SearchScreen.dart';
import 'main.dart';
import 'package:bq_version/main.dart';

////////////////////////////////////////////////////////////////////////////////
// HOME PAGE

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color _themePrimary = Color(0xFFDC143C);
  static const Color _themeLight = Colors.white; // theme primary
// theme primary
  Widget body = HomeMeeting();
  bool searchBarPresent = false;
  Color meetingColor = _themeLight;
  Color meetingTextColor = _themePrimary;
  Color favoriteColor = _themePrimary;
  Color favoriteTextColor = _themeLight;

  toggleMeeting() {
    if (body is! HomeMeeting) {
      print('what');
      setState(() {
        body = HomeMeeting();
        meetingColor = _themeLight;
        meetingTextColor = _themePrimary;
        favoriteColor = _themePrimary;
        favoriteTextColor = _themeLight;
      });
    }
  }

  toggleFavorite() {
    if (body is! HomeFavorite) {
      setState(() {
        body = HomeFavorite();
        meetingColor = _themePrimary;
        meetingTextColor = _themeLight;
        favoriteColor = _themeLight;
        favoriteTextColor = _themePrimary;
      });
    }
  }

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
            Container(
                height: 50,
                width: double.infinity,
                color: _themePrimary,
                child: Row(children: <Widget>[
                  SizedBox(width: 20),
                  GestureDetector(
                    onTap: toggleMeeting,
                    child: Container(
                      height: 25,
                      width: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: meetingColor,
                      ),
                      child: Center(
                        child: Text(
                          'Meetings',
                          style: TextStyle(color: meetingTextColor),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  GestureDetector(
                    onTap: toggleFavorite,
                    child: Container(
                      height: 25,
                      width: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: favoriteColor,
                      ),
                      child: Center(
                        child: Text(
                          'Favorites',
                          style: TextStyle(color: favoriteTextColor),
                        ),
                      ),
                    ),
                  ),
                ])),
            Expanded(child: body),
            NavBar(),
          ]),
    );
  }
}

////////////////////////////////////////////////////////////////////////////////
// Home Meeting Body

class HomeMeeting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    return StreamBuilder<QuerySnapshot>(
      stream: users.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          print(snapshot.hasError);
          return Container();
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          print(snapshot.connectionState);
          return Container();
        }

        return ListView(
          children: snapshot.data.docs.map((DocumentSnapshot document) {
            return MentorExpandableCard(
              firstName: document.data()['first_name'],
              lastName: document.data()['last_name'],
              rating: double.parse(document.data()['rating']),
              headline: document.data()['headline'],
              imageURL: document.data()['image_url'],
            );
          }).toList(),
        );
      },
    );
  }
}

////////////////////////////////////////////////////////////////////////////////
// FAVORITES BODY

class HomeFavorite extends StatefulWidget {
  @override
  _HomeFavoriteState createState() => _HomeFavoriteState();
}

class _HomeFavoriteState extends State<HomeFavorite> {
  Future<List> downloadMentorData() async {
    List favorites;
    List<Widget> favoriteCardList = [];
    await FirebaseFirestore.instance
        .collection('user')
        .doc(currentUser)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        favorites = documentSnapshot.data()["favorite"];
      }
    });
    print(favorites);
    await FirebaseFirestore.instance
        .collection('users')
        .where("id", whereIn: favorites)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        print(doc.data());
        favoriteCardList.add(
          FavoriteCard(
            firstName: doc["first_name"],
            lastName: doc["last_name"],
            imageURL: doc['image_url'],
            rating: double.parse(doc['rating']),
            headline: doc['headline'],
            id: doc['id'],
            refreshCallBack: refresh,
          ),
        );
      });
    });
    print(favoriteCardList);
    return favoriteCardList;
  }

  void refresh() {
    // reload
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List>(
      future: downloadMentorData(),
      builder: (BuildContext context, AsyncSnapshot<List> list) {
        if (list.hasError) {
          return Center(child: Text("No favorites"));
        }

        if (list.connectionState == ConnectionState.done) {
          return ListView(children: list.data);
        }
        print("loading");
        return Container();
      },
    );
  }
}

////////////////////////////////////////////////////////////////////////////////
// HOME SCREEN APPOINTMENT CARD

class MentorExpandableCard extends StatefulWidget {
  final String imageURL;
  final String firstName;
  final String lastName;
  final double rating;
  final String headline;
  const MentorExpandableCard(
      {this.imageURL,
      this.firstName,
      this.lastName,
      this.rating,
      this.headline});

  @override
  _MentorExpandableCardState createState() => _MentorExpandableCardState();
}

class _MentorExpandableCardState extends State<MentorExpandableCard> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    Color color;
    if (widget.rating <= 1) {
      color = Colors.red[200];
    } else if (widget.rating <= 2) {
      color = Colors.orange[200];
    } else if (widget.rating <= 3) {
      color = Colors.yellow[200];
    } else if (widget.rating <= 4) {
      color = Colors.green[200];
    } else {
      color = Colors.purple[200];
    }

    return ExpansionPanelList(
      elevation: 0, // 1st add this line
      expansionCallback: (int index, bool isExpanded) {
        if (isExpanded == true) {
          setState(() {
            expanded = false;
          });
        } else {
          setState(() {
            expanded = true;
          });
        }
      },
      children: [
        ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              title: Container(
                  margin: EdgeInsets.symmetric(vertical: 20),
                  height: 100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      CircleAvatar(
                          backgroundImage: NetworkImage(widget.imageURL),
                          radius: 40),
                      SizedBox(width: 20),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            widget.firstName + " " + widget.lastName,
                            style:
                                TextStyle(fontSize: 20, fontFamily: "OpenSans"),
                          ),
                          SizedBox(height: 10),
                          RatingBar(rating: widget.rating, color: color),
                          SizedBox(height: 10),
                          Text(widget.headline,
                              style: TextStyle(
                                  fontSize: 12, fontFamily: "OpenSans"))
                        ],
                      ),
                    ],
                  )),
            );
          },
          body: ListTile(
            title: Text('Item 2 child'),
            subtitle: Text('Details goes here'),
          ),
          isExpanded: expanded,
        ),
      ],
    );
  }
}

////////////////////////////////////////////////////////////////////////////////
// FAVORITE CARD FOR SEARCH SCREEN

class FavoriteCard extends StatefulWidget {
  final String imageURL;
  final String firstName;
  final String lastName;
  final double rating;
  final String headline;
  final String id;
  final Function refreshCallBack;
  const FavoriteCard(
      {this.imageURL,
      this.firstName,
      this.lastName,
      this.rating,
      this.headline,
      this.id,
      this.refreshCallBack});

  @override
  _FavoriteCardState createState() => _FavoriteCardState();
}

class _FavoriteCardState extends State<FavoriteCard> {
  Icon starBorder = Icon(Icons.star_border, color: Colors.grey[300]);
  Icon starNoBorder = Icon(Icons.star, color: Colors.yellow[300]);
  Icon icon;

  @override
  initState() {
    icon = starNoBorder;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Color color;
    if (widget.rating <= 1) {
      color = Colors.red[200];
    } else if (widget.rating <= 2) {
      color = Colors.orange[200];
    } else if (widget.rating <= 3) {
      color = Colors.yellow[200];
    } else if (widget.rating <= 4) {
      color = Colors.green[200];
    } else {
      color = Colors.purple[200];
    }

    return ListTile(
      onTap: () {},
      title: Container(
          margin: EdgeInsets.symmetric(vertical: 20),
          height: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              CircleAvatar(
                  backgroundImage: NetworkImage(widget.imageURL), radius: 40),
              SizedBox(width: 20),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.firstName + " " + widget.lastName,
                    style: TextStyle(fontSize: 20, fontFamily: "OpenSans"),
                  ),
                  SizedBox(height: 10),
                  RatingBar(rating: widget.rating, color: color),
                  SizedBox(height: 10),
                  Text(widget.headline,
                      style: TextStyle(fontSize: 12, fontFamily: "OpenSans"))
                ],
              ),
              SizedBox(width: 10),
              GestureDetector(
                  child: icon,
                  onTap: () async {
                    if (icon == starNoBorder) {
                      await FirebaseFirestore.instance
                          .collection('user')
                          .doc(currentUser)
                          .update({
                        "favorite": FieldValue.arrayRemove([widget.id])
                      });
                      setState(() {
                        icon = starBorder;
                      });
                      widget.refreshCallBack();
                    } else {
                      print(currentUser);
                      await FirebaseFirestore.instance
                          .collection('user')
                          .doc(currentUser)
                          .update({
                        "favorite": FieldValue.arrayUnion([widget.id])
                      });
                      setState(() {
                        icon = starNoBorder;
                      });
                      widget.refreshCallBack();
                    }
                  }),
            ],
          )),
    );
  }
}

////////////////////////////////////////////////////////////////////////////////
// CUSTOM WIDGET LOADING FOR SEARCH SCREEN

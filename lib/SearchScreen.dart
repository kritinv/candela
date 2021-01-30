import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Custom Widgets/NavBar.dart';
import 'Custom Widgets/RatingBar.dart';
import 'package:bq_version/ProfilePage.dart';
import 'package:firebase_auth/firebase_auth.dart';

////////////////////////////////////////////////////////////////////////////////

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String currentUser = FirebaseAuth.instance.currentUser.uid;

  Future<List> downloadStarred() async {
    List favorites = [];
    await FirebaseFirestore.instance
        .collection('user')
        .doc(currentUser)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        favorites = documentSnapshot.data()["favorite"];
      }
    });
    return favorites;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List>(
      future: downloadStarred(), // a previously-obtained Future<String> or null
      builder: (BuildContext context, AsyncSnapshot<List> list) {
        if (list.hasData) {
          return SearchMain(favorites: list.data);
        } else if (list.hasError) {
          return Center(
            child: Text("Error"),
          );
        }
        print("loading");
        return Container();
      },
    );
  }
}

////////////////////////////////////////////////////////////////////////////////
// SEARCH SCREEN

class SearchMain extends StatefulWidget {
  final List favorites;
  SearchMain({this.favorites});

  @override
  _SearchMainState createState() => _SearchMainState();
}

class _SearchMainState extends State<SearchMain> {
  static const Color _themePrimary = Color(0xFFDC143C); // theme primary
  TextEditingController searchEntry = TextEditingController();
  bool searchBarPresent = false;
  String searchText = "";
  String category = "All";
  SearchBody body;

  @override
  void initState() {
    body = SearchBody(
      starredList: widget.favorites,
      searchText: searchText,
      updateStarred: callbackFavorites,
      category: category,
    );
    super.initState();
  }

  void callbackCategory(category) {
    setState(() {
      this.category = category;
    });
  }

  void callbackFavorites({how, value}) {
    setState(() {
      if (how == "add") {
        widget.favorites.add(value);
      } else if (how == 'remove') {
        widget.favorites.remove(value);
      }
    });
  }

  void updateSearch(newValue) {
    print(newValue);
    print(category);
    setState(() {
      body = SearchBody(
        starredList: widget.favorites,
        searchText: newValue,
        updateStarred: callbackFavorites,
        category: category,
      );
    });
  }

  void updateCategory(category) {
    print(category);
    setState(() {
      body = SearchBody(
        starredList: widget.favorites,
        searchText: searchText,
        updateStarred: callbackFavorites,
        category: category,
      );
    });
    Navigator.pop(context);
  }

  void toggleSearch() {
    if (searchBarPresent == false) {
      setState(() {
        searchBarPresent = true;
      });
      print("search bar is now present");
    } else {
      setState(() {
        searchBarPresent = false;
      });
      print("search bar is now hidden");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _themePrimary,
        elevation: 0,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.search,
              size: 30,
              color: Colors.white,
            ),
            onPressed: toggleSearch,
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.symmetric(vertical: 0),
          children: <Widget>[
            Container(
              height: 150,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: _themePrimary,
                ),
                child: Container(
                  margin: EdgeInsets.only(left: 8, bottom: 3),
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    'TOPICS',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        letterSpacing: 3),
                  ),
                ),
              ),
            ),
            DrawerItem(
              category: "All",
              updateCat: updateCategory,
              callbackCat: callbackCategory,
            ),
            DrawerItem(
              category: "Resume",
              updateCat: updateCategory,
              callbackCat: callbackCategory,
            ),
            DrawerItem(
              category: "Interview",
              updateCat: updateCategory,
              callbackCat: callbackCategory,
            ),
            DrawerItem(
              category: "Essay",
              updateCat: updateCategory,
              callbackCat: callbackCategory,
            ),
            DrawerItem(
              category: "Extracurriculars",
              updateCat: updateCategory,
              callbackCat: callbackCategory,
            ),
            DrawerItem(
              category: "Community Service",
              updateCat: updateCategory,
              callbackCat: callbackCategory,
            ),
            DrawerItem(
              category: "Research",
              updateCat: updateCategory,
              callbackCat: callbackCategory,
            ),
            DrawerItem(
              category: "General Advice",
              updateCat: updateCategory,
              callbackCat: callbackCategory,
            ),
          ],
        ),
      ),
      body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            (searchBarPresent)
                ? Column(children: [
                    SizedBox(height: 20),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      child: Theme(
                        data: new ThemeData(
                          primaryColor: Colors.grey,
                          primaryColorDark: Colors.grey,
                        ),
                        child: TextField(
                          onChanged: (newValue) {
                            updateSearch(newValue);
                          },
                          controller: searchEntry,
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                            hintText: 'Search...',
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Colors.grey,
                            ),
                            enabledBorder: new OutlineInputBorder(
                              borderSide: new BorderSide(
                                color: Colors.grey[300],
                                width: 3,
                              ),
                            ),
                            focusedBorder: new OutlineInputBorder(
                              borderSide: new BorderSide(
                                color: Colors.grey[300],
                                width: 3,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ])
                : Container(height: 0, width: 0),
            Expanded(child: body),
            NavBar(),
          ]),
    );
  }
}

////////////////////////////////////////////////////////////////////////////////
// SEARCH BODY FOR SEARCH SCREEN

class SearchBody extends StatelessWidget {
  final String searchText;
  final List starredList;
  final Function updateStarred;
  final String category;
  SearchBody(
      {this.starredList, this.searchText, this.updateStarred, this.category});

  @override
  Widget build(BuildContext context) {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    return StreamBuilder<QuerySnapshot>(
        stream: users.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Container();
          }

          if (snapshot.connectionState == ConnectionState.waiting) {}

          if (snapshot.connectionState == ConnectionState.active) {
            List<MentorCard> cardList = [];

            snapshot.data.docs.forEach((DocumentSnapshot document) {
              // determining search
              bool starred;
              if (starredList.contains(document.id)) {
                starred = true;
              } else {
                starred = false;
              }

              // filtering based on category
              List specialty = document.data()['specialty'];
              if (category != 'All') {
                if (specialty.contains(category)) {
                  // filtering based on search bar
                  String firstName = document.data()['first_name'];
                  String lastName = document.data()['last_name'];
                  if ((firstName + lastName).contains(searchText)) {
                    print(firstName + lastName);
                    cardList.add(
                      MentorCard(
                        firstName: firstName,
                        lastName: lastName,
                        rating: double.parse(document.data()['rating']),
                        headline: document.data()['headline'],
                        imageURL: document.data()['image_url'],
                        id: document.id,
                        starred: starred,
                        updateStarred: updateStarred,
                      ),
                    );
                  }
                }
              } else {
                String firstName = document.data()['first_name'];
                String lastName = document.data()['last_name'];
                if ((firstName + lastName).contains(searchText)) {
                  print(firstName + lastName);
                  cardList.add(
                    MentorCard(
                      firstName: firstName,
                      lastName: lastName,
                      rating: double.parse(document.data()['rating']),
                      headline: document.data()['headline'],
                      imageURL: document.data()['image_url'],
                      id: document.id,
                      starred: starred,
                      updateStarred: updateStarred,
                      bio: document.data()['bio'],
                    ),
                  );
                }
              }
            });
            return ListView(children: cardList);
          }
          return Container();
        });
  }
}

////////////////////////////////////////////////////////////////////////////////
// MENTOR CARD FOR SEARCH SCREEN

class MentorCard extends StatefulWidget {
  final String imageURL;
  final String firstName;
  final String lastName;
  final double rating;
  final String headline;
  final String id;
  final bool starred;
  final Function updateStarred;
  final String bio;
  const MentorCard(
      {this.imageURL,
      this.firstName,
      this.lastName,
      this.rating,
      this.headline,
      this.id,
      this.starred,
      this.updateStarred,
      this.bio});

  @override
  _MentorCardState createState() => _MentorCardState();
}

class _MentorCardState extends State<MentorCard> {
  String currentUser = FirebaseAuth.instance.currentUser.uid;

  Icon starBorder = Icon(Icons.star_border, color: Colors.grey[300]);
  Icon starNoBorder = Icon(Icons.star, color: Colors.yellow[300]);
  Icon icon;

  @override
  initState() {
    if (widget.starred) {
      icon = starNoBorder;
    } else {
      icon = starBorder;
    }
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
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilePage(
              id: widget.id,
              imageURL: widget.imageURL,
              firstName: widget.firstName,
              lastName: widget.lastName,
              headline: widget.headline,
              ratingBar: RatingBar(rating: widget.rating, color: color),
              rating: widget.rating,
              color: color,
              bio: widget.bio,
            ),
          ),
        );
      },
      title: Container(
          margin: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          height: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              CircleAvatar(
                  backgroundImage: NetworkImage(widget.imageURL), radius: 40),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      widget.firstName + " " + widget.lastName,
                      style: TextStyle(fontSize: 20, fontFamily: "OpenSans"),
                      textAlign: TextAlign.center,
                    ),
                    RatingBar(rating: widget.rating, color: color),
                    Text(
                      widget.headline,
                      style: TextStyle(fontSize: 12, fontFamily: "OpenSans"),
                      textAlign: TextAlign.center,
                    )
                  ],
                ),
              ),
              SizedBox(width: 10),
              GestureDetector(
                  child: icon,
                  onTap: () async {
                    print(currentUser);
                    if (icon == starNoBorder) {
                      await FirebaseFirestore.instance
                          .collection('user')
                          .doc(currentUser)
                          .update({
                        "favorite": FieldValue.arrayRemove([widget.id])
                      });
                      setState(() {
                        icon = starBorder;
                        widget.updateStarred(how: "remove", value: widget.id);
                      });
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
                        widget.updateStarred(how: "add", value: widget.id);
                      });
                    }
                  }),
            ],
          )),
    );
  }
}

////////////////////////////////////////////////////////////////////////////////
// CUSTOM WIDGET LOADING FOR SEARCH SCREEN

class LoadingSearch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 20),
        height: 100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(backgroundColor: Colors.redAccent, radius: 40),
            SizedBox(width: 20),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 20,
                  width: 150,
                  decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(10)),
                ),
                SizedBox(height: 10),
                RatingBar(rating: 0, color: null),
                SizedBox(height: 10),
                Container(
                  height: 8,
                  width: 150,
                  decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(10)),
                ),
              ],
            ),
            SizedBox(width: 10),
            Icon(Icons.star, color: Colors.grey[300]),
          ],
        ));
  }
}

////////////////////////////////////////////////////////////////////////////////
// CUSTOM WIDGET DRAWER ITEM

class DrawerItem extends StatelessWidget {
  final String category;
  final Function updateCat;
  final Function callbackCat;
  DrawerItem({this.category, this.updateCat, this.callbackCat});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.only(bottom: 10, top: 10, left: 30),
      title: Row(children: [
        CircleAvatar(backgroundColor: Color(0xFFDC143C), radius: 5),
        SizedBox(width: 10),
        Text(
          category,
          style: TextStyle(
            fontSize: 16,
          ),
        ),
      ]),
      onTap: () {
        callbackCat(category);
        updateCat(category);
      },
    );
  }
}

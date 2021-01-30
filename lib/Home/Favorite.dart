import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Custom Widgets/RatingBar.dart';
import 'package:bq_version/ProfilePage.dart';

////////////////////////////////////////////////////////////////////////////////
// FAVORITES BODY

class HomeFavorite extends StatefulWidget {
  @override
  _HomeFavoriteState createState() => _HomeFavoriteState();
}

class _HomeFavoriteState extends State<HomeFavorite> {
  String currentUser = FirebaseAuth.instance.currentUser.uid;

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
            bio: "",
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
// FAVORITE CARD FOR SEARCH SCREEN

class FavoriteCard extends StatefulWidget {
  final String imageURL;
  final String firstName;
  final String lastName;
  final double rating;
  final String headline;
  final String id;
  final Function refreshCallBack;
  final String bio;
  const FavoriteCard(
      {this.imageURL,
      this.firstName,
      this.lastName,
      this.rating,
      this.headline,
      this.id,
      this.refreshCallBack,
      this.bio});

  @override
  _FavoriteCardState createState() => _FavoriteCardState();
}

class _FavoriteCardState extends State<FavoriteCard> {
  Icon starBorder = Icon(Icons.star_border, color: Colors.grey[300]);
  Icon starNoBorder = Icon(Icons.star, color: Colors.yellow[300]);
  Icon icon;
  String currentUser = FirebaseAuth.instance.currentUser.uid;

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
                bio: widget.bio),
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

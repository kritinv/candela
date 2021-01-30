import 'package:flutter/material.dart';
import 'package:bq_version/Custom Widgets/NavBar.dart';
import 'package:bq_version/main.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'ConsultantSignUp.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bq_version/Editables/BioEdit.dart';
import 'package:bq_version/Editables/HeadlineEdit.dart';

class UserProfile extends StatefulWidget {
  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  String email = FirebaseAuth.instance.currentUser.email;
  String photoURL = FirebaseAuth.instance.currentUser.photoURL;
  String fullName = FirebaseAuth.instance.currentUser.displayName;
  List nameArray = FirebaseAuth.instance.currentUser.displayName.split(" ");
  String firstName;
  String lastName = "";
  Map userData;

  void refresh() {
    setState(() {});
  }

  Future<String> downloadUserData() async {
    String id = FirebaseAuth.instance.currentUser.uid;
    await FirebaseFirestore.instance.collection('user').doc(id).get().then(
      (DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          print(documentSnapshot.data());
          userData = documentSnapshot.data();
        }
      },
    );
    return 'done';
  }

  @override
  Widget build(BuildContext context) {
    if (nameArray.length == 2) {
      firstName = nameArray[0];
      lastName = nameArray[1];
    } else {
      firstName = nameArray[0];
    }

    return FutureBuilder<String>(
        future: downloadUserData(),
        builder: (BuildContext context, AsyncSnapshot<String> string) {
          if (string.hasError) {
            return Text("Something went wrong");
          }
          if (string.hasData) {
            return DefaultTabController(
              length: 3,
              child: Scaffold(
                appBar: AppBar(
                  backgroundColor: Color(0xFFDC143C),
                  elevation: 0,
                  automaticallyImplyLeading: false,
                ),
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      child: Column(
                        children: [
                          SizedBox(height: 30),
                          GestureDetector(
                            onTap: () {
                              // _showPicker(context);
                            },
                            child: CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius: 55,
                                backgroundImage: NetworkImage(photoURL),
                              ),
                            ),
                          ),
                          Container(
                            child: Column(
                              children: [
                                Text(
                                  fullName,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  email,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                                SizedBox(height: 15),
                                (userData['status'] == 'normal')
                                    ? GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ConsultantSignUp(
                                                bio: this.userData['bio'],
                                                headline:
                                                    this.userData['headline'],
                                                refresh: refresh,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(7),
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                            color: Colors.white,
                                            width: 1,
                                          )),
                                          child: IntrinsicWidth(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.school,
                                                  color: Colors.white,
                                                  size: 12,
                                                ),
                                                SizedBox(width: 5),
                                                Text(
                                                  "Become a Consultant",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    : GestureDetector(
                                        onTap: () async {
                                          FirebaseFirestore.instance
                                              .collection('user')
                                              .doc(FirebaseAuth
                                                  .instance.currentUser.uid)
                                              .update({"status": "normal"});

                                          await FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(FirebaseAuth
                                                  .instance.currentUser.uid)
                                              .delete()
                                              .then((value) =>
                                                  print("User Deleted"))
                                              .catchError((error) => print(
                                                  "Failed to delete user: $error"));
                                          refresh();
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(7),
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                            color: Colors.white,
                                            width: 1,
                                          )),
                                          child: IntrinsicWidth(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.cancel,
                                                  color: Colors.white,
                                                  size: 12,
                                                ),
                                                SizedBox(width: 5),
                                                Text(
                                                  "Cancel Consultant Status",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                SizedBox(height: 10),
                              ],
                            ),
                            margin: EdgeInsets.all(20),
                          )
                        ],
                      ),
                      width: double.infinity,
                      color: Color(0xFFDC143C),
                    ),
                    Container(
                      color: Colors.red[300],
                      child: TabBar(
                        indicatorColor: Colors.transparent,
                        tabs: [
                          Tab(icon: Icon(Icons.person)),
                          Tab(icon: Icon(Icons.people)),
                          Tab(icon: Icon(Icons.settings)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          ListView(
                            children: [
                              ListTile(
                                onTap: () {},
                                leading: Icon(
                                  Icons.star,
                                  color: Colors.yellow,
                                ),
                                title: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 5),
                                    child: Text('Ratings')),
                                subtitle: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 5),
                                  child: Text(
                                      '5 users left ratings on your profile'),
                                ),
                                trailing: Icon(Icons.keyboard_arrow_right),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 30,
                                ),
                              ),
                              ListTile(
                                onTap: () {},
                                leading: Icon(
                                  Icons.person_add_alt_1_sharp,
                                  color: Colors.blue[300],
                                ),
                                title: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 5),
                                  child: Text('Favorites'),
                                ),
                                subtitle: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 5),
                                  child: Text(
                                      '11 users added you to their favorites list'),
                                ),
                                trailing: Icon(Icons.keyboard_arrow_right),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 30,
                                ),
                              ),
                              ListTile(
                                onTap: () {},
                                leading: Icon(
                                  Icons.menu_book,
                                  color: Colors.purple[300],
                                ),
                                title: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 5),
                                    child: Text('Bookings')),
                                subtitle: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 5),
                                    child: Text(
                                        'You have 6 new bookings waiting to be confirmed!')),
                                trailing: Icon(Icons.keyboard_arrow_right),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 30,
                                ),
                              ),
                              ListTile(
                                onTap: () {},
                                leading: Icon(
                                  Icons.cancel,
                                  color: Colors.red[300],
                                ),
                                title: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 5),
                                    child: Text('Cancellations')),
                                subtitle: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 5),
                                  child: Text(
                                      'Bomb cancelled his booking with you on January 9, 2021'),
                                ),
                                trailing: Icon(Icons.keyboard_arrow_right),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 30,
                                ),
                              ),
                              ListTile(
                                onTap: () {},
                                leading: Icon(Icons.watch_later_outlined),
                                title: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 5),
                                    child: Text('Added Appointments')),
                                subtitle: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 5),
                                    child: Text(
                                        'Bomb added an extra appointment')),
                                trailing: Icon(Icons.keyboard_arrow_right),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 30,
                                ),
                              ),
                            ],
                          ),
                          (this.userData['status'] == 'normal')
                              ? Center(
                                  child: Text("You are not a Consultant"),
                                )
                              : ListView(
                                  children: [
                                    ListTile(
                                      onTap: () {},
                                      leading: Icon(
                                        Icons.star,
                                        color: Colors.yellow,
                                      ),
                                      title: Padding(
                                          padding:
                                              EdgeInsets.symmetric(vertical: 5),
                                          child: Text('Ratings')),
                                      subtitle: Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 5),
                                        child: Text(
                                            '5 users left ratings on your profile'),
                                      ),
                                      trailing:
                                          Icon(Icons.keyboard_arrow_right),
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 10,
                                        horizontal: 30,
                                      ),
                                    ),
                                    ListTile(
                                      onTap: () {},
                                      leading: Icon(
                                        Icons.person_add_alt_1_sharp,
                                        color: Colors.blue[300],
                                      ),
                                      title: Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 5),
                                        child: Text('Favorites'),
                                      ),
                                      subtitle: Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 5),
                                        child: Text(
                                            '11 users added you to their favorites list'),
                                      ),
                                      trailing:
                                          Icon(Icons.keyboard_arrow_right),
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 10,
                                        horizontal: 30,
                                      ),
                                    ),
                                    ListTile(
                                      onTap: () {},
                                      leading: Icon(
                                        Icons.menu_book,
                                        color: Colors.purple[300],
                                      ),
                                      title: Padding(
                                          padding:
                                              EdgeInsets.symmetric(vertical: 5),
                                          child: Text('Bookings')),
                                      subtitle: Padding(
                                          padding:
                                              EdgeInsets.symmetric(vertical: 5),
                                          child: Text(
                                              'You have 6 new bookings waiting to be confirmed!')),
                                      trailing:
                                          Icon(Icons.keyboard_arrow_right),
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 10,
                                        horizontal: 30,
                                      ),
                                    ),
                                    ListTile(
                                      onTap: () {},
                                      leading: Icon(
                                        Icons.cancel,
                                        color: Colors.red[300],
                                      ),
                                      title: Padding(
                                          padding:
                                              EdgeInsets.symmetric(vertical: 5),
                                          child: Text('Cancellations')),
                                      subtitle: Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 5),
                                        child: Text(
                                            'Bomb cancelled his booking with you on January 9, 2021'),
                                      ),
                                      trailing:
                                          Icon(Icons.keyboard_arrow_right),
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 10,
                                        horizontal: 30,
                                      ),
                                    ),
                                    ListTile(
                                      onTap: () {},
                                      leading: Icon(Icons.watch_later_outlined),
                                      title: Padding(
                                          padding:
                                              EdgeInsets.symmetric(vertical: 5),
                                          child: Text('Added Appointments')),
                                      subtitle: Padding(
                                          padding:
                                              EdgeInsets.symmetric(vertical: 5),
                                          child: Text(
                                              'Bomb added an extra appointment')),
                                      trailing:
                                          Icon(Icons.keyboard_arrow_right),
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 10,
                                        horizontal: 30,
                                      ),
                                    ),
                                  ],
                                ),
                          ListView(
                            children: [
                              ListTile(
                                leading: Icon(
                                  Icons.view_headline,
                                  color: Colors.red[300],
                                ),
                                title: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 5),
                                    child: Text("Headline")),
                                subtitle: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 5),
                                  child: Text(this.userData['headline']),
                                ),
                                trailing: Icon(Icons.keyboard_arrow_right),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 30,
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => HeadlineEdit(
                                        refresh: refresh,
                                        headline: this.userData['headline'],
                                        status: this.userData['status'],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              ListTile(
                                leading: Icon(
                                  Icons.person_pin_circle_rounded,
                                  color: Colors.red[300],
                                ),
                                title: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 5),
                                    child: Text("Bio")),
                                subtitle: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 5),
                                  child: Text(this.userData['bio']),
                                ),
                                trailing: Icon(Icons.keyboard_arrow_right),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 30,
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BioEdit(
                                        refresh: refresh,
                                        bio: this.userData['bio'],
                                        status: this.userData['status'],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              ListTile(
                                leading: Icon(
                                  Icons.logout,
                                  color: Colors.grey,
                                ),
                                title: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 5),
                                    child: Text("Log Out")),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 30,
                                ),
                                onTap: () {
                                  context
                                      .read<AuthenticationService>()
                                      .signOut();
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    NavBar(),
                  ],
                ),
              ),
            );
          }
          return Container();
        });
  }
}

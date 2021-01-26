import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Custom Widgets/NavBar.dart';
import 'Custom Widgets/RatingBar.dart';
import 'main.dart';
import 'package:bq_version/main.dart';
import 'package:bq_version/ProfilePage.dart';
import 'package:overlay_screen/overlay_screen.dart';

////////////////////////////////////////////////////////////////////////////////
// HOME PAGE

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color _themePrimary = Color(0xFFDC143C);
  static const Color _themeLight = Colors.white;
  double height;
  double width;

  Widget body = HomeMeeting();
  bool searchBarPresent = false;
  Color meetingColor = _themeLight;
  Color meetingTextColor = _themePrimary;
  Color favoriteColor = _themePrimary;
  Color favoriteTextColor = _themeLight;

  toggleMeeting({width, height}) {
    if (body is! HomeMeeting) {
      print('what');
      setState(() {
        body = HomeMeeting(width: width, height: height);
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
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

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
                    onTap: () {
                      toggleMeeting(width: width, height: height);
                    },
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
                    onTap: () {
                      toggleFavorite();
                    },
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

class HomeMeeting extends StatefulWidget {
  final double width;
  final double height;
  const HomeMeeting({this.width, this.height});

  @override
  _HomeMeetingState createState() => _HomeMeetingState();
}

class _HomeMeetingState extends State<HomeMeeting> {
  // download mentor meetings data
  Future<List<Widget>> downloadMeeting() async {
    List<Widget> meetingWidget = [];
    Map meetingMap;
    await FirebaseFirestore.instance
        .collection('user')
        .doc(currentUser)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        meetingMap = documentSnapshot.data()["meeting"];
      }
    });

    print(meetingMap);
    List keys = meetingMap.keys.toList();

    await FirebaseFirestore.instance
        .collection('users')
        .where("id", whereIn: keys)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        List meetingTimes = meetingMap[doc["id"]];
        meetingTimes.sort();
        meetingWidget.add(
          MentorExpandableCard(
              firstName: doc["first_name"],
              lastName: doc["last_name"],
              imageURL: doc['image_url'],
              rating: double.parse(doc['rating']),
              headline: doc['headline'],
              meetingTimes: meetingTimes,
              totalMeetingTimes: doc["meeting"],
              id: doc.id,
              refresh: refresh,
              width: widget.width,
              height: widget.height),
        );
      });
    });
    return meetingWidget;
  }

  //refresh
  void refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Widget>>(
      future: downloadMeeting(),
      builder: (BuildContext context, AsyncSnapshot<List<Widget>> list) {
        if (list.hasError) {
          print(list.hasError);
          return Center(child: Text('No Upcoming Meetings'));
        }

        if (list.connectionState == ConnectionState.waiting) {
          print(list.connectionState);
          return Container();
        }
        print(list.data);
        return ListView(children: list.data);
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
  final List meetingTimes;
  final List totalMeetingTimes;
  final String id;
  final Function refresh;
  final double height;
  final double width;

  const MentorExpandableCard({
    this.imageURL,
    this.firstName,
    this.lastName,
    this.rating,
    this.headline,
    this.meetingTimes,
    this.totalMeetingTimes,
    this.id,
    this.refresh,
    this.height,
    this.width,
  });

  @override
  _MentorExpandableCardState createState() => _MentorExpandableCardState();
}

class _MentorExpandableCardState extends State<MentorExpandableCard> {
  List<String> selectedTimeSlots = [];
  List<Widget> timeBoxes = [];
  bool displayCancel = false;

  // initialize state
  @override
  void initState() {
    int length = widget.meetingTimes.length;
    for (int i = 0; i < length; i += 3) {
      timeBoxes.add(
        TimeRow(
            timeOne: widget.meetingTimes[i],
            timeTwo: (i + 1 < length) ? widget.meetingTimes[i + 1] : null,
            timeThree: (i + 2 < length) ? widget.meetingTimes[i + 2] : null,
            updateSelectedTimeSlots: updateSelectedTimeSlots,
            id: widget.id),
      );
    }
    super.initState();
  }

  // void cancel Appointment
  void cancelTime() async {
    widget.meetingTimes
        .removeWhere((element) => selectedTimeSlots.contains(element));
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.id)
        .update({'meeting': FieldValue.arrayUnion(selectedTimeSlots)});

    if (widget.meetingTimes.isEmpty) {
      await FirebaseFirestore.instance
          .collection('user')
          .doc(currentUser)
          .update({('meeting.' + widget.id): FieldValue.delete()});
      timeBoxes = [];
      widget.refresh();
    } else {
      await FirebaseFirestore.instance
          .collection('user')
          .doc(currentUser)
          .update({
        ('meeting.' + widget.id): FieldValue.arrayRemove(selectedTimeSlots)
      });
      timeBoxes = [];
      int length = widget.meetingTimes.length;
      for (int i = 0; i < length; i += 3) {
        timeBoxes.add(
          TimeRow(
              timeOne: widget.meetingTimes[i],
              timeTwo: (i + 1 < length) ? widget.meetingTimes[i + 1] : null,
              timeThree: (i + 2 < length) ? widget.meetingTimes[i + 2] : null,
              updateSelectedTimeSlots: updateSelectedTimeSlots,
              id: widget.id),
        );
      }
      setState(() {
        selectedTimeSlots = [];
        displayCancel = false;
      });
    }
  }

  //////////////////////////////////////////////////////////////////////////////

  List selectedNewTimeSlots = [];
  List timeSlotsTime = [];

  // add appointment
  void addAppointment({context}) {
    OverlayScreen().show(
      context,
      identifier: "TimeSlots",
    );
  }

  void updateNewSelectedTimeSlots({how, value}) {
    if (how == 'add') {
      setState(() {
        selectedTimeSlots.add(value);
      });
    } else {
      setState(() {
        selectedTimeSlots.remove(value);
      });
    }
    print(selectedTimeSlots);
  }

  Future<List> downloadMeetings() async {
    List<Widget> timeSlotsWidget = [];
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.id)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        print(documentSnapshot.data());
        timeSlotsTime = documentSnapshot.data()["meeting"];
      }
    });
    if (timeSlotsTime.isNotEmpty) {
      for (int i = 0; i < timeSlotsTime.length; i += 2) {
        timeSlotsWidget.add(
          TimeSlot(
            timeSlotOne: timeSlotsTime[i],
            timeSlotTwo:
                ((i + 1) < timeSlotsTime.length && timeSlotsTime.length != 1)
                    ? timeSlotsTime[i + 1]
                    : null,
            updateSelectedTimeSlots: updateSelectedTimeSlots,
          ),
        );
        print(timeSlotsWidget);
      }
    }
    return timeSlotsWidget;
  }

  //////////////////////////////////////////////////////////////////////////////

  // update selected time slots
  void updateSelectedTimeSlots({how, id, value}) {
    if (how == 'add') {
      selectedTimeSlots.add(value);
    } else {
      selectedTimeSlots.remove(value);
    }
    print(selectedTimeSlots);
    if (selectedTimeSlots.isNotEmpty) {
      setState(() {
        displayCancel = true;
      });
    } else {
      setState(() {
        displayCancel = false;
      });
    }
  }

  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List>(
        future:
            downloadMeetings(), // a previously-obtained Future<String> or null
        builder: (BuildContext context, AsyncSnapshot<List> list) {
          if (list.hasData) {
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
                        Column(children: [
                          Container(
                              margin: EdgeInsets.only(right: 20),
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                  icon: Icon(Icons.close),
                                  onPressed: () {
                                    OverlayScreen().pop();
                                  })),
                          SizedBox(height: 10),
                          Container(
                            height: height * 2 / 3,
                            child: ListView(children: list.data),
                          ),
                        ]),
                        Container(
                          margin: EdgeInsets.only(bottom: 10),
                          width: width * 2 / 3,
                          height: 50,
                          child: FlatButton(
                            color: Colors.orange[300],
                            child: Text("Confirm Meeting Times"),
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection('user')
                                  .doc(currentUser)
                                  .update({
                                ('meeting.' + widget.id):
                                    FieldValue.arrayUnion(selectedTimeSlots)
                              });
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(widget.id)
                                  .update({
                                'meeting':
                                    FieldValue.arrayRemove(selectedTimeSlots)
                              });
                              OverlayScreen().pop();
                              Navigator.pushReplacementNamed(context, '/home');
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            });

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
                        margin: EdgeInsets.symmetric(vertical: 10),
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
                                  style: TextStyle(
                                      fontSize: 20, fontFamily: "OpenSans"),
                                ),
                                SizedBox(height: 10),
                                RatingBar(rating: widget.rating, color: color),
                                SizedBox(height: 10),
                                Text(
                                  widget.headline,
                                  style: TextStyle(
                                      fontSize: 12, fontFamily: "OpenSans"),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  body: ListTile(
                    contentPadding: EdgeInsets.only(bottom: 10),
                    title: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (timeSlotsTime.length != 0) {
                              addAppointment(context: context);
                            }
                          },
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              width: 160,
                              height: 30,
                              margin: EdgeInsets.only(left: 30),
                              child: Center(
                                child: Text(
                                  "Add Appointments (${timeSlotsTime.length})",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              decoration: BoxDecoration(
                                  color: Colors.orange[300],
                                  borderRadius: BorderRadius.circular(5)),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Column(children: timeBoxes),
                        (displayCancel)
                            ? Column(children: [
                                SizedBox(height: 10),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          timeSlotsTime = [];
                                          cancelTime();
                                        },
                                        child: Container(
                                          width: 80,
                                          height: 25,
                                          child: Center(
                                            child: Text(
                                              "Cancel",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                          decoration: BoxDecoration(
                                              color: Color(0xFFDC143C),
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                        ),
                                      ),
                                    ]),
                              ])
                            : Container(height: 0, width: 0),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                  isExpanded: expanded,
                ),
              ],
            );
          } else if (list.hasError) {
            return Text('error');
          } else {
            return Container();
          }
        });
  }
}

////////////////////////////////////////////////////////////////////////////////
// CUSTOM WIDGET FOR DISPLAYING TIME SLOTS IN MEETING BOX

class TimeRow extends StatelessWidget {
  final String timeOne;
  final String timeTwo;
  final String timeThree;
  final Function updateSelectedTimeSlots;
  final String id;
  TimeRow(
      {this.timeOne,
      this.timeTwo,
      this.timeThree,
      this.updateSelectedTimeSlots,
      this.id});

  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 5, bottom: 5, left: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          TimeBox(
            time: timeOne,
            updateSelectedTimeSlots: updateSelectedTimeSlots,
            id: id,
          ),
          (timeTwo != null)
              ? TimeBox(
                  time: timeTwo,
                  updateSelectedTimeSlots: updateSelectedTimeSlots,
                  id: id,
                )
              : Container(width: 100, height: 30),
          (timeThree != null)
              ? TimeBox(
                  time: timeThree,
                  updateSelectedTimeSlots: updateSelectedTimeSlots,
                  id: id,
                )
              : Container(width: 100, height: 30),
        ],
      ),
    );
  }
}

class TimeBox extends StatefulWidget {
  final Function updateSelectedTimeSlots;
  final String time;
  final String id;
  TimeBox({this.time, this.updateSelectedTimeSlots, this.id});

  @override
  _TimeBoxState createState() => _TimeBoxState();
}

class _TimeBoxState extends State<TimeBox> {
  bool selected = false;

  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (selected == false) {
          setState(() {
            selected = true;
          });
          widget.updateSelectedTimeSlots(
              how: "add", value: widget.time, id: widget.id);
        } else {
          setState(() {
            selected = false;
          });
          widget.updateSelectedTimeSlots(
              how: "remove", value: widget.time, id: widget.id);
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 5),
        width: 100,
        height: 30,
        child: Center(
          child: Text(
            widget.time,
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.red[300],
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: (selected) ? Colors.orange[300] : Colors.transparent,
            width: 3,
          ),
        ),
      ),
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
            ),
          ),
        );
      },
      title: Container(
          margin: EdgeInsets.only(top: 10),
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

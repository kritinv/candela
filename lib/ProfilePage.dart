import 'package:flutter/material.dart';
import 'Custom Widgets/NavBar.dart';
import 'Custom Widgets/RatingBar.dart';
import 'package:overlay_screen/overlay_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart';

class ProfilePage extends StatefulWidget {
  final String imageURL;
  final String firstName;
  final String lastName;
  final String headline;
  final RatingBar ratingBar;
  final double rating;
  final Color color;
  final String id;

  ProfilePage(
      {@required this.imageURL,
      @required this.firstName,
      @required this.lastName,
      @required this.headline,
      @required this.ratingBar,
      @required this.rating,
      @required this.color,
      @required this.id});

  static const Color _themePrimary = Color(0xFFDC143C);
  static const Color _themeLight = Colors.white;

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List selectedTimeSlots = [];
  List timeSlotsTime;
  bool unavailableMessage = false;

  void refresh() {
    setState(() {});
  }

  void showUnavailable() {
    setState(() {
      unavailableMessage = true;
    });
  }

  void updateSelectedTimeSlots({how, value}) {
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
    print("ok");

    timeSlotsTime = [];
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
    print('1asdfasdfasd');
    print(timeSlotsTime);
    if (timeSlotsTime.isNotEmpty) {
      for (int i = 0; i < timeSlotsTime.length; i += 2) {
        print(i);
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
        print('hi');
        print(timeSlotsWidget);
      }
    }
    print("ok");

    return timeSlotsWidget;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List>(
      future:
          downloadMeetings(), // a previously-obtained Future<String> or null
      builder: (BuildContext context, AsyncSnapshot<List> list) {
        if (list.hasData) {
          double height = MediaQuery.of(context).size.height;
          double width = MediaQuery.of(context).size.width;
          OverlayScreen().saveScreens({
            'TimeSlots': CustomOverlayScreen(
              backgroundColor: Colors.transparent,
              content: Container(
                width: width * 3 / 2,
                height: height * 3 / 2,
                child: Dialog(
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

          // profile page content part
          return Scaffold(
            appBar: AppBar(
              backgroundColor: ProfilePage._themePrimary,
              elevation: 0,
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
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
                        Text(
                          "@username",
                          style: TextStyle(
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 15),
                        Text(widget.firstName + " " + widget.lastName,
                            style: TextStyle(fontSize: 25)),
                        SizedBox(height: 10),
                        Text(
                          widget.headline,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 15),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 50),
                          child: Text(
                              "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis lacinia volutpat urna, non aliquam mi dictum vel. Vestibulum pretium id lacus at lobortis.",
                              style: TextStyle(fontSize: 15),
                              textAlign: TextAlign.left),
                        ),
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
                                child: Text(
                                  widget.rating.toString(),
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 30),
                        FlatButton(
                          onPressed: () {
                            if (timeSlotsTime.length == 0) {
                              showUnavailable();
                            } else {
                              OverlayScreen().show(
                                context,
                                identifier: "TimeSlots",
                              );
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            height: 40,
                            margin: EdgeInsets.symmetric(horizontal: 50),
                            child: Center(
                              child: Text(
                                "Meetings (${timeSlotsTime.length})",
                                style:
                                    TextStyle(color: ProfilePage._themeLight),
                              ),
                            ),
                            color: ProfilePage._themePrimary,
                          ),
                        ),
                        SizedBox(height: 10),
                        (unavailableMessage)
                            ? Text(
                                'No Available Timeslots',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFDC143C),
                                ),
                              )
                            : Container(width: 0, height: 0),
                      ],
                    ),
                  ),
                ),
                NavBar(),
              ],
            ),
          );
        } else if (list.hasError) {
          return Text('error');
        } else {
          return Container();
        }
      },
    );
  }
}

////////////////////////////////////////////////////////////////////////////////
// CUSTOM WIDGET TIME SLOT

class TimeSlot extends StatefulWidget {
  final String timeSlotOne;
  final String timeSlotTwo;
  final Function updateSelectedTimeSlots;
  TimeSlot({this.timeSlotOne, this.timeSlotTwo, this.updateSelectedTimeSlots});

  @override
  _TimeSlotState createState() => _TimeSlotState();
}

class _TimeSlotState extends State<TimeSlot> {
  bool selectedStateOne = false;
  bool selectedStateTwo = false;
  static const Color _themePrimary = Color(0xFFDC143C);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              setState(() {
                if (selectedStateOne == true) {
                  setState(() {
                    selectedStateOne = false;
                    widget.updateSelectedTimeSlots(
                        how: 'remove', value: widget.timeSlotOne);
                  });
                } else {
                  selectedStateOne = true;
                  widget.updateSelectedTimeSlots(
                      how: 'add', value: widget.timeSlotOne);
                }
              });
            },
            child: Container(
              height: 50,
              width: 130,
              decoration: BoxDecoration(
                color: _themePrimary,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: (selectedStateOne)
                      ? Colors.orange[300]
                      : Colors.transparent,
                  width: 5,
                ),
              ),
              child: Center(
                child: Text(
                  widget.timeSlotOne,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          (widget.timeSlotTwo != null)
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      if (selectedStateTwo == true) {
                        setState(() {
                          selectedStateTwo = false;
                          widget.updateSelectedTimeSlots(
                              how: 'remove', value: widget.timeSlotTwo);
                        });
                      } else {
                        selectedStateTwo = true;
                        widget.updateSelectedTimeSlots(
                            how: 'add', value: widget.timeSlotTwo);
                      }
                    });
                  },
                  child: Container(
                    height: 50,
                    width: 130,
                    decoration: BoxDecoration(
                      color: _themePrimary,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: (selectedStateTwo)
                            ? Colors.orange[300]
                            : Colors.transparent,
                        width: 5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        widget.timeSlotTwo,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                )
              : Container(
                  width: 130,
                  height: 50,
                )
        ],
      ),
    );
  }
}

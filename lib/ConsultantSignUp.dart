import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bq_version/Custom Widgets/NavBar.dart';
import 'package:time_range_picker/time_range_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

extension TimeOfDayExtension on TimeOfDay {
  // Ported from org.threeten.bp;
  TimeOfDay plusMinutes(int minutes) {
    if (minutes == 0) {
      return this;
    } else {
      int mofd = this.hour * 60 + this.minute;
      int newMofd = ((minutes % 1440) + mofd + 1440) % 1440;
      if (mofd == newMofd) {
        return this;
      } else {
        int newHour = newMofd ~/ 60;
        int newMinute = newMofd % 60;
        return TimeOfDay(hour: newHour, minute: newMinute);
      }
    }
  }
}

class ConsultantSignUp extends StatefulWidget {
  static const Color _themePrimary = Color(0xFFDC143C);
  final String bio;
  final String headline;
  final Function refresh;
  ConsultantSignUp({this.bio, this.headline, this.refresh});
  @override
  _ConsultantSignUpState createState() => _ConsultantSignUpState();
}

class _ConsultantSignUpState extends State<ConsultantSignUp> {
  // time variables
  String dropDownValue;
  TimeOfDay start;
  TimeOfDay end;
  Duration timeInterval;

  // array
  List days;
  List specialties;
  List timeSlots;

  // days boolean
  bool monday;
  bool tuesday;
  bool wednesday;
  bool thursday;
  bool friday;
  bool saturday;
  bool sunday;

  // specialties boolean
  bool resume;
  bool interview;
  bool essay;
  bool extracurriculars;
  bool communityService;
  bool research;
  bool generalAdvice;

  @override
  void initState() {
    dropDownValue = "15 minutes";
    start = TimeOfDay(hour: 0, minute: 0);
    end = TimeOfDay(hour: 0, minute: 0);
    timeInterval = Duration(minutes: 15);

    // array
    days = [];
    specialties = [];
    timeSlots = [];

    // days boolean
    monday = false;
    tuesday = false;
    wednesday = false;
    thursday = false;
    friday = false;
    saturday = false;
    sunday = false;

    // specialties boolean
    resume = false;
    interview = false;
    essay = false;
    extracurriculars = false;
    communityService = false;
    research = false;
    generalAdvice = false;
    super.initState();
  }

  // add remove day
  void toggleDay({boolean, day}) {
    if (boolean == true) {
      days.add(day);
    } else {
      days.remove(day);
    }
    print(days);
  }

  // add remove day
  void toggleSpecialties({boolean, specialty}) {
    if (boolean == true) {
      specialties.add(specialty);
    } else {
      specialties.remove(specialty);
    }
    print(specialties);
  }

  void setTimeInterval() {
    setState(() {
      if (dropDownValue == '15 minutes') {
        timeInterval = Duration(minutes: 15);
      } else if (dropDownValue == '30 minutes') {
        timeInterval = Duration(minutes: 30);
      } else if (dropDownValue == '1 hour') {
        timeInterval = Duration(hours: 1);
      } else if (dropDownValue == '2 hours') {
        timeInterval = Duration(hours: 2);
      } else {
        print("There is something wrong");
      }
      start = TimeOfDay(hour: 0, minute: 0);
      end = TimeOfDay(hour: 0, minute: 0);
    });
  }

  void createTimeSlots() {
    TimeOfDay time = start;
    do {
      String stringTime = "";
      stringTime += time.hour.toString() +
          ":" +
          (time.minute < 10 ? "0" : "") +
          time.minute.toString() +
          " - ";
      time = time.plusMinutes(timeInterval.inMinutes);
      stringTime += time.hour.toString() +
          ":" +
          (time.minute < 10 ? "0" : "") +
          time.minute.toString();
      print(stringTime);
      timeSlots.add(stringTime);
    } while (time != end);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ConsultantSignUp._themePrimary,
        elevation: 0,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Container(
              padding: EdgeInsets.all(20),
              child: ListView(
                children: [
                  Text(
                    'Time Interval',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  DropdownButton<String>(
                    value: dropDownValue,
                    icon: Icon(Icons.keyboard_arrow_down),
                    iconSize: 24,
                    elevation: 16,
                    style: TextStyle(color: Colors.black),
                    underline: Container(
                      height: 2,
                      color: Colors.red[300],
                    ),
                    onChanged: (String newValue) {
                      setState(() {
                        dropDownValue = newValue;
                        setTimeInterval();
                      });
                    },
                    items: <String>[
                      '15 minutes',
                      '30 minutes',
                      '1 hour',
                      '2 hours',
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 30),
                  Text(
                    'Time Range',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    child: RaisedButton(
                      onPressed: () async {
                        TimeRange result = await showTimeRangePicker(
                            context: context,
                            interval: timeInterval,
                            start: start,
                            end: end,
                            onStartChange: (TimeOfDay start) {
                              setState(() {
                                this.start = start;
                              });
                            },
                            onEndChange: (TimeOfDay end) {
                              setState(() {
                                this.start = end;
                              });
                            });
                        print("result " + result.toString());
                      },
                      child: Text(
                        "Add Time Range",
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                  Container(
                    child: Row(children: [
                      Icon(Icons.watch_later),
                      SizedBox(width: 5),
                      Text(
                          "${start.hour}:${(start.minute < 10 ? "0" : "") + start.minute.toString()}"),
                      Text("-"),
                      Text(
                          "${end.hour}:${(end.minute < 10 ? "0" : "") + end.minute.toString()}"),
                    ]),
                  ),
                  SizedBox(height: 30),
                  Text(
                    'Available Dates',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Column(
                    children: [
                      LabeledCheckbox(
                        label: 'Monday',
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        value: monday,
                        onChanged: (bool newValue) {
                          setState(() {
                            monday = newValue;
                          });
                          toggleDay(day: 'Monday', boolean: newValue);
                        },
                      ),
                      LabeledCheckbox(
                        label: 'Tuesday',
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        value: tuesday,
                        onChanged: (bool newValue) {
                          setState(() {
                            tuesday = newValue;
                          });
                          toggleDay(day: 'Tuesday', boolean: newValue);
                        },
                      ),
                      LabeledCheckbox(
                        label: 'Wednesday',
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        value: wednesday,
                        onChanged: (bool newValue) {
                          setState(() {
                            wednesday = newValue;
                          });
                          toggleDay(day: 'Wednesday', boolean: newValue);
                        },
                      ),
                      LabeledCheckbox(
                        label: 'Thursday',
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        value: thursday,
                        onChanged: (bool newValue) {
                          setState(() {
                            thursday = newValue;
                          });
                          toggleDay(day: 'Thursday', boolean: newValue);
                        },
                      ),
                      LabeledCheckbox(
                        label: 'Friday',
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        value: friday,
                        onChanged: (bool newValue) {
                          setState(() {
                            friday = newValue;
                          });
                          toggleDay(day: 'Friday', boolean: newValue);
                        },
                      ),
                      LabeledCheckbox(
                        label: 'Saturday',
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        value: saturday,
                        onChanged: (bool newValue) {
                          setState(() {
                            saturday = newValue;
                          });
                          toggleDay(day: 'Saturday', boolean: newValue);
                        },
                      ),
                      LabeledCheckbox(
                        label: 'Sunday',
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        value: sunday,
                        onChanged: (bool newValue) {
                          setState(() {
                            sunday = newValue;
                          });
                          toggleDay(day: 'Sunday', boolean: newValue);
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  Text(
                    'Specialties',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 30),
                  Column(
                    children: [
                      LabeledCheckbox(
                        label: 'Resume',
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        value: resume,
                        onChanged: (bool newValue) {
                          setState(() {
                            resume = newValue;
                          });
                          toggleSpecialties(
                              boolean: newValue, specialty: "Resume");
                        },
                      ),
                      LabeledCheckbox(
                        label: 'Interview',
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        value: interview,
                        onChanged: (bool newValue) {
                          setState(() {
                            interview = newValue;
                          });
                          toggleSpecialties(
                              boolean: newValue, specialty: "Interview");
                        },
                      ),
                      LabeledCheckbox(
                        label: 'Essay',
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        value: essay,
                        onChanged: (bool newValue) {
                          setState(() {
                            essay = newValue;
                          });
                          toggleSpecialties(
                              boolean: newValue, specialty: "Essay");
                        },
                      ),
                      LabeledCheckbox(
                        label: 'Extracurriculars',
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        value: extracurriculars,
                        onChanged: (bool newValue) {
                          setState(() {
                            extracurriculars = newValue;
                          });
                          toggleSpecialties(
                              boolean: newValue, specialty: "Extracurriculars");
                        },
                      ),
                      LabeledCheckbox(
                        label: 'Community Service',
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        value: communityService,
                        onChanged: (bool newValue) {
                          setState(() {
                            communityService = newValue;
                          });
                          toggleSpecialties(
                              boolean: newValue,
                              specialty: "Community Service");
                        },
                      ),
                      LabeledCheckbox(
                        label: 'Research',
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        value: research,
                        onChanged: (bool newValue) {
                          setState(() {
                            research = newValue;
                          });
                          toggleSpecialties(
                              boolean: newValue, specialty: "Research");
                        },
                      ),
                      LabeledCheckbox(
                        label: 'General Advice',
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        value: generalAdvice,
                        onChanged: (bool newValue) {
                          setState(() {
                            generalAdvice = newValue;
                          });
                          toggleSpecialties(
                              boolean: newValue, specialty: "General Advice");
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  RaisedButton(
                    padding: EdgeInsets.all(20),
                    color: Colors.red[300],
                    onPressed: () async {
                      createTimeSlots();
                      await FirebaseFirestore.instance
                          .collection('user')
                          .doc(FirebaseAuth.instance.currentUser.uid)
                          .update({
                        "status": "consultant",
                        "meeting_mentee": {},
                      });

                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser.uid)
                          .set({
                        "first_name": FirebaseAuth
                            .instance.currentUser.displayName
                            .split(" ")[0],
                        "last_name": (FirebaseAuth
                                    .instance.currentUser.displayName
                                    .split(" ")
                                    .length ==
                                2)
                            ? FirebaseAuth.instance.currentUser.displayName
                                .split(" ")[1]
                            : "",
                        "image_url": FirebaseAuth.instance.currentUser.photoURL,
                        "id": FirebaseAuth.instance.currentUser.uid,
                        "rating": "0",
                        "specialty": specialties,
                        "meeting": timeSlots,
                        "bio": widget.bio,
                        "headline": widget.headline,
                        "status": "consultant"
                      });
                      widget.refresh();
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Become a Consultant",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          NavBar(),
        ],
      ),
    );
  }
}

class LabeledCheckbox extends StatelessWidget {
  const LabeledCheckbox({
    this.label,
    this.padding,
    this.value,
    this.onChanged,
  });

  final String label;
  final EdgeInsets padding;
  final bool value;
  final Function onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onChanged(!value);
      },
      child: Padding(
        padding: padding,
        child: Row(
          children: <Widget>[
            Checkbox(
              activeColor: Colors.red[300],
              value: value,
              onChanged: (bool newValue) {
                onChanged(newValue);
              },
            ),
            Text(label),
          ],
        ),
      ),
    );
  }
}

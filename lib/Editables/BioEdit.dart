import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BioEdit extends StatefulWidget {
  final String bio;
  final Function refresh;
  final String status;
  BioEdit({this.bio, this.refresh, this.status});

  @override
  _BioEditState createState() => _BioEditState();
}

class _BioEditState extends State<BioEdit> {
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    controller.text = widget.bio;

    return Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            GestureDetector(
              child: Container(
                margin: EdgeInsets.fromLTRB(0, 20, 20, 0),
                child: Text("Done", style: TextStyle(fontSize: 16)),
              ),
              onTap: () async {
                await FirebaseFirestore.instance
                    .collection('user')
                    .doc(FirebaseAuth.instance.currentUser.uid)
                    .update({"bio": controller.text});
                if (widget.status == 'consultant') {
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser.uid)
                      .update({"bio": controller.text});
                }
                widget.refresh();
                Navigator.pop(context);
              },
            )
          ],
        ),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              color: Colors.grey[200],
              margin: EdgeInsets.only(left: 13),
              padding: EdgeInsets.only(top: 4),
              height: 15,
              child: Text('Bio',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  )),
            ),
            Container(
                child: TextField(
              minLines: 3,
              maxLines: 5,
              controller: controller,
              decoration: new InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
              ),
            )),
          ],
        ));
  }
}

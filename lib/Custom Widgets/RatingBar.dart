import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

////////////////////////////////////////////////////////////////////////////////
// RATING BAR CUSTOM WIDGET

class RatingBar extends StatefulWidget {
  final double rating;
  final Color color;
  RatingBar({@required this.rating, @required this.color});

  @override
  _RatingBarState createState() => _RatingBarState();
}

class _RatingBarState extends State<RatingBar> {
  @override
  Widget build(BuildContext context) {
    return LinearPercentIndicator(
      lineHeight: 10.0,
      percent: widget.rating / 5.0,
      progressColor: widget.color,
    );
  }
}

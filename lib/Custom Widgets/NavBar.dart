import 'package:flutter/material.dart';

////////////////////////////////////////////////////////////////////////////////
// CUSTOM WIDGET Navigation

class NavBar extends StatelessWidget {
  static const Color _themePrimary = Color(0xFFDC143C); // theme primary
  @override
  Widget build(BuildContext context) {
    return Container(
      color: _themePrimary,
      height: 80,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          NavBarItem(icon: Icons.home, routeName: "/home"),
          NavBarItem(icon: Icons.search, routeName: "/search"),
          NavBarItem(icon: Icons.notifications, routeName: "/notifications"),
          NavBarItem(icon: Icons.check, routeName: "/completed"),
          NavBarItem(icon: Icons.person, routeName: "/user"),
        ],
      ),
    );
  }
}

class NavBarItem extends StatelessWidget {
  final IconData icon;
  final String routeName;
  NavBarItem({this.icon, this.routeName});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Icon(icon, color: Color(0xFFEFEFEF), size: 30),
      onTap: () {
        Navigator.pushReplacementNamed(context, routeName);
      },
    );
  }
}

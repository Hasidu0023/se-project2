import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';

import 'Tr_Classes_Page.dart';
import 'Tr_Notifications_Page.dart';
import 'Tr_Payments_Page.dart';
import 'Tr_Profile_Page.dart';

class TeacherDashboard extends StatefulWidget {
  final String username;

  const TeacherDashboard({super.key, required this.username});

  @override
  _TeacherDashboardState createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  int _pageIndex = 0;
  GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      ProfilePage(username: widget.username),
      AllClassesPage(username: widget.username),
      EnrolledClassesPage(
        username: widget.username,
      ),
      NotificationsPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(5.0), // Set height of AppBar
        child: AppBar(
          title: Text(""),
          backgroundColor: Colors.lightBlue, // Set AppBar color to light blue
        ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        height: 50.0, // Set height of NavigationBar
        color: Colors.lightBlue, // Set NavigationBar color to light blue
        backgroundColor:
            Colors.white, // Set background color of the scaffold to white
        items: <Widget>[
          Icon(Icons.person, size: 30, color: Colors.white), // Profile
          Icon(Icons.all_inbox, size: 30, color: Colors.white), // All Classes
          Icon(Icons.class_, size: 30, color: Colors.white), // Enrolled Classes
          Icon(Icons.notifications,
              size: 30, color: Colors.white), // Notifications
        ],
        onTap: (index) {
          setState(() {
            _pageIndex = index; // Update the page index
          });
        },
      ),
      body: Container(
        color: Colors.white, // Set body background to white
        child: _pages[_pageIndex], // Display the corresponding page
      ),
    );
  }
}

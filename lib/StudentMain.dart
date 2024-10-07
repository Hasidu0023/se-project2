import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';

import 'St_All Classes_Page.dart';
import 'St_Enrolled_Classes_Page.dart';
import 'St_Notifications_Page.dart';
import 'St_Profile_Page.dart';

class StudentDashboard extends StatefulWidget {
  final String username; // Add username as a variable

  const StudentDashboard(
      {super.key,
      required this.username}); // Accept username in the constructor

  @override
  _StudentDashboardState createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _pageIndex = 0;
  GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  // Define the pages for each navigation item
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    // Initialize the pages and pass the username to the necessary pages
    _pages = [
      HomePage(username: widget.username), // Pass username to HomePage
      AllClassesPage(username: widget.username), // Pass username
      AssignmentsPage(username: widget.username), // Pass username
      NotificationsPage(), // Pass username
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
          Icon(Icons.home, size: 30, color: Colors.white), // Home
          Icon(Icons.class_, size: 30, color: Colors.white), // Enrolled Classes
          Icon(Icons.assignment, size: 30, color: Colors.white), // Assignments
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

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Pr_Enrolled_Classes_Page.dart';
import 'package:flutter_application_1/Pr_Notifications_Page.dart';
import 'package:flutter_application_1/Pr_Payments_Page.dart';
import 'package:flutter_application_1/Pr_Profile_Page.dart';

class ParentDashboard extends StatefulWidget {
  const ParentDashboard({super.key, required this.username});

  final String username; // Add username as a variable

  @override
  _ParentDashboardState createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {
  int _pageIndex = 0;
  GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    // Define the pages for each navigation item, passing username where needed
    final List<Widget> _pages = [
      ProfilePage(username: widget.username),
      EnrolledClassesPage(
        username: widget.username,
      ),
      PaymentsPage(username: widget.username),
      NotificationsPage(),
    ];

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
          Icon(Icons.class_, size: 30, color: Colors.white), // Enrolled Classes
          Icon(Icons.payment, size: 30, color: Colors.white), // Payments
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

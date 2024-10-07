import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<DocumentSnapshot> _allNotices = [];
  List<DocumentSnapshot> _filteredNotices = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchNotices();
  }

  void _fetchNotices() async {
    final snapshot = await _firestore.collection('notices').get();
    setState(() {
      _allNotices = snapshot.docs;
      _filteredNotices = _allNotices;
    });
  }

  void _filterNotices(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      _filteredNotices = _allNotices
          .where(
              (notice) => notice['Title'].toLowerCase().contains(_searchQuery))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('notices'),
        backgroundColor: const Color.fromARGB(255, 252, 254, 255),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _filterNotices,
              decoration: InputDecoration(
                hintText: 'Search notices...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredNotices.length,
              itemBuilder: (context, index) {
                var notice = _filteredNotices[index];
                return Card(
                  elevation: 5,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    title: Text(
                      notice['Title'],
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${notice['Date']} - Posted by ${notice['PostedBy']}',
                      style: TextStyle(
                          color: const Color.fromARGB(255, 93, 89, 89)),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NoticeDetailsPage(
                            title: notice['Title'],
                            details: notice['Details'],
                            date: notice['Date'],
                            postedBy: notice['PostedBy'],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class NoticeDetailsPage extends StatelessWidget {
  final String title;
  final String details;
  final String date;
  final String postedBy;

  NoticeDetailsPage({
    required this.title,
    required this.details,
    required this.date,
    required this.postedBy,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          // Added to make the content scrollable
          child: Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(
                  255, 218, 220, 249), // Light background color
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(255, 220, 71, 71)
                      .withOpacity(0.3), // Softer shadow
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2C3E50), // Darker text color
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Date: $date',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.blueGrey,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Posted By: $postedBy',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.blueGrey,
                    ),
                  ),
                  SizedBox(height: 16),
                  Divider(
                    color: const Color(0xFF7986CB)
                        .withOpacity(0.5), // Lighter divider
                    thickness: 1.5, // Thicker divider for better visibility
                  ),
                  SizedBox(height: 16),
                  Text(
                    details,
                    style: TextStyle(
                      fontSize: 18,
                      //lineHeight: 1.5, // Improved line height for better readability
                      color: const Color(0xFF34495E), // Darker text color
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

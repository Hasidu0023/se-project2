import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<DocumentSnapshot>> _fetchNotices() async {
    final snapshot = await _firestore.collection('notices').get();
    return snapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DocumentSnapshot>>(
      future: _fetchNotices(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No notices Found'));
        }

        final notices = snapshot.data!;
        return NotificationsList(notices: notices);
      },
    );
  }
}

class NotificationsList extends StatefulWidget {
  final List<DocumentSnapshot> notices;

  NotificationsList({required this.notices});

  @override
  _NotificationsListState createState() => _NotificationsListState();
}

class _NotificationsListState extends State<NotificationsList> {
  List<DocumentSnapshot> _filteredNotices = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _filteredNotices = widget.notices;
  }

  void _filterNotices(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      _filteredNotices = widget.notices
          .where(
              (notice) => notice['Title'].toLowerCase().contains(_searchQuery))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding:
              const EdgeInsets.all(16.0), // Increase padding for better spacing
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30), // More rounded corners
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2), // Subtle shadow
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3), // Shadow position
                ),
              ],
            ),
            child: TextField(
              onChanged: _filterNotices,
              decoration: InputDecoration(
                hintText: 'Search notices...',
                hintStyle: TextStyle(
                    color: const Color.fromARGB(
                        255, 160, 153, 153)), // Hint text color
                prefixIcon: Icon(Icons.search,
                    color:
                        const Color.fromARGB(255, 126, 120, 120)), // Icon color
                border: InputBorder.none, // Remove border
                filled: true, // Fill the background
                fillColor: const Color.fromARGB(
                    255, 236, 229, 229), // Background color
                contentPadding: EdgeInsets.symmetric(vertical: 15.0), // Padding
              ),
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${notice['Date']} - Posted by ${notice['PostedBy']}',
                    style: TextStyle(color: Color.fromARGB(255, 93, 89, 89)),
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

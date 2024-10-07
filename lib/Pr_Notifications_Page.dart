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

class NotificationsList extends StatelessWidget {
  final List<DocumentSnapshot> notices;

  NotificationsList({required this.notices});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            onChanged: (query) {
              // Implement search functionality here
            },
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
            itemCount: notices.length,
            itemBuilder: (context, index) {
              var notice = notices[index];
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

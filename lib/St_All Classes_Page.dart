import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AllClassesPage extends StatefulWidget {
  final String username;

  const AllClassesPage({Key? key, required this.username}) : super(key: key);

  @override
  _AllClassesPageState createState() => _AllClassesPageState();
}

class _AllClassesPageState extends State<AllClassesPage> {
  String selectedStream = '';
  String selectedClassId = '';
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // Timer to automatically switch images every 3 seconds
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_currentPage < 2) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'All Classes',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 252, 253, 255),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Enhanced image carousel with a frame and modern UI
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20), // Rounded corners
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 5,
                    blurRadius: 10,
                    offset: const Offset(0, 3), // Positioning shadow
                  ),
                ],
              ),
              clipBehavior: Clip.hardEdge,
              child: SizedBox(
                height: 200, // Adjust the height as needed
                child: PageView(
                  controller: _pageController,
                  children: [
                    _buildImageWithFrame('assets/Home1.jpeg'),
                    _buildImageWithFrame('assets/Home2.jpg'),
                    _buildImageWithFrame('assets/Home3.jpg'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Welcome ${widget.username}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 20),
            // Existing filters and content
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blueAccent),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                labelText: 'Filter by Stream',
                labelStyle: const TextStyle(color: Colors.blueAccent),
              ),
              value: selectedStream.isEmpty ? null : selectedStream,
              items: [
                'Physical Science stream',
                'Science stream',
                'Commerce stream',
                'Arts stream',
                'Technology stream'
              ].map((stream) {
                return DropdownMenuItem<String>(
                  value: stream,
                  child: Text(stream),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedStream = value ?? '';
                });
              },
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blueAccent),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                labelText: 'Filter by Class ID',
                labelStyle: const TextStyle(color: Colors.blueAccent),
              ),
              onChanged: (value) {
                setState(() {
                  selectedClassId = value;
                });
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Available Classes:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('classes')
                  .where('stream',
                      isEqualTo:
                          selectedStream.isNotEmpty ? selectedStream : null)
                  .where('classId',
                      isEqualTo:
                          selectedClassId.isNotEmpty ? selectedClassId : null)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No classes found.'));
                }

                var classes = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: classes.length,
                  itemBuilder: (context, index) {
                    var classData = classes[index];

                    return Card(
                      elevation: 8,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          '${classData['subjectId']} - ${classData['stream']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xFF34495E),
                          ),
                        ),
                        subtitle: Text(
                          'Class ID: ${classData['classId']}',
                          style: const TextStyle(color: Colors.blueGrey),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ClassDetailsPage(
                                classData: classData,
                                username: widget.username,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Function to create a framed image with modern UI
  Widget _buildImageWithFrame(String assetPath) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white,
          width: 4,
        ),
      ),
      child: Image.asset(
        assetPath,
        fit: BoxFit.cover,
      ),
    );
  }
}

class ClassDetailsPage extends StatelessWidget {
  final QueryDocumentSnapshot classData;
  final String username;

  const ClassDetailsPage(
      {Key? key, required this.classData, required this.username})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Details'),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Image at the top
            Container(
              width: screenWidth,
              height: screenWidth * 0.6, // Aspect ratio of 3:5 (width:height)
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/45.png'),
                  fit: BoxFit.cover, // Ensure image covers the container
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Class ID:', classData['classId']),
                      _buildDetailRow('Subject:', classData['subjectId']),
                      _buildDetailRow('Stream:', classData['stream']),
                      _buildDetailRow('Date:', classData['date']),
                      _buildDetailRow('Day:', classData['day']),
                      _buildDetailRow(
                          'Duration:', '${classData['duration']} minutes'),
                      _buildDetailRow(
                          'Introduction:', classData['introduction']),
                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color.fromARGB(
                                  255, 19, 7, 125), // First color
                              const Color.fromARGB(
                                  255, 9, 68, 230), // Second color
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(
                              10), // Match button's border radius
                        ),
                        child: ElevatedButton(
                          onPressed: () async {
                            // Enroll the user by adding data to ClassEnrollment collection
                            await FirebaseFirestore.instance
                                .collection('ClassEnrollment')
                                .add({
                              'classId': classData['classId'],
                              'date': classData['date'],
                              'day': classData['day'],
                              'duration': classData['duration'],
                              'introduction': classData['introduction'],
                              'stream': classData['stream'],
                              'subjectId': classData['subjectId'],
                              'teacherId': classData[
                                  'teacherId'], // Pass the teacherId as username
                              'studentId':
                                  username, // Replace with actual StudentID from user
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Enrolled successfully!')),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 0, // Remove default elevation
                            backgroundColor: Colors
                                .transparent, // Make button background transparent
                            minimumSize:
                                Size(double.infinity, 50), // Full width
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 201, 194,
                                  194), // Set text color to white
                            ),
                          ),
                          child: const Text(
                            'Enroll',
                            style: TextStyle(
                              color: Colors.white, // Set text color to white
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build each detail row with highlighted text
  Widget _buildDetailRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.lightBlueAccent.withOpacity(0.1), // Highlight color
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.lightBlueAccent),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$label',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 18,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

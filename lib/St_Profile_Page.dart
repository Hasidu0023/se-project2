import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final String username;

  HomePage({Key? key, required this.username}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late PageController _pageController;
  int _currentIndex = 0;
  Timer? _timer;

  final List<String> _notices = [
    "Welcome to EduSync, the largest online education platform.",
    "Offers high-quality education tailored to your needs.",
    "Join us for an enriching learning experience!"
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (_currentIndex < _notices.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }
      _pageController.animateToPage(_currentIndex,
          duration: Duration(milliseconds: 300), curve: Curves.easeIn);
    });
  }

  @override
  Widget build(BuildContext context) {
    final CollectionReference studentRequests =
        FirebaseFirestore.instance.collection('studentRequests');
    final CollectionReference classes =
        FirebaseFirestore.instance.collection('classes');
    final CollectionReference parents =
        FirebaseFirestore.instance.collection('parents');
    final CollectionReference subjects =
        FirebaseFirestore.instance.collection('subjects');
    final CollectionReference teachers =
        FirebaseFirestore.instance.collection('teachers');

    return Scaffold(
      appBar: AppBar(
        title: Text('Student Dashboard'),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Notices section
            Container(
              height: 80,
              color: Colors
                  .lightBlue[100], // Set the background color to light blue
              child: PageView.builder(
                controller: _pageController,
                itemCount: _notices.length,
                itemBuilder: (context, index) {
                  return Container(
                    padding: EdgeInsets.all(16),
                    alignment: Alignment.center,
                    child: Text(
                      _notices[index],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color:
                            const Color.fromARGB(255, 9, 72, 181), // Text color
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 16), // Spacing between notices and other content
            // Display counts of different collections in boxes
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // First row: Classes and Parents
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: _buildCountBox(classes, 'Classes')),
                      SizedBox(width: 16), // Spacing between boxes
                      Expanded(child: _buildCountBox(parents, 'Parents')),
                    ],
                  ),
                  SizedBox(height: 16), // Spacing between rows
                  // Second row: Subjects and Teachers
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: _buildCountBox(subjects, 'Subjects')),
                      SizedBox(width: 16), // Spacing between boxes
                      Expanded(child: _buildCountBox(teachers, 'Teachers')),
                    ],
                  ),
                  SizedBox(height: 16), // Spacing between rows
                  // Third row: Student Requests
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                          child: _buildCountBox(studentRequests, 'Students')),
                    ],
                  ),
                ],
              ),
            ),
            // The existing StreamBuilder for the student profile
            StreamBuilder<QuerySnapshot>(
              stream: studentRequests
                  .where('StudentID', isEqualTo: widget.username)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No student requests found'));
                }

                return ListView(
                  padding: EdgeInsets.all(16),
                  shrinkWrap: true, // Prevents overflow
                  physics: NeverScrollableScrollPhysics(), // Disables scrolling
                  children: snapshot.data!.docs.map((doc) {
                    Map<String, dynamic> data =
                        doc.data() as Map<String, dynamic>;

                    return Container(
                      margin: EdgeInsets.only(bottom: 16),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage:
                                        AssetImage('assets/user.png'),
                                    radius: 40,
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${data['FirstName'] ?? 'N/A'} ${data['LastName'] ?? 'N/A'}',
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          '${data['StudentID'] ?? 'N/A'}',
                                          style: TextStyle(
                                              fontSize: 16, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              Divider(thickness: 1.5),
                              SizedBox(height: 16),
                              Text(
                                'Academic Year: ${data['AcademicYear'] ?? 'N/A'}',
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(
                                'Stream: ${data['Stream'] ?? 'N/A'}',
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(
                                'Gender: ${data['Gender'] ?? 'N/A'}',
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(
                                'Age: ${data['Age'] ?? 'N/A'}',
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(
                                'Student NIC: ${data['StudentNIC'] ?? 'N/A'}',
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(
                                'Email: ${data['Email'] ?? 'N/A'}',
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(
                                'Telephone No: ${data['TelephoneNo'] ?? 'N/A'}',
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(
                                'Address: ${data['Address'] ?? 'N/A'}',
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(
                                'School: ${data['School'] ?? 'N/A'}',
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Parent Details:',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Parent Name: ${data['ParentName'] ?? 'N/A'}',
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(
                                'Parent ID: ${data['ParentID'] ?? 'N/A'}',
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(
                                'Parent Email: ${data['ParentEmail'] ?? 'N/A'}',
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(
                                'Parent Telephone: ${data['ParentTelephone'] ?? 'N/A'}',
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(height: 16),

                              // Add Update Information Button
                              Center(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditPage(
                                          docId: doc.id,
                                          data: data,
                                        ),
                                      ),
                                    );
                                  },
                                  label: const Text(
                                    'Update Information',
                                    style: TextStyle(
                                      color: Colors
                                          .white, // Set text color to white
                                      fontSize: 15, // Set font size to 20
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color.fromARGB(255, 53, 133, 241),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 12),
                                  ),
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountBox(CollectionReference collection, String title) {
    return FutureBuilder<QuerySnapshot>(
      future: collection.get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 100,
            decoration: BoxDecoration(
              color: const Color.fromRGBO(68, 138, 255, 1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        final count = snapshot.data?.docs.length ?? 0;

        return Container(
          height: 100,
          decoration: BoxDecoration(
            color: const Color.fromRGBO(68, 138, 255, 1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class EditPage extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> data;

  EditPage({Key? key, required this.docId, required this.data})
      : super(key: key);

  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController academicYearController;
  late TextEditingController streamController;
  late TextEditingController emailController;
  late TextEditingController telephoneController;
  late TextEditingController genderController;
  late TextEditingController ageController;
  late TextEditingController studentNicController;
  late TextEditingController parentNameController;
  late TextEditingController addressController;
  late TextEditingController schoolController;
  late TextEditingController studentPasswordController;

  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController(text: widget.data['FirstName']);
    lastNameController = TextEditingController(text: widget.data['LastName']);
    academicYearController =
        TextEditingController(text: widget.data['AcademicYear']);
    streamController = TextEditingController(text: widget.data['Stream']);
    emailController = TextEditingController(text: widget.data['Email']);
    telephoneController =
        TextEditingController(text: widget.data['TelephoneNo']);
    genderController = TextEditingController(text: widget.data['Gender']);
    ageController = TextEditingController(text: widget.data['Age']);
    studentNicController =
        TextEditingController(text: widget.data['StudentNIC']);
    parentNameController =
        TextEditingController(text: widget.data['ParentName']);
    addressController = TextEditingController(text: widget.data['Address']);
    schoolController = TextEditingController(text: widget.data['School']);
    studentPasswordController =
        TextEditingController(text: widget.data['StudentPassword']);
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    academicYearController.dispose();
    streamController.dispose();
    emailController.dispose();
    telephoneController.dispose();
    genderController.dispose();
    ageController.dispose();
    studentNicController.dispose();
    parentNameController.dispose();
    addressController.dispose();
    schoolController.dispose();
    studentPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CollectionReference studentRequests =
        FirebaseFirestore.instance.collection('studentRequests');

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: EdgeInsets.all(16.0),
              color: const Color.fromARGB(255, 251, 248, 248),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: AssetImage('assets/user.png'),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: Icon(Icons.camera_alt,
                                color: Colors.blue, size: 20),
                            onPressed: () {
                              // Implement change profile picture functionality
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Update Profile',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            // Profile Form
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildTextField(firstNameController, 'First Name'),
                  buildTextField(lastNameController, 'Last Name'),
                  buildTextField(academicYearController, 'Academic Year'),
                  buildTextField(streamController, 'Stream'),
                  buildTextField(emailController, 'Email'),
                  buildTextField(telephoneController, 'Telephone No'),
                  buildTextField(genderController, 'Gender'),
                  buildTextField(ageController, 'Age'),
                  buildTextField(studentNicController, 'Student NIC'),
                  buildTextField(parentNameController, 'Parent Name'),
                  buildTextField(addressController, 'Address'),
                  buildTextField(schoolController, 'School'),
                  buildTextField(studentPasswordController, 'Student Password',
                      obscureText: true),
                  SizedBox(height: 20),
                  Center(
                    child: Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          studentRequests.doc(widget.docId).update({
                            'FirstName': firstNameController.text,
                            'LastName': lastNameController.text,
                            'AcademicYear': academicYearController.text,
                            'Stream': streamController.text,
                            'Email': emailController.text,
                            'TelephoneNo': telephoneController.text,
                            'Gender': genderController.text,
                            'Age': ageController.text,
                            'StudentNIC': studentNicController.text,
                            'StudentPassword': studentPasswordController.text,
                            'ParentName': parentNameController.text,
                            'Address': addressController.text,
                            'School': schoolController.text,
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Data updated successfully')),
                          );
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 47, 102, 222),
                          padding: EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          textStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 255, 255, 255),
                          ),
                        ),
                        child: Text('Update'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String label,
      {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        obscureText: obscureText,
      ),
    );
  }
}

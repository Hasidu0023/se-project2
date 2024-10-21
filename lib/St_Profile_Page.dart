import 'dart:async'; // Import for Timer

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  final String username;

  HomePage({required this.username});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _imageController = PageController();
  Timer? _timer;

  final List<String> _images = [
    'assets/Home5.jpg',
    'assets/Home6.jpg',
    'assets/Home7.jpg',
  ];
  final List<String> _notices = [
    "Welcome to EduSync, the largest online education platform.",
    "Offers high-quality education tailored to your needs.",
    "Join us for an enriching learning experience!"
  ];

  @override
  void initState() {
    super.initState();
    _startAutoSwipe(); // Start the auto-swipe when the widget is initialized
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when disposing
    _imageController.dispose(); // Dispose the controller
    super.dispose();
  }

  void _startAutoSwipe() {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (_imageController.hasClients) {
        int nextPage = _imageController.page!.toInt() + 1;
        if (nextPage >= _images.length) {
          nextPage = 0; // Loop back to the first image
        }
        _imageController.animateToPage(
          nextPage,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
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
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.black),
            onPressed: () {
              SystemNavigator.pop(); // This will close the app
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        // Wrap the Column with SingleChildScrollView
        child: Column(
          children: [
            // Image Carousel section
            Container(
              height: 200,
              child: PageView.builder(
                controller: _imageController,
                itemCount: _images.length,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(_images[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),

            // Notices section
            Container(
              height: 80,
              color: Colors.lightBlue[100],
              child: PageView.builder(
                controller:
                    PageController(), // Use a new controller for notices
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
                        color: const Color.fromARGB(255, 9, 72, 181),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 10),

            // Display counts of different collections in boxes
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: _buildCountBox(classes, 'Classes')),
                      SizedBox(width: 16),
                      Expanded(child: _buildCountBox(parents, 'Parents')),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: _buildCountBox(subjects, 'Subjects')),
                      SizedBox(width: 16),
                      Expanded(child: _buildCountBox(teachers, 'Teachers')),
                    ],
                  ),
                  SizedBox(height: 16),
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
                  padding: EdgeInsets.symmetric(vertical: 20),
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(), // Disable scrolling
                  children: snapshot.data!.docs.map((doc) {
                    Map<String, dynamic> data =
                        doc.data() as Map<String, dynamic>;

                    return Container(
                      margin: EdgeInsets.only(bottom: 16),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 6,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // User profile and Student Info Section
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
                                            fontSize: 16,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              Divider(thickness: 1.5),
                              SizedBox(height: 16),

                              // Student Information Section
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Academic Year: ${data['AcademicYear'] ?? 'N/A'}',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Stream: ${data['Stream'] ?? 'N/A'}',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Gender: ${data['Gender'] ?? 'N/A'}',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Age: ${data['Age'] ?? 'N/A'}',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Student NIC: ${data['StudentNIC'] ?? 'N/A'}',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Email: ${data['Email'] ?? 'N/A'}',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Telephone No: ${data['TelephoneNo'] ?? 'N/A'}',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'School: ${data['School'] ?? 'N/A'}',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Address: ${data['Address'] ?? 'N/A'}',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  SizedBox(height: 22),

                                  // Parent Details
                                  Text(
                                    'Parent Name: ${data['ParentName'] ?? 'N/A'}',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Parent NIC: ${data['ParentNIC'] ?? 'N/A'}',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Parent Email: ${data['ParentEmail'] ?? 'N/A'}',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Parent Telephone: ${data['ParentTelephone'] ?? 'N/A'}',
                                    style: TextStyle(fontSize: 16),
                                  ),

                                  // Update Profile Button
                                  SizedBox(height: 20),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EditPage(
                                            data: data,
                                            docId: doc.id,
                                            studentData: const {},
                                          ),
                                        ),
                                      );
                                    },
                                    child: Text('Update Profile'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.lightBlueAccent,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 36, vertical: 10),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                  ),
                                ],
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
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 4,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.grey[300],
              ),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasError) {
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 4,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.red[300],
              ),
              child: Center(child: Text('Error: ${snapshot.error}')),
            ),
          );
        }

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 4,
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.lightBlue[200],
            ),
            child: Center(
              child: Text(
                '$title: ${snapshot.data!.docs.length}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
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

  EditPage(
      {Key? key,
      required this.docId,
      required this.data,
      required Map<String, dynamic> studentData})
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

  bool _validateFields() {
    if (firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        academicYearController.text.isEmpty ||
        streamController.text.isEmpty ||
        emailController.text.isEmpty ||
        telephoneController.text.isEmpty ||
        genderController.text.isEmpty ||
        ageController.text.isEmpty ||
        studentNicController.text.isEmpty ||
        parentNameController.text.isEmpty ||
        addressController.text.isEmpty ||
        schoolController.text.isEmpty ||
        studentPasswordController.text.isEmpty) {
      return false;
    }
    return true;
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
                          if (_validateFields()) {
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
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Some fields are empty!')),
                            );
                          }
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
                        child: Text(
                          'Update',
                          style: TextStyle(color: Colors.white),
                        ),
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

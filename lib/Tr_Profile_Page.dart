import 'dart:async'; // Import this for the Timer

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProfilePage extends StatefulWidget {
  final String username;

  ProfilePage({required this.username});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final PageController _imagePageController = PageController();
  final PageController _noticePageController = PageController();
  int _currentImagePage = 0;
  int _currentNoticePage = 0;

  final List<String> notices = [
    "Welcome to EduSync!",
    "Largest online education platform.",
    "Offers high-quality education.",
  ];

  // List of images for the carousel
  final List<String> imagePaths = [
    'assets/Home5.jpg',
    'assets/Home6.jpg',
    'assets/Home7.jpg',
  ];

  Timer? _imageTimer;
  Timer? _noticeTimer;

  @override
  void initState() {
    super.initState();

    // Set up a timer for the image carousel
    _imageTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (_currentImagePage < imagePaths.length - 1) {
        _currentImagePage++;
      } else {
        _currentImagePage = 0;
      }
      _imagePageController.jumpToPage(_currentImagePage);
    });

    // Set up a timer for the notices
    _noticeTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (_currentNoticePage < notices.length - 1) {
        _currentNoticePage++;
      } else {
        _currentNoticePage = 0;
      }
      _noticePageController.jumpToPage(_currentNoticePage);
    });
  }

  @override
  void dispose() {
    _imageTimer?.cancel(); // Cancel the image timer
    _noticeTimer?.cancel(); // Cancel the notice timer
    _imagePageController.dispose(); // Dispose of the image controller
    _noticePageController.dispose(); // Dispose of the notice controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CollectionReference teachersCollection =
        FirebaseFirestore.instance.collection('teachers');
    final CollectionReference classesCollection =
        FirebaseFirestore.instance.collection('classes');
    final CollectionReference parentsCollection =
        FirebaseFirestore.instance.collection('parents');
    final CollectionReference studentRequestsCollection =
        FirebaseFirestore.instance.collection('studentRequests');
    final CollectionReference subjectsCollection =
        FirebaseFirestore.instance.collection('subjects');

    return Scaffold(
      appBar: AppBar(
        title: Text('Teacher Dashboard'),
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
        child: Column(
          children: [
            // Add the image carousel at the top
            Container(
              height: 200, // Set a height for the image carousel
              child: PageView.builder(
                controller: _imagePageController,
                itemCount: imagePaths.length,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(imagePaths[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Add the notices section here
            Container(
              height: 60, // Set a height for the notice section
              width: double.infinity, // Ensures the container takes full width
              child: PageView.builder(
                controller: _noticePageController,
                itemCount: notices.length,
                itemBuilder: (context, index) {
                  return Container(
                    color:
                        Colors.lightBlue[100], // Background color to light blue
                    alignment: Alignment.center, // Center the text vertically
                    child: Text(
                      notices[index],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(
                            255, 19, 87, 195), // Text color
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
            ),

            // Existing content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildCountGrid(
                  classesCollection,
                  parentsCollection,
                  subjectsCollection,
                  teachersCollection,
                  studentRequestsCollection),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: teachersCollection
                  .where('teacherID', isEqualTo: widget.username)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                      child:
                          Text('No teacher found with ID: ${widget.username}'));
                }

                var teacherData =
                    snapshot.data!.docs[0].data() as Map<String, dynamic>;

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 60,
                          backgroundImage: AssetImage('assets/user.png'),
                        ),
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: Text(
                          '${teacherData['fname']} ${teacherData['lname']}',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDetailRow(
                                  'Teacher ID', teacherData['teacherID']),
                              _buildDetailRow('Email', teacherData['email']),
                              _buildDetailRow('NIC', teacherData['nic']),
                              _buildDetailRow(
                                  'Age', teacherData['age'].toString()),
                              _buildDetailRow('Gender', teacherData['gender']),
                              _buildDetailRow(
                                  'Address', teacherData['address']),
                              _buildDetailRow('Qualification',
                                  teacherData['qualification']),
                              _buildDetailRow('Stream', teacherData['stream']),
                              _buildDetailRow(
                                  'Subject Name', teacherData['subjectName']),
                              _buildDetailRow(
                                  'Telephone', teacherData['telephone']),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UpdateProfilePage(
                                  teacherData: teacherData,
                                  docId: snapshot.data!.docs[0].id,
                                ),
                              ),
                            );
                          },
                          icon: Icon(Icons.edit),
                          label: Text('Update Profile'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.blueAccent,
                            padding: EdgeInsets.symmetric(
                                horizontal: 30, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountGrid(
      CollectionReference classesCollection,
      CollectionReference parentsCollection,
      CollectionReference subjectsCollection,
      CollectionReference teachersCollection,
      CollectionReference studentRequestsCollection) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildCountBox('Classes', classesCollection),
            _buildCountBox('Parents', parentsCollection),
          ],
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildCountBox('Subjects', subjectsCollection),
            _buildCountBox('Teachers', teachersCollection),
          ],
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCountBox('Student Requests', studentRequestsCollection,
                isSingle: true),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.black54, fontSize: 16),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountBox(String title, CollectionReference collection,
      {bool isSingle = false}) {
    return FutureBuilder<QuerySnapshot>(
      future: collection.get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error');
        }
        var count = snapshot.data!.size;
        return Expanded(
          child: Card(
            color: const Color.fromRGBO(68, 138, 255, 1),
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    count.toString(),
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    title,
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class UpdateProfilePage extends StatefulWidget {
  final Map<String, dynamic> teacherData;
  final String docId; // Document ID for updating Firestore

  UpdateProfilePage({required this.teacherData, required this.docId});

  @override
  _UpdateProfilePageState createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  late TextEditingController fnameController;
  late TextEditingController lnameController;
  late TextEditingController emailController;
  late TextEditingController nicController;
  late TextEditingController ageController;
  late TextEditingController genderController;
  late TextEditingController addressController;
  late TextEditingController qualificationController;
  late TextEditingController streamController;
  late TextEditingController subjectNameController;
  late TextEditingController telephoneController;

  @override
  void initState() {
    super.initState();
    // Initialize the controllers with the current teacher data
    fnameController = TextEditingController(text: widget.teacherData['fname']);
    lnameController = TextEditingController(text: widget.teacherData['lname']);
    emailController = TextEditingController(text: widget.teacherData['email']);
    nicController = TextEditingController(text: widget.teacherData['nic']);
    ageController =
        TextEditingController(text: widget.teacherData['age'].toString());
    genderController =
        TextEditingController(text: widget.teacherData['gender']);
    addressController =
        TextEditingController(text: widget.teacherData['address']);
    qualificationController =
        TextEditingController(text: widget.teacherData['qualification']);
    streamController =
        TextEditingController(text: widget.teacherData['stream']);
    subjectNameController =
        TextEditingController(text: widget.teacherData['subjectName']);
    telephoneController =
        TextEditingController(text: widget.teacherData['telephone']);
  }

  @override
  void dispose() {
    // Dispose controllers when the widget is removed from the widget tree
    fnameController.dispose();
    lnameController.dispose();
    emailController.dispose();
    nicController.dispose();
    ageController.dispose();
    genderController.dispose();
    addressController.dispose();
    qualificationController.dispose();
    streamController.dispose();
    subjectNameController.dispose();
    telephoneController.dispose();
    super.dispose();
  }

  // Function to update Firestore
  Future<void> _updateTeacherData() async {
    // Check if any field is empty
    if (fnameController.text.isEmpty ||
        lnameController.text.isEmpty ||
        emailController.text.isEmpty ||
        nicController.text.isEmpty ||
        ageController.text.isEmpty ||
        genderController.text.isEmpty ||
        addressController.text.isEmpty ||
        qualificationController.text.isEmpty ||
        streamController.text.isEmpty ||
        subjectNameController.text.isEmpty ||
        telephoneController.text.isEmpty) {
      // Show error message if any field is empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: Some fields are empty')),
      );
      return; // Exit the function if validation fails
    }

    final CollectionReference teachersCollection =
        FirebaseFirestore.instance.collection('teachers');

    try {
      await teachersCollection.doc(widget.docId).update({
        'fname': fnameController.text,
        'lname': lnameController.text,
        'email': emailController.text,
        'nic': nicController.text,
        'age': int.parse(ageController.text),
        'gender': genderController.text,
        'address': addressController.text,
        'qualification': qualificationController.text,
        'stream': streamController.text,
        'subjectName': subjectNameController.text,
        'telephone': telephoneController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile Updated Successfully')));
      Navigator.pop(context); // Go back after updating
    } catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildTextField('First Name', fnameController),
            _buildTextField('Last Name', lnameController),
            _buildTextField('Email', emailController),
            _buildTextField('NIC', nicController),
            _buildTextField('Age', ageController),
            _buildTextField('Gender', genderController),
            _buildTextField('Address', addressController),
            _buildTextField('Qualification', qualificationController),
            _buildTextField('Stream', streamController),
            _buildTextField('Subject Name', subjectNameController),
            _buildTextField('Telephone', telephoneController),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateTeacherData, // Update the data when pressed
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue[800], // White text color
                shadowColor: Colors.blue[300], // Light blue shadow color
                elevation: 5, // Add elevation to the button for shadow effect
                padding: EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12), // Adjust padding
              ),
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}

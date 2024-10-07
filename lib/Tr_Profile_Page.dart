import 'dart:async'; // Import this for the Timer

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  // Change to StatefulWidget to manage state
  final String username;

  ProfilePage({required this.username});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<String> notices = [
    "Welcome to EduSync!",
    "Largest online education platform.",
    "Offers high-quality education.",
  ];

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Set up a timer to change the page every 3 seconds
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (_currentPage < notices.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.jumpToPage(_currentPage);
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
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
        title: Text(
          'Teacher Profile',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1.0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        // Make the entire body scrollable
        child: Column(
          children: [
            // Add the notices section here
            Container(
              height: 100, // Set a height for the notice section
              child: PageView.builder(
                controller: _pageController,
                itemCount: notices.length,
                itemBuilder: (context, index) {
                  return Container(
                    color: Colors.lightBlue[
                        100], // Set the background color to light blue
                    alignment: Alignment.center, // Center the text vertically
                    child: Text(
                      notices[index],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent, // Text color
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
                  context,
                  classesCollection,
                  parentsCollection,
                  subjectsCollection,
                  teachersCollection,
                  studentRequestsCollection),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: teachersCollection
                  .where('teacherID',
                      isEqualTo: widget.username) // Use widget.username
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
                    // Change ListView to Column to allow scrolling
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
      BuildContext context,
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
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildCountBox('Subjects', subjectsCollection),
            _buildCountBox('Teachers', teachersCollection),
          ],
        ),
        SizedBox(height: 16),
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

  Widget _buildCountBox(String label, CollectionReference collection,
      {bool isSingle = false}) {
    return Expanded(
      child: FutureBuilder<QuerySnapshot>(
        future: collection.get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildCountCard(label, '...');
          }
          if (snapshot.hasError) {
            return _buildCountCard(label, 'Error');
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildCountCard(label, '0');
          }
          return _buildCountCard(label, snapshot.data!.size.toString());
        },
      ),
    );
  }

  Widget _buildCountCard(String label, String count) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: const Color.fromRGBO(68, 138, 255, 1),
      child: Container(
        height: 110,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              count,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
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

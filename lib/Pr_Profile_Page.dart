import 'dart:async'; // Import for Timer

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProfilePage extends StatefulWidget {
  final String username;

  ProfilePage({Key? key, required this.username}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final PageController _imagePageController = PageController();
  final PageController _noticePageController = PageController();
  late Timer _imageTimer;
  late Timer _noticeTimer;

  final List<String> notices = [
    "Welcome to EduSync, the largest online education platform!",
    "EduSync offers high-quality education tailored for you.",
    "Join thousands of learners achieving their goals with us."
  ];

  final List<String> imagePaths = [
    'assets/Home5.jpg',
    'assets/Home6.jpg',
    'assets/Home7.jpg',
  ];

  @override
  void initState() {
    super.initState();

    // Timer to change the images every 5 seconds
    _imageTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (_imagePageController.hasClients) {
        _imagePageController.nextPage(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });

    // Timer to change the notices every 5 seconds
    _noticeTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (_noticePageController.hasClients) {
        _noticePageController.nextPage(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _imageTimer.cancel();
    _noticeTimer.cancel();
    _imagePageController.dispose();
    _noticePageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CollectionReference parentCollection =
        FirebaseFirestore.instance.collection('studentRequests');

    // Define the collections to be counted
    final List<Map<String, dynamic>> collections = [
      {'name': 'Classes', 'collection': 'classes'},
      {'name': 'Parents', 'collection': 'parents'},
      {'name': 'Student Requests', 'collection': 'studentRequests'},
      {'name': 'Subjects', 'collection': 'subjects'},
      {'name': 'Teachers', 'collection': 'teachers'},
    ];

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(40.0), // Set height of AppBar
        child: AppBar(
          title: Text('Parent Dashboard'),
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
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Minimize column height
            children: [
              SizedBox(height: 10),

              // Image Slider Section
              Container(
                height: 200, // Adjust height as needed
                child: PageView.builder(
                  controller: _imagePageController,
                  itemCount: imagePaths.length,
                  itemBuilder: (context, index) {
                    return Image.asset(
                      imagePaths[index],
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),

              SizedBox(height: 36),

              // Notice Section
              Container(
                height: 50, // Adjust height as needed
                color: const Color.fromARGB(
                    255, 164, 224, 250), // Light blue color
                child: PageView.builder(
                  controller: _noticePageController,
                  itemCount: notices.length,
                  itemBuilder: (context, index) {
                    return Center(
                      child: Text(
                        notices[index],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 23, 141, 237),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 16),
              // Display the boxes with document counts in a grid
              buildInfoGrid(collections.sublist(0, collections.length - 1)),
              SizedBox(height: 16),
              // Full-width box for the last item
              buildFullWidthBox(collections.last),
              SizedBox(height: 50),
              // Profile Information Section
              StreamBuilder<QuerySnapshot>(
                stream: parentCollection
                    .where('ParentID', isEqualTo: widget.username)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No data found'));
                  }

                  return ListView(
                    padding: EdgeInsets.all(16.0),
                    shrinkWrap: true,
                    physics:
                        NeverScrollableScrollPhysics(), // Prevent inner scroll
                    children: snapshot.data!.docs.map((doc) {
                      Map<String, dynamic> data =
                          doc.data() as Map<String, dynamic>;

                      return Container(
                        // Wrap the entire column in a Container
                        width: double.infinity, // Set width to maximum
                        padding: EdgeInsets.all(
                            16.0), // Add padding around the container
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.center, // Center the column
                          children: [
                            // Profile Picture Section
                            CircleAvatar(
                              radius: 60,
                              backgroundImage: AssetImage('assets/user.png'),
                            ),
                            SizedBox(height: 20),

                            // Parent Information Card
                            Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    Text(
                                      '${data['ParentName'] ?? 'N/A'}',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      'Parent ID: ${data['ParentID'] ?? 'N/A'}',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.grey),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            Divider(thickness: 1, height: 40),

                            // Student Information Section
                            buildProfileSection("Student Information", [
                              'Student ID: ${data['StudentID'] ?? 'N/A'}',
                              'First Name: ${data['FirstName'] ?? 'N/A'}',
                              'Last Name: ${data['LastName'] ?? 'N/A'}',
                              'Academic Year: ${data['AcademicYear'] ?? 'N/A'}',
                              'Stream: ${data['Stream'] ?? 'N/A'}',
                              'Gender: ${data['Gender'] ?? 'N/A'}',
                              'Age: ${data['Age'] ?? 'N/A'}',
                              'Student NIC: ${data['StudentNIC'] ?? 'N/A'}',
                              'Email: ${data['Email'] ?? 'N/A'}',
                              'Telephone: ${data['TelephoneNo'] ?? 'N/A'}',
                            ]),
                            SizedBox(height: 20),

                            // Parent Information Section
                            buildProfileSection("Parent Information", [
                              'Parent NIC: ${data['ParentNIC'] ?? 'N/A'}',
                              'Parent Email: ${data['ParentEmail'] ?? 'N/A'}',
                              'Parent Telephone: ${data['ParentTelephone'] ?? 'N/A'}',
                            ]),

                            // Update Button
                            SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UpdatePage(
                                      docId: doc.id,
                                      currentData: data,
                                    ),
                                  ),
                                );
                              },
                              icon: Icon(Icons.edit, color: Colors.white),
                              label: Text(
                                'Update Information',
                                style: TextStyle(
                                    color: Colors.white), // White text color
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color.fromARGB(
                                    255, 63, 136, 237), // Button color
                                padding: EdgeInsets.symmetric(
                                    vertical: 15,
                                    horizontal: 30), // Button padding
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Method to build info grid for the collection counts
  Widget buildInfoGrid(List<Map<String, dynamic>> collections) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5, // Aspect ratio for grid items
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
      ),
      shrinkWrap: true, // Prevents the grid from taking all available space
      physics: NeverScrollableScrollPhysics(), // Disable grid scroll
      itemCount: collections.length,
      itemBuilder: (context, index) {
        return FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection(collections[index]['collection'])
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final count = snapshot.data!.docs.length;

            return Container(
              decoration: BoxDecoration(
                color: const Color.fromRGBO(68, 138, 255, 1),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      collections[index]['name'],
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 255, 255, 255),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Method to build full-width box for a single item
  Widget buildFullWidthBox(Map<String, dynamic> collection) {
    return FutureBuilder<QuerySnapshot>(
      future:
          FirebaseFirestore.instance.collection(collection['collection']).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final count = snapshot.data!.docs.length;

        return Container(
          width: double.infinity, // Full width container
          decoration: BoxDecoration(
            color: const Color.fromRGBO(68, 138, 255, 1),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  collection['name'],
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Method to build profile sections
  Widget buildProfileSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Text(
                item,
                style: TextStyle(fontSize: 16),
              ),
            )),
      ],
    );
  }
}

// UpdatePage is another screen where you can update profile information

// UpdatePage class (as per your requirement)
// Ensure to import required packages and implement the update functionality.

class UpdatePage extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> currentData;

  UpdatePage({Key? key, required this.docId, required this.currentData})
      : super(key: key);

  @override
  _UpdatePageState createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController academicYearController;
  late TextEditingController streamController;
  late TextEditingController genderController;
  late TextEditingController ageController;
  late TextEditingController studentNICController;
  late TextEditingController emailController;
  late TextEditingController telephoneController;
  late TextEditingController parentNameController;
  late TextEditingController parentNICController;
  late TextEditingController parentEmailController;
  late TextEditingController parentTelephoneController;

  @override
  void initState() {
    super.initState();
    firstNameController =
        TextEditingController(text: widget.currentData['FirstName']);
    lastNameController =
        TextEditingController(text: widget.currentData['LastName']);
    academicYearController =
        TextEditingController(text: widget.currentData['AcademicYear']);
    streamController =
        TextEditingController(text: widget.currentData['Stream']);
    genderController =
        TextEditingController(text: widget.currentData['Gender']);
    ageController = TextEditingController(text: widget.currentData['Age']);
    studentNICController =
        TextEditingController(text: widget.currentData['StudentNIC']);
    emailController = TextEditingController(text: widget.currentData['Email']);
    telephoneController =
        TextEditingController(text: widget.currentData['TelephoneNo']);
    parentNameController =
        TextEditingController(text: widget.currentData['ParentName']);
    parentNICController =
        TextEditingController(text: widget.currentData['ParentNIC']);
    parentEmailController =
        TextEditingController(text: widget.currentData['ParentEmail']);
    parentTelephoneController =
        TextEditingController(text: widget.currentData['ParentTelephone']);
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    academicYearController.dispose();
    streamController.dispose();
    genderController.dispose();
    ageController.dispose();
    studentNICController.dispose();
    emailController.dispose();
    telephoneController.dispose();
    parentNameController.dispose();
    parentNICController.dispose();
    parentEmailController.dispose();
    parentTelephoneController.dispose();
    super.dispose();
  }

  Future<void> updateData() async {
    // Check for empty fields
    if (firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        academicYearController.text.isEmpty ||
        streamController.text.isEmpty ||
        genderController.text.isEmpty ||
        ageController.text.isEmpty ||
        studentNICController.text.isEmpty ||
        emailController.text.isEmpty ||
        telephoneController.text.isEmpty ||
        parentNameController.text.isEmpty ||
        parentNICController.text.isEmpty ||
        parentEmailController.text.isEmpty ||
        parentTelephoneController.text.isEmpty) {
      // Show a SnackBar message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all fields.'),
          duration: Duration(seconds: 2),
        ),
      );
      return; // Stop further execution
    }

    final CollectionReference parentCollection =
        FirebaseFirestore.instance.collection('studentRequests');

    await parentCollection.doc(widget.docId).update({
      'FirstName': firstNameController.text,
      'LastName': lastNameController.text,
      'AcademicYear': academicYearController.text,
      'Stream': streamController.text,
      'Gender': genderController.text,
      'Age': ageController.text,
      'StudentNIC': studentNICController.text,
      'Email': emailController.text,
      'TelephoneNo': telephoneController.text,
      'ParentName': parentNameController.text,
      'ParentNIC': parentNICController.text,
      'ParentEmail': parentEmailController.text,
      'ParentTelephone': parentTelephoneController.text,
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Profile'),
        backgroundColor: Colors.lightBlue,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Profile Picture Section
              Center(
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: AssetImage('assets/user.png'),
                  backgroundColor:
                      Colors.grey[200], // Light grey background for contrast
                ),
              ),
              SizedBox(height: 20),

              // FirstName and LastName Row
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: firstNameController,
                      decoration: InputDecoration(
                        labelText: 'First Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: lastNameController,
                      decoration: InputDecoration(
                        labelText: 'Last Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Other Fields
              buildTextField(academicYearController, 'Academic Year'),
              SizedBox(height: 20),
              buildTextField(streamController, 'Stream'),
              SizedBox(height: 20),
              buildTextField(genderController, 'Gender'),
              SizedBox(height: 20),
              buildTextField(ageController, 'Age'),
              SizedBox(height: 20),
              buildTextField(studentNICController, 'Student NIC'),
              SizedBox(height: 20),
              buildTextField(emailController, 'Email'),
              SizedBox(height: 20),
              buildTextField(telephoneController, 'Telephone No'),
              SizedBox(height: 20),
              buildTextField(parentNameController, 'Parent Name'),
              SizedBox(height: 20),
              buildTextField(parentNICController, 'Parent NIC'),
              SizedBox(height: 20),
              buildTextField(parentEmailController, 'Parent Email'),
              SizedBox(height: 20),
              buildTextField(parentTelephoneController, 'Parent Telephone'),
              SizedBox(height: 30),

              // Save Button
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color.fromARGB(255, 110, 152, 235), // First color
                      const Color.fromARGB(255, 23, 13, 208), // Second color
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(
                      10.0), // Match the button's border radius
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: updateData,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      backgroundColor: Colors
                          .transparent, // Make button background transparent
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        color: Colors.white, // Set text color to white
                        fontSize: 20, // Set font size to 20
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to create text fields with consistent style
  Widget buildTextField(TextEditingController controller, String labelText) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }
}

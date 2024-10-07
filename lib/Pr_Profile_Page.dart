import 'dart:async'; // Import for Timer

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  // Change to StatefulWidget
  final String username;

  ProfilePage({Key? key, required this.username}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final PageController _pageController = PageController();
  late Timer _timer;

  final List<String> notices = [
    "Welcome to EduSync, the largest online education platform!",
    "EduSync offers high-quality education tailored for you.",
    "Join thousands of learners achieving their goals with us."
  ];

  @override
  void initState() {
    super.initState();
    // Timer to change the page every 5 seconds
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        _pageController.nextPage(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
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
        preferredSize: Size.fromHeight(50.0), // Set height of AppBar
        child: AppBar(
          title: Text(
            "Parent Dashboard",
            style: TextStyle(
              fontSize: 25.0, // Set the font size
              fontWeight: FontWeight.bold, // Set the font weight
              color:
                  const Color.fromARGB(255, 10, 11, 11), // Set the text color
              letterSpacing: 1.5, // Adjust letter spacing
            ),
          ),
          backgroundColor: const Color.fromARGB(
              255, 253, 254, 255), // Set AppBar color to light blue
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              SizedBox(height: 10),

              // Notice Section
              Container(
                height: 50, // Adjust height as needed
                color: const Color.fromARGB(
                    255, 164, 224, 250), // Light blue color
                child: PageView.builder(
                  controller: _pageController,
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
              SizedBox(height: 20),
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
                        child: Column(
                          children: [
                            // Profile Picture Section
                            CircleAvatar(
                              radius: 60,
                              backgroundImage: AssetImage('assets/user.png'),
                            ),
                            SizedBox(height: 20),

                            // Parent Information
                            Text(
                              '${data['ParentName'] ?? 'N/A'}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign:
                                  TextAlign.center, // Center align the text
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Parent ID: ${data['ParentID'] ?? 'N/A'}',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                              textAlign:
                                  TextAlign.center, // Center align the text
                            ),
                            Divider(thickness: 1, height: 40),

                            // Student Information
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

                            SizedBox(height: 10),

                            // Parent Information
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
                              icon: Icon(Icons.edit,
                                  color:
                                      const Color.fromARGB(255, 246, 247, 253)),
                              label: Text(
                                'Update Information',
                                style: TextStyle(
                                  color: const Color.fromARGB(
                                      255, 250, 245, 245), // White text color
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 28, 115, 237),
                                padding: EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 60),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to build the grid for the first few boxes
  Widget buildInfoGrid(List<Map<String, dynamic>> collections) {
    return GridView.count(
      crossAxisCount: 2, // 2 boxes per row
      shrinkWrap: true,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 2, // Adjust height of the boxes
      physics: NeverScrollableScrollPhysics(),
      children: collections.map((collection) {
        return FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection(collection['collection'])
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error'));
            }

            // Get document count
            int count = snapshot.hasData ? snapshot.data!.docs.length : 0;

            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              color: const Color.fromRGBO(68, 138, 255, 1),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      collection['name'],
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '$count',
                      style: TextStyle(
                          fontSize: 30,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  // Function to build the full-width box for the last item
  Widget buildFullWidthBox(Map<String, dynamic> collection) {
    return FutureBuilder<QuerySnapshot>(
      future:
          FirebaseFirestore.instance.collection(collection['collection']).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error'));
        }

        // Get document count
        int count = snapshot.hasData ? snapshot.data!.docs.length : 0;

        return Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          color: const Color.fromRGBO(68, 138, 255, 1),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    collection['name'],
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '$count',
                    style: TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Function to build a section with title and information
  Widget buildProfileSection(String title, List<String> info) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          ...info.map((line) => Text(line)).toList(),
        ],
      ),
    );
  }
}

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
              )
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

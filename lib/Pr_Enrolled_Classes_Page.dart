import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EnrolledClassesPage extends StatefulWidget {
  final String username;

  const EnrolledClassesPage({Key? key, required this.username})
      : super(key: key);

  @override
  _EnrolledClassesPageState createState() => _EnrolledClassesPageState();
}

class _EnrolledClassesPageState extends State<EnrolledClassesPage> {
  String studentID = '';
  bool isLoading = true;
  List<DocumentSnapshot> classes = [];

  @override
  void initState() {
    super.initState();
    fetchStudentID();
  }

  Future<void> fetchStudentID() async {
    try {
      // Query Firestore to find the document where ParentID matches the username
      final querySnapshot = await FirebaseFirestore.instance
          .collection('studentRequests')
          .where('ParentID', isEqualTo: widget.username)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Get the StudentID from the document
        setState(() {
          studentID = querySnapshot.docs.first['StudentID'];
        });

        // Fetch the enrolled classes for the StudentID
        fetchClasses();
      } else {
        setState(() {
          studentID = 'Student ID not found';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        studentID = 'Error fetching Student ID';
        isLoading = false;
      });
      print('Error fetching data: $e');
    }
  }

  Future<void> fetchClasses() async {
    try {
      // Query Firestore to fetch classes for the StudentID from ClassEnrollment table
      final classQuerySnapshot = await FirebaseFirestore.instance
          .collection('ClassEnrollment')
          .where('studentId', isEqualTo: studentID)
          .get();

      setState(() {
        classes = classQuerySnapshot.docs;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching classes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          ' Your Enrolled Classes',
          style: TextStyle(
            color: const Color.fromARGB(255, 2, 2, 2),
            fontSize: 25, // Increased font size for better visibility
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: Column(
        children: [
          // Add the message banner at the top of the page
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
                vertical: 20.0, horizontal: 16.0), // Increase vertical padding
            decoration: BoxDecoration(
              color: const Color.fromRGBO(
                  68, 138, 255, 1), // Modern color for the banner
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8, // Slightly increased blur radius
                  offset: Offset(0, 4), // Increased vertical offset
                ),
              ],
            ),
            margin: const EdgeInsets.all(16.0), // Keep margin consistent
            child: const Text(
              'Students must provide accurate info, respect privacy, engage respectfully, follow rules, avoid inappropriate language, and submit work on time.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16, // Increased font size for better visibility
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // The rest of the content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: isLoading
                    ? const CircularProgressIndicator()
                    : classes.isEmpty
                        ? Text(
                            'No classes found for Student ID: $studentID',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.grey),
                            textAlign: TextAlign.center,
                          )
                        : ListView.builder(
                            itemCount: classes.length,
                            itemBuilder: (context, index) {
                              final classData =
                                  classes[index].data() as Map<String, dynamic>;
                              final className =
                                  classData['classId'] ?? 'Unnamed Class';

                              return Card(
                                elevation: 5,
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: ListTile(
                                  title: Text(
                                    className,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle:
                                      Text('Class ID: ${classData['classId']}'),
                                  onTap: () {
                                    // Navigate to class details page when a class is clicked
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ClassDetailsPage(
                                          classData: classData,
                                          username: widget
                                              .username, // Pass the username
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ClassDetailsPage extends StatefulWidget {
  final Map<String, dynamic> classData;
  final String username;

  const ClassDetailsPage({
    Key? key,
    required this.classData,
    required this.username,
  }) : super(key: key);

  @override
  _ClassDetailsPageState createState() => _ClassDetailsPageState();
}

class _ClassDetailsPageState extends State<ClassDetailsPage> {
  Map<String, dynamic> classAccessData = {};
  Map<String, dynamic> classDetails = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchClassDetails(widget.classData['classId']);
    _fetchClassAccessData(widget.classData['classId']);
  }

  Future<void> _fetchClassDetails(String classId) async {
    final doc = await FirebaseFirestore.instance
        .collection('classes') // Ensure this is the correct collection name
        .doc(classId)
        .get();

    if (doc.exists) {
      setState(() {
        classDetails = doc.data() ?? {};
      });
    } else {
      print("Class details not found for classId: $classId");
    }
  }

  Future<void> _fetchClassAccessData(String classId) async {
    final doc = await FirebaseFirestore.instance
        .collection('Class_access_areas.')
        .doc(classId)
        .get();

    if (doc.exists) {
      setState(() {
        classAccessData = doc.data() ?? {};
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value?.toString() ?? 'N/A'), // Display the value
        ],
      ),
    );
  }

  Widget _buildLinkSection(String title, List<String> links) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 36, 7, 94)),
              ),
              const SizedBox(height: 10),
              for (var link in links)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    link,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.launch, color: Colors.blueAccent),
                    onPressed: () async {
                      final Uri url = Uri.parse(link);
                      if (await canLaunch(url.toString())) {
                        await launch(url.toString(), forceSafariVC: false);
                      } else {
                        print("Could not launch $url");
                      }
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButton(String title, VoidCallback onPressed) {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15.0),
          backgroundColor: Colors.lightBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        child: Text(
          title,
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.classData['ClassName'] ?? 'Class Details',
          style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: const Color.fromARGB(255, 9, 9, 9)),
        ),
        backgroundColor: Colors.lightBlue,
        elevation: 5,
        actions: [
          Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 13, 10, 169),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.chat),
              color: Colors.white,
              iconSize: 35,
              onPressed: () {
                _navigateToChatPage(context);
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enrolled Classes Details',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 60, 61, 63),
              ),
            ),
            SizedBox(height: 20),
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Class ID:', classDetails['classId']),
                    _buildDetailRow('Teacher ID:', classDetails['teacherId']),
                    _buildDetailRow('Subject ID:', classDetails['subjectId']),
                    _buildDetailRow('Date:', classDetails['date']),
                    _buildDetailRow('Day:', classDetails['day']),
                    _buildDetailRow('Duration:', classDetails['duration']),
                    _buildDetailRow(
                        'Introduction:', classDetails['introduction']),
                    _buildDetailRow('Stream:', classDetails['stream']),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            // Displaying additional links fetched from Firestore
            if (isLoading)
              Center(child: CircularProgressIndicator())
            else if (classAccessData.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLinkSection(
                    'Other Links',
                    List<String>.from(classAccessData['other links'] ?? []),
                  ),
                ],
              )
            else
              const Text('No additional information available'),

            // Navigation buttons
            SizedBox(height: 20),
            _buildNavigationButton(
              'Payment',
              () => _navigateToPaymentPage(context),
            ),
            SizedBox(height: 10), // Space between buttons
            _buildNavigationButton(
              'Attendance',
              () => _navigateToAttendancePage(context),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToChatPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          username: widget.username,
          classId: widget.classData['classId'] ?? 'Unknown',
        ),
      ),
    );
  }

  void _navigateToPaymentPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentPage(
          username: widget.username,
          classId: widget.classData['classId'],
        ),
      ),
    );
  }

  void _navigateToAttendancePage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AttendancePage(
          username: widget.username,
          classId: widget.classData['classId'],
        ),
      ),
    );
  }
}

class AttendancePage extends StatefulWidget {
  final String classId;
  final String username;

  const AttendancePage(
      {Key? key, required this.classId, required this.username})
      : super(key: key);

  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  String studentp = ''; // Variable to hold the StudentID value
  bool isLoadingStudentID =
      true; // To show a loading indicator while fetching student ID
  bool isLoadingAttendance =
      true; // To show a loading indicator while fetching attendance
  List<Map<String, dynamic>> attendanceRecords =
      []; // List to hold attendance records

  // Date and Time Range filters
  String selectedDate = ''; // Variable to store the input date for filtering
  String startTime = ''; // Start time for filtering
  String endTime = ''; // End time for filtering

  @override
  void initState() {
    super.initState();
    fetchStudentID();
  }

  Future<void> fetchStudentID() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('studentRequests')
          .where('ParentID', isEqualTo: widget.username)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var studentData = snapshot.docs.first.data() as Map<String, dynamic>;
        setState(() {
          studentp = studentData['StudentID'] ?? 'Unknown';
          isLoadingStudentID = false;
        });
        fetchAttendanceRecords(
            studentp); // Fetch attendance after getting the StudentID
      } else {
        setState(() {
          studentp = 'No student found';
          isLoadingStudentID = false;
        });
      }
    } catch (e) {
      setState(() {
        studentp = 'Error fetching student';
        isLoadingStudentID = false;
      });
      print('Error fetching StudentID: $e');
    }
  }

  Future<void> fetchAttendanceRecords(String studentID) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('attendance')
          .where('StudentID', isEqualTo: studentID)
          .where('classId', isEqualTo: widget.classId)
          .get();

      List<Map<String, dynamic>> records = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      if (selectedDate.isNotEmpty) {
        records =
            records.where((record) => record['Date'] == selectedDate).toList();
      }

      if (startTime.isNotEmpty && endTime.isNotEmpty) {
        records = records
            .where((record) =>
                record['Time'].compareTo(startTime) >= 0 &&
                record['Time'].compareTo(endTime) <= 0)
            .toList();
      }

      setState(() {
        attendanceRecords = records;
        isLoadingAttendance = false;
      });
    } catch (e) {
      setState(() {
        attendanceRecords = [];
        isLoadingAttendance = false;
      });
      print('Error fetching attendance records: $e');
    }
  }

  void handleSearch() {
    setState(() {
      isLoadingAttendance = true;
    });
    fetchAttendanceRecords(studentp);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance'),
        backgroundColor: const Color.fromARGB(255, 60, 187, 246),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attendance Details',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            isLoadingStudentID
                ? Center(child: CircularProgressIndicator())
                : Text('Student ID: $studentp',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600])),
            SizedBox(height: 20),
            _buildFilterSection(),
            SizedBox(height: 20),
// Search Button
            SizedBox(
              width: double
                  .infinity, // Optional: Set the button width to fill the available space
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color.fromARGB(255, 24, 143, 198), // First color
                      const Color.fromARGB(255, 73, 164, 155), // Second color
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(
                      12), // Match the button's border radius
                ),
                child: ElevatedButton.icon(
                  onPressed: handleSearch,
                  icon: const Icon(
                    Icons.search,
                    color: Colors.white, // Set icon color to white
                  ),
                  label: Text(
                    'Search',
                    style: const TextStyle(
                      color: Colors.white, // Set text color to white
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors
                        .transparent, // Make the button's background transparent
                    padding:
                        EdgeInsets.symmetric(vertical: 14.0, horizontal: 24.0),
                  ),
                ),
              ),
            ),

            SizedBox(height: 20),
            isLoadingAttendance
                ? Center(child: CircularProgressIndicator())
                : _buildAttendanceRecords(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          decoration: InputDecoration(
            labelText: 'Filter by Date (YYYY-MM-DD)',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.date_range),
          ),
          onChanged: (value) {
            selectedDate = value;
          },
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Start Time (HH:MM)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.access_time),
                ),
                onChanged: (value) {
                  startTime = value;
                },
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'End Time (HH:MM)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.access_time_outlined),
                ),
                onChanged: (value) {
                  endTime = value;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAttendanceRecords() {
    return attendanceRecords.isNotEmpty
        ? Expanded(
            child: ListView.builder(
              itemCount: attendanceRecords.length,
              itemBuilder: (context, index) {
                var record = attendanceRecords[index];
                return Card(
                  elevation: 4,
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Date: ${record['Date']}',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600)),
                        Text('Time: ${record['Time']}',
                            style: TextStyle(color: Colors.grey[600])),
                        SizedBox(height: 10),
                        Text('Class ID: ${record['classId']}',
                            style: TextStyle(color: Colors.grey[700])),
                        Text('Student ID: ${record['StudentID']}',
                            style: TextStyle(color: Colors.grey[700])),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        : Center(child: Text('No attendance records found.'));
  }
}

class ChatPage extends StatefulWidget {
  final String username;
  final String classId;

  const ChatPage({
    required this.username,
    required this.classId,
  });

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();

  void _sendMessage() async {
    if (_messageController.text.isEmpty) {
      return;
    }

    await FirebaseFirestore.instance.collection('chat_St_Class').add({
      'Message': _messageController.text,
      'StudentID': widget.username,
      'classId': widget.classId,
      'de': widget.username, // 'de' is also set to username value
      'timestamp': FieldValue.serverTimestamp(), // Optional: Add a timestamp
    });

    _messageController.clear(); // Clear the input field after sending
  }

  void _deleteMessage(String documentId) async {
    await FirebaseFirestore.instance
        .collection('chat_St_Class')
        .doc(documentId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chat_St_Class')
                  .where('StudentID', isEqualTo: widget.username)
                  .where('classId', isEqualTo: widget.classId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No messages available.'));
                }

                var messages = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var messageData =
                        messages[index].data() as Map<String, dynamic>?;

                    if (messageData == null) {
                      return ListTile(
                        title: Text('No message data available'),
                      );
                    }

                    String message = messageData['Message'] ?? 'No message';
                    String messageId = messages[index].id; // Get document ID

                    return Card(
                      margin:
                          EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                      elevation: 2,
                      child: ListTile(
                        title: Text(
                          message,
                          style: TextStyle(fontSize: 16),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () {
                            _deleteMessage(messageId); // Delete the message
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Enter your message',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide(color: Colors.lightBlueAccent),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                    ),
                  ),
                ),
                SizedBox(
                    width: 8.0), // Add spacing between TextField and IconButton
                IconButton(
                  icon: Icon(Icons.send, color: Colors.lightBlueAccent),
                  onPressed: _sendMessage,
                  padding: EdgeInsets.all(0),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentPage extends StatefulWidget {
  final String classId;
  final String username;

  PaymentPage({required this.classId, required this.username});

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final TextEditingController paymentAmountController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController expirationDateController =
      TextEditingController();
  final TextEditingController cvvController = TextEditingController();

  String selectedMonth = 'January';
  final List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  List<Map<String, dynamic>> paymentHistory = [];

  @override
  void initState() {
    super.initState();
    fetchPaymentHistory();
  }

  Future<void> _savePaymentData(BuildContext context) async {
    // Validate inputs
    if (paymentAmountController.text.isEmpty ||
        fullNameController.text.isEmpty ||
        cardNumberController.text.isEmpty ||
        expirationDateController.text.isEmpty ||
        cvvController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all fields before submitting.'),
          backgroundColor: Colors.red,
        ),
      );
      return; // Exit the function if any field is empty
    }

    try {
      // Fetch StudentID from Firestore where ParentID matches username
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('studentRequests')
          .where('ParentID', isEqualTo: widget.username)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var studentData = snapshot.docs.first.data() as Map<String, dynamic>;
        String studentID = studentData['StudentID'];

        // Prepare payment data with the fetched StudentID
        final paymentData = {
          'classId': widget.classId,
          'username': studentID, // Assign StudentID here
          'paymentAmount': paymentAmountController.text,
          'month': selectedMonth,
          'fullName': fullNameController.text,
          'cardNumber': cardNumberController.text,
          'expirationDate': expirationDateController.text,
          'cvv': cvvController.text,
        };

        // Save payment data to Firestore
        await FirebaseFirestore.instance.collection('payment').add(paymentData);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment Successful!')),
        );

        // Clear form fields
        paymentAmountController.clear();
        fullNameController.clear();
        cardNumberController.clear();
        expirationDateController.clear();
        cvvController.clear();

        // Refresh payment history
        fetchPaymentHistory();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('No matching student found for the provided ParentID.'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> fetchPaymentHistory() async {
    try {
      // Fetch StudentID from Firestore where ParentID matches username
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('studentRequests')
          .where('ParentID', isEqualTo: widget.username)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var studentData = snapshot.docs.first.data() as Map<String, dynamic>;
        String studentID = studentData['StudentID'];

        // Fetch payment history where classId and studentID match
        QuerySnapshot paymentSnapshot = await FirebaseFirestore.instance
            .collection('payment')
            .where('classId', isEqualTo: widget.classId)
            .where('username', isEqualTo: studentID)
            .get();

        setState(() {
          paymentHistory = paymentSnapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error fetching payment history: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Page'),
        backgroundColor: Colors.lightBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Payment Form
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Payment Amount
                      TextField(
                        controller: paymentAmountController,
                        decoration: InputDecoration(
                          labelText: 'Payment Amount',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 20),

                      // Select Month
                      DropdownButtonFormField<String>(
                        value: selectedMonth,
                        decoration: InputDecoration(
                          labelText: 'Select Month',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            selectedMonth = value!;
                          });
                        },
                        items: months
                            .map((month) => DropdownMenuItem(
                                  child: Text(month),
                                  value: month,
                                ))
                            .toList(),
                      ),
                      SizedBox(height: 20),

                      // Full Name
                      TextField(
                        controller: fullNameController,
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 20),

                      // Card Number
                      TextField(
                        controller: cardNumberController,
                        decoration: InputDecoration(
                          labelText: 'Card Number',
                          hintText: '1234 5678 9012 3456',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 20),

                      // Expiration Date and CVV
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: expirationDateController,
                              decoration: InputDecoration(
                                labelText: 'Expiration Date',
                                hintText: 'MM/YY',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.datetime,
                            ),
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            child: TextField(
                              controller: cvvController,
                              decoration: InputDecoration(
                                labelText: 'CVV/CVC',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 30),

// Submit Payment Button
                      SizedBox(
                        width: double.infinity,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color.fromARGB(255, 107, 191, 230),
                                Colors.blueAccent
                              ], // Mix of two colors
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(
                                12), // Match the button's border radius
                          ),
                          child: ElevatedButton(
                            onPressed: () => _savePaymentData(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors
                                  .transparent, // Make the button's background transparent
                              padding: EdgeInsets.symmetric(
                                  horizontal: 50, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Submit Payment',
                              style: TextStyle(
                                color: Colors.white, // Set text color to white
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),

              // Payment History
              Text(
                'Payment History',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),

              // Display payment history
              if (paymentHistory.isEmpty)
                Text('No payments found for this class.')
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: paymentHistory.length,
                  itemBuilder: (context, index) {
                    final payment = paymentHistory[index];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: EdgeInsets.symmetric(vertical: 5),
                      child: ListTile(
                        title: Text(
                          'Full Name: ${payment['fullName']}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Month: ${payment['month']}'),
                            Text('Payment Amount: ${payment['paymentAmount']}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

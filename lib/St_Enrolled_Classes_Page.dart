import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AssignmentsPage extends StatelessWidget {
  final String username;

  const AssignmentsPage({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enrolled Classes'),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: SingleChildScrollView(
        // Wrap the entire content in a ScrollView
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, $username',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Your Enrolled Classes:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 10),

              // Notice section for Classroom Rules
              Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 169, 217, 240),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16.0),
                margin: const EdgeInsets.only(bottom: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Classroom Rules',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• Respect others and their opinions.\n'
                      '• Be punctual and attend classes regularly.\n'
                      '• Participate actively in discussions.\n'
                      '• Bullying prevention is crucial; support each other.\n'
                      '• Maintain cleanliness and seek help when needed.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              // Expanded list of enrolled classes
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('ClassEnrollment')
                    .where('studentId', isEqualTo: username)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                        child: Text('No Enrolled classes found.'));
                  }

                  final classes = snapshot.data!.docs;

                  return ListView.builder(
                    physics:
                        const NeverScrollableScrollPhysics(), // Prevents inner scrolling
                    shrinkWrap:
                        true, // Makes the ListView take up only the required height
                    itemCount: classes.length,
                    itemBuilder: (context, index) {
                      final classData =
                          classes[index].data() as Map<String, dynamic>;
                      final className = classData['classId'] ?? 'Unknown Class';
                      final stream = classData['stream'] ?? 'Unknown Stream';
                      final date = classData['date'] ?? 'No Date';

                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16.0),
                          title: Text(
                            className,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Text(
                                'Stream: $stream',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Date: $date',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios,
                              color: Colors.lightBlue),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ClassDetailPage(
                                  classData: classData,
                                  username: username,
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
      ),
    );
  }
}

class ClassDetailPage extends StatelessWidget {
  final Map<String, dynamic> classData;
  final String username;

  const ClassDetailPage({
    super.key,
    required this.classData,
    required this.username,
  });

  Future<void> _logAttendance(String studentId, String classId) async {
    final DateTime now = DateTime.now();
    final String formattedDate = "${now.year}-${now.month}-${now.day}";
    final String formattedTime = "${now.hour}:${now.minute}:${now.second}";

    await FirebaseFirestore.instance.collection('attendance').add({
      'StudentID': studentId,
      'classId': classId,
      'Date': formattedDate,
      'Time': formattedTime,
    });
  }

  Future<Map<String, dynamic>> _fetchClassAccessData(String classId) async {
    final doc = await FirebaseFirestore.instance
        .collection('Class_access_areas.')
        .doc(classId)
        .get();
    return doc.data() ?? {};
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
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url,
                            mode: LaunchMode.externalApplication);
                      }
                    },
                  ),
                  onTap: () async {
                    final Uri url = Uri.parse(link);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url,
                          mode: LaunchMode.externalApplication);
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchGoogle() async {
    final Uri googleUrl = Uri.parse('https://www.google.com');
    if (await canLaunchUrl(googleUrl)) {
      await launchUrl(googleUrl, mode: LaunchMode.externalApplication);
    } else {
      print("Could not launch $googleUrl");
    }
  }

  @override
  Widget build(BuildContext context) {
    final classId = classData['classId'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text('${classData['classId'] ?? 'Class Detail'}'),
        backgroundColor: Colors.lightBlue,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 13, 10, 169),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.chat),
                color: Colors.white,
                iconSize: 30,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(
                        username: 'YourUsername',
                        classId: classData['classId'] ?? 'Unknown',
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Class Information',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                    const Divider(),
                    Text(
                      'Username: $username',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Class ID: ${classData['classId'] ?? 'N/A'}',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    Text('Stream: ${classData['stream'] ?? 'N/A'}'),
                    const SizedBox(height: 10),
                    Text('Subject ID: ${classData['subjectId'] ?? 'N/A'}'),
                    const SizedBox(height: 10),
                    Text('Teacher ID: ${classData['teacherId'] ?? 'N/A'}'),
                    const SizedBox(height: 10),
                    Text('Date: ${classData['date'] ?? 'N/A'}'),
                    const SizedBox(height: 10),
                    Text('Day: ${classData['day'] ?? 'N/A'}'),
                    const SizedBox(height: 10),
                    Text('Duration: ${classData['duration'] ?? 'N/A'}'),
                    const SizedBox(height: 10),
                    Text(
                        'Introduction: ${classData['introduction'] ?? 'No Introduction'}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            FutureBuilder<Map<String, dynamic>>(
              future: _fetchClassAccessData(classId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('No additional information available');
                } else {
                  final accessData = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLinkSection(
                        'Zoom Links',
                        List<String>.from(accessData['zoom links'] ?? []),
                      ),
                      _buildLinkSection(
                        'Tutorials Links',
                        List<String>.from(accessData['tutorials links'] ?? []),
                      ),
                      _buildLinkSection(
                        'Video Links',
                        List<String>.from(accessData['video links'] ?? []),
                      ),
                      _buildLinkSection(
                        'Other Links',
                        List<String>.from(accessData['other links'] ?? []),
                      ),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.start, // Align buttons to the left
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width *
                      0.65, // 65% of screen width
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.lightBlue.shade400, // First color
                          Colors.lightBlue.shade600, // Second color
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(
                          10), // Match the button's border radius
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await _logAttendance(username, classId);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LiveStreamPage(
                              username: username,
                              classId: classId,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.video_call,
                          size: 24,
                          color: Colors.white), // Set icon color to white
                      label: const Text(
                        'Join Live Stream',
                        style: TextStyle(
                            color: Colors.white), // Set text color to white
                      ),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor:
                            Colors.transparent, // Remove default elevation
                        padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal:
                                24), // Make button background transparent
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.start, // Align buttons to the left
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width *
                      0.65, // 65% of screen width
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.lightBlue.shade400, // First color
                          Colors.lightBlue.shade600, // Second color
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(
                          10), // Match the button's border radius
                    ),
                    child: ElevatedButton.icon(
                      onPressed: _launchGoogle,
                      icon: const Icon(
                        Icons.search,
                        color: Colors.white, // Set icon color to white
                      ),
                      label: const Text(
                        'Launch Google',
                        style: TextStyle(
                            color: Colors.white), // Set text color to white
                      ),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor:
                            Colors.transparent, // Remove default elevation
                        padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal:
                                24), // Make button background transparent
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.start, // Align buttons to the left
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width *
                      0.65, // 65% of screen width
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color.fromARGB(
                              255, 89, 181, 226), // First color
                          const Color.fromRGBO(3, 155, 229, 1), // Second color
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(
                          10), // Match the button's border radius
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color.fromRGBO(
                                41, 182, 246, 1), // First color
                            const Color.fromRGBO(
                                3, 155, 229, 1), // Second color
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(
                            10), // Match the button's border radius
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AttendancePage(
                                username: username,
                                classId: classId,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.check_circle,
                          size: 24,
                          color: Colors.white, // Set icon color to white
                        ),
                        label: const Text(
                          'Attendance',
                          style: TextStyle(
                              color: Colors.white), // Set text color to white
                        ),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor:
                              Colors.transparent, // Remove default elevation
                          padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal:
                                  24), // Make button background transparent
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 76, 162, 223), // First color
                Color.fromARGB(255, 33, 22, 241), // Second color
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius:
                BorderRadius.circular(8.0), // Optional: Add rounded corners
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 37, 216, 235), // First color
                  Color.fromARGB(255, 7, 35, 220), // Second color
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius:
                  BorderRadius.circular(8.0), // Optional: Add rounded corners
            ),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentPage(
                      classId: classId,
                      username: '$username',
                    ),
                  ),
                );
              },
              child: const Text('Proceed to Payment'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.transparent,
                elevation: 0, // Remove default elevation
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                textStyle:
                    const TextStyle(fontSize: 20), // Set text color to white
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// LiveStreamPage

class LiveStreamPage extends StatelessWidget {
  final String username;
  final String classId;

  const LiveStreamPage({
    super.key,
    required this.username,
    required this.classId,
  });

  Future<List<Map<String, dynamic>>> _fetchZoomMeetings() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('zoomMeetings')
        .where('ZoomClassID', isEqualTo: classId)
        .get();

    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunch(uri.toString())) {
      await launch(uri.toString(), forceSafariVC: false);
    } else {
      // If URL cannot be launched, show a SnackBar with error message
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Live Stream'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          // Enable scrolling for the entire page
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section with user and class ID info
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 224, 243, 252),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, $username!',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Class ID: $classId',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Fetch and display Zoom meetings
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchZoomMeetings(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No Zoom meetings available'));
                  } else {
                    final meetings = snapshot.data!;
                    return ListView.builder(
                      shrinkWrap: true,
                      physics:
                          NeverScrollableScrollPhysics(), // Prevent scrolling conflict
                      itemCount: meetings.length,
                      itemBuilder: (context, index) {
                        final meeting = meetings[index];
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Meeting Date: ${meeting['MeetingDate'] ?? 'N/A'}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Meeting Time: ${meeting['MeetingTime'] ?? 'N/A'}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Zoom Class ID: ${meeting['ZoomClassID'] ?? 'N/A'}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: () async {
                                    final String? meetingLink =
                                        meeting['MeetingLink'];
                                    if (meetingLink != null &&
                                        meetingLink.isNotEmpty) {
                                      await _launchUrl(meetingLink);
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Meeting link is not available'),
                                        ),
                                      );
                                    }
                                  },
                                  child: Text(
                                    'Meeting Link: ${meeting['MeetingLink'] ?? 'N/A'}',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Payment Page

class PaymentPage extends StatefulWidget {
  final String classId;
  final String username;

  const PaymentPage({Key? key, required this.classId, required this.username})
      : super(key: key);

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

  void _savePaymentData(BuildContext context) async {
    // Validate input fields
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
      return;
    }

    // Here, integrate the payment gateway logic
    try {
      // Assuming payment is successful, prepare payment data for Firestore
      final paymentData = {
        'classId': widget.classId,
        'username': widget.username,
        'paymentAmount': paymentAmountController.text,
        'month': selectedMonth,
        'fullName': fullNameController.text,
        'cardNumber': cardNumberController.text,
        'expirationDate': expirationDateController.text,
        'cvv': cvvController.text,
      };

      // Save payment data to Firestore
      await FirebaseFirestore.instance.collection('payment').add(paymentData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment Successful!')),
      );

      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Stream<QuerySnapshot> _getPaymentHistory() {
    return FirebaseFirestore.instance
        .collection('payment')
        .where('classId', isEqualTo: widget.classId)
        .where('username', isEqualTo: widget.username)
        .snapshots();
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
              // Payment form
              _buildTextField(
                paymentAmountController,
                'Payment Amount',
                hintText: 'e.g., 100',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _buildDropdown(),
              const SizedBox(height: 16),
              _buildTextField(fullNameController, 'Full Name'),
              const SizedBox(height: 16),
              _buildTextField(
                cardNumberController,
                'Card Number',
                hintText: '1234 5678 9012 3456',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _buildRowOfFields(),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: () => _savePaymentData(context),
                  child: Text('Submit Payment'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Payment history section
              Text(
                'Payment History',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              StreamBuilder<QuerySnapshot>(
                stream: _getPaymentHistory(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Text('No payment history found.');
                  }

                  final payments = snapshot.data!.docs;

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: payments.length,
                    itemBuilder: (context, index) {
                      var paymentData =
                          payments[index].data() as Map<String, dynamic>;
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(paymentData['fullName']),
                          subtitle: Text(
                            'Month: ${paymentData['month']}, Amount: ${paymentData['paymentAmount']}',
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {String? hintText, TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.lightBlue, width: 2),
        ),
      ),
      keyboardType: keyboardType,
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
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
    );
  }

  Widget _buildRowOfFields() {
    return Row(
      children: [
        Expanded(
          child: _buildTextField(expirationDateController, 'Expiration Date',
              hintText: 'MM/YY', keyboardType: TextInputType.datetime),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildTextField(cvvController, 'CVV/CVC',
              keyboardType: TextInputType.number),
        ),
      ],
    );
  }
}

class ChatPage extends StatefulWidget {
  final String username;
  final String classId;

  const ChatPage({
    Key? key,
    required this.username,
    required this.classId,
  }) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();

  // Function to send the message to Firestore
  void _sendMessage() async {
    if (_messageController.text.isEmpty) {
      return;
    }

    // Add the message to the chat_St_Class collection
    await FirebaseFirestore.instance.collection('chat_St_Class').add({
      'Message': _messageController.text,
      'StudentID': widget.username,
      'classId': widget.classId,
      'de': widget.username, // 'de' is also set to username value
      'timestamp': FieldValue.serverTimestamp(), // Optional: Add a timestamp
    });

    // Clear the text field after sending the message
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Page', style: TextStyle(fontWeight: FontWeight.bold)),
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

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No messages found'));
                }

                final messages = snapshot.data!.docs;

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

                    return Card(
                      margin:
                          EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          message,
                          style: TextStyle(fontSize: 16),
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AttendancePage extends StatefulWidget {
  final String username;
  final String classId;

  const AttendancePage({
    Key? key,
    required this.username,
    required this.classId,
  }) : super(key: key);

  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  String selectedDate = ''; // To store the date input for filtering

  Future<List<Map<String, dynamic>>> _fetchAttendanceData(String? date) async {
    QuerySnapshot attendanceSnapshot = await FirebaseFirestore.instance
        .collection('attendance')
        .where('classId', isEqualTo: widget.classId)
        .where('StudentID', isEqualTo: widget.username)
        .get();

    // If a date is provided, filter the results by date
    if (date != null && date.isNotEmpty) {
      return attendanceSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .where((attendance) => attendance['Date'] == date)
          .toList();
    }

    return attendanceSnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Details'),
        backgroundColor: Colors.lightBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSearchBar(),
            const SizedBox(height: 16.0),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchAttendanceData(selectedDate),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text('No attendance records found'));
                  }

                  final attendanceData = snapshot.data!;

                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: attendanceData.length,
                    itemBuilder: (context, index) {
                      final attendance = attendanceData[index];
                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title:
                              Text('Date: ${attendance['Date'] ?? 'Unknown'}'),
                          subtitle:
                              Text('Time: ${attendance['Time'] ?? 'Unknown'}'),
                          trailing: const Icon(Icons.check_circle,
                              color: Color.fromARGB(255, 112, 231, 116)),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        labelText: 'Filter by Date (YYYY-MM-DD)',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.date_range),
      ),
      onChanged: (value) {
        setState(() {
          selectedDate = value; // Update selectedDate when the user types
        });
      },
    );
  }
}

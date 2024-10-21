import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AllClassesPage extends StatelessWidget {
  final String username;

  const AllClassesPage({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Classes'),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, $username!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Here are all the classes you are teaching:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 20),

            // Notice section
            Container(
              decoration: BoxDecoration(
                color: Colors.lightBlue.shade50,
                borderRadius: BorderRadius.circular(10),
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
                    'Welcome to the Online Education System!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'As a teacher, you can create engaging lessons and track student progress, making learning accessible and enjoyable for everyone!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('classes')
                    .where('teacherId', isEqualTo: username)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No classes found.'));
                  }

                  final classes = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: classes.length,
                    itemBuilder: (context, index) {
                      final classData =
                          classes[index].data() as Map<String, dynamic>;
                      final classId = classData['classId'] ?? 'Unknown';
                      final subjectId = classData['subjectId'] ?? 'No Subject';

                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(
                            'Class ID: $classId',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Text(
                            'Subject: $subjectId',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          trailing: Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ClassDetailsPage(
                                  classData: classData,
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
            ),
          ],
        ),
      ),
    );
  }
}

class ClassDetailsPage extends StatelessWidget {
  final Map<String, dynamic> classData;

  const ClassDetailsPage({super.key, required this.classData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(classData['classId'] ?? 'Class Details'),
        backgroundColor: Colors.lightBlueAccent,
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MessagePage(
                      username: 'YourUsername',
                      classId: classData['classId'] ?? 'Unknown',
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Class ID: ${classData['classId'] ?? 'Unknown'}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  SizedBox(height: 30),
                  _buildDetailRow('Date:', classData['date'] ?? 'No Date'),
                  _buildDetailRow('Day:', classData['day'] ?? 'No Day'),
                  _buildDetailRow(
                      'Duration:', classData['duration'] ?? 'No Duration'),
                  _buildDetailRow('Introduction:',
                      classData['introduction'] ?? 'No Introduction'),
                  _buildDetailRow(
                      'Stream:', classData['stream'] ?? 'No Stream'),
                  _buildDetailRow(
                      'Subject ID:', classData['subjectId'] ?? 'No Subject'),
                  _buildDetailRow(
                      'Teacher ID:', classData['teacherId'] ?? 'No Teacher'),
                  SizedBox(height: 20),
                  _buildLinkBox(context, 'Zoom Links', classData['classId']),
                  SizedBox(height: 10),
                  _buildLinkBox(
                      context, 'Tutorials Links', classData['classId']),
                  SizedBox(height: 10),
                  _buildLinkBox(context, 'Video Links', classData['classId']),
                  SizedBox(height: 10),
                  _buildLinkBox(context, 'Other Links', classData['classId']),
                  SizedBox(height: 200), // Space for the button at the bottom
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // First button: "Check Attendance"
                Container(
                  width: double.infinity, // Full width of the screen
                  margin: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8), // Add margins
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlueAccent,
                      padding: EdgeInsets.symmetric(
                          vertical: 20), // Increased padding for a modern look
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(30), // Rounded button corners
                      ),
                      elevation: 5, // Add a slight shadow for depth
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AttendancePage(
                            classId: classData['classId'] ?? 'Unknown',
                          ),
                        ),
                      );
                    },
                    child: Text(
                      'Check Attendance',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),

                // Second button: "Academic Center Payments"
                Container(
                  width: double.infinity, // Full width of the screen
                  margin: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8), // Add margins
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlueAccent,
                      padding: EdgeInsets.symmetric(
                          vertical: 20), // Increased padding for a modern look
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(30), // Rounded button corners
                      ),
                      elevation: 5, // Add a slight shadow for depth
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AcademicCenterPage(
                            classId: classData['classId'] ?? 'Unknown',
                          ),
                        ),
                      );
                    },
                    child: Text(
                      'Academic Center Payments',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkBox(BuildContext context, String linkType, String classId) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                LinksManagementPage(linkType: linkType, classId: classId),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 82, 168, 239),
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade400,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            linkType,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}

// Define the AttendancePage where classId is passed

class AttendancePage extends StatefulWidget {
  final String classId;

  const AttendancePage({super.key, required this.classId});

  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  String? studentId;
  String? date;
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance for ${widget.classId}'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchFields(),
              SizedBox(height: 16),
              Container(
                height: MediaQuery.of(context).size.height * 0.7,
                child: _buildAttendanceList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchFields() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Search Attendance',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            SizedBox(height: 16),
            // Search by StudentID
            TextField(
              decoration: InputDecoration(
                labelText: 'Search by Student ID',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              onChanged: (value) {
                setState(() {
                  studentId = value.isNotEmpty ? value : null;
                });
              },
            ),
            SizedBox(height: 16),
            // Search by Date
            TextField(
              decoration: InputDecoration(
                labelText: 'Search by Date',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
              ),
              onChanged: (value) {
                setState(() {
                  date = value.isNotEmpty ? value : null;
                });
              },
            ),
            SizedBox(height: 16),
            // Search by Time Range
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Start Time (HH:mm)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.access_time),
                    ),
                    onChanged: (value) {
                      setState(() {
                        startTime = _parseTime(value);
                      });
                    },
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'End Time (HH:mm)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.access_time),
                    ),
                    onChanged: (value) {
                      setState(() {
                        endTime = _parseTime(value);
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _getFilteredAttendanceStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'No attendance records found for Class ID: ${widget.classId}',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var attendanceData = snapshot.data!.docs[index];
            return Card(
              margin: EdgeInsets.symmetric(vertical: 8),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: Text(
                    attendanceData['StudentID'][0],
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(
                  'Student ID: ${attendanceData['StudentID']}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Date: ${attendanceData['Date']}'),
                    Text('Time: ${attendanceData['Time']}'),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Stream<QuerySnapshot> _getFilteredAttendanceStream() {
    var query = FirebaseFirestore.instance
        .collection('attendance')
        .where('classId', isEqualTo: widget.classId);

    if (studentId != null && studentId!.isNotEmpty) {
      query = query.where('StudentID', isEqualTo: studentId);
    }

    if (date != null && date!.isNotEmpty) {
      query = query.where('Date', isEqualTo: date);
    }

    if (startTime != null && endTime != null) {
      var startTimeFormatted = _formatTime(startTime!);
      var endTimeFormatted = _formatTime(endTime!);

      query = query
          .where('Time', isGreaterThanOrEqualTo: startTimeFormatted)
          .where('Time', isLessThanOrEqualTo: endTimeFormatted);
    }

    return query.snapshots();
  }

  TimeOfDay? _parseTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      if (parts.length == 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        return TimeOfDay(hour: hour, minute: minute);
      }
    } catch (e) {
      // Handle parsing error
    }
    return null;
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

class LinksManagementPage extends StatefulWidget {
  final String linkType;
  final String classId;

  const LinksManagementPage(
      {super.key, required this.linkType, required this.classId});

  @override
  _LinksManagementPageState createState() => _LinksManagementPageState();
}

class _LinksManagementPageState extends State<LinksManagementPage> {
  TextEditingController _linkController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.linkType,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Class_access_areas.')
                    .doc(widget.classId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  var data = snapshot.data!.data() as Map<String, dynamic>?;
                  var links =
                      (data?[widget.linkType.toLowerCase()] as List<dynamic>?)
                              ?.map((e) => e as String)
                              .toList() ??
                          [];

                  return ListView.builder(
                    itemCount: links.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 2,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          title: Text(
                            links[index],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _deleteLink(index, links);
                            },
                          ),
                          onTap: () {
                            _showEditDialog(links[index], index);
                          },
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
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity, // Full width button
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              padding: EdgeInsets.symmetric(vertical: 16), // Button height
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12), // Rounded corners
              ),
              elevation: 6, // Adds shadow to the button
            ),
            onPressed: () {
              _showAddDialog();
            },
            child: Text(
              'Add New ${widget.linkType}',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAddDialog() {
    _linkController.clear();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            'Add ${widget.linkType}',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: _linkController,
            decoration: InputDecoration(
              hintText: 'Enter link here',
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _addLink(_linkController.text);
                Navigator.pop(context);
              },
              child: Text(
                'Add',
                style: TextStyle(color: Colors.blueAccent),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog(String currentLink, int index) {
    _linkController.text = currentLink;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            'Edit ${widget.linkType}',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: _linkController,
            decoration: InputDecoration(
              hintText: 'Enter new link here',
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _updateLink(_linkController.text, currentLink, index);
                Navigator.pop(context);
              },
              child: Text(
                'Update',
                style: TextStyle(color: Colors.blueAccent),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _addLink(String newLink) async {
    if (newLink.isNotEmpty) {
      var classAccessRef = FirebaseFirestore.instance
          .collection('Class_access_areas.')
          .doc(widget.classId);

      var docSnapshot = await classAccessRef.get();
      if (docSnapshot.exists) {
        var data = docSnapshot.data() as Map<String, dynamic>?;
        var existingLinks =
            (data?[widget.linkType.toLowerCase()] as List<dynamic>?)
                    ?.map((e) => e as String)
                    .toList() ??
                [];
        existingLinks.add(newLink);
        await classAccessRef.update({
          widget.linkType.toLowerCase(): existingLinks,
        });
      } else {
        await classAccessRef.set({
          widget.linkType.toLowerCase(): [newLink],
        });
      }
    }
  }

  void _updateLink(String newLink, String oldLink, int index) async {
    if (newLink.isNotEmpty) {
      var classAccessRef = FirebaseFirestore.instance
          .collection('Class_access_areas.')
          .doc(widget.classId);

      var docSnapshot = await classAccessRef.get();
      var data = docSnapshot.data() as Map<String, dynamic>?;

      var existingLinks =
          (data?[widget.linkType.toLowerCase()] as List<dynamic>?)
                  ?.map((e) => e as String)
                  .toList() ??
              [];

      existingLinks[index] = newLink;

      await classAccessRef.update({
        widget.linkType.toLowerCase(): existingLinks,
      });
    }
  }

  void _deleteLink(int index, List<String> links) async {
    var classAccessRef = FirebaseFirestore.instance
        .collection('Class_access_areas.')
        .doc(widget.classId);

    links.removeAt(index);

    await classAccessRef.update({
      widget.linkType.toLowerCase(): links,
    });
  }
}

class MessagePage extends StatelessWidget {
  final String username;
  final String classId;

  const MessagePage({super.key, required this.username, required this.classId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Messages'),
        backgroundColor: Colors.lightBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Username: $username',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Class ID: $classId',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('chat_St_Class')
                    .where('classId', isEqualTo: classId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No messages found.'));
                  }

                  final messages = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message =
                          messages[index].data() as Map<String, dynamic>;
                      final documentId = messages[index].id;

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 4,
                        child: ListTile(
                          title: Text(
                            message['Message'] ?? 'No message content',
                            style: TextStyle(fontSize: 16),
                          ),
                          subtitle: Text(
                            'Posted by: ${message['StudentID'] ?? 'Unknown'}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _showEditDialog(
                                    context, documentId, message['Message']),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () =>
                                    _showDeleteDialog(context, documentId),
                              ),
                            ],
                          ),
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

  void _showEditDialog(
      BuildContext context, String messageId, String currentMessage) {
    final TextEditingController messageController =
        TextEditingController(text: currentMessage);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Message'),
          content: TextField(
            controller: messageController,
            decoration: InputDecoration(hintText: 'Add your reply here'),
            maxLines: 3,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                final newMessageText = messageController.text.trim();
                if (newMessageText.isNotEmpty) {
                  await _updateMessage(
                      messageId, currentMessage, newMessageText, context);
                }
                Navigator.of(context).pop();
              },
              child: Text('Update'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateMessage(String messageId, String currentMessage,
      String newMessageText, BuildContext context) async {
    try {
      final messageDocRef =
          FirebaseFirestore.instance.collection('chat_St_Class').doc(messageId);

      final updatedMessage =
          '$currentMessage\n\nTeacher Responses \n$newMessageText';

      await messageDocRef.update({
        'Message': updatedMessage,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Message updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating message: $e')),
      );
      print('Error updating message: $e');
    }
  }

  void _showDeleteDialog(BuildContext context, String messageId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Message'),
          content: Text('Are you sure you want to delete this message?'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                await _deleteMessage(messageId, context);
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteMessage(String messageId, BuildContext context) async {
    try {
      final messageDocRef =
          FirebaseFirestore.instance.collection('chat_St_Class').doc(messageId);

      await messageDocRef.delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Message deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting message: $e')),
      );
      print('Error deleting message: $e');
    }
  }
}

class AcademicCenterPage extends StatefulWidget {
  final String classId;

  const AcademicCenterPage({super.key, required this.classId});

  @override
  _AcademicCenterPageState createState() => _AcademicCenterPageState();
}

class _AcademicCenterPageState extends State<AcademicCenterPage> {
  String? selectedMonth;
  String? selectedStatus;

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
    'December'
  ];

  final List<String> statuses = ['Paid', 'Not Paid'];

  // Method to build the Firestore query with filters
  Stream<QuerySnapshot> getFilteredPayments() {
    Query query = FirebaseFirestore.instance
        .collection('teacherPayment')
        .where('classID', isEqualTo: widget.classId);

    if (selectedMonth != null) {
      query = query.where('month', isEqualTo: selectedMonth);
    }
    if (selectedStatus != null) {
      query = query.where('status', isEqualTo: selectedStatus);
    }

    return query.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Academic Center - ${widget.classId}'),
        backgroundColor: Colors.blue[700],
        elevation: 5.0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payments for Class ID: ${widget.classId}',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w600,
                color: Colors.blueAccent,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Manage and view payment details below.',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            SizedBox(height: 20),

            // Dropdowns with improved UI for selecting month and status
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 165, 219, 255),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButton<String>(
                      underline: SizedBox(),
                      isExpanded: true,
                      hint: Text(
                        'Select Month',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      value: selectedMonth,
                      items: months.map((String month) {
                        return DropdownMenuItem<String>(
                          value: month,
                          child: Text(month),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedMonth = value;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 165, 219, 255),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButton<String>(
                      underline: SizedBox(),
                      isExpanded: true,
                      hint: Text(
                        'Payment Status',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      value: selectedStatus,
                      items: statuses.map((String status) {
                        return DropdownMenuItem<String>(
                          value: status,
                          child: Text(status),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedStatus = value;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // StreamBuilder to fetch and display the data with filters
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: getFilteredPayments(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        'No payment details found.',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var paymentData = snapshot.data!.docs[index].data()
                          as Map<String, dynamic>;

                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16),
                          title: Text(
                            'Teacher: ${paymentData['teacherID'] ?? 'Unknown'}',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Teacher ID: ${paymentData['teacherID'] ?? 'Unknown'}',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                              Text(
                                'Payment ID: ${paymentData['paymentID'] ?? 'Unknown'}',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                              Text(
                                'Month: ${paymentData['month'] ?? 'Unknown'}',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                              Text(
                                'Date: ${paymentData['date'] ?? 'Unknown'}',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                              Text(
                                'Amount: ${paymentData['amount'] ?? '0.00'}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                ),
                              ),
                              Text(
                                'Status: ${paymentData['status'] ?? 'Unknown'}',
                                style: TextStyle(
                                  color: paymentData['status'] == 'Paid'
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
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
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EnrolledClassesPage extends StatefulWidget {
  final String username;

  // Constructor to accept username
  EnrolledClassesPage({required this.username});

  @override
  _EnrolledClassesPageState createState() => _EnrolledClassesPageState();
}

class _EnrolledClassesPageState extends State<EnrolledClassesPage> {
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            // Welcome Message
            Text(
              'Classes Student Payment Details',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Welcome ${widget.username}',
              style: const TextStyle(
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 30),

            // Centered Search Field
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: '',
                    hintStyle:
                        TextStyle(color: const Color.fromARGB(255, 94, 88, 88)),
                    border: InputBorder.none,
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Information Message
            Container(
              padding: const EdgeInsets.all(16.0),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Thank you for your dedication!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Ensure that all payment details are up to date to receive your earnings promptly. If you have any questions or need assistance, please reach out to our support team.',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Available Classes Section
            const Text(
              'Classes:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('classes')
                    .where('teacherId', isEqualTo: widget.username)
                    .snapshots(),
                builder: (context, snapshot) {
                  // Check for loading state
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  // Filter classes based on the search query
                  final filteredClasses = snapshot.data?.docs.where((doc) {
                    final classId = doc.id.toLowerCase();
                    return classId.contains(_searchQuery.toLowerCase());
                  }).toList();

                  // Check if there is any data
                  if (filteredClasses == null || filteredClasses.isEmpty) {
                    return Center(
                      child: Text('No classes found for ${widget.username}.'),
                    );
                  }

                  // Display the list of classes
                  return ListView(
                    children: filteredClasses.map((doc) {
                      // Extract class data from Firestore document
                      Map<String, dynamic> classData =
                          doc.data() as Map<String, dynamic>;

                      return Card(
                        elevation: 5,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title:
                              Text(classData['className'] ?? 'No class name'),
                          subtitle: Text('Class ID: ${doc.id}'),
                          onTap: () {
                            // Navigate to PaymentPage and pass classId
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PaymentPage(classId: doc.id),
                              ),
                            );
                          },
                        ),
                      );
                    }).toList(),
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

class PaymentPage extends StatefulWidget {
  final String classId;

  PaymentPage({required this.classId});

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final TextEditingController _usernameController = TextEditingController();

  String _selectedMonth = 'All'; // Default value for dropdown
  String _usernameQuery = '';

  // List of months for dropdown
  final List<String> _months = [
    'All',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment for ${widget.classId}'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Dropdown for selecting month
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color.fromARGB(255, 205, 209, 246),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 5,
                    spreadRadius: 1,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedMonth,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedMonth = newValue ?? 'All';
                    });
                  },
                  isExpanded: true,
                  items: _months.map<DropdownMenuItem<String>>((String month) {
                    return DropdownMenuItem<String>(
                      value: month,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Text(month),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            SizedBox(height: 16), // Space between dropdown and text field

            // TextField for searching by username
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Search by Username',
                labelStyle: TextStyle(color: Colors.blueGrey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.blueAccent),
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _usernameController.clear();
                    setState(() {
                      _usernameQuery = '';
                    });
                  },
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _usernameQuery = value;
                });
              },
            ),

            SizedBox(height: 16), // Space between text field and list

            // Expanded widget for displaying payment records
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('payment')
                    .where('classId', isEqualTo: widget.classId)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  // Check for errors or loading state
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  // Filter payments based on search queries
                  final filteredPayments = snapshot.data?.docs.where((doc) {
                    final paymentData = doc.data() as Map<String, dynamic>;
                    final month = paymentData['month'] ?? '';
                    final username = paymentData['username'] ?? '';

                    return (_selectedMonth == 'All' ||
                            month.toLowerCase() ==
                                _selectedMonth.toLowerCase()) &&
                        (username
                                .toLowerCase()
                                .contains(_usernameQuery.toLowerCase()) ||
                            _usernameQuery.isEmpty);
                  }).toList();

                  // Check if there is any data
                  if (filteredPayments == null || filteredPayments.isEmpty) {
                    return Center(child: Text('No payment records found.'));
                  }

                  // Display the list of payments
                  return ListView.separated(
                    itemCount: filteredPayments.length,
                    separatorBuilder: (context, index) => Divider(),
                    itemBuilder: (context, index) {
                      final paymentData = filteredPayments[index].data()
                          as Map<String, dynamic>;

                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 204, 213, 244),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 5,
                              spreadRadius: 1,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Full Name: ${paymentData['fullName'] ?? 'N/A'}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Text('Month: ${paymentData['month'] ?? 'N/A'}'),
                            Text(
                                'Payment Amount: ${paymentData['paymentAmount'] ?? 'N/A'}'),
                            Text(
                                'StudentID: ${paymentData['username'] ?? 'N/A'}'),
                          ],
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

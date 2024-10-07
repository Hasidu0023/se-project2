import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PaymentsPage extends StatefulWidget {
  final String username;

  const PaymentsPage({Key? key, required this.username}) : super(key: key);

  @override
  _PaymentsPageState createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  String studentP = 'Fetching...'; // Placeholder value for the StudentID
  List<Map<String, dynamic>> classEnrollmentData =
      []; // List to hold the class data

  @override
  void initState() {
    super.initState();
    _getStudentID(); // Fetch the StudentID when the widget is initialized
  }

  // Method to fetch the StudentID from Firestore based on ParentID (username)
  Future<void> _getStudentID() async {
    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('studentRequests')
          .where('ParentID', isEqualTo: widget.username)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var studentData = querySnapshot.docs.first.data();
        setState(() {
          studentP = studentData['StudentID'];
        });

        // After fetching the StudentID, fetch class enrollment data
        _getClassEnrollmentData();
      } else {
        setState(() {
          studentP = 'StudentID not found';
        });
      }
    } catch (e) {
      setState(() {
        studentP = 'Error fetching StudentID';
      });
    }
  }

  // Method to fetch class enrollment data for the studentP
  Future<void> _getClassEnrollmentData() async {
    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('ClassEnrollment')
          .where('studentId', isEqualTo: studentP)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          classEnrollmentData = querySnapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();
        });
      }
    } catch (e) {}
  }

  // Navigate to PaymentDetailsPage with classId
  void _goToPaymentDetailsPage(String classId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentDetailsPage(
          classId: classId,
          studentP: studentP,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Message Banner
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(
                    68, 138, 255, 1), // Color for the warning banner
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              margin: const EdgeInsets.only(
                  bottom: 16.0), // Margin below the banner

              child: const Text(
                'Students must pay fees on time to avoid penalties and secure their class enrollment. Fees are non-refundable, and payment records should be kept for future reference.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16, // Font size for visibility
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Page Title
            Text(
              'Payments Page',
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.lightBlue),
            ),
            const SizedBox(height: 20),
            Text(
              'Logged in as: ${widget.username}',
              style: const TextStyle(
                fontSize: 20,
                color: Color.fromARGB(255, 19, 19, 240),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Student ID: $studentP',
              style: const TextStyle(
                fontSize: 20,
                color: Color.fromARGB(255, 19, 19, 240),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: classEnrollmentData.isEmpty
                  ? const Center(
                      child: Text('No class enrollment data available.',
                          style: TextStyle(
                              fontSize: 18,
                              color: Color.fromARGB(255, 255, 64, 17))))
                  : ListView.builder(
                      itemCount: classEnrollmentData.length,
                      itemBuilder: (context, index) {
                        var classData = classEnrollmentData[index];
                        return Card(
                          elevation: 5,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text('Class ID: ${classData['classId']}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle: Text(
                                'Stream: ${classData['stream']}\nSubject: ${classData['subjectId']}'),
                            onTap: () =>
                                _goToPaymentDetailsPage(classData['classId']),
                          ),
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

class PaymentDetailsPage extends StatefulWidget {
  final String classId;
  final String
      studentP; // Pass the studentP (username) value to filter payments

  PaymentDetailsPage({required this.classId, required this.studentP});

  @override
  _PaymentDetailsPageState createState() => _PaymentDetailsPageState();
}

class _PaymentDetailsPageState extends State<PaymentDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _expirationDateController =
      TextEditingController();
  final TextEditingController _paymentAmountController =
      TextEditingController();

  String selectedMonth = 'January'; // Default month selection
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

  void _submitPayment() async {
    // Check if the form is valid before submission
    if (_formKey.currentState!.validate()) {
      // Create a new payment entry
      await FirebaseFirestore.instance.collection('payment').add({
        'classId': widget.classId,
        'fullName': _fullNameController.text,
        'cardNumber': _cardNumberController.text,
        'cvv': _cvvController.text,
        'expirationDate': _expirationDateController.text,
        'month': selectedMonth, // Use the selected month
        'paymentAmount': _paymentAmountController.text,
        'username': widget.studentP,
      });

      // Clear the form fields
      _fullNameController.clear();
      _cardNumberController.clear();
      _cvvController.clear();
      _expirationDateController.clear();
      _paymentAmountController.clear();

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment submitted successfully!')),
      );
    } else {
      // If the form is not valid, show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all the fields correctly.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Details for Class ${widget.classId}'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        // Enable scrolling
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            // Use Column to accommodate the full width
            children: [
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _fullNameController,
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your full name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: _cardNumberController,
                        decoration: InputDecoration(
                          labelText: 'Card Number',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.credit_card),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your card number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: _cvvController,
                        decoration: InputDecoration(
                          labelText: 'CVV',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your CVV';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: _expirationDateController,
                        decoration: InputDecoration(
                          labelText: 'Expiration Date (MM/YY)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the expiration date';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 12),
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
                                  value: month,
                                  child: Text(month),
                                ))
                            .toList(),
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a month';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: _paymentAmountController,
                        decoration: InputDecoration(
                          labelText: 'Payment Amount',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the payment amount';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      // Make the button full-width
                      SizedBox(
                        width: double.infinity,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color.fromARGB(255, 9, 83, 210),
                                const Color.fromARGB(255, 96, 203, 252)
                              ], // Mix of two colors
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(
                                30), // Match the button's border radius
                          ),
                          child: ElevatedButton(
                            onPressed: _submitPayment,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors
                                  .transparent, // Make the button's background transparent
                              padding: EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              'Submit Payment',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white, // Set text color to white
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              // Display previous payments (if any)
              FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection('payment')
                    .where('classId', isEqualTo: widget.classId)
                    .where('username', isEqualTo: widget.studentP)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error fetching payment data'));
                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                        child: Text('No payments found for this class'));
                  } else {
                    var paymentData = snapshot.data!.docs
                        .map((doc) => doc.data() as Map<String, dynamic>)
                        .toList();
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: paymentData.length,
                      itemBuilder: (context, index) {
                        var payment = paymentData[index];
                        return Card(
                          margin: EdgeInsets.all(8.0),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            title: Text(
                              'Full Name: ${payment['fullName']}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Card Number: ${payment['cardNumber']}'),
                                Text('CVV: ${payment['cvv']}'),
                                Text(
                                    'Expiration Date: ${payment['expirationDate']}'),
                                Text(
                                    'Payment Amount: ${payment['paymentAmount']}'),
                                Text('Month: ${payment['month']}'),
                                Text('Username: ${payment['username']}'),
                                Text('Class ID: ${payment['classId']}'),
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

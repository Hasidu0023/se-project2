import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/ParentMain.dart';
import 'package:flutter_application_1/StudentMain.dart';
import 'package:flutter_application_1/TeacherMain.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "EduSync",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    // Determine the role based on the first two characters of the username
    String role = '';
    CollectionReference dbRef;
    String userIdField, passwordField;

    if (username.startsWith('St')) {
      role = 'Student';
      dbRef = FirebaseFirestore.instance.collection('studentRequests');
      userIdField = 'StudentID';
      passwordField = 'StudentPassword';
    } else if (username.startsWith('Te')) {
      role = 'Teacher';
      dbRef = FirebaseFirestore.instance.collection('teachers');
      userIdField = 'teacherID';
      passwordField = 'password';
    } else if (username.startsWith('Pr')) {
      role = 'Parent';
      dbRef = FirebaseFirestore.instance.collection('studentRequests');
      userIdField = 'ParentID';
      passwordField = 'ParentPassword';
    } else {
      _showError('Invalid username format.');
      return;
    }

    try {
      final querySnapshot =
          await dbRef.where(userIdField, isEqualTo: username).limit(1).get();

      if (querySnapshot.docs.isNotEmpty) {
        final user = querySnapshot.docs.first.data() as Map<String, dynamic>;
        if (user[passwordField] == password) {
          if (role == 'Student') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => StudentDashboard(username: username)),
            );
          } else if (role == 'Teacher') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => TeacherDashboard(username: username)),
            );
          } else if (role == 'Parent') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => ParentDashboard(username: username)),
            );
          }
        } else {
          _showError('Username or password is incorrect.');
        }
      } else {
        _showError('Username or password is incorrect.');
      }
    } catch (e) {
      _showError('Error during login. Please try again.');
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _register() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegistrationPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Full-width image
                Image.asset(
                  "assets/45.png",
                  width: MediaQuery.of(context).size.width, // Full screen width
                  height: 280, // Adjust height as per your requirement
                  fit: BoxFit.cover, // Adjust the image to cover the width
                ),
                SizedBox(height: 120), // Adjust spacing as needed
                // TextField for username
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: "Email or ID",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                ),
                SizedBox(height: 10),
                // TextField for password
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 30),
                // Login button with modern style
// Login Button
                GestureDetector(
                  onTap: _login,
                  child: Container(
                    width: double.infinity, // Full width
                    height: 60, // Button height
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color.fromRGBO(146, 175, 255, 1), // Light blue
                          Color.fromRGBO(0, 9, 190, 1), // Dark blue
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(12), // Curved edges
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3), // Changes position of shadow
                        ),
                      ],
                    ),
                    alignment: Alignment.center, // Center the text
                    child: Text(
                      "Login",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 10),

// Register Button
                GestureDetector(
                  onTap: _register,
                  child: Container(
                    width: double.infinity, // Full width
                    height: 60, // Button height
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color.fromRGBO(146, 175, 255, 1), // Light blue
                          Color.fromRGBO(0, 9, 190, 1), // Dark blue
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(12), // Curved edges
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3), // Changes position of shadow
                        ),
                      ],
                    ),
                    alignment: Alignment.center, // Center the text
                    child: Text(
                      "Register",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  String _selectedGender = 'Male'; // Default value for gender selection
  final TextEditingController _schoolController = TextEditingController();
  final TextEditingController _streamController = TextEditingController();
  final TextEditingController _studentNicController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _academicYearController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _parentNameController = TextEditingController();
  final TextEditingController _parentEmailController = TextEditingController();
  final TextEditingController _parentNicController = TextEditingController();
  final TextEditingController _parentTelController = TextEditingController();

  String? _academicYearError;
  String? _ageError;
  String? _telephoneError;
  String? _parentTelError;

  Future<void> _submitRegistration() async {
    // Validate fields before submission
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _schoolController.text.isEmpty ||
        _streamController.text.isEmpty ||
        _studentNicController.text.isEmpty ||
        _telephoneController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _academicYearController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _ageController.text.isEmpty ||
        _parentNameController.text.isEmpty ||
        _parentEmailController.text.isEmpty ||
        _parentNicController.text.isEmpty ||
        _parentTelController.text.isEmpty) {
      _showErrorDialog("Please fill all fields.");
      return; // Exit the function if validation fails
    }

    // If any numeric input validation errors exist, show an error dialog
    if (_academicYearError != null ||
        _ageError != null ||
        _telephoneError != null ||
        _parentTelError != null) {
      _showErrorDialog("Please fix the input errors before submitting.");
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('studentRequests').add({
        'AcademicYear': _academicYearController.text,
        'Address': _addressController.text,
        'Age': _ageController.text,
        'Date_Time': DateTime.now().toIso8601String(),
        'Email': _emailController.text,
        'FirstName': _firstNameController.text,
        'Gender': _selectedGender,
        'LastName': _lastNameController.text,
        'ParentEmail': _parentEmailController.text,
        'ParentID': 'generatedParentID',
        'ParentNIC': _parentNicController.text,
        'ParentName': _parentNameController.text,
        'ParentPassword': 'generatedParentPassword',
        'ParentTelephone': _parentTelController.text,
        'School': _schoolController.text,
        'Stream': _streamController.text,
        'StudentID': 'generatedStudentID',
        'StudentNIC': _studentNicController.text,
        'StudentPassword': 'generatedStudentPassword',
        'TelephoneNo': _telephoneController.text,
      });

      _showSuccessDialog();
    } catch (e) {
      print("Error saving registration data: $e");
      _showErrorDialog("There was an error processing your registration.");
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Registration Successful"),
        content: Text(
            "Thanks for registering with EduSync! Your username and password will be emailed within 5 days."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
              Navigator.pop(context); // Go back to the previous page
            },
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, Icon icon,
      {TextInputType inputType = TextInputType.text, String? errorText}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            keyboardType: inputType,
            decoration: InputDecoration(
              prefixIcon: icon,
              labelText: label,
              filled: true,
              fillColor: const Color.fromARGB(255, 215, 219, 254),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide.none,
              ),
              errorText: errorText, // Display the error message if any
            ),
          ),
        ],
      ),
    );
  }

  void _validateNumericInput(TextEditingController controller, String type) {
    final value = controller.text;
    if (value.isNotEmpty && double.tryParse(value) == null) {
      setState(() {
        if (type == 'academicYear') {
          _academicYearError = "Please enter a valid number for Academic Year.";
        } else if (type == 'age') {
          _ageError = "Please enter a valid number for Age.";
        } else if (type == 'telephone') {
          _telephoneError = "Please enter a valid number for Telephone.";
        } else if (type == 'parentTel') {
          _parentTelError = "Please enter a valid number for Parent Telephone.";
        }
      });
    } else {
      setState(() {
        if (type == 'academicYear') {
          _academicYearError = null;
        } else if (type == 'age') {
          _ageError = null;
        } else if (type == 'telephone') {
          _telephoneError = null;
        } else if (type == 'parentTel') {
          _parentTelError = null;
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();

    // Add listeners for input validation
    _academicYearController.addListener(() {
      _validateNumericInput(_academicYearController, 'academicYear');
    });
    _ageController.addListener(() {
      _validateNumericInput(_ageController, 'age');
    });
    _telephoneController.addListener(() {
      _validateNumericInput(_telephoneController, 'telephone');
    });
    _parentTelController.addListener(() {
      _validateNumericInput(_parentTelController, 'parentTel');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Registration"),
        backgroundColor: Colors.blueAccent,
        leading: BackButton(),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Register Your Details",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(166, 22, 23, 67),
                ),
              ),
              SizedBox(height: 20),
              Card(
                elevation: 2.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildTextField(
                        "First Name",
                        _firstNameController,
                        Icon(Icons.person),
                      ),
                      _buildTextField(
                        "Last Name",
                        _lastNameController,
                        Icon(Icons.person_outline),
                      ),
                      // Gender Selection
                      Padding(
                        padding: const EdgeInsets.only(bottom: 15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Gender:"),
                            DropdownButton<String>(
                              value: _selectedGender,
                              icon: Icon(Icons.arrow_drop_down),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedGender = newValue!;
                                });
                              },
                              items: <String>[
                                'Male',
                                'Female'
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      _buildTextField(
                        "School",
                        _schoolController,
                        Icon(Icons.school),
                      ),
                      _buildTextField(
                        "Stream",
                        _streamController,
                        Icon(Icons.category),
                      ),
                      _buildTextField(
                        "Student NIC",
                        _studentNicController,
                        Icon(Icons.badge),
                      ),
                      _buildTextField(
                        "Telephone Number",
                        _telephoneController,
                        Icon(Icons.phone),
                        inputType: TextInputType.phone,
                        errorText: _telephoneError,
                      ),
                      _buildTextField(
                        "Email",
                        _emailController,
                        Icon(Icons.email),
                        inputType: TextInputType.emailAddress,
                      ),
                      _buildTextField(
                        "Academic Year",
                        _academicYearController,
                        Icon(Icons.calendar_today),
                        inputType: TextInputType.number,
                        errorText: _academicYearError,
                      ),
                      _buildTextField(
                        "Address",
                        _addressController,
                        Icon(Icons.location_on),
                      ),
                      _buildTextField(
                        "Age",
                        _ageController,
                        Icon(Icons.calendar_view_day),
                        inputType: TextInputType.number,
                        errorText: _ageError,
                      ),
                      SizedBox(height: 20),

                      Text(
                        "Enter Your Perent Details",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(166, 22, 23, 67),
                        ),
                      ),
                      SizedBox(height: 20),
                      _buildTextField(
                        "Parent Name",
                        _parentNameController,
                        Icon(Icons.people),
                      ),
                      _buildTextField(
                        "Parent Email",
                        _parentEmailController,
                        Icon(Icons.email_outlined),
                        inputType: TextInputType.emailAddress,
                      ),
                      _buildTextField(
                        "Parent NIC",
                        _parentNicController,
                        Icon(Icons.badge_outlined),
                      ),
                      _buildTextField(
                        "Parent Telephone",
                        _parentTelController,
                        Icon(Icons.phone_callback),
                        inputType: TextInputType.phone,
                        errorText: _parentTelError,
                      ),
                      SizedBox(height: 20),
                      Container(
                        width: double
                            .infinity, // Set the width to be as large as possible
                        height: 50, // Button height
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color.fromARGB(
                                  255, 26, 101, 231), // First color of gradient
                              const Color.fromARGB(255, 56, 189,
                                  251), // Second color of gradient
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius:
                              BorderRadius.circular(10), // Rounded corners
                        ),
                        child: ElevatedButton.icon(
                          onPressed: _submitRegistration,
                          style: ElevatedButton.styleFrom(
                            elevation:
                                0, // Remove elevation to maintain flat look with the gradient
                            backgroundColor: Colors
                                .transparent, // Transparent background to see the gradient
                            shadowColor: Colors.transparent, // Remove shadow
                          ),
                          icon: Icon(
                            Icons
                                .check, // Example icon, you can change to any other
                            color: Colors.white, // Set the icon color to white
                          ),
                          label: Text(
                            "Register",
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  Colors.white, // Set the text color to white
                              fontWeight: FontWeight
                                  .bold, // Make the text bold for decoration
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

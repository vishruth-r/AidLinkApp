import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../services/login_services.dart';
import 'FR/home_page.dart';
import 'package:aidlink/screens/AM/ambulance_page.dart';
import 'package:aidlink/screens/DR/admin_alerts_page.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top: 120.0, right: 30, left: 30),
        child: LoginForm(),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final LoginService loginService = LoginService();
  bool isLoading = false; // Track loading state

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Center(
            child: isLoading
                ? Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Image.asset(
                'assets/images/resq-logo.png',
                height: 120,
                width: 120,
              ),
            )
                : Image.asset(
              'assets/images/resq-logo.png',
              height: 120,
              width: 120,
            ),
          ),
          SizedBox(height: 16.0),
          isLoading
              ? Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: TextFormField(
              controller: _phoneController,
              maxLength: 10,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Mobile',
                border: OutlineInputBorder(),
              ),
            ),
          )
              : TextFormField(
            controller: _phoneController,
            maxLength: 10,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Mobile',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16.0),
          isLoading
              ? Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
          )
              : TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 24.0),
          ElevatedButton(
            onPressed: isLoading
                ? null
                : () async {
              setState(() {
                isLoading = true;
              });
              String phone = _phoneController.text;
              String password = _passwordController.text;

              Map<String, String>? userData =
              await loginService.loginUser(phone, password);

              if (userData != null) {
                String? userType = userData['type'];

                if (userType != null) {
                  if (userType == 'F') {
                    // Navigate to admin page
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomePage(),
                      ),
                    );
                  } else if (userType == 'A') {
                    // Navigate to ambulance page
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AmbulancePage(),
                      ),
                    );
                  } else if (userType == 'D') {
                    // Navigate to admin alerts page
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminAlertsPage(),
                      ),
                    );
                  } else {
                    // Handle other user types or show an error
                  }
                }
              } else {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Login Failed'),
                      content: Text('Invalid credentials. Please try again.'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              }

              setState(() {
                isLoading = false; // Set loading state to false after operation completes
              });
            },
            child: isLoading
                ? Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Text('Login'),
            )
                : Text('Login'),
          ),
          SizedBox(height: 180.0),
          Image.asset(
            'assets/images/cr-logo.png', // Replace with your bottom image path
            height: 50,
            width: 50,
          ),
        ],
      ),
    );
  }
}

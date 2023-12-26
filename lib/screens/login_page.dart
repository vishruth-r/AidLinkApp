import 'package:aidlink/screens/AM/ambulance_page.dart';
import 'package:aidlink/screens/DR/admin_alerts_page.dart';
import 'package:flutter/material.dart';
import '../services/login_services.dart';
import 'FR/home_page.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
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
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final LoginService loginService = LoginService();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        TextFormField(
          controller: _usernameController,
          decoration: InputDecoration(
            labelText: 'Username',
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 16.0),
        TextFormField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Password',
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 24.0),
        ElevatedButton(
          onPressed: () async {
            String username = _usernameController.text;
            String password = _passwordController.text;

            Map<String, String>? userData = await loginService.loginUser(username, password);

            if (userData != null) {
              String? userType = userData['type'];

              if (userType != null) {
                if (userType == 'F') {
                  // Navigate to admin page
                  // Replace AdminPage with your intended admin page
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                } else if (userType == 'A') {
                  // Navigate to user page
                  // Replace UserPage with your intended user page
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => AmbulancePage()),
                  );
                }
                else if (userType == 'D') {
                  // Navigate to user page
                  // Replace UserPage with your intended user page
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => AdminAlertsPage()),
                  );
                }
                else {
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
          },
          child: Text('Login'),
        ),
      ],
    );
  }
}
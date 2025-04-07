import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transport_app/Navbar.dart';
import 'package:transport_app/Screens/Otp.dart';
import 'package:transport_app/Screens/Signup.dart';
import 'package:transport_app/api-service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  void _loginUser() async {
    setState(() {
      _isLoading = true;
    });

    final email = _emailController.text;
    final password = _passwordController.text;

    try {
      final response = await ApiService.loginUser(email, password);
      final username = response['fullName'] ?? 'Unknown User';
      final userEmail = response['email'] ?? 'No email';
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('authToken', response['authToken']);

      if (response['authToken'] != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Navbar(
              username: username,
              email: userEmail,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${response['error']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 37, 31, 50),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: screenHeight * 0.7,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 19, 16, 25),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30.0),
                  bottomRight: Radius.circular(30.0),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 75),
                    Text(
                      'Hello there!',
                      style: TextStyle(
                        color: const Color.fromARGB(255, 250, 30, 78),
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Sans',
                      ),
                    ),
                    const SizedBox(height: 30),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Email',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontFamily: 'Sans',
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 37, 31, 50),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 10),
                                hintText: 'Enter your Email',
                                hintStyle: TextStyle(
                                  fontFamily: 'Sans',
                                  color:
                                      const Color.fromARGB(255, 157, 157, 157),
                                ),
                              ),
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Sans',
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Password',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontFamily: 'Sans',
                            ),
                          ),
                          SizedBox(height: 5),
                          Container(
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 37, 31, 50),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: TextField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 10),
                                hintText: 'Enter your Password',
                                hintStyle: TextStyle(
                                  fontFamily: 'Sans',
                                  color:
                                      const Color.fromARGB(255, 157, 157, 157),
                                ),
                              ),
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Sans',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'We will send you a one-time password (OTP) for verification.',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        fontFamily: 'Sans',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 50),
            Container(
              width: double.infinity,
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ElevatedButton(
                onPressed: () {
                  _isLoading ? null : _loginUser();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 250, 30, 78),
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      )
                    : Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontFamily: 'Sans',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SignUpPage()));
              },
              child: Text(
                "Don't have an account? Sign up here",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: 'Sans',
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

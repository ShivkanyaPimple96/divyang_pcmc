import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:divyang_pimpri_chinchwad_municipal_corporation/utils/responsive_size.dart';
import 'package:divyang_pimpri_chinchwad_municipal_corporation/office_login_screens/enter_aadhar_number_screen_login.dart';

class UserLoginScreen extends StatefulWidget {
  const UserLoginScreen({super.key});

  @override
  State<UserLoginScreen> createState() => _UserLoginScreenState();
}

class _UserLoginScreenState extends State<UserLoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  /// Creates an HTTP client that accepts self-signed SSL certificates.
  http.Client _createHttpClient() {
    final HttpClient httpClient = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    return IOClient(httpClient);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ResponsiveSize().init(context);
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final client = _createHttpClient();

      try {
        final Map<String, dynamic> requestBody = {
          "Username": _usernameController.text.trim(),
          "Password": _passwordController.text.trim(),
        };

        final response = await client.post(
          Uri.parse('https://lc.pcmcdivyang.com/api/aadhar/OfficeLogin'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(requestBody),
        );

        final Map<String, dynamic> responseData = json.decode(response.body);

        setState(() {
          _isLoading = false;
        });

        if (response.statusCode == 200) {
          if (responseData['Success'] == true) {
            final String userId = responseData['Data']['UserId'].toString();
            _showPopupMessage(
              'Success',
              responseData['Message'] ?? 'Authentication successful',
            );

            Future.delayed(const Duration(seconds: 1), () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      EnterAadharNumberScreenLogin(userId: userId),
                ),
              );
            });
          } else {
            _showPopupMessage(
              'Note',
              'Failed to login. Please try again.',
            );
          }
        } else if (response.statusCode == 401) {
          _showPopupMessage(
            'Note',
            'Invalid username or password.\nPlease do not include spaces when entering your username and password.',
          );
        } else {
          _showPopupMessage(
            'Note',
            'Failed to authenticate. Please try again.',
          );
        }
      } catch (error) {
        setState(() {
          _isLoading = false;
        });
        // Show the actual error for easier debugging
        _showPopupMessage(
          'Note',
          ' कृपया तुमचे इंटरनेट कनेक्शन तपासा आणि पुन्हा प्रयत्न करा.\nPlease check your Internet connection and try again.',
        );
      } finally {
        client.close();
      }
    }
  }

  void _showPopupMessage(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(thickness: 2.5),
              Text(
                message,
                style: TextStyle(fontSize: 20.sp),
                textAlign: TextAlign.center,
              ),
              const Divider(thickness: 2.5),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'OK',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 18.sp,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Login Screen',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 20.sp,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.yellow,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: ResponsiveSize.padding(all: 6),
          child: Column(
            children: [
              SizedBox(height: 8.h),
              Text(
                'Login',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 20.sp,
                ),
              ),
              SizedBox(height: 6.h),
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.w),
                  side: BorderSide(
                    color: Colors.yellow,
                    width: 0.5.w,
                  ),
                ),
                child: Padding(
                  padding: ResponsiveSize.padding(all: 6),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Username Field
                        TextFormField(
                          controller: _usernameController,
                          style: TextStyle(fontSize: 15.sp),
                          decoration: InputDecoration(
                            labelText: 'Username',
                            labelStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 15.sp,
                            ),
                            prefixIcon: Icon(
                              Icons.person,
                              color: Colors.black,
                              size: 6.w,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(2.w),
                              borderSide: const BorderSide(color: Colors.black),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(2.w),
                              borderSide: const BorderSide(
                                color: Colors.black,
                                width: 2,
                              ),
                            ),
                            contentPadding: ResponsiveSize.padding(
                              horizontal: 3,
                              vertical: 2,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your username';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 2.h),
                        // Password Field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          style: TextStyle(fontSize: 15.sp),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 15.sp,
                            ),
                            prefixIcon: Icon(
                              Icons.lock,
                              color: Colors.black,
                              size: 6.w,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.black,
                                size: 6.w,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(2.w),
                              borderSide: const BorderSide(color: Colors.black),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(2.w),
                              borderSide: const BorderSide(
                                color: Colors.black,
                                width: 2,
                              ),
                            ),
                            contentPadding: ResponsiveSize.padding(
                              horizontal: 3,
                              vertical: 2,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 3.h),
                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 6.h,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.yellow,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(2.w),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 1.5.h),
                            ),
                            child: _isLoading
                                ? SizedBox(
                                    width: 5.w,
                                    height: 5.w,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : Text(
                                    'Login',
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

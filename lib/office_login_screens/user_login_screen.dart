import 'dart:convert';

import 'package:divyang_pimpri_chinchwad_municipal_corporation/office_login_screens/get_aadhar_detailes_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

  // API call for login
  // Future<void> _login() async {
  //   if (_formKey.currentState!.validate()) {
  //     setState(() {
  //       _isLoading = true;
  //     });

  //     try {
  //       // Prepare request body
  //       final Map<String, dynamic> requestBody = {
  //         "Username": _usernameController.text,
  //         "Password": _passwordController.text,
  //       };

  //       // Make API call
  //       final response = await http.post(
  //         Uri.parse('https://divyangpcmc.altwise.in/api/aadhar/OfficeLogin'),
  //         headers: <String, String>{
  //           'Content-Type': 'application/json; charset=UTF-8',
  //         },
  //         body: jsonEncode(requestBody),
  //       );

  //       // Parse response
  //       final Map<String, dynamic> responseData = json.decode(response.body);

  //       setState(() {
  //         _isLoading = false;
  //       });

  //       // Handle different response statuses
  //       if (response.statusCode == 200) {
  //         if (responseData['Success'] == true) {
  //           // Show success message
  //           // _showPopupMessage('Success',
  //           //     responseData['Message'] ?? 'Authentication successful');

  //           // Navigate to the next screen after a short delay
  //           Future.delayed(const Duration(seconds: 1), () {
  //             Navigator.push(
  //               context,
  //               MaterialPageRoute(
  //                 builder: (context) => const GetAadharDetailesScreen(),
  //               ),
  //             );
  //           });
  //         } else {
  //           // Show error message from API
  //           _showPopupMessage(
  //               'Note', responseData['Message'] ?? 'Authentication failed');
  //         }
  //       } else if (response.statusCode == 401) {
  //         // Show unauthorized error message
  //         _showPopupMessage('Note',
  //             responseData['Message'] ?? 'Invalid username or password');
  //       } else {
  //         // Show generic error message for other status codes
  //         _showPopupMessage(
  //             'Note', 'An unexpected error occurred. Please try again.');
  //       }
  //     } catch (error) {
  //       setState(() {
  //         _isLoading = false;
  //       });

  //       // Show network error message
  //       _showPopupMessage('Error',
  //           'Network error. Please check your connection and try again.');
  //     }
  //   }
  // }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Prepare request body
        final Map<String, dynamic> requestBody = {
          "Username": _usernameController.text,
          "Password": _passwordController.text,
        };

        // Make API call
        final response = await http.post(
          Uri.parse('https://divyangpcmc.altwise.in/api/aadhar/OfficeLogin'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(requestBody),
        );

        // Parse response
        final Map<String, dynamic> responseData = json.decode(response.body);

        setState(() {
          _isLoading = false;
        });

        // Handle different response statuses
        if (response.statusCode == 200) {
          if (responseData['Success'] == true) {
            // Extract UserId from response as String
            final String userId = responseData['Data']['UserId'].toString();

            // Show success message
            _showPopupMessage('Success',
                responseData['Message'] ?? 'Authentication successful');

            // Navigate to the next screen after a short delay
            Future.delayed(const Duration(seconds: 1), () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GetAadharDetailesScreen(userId: userId),
                ),
              );
            });
          } else {
            // Show error message from API
            _showPopupMessage(
                'Note', responseData['Message'] ?? 'Authentication failed');
          }
        } else if (response.statusCode == 401) {
          // Show unauthorized error message
          _showPopupMessage('Note',
              responseData['Message'] ?? 'Invalid username or password');
        } else {
          // Show generic error message for other status codes
          _showPopupMessage(
              'Note', 'An unexpected error occurred. Please try again.');
        }
      } catch (error) {
        setState(() {
          _isLoading = false;
        });

        // Show network error message
        _showPopupMessage('Error',
            'Network error. Please check your connection and try again.');
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
          title: Row(
            children: [
              // Icon(Icons.check_circle_outline, color: Colors.blue, size: 28),
              // SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Divider(thickness: 2.5),
              Text(
                message,
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              Divider(thickness: 2.5),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK', style: TextStyle(color: Colors.blue)),
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
        title: const Text(
          'Login Screen',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.yellow,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Container(
        decoration: const BoxDecoration(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 70),
              Text(
                'Login ',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 25),
              ),
              // Logo/Icon with container
              const SizedBox(height: 50),
              // Login card
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  side: BorderSide(
                    color:
                        Colors.yellow, // This creates the actual yellow border
                    width: 2.0, // Adjust the border thickness as needed
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Username Field
                        TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: 'Username',
                            labelStyle: const TextStyle(color: Colors.black),
                            prefixIcon:
                                const Icon(Icons.person, color: Colors.black),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: const BorderSide(color: Colors.black),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: const BorderSide(
                                  color: Colors.black, width: 2),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your username';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // Password Field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: const TextStyle(color: Colors.black),
                            prefixIcon:
                                const Icon(Icons.lock, color: Colors.black),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.black,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: const BorderSide(color: Colors.black),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: const BorderSide(
                                  color: Colors.black, width: 2),
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
                        const SizedBox(height: 24),
                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.yellow,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Login',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Sign up option
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account? ",
                    style: TextStyle(color: Colors.black),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Navigate to sign up screen
                    },
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
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

// import 'package:divyang_pimpri_chinchwad_municipal_corporation/office_login_screens/get_aadhar_detailes_screen.dart';
// import 'package:flutter/material.dart';

// class UserLoginScreen extends StatefulWidget {
//   const UserLoginScreen({super.key});

//   @override
//   State<UserLoginScreen> createState() => _UserLoginScreenState();
// }

// class _UserLoginScreenState extends State<UserLoginScreen> {
//   final TextEditingController _usernameController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();
//   bool _isPasswordVisible = false;
//   bool _isLoading = false;

//   // Simulate login process
//   void _login() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() {
//         _isLoading = true;
//       });

//       // Simulate network delay
//       await Future.delayed(const Duration(seconds: 2));

//       setState(() {
//         _isLoading = false;
//       });

//       // Navigate to the next screen
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => const GetAadharDetailesScreen(),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text(
//           'Login Screen',
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             color: Colors.black,
//           ),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.yellow,
//         elevation: 0,
//         iconTheme: const IconThemeData(color: Colors.black),
//       ),
//       body: Container(
//         decoration: const BoxDecoration(
//             // gradient: LinearGradient(
//             //   begin: Alignment.topCenter,
//             //   end: Alignment.bottomCenter,
//             //   colors: [
//             //     Colors.blue,
//             //     Colors.lightBlueAccent,
//             //   ],
//             // ),
//             ),
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             children: [
//               const SizedBox(height: 70),
//               Text(
//                 'Login ',
//                 style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black,
//                     fontSize: 25),
//               ),
//               // Logo/Icon with container
//               const SizedBox(height: 50),
//               // Login card
//               Card(
//                 elevation: 8,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16.0),
//                   side: BorderSide(
//                     color:
//                         Colors.yellow, // This creates the actual yellow border
//                     width: 2.0, // Adjust the border thickness as needed
//                   ),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(24.0),
//                   child: Form(
//                     key: _formKey,
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         // Username Field
//                         TextFormField(
//                           controller: _usernameController,
//                           decoration: InputDecoration(
//                             labelText: 'Username',
//                             labelStyle: const TextStyle(color: Colors.black),
//                             prefixIcon:
//                                 const Icon(Icons.person, color: Colors.black),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(8.0),
//                               borderSide: const BorderSide(color: Colors.black),
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(8.0),
//                               borderSide: const BorderSide(
//                                   color: Colors.black, width: 2),
//                             ),
//                           ),
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please enter your username';
//                             }
//                             return null;
//                           },
//                         ),
//                         const SizedBox(height: 16),
//                         // Password Field
//                         TextFormField(
//                           controller: _passwordController,
//                           obscureText: !_isPasswordVisible,
//                           decoration: InputDecoration(
//                             labelText: 'Password',
//                             labelStyle: const TextStyle(color: Colors.black),
//                             prefixIcon:
//                                 const Icon(Icons.lock, color: Colors.black),
//                             suffixIcon: IconButton(
//                               icon: Icon(
//                                 _isPasswordVisible
//                                     ? Icons.visibility
//                                     : Icons.visibility_off,
//                                 color: Colors.black,
//                               ),
//                               onPressed: () {
//                                 setState(() {
//                                   _isPasswordVisible = !_isPasswordVisible;
//                                 });
//                               },
//                             ),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(8.0),
//                               borderSide: const BorderSide(color: Colors.black),
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(8.0),
//                               borderSide: const BorderSide(
//                                   color: Colors.black, width: 2),
//                             ),
//                           ),
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please enter your password';
//                             }
//                             if (value.length < 6) {
//                               return 'Password must be at least 6 characters';
//                             }
//                             return null;
//                           },
//                         ),
//                         const SizedBox(height: 24),
//                         // Login Button
//                         SizedBox(
//                           width: double.infinity,
//                           height: 50,
//                           child: ElevatedButton(
//                             onPressed: _isLoading ? null : _login,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.yellow,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8.0),
//                               ),
//                               padding: const EdgeInsets.symmetric(vertical: 14),
//                             ),
//                             child: _isLoading
//                                 ? const SizedBox(
//                                     width: 20,
//                                     height: 20,
//                                     child: CircularProgressIndicator(
//                                       strokeWidth: 2,
//                                       valueColor: AlwaysStoppedAnimation<Color>(
//                                           Colors.white),
//                                     ),
//                                   )
//                                 : const Text(
//                                     'Login',
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.black,
//                                     ),
//                                   ),
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         // Forgot Password
//                         // TextButton(
//                         //   onPressed: () {
//                         //     // Forgot password functionality
//                         //   },
//                         //   child: const Text(
//                         //     'Forgot Password?',
//                         //     style: TextStyle(color: Colors.black),
//                         //   ),
//                         // ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               // Sign up option
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Text(
//                     "Don't have an account? ",
//                     style: TextStyle(color: Colors.white),
//                   ),
//                   GestureDetector(
//                     onTap: () {
//                       // Navigate to sign up screen
//                     },
//                     child: const Text(
//                       'Sign Up',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _usernameController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }
// }

// import 'package:flutter/material.dart';

// class UserLoginScreen extends StatefulWidget {
//   const UserLoginScreen({super.key});

//   @override
//   State<UserLoginScreen> createState() => _UserLoginScreenState();
// }

// class _UserLoginScreenState extends State<UserLoginScreen> {
//   final TextEditingController _usernameController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();
//   bool _isPasswordVisible = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24.0),
//           child: Card(
//             elevation: 4,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16.0),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(24.0),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     // App Icon/Logo
//                     const Icon(
//                       Icons.business,
//                       size: 64,
//                       color: Colors.blue,
//                     ),
//                     const SizedBox(height: 16),
//                     // Title
//                     const Text(
//                       'Office Login',
//                       style: TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 24),
//                     // Username Field
//                     TextFormField(
//                       controller: _usernameController,
//                       decoration: InputDecoration(
//                         labelText: 'Username',
//                         prefixIcon: const Icon(Icons.person),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8.0),
//                         ),
//                       ),
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter your username';
//                         }
//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 16),
//                     // Password Field
//                     TextFormField(
//                       controller: _passwordController,
//                       obscureText: !_isPasswordVisible,
//                       decoration: InputDecoration(
//                         labelText: 'Password',
//                         prefixIcon: const Icon(Icons.lock),
//                         suffixIcon: IconButton(
//                           icon: Icon(
//                             _isPasswordVisible
//                                 ? Icons.visibility
//                                 : Icons.visibility_off,
//                           ),
//                           onPressed: () {
//                             setState(() {
//                               _isPasswordVisible = !_isPasswordVisible;
//                             });
//                           },
//                         ),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8.0),
//                         ),
//                       ),
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter your password';
//                         }
//                         if (value.length < 6) {
//                           return 'Password must be at least 6 characters';
//                         }
//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 24),
//                     // Login Button
//                     SizedBox(
//                       width: double.infinity,
//                       height: 50,
//                       child: ElevatedButton(
//                         onPressed: () {
//                           if (_formKey.currentState!.validate()) {
//                             // Navigate to the next screen
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => const HomeScreen(),
//                               ),
//                             );
//                           }
//                         },
//                         style: ElevatedButton.styleFrom(
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8.0),
//                           ),
//                         ),
//                         child: const Text(
//                           'Login',
//                           style: TextStyle(fontSize: 16),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     // Forgot Password
//                     TextButton(
//                       onPressed: () {
//                         // Forgot password functionality
//                       },
//                       child: const Text('Forgot Password?'),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _usernameController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }
// }

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Home Screen'),
//       ),
//       body: const Center(
//         child: Text(
//           'Welcome to the Office Dashboard!',
//           style: TextStyle(fontSize: 20),
//         ),
//       ),
//     );
//   }
// }

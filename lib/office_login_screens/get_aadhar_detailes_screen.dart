import 'dart:convert';

import 'package:divyang_pimpri_chinchwad_municipal_corporation/office_login_screens/divyang_detailes_officelogin_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class GetAadharDetailesScreen extends StatefulWidget {
  final String userId;
  const GetAadharDetailesScreen({super.key, required this.userId});

  @override
  State<GetAadharDetailesScreen> createState() =>
      _GetAadharDetailesScreenState();
}

class _GetAadharDetailesScreenState extends State<GetAadharDetailesScreen> {
  final TextEditingController _aadharController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  Map<String, dynamic>? _apiResponse;
  String _errorMessage = '';
  // bool _showKYCButton = false;

  // Validate Aadhar number (basic validation for 12 digits)
  String? _validateAadhar(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your Aadhar number';
    }
    if (value.length != 12) {
      return 'Aadhar number must be 12 digits';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Aadhar number must contain only digits';
    }
    return null;
  }

  Future<void> _callAadharAPI(String aadharNumber) async {
    setState(() {
      _isLoading = true;
      _apiResponse = null;
      _errorMessage = '';
      // _showKYCButton = false;
    });

    try {
      final url = Uri.parse(
          'http://103.224.247.133:8085/BSUPN/rest/service/getbyAadharNumber?aadharnumber=$aadharNumber');
      final response = await http.get(url);

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          _apiResponse = data;
        });

        // Check the response code from the API
        if (data['code'] == "200") {
          // Automatically navigate to the next screen
          _navigateToPhotoClickScreen();
        } else if (data['code'] == "201") {
          // Show popup with the message
          _showPopupMessage(
            'Note',
            data['message'] ?? 'Data not found for this Aadhar number',
          );
        }
      } else {
        setState(() {
          _errorMessage =
              'Failed to fetch data. Status code: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });

      _showPopupMessage('Exception', e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToPhotoClickScreen() {
    if (_apiResponse != null && _apiResponse!['code'] == "200") {
      final List<dynamic> dataList =
          _apiResponse!['allData'] is List ? _apiResponse!['allData'] : [];
      if (dataList.isNotEmpty) {
        final aadharData = dataList.first;

        // Extract all fields with null safety
        final String avakNo = aadharData['avakNo']?.toString() ?? 'N/A';
        final String adharNo = aadharData['adharNo']?.toString() ?? 'N/A';
        final String name = aadharData['name']?.toString() ?? 'N/A';
        final String mobileNo = aadharData['mobileNo']?.toString() ?? 'N/A';
        final String uniqueKey = aadharData['uniqueKey']?.toString() ?? 'N/A';

        // Navigate to DivyangDetailesOfficeloginScreen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DivyangDetailesOfficeloginScreen(
              userId: widget.userId,
              avakNo: avakNo,
              adharNo: adharNo,
              name: name,
              mobileNo: mobileNo,
              uniqueKey: uniqueKey,
              lastSubmit: '',
            ),
          ),
        );
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
              Icon(Icons.info_outline, color: Colors.blue, size: 28),
              SizedBox(width: 10),
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

  // Handle form submission
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _callAadharAPI(_aadharController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Aadhar Details',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.yellow,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'User ID is: ${widget.userId}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Enter Aadhar Number (आधार क्रमांक टाका):',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _aadharController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(12),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Aadhar Number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.yellow),
                      ),
                      hintText: 'Enter 12-digit Aadhar number',
                    ),
                    validator: _validateAadhar,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Enter your 12-digit Aadhar number without spaces',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'SUBMIT AADHAR NUMBER',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Display API response or error
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _aadharController.dispose();
    super.dispose();
  }
}

// import 'dart:convert';

// import 'package:divyang_pimpri_chinchwad_municipal_corporation/office_login_screens/divyang_detailes_officelogin_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;

// class GetAadharDetailesScreen extends StatefulWidget {
//   final String userId;
//   const GetAadharDetailesScreen({super.key, required this.userId});

//   @override
//   State<GetAadharDetailesScreen> createState() =>
//       _GetAadharDetailesScreenState();
// }

// class _GetAadharDetailesScreenState extends State<GetAadharDetailesScreen> {
//   final TextEditingController _aadharController = TextEditingController();
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   bool _isLoading = false;
//   Map<String, dynamic>? _apiResponse;
//   String _errorMessage = '';
//   bool _showKYCButton = false; // New flag to control KYC button visibility

//   // Validate Aadhar number (basic validation for 12 digits)
//   String? _validateAadhar(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Please enter your Aadhar number';
//     }
//     if (value.length != 12) {
//       return 'Aadhar number must be 12 digits';
//     }
//     if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
//       return 'Aadhar number must contain only digits';
//     }
//     return null;
//   }

//   Future<void> _callAadharAPI(String aadharNumber) async {
//     setState(() {
//       _isLoading = true;
//       _apiResponse = null;
//       _errorMessage = '';
//       _showKYCButton = false; // Reset KYC button visibility
//     });

//     try {
//       final url = Uri.parse(
//           'http://103.224.247.133:8085/BSUPN/rest/service/getbyAadharNumber?aadharnumber=$aadharNumber');
//       final response = await http.get(url);

//       print('Status Code: ${response.statusCode}');
//       print('Response Body: ${response.body}');

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = json.decode(response.body);
//         setState(() {
//           _apiResponse = data;
//         });

//         // Check the response code from the API
//         if (data['code'] == "200") {
//           setState(() {
//             _showKYCButton = true; // Show KYC button on successful response
//           });
//         } else if (data['code'] == "201") {
//           // Show popup with the message
//           _showPopupMessage(
//             'Note',
//             data['message'] ?? 'Data not found for this Aadhar number',
//           );
//         }
//       } else {
//         setState(() {
//           _errorMessage =
//               'Failed to fetch data. Status code: ${response.statusCode}';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Error: ${e.toString()}';
//       });

//       _showPopupMessage('Exception', e.toString());
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   void _navigateToPhotoClickScreen() {
//     if (_apiResponse != null && _apiResponse!['code'] == "200") {
//       final List<dynamic> dataList =
//           _apiResponse!['allData'] is List ? _apiResponse!['allData'] : [];
//       if (dataList.isNotEmpty) {
//         final aadharData = dataList.first;

//         // Extract all fields with null safety
//         final String avakNo = aadharData['avakNo']?.toString() ?? 'N/A';
//         final String adharNo = aadharData['adharNo']?.toString() ?? 'N/A';
//         final String name = aadharData['name']?.toString() ?? 'N/A';
//         final String mobileNo = aadharData['mobileNo']?.toString() ?? 'N/A';
//         final String uniqueKey = aadharData['uniqueKey']?.toString() ?? 'N/A';

//         // Navigate to PhotoClickScreen and pass all fields separately
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => DivyangDetailesOfficeloginScreen(
//               userId: widget.userId,
//               avakNo: avakNo,
//               adharNo: adharNo,
//               name: name,
//               mobileNo: mobileNo,
//               uniqueKey: uniqueKey,
//               lastSubmit: '',
//             ),
//           ),
//         );
//       }
//     }
//   }

//   void _showPopupMessage(String title, String message) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20.0),
//           ),
//           title: Row(
//             children: [
//               Icon(Icons.info_outline, color: Colors.blue, size: 28),
//               SizedBox(width: 10),
//               Text(
//                 title,
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//             ],
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Divider(thickness: 2.5),
//               Text(
//                 message,
//                 style: TextStyle(fontSize: 16),
//                 textAlign: TextAlign.center,
//               ),
//               Divider(thickness: 2.5),
//             ],
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text('OK', style: TextStyle(color: Colors.blue)),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // Handle form submission
//   void _submitForm() {
//     if (_formKey.currentState!.validate()) {
//       _callAadharAPI(_aadharController.text);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text(
//             'Aadhar Details',
//             style: TextStyle(color: Colors.black),
//           ),
//           backgroundColor: Colors.yellow,
//         ),
//         body: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(20.0),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const SizedBox(height: 20),
//                   Text(
//                     'User ID is: ${widget.userId}',
//                     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 20),
//                   const Text(
//                     'Enter Aadhar Number (आधार क्रमांक टाका):',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   TextFormField(
//                     controller: _aadharController,
//                     keyboardType: TextInputType.number,
//                     inputFormatters: [
//                       FilteringTextInputFormatter.digitsOnly,
//                       LengthLimitingTextInputFormatter(12),
//                     ],
//                     decoration: InputDecoration(
//                       labelText: 'Aadhar Number',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(8),
//                         borderSide: const BorderSide(color: Colors.yellow),
//                       ),
//                       hintText: 'Enter 12-digit Aadhar number',
//                     ),
//                     validator: _validateAadhar,
//                   ),
//                   const SizedBox(height: 10),
//                   const Text(
//                     'Enter your 12-digit Aadhar number without spaces',
//                     style: TextStyle(
//                       color: Colors.grey,
//                       fontSize: 13,
//                     ),
//                   ),
//                   const SizedBox(height: 30),
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed: _isLoading ? null : _submitForm,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.yellow,
//                         padding: const EdgeInsets.symmetric(vertical: 16),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                       child: _isLoading
//                           ? const SizedBox(
//                               width: 20,
//                               height: 20,
//                               child: CircularProgressIndicator(
//                                 color: Colors.white,
//                                 strokeWidth: 2,
//                               ),
//                             )
//                           : const Text(
//                               'SUBMIT AADHAR NUMBER',
//                               style: TextStyle(
//                                 color: Colors.black,
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                     ),
//                   ),
//                   const SizedBox(height: 20),

//                   // Display API response or error
//                   if (_isLoading)
//                     const Center(child: CircularProgressIndicator())
//                   else if (_errorMessage.isNotEmpty)
//                     Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 16.0),
//                       child: Text(
//                         _errorMessage,
//                         style: const TextStyle(color: Colors.red, fontSize: 16),
//                       ),
//                     )
//                   else if (_apiResponse != null)
//                     _buildResponseUI(),

//                   // KYC Button - Only show when response is successful
//                   if (_showKYCButton)
//                     Padding(
//                       padding: const EdgeInsets.only(top: 30.0),
//                       child: SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           onPressed: _navigateToPhotoClickScreen,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.green,
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                           ),
//                           child: const Text(
//                             'COMPLETE YOUR KYC',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildResponseUI() {
//     final code = _apiResponse!['code'];
//     final message = _apiResponse!['message'];

//     // Handle null or non-list allData safely
//     final allData = _apiResponse!['allData'];
//     final List<dynamic> dataList = allData is List ? allData : [];

//     if (code != "200" || dataList.isEmpty) {
//       return Padding(
//         padding: const EdgeInsets.symmetric(vertical: 16.0),
//         child: Text(
//           message.isNotEmpty ? message : 'No data found for this Aadhar number',
//           style: const TextStyle(color: Colors.red, fontSize: 16),
//         ),
//       );
//     }

//     final data = dataList.first;

//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16.0),
//       decoration: BoxDecoration(
//         color: Colors.grey[100],
//         borderRadius: BorderRadius.circular(8.0),
//         border: Border.all(color: Colors.yellow),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Aadhar Details:',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.green,
//             ),
//           ),
//           const SizedBox(height: 16),
//           _buildDetailRow('Avak Number', data['avakNo']?.toString() ?? 'N/A'),
//           _buildDetailRow(
//               'Aadhar Number', data['adharNo']?.toString() ?? 'N/A'),
//           _buildDetailRow('Name', data['name']?.toString() ?? 'N/A'),
//           _buildDetailRow(
//               'Mobile Number', data['mobileNo']?.toString() ?? 'N/A'),
//           _buildDetailRow('Unique Key', data['uniqueKey']?.toString() ?? 'N/A'),
//         ],
//       ),
//     );
//   }

//   Widget _buildDetailRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 120,
//             child: Text(
//               '$label:',
//               style: const TextStyle(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(
//                 fontSize: 16,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _aadharController.dispose();
//     super.dispose();
//   }
// }


// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;

// import 'photo_click_screen.dart'; // Import the PhotoClickScreen

// class GetAadharDetailesScreen extends StatefulWidget {
//   final String userId;
//   const GetAadharDetailesScreen({super.key, required this.userId});

//   @override
//   State<GetAadharDetailesScreen> createState() =>
//       _GetAadharDetailesScreenState();
// }

// class _GetAadharDetailesScreenState extends State<GetAadharDetailesScreen> {
//   final TextEditingController _aadharController = TextEditingController();
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   bool _isLoading = false;
//   Map<String, dynamic>? _apiResponse;
//   String _errorMessage = '';

//   // Validate Aadhar number (basic validation for 12 digits)
//   String? _validateAadhar(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Please enter your Aadhar number';
//     }
//     if (value.length != 12) {
//       return 'Aadhar number must be 12 digits';
//     }
//     if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
//       return 'Aadhar number must contain only digits';
//     }
//     return null;
//   }

//   Future<void> _callAadharAPI(String aadharNumber) async {
//     setState(() {
//       _isLoading = true;
//       _apiResponse = null;
//       _errorMessage = '';
//     });

//     try {
//       final url = Uri.parse(
//           'http://103.224.247.133:8085/BSUPN/rest/service/getbyAadharNumber?aadharnumber=$aadharNumber');
//       final response = await http.get(url);

//       print('Status Code: ${response.statusCode}');
//       print('Response Body: ${response.body}');

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = json.decode(response.body);
//         setState(() {
//           _apiResponse = data;
//         });

//         // Check the response code from the API
//         if (data['code'] == "200") {
//           final List<dynamic> dataList = data['allData'] is List ? data['allData'] : [];
//           if (dataList.isNotEmpty) {
//             final aadharData = dataList.first;
            
//             // Extract all fields with null safety
//             final String avakNo = aadharData['avakNo']?.toString() ?? 'N/A';
//             final String adharNo = aadharData['adharNo']?.toString() ?? 'N/A';
//             final String name = aadharData['name']?.toString() ?? 'N/A';
//             final String mobileNo = aadharData['mobileNo']?.toString() ?? 'N/A';
//             final String uniqueKey = aadharData['uniqueKey']?.toString() ?? 'N/A';
            
//             // Navigate to PhotoClickScreen and pass all fields separately
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => PhotoClickScreen(
//                   userId: widget.userId,
//                   avakNo: avakNo,
//                   adharNo: adharNo,
//                   name: name,
//                   mobileNo: mobileNo,
//                   uniqueKey: uniqueKey, lastSubmit: '',
//                 ),
//               ),
//             );
//           }
//         } else if (data['code'] == "201") {
//           // Show popup with the message
//           _showPopupMessage(
//             'Note',
//             data['message'] ?? 'Data not found for this Aadhar number',
//           );
//         }
//       } else {
//         setState(() {
//           _errorMessage =
//               'Failed to fetch data. Status code: ${response.statusCode}';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Error: ${e.toString()}';
//       });

//       _showPopupMessage('Exception', e.toString());
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   void _showPopupMessage(String title, String message) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20.0),
//           ),
//           title: Row(
//             children: [
//               Icon(Icons.info_outline, color: Colors.blue, size: 28),
//               SizedBox(width: 10),
//               Text(
//                 title,
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//             ],
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Divider(thickness: 2.5),
//               Text(
//                 message,
//                 style: TextStyle(fontSize: 16),
//                 textAlign: TextAlign.center,
//               ),
//               Divider(thickness: 2.5),
//             ],
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text('OK', style: TextStyle(color: Colors.blue)),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // Handle form submission
//   void _submitForm() {
//     if (_formKey.currentState!.validate()) {
//       _callAadharAPI(_aadharController.text);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text(
//             'Aadhar Details',
//             style: TextStyle(color: Colors.black),
//           ),
//           backgroundColor: Colors.yellow,
//         ),
//         body: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(20.0),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const SizedBox(height: 20),
//                   Text(
//                     'User ID is: ${widget.userId}',
//                     style: TextStyle(
//                         fontSize: 20, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 20),
//                   const Text(
//                     'Enter Aadhar Number (आधार क्रमांक टाका):',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   TextFormField(
//                     controller: _aadharController,
//                     keyboardType: TextInputType.number,
//                     inputFormatters: [
//                       FilteringTextInputFormatter.digitsOnly,
//                       LengthLimitingTextInputFormatter(12),
//                     ],
//                     decoration: InputDecoration(
//                       labelText: 'Aadhar Number',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(8),
//                         borderSide:
//                             const BorderSide(color: Colors.yellow),
//                       ),
//                       hintText: 'Enter 12-digit Aadhar number',
//                     ),
//                     validator: _validateAadhar,
//                   ),
//                   const SizedBox(height: 10),
//                   const Text(
//                     'Enter your 12-digit Aadhar number without spaces',
//                     style: TextStyle(
//                       color: Colors.grey,
//                       fontSize: 13,
//                     ),
//                   ),
//                   const SizedBox(height: 30),
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed: _isLoading ? null : _submitForm,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.yellow,
//                         padding: const EdgeInsets.symmetric(vertical: 16),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                       child: _isLoading
//                           ? const SizedBox(
//                               width: 20,
//                               height: 20,
//                               child: CircularProgressIndicator(
//                                 color: Colors.white,
//                                 strokeWidth: 2,
//                               ),
//                             )
//                           : const Text(
//                               'SUBMIT AADHAR NUMBER',
//                               style: TextStyle(
//                                 color: Colors.black,
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                     ),
//                   ),
//                   const SizedBox(height: 20),

//                   // Display API response or error
//                   if (_isLoading)
//                     const Center(child: CircularProgressIndicator())
//                   else if (_errorMessage.isNotEmpty)
//                     Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 16.0),
//                       child: Text(
//                         _errorMessage,
//                         style: const TextStyle(
//                             color: Colors.red, fontSize: 16),
//                       ),
//                     )
//                   else if (_apiResponse != null)
//                     _buildResponseUI(),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildResponseUI() {
//     final code = _apiResponse!['code'];
//     final message = _apiResponse!['message'];

//     // Handle null or non-list allData safely
//     final allData = _apiResponse!['allData'];
//     final List<dynamic> dataList = allData is List ? allData : [];

//     if (code != "200" || dataList.isEmpty) {
//       return Padding(
//         padding: const EdgeInsets.symmetric(vertical: 16.0),
//         child: Text(
//           message.isNotEmpty ? message : 'No data found for this Aadhar number',
//           style: const TextStyle(color: Colors.red, fontSize: 16),
//         ),
//       );
//     }

//     final data = dataList.first;

//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16.0),
//       decoration: BoxDecoration(
//         color: Colors.grey[100],
//         borderRadius: BorderRadius.circular(8.0),
//         border: Border.all(color: Colors.yellow),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Aadhar Details:',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.green,
//             ),
//           ),
//           const SizedBox(height: 16),
//           _buildDetailRow('Avak Number', data['avakNo']?.toString() ?? 'N/A'),
//           _buildDetailRow('Aadhar Number', data['adharNo']?.toString() ?? 'N/A'),
//           _buildDetailRow('Name', data['name']?.toString() ?? 'N/A'),
//           _buildDetailRow(
//               'Mobile Number', data['mobileNo']?.toString() ?? 'N/A'),
//           _buildDetailRow('Unique Key', data['uniqueKey']?.toString() ?? 'N/A'),
//         ],
//       ),
//     );
//   }

//   Widget _buildDetailRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 120,
//             child: Text(
//               '$label:',
//               style: const TextStyle(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(
//                 fontSize: 16,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _aadharController.dispose();
//     super.dispose();
//   }
// }


// import 'dart:convert';

// import 'package:divyang_pimpri_chinchwad_municipal_corporation/office_login_screens/photo_click_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;

// class GetAadharDetailesScreen extends StatefulWidget {
//   final String userId;
//   //  final String lastSubmit;
//   const GetAadharDetailesScreen({super.key, required this.userId, });

//   @override
//   State<GetAadharDetailesScreen> createState() =>
//       _GetAadharDetailesScreenState();
// }

// class _GetAadharDetailesScreenState extends State<GetAadharDetailesScreen> {
//   final TextEditingController _aadharController = TextEditingController();
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   bool _isLoading = false;
//   Map<String, dynamic>? _apiResponse;
//   String _errorMessage = '';
//   bool _showKYCButton = false; 
//   // Add this flag to control KYC button visibility

//   // Validate Aadhar number (basic validation for 12 digits)
//   String? _validateAadhar(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Please enter your Aadhar number';
//     }
//     if (value.length != 12) {
//       return 'Aadhar number must be 12 digits';
//     }
//     if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
//       return 'Aadhar number must contain only digits';
//     }
//     return null;
//   }

//   // Future<void> _callAadharAPI(String aadharNumber) async {
//   //   setState(() {
//   //     _isLoading = true;
//   //     _apiResponse = null;
//   //     _errorMessage = '';
//   //     _showKYCButton = false; // Reset KYC button flag
//   //   });

//   //   try {
//   //     final url = Uri.parse(
//   //         'http://103.224.247.133:8085/BSUPN/rest/service/getbyAadharNumber?aadharnumber=$aadharNumber');
//   //     final response = await http.get(url);

//   //     print('Status Code: ${response.statusCode}');
//   //     print('Response Body: ${response.body}');

//   //     if (response.statusCode == 200) {
//   //       final Map<String, dynamic> data = json.decode(response.body);
//   //       setState(() {
//   //         _apiResponse = data;
//   //       });

//   //       // Check the response code from the API
//   //       if (data['code'] == "200") {
//   //         // Show KYC button when response is successful
//   //         setState(() {
//   //           _showKYCButton = true;
//   //         });

//   //         // Navigate to another screen (PhotoScreen) and pass the data
//   //         // Navigator.push(
//   //         //   context,
//   //         //   MaterialPageRoute(
//   //         //     builder: (context) => PhotoClickScreen(),
//   //         //   ),
//   //         // );
//   //       } else if (data['code'] == "201") {
//   //         // Show popup with the message
//   //         _showPopupMessage(
//   //             'Note',
//   //             data['Data not found for this Aadhar number'] ??
//   //                 'Data not found for this Aadhar number');
//   //       }
//   //     } else {
//   //       setState(() {
//   //         _errorMessage =
//   //             'Failed to fetch data. Status code: ${response.statusCode}';
//   //       });
//   //     }
//   //   } catch (e) {
//   //     setState(() {
//   //       _errorMessage = 'Error: ${e.toString()}';
//   //     });

//   //     _showPopupMessage('Exception', e.toString());
//   //   } finally {
//   //     setState(() {
//   //       _isLoading = false;
//   //     });
//   //   }
//   // }

//   Future<void> _callAadharAPI(String aadharNumber) async {
//   setState(() {
//     _isLoading = true;
//     _apiResponse = null;
//     _errorMessage = '';
//   });

//   try {
//     final url = Uri.parse(
//         'http://103.224.247.133:8085/BSUPN/rest/service/getbyAadharNumber?aadharnumber=$aadharNumber');
//     final response = await http.get(url);

//     print('Status Code: ${response.statusCode}');
//     print('Response Body: ${response.body}');

//     if (response.statusCode == 200) {
//       final Map<String, dynamic> data = json.decode(response.body);
//       setState(() {
//         _apiResponse = data;
//       });

//       // Check the response code from the API
//       if (data['code'] == "200") {
//         final List<dynamic> dataList = data['allData'] is List ? data['allData'] : [];
//         if (dataList.isNotEmpty) {
//           final aadharData = dataList.first;
          
//           // Extract individual fields
//           final String avakNo = aadharData['avakNo']?.toString() ?? '';
//           final String adharNo = aadharData['adharNo']?.toString() ?? '';
//           final String name = aadharData['name']?.toString() ?? '';
//           final String mobileNo = aadharData['mobileNo']?.toString() ?? '';
//           final String uniqueKey = aadharData['uniqueKey']?.toString() ?? '';
          
//           // Navigate to PhotoClickScreen and pass all fields separately
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => PhotoClickScreen(
//                 userId: widget.userId,
//                 avakNo: avakNo,
//                 adharNo: adharNo,
//                 name: name,
//                 mobileNo: mobileNo,
//                 uniqueKey: uniqueKey,
//                  lastSubmit: "",
//               ),
//             ),
//           );
//         }
//       } else if (data['code'] == "201") {
//         // Show popup with the message
//         _showPopupMessage(
//             'Note',
//             data['Data not found for this Aadhar number'] ??
//                 'Data not found for this Aadhar number');
//       }
//     } else {
//       setState(() {
//         _errorMessage =
//             'Failed to fetch data. Status code: ${response.statusCode}';
//       });
//     }
//   } catch (e) {
//     setState(() {
//       _errorMessage = 'Error: ${e.toString()}';
//     });

//     _showPopupMessage('Exception', e.toString());
//   } finally {
//     setState(() {
//       _isLoading = false;
//     });
//   }
// }

//   void _showPopupMessage(String title, String message) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20.0),
//           ),
//           title: Row(
//             children: [
//               Icon(Icons.check_circle_outline, color: Colors.blue, size: 28),
//               SizedBox(width: 10),
//               Text(
//                 title,
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//             ],
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Divider(thickness: 2.5),
//               Text(
//                 message,
//                 style: TextStyle(fontSize: 16),
//                 textAlign: TextAlign.center,
//               ),
//               Divider(thickness: 2.5),
//             ],
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text('OK', style: TextStyle(color: Colors.blue)),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // Handle form submission
//   void _submitForm() {
//     if (_formKey.currentState!.validate()) {
//       _callAadharAPI(_aadharController.text);
//     }
//   }

//   // Handle KYC button press
//   void _onKYCButtonPressed() {
//     // Add your KYC completion logic here
//     print("Complete KYC button pressed");
//     // You can navigate to a KYC screen or show a dialog
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text(
//             'Aadhar Details',
//             style: TextStyle(color: Colors.black),
//           ),
//           backgroundColor: Colors.yellow,
//         ),
//         body: Column(
//           children: [
//             Expanded(
//               child: SingleChildScrollView(
//                 child: Padding(
//                   padding: const EdgeInsets.all(20.0),
//                   child: Form(
//                     key: _formKey,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const SizedBox(height: 20),
//                         Text(
//                           'User ID is: ${widget.userId}',
//                           style: TextStyle(
//                               fontSize: 20, fontWeight: FontWeight.bold),
//                         ),
//                         const Text(
//                           'Enter Aadhar Number (आधार क्रमांक टाका):',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 20),
//                         TextFormField(
//                           controller: _aadharController,
//                           keyboardType: TextInputType.number,
//                           inputFormatters: [
//                             FilteringTextInputFormatter.digitsOnly,
//                             LengthLimitingTextInputFormatter(12),
//                           ],
//                           decoration: InputDecoration(
//                             labelText: 'Aadhar Number',
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(8),
//                               borderSide:
//                                   const BorderSide(color: Colors.yellow),
//                             ),
//                             hintText: 'Enter 12-digit Aadhar number',
//                           ),
//                           validator: _validateAadhar,
//                         ),
//                         const SizedBox(height: 10),
//                         const Text(
//                           'Enter your 12-digit Aadhar number without spaces',
//                           style: TextStyle(
//                             color: Colors.grey,
//                             fontSize: 13,
//                           ),
//                         ),
//                         const SizedBox(height: 30),
//                         SizedBox(
//                           width: double.infinity,
//                           child: ElevatedButton(
//                             onPressed: _isLoading ? null : _submitForm,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.yellow,
//                               padding: const EdgeInsets.symmetric(vertical: 16),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                             ),
//                             child: _isLoading
//                                 ? const SizedBox(
//                                     width: 20,
//                                     height: 20,
//                                     child: CircularProgressIndicator(
//                                       color: Colors.white,
//                                       strokeWidth: 2,
//                                     ),
//                                   )
//                                 : const Text(
//                                     'SUBMIT AADHAR NUMBER',
//                                     style: TextStyle(
//                                       color: Colors.black,
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                           ),
//                         ),
//                         const SizedBox(height: 20),

//                         // Display API response or error
//                         if (_isLoading)
//                           const Center(child: CircularProgressIndicator())
//                         // else if (_errorMessage.isNotEmpty)
//                         //   Padding(
//                         //     padding: const EdgeInsets.symmetric(vertical: 16.0),
//                         //     child: Text(
//                         //       _errorMessage,
//                         //       style: const TextStyle(
//                         //           color: Colors.red, fontSize: 16),
//                         //     ),
//                         //   )
//                         else if (_apiResponse != null)
//                           _buildResponseUI(),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),

//             // Add KYC button at the bottom when response is 200
//             if (_showKYCButton)
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(16.0),
//                 child: ElevatedButton(
//                   onPressed: _onKYCButtonPressed,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green,
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   child: const Text(
//                     'COMPLETE YOUR KYC',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildResponseUI() {
//     final code = _apiResponse!['code'];
//     final message = _apiResponse!['message'];

//     // Handle null or non-list allData safely
//     final allData = _apiResponse!['allData'];
//     final List<dynamic> dataList = allData is List ? allData : [];

//     if (code != "200" || dataList.isEmpty) {
//       return Padding(
//         padding: const EdgeInsets.symmetric(vertical: 16.0),
//         child: Text(
//           message.isNotEmpty ? message : 'No data found for this Aadhar number',
//           style: const TextStyle(color: Colors.red, fontSize: 16),
//         ),
//       );
//     }

//     final data = dataList.first;

//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16.0),
//       decoration: BoxDecoration(
//         color: Colors.grey[100],
//         borderRadius: BorderRadius.circular(8.0),
//         border: Border.all(color: Colors.yellow),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Aadhar Details:',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.green,
//             ),
//           ),
//           const SizedBox(height: 16),
//           // _buildDetailRow('Avak Number', data['avakNo']),
//           // _buildDetailRow('Aadhar Number', data['adharNo']),
//           _buildDetailRow('Name', data['name']?.toString() ?? 'N/A'),
//           _buildDetailRow(
//               'Mobile Number', data['mobileNo']?.toString() ?? 'N/A'),
//           // _buildDetailRow('Unique Key', data['uniqueKey']),
//         ],
//       ),
//     );
//   }

//   Widget _buildDetailRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 120,
//             child: Text(
//               '$label:',
//               style: const TextStyle(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(
//                 fontSize: 16,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _aadharController.dispose();
//     super.dispose();
//   }
// }

// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;

// class GetAadharDetailesScreen extends StatefulWidget {
//   const GetAadharDetailesScreen({super.key});

//   @override
//   State<GetAadharDetailesScreen> createState() =>
//       _GetAadharDetailesScreenState();
// }

// class _GetAadharDetailesScreenState extends State<GetAadharDetailesScreen> {
//   final TextEditingController _aadharController = TextEditingController();
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   bool _isLoading = false;
//   Map<String, dynamic>? _apiResponse;
//   String _errorMessage = '';

//   // Validate Aadhar number (basic validation for 12 digits)
//   String? _validateAadhar(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Please enter your Aadhar number';
//     }
//     if (value.length != 12) {
//       return 'Aadhar number must be 12 digits';
//     }
//     if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
//       return 'Aadhar number must contain only digits';
//     }
//     return null;
//   }

//   Future<void> _callAadharAPI(String aadharNumber) async {
//     setState(() {
//       _isLoading = true;
//       _apiResponse = null;
//       _errorMessage = '';
//     });

//     try {
//       final url = Uri.parse(
//           'http://103.224.247.133:8085/BSUPN/rest/service/getbyAadharNumber?aadharnumber=$aadharNumber');
//       final response = await http.get(url);

//       print('Status Code: ${response.statusCode}');
//       print('Response Body: ${response.body}');

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = json.decode(response.body);
//         setState(() {
//           _apiResponse = data;
//         });

//         // Check the response code from the API
//         if (data['code'] == "200") {
//           // Navigate to another screen (PhotoScreen) and pass the data
//           // Navigator.push(
//           //   context,
//           //   MaterialPageRoute(
//           //     builder: (context) => PhotoScreen(aadharData: data),
//           //   ),
//           // );
//         } else if (data['code'] == "201") {
//           // Show popup with the message
//           _showPopupMessage(
//               'Note',
//               data['Data not found for this Aadhar number'] ??
//                   'Data not found for this Aadhar number');
//         }
//       } else {
//         setState(() {
//           _errorMessage =
//               'Failed to fetch data. Status code: ${response.statusCode}';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Error: ${e.toString()}';
//       });

//       _showPopupMessage('Exception', e.toString());
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   void _showPopupMessage(String title, String message) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20.0),
//           ),
//           title: Row(
//             children: [
//               Icon(Icons.check_circle_outline, color: Colors.blue, size: 28),
//               SizedBox(width: 10),
//               Text(
//                 title,
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//             ],
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Divider(thickness: 2.5),
//               Text(
//                 message,
//                 style: TextStyle(fontSize: 16),
//                 textAlign: TextAlign.center,
//               ),
//               Divider(thickness: 2.5),
//             ],
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text('OK', style: TextStyle(color: Colors.blue)),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // Handle form submission
//   void _submitForm() {
//     if (_formKey.currentState!.validate()) {
//       _callAadharAPI(_aadharController.text);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text(
//             'Aadhar Details',
//             style: TextStyle(color: Colors.black),
//           ),
//           backgroundColor: Colors.yellow,
//         ),
//         body: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(20.0),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const SizedBox(height: 20),
//                   const Text(
//                     'Enter Aadhar Number (आधार क्रमांक टाका):',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   TextFormField(
//                     controller: _aadharController,
//                     keyboardType: TextInputType.number,
//                     inputFormatters: [
//                       FilteringTextInputFormatter.digitsOnly,
//                       LengthLimitingTextInputFormatter(12),
//                     ],
//                     decoration: InputDecoration(
//                       labelText: 'Aadhar Number',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(8),
//                         borderSide: const BorderSide(color: Colors.yellow),
//                       ),
//                       hintText: 'Enter 12-digit Aadhar number',
//                     ),
//                     validator: _validateAadhar,
//                   ),
//                   const SizedBox(height: 10),
//                   const Text(
//                     'Enter your 12-digit Aadhar number without spaces',
//                     style: TextStyle(
//                       color: Colors.grey,
//                       fontSize: 13,
//                     ),
//                   ),
//                   const SizedBox(height: 30),
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed: _isLoading ? null : _submitForm,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.yellow,
//                         padding: const EdgeInsets.symmetric(vertical: 16),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                       child: _isLoading
//                           ? const SizedBox(
//                               width: 20,
//                               height: 20,
//                               child: CircularProgressIndicator(
//                                 color: Colors.white,
//                                 strokeWidth: 2,
//                               ),
//                             )
//                           : const Text(
//                               'SUBMIT AADHAR NUMBER',
//                               style: TextStyle(
//                                 color: Colors.black,
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                     ),
//                   ),
//                   const SizedBox(height: 20),

//                   // Display API response or error
//                   if (_isLoading)
//                     const Center(child: CircularProgressIndicator())
//                   else if (_errorMessage.isNotEmpty)
//                     Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 16.0),
//                       child: Text(
//                         _errorMessage,
//                         style: const TextStyle(color: Colors.red, fontSize: 16),
//                       ),
//                     )
//                   else if (_apiResponse != null)
//                     _buildResponseUI(),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildResponseUI() {
//     final code = _apiResponse!['code'];
//     final message = _apiResponse!['message'];

//     // Handle null or non-list allData safely
//     final allData = _apiResponse!['allData'];
//     final List<dynamic> dataList = allData is List ? allData : [];

//     if (code != "200" || dataList.isEmpty) {
//       return Padding(
//         padding: const EdgeInsets.symmetric(vertical: 16.0),
//         child: Text(
//           message.isNotEmpty ? message : 'No data found for this Aadhar number',
//           style: const TextStyle(color: Colors.red, fontSize: 16),
//         ),
//       );
//     }

//     final data = dataList.first;

//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16.0),
//       decoration: BoxDecoration(
//         color: Colors.grey[100],
//         borderRadius: BorderRadius.circular(8.0),
//         border: Border.all(color: Colors.yellow),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Aadhar Details:',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.green,
//             ),
//           ),
//           const SizedBox(height: 16),
//           // _buildDetailRow('Avak Number', data['avakNo']),
//           // _buildDetailRow('Aadhar Number', data['adharNo']),
//           _buildDetailRow('Name', data['name']?.toString() ?? 'N/A'),
//           _buildDetailRow(
//               'Mobile Number', data['mobileNo']?.toString() ?? 'N/A'),
//           // _buildDetailRow('Unique Key', data['uniqueKey']),
//         ],
//       ),
//     );
//   }

//   Widget _buildDetailRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 120,
//             child: Text(
//               '$label:',
//               style: const TextStyle(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(
//                 fontSize: 16,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _aadharController.dispose();
//     super.dispose();
//   }
// }

// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;

// class GetAadharDetailesScreen extends StatefulWidget {
//   const GetAadharDetailesScreen({super.key});

//   @override
//   State<GetAadharDetailesScreen> createState() =>
//       _GetAadharDetailesScreenState();
// }

// class _GetAadharDetailesScreenState extends State<GetAadharDetailesScreen> {
//   final TextEditingController _aadharController = TextEditingController();
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   bool _isLoading = false;
//   Map<String, dynamic>? _apiResponse;
//   String _errorMessage = '';

//   // Validate Aadhar number (basic validation for 12 digits)
//   String? _validateAadhar(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Please enter your Aadhar number';
//     }
//     if (value.length != 12) {
//       return 'Aadhar number must be 12 digits';
//     }
//     if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
//       return 'Aadhar number must contain only digits';
//     }
//     return null;
//   }

//   // API call function
//   // Future<void> _callAadharAPI(String aadharNumber) async {
//   //   setState(() {
//   //     _isLoading = true;
//   //     _apiResponse = null;
//   //     _errorMessage = '';
//   //   });

//   //   try {
//   //     final url = Uri.parse(
//   //         'http://103.224.247.133:8085/BSUPN/rest/service/getbyAadharNumber?aadharnumber=$aadharNumber');
//   //     final response = await http.get(url);

//   //     if (response.statusCode == 200) {
//   //       final Map<String, dynamic> data = json.decode(response.body);
//   //       setState(() {
//   //         _apiResponse = data;
//   //       });
//   //     } else {
//   //       setState(() {
//   //         _errorMessage =
//   //             'Failed to fetch data. Status code: ${response.statusCode}';
//   //       });
//   //     }
//   //   } catch (e) {
//   //     setState(() {
//   //       _errorMessage = 'Error: ${e.toString()}';
//   //     });
//   //   } finally {
//   //     setState(() {
//   //       _isLoading = false;
//   //     });
//   //   }
//   // }

//   Future<void> _callAadharAPI(String aadharNumber) async {
//     setState(() {
//       _isLoading = true;
//       _apiResponse = null;
//       _errorMessage = '';
//     });

//     try {
//       final url = Uri.parse(
//           'http://103.224.247.133:8085/BSUPN/rest/service/getbyAadharNumber?aadharnumber=$aadharNumber');
//       final response = await http.get(url);

//       print('Status Code: ${response.statusCode}');
//       print('Response Body: ${response.body}');

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = json.decode(response.body);
//         setState(() {
//           _apiResponse = data;
//         });

//         // Check the response code from the API
//         if (data['code'] == "200") {
//           // Navigate to another screen (PhotoScreen) and pass the data
//           // Navigator.push(
//           //   context,
//           //   MaterialPageRoute(
//           //     builder: (context) => PhotoScreen(aadharData: data),
//           //   ),
//           // );
//         } else if (data['code'] == "201") {
//           // Show popup with the message
//           _showPopupMessage(
//               'Note',
//               data['Data not found for this Aadhar number'] ??
//                   'Data not found for this Aadhar number');
//         }
//       } else {
//         setState(() {
//           _errorMessage =
//               'Failed to fetch data. Status code: ${response.statusCode}';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Error: ${e.toString()}';
//       });

//       _showPopupMessage('Exception', e.toString());
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   void _showPopupMessage(String title, String message) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20.0),
//           ),
//           title: Row(
//             children: [
//               Icon(Icons.check_circle_outline, color: Colors.blue, size: 28),
//               SizedBox(width: 10),
//               Text(
//                 title,
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//             ],
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Divider(thickness: 2.5),
//               Text(
//                 message,
//                 style: TextStyle(fontSize: 16),
//                 textAlign: TextAlign.center,
//               ),
//               Divider(thickness: 2.5),
//             ],
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text('OK', style: TextStyle(color: Colors.blue)),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // Handle form submission
//   void _submitForm() {
//     if (_formKey.currentState!.validate()) {
//       _callAadharAPI(_aadharController.text);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text(
//             'Aadhar Details',
//             style: TextStyle(color: Colors.black),
//           ),
//           backgroundColor: Colors.yellow,
//         ),
//         body: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(20.0),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const SizedBox(height: 20),
//                   const Text(
//                     'Enter Aadhar Number (आधार क्रमांक टाका):',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   TextFormField(
//                     controller: _aadharController,
//                     keyboardType: TextInputType.number,
//                     inputFormatters: [
//                       FilteringTextInputFormatter.digitsOnly,
//                       LengthLimitingTextInputFormatter(12),
//                     ],
//                     decoration: InputDecoration(
//                       labelText: 'Aadhar Number',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(8),
//                         borderSide: const BorderSide(color: Colors.yellow),
//                       ),
//                       hintText: 'Enter 12-digit Aadhar number',
//                     ),
//                     validator: _validateAadhar,
//                   ),
//                   const SizedBox(height: 10),
//                   const Text(
//                     'Enter your 12-digit Aadhar number without spaces',
//                     style: TextStyle(
//                       color: Colors.grey,
//                       fontSize: 13,
//                     ),
//                   ),
//                   const SizedBox(height: 30),
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed: _isLoading ? null : _submitForm,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.yellow,
//                         padding: const EdgeInsets.symmetric(vertical: 16),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                       child: _isLoading
//                           ? const SizedBox(
//                               width: 20,
//                               height: 20,
//                               child: CircularProgressIndicator(
//                                 color: Colors.white,
//                                 strokeWidth: 2,
//                               ),
//                             )
//                           : const Text(
//                               'SUBMIT AADHAR NUMBER',
//                               style: TextStyle(
//                                 color: Colors.black,
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                     ),
//                   ),
//                   const SizedBox(height: 20),

//                   // Display API response or error
//                   if (_isLoading)
//                     const Center(child: CircularProgressIndicator())
//                   else if (_errorMessage.isNotEmpty)
//                     Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 16.0),
//                       child: Text(
//                         _errorMessage,
//                         style: const TextStyle(color: Colors.red, fontSize: 16),
//                       ),
//                     )
//                   else if (_apiResponse != null)
//                     _buildResponseUI(),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildResponseUI() {
//     final code = _apiResponse!['code'];
//     final message = _apiResponse!['message'];
//     final allData = _apiResponse!['allData'] as List<dynamic>;

//     if (code != "200" || allData.isEmpty) {
//       return Padding(
//         padding: const EdgeInsets.symmetric(vertical: 16.0),
//         child: Text(
//           message.isNotEmpty ? message : 'No data found for this Aadhar number',
//           style: const TextStyle(color: Colors.red, fontSize: 16),
//         ),
//       );
//     }

//     final data = allData.first;

//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16.0),
//       decoration: BoxDecoration(
//         color: Colors.grey[100],
//         borderRadius: BorderRadius.circular(8.0),
//         border: Border.all(color: Colors.yellow),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Aadhar Details:',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.green,
//             ),
//           ),
//           const SizedBox(height: 16),
//           // _buildDetailRow('Avak Number', data['avakNo']),
//           // _buildDetailRow('Aadhar Number', data['adharNo']),
//           _buildDetailRow('Name', data['name']),
//           _buildDetailRow('Mobile Number', data['mobileNo']),
//           // _buildDetailRow('Unique Key', data['uniqueKey']),
//         ],
//       ),
//     );
//   }

//   Widget _buildDetailRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 120,
//             child: Text(
//               '$label:',
//               style: const TextStyle(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(
//                 fontSize: 16,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _aadharController.dispose();
//     super.dispose();
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// class GetAadharDetailesScreen extends StatefulWidget {
//   const GetAadharDetailesScreen({super.key});

//   @override
//   State<GetAadharDetailesScreen> createState() =>
//       _GetAadharDetailesScreenState();
// }

// class _GetAadharDetailesScreenState extends State<GetAadharDetailesScreen> {
//   final TextEditingController _aadharController = TextEditingController();
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   bool _isLoading = false;

//   // Validate Aadhar number (basic validation for 12 digits)
//   String? _validateAadhar(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Please enter your Aadhar number';
//     }
//     if (value.length != 12) {
//       return 'Aadhar number must be 12 digits';
//     }
//     if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
//       return 'Aadhar number must contain only digits';
//     }
//     return null;
//   }

//   // Handle form submission
//   void _submitForm() {
//     if (_formKey.currentState!.validate()) {
//       setState(() {
//         _isLoading = true;
//       });

//       // Simulate API call or processing
//       Future.delayed(const Duration(seconds: 2), () {
//         setState(() {
//           _isLoading = false;
//         });
//         // Navigate to next screen or show success message
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Aadhar submitted successfully!'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Aadhar Details',
//           style: TextStyle(color: Colors.black),
//         ),
//         backgroundColor: Colors.yellow,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const SizedBox(height: 20),
//               const Text(
//                 'Enter Aadhar Number (आधार क्रमांक टाका):',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 20),
//               TextFormField(
//                 controller: _aadharController,
//                 keyboardType: TextInputType.number,
//                 inputFormatters: [
//                   FilteringTextInputFormatter.digitsOnly,
//                   LengthLimitingTextInputFormatter(12),
//                 ],
//                 decoration: InputDecoration(
//                   labelText: 'Aadhar Number',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                     borderSide: BorderSide(color: Colors.yellow),
//                   ),
//                   hintText: 'Enter 12-digit Aadhar number',
//                 ),
//                 validator: _validateAadhar,
//               ),
//               const SizedBox(height: 10),
//               const Text(
//                 'Enter your 12-digit Aadhar number without spaces',
//                 style: TextStyle(
//                   color: Colors.grey,
//                   fontSize: 13,
//                 ),
//               ),
//               const SizedBox(height: 30),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _isLoading ? null : _submitForm,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.yellow,
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   child: _isLoading
//                       ? const SizedBox(
//                           width: 20,
//                           height: 20,
//                           child: CircularProgressIndicator(
//                             color: Colors.white,
//                             strokeWidth: 2,
//                           ),
//                         )
//                       : const Text(
//                           'SUBMIT AADHAR NUMBER',
//                           style: TextStyle(
//                             color: Colors.black,
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _aadharController.dispose();
//     super.dispose();
//   }
// }

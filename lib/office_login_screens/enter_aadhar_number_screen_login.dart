import 'dart:convert';

import 'package:divyang_pimpri_chinchwad_municipal_corporation/office_login_screens/divyang_detailes_officelogin_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class EnterAadharNumberScreenLogin extends StatefulWidget {
  final String userId;
  const EnterAadharNumberScreenLogin({super.key, required this.userId});

  @override
  State<EnterAadharNumberScreenLogin> createState() =>
      _EnterAadharNumberScreenLoginState();
}

class _EnterAadharNumberScreenLoginState
    extends State<EnterAadharNumberScreenLogin> {
  final TextEditingController _aadharController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  Map<String, dynamic>? _apiResponse;
  String _errorMessage = '';

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
          // Call POST API before navigation
          await _storeAadharData(data);
        } else if (data['code'] == "201") {
          // Show popup with the message
          _showPopupMessage(
            'Note',
            'Aadhar data is not found for this number\nPlease contact this number: 8888888888',
            // data['message'] ?? 'Data not found for this Aadhar number',
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

  Future<void> _storeAadharData(Map<String, dynamic> data) async {
    try {
      final List<dynamic> dataList =
          data['allData'] is List ? data['allData'] : [];

      if (dataList.isEmpty) {
        _showPopupMessage('Error', 'No data available to store');
        return;
      }

      final aadharData = dataList.first;

      // Prepare the data object for POST request
      final Map<String, dynamic> postData = {
        "avakNo": aadharData['avakNo']?.toString() ?? '',
        "adharNo": aadharData['adharNo']?.toString() ?? '',
        "name": aadharData['name']?.toString() ?? '',
        "mobileNo": aadharData['mobileNo']?.toString() ?? '',
        "uniqueKey": aadharData['uniqueKey']?.toString() ?? '',
      };

      print('POST Data: ${json.encode(postData)}');

      // Call POST API
      final url = Uri.parse('https://divyangpcmc.altwise.in/api/aadhar/Store');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(postData),
      );

      print('POST Status Code: ${response.statusCode}');
      print('POST Response Body: ${response.body}');

      if (response.statusCode == 200) {
        // POST API successful, navigate to next screen
        _navigateToPhotoClickScreen(
          avakNo: postData['avakNo']!,
          adharNo: postData['adharNo']!,
          name: postData['name']!,
          mobileNo: postData['mobileNo']!,
          uniqueKey: postData['uniqueKey']!,
        );
      } else {
        // POST API failed
        _showPopupMessage(
          'Error',
          'Failed to store data. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Store Error: ${e.toString()}');
      _showPopupMessage('Exception', 'Failed to store data: ${e.toString()}');
    }
  }

  void _navigateToPhotoClickScreen({
    required String avakNo,
    required String adharNo,
    required String name,
    required String mobileNo,
    required String uniqueKey,
  }) {
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
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Enter Aadhar Number Screen',
            style: TextStyle(
                color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.yellow,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(width * 0.05),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: height * 0.025),
                  const Text(
                    'Enter Aadhar Number (आधार क्रमांक टाका):',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: height * 0.025),
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
                  SizedBox(height: height * 0.012),
                  const Text(
                    'Enter your 12-digit Aadhar number without spaces',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(height: height * 0.038),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow,
                        padding: EdgeInsets.symmetric(vertical: height * 0.02),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              width: width * 0.05,
                              height: width * 0.05,
                              child: const CircularProgressIndicator(
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
                  SizedBox(height: height * 0.025),

                  // Display API response or error
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: height * 0.02),
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

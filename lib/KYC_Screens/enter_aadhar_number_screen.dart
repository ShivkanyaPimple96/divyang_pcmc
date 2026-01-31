import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:divyang_pimpri_chinchwad_municipal_corporation/KYC_Screens/divyang_detailes_screen.dart';
import 'package:divyang_pimpri_chinchwad_municipal_corporation/KYC_Screens/search_aadhar_no_screen.dart';
import 'package:divyang_pimpri_chinchwad_municipal_corporation/KYC_Screens/view_button_pensioner_detailes_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

class EnterAadharNumberScreen extends StatefulWidget {
  const EnterAadharNumberScreen({super.key});

  @override
  _EnterAadharNumberScreenState createState() =>
      _EnterAadharNumberScreenState();
}

class _EnterAadharNumberScreenState extends State<EnterAadharNumberScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _aadharNumberController = TextEditingController();

  final List<TextEditingController> _digitControllers =
      List.generate(5, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(5, (_) => FocusNode());

  bool _isMobileSubmitted = false;
  bool _isAadharSubmitted = false;
  bool _isLoadingAadharNumber = false;
  bool _apiError = false;
  String _apiErrorMessage = '';
  String _fullName = '';
  bool _isLoadingOTP = false;
  bool _otpApiError = false;
  String _otpApiErrorMessage = '';
  bool _isVerifyingOTP = false;
  bool _otpVerificationError = false;
  String _otpVerificationErrorMessage = '';

  // Resend OTP Timer variables
  int _countdown = 120;
  bool _isCountdownActive = false;
  Timer? _timer;

  String _apiMobileNumber = '';

  @override
  void dispose() {
    _mobileController.dispose();
    _otpController.dispose();
    _aadharNumberController.dispose();
    for (var controller in _digitControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    // Cancel timer if active
    if (_isCountdownActive && _timer != null) {
      _timer!.cancel();
    }
    super.dispose();
  }

  void _startCountdown() {
    setState(() {
      _isCountdownActive = true;
      _countdown = 120; // 2 minutes countdown
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown == 0) {
        timer.cancel();
        setState(() {
          _isCountdownActive = false;
        });
      } else {
        setState(() {
          _countdown--;
        });
      }
    });
  }

  Future<void> _verifyOtp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isVerifyingOTP = true;
        _otpVerificationError = false;
        _otpVerificationErrorMessage = '';
      });

      try {
        final apiUrl =
            'http://divyangpcmc.altwise.in/api/aadhar/SubmitOtpUsingAadhaarNumber?AadhaarNumber=${_aadharNumberController.text}&MobileNo=${_mobileController.text}&Otp=${_otpController.text}';
        print('Calling OTP Verification API: $apiUrl');

        final response = await CustomHttpClient.get(apiUrl);
        print(
            'OTP Verification API Response Status Code: ${response.statusCode}');
        print('OTP Verification API Response Body: ${response.body}');

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          print('Parsed OTP Verification Data: $data');

          if ((data['Message']
                      ?.toString()
                      .toLowerCase()
                      .contains('success') ??
                  false) ||
              (data['message']?.toString().toLowerCase().contains('success') ??
                  false) ||
              (data['Success'] == true)) {
            print('OTP verified successfully!');

            // Extract all the data from the response
            final responseData = data['Data'];
            final verificationStatusNote =
                responseData['VerificationStatusNote'] ?? '';
            final avakNumber = responseData['avakNo'] ?? '';
            final uniqueKey = responseData['uniqueKey'] ?? '';
            final disabilityType = responseData['DisabilityType'] ?? '';
            final disabilityPercentage =
                responseData['DisabilityPercentage'] ?? '';

            // Check if application is approved
            if (verificationStatusNote
                .toLowerCase()
                .contains('application approved')) {
              // Navigate to approved screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewButtonPensionerDetailesScreen(
                    ppoNumber: _aadharNumberController.text,
                    mobileNumber: _mobileController.text,
                    fullName: responseData['FullName'] ?? '',
                    url: responseData['Url'] ?? '',
                    aadhaarNumber: responseData['AadhaarNumber'] ?? '',
                    addresss: responseData['Addresss'] ?? '',
                    avakNumber: responseData['avakNo'] ?? '',
                    uniqueKey: responseData['uniqueKey'] ?? '',
                    udidNumber: responseData['UDIDNumber'] ?? '',
                    gender: responseData['Gender'] ?? '',
                    bankName: responseData['BankName'] ?? '',
                    verificationStatus:
                        responseData['VerificationStatus'] ?? '',
                    // uniqueKey: responseData['uniqueKey'] ?? '',
                    disabilityType: responseData['DisabilityType'] ?? '',
                    disabilityPercentage:
                        responseData['DisabilityPercentage'] ?? '',
                  ),
                ),
              );
            } else {
              // Navigate to regular details screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DivyangDetailesScreen(
                    aadharNumber: _aadharNumberController.text,
                    mobileNumber: _mobileController.text,
                    fullName: responseData['FullName'] ?? '',
                    url: responseData['Url'] ?? '',
                    aadhaarNumber: responseData['AadhaarNumber'] ?? '',
                    addresss: responseData['Addresss'] ?? '',
                    udidNumber: responseData['UDIDNumber'] ?? '',
                    uniqueKey: responseData['uniqueKey'] ?? '',
                    avakNumber: responseData['avakNo'] ?? '',
                    gender: responseData['Gender'] ?? '',
                    disabilityType: responseData['DisabilityType'] ?? '',
                    verificationStatus:
                        responseData['VerificationStatus'] ?? '',
                  ),
                ),
              );
            }
          } else {
            print('OTP verification failed');
            final errorMessage =
                data['Message'] ?? data['message'] ?? 'Invalid OTP';
            showErrorDialog(errorMessage);
            setState(() {
              _otpVerificationError = true;
              _otpVerificationErrorMessage = errorMessage;
            });
          }
        } else {
          print('OTP Verification API returned non-200 status code');
          final errorMessage =
              'Please Enter Correct OTP\nकृपया योग्य OTP एंटर करा';
          showErrorDialog(errorMessage);
          setState(() {
            _otpVerificationError = true;
            _otpVerificationErrorMessage = errorMessage;
          });
        }
      } catch (e) {
        print('Error in OTP verification API call: $e');
        final errorMessage =
            'Network error: Please Check Your Internet Connection';
        showErrorDialog(errorMessage);
        setState(() {
          _otpVerificationError = true;
          _otpVerificationErrorMessage = errorMessage;
        });
      } finally {
        setState(() {
          _isVerifyingOTP = false;
        });
      }
    }
  }

  Future<void> _sendOtpRequest() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoadingOTP = true;
        _otpApiError = false;
        _otpApiErrorMessage = '';
      });

      try {
        final apiUrl =
            'http://divyangpcmc.altwise.in/api/aadhar/GetOtpUsingMobileNo?AadhaarNumber=${_aadharNumberController.text}&MobileNo=${_mobileController.text}';
        print('Calling API: $apiUrl');

        final response = await CustomHttpClient.get(apiUrl);
        print('API Response Status Code: ${response.statusCode}');
        print('API Response Body: ${response.body}');

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          print('Parsed API Data: $data');

          // Check if the message indicates success regardless of the 'success' flag
          if ((data['Message']?.toString().toLowerCase().contains('success') ??
                  false) ||
              (data['message']?.toString().toLowerCase().contains('success') ??
                  false)) {
            print('OTP sent successfully!');
            setState(() {
              _isMobileSubmitted = true;
            });
            // Start countdown timer after successful OTP send
            _startCountdown();
          } else {
            print('API did not return success message');
            final errorMessage =
                data['Message'] ?? data['message'] ?? 'Failed to send OTP';
            showErrorDialog(errorMessage);
            setState(() {
              _otpApiError = true;
              _otpApiErrorMessage = errorMessage;
              _isMobileSubmitted = false;
            });
          }
        } else {
          print('API returned non-200 status code');
          final errorMessage =
              'Please Enter Correct OTP: ${response.statusCode}';
          showErrorDialog(errorMessage);
          setState(() {
            _otpApiError = true;
            _otpApiErrorMessage = errorMessage;
            _isMobileSubmitted = false;
          });
        }
      } catch (e) {
        print('Error in OTP API call: $e');
        final errorMessage =
            'Network error: Please Check Your Internet Connection\nकृपया तुमचे इंटरनेट नेटवर्क तपासा.';
        showErrorDialog(errorMessage);
        setState(() {
          _otpApiError = true;
          _otpApiErrorMessage = errorMessage;
          _isMobileSubmitted = false;
        });
      } finally {
        setState(() {
          _isLoadingOTP = false;
        });
      }
    }
  }

  Future<void> _resendOtp() async {
    // Clear the OTP field when resending
    _otpController.clear();

    setState(() {
      _isLoadingOTP = true;
      _otpApiError = false;
      _otpApiErrorMessage = '';
    });

    try {
      final apiUrl =
          'http://divyangpcmc.altwise.in/api/aadhar/GetOtpUsingMobileNo?AadhaarNumber=${_aadharNumberController.text}&MobileNo=${_mobileController.text}';
      print('Calling Resend OTP API: $apiUrl');

      final response = await CustomHttpClient.get(apiUrl);
      print('Resend OTP API Response Status Code: ${response.statusCode}');
      print('Resend OTP API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Parsed Resend OTP API Data: $data');

        if ((data['Message']?.toString().toLowerCase().contains('success') ??
                false) ||
            (data['message']?.toString().toLowerCase().contains('success') ??
                false)) {
          print('OTP resent successfully!');

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('OTP sent successfully!\nOTP यशस्वीरित्या पाठवला!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );

          // Restart countdown timer
          _startCountdown();
        } else {
          print('Resend OTP API did not return success message');
          final errorMessage =
              data['Message'] ?? data['message'] ?? 'Failed to resend OTP';
          showErrorDialog(errorMessage);
          setState(() {
            _otpApiError = true;
            _otpApiErrorMessage = errorMessage;
          });
        }
      } else {
        print('Resend OTP API returned non-200 status code');
        final errorMessage = 'Failed to resend OTP: ${response.statusCode}';
        showErrorDialog(errorMessage);
        setState(() {
          _otpApiError = true;
          _otpApiErrorMessage = errorMessage;
        });
      }
    } catch (e) {
      print('Error in Resend OTP API call: $e');
      final errorMessage =
          'Network error: Please Check Your Internet Connection\nकृपया तुमचे इंटरनेट नेटवर्क तपासा.';
      showErrorDialog(errorMessage);
      setState(() {
        _otpApiError = true;
        _otpApiErrorMessage = errorMessage;
      });
    } finally {
      setState(() {
        _isLoadingOTP = false;
      });
    }
  }

  Future<void> _fetchDivyangDetails(String aadharNumber,
      {bool showErrors = true}) async {
    setState(() {
      _isLoadingAadharNumber = true;
      _apiError = false;
      _apiErrorMessage = '';
      _apiMobileNumber = '';
    });

    try {
      final response = await CustomHttpClient.get(
        'http://divyangpcmc.altwise.in/api/aadhar/GetDetailsUsingAadhaarNumber?AadhaarNumber=$aadharNumber',
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            _fullName = data['data']['FullName'] ?? '';
            _apiMobileNumber = data['data']['MobileNumber'] ?? '';
            _isAadharSubmitted = true;

            // If mobile number is available from API, set it in the controller
            if (_apiMobileNumber.isNotEmpty) {
              _mobileController.text = _apiMobileNumber;
            }
          });
        } else if (showErrors) {
          final errorMessage = data['message'] ?? 'Failed to fetch details';
          showErrorDialog(errorMessage);
        }
      } else if (showErrors) {
        showErrorDialog('Aadhar Number Not Found\n आधार नंबर सापडला नाही');
      }
    } catch (e) {
      if (showErrors) {
        showErrorDialog(
            'Network error: Please Check Your Internet Network\nकृपया तुमचे इंटरनेट नेटवर्क तपासा.');
      }
    } finally {
      setState(() {
        _isLoadingAadharNumber = false;
      });
    }
  }

  Future<void> showErrorDialog(String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: const Row(
            children: [
              SizedBox(width: 10),
              Text(
                'Note',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(thickness: 2.5),
              Text(
                message,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const Divider(thickness: 2.5),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Enter Aadhar Number [Step-1]',
            style: TextStyle(
              color: Colors.white,
              fontSize: width * 0.05,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: const Color(0xFFF76048),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(width * 0.04),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: height * 0.005),
                Text(
                  'Enter Your Aadhar Number\nआधार क्रमांक टाका',
                  style: TextStyle(
                    fontSize: width * 0.055,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: height * 0.012),
                Center(
                  child: Container(
                    height: height * 0.075,
                    width: width * 0.75,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(width * 0.025),
                      border: Border.all(
                        color: const Color(0xFFF76048),
                        width: 2,
                      ),
                    ),
                    child: TextFormField(
                      style: TextStyle(fontSize: width * 0.06),
                      keyboardType: TextInputType.number,
                      controller: _aadharNumberController,
                      enabled: !_isAadharSubmitted,
                      textAlign: TextAlign.center,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter aadhar number',
                        hintStyle: TextStyle(
                          color: Colors.grey[600],
                          fontSize: width * 0.045,
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(12),
                      ],
                      validator: (value) {
                        if (!_isAadharSubmitted) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your aadhar number';
                          }
                          if (value.length != 12) {
                            return ' Aadhar number must be exactly 12 digits';
                          }
                          if (!RegExp(r'^\d{12}$').hasMatch(value)) {
                            return '  Aadhar number must contain only digits';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                SizedBox(height: height * 0.020),
                Visibility(
                  visible: !_isAadharSubmitted,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _fetchDivyangDetails(_aadharNumberController.text);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFF76048),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(width * 0.075),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.1,
                        vertical: height * 0.012,
                      ),
                    ),
                    child: Text(
                      'Submit Aadhar Number\nआधार क्रमांक सबमिट करा',
                      style: TextStyle(
                        fontSize: width * 0.04,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SizedBox(height: height * 0.02),
                Center(
                  child: Visibility(
                    visible: !_isAadharSubmitted,
                    child: ElevatedButton(
                      onPressed: () {
                        _fetchDivyangDetails(_aadharNumberController.text,
                            showErrors: false);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AadharSearchScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 235, 149, 38),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(width * 0.0125),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: width * 0.025,
                          vertical: height * 0.0,
                        ),
                      ),
                      child: Text(
                        'Know your Aadhar Number\nतुमचा आधार नंबर जाणून घ्या',
                        style: TextStyle(
                          fontSize: width * 0.045,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                if (_isLoadingAadharNumber) ...[
                  SizedBox(height: height * 0.020),
                  Center(
                    child: CircularProgressIndicator(
                      strokeWidth: width * 0.01,
                    ),
                  ),
                ],
                if (_isAadharSubmitted && _fullName.isNotEmpty) ...[
                  Center(
                    child: Text(
                      ' दिव्यांग व्यक्तीचे नाव:\n$_fullName',
                      style: TextStyle(
                        fontSize: width * 0.05,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: height * 0.020),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.02),
                    child: Center(
                      child: Text(
                        'Enter your mobile number\n मोबाईल नंबर टाका',
                        style: TextStyle(
                          fontSize: width * 0.055,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.012),
                  Center(
                    child: Container(
                      height: height * 0.075,
                      width: width * 0.625,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(width * 0.025),
                        border: Border.all(
                          color: const Color(0xFFF76048),
                          width: 2,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(top: height * 0.012),
                        child: TextFormField(
                          controller: _mobileController,
                          enabled:
                              !_isMobileSubmitted && _apiMobileNumber.isEmpty,
                          keyboardType: TextInputType.phone,
                          textAlign: TextAlign.center,
                          textAlignVertical: TextAlignVertical.center,
                          style: TextStyle(
                            fontSize: width * 0.0625,
                            color: Colors.black,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Enter mobile number',
                            hintStyle: TextStyle(
                              color: Colors.grey[600],
                              fontSize: width * 0.045,
                            ),
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                          ),
                          validator: (value) {
                            if (!_isMobileSubmitted) {
                              if (_apiMobileNumber.isEmpty &&
                                  (value == null || value.isEmpty)) {
                                return '  Please enter mobile number';
                              }
                              if (_apiMobileNumber.isEmpty &&
                                  !RegExp(r'^[0-9]{10}$').hasMatch(value!)) {
                                return '  Please Enter 10 digit mobile number';
                              }
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.020),
                  Visibility(
                    visible: !_isMobileSubmitted,
                    child: Column(
                      children: [
                        if (_otpApiError)
                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: height * 0.012,
                            ),
                          ),
                        if (_isLoadingOTP)
                          Center(
                            child: CircularProgressIndicator(
                              strokeWidth: width * 0.01,
                            ),
                          )
                        else
                          ElevatedButton(
                            onPressed: _sendOtpRequest,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFF76048),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(width * 0.075),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: width * 0.1,
                                vertical: height * 0.012,
                              ),
                            ),
                            child: Text(
                              "Submit Mobile Number\nमोबाईल नंबर सबमिट करा",
                              style: TextStyle(
                                fontSize: width * 0.045,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
                if (_isMobileSubmitted) ...[
                  SizedBox(height: height * 0.015),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.02),
                    child: Center(
                      child: Text(
                        'Enter OTP\n OTP टाका',
                        style: TextStyle(
                          fontSize: width * 0.055,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.010),
                  Center(
                    child: Container(
                      width: width * 0.5,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(width * 0.025),
                        border: Border.all(
                          color: const Color(0xFFF76048),
                          width: 2,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: width * 0.03),
                        child: TextFormField(
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          textAlignVertical: TextAlignVertical.center,
                          style: TextStyle(
                            fontSize: width * 0.0625,
                            color: Colors.black,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),
                          ],
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Enter OTP',
                            hintStyle: TextStyle(
                              color: Colors.grey[600],
                              fontSize: width * 0.045,
                            ),
                          ),
                          validator: (value) {
                            if (_isMobileSubmitted) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter OTP';
                              }
                              if (value.length != 4) {
                                return 'OTP must be 4 digits';
                              }
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.015),
                  // Resend OTP Section
                  Center(
                    child: _isCountdownActive
                        ? Text(
                            'Wait For Resend OTP in $_countdown seconds',
                            style: TextStyle(
                              fontSize: width * 0.045,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          )
                        : TextButton(
                            onPressed: _isLoadingOTP ? null : _resendOtp,
                            child: _isLoadingOTP
                                ? SizedBox(
                                    height: 15,
                                    width: 15,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Color(0xFFF76048)),
                                    ),
                                  )
                                : Text(
                                    'Resend OTP\nपुन्हा OTP पाठवा',
                                    style: TextStyle(
                                      fontSize: width * 0.045,
                                      color: Color(0xFFF76048),
                                      fontWeight: FontWeight.bold,
                                      // decoration: TextDecoration.underline,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                          ),
                  ),
                  SizedBox(height: height * 0.030),
                  Center(
                    child: _isVerifyingOTP
                        ? CircularProgressIndicator(
                            strokeWidth: width * 0.01,
                          )
                        : ElevatedButton(
                            onPressed: _verifyOtp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFF76048),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(width * 0.075),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: width * 0.1,
                                vertical: height * 0.012,
                              ),
                            ),
                            child: Text(
                              "Submit OTP\nOTP सबमिट करा",
                              style: TextStyle(
                                fontSize: width * 0.045,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomHttpClient {
  static Future<http.Client> get _instance async {
    final ioClient = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    return IOClient(ioClient);
  }

  static Future<http.Response> get(String url) async {
    final client = await _instance;
    return client.get(Uri.parse(url));
  }
}

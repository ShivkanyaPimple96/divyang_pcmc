import 'dart:convert';

import 'package:divyang_pimpri_chinchwad_municipal_corporation/KYC_Screens/aadhar_verification_screen.dart';
import 'package:divyang_pimpri_chinchwad_municipal_corporation/KYC_Screens/view_certificate_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class DivyangDetailesScreen extends StatefulWidget {
  final String aadharNumber;
  final String mobileNumber;
  final String fullName;
  final String verificationStatus;
  final String url;
  final String aadhaarNumber;
  final String addresss;
  final String gender;
  final String disabilityType;

  const DivyangDetailesScreen({
    super.key,
    required this.aadharNumber,
    required this.mobileNumber,
    required this.fullName,
    required this.url,
    required this.aadhaarNumber,
    required this.addresss,
    required this.gender,
    required this.verificationStatus,
    required this.disabilityType,
  });

  @override
  State<DivyangDetailesScreen> createState() => _DivyangDetailesScreenState();
}

class _DivyangDetailesScreenState extends State<DivyangDetailesScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _aadharController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _udidController = TextEditingController();
  bool _isLoading = false;
  String? _selectedGender;
  String? _selectedDisabilityType;
  String? _selectedDisabilityPercentage;
  bool _formSubmitted = false;

  // Validation flags
  bool _showAadharError = false;
  bool _showAddressError = false;
  bool _showGenderError = false;
  bool _showUdidError = false;
  bool _showDisabilityTypeError = false;
  bool _showDisabilityPercentageError = false;

  // Disability types list
  final List<Map<String, String>> _disabilityTypes = [
    {'value': '1', 'label': 'पूर्णतः अंध (Blindness)'},
    {'value': '2', 'label': 'अंशतः अंध (Low Vision)'},
    {'value': '3', 'label': 'कर्णबधीर (Hearing Impairment)'},
    {'value': '4', 'label': 'वाचा दोष (Speech and Language Disability)'},
    {'value': '5', 'label': 'अस्थिव्यंग (Locomotor Disability)'},
    {'value': '6', 'label': 'मानसिक आजार (Mental Illness)'},
    {'value': '7', 'label': 'अध्ययन अक्षम (Learning Disability)'},
    {'value': '8', 'label': 'मेंदूचा पक्षाघात (Cerebral Palsy)'},
    {'value': '9', 'label': 'स्वमग्न (Autism)'},
    {'value': '10', 'label': 'बहुविकलांग (Multiple Disability)'},
    {'value': '11', 'label': 'कुष्ठरोग (Leprosy Cured Persons)'},
    {'value': '12', 'label': 'बुटकेपणा (Dwarfism)'},
    {'value': '13', 'label': 'बौद्धिक अक्षमता (Intellectual Disability)'},
    {'value': '14', 'label': 'माशपेशीय क्षरण (Muscular Disability)'},
    {
      'value': '15',
      'label': 'मज्जासंस्थेचे तीव्र आजार (Chronic Neurological Conditions)'
    },
    {'value': '16', 'label': 'मल्टिपल स्क्लेरोसिस (Multiple Sclerosis)'},
    {'value': '17', 'label': 'थॅलेसिमिया (Thalassemia)'},
    {'value': '18', 'label': 'अधिक रक्तस्त्राव (Hemophilia)'},
    {'value': '19', 'label': 'सिकल सेल (Sickle Cell Disease)'},
    {'value': '20', 'label': 'अॅसिड अटॅक (Acid Attack Victim)'},
    {'value': '21', 'label': 'कंपवात रोग (Parkinson\'s Disease)'},
  ];

  // Generate percentage list from 40% to 100%
  List<String> get _disabilityPercentages {
    return List.generate(61, (index) => '${40 + index}%');
  }

  @override
  void initState() {
    super.initState();
    _selectedGender = null;
    _aadharController.text = widget.aadharNumber;
  }

  @override
  void dispose() {
    _aadharController.dispose();
    _addressController.dispose();
    _udidController.dispose();
    super.dispose();
  }

  // Helper method to check if data should be shown
  bool get _shouldShowUserData {
    return widget.verificationStatus == 'Verification In Progress' ||
        widget.verificationStatus == 'Application Approved';
  }

  // Helper method to check if form fields should be shown
  bool get _shouldShowFormFields {
    return widget.verificationStatus != 'Verification In Progress' &&
        widget.verificationStatus != 'Application Approved';
  }

  Future<void> _validateAndProceed() async {
    setState(() {
      _formSubmitted = true;
    });

    // Validate form fields
    bool isValid = true;
    String? errorMessage;

    if (_aadharController.text.isEmpty) {
      errorMessage = 'Please enter Aadhaar number';
      isValid = false;
      setState(() {
        _showAadharError = true;
      });
    } else if (_aadharController.text.length != 12) {
      errorMessage = 'Aadhaar must be exactly 12 digits';
      isValid = false;
      setState(() {
        _showAadharError = true;
      });
    } else if (_addressController.text.isEmpty) {
      errorMessage = 'Please enter your address';
      isValid = false;
      setState(() {
        _showAddressError = true;
      });
    } else if (_selectedGender == null || _selectedGender!.isEmpty) {
      errorMessage = 'Please select your gender';
      isValid = false;
      setState(() {
        _showGenderError = true;
      });
    } else if (_udidController.text.isEmpty) {
      errorMessage = 'Please enter UDID card number';
      isValid = false;
      setState(() {
        _showUdidError = true;
      });
    } else if (_selectedDisabilityType == null ||
        _selectedDisabilityType!.isEmpty) {
      errorMessage = 'Please select type of disability';
      isValid = false;
      setState(() {
        _showDisabilityTypeError = true;
      });
    } else if (_selectedDisabilityPercentage == null ||
        _selectedDisabilityPercentage!.isEmpty) {
      errorMessage = 'Please select percentage of disability';
      isValid = false;
      setState(() {
        _showDisabilityPercentageError = true;
      });
    }

    if (!isValid) {
      Fluttertoast.showToast(
        msg: errorMessage!,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.blue,
        textColor: Colors.white,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final Map<String, dynamic> requestBody = {
        "AadhaarNumber": _aadharController.text,
        "Address": _addressController.text,
        "Gender": _selectedGender,
        "UDIDNumber": _udidController.text,
        "DisabilityType": _selectedDisabilityType,
        "DisabilityPercentage": _selectedDisabilityPercentage,
      };

      print('Sending request: ${json.encode(requestBody)}');

      final response = await http.post(
        Uri.parse(
            'https://divyangpcmc.altwise.in/api/v1/aadhar/SubmitUserDetails'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      print('API Response: ${response.statusCode} - ${response.body}');

      setState(() {
        _isLoading = false;
      });

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        Fluttertoast.showToast(
          msg: responseData['Message'] ?? 'Details updated successfully',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AadharVerificationKYCScreen(
              ppoNumber: widget.aadharNumber,
              fullName: widget.fullName,
              mobileNumber: widget.mobileNumber,
              aadharNumber: _aadharController.text,
              addressEnter: _addressController.text,
              gender: _selectedGender!,
              udidNumber: _udidController.text,
              disabilityType: _selectedDisabilityType!,
              disabilityPercentage: _selectedDisabilityPercentage!,
            ),
          ),
        );
      } else {
        Fluttertoast.showToast(
          msg: responseData['Message'] ??
              'Failed to submit details\n डेटा सबमिट करण्यात अयशस्वी',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      Fluttertoast.showToast(
        msg:
            'Note: Please check your internet connection\nकृपया तुमचे इंटरनेट कनेक्शन तपासा.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
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
          title: Text(
            'Divyang Details [Step-2]',
            style: TextStyle(
              color: Colors.white,
              fontSize: width * 0.05,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: const Color(0xFFF76048),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.all(width * 0.04),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(width * 0.03),
                        border: Border.all(
                            color: const Color(0xFFF76048), width: 2),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(width * 0.04),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoCard('Full Name', widget.fullName, width),
                            SizedBox(height: height * 0.02),
                            _buildInfoCard(
                                'Mobile Number', widget.mobileNumber, width),
                            SizedBox(height: height * 0.02),

                            // Show additional fields if status is Verification In Progress or Approved
                            if (_shouldShowUserData &&
                                widget.aadhaarNumber.isNotEmpty) ...[
                              _buildInfoCard('Aadhaar Number',
                                  widget.aadhaarNumber, width),
                              SizedBox(height: height * 0.02),
                            ],
                            if (_shouldShowUserData &&
                                widget.addresss.isNotEmpty) ...[
                              _buildInfoCard('Address', widget.addresss, width),
                              SizedBox(height: height * 0.02),
                            ],
                            if (_shouldShowUserData &&
                                widget.gender.isNotEmpty) ...[
                              _buildInfoCard('Gender', widget.gender, width),
                            ],
                            // if (_shouldShowUserData &&
                            //     widget.disabilityType.isNotEmpty) ...[
                            //   _buildInfoCard('DisabilityType',
                            //       widget.disabilityType, width),
                            // ],

                            // Only show form fields if verification is NOT in progress and NOT approved
                            if (_shouldShowFormFields) ...[
                              SizedBox(height: height * 0.020),
                              Text(
                                'Enter Your Aadhar Number(आधार क्रमांक टाका):',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: width * 0.038,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: height * 0.012),
                              TextFormField(
                                controller: _aadharController,
                                keyboardType: TextInputType.number,
                                maxLength: 12,
                                decoration: InputDecoration(
                                  hintText: 'Enter Aadhaar number',
                                  hintStyle: TextStyle(fontSize: width * 0.035),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: width * 0.04,
                                    vertical: height * 0.015,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(width * 0.025),
                                    borderSide: BorderSide(
                                        color:
                                            (_formSubmitted && _showAadharError)
                                                ? Colors.red
                                                : const Color(0xFFF76048),
                                        width: 2),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(width * 0.025),
                                    borderSide: BorderSide(
                                        color:
                                            (_formSubmitted && _showAadharError)
                                                ? Colors.red
                                                : const Color(0xFFF76048),
                                        width: 2),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(width * 0.025),
                                    borderSide: BorderSide(
                                        color:
                                            (_formSubmitted && _showAadharError)
                                                ? Colors.red
                                                : Colors.green,
                                        width: 2),
                                  ),
                                  errorText: (_formSubmitted &&
                                          _aadharController.text.isEmpty)
                                      ? 'Aadhaar number is required'
                                      : (_formSubmitted &&
                                              _aadharController.text.length !=
                                                  12)
                                          ? 'Aadhaar must be exactly 12 digits'
                                          : null,
                                ),
                                onChanged: (value) {
                                  if (_formSubmitted) {
                                    setState(() {
                                      _showAadharError =
                                          value.isEmpty || value.length != 12;
                                    });
                                  }
                                },
                              ),
                              SizedBox(height: height * 0.025),
                              Text(
                                'Enter Your Address( पत्ता टाका):',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: width * 0.038,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: height * 0.012),
                              TextFormField(
                                controller: _addressController,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  hintText: 'Enter your address',
                                  hintStyle: TextStyle(fontSize: width * 0.035),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: width * 0.04,
                                    vertical: height * 0.015,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(width * 0.025),
                                    borderSide: BorderSide(
                                        color: (_formSubmitted &&
                                                _showAddressError)
                                            ? Colors.red
                                            : const Color(0xFFF76048),
                                        width: 2),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(width * 0.025),
                                    borderSide: BorderSide(
                                        color: (_formSubmitted &&
                                                _showAddressError)
                                            ? Colors.red
                                            : const Color(0xFFF76048),
                                        width: 2),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(width * 0.025),
                                    borderSide: BorderSide(
                                        color: (_formSubmitted &&
                                                _showAddressError)
                                            ? Colors.red
                                            : Colors.green,
                                        width: 2),
                                  ),
                                  errorText: (_formSubmitted &&
                                          _addressController.text.isEmpty)
                                      ? 'Address is required'
                                      : null,
                                ),
                                onChanged: (value) {
                                  if (_formSubmitted) {
                                    setState(() {
                                      _showAddressError = value.isEmpty;
                                    });
                                  }
                                },
                              ),
                              SizedBox(height: height * 0.025),
                              Text(
                                'Enter Your Gender( लिंग टाका):',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: width * 0.038,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: height * 0.012),
                              DropdownButtonFormField<String>(
                                value: _selectedGender,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: width * 0.04,
                                    vertical: height * 0.015,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(width * 0.025),
                                    borderSide: BorderSide(
                                        color:
                                            (_formSubmitted && _showGenderError)
                                                ? Colors.red
                                                : const Color(0xFFF76048),
                                        width: 2),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(width * 0.025),
                                    borderSide: BorderSide(
                                        color:
                                            (_formSubmitted && _showGenderError)
                                                ? Colors.red
                                                : const Color(0xFFF76048),
                                        width: 2),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(width * 0.025),
                                    borderSide: BorderSide(
                                        color:
                                            (_formSubmitted && _showGenderError)
                                                ? Colors.red
                                                : Colors.green,
                                        width: 2),
                                  ),
                                  errorText: (_formSubmitted &&
                                          (_selectedGender == null ||
                                              _selectedGender!.isEmpty))
                                      ? 'Gender is required'
                                      : null,
                                ),
                                items: [
                                  DropdownMenuItem<String>(
                                    value: 'Male',
                                    child: Text('Male',
                                        style:
                                            TextStyle(fontSize: width * 0.038)),
                                  ),
                                  DropdownMenuItem<String>(
                                    value: 'Female',
                                    child: Text('Female',
                                        style:
                                            TextStyle(fontSize: width * 0.038)),
                                  ),
                                  DropdownMenuItem<String>(
                                    value: 'Transgender',
                                    child: Text('Transgender',
                                        style:
                                            TextStyle(fontSize: width * 0.038)),
                                  ),
                                ],
                                onChanged: (newValue) {
                                  setState(() {
                                    _selectedGender = newValue;
                                    if (_formSubmitted) {
                                      _showGenderError =
                                          newValue == null || newValue.isEmpty;
                                    }
                                  });
                                },
                                hint: Text('Please select gender',
                                    style: TextStyle(fontSize: width * 0.035)),
                              ),
                              SizedBox(height: height * 0.025),
                              Text(
                                'Enter UDID Card Number (UDID कार्ड नंबर टाका):',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: width * 0.038,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: height * 0.012),
                              TextFormField(
                                controller: _udidController,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  hintText: 'Enter UDID card number',
                                  hintStyle: TextStyle(fontSize: width * 0.035),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: width * 0.04,
                                    vertical: height * 0.015,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(width * 0.025),
                                    borderSide: BorderSide(
                                        color:
                                            (_formSubmitted && _showUdidError)
                                                ? Colors.red
                                                : const Color(0xFFF76048),
                                        width: 2),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(width * 0.025),
                                    borderSide: BorderSide(
                                        color:
                                            (_formSubmitted && _showUdidError)
                                                ? Colors.red
                                                : const Color(0xFFF76048),
                                        width: 2),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(width * 0.025),
                                    borderSide: BorderSide(
                                        color:
                                            (_formSubmitted && _showUdidError)
                                                ? Colors.red
                                                : Colors.green,
                                        width: 2),
                                  ),
                                  errorText: (_formSubmitted &&
                                          _udidController.text.isEmpty)
                                      ? 'UDID card number is required'
                                      : null,
                                ),
                                onChanged: (value) {
                                  if (_formSubmitted) {
                                    setState(() {
                                      _showUdidError = value.isEmpty;
                                    });
                                  }
                                },
                              ),
                              SizedBox(height: height * 0.025),
                              Text(
                                'Type of Disability (अपंगत्वाचा प्रकार):',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: width * 0.038,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: height * 0.012),
                              DropdownButtonFormField<String>(
                                value: _selectedDisabilityType,
                                isExpanded: true,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: width * 0.04,
                                    vertical: height * 0.015,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(width * 0.025),
                                    borderSide: BorderSide(
                                        color: (_formSubmitted &&
                                                _showDisabilityTypeError)
                                            ? Colors.red
                                            : const Color(0xFFF76048),
                                        width: 2),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(width * 0.025),
                                    borderSide: BorderSide(
                                        color: (_formSubmitted &&
                                                _showDisabilityTypeError)
                                            ? Colors.red
                                            : const Color(0xFFF76048),
                                        width: 2),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(width * 0.025),
                                    borderSide: BorderSide(
                                        color: (_formSubmitted &&
                                                _showDisabilityTypeError)
                                            ? Colors.red
                                            : Colors.green,
                                        width: 2),
                                  ),
                                  errorText: (_formSubmitted &&
                                          (_selectedDisabilityType == null ||
                                              _selectedDisabilityType!.isEmpty))
                                      ? 'Type of disability is required'
                                      : null,
                                ),
                                items: _disabilityTypes.map((disability) {
                                  return DropdownMenuItem<String>(
                                    value: disability['label'],
                                    child: Text(
                                      disability['label']!,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: width * 0.038),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (newValue) {
                                  setState(() {
                                    _selectedDisabilityType = newValue;
                                    if (_formSubmitted) {
                                      _showDisabilityTypeError =
                                          newValue == null || newValue.isEmpty;
                                    }
                                  });
                                },
                                hint: Text('Select Type of Disability',
                                    style: TextStyle(fontSize: width * 0.035)),
                              ),
                              SizedBox(height: height * 0.025),
                              Text(
                                'Percentage of Disability (अपंगत्वाची टक्केवारी):',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: width * 0.038,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: height * 0.012),
                              DropdownButtonFormField<String>(
                                value: _selectedDisabilityPercentage,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: width * 0.04,
                                    vertical: height * 0.015,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(width * 0.025),
                                    borderSide: BorderSide(
                                        color: (_formSubmitted &&
                                                _showDisabilityPercentageError)
                                            ? Colors.red
                                            : const Color(0xFFF76048),
                                        width: 2),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(width * 0.025),
                                    borderSide: BorderSide(
                                        color: (_formSubmitted &&
                                                _showDisabilityPercentageError)
                                            ? Colors.red
                                            : const Color(0xFFF76048),
                                        width: 2),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(width * 0.025),
                                    borderSide: BorderSide(
                                        color: (_formSubmitted &&
                                                _showDisabilityPercentageError)
                                            ? Colors.red
                                            : Colors.green,
                                        width: 2),
                                  ),
                                  errorText: (_formSubmitted &&
                                          (_selectedDisabilityPercentage ==
                                                  null ||
                                              _selectedDisabilityPercentage!
                                                  .isEmpty))
                                      ? 'Percentage of disability is required'
                                      : null,
                                ),
                                items: _disabilityPercentages.map((percentage) {
                                  return DropdownMenuItem<String>(
                                    value: percentage,
                                    child: Text(percentage,
                                        style:
                                            TextStyle(fontSize: width * 0.038)),
                                  );
                                }).toList(),
                                onChanged: (newValue) {
                                  setState(() {
                                    _selectedDisabilityPercentage = newValue;
                                    if (_formSubmitted) {
                                      _showDisabilityPercentageError =
                                          newValue == null || newValue.isEmpty;
                                    }
                                  });
                                },
                                hint: Text('Select Percentage',
                                    style: TextStyle(fontSize: width * 0.035)),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.03),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(width * 0.05),
                        border: Border.all(
                            color: const Color(0xFFF76048), width: 2),
                      ),
                      padding: EdgeInsets.all(width * 0.04),
                      child: Column(
                        children: [
                          _buildInfoCard('Verification Status',
                              widget.verificationStatus, width),
                          SizedBox(height: height * 0.035),
                          Center(
                            child: Builder(
                              builder: (context) {
                                if (widget.verificationStatus.isEmpty) {
                                  return ElevatedButton(
                                    onPressed:
                                        _isLoading ? null : _validateAndProceed,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFF76048),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            width * 0.075),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: width * 0.1,
                                        vertical: height * 0.012,
                                      ),
                                    ),
                                    child: Text(
                                      'Complete Your KYC\nतुमची केवायसी पूर्ण करा',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: width * 0.04,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  );
                                } else if (widget.verificationStatus ==
                                    'Application Rejected') {
                                  return ElevatedButton(
                                    onPressed:
                                        _isLoading ? null : _validateAndProceed,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFF76048),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            width * 0.075),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: width * 0.1,
                                        vertical: height * 0.012,
                                      ),
                                    ),
                                    child: Text(
                                      'Re-Complete Your KYC\nतुमची केवायसी पूर्ण करा',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: width * 0.04,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  );
                                } else if (widget.verificationStatus ==
                                    'Verification In Progress') {
                                  return ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.blue,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            width * 0.075),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: width * 0.1,
                                        vertical: height * 0.012,
                                      ),
                                    ),
                                    child: Text(
                                      'Verification in Process\nपडताळणी प्रक्रियेत आहे',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: width * 0.04,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  );
                                } else if (widget.verificationStatus ==
                                    'Application Approved') {
                                  return ElevatedButton(
                                    onPressed: () {
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              CertificateWebViewScreen(
                                                  url: widget.url),
                                        ),
                                        (Route<dynamic> route) => false,
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.black,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            width * 0.075),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: width * 0.1,
                                        vertical: height * 0.012,
                                      ),
                                    ),
                                    child: Text(
                                      'View Certificate\nप्रमाणपत्र पहा',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: width * 0.04,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  );
                                }
                                return Container();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_isLoading)
              Center(
                child: CircularProgressIndicator(
                  strokeWidth: width * 0.01,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, double width) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(width * 0.038),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(width * 0.025),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: width * 0.035,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: width * 0.012),
          Text(
            value,
            style: TextStyle(
              fontSize: width * 0.04,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// import 'dart:convert';

// import 'package:divyang_pimpri_chinchwad_municipal_corporation/KYC_Screens/aadhar_verification_screen.dart';
// import 'package:divyang_pimpri_chinchwad_municipal_corporation/KYC_Screens/view_certificate_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:http/http.dart' as http;

// class DivyangDetailesScreen extends StatefulWidget {
//   final String aadharNumber;
//   final String mobileNumber;
//   final String fullName;
//   final String verificationStatus;
//   final String url;
//   final String aadhaarNumber;
//   final String addresss;
//   final String gender;

//   const DivyangDetailesScreen({
//     super.key,
//     required this.aadharNumber,
//     required this.mobileNumber,
//     required this.fullName,
//     required this.url,
//     required this.aadhaarNumber,
//     required this.addresss,
//     required this.gender,
//     required this.verificationStatus,
//   });

//   @override
//   State<DivyangDetailesScreen> createState() => _DivyangDetailesScreenState();
// }

// class _DivyangDetailesScreenState extends State<DivyangDetailesScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _aadharController = TextEditingController();
//   final TextEditingController _addressController = TextEditingController();
//   final TextEditingController _udidController = TextEditingController();
//   bool _isLoading = false;
//   String? _selectedGender;
//   String? _selectedDisabilityType;
//   String? _selectedDisabilityPercentage;
//   bool _dataLoaded = false;
//   bool _formSubmitted = false;

//   // Validation flags
//   bool _showAadharError = false;
//   bool _showAddressError = false;
//   bool _showGenderError = false;
//   bool _showUdidError = false;
//   bool _showDisabilityTypeError = false;
//   bool _showDisabilityPercentageError = false;

//   // Disability types list
//   final List<Map<String, String>> _disabilityTypes = [
//     {'value': '1', 'label': 'पूर्णतः अंध (Blindness)'},
//     {'value': '2', 'label': 'अंशतः अंध (Low Vision)'},
//     {'value': '3', 'label': 'कर्णबधीर (Hearing Impairment)'},
//     {'value': '4', 'label': 'वाचा दोष (Speech and Language Disability)'},
//     {'value': '5', 'label': 'अस्थिव्यंग (Locomotor Disability)'},
//     {'value': '6', 'label': 'मानसिक आजार (Mental Illness)'},
//     {'value': '7', 'label': 'अध्ययन अक्षम (Learning Disability)'},
//     {'value': '8', 'label': 'मेंदूचा पक्षाघात (Cerebral Palsy)'},
//     {'value': '9', 'label': 'स्वमग्न (Autism)'},
//     {'value': '10', 'label': 'बहुविकलांग (Multiple Disability)'},
//     {'value': '11', 'label': 'कुष्ठरोग (Leprosy Cured Persons)'},
//     {'value': '12', 'label': 'बुटकेपणा (Dwarfism)'},
//     {'value': '13', 'label': 'बौद्धिक अक्षमता (Intellectual Disability)'},
//     {'value': '14', 'label': 'माशपेशीय क्षरण (Muscular Disability)'},
//     {
//       'value': '15',
//       'label': 'मज्जासंस्थेचे तीव्र आजार (Chronic Neurological Conditions)'
//     },
//     {'value': '16', 'label': 'मल्टिपल स्क्लेरोसिस (Multiple Sclerosis)'},
//     {'value': '17', 'label': 'थॅलेसिमिया (Thalassemia)'},
//     {'value': '18', 'label': 'अधिक रक्तस्त्राव (Hemophilia)'},
//     {'value': '19', 'label': 'सिकल सेल (Sickle Cell Disease)'},
//     {'value': '20', 'label': 'अॅसिड अटॅक (Acid Attack Victim)'},
//     {'value': '21', 'label': 'कंपवात रोग (Parkinson\'s Disease)'},
//   ];

//   // Generate percentage list from 40% to 100%
//   List<String> get _disabilityPercentages {
//     return List.generate(61, (index) => '${40 + index}%');
//   }

//   @override
//   void initState() {
//     super.initState();
//     // Initialize with null instead of default value
//     _selectedGender = null;
//     _aadharController.text = widget.aadharNumber;
//   }

//   @override
//   void dispose() {
//     _aadharController.dispose();
//     _addressController.dispose();
//     _udidController.dispose();
//     super.dispose();
//   }

//   Future<void> _validateAndProceed() async {
//     setState(() {
//       _formSubmitted = true;
//     });

//     // Validate form fields
//     bool isValid = true;
//     String? errorMessage;

//     if (_aadharController.text.isEmpty) {
//       errorMessage = 'Please enter Aadhaar number';
//       isValid = false;
//       setState(() {
//         _showAadharError = true;
//       });
//     } else if (_aadharController.text.length != 12) {
//       errorMessage = 'Aadhaar must be exactly 12 digits';
//       isValid = false;
//       setState(() {
//         _showAadharError = true;
//       });
//     } else if (_addressController.text.isEmpty) {
//       errorMessage = 'Please enter your address';
//       isValid = false;
//       setState(() {
//         _showAddressError = true;
//       });
//     } else if (_selectedGender == null || _selectedGender!.isEmpty) {
//       errorMessage = 'Please select your gender';
//       isValid = false;
//       setState(() {
//         _showGenderError = true;
//       });
//     } else if (_udidController.text.isEmpty) {
//       errorMessage = 'Please enter UDID card number';
//       isValid = false;
//       setState(() {
//         _showUdidError = true;
//       });
//     } else if (_selectedDisabilityType == null ||
//         _selectedDisabilityType!.isEmpty) {
//       errorMessage = 'Please select type of disability';
//       isValid = false;
//       setState(() {
//         _showDisabilityTypeError = true;
//       });
//     } else if (_selectedDisabilityPercentage == null ||
//         _selectedDisabilityPercentage!.isEmpty) {
//       errorMessage = 'Please select percentage of disability';
//       isValid = false;
//       setState(() {
//         _showDisabilityPercentageError = true;
//       });
//     }

//     if (!isValid) {
//       Fluttertoast.showToast(
//         msg: errorMessage!,
//         toastLength: Toast.LENGTH_LONG,
//         gravity: ToastGravity.BOTTOM,
//         backgroundColor: Colors.blue,
//         textColor: Colors.white,
//       );
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       // Prepare request body with correct field names
//       final Map<String, dynamic> requestBody = {
//         "AadhaarNumber": _aadharController.text,
//         "Address": _addressController.text,
//         "Gender": _selectedGender,
//         "UDIDNumber": _udidController.text,
//         "DisabilityType": _selectedDisabilityType,
//         "DisabilityPercentage": _selectedDisabilityPercentage,
//       };

//       print('Sending request: ${json.encode(requestBody)}');

//       // Make API call
//       final response = await http.post(
//         Uri.parse(
//             'https://divyangpcmc.altwise.in/api/v1/aadhar/SubmitUserDetails'),
//         headers: {
//           'Content-Type': 'application/json',
//         },
//         body: json.encode(requestBody),
//       );

//       print('API Response: ${response.statusCode} - ${response.body}');

//       setState(() {
//         _isLoading = false;
//       });

//       final responseData = json.decode(response.body);

//       if (response.statusCode == 200) {
//         Fluttertoast.showToast(
//           msg: responseData['Message'] ?? 'Details updated successfully',
//           toastLength: Toast.LENGTH_LONG,
//           gravity: ToastGravity.BOTTOM,
//           backgroundColor: Colors.green,
//           textColor: Colors.white,
//         );

//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => AadharVerificationKYCScreen(
//               ppoNumber: widget.aadharNumber,
//               fullName: widget.fullName,
//               mobileNumber: widget.mobileNumber,
//               aadharNumber: _aadharController.text,
//               addressEnter: _addressController.text,
//               gender: _selectedGender!,
//               udidNumber: _udidController.text,
//               disabilityType: _selectedDisabilityType!,
//               disabilityPercentage: _selectedDisabilityPercentage!,
//             ),
//           ),
//         );
//       } else {
//         Fluttertoast.showToast(
//           msg: responseData['Message'] ??
//               'Failed to submit details\n डेटा सबमिट करण्यात अयशस्वी',
//           toastLength: Toast.LENGTH_LONG,
//           gravity: ToastGravity.BOTTOM,
//           backgroundColor: Colors.red,
//           textColor: Colors.white,
//         );
//       }
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });

//       Fluttertoast.showToast(
//         msg:
//             'Note: Please check your internet connection\nकृपया तुमचे इंटरनेट कनेक्शन तपासा.',
//         toastLength: Toast.LENGTH_LONG,
//         gravity: ToastGravity.BOTTOM,
//         backgroundColor: Colors.red,
//         textColor: Colors.white,
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Get screen dimensions
//     final size = MediaQuery.of(context).size;
//     final width = size.width;
//     final height = size.height;

//     return SafeArea(
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text(
//             'Divyang Details [Step-2]',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: width * 0.05, // Responsive font size
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           backgroundColor: const Color(0xFFF76048),
//         ),
//         body: Stack(
//           children: [
//             SingleChildScrollView(
//               padding: EdgeInsets.all(width * 0.04), // Responsive padding
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   children: [
//                     Container(
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(width * 0.03),
//                         border: Border.all(
//                             color: const Color(0xFFF76048), width: 2),
//                       ),
//                       child: Padding(
//                         padding: EdgeInsets.all(width * 0.04),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 _buildInfoCard(
//                                     'Full Name', widget.fullName, width),
//                                 SizedBox(height: height * 0.02),
//                                 _buildInfoCard('Mobile Number',
//                                     widget.mobileNumber, width),
//                                 SizedBox(height: height * 0.02),

//                                 // Show additional fields if status is Verification In Progress or Approved
//                                 if ((widget.verificationStatus ==
//                                             'Verification In Progress' ||
//                                         widget.verificationStatus ==
//                                             'Application Approved') &&
//                                     _dataLoaded) ...[
//                                   SizedBox(height: height * 0.02),
//                                   _buildInfoCard('AadhaarNumber',
//                                       widget.aadhaarNumber, width),
//                                   SizedBox(height: height * 0.02),
//                                   _buildInfoCard(
//                                       'Addresss', widget.addresss, width),
//                                   SizedBox(height: height * 0.02),
//                                   _buildInfoCard(
//                                       'Gender', widget.gender, width),
//                                 ],
//                               ],
//                             ),

//                             SizedBox(height: height * 0.025),

//                             // Only show these fields if verification is NOT in progress and NOT approved
//                             if (widget.verificationStatus !=
//                                     'Verification In Progress' &&
//                                 widget.verificationStatus !=
//                                     'Application Approved') ...[
//                               Text(
//                                 'Enter Your Aadhar Number(आधार क्रमांक टाका):',
//                                 style: TextStyle(
//                                   color: Colors.black54,
//                                   fontSize: width * 0.038,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               SizedBox(height: height * 0.012),
//                               TextFormField(
//                                 controller: _aadharController,
//                                 keyboardType: TextInputType.number,
//                                 maxLength: 12,
//                                 decoration: InputDecoration(
//                                   hintText: 'Enter Aadhaar number',
//                                   hintStyle: TextStyle(fontSize: width * 0.035),
//                                   filled: true,
//                                   fillColor: Colors.white,
//                                   contentPadding: EdgeInsets.symmetric(
//                                     horizontal: width * 0.04,
//                                     vertical: height * 0.015,
//                                   ),
//                                   border: OutlineInputBorder(
//                                     borderRadius:
//                                         BorderRadius.circular(width * 0.025),
//                                     borderSide: BorderSide(
//                                         color:
//                                             (_formSubmitted && _showAadharError)
//                                                 ? Colors.red
//                                                 : const Color(0xFFF76048),
//                                         width: 2),
//                                   ),
//                                   enabledBorder: OutlineInputBorder(
//                                     borderRadius:
//                                         BorderRadius.circular(width * 0.025),
//                                     borderSide: BorderSide(
//                                         color:
//                                             (_formSubmitted && _showAadharError)
//                                                 ? Colors.red
//                                                 : const Color(0xFFF76048),
//                                         width: 2),
//                                   ),
//                                   focusedBorder: OutlineInputBorder(
//                                     borderRadius:
//                                         BorderRadius.circular(width * 0.025),
//                                     borderSide: BorderSide(
//                                         color:
//                                             (_formSubmitted && _showAadharError)
//                                                 ? Colors.red
//                                                 : Colors.green,
//                                         width: 2),
//                                   ),
//                                   errorText: (_formSubmitted &&
//                                           _aadharController.text.isEmpty)
//                                       ? 'Aadhaar number is required'
//                                       : (_formSubmitted &&
//                                               _aadharController.text.length !=
//                                                   12)
//                                           ? 'Aadhaar must be exactly 12 digits'
//                                           : null,
//                                 ),
//                                 onChanged: (value) {
//                                   if (_formSubmitted) {
//                                     setState(() {
//                                       _showAadharError =
//                                           value.isEmpty || value.length != 12;
//                                     });
//                                   }
//                                 },
//                               ),
//                               SizedBox(height: height * 0.025),
//                               Text(
//                                 'Enter Your Address( पत्ता टाका):',
//                                 style: TextStyle(
//                                   color: Colors.black54,
//                                   fontSize: width * 0.038,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               SizedBox(height: height * 0.012),
//                               TextFormField(
//                                 controller: _addressController,
//                                 maxLines: 3,
//                                 decoration: InputDecoration(
//                                   hintText: 'Enter your address',
//                                   hintStyle: TextStyle(fontSize: width * 0.035),
//                                   filled: true,
//                                   fillColor: Colors.white,
//                                   contentPadding: EdgeInsets.symmetric(
//                                     horizontal: width * 0.04,
//                                     vertical: height * 0.015,
//                                   ),
//                                   border: OutlineInputBorder(
//                                     borderRadius:
//                                         BorderRadius.circular(width * 0.025),
//                                     borderSide: BorderSide(
//                                         color: (_formSubmitted &&
//                                                 _showAddressError)
//                                             ? Colors.red
//                                             : const Color(0xFFF76048),
//                                         width: 2),
//                                   ),
//                                   enabledBorder: OutlineInputBorder(
//                                     borderRadius:
//                                         BorderRadius.circular(width * 0.025),
//                                     borderSide: BorderSide(
//                                         color: (_formSubmitted &&
//                                                 _showAddressError)
//                                             ? Colors.red
//                                             : const Color(0xFFF76048),
//                                         width: 2),
//                                   ),
//                                   focusedBorder: OutlineInputBorder(
//                                     borderRadius:
//                                         BorderRadius.circular(width * 0.025),
//                                     borderSide: BorderSide(
//                                         color: (_formSubmitted &&
//                                                 _showAddressError)
//                                             ? Colors.red
//                                             : Colors.green,
//                                         width: 2),
//                                   ),
//                                   errorText: (_formSubmitted &&
//                                           _addressController.text.isEmpty)
//                                       ? 'Address is required'
//                                       : null,
//                                 ),
//                                 onChanged: (value) {
//                                   if (_formSubmitted) {
//                                     setState(() {
//                                       _showAddressError = value.isEmpty;
//                                     });
//                                   }
//                                 },
//                               ),
//                               SizedBox(height: height * 0.025),
//                               Text(
//                                 'Enter Your Gender( लिंग टाका):',
//                                 style: TextStyle(
//                                   color: Colors.black54,
//                                   fontSize: width * 0.038,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               SizedBox(height: height * 0.012),
//                               DropdownButtonFormField<String>(
//                                 value: _selectedGender,
//                                 decoration: InputDecoration(
//                                   filled: true,
//                                   fillColor: Colors.white,
//                                   contentPadding: EdgeInsets.symmetric(
//                                     horizontal: width * 0.04,
//                                     vertical: height * 0.015,
//                                   ),
//                                   border: OutlineInputBorder(
//                                     borderRadius:
//                                         BorderRadius.circular(width * 0.025),
//                                     borderSide: BorderSide(
//                                         color:
//                                             (_formSubmitted && _showGenderError)
//                                                 ? Colors.red
//                                                 : const Color(0xFFF76048),
//                                         width: 2),
//                                   ),
//                                   enabledBorder: OutlineInputBorder(
//                                     borderRadius:
//                                         BorderRadius.circular(width * 0.025),
//                                     borderSide: BorderSide(
//                                         color:
//                                             (_formSubmitted && _showGenderError)
//                                                 ? Colors.red
//                                                 : const Color(0xFFF76048),
//                                         width: 2),
//                                   ),
//                                   focusedBorder: OutlineInputBorder(
//                                     borderRadius:
//                                         BorderRadius.circular(width * 0.025),
//                                     borderSide: BorderSide(
//                                         color:
//                                             (_formSubmitted && _showGenderError)
//                                                 ? Colors.red
//                                                 : Colors.green,
//                                         width: 2),
//                                   ),
//                                   errorText: (_formSubmitted &&
//                                           (_selectedGender == null ||
//                                               _selectedGender!.isEmpty))
//                                       ? 'Gender is required'
//                                       : null,
//                                 ),
//                                 items: [
//                                   DropdownMenuItem<String>(
//                                     value: 'Male',
//                                     child: Text('Male',
//                                         style:
//                                             TextStyle(fontSize: width * 0.038)),
//                                   ),
//                                   DropdownMenuItem<String>(
//                                     value: 'Female',
//                                     child: Text('Female',
//                                         style:
//                                             TextStyle(fontSize: width * 0.038)),
//                                   ),
//                                   DropdownMenuItem<String>(
//                                     value: 'Transgender',
//                                     child: Text('Transgender',
//                                         style:
//                                             TextStyle(fontSize: width * 0.038)),
//                                   ),
//                                 ],
//                                 onChanged: (newValue) {
//                                   setState(() {
//                                     _selectedGender = newValue;
//                                     if (_formSubmitted) {
//                                       _showGenderError =
//                                           newValue == null || newValue.isEmpty;
//                                     }
//                                   });
//                                 },
//                                 hint: Text('Please select gender',
//                                     style: TextStyle(fontSize: width * 0.035)),
//                               ),
//                               SizedBox(height: height * 0.025),

//                               // UDID Card Number field
//                               Text(
//                                 'Enter UDID Card Number (UDID कार्ड नंबर टाका):',
//                                 style: TextStyle(
//                                   color: Colors.black54,
//                                   fontSize: width * 0.038,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               SizedBox(height: height * 0.012),
//                               TextFormField(
//                                 controller: _udidController,
//                                 keyboardType: TextInputType.text,
//                                 decoration: InputDecoration(
//                                   hintText: 'Enter UDID card number',
//                                   hintStyle: TextStyle(fontSize: width * 0.035),
//                                   filled: true,
//                                   fillColor: Colors.white,
//                                   contentPadding: EdgeInsets.symmetric(
//                                     horizontal: width * 0.04,
//                                     vertical: height * 0.015,
//                                   ),
//                                   border: OutlineInputBorder(
//                                     borderRadius:
//                                         BorderRadius.circular(width * 0.025),
//                                     borderSide: BorderSide(
//                                         color:
//                                             (_formSubmitted && _showUdidError)
//                                                 ? Colors.red
//                                                 : const Color(0xFFF76048),
//                                         width: 2),
//                                   ),
//                                   enabledBorder: OutlineInputBorder(
//                                     borderRadius:
//                                         BorderRadius.circular(width * 0.025),
//                                     borderSide: BorderSide(
//                                         color:
//                                             (_formSubmitted && _showUdidError)
//                                                 ? Colors.red
//                                                 : const Color(0xFFF76048),
//                                         width: 2),
//                                   ),
//                                   focusedBorder: OutlineInputBorder(
//                                     borderRadius:
//                                         BorderRadius.circular(width * 0.025),
//                                     borderSide: BorderSide(
//                                         color:
//                                             (_formSubmitted && _showUdidError)
//                                                 ? Colors.red
//                                                 : Colors.green,
//                                         width: 2),
//                                   ),
//                                   errorText: (_formSubmitted &&
//                                           _udidController.text.isEmpty)
//                                       ? 'UDID card number is required'
//                                       : null,
//                                 ),
//                                 onChanged: (value) {
//                                   if (_formSubmitted) {
//                                     setState(() {
//                                       _showUdidError = value.isEmpty;
//                                     });
//                                   }
//                                 },
//                               ),
//                               SizedBox(height: height * 0.025),

//                               // Type of Disability field
//                               Text(
//                                 'Type of Disability (अपंगत्वाचा प्रकार):',
//                                 style: TextStyle(
//                                   color: Colors.black54,
//                                   fontSize: width * 0.038,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               SizedBox(height: height * 0.012),
//                               DropdownButtonFormField<String>(
//                                 value: _selectedDisabilityType,
//                                 isExpanded: true,
//                                 decoration: InputDecoration(
//                                   filled: true,
//                                   fillColor: Colors.white,
//                                   contentPadding: EdgeInsets.symmetric(
//                                     horizontal: width * 0.04,
//                                     vertical: height * 0.015,
//                                   ),
//                                   border: OutlineInputBorder(
//                                     borderRadius:
//                                         BorderRadius.circular(width * 0.025),
//                                     borderSide: BorderSide(
//                                         color: (_formSubmitted &&
//                                                 _showDisabilityTypeError)
//                                             ? Colors.red
//                                             : const Color(0xFFF76048),
//                                         width: 2),
//                                   ),
//                                   enabledBorder: OutlineInputBorder(
//                                     borderRadius:
//                                         BorderRadius.circular(width * 0.025),
//                                     borderSide: BorderSide(
//                                         color: (_formSubmitted &&
//                                                 _showDisabilityTypeError)
//                                             ? Colors.red
//                                             : const Color(0xFFF76048),
//                                         width: 2),
//                                   ),
//                                   focusedBorder: OutlineInputBorder(
//                                     borderRadius:
//                                         BorderRadius.circular(width * 0.025),
//                                     borderSide: BorderSide(
//                                         color: (_formSubmitted &&
//                                                 _showDisabilityTypeError)
//                                             ? Colors.red
//                                             : Colors.green,
//                                         width: 2),
//                                   ),
//                                   errorText: (_formSubmitted &&
//                                           (_selectedDisabilityType == null ||
//                                               _selectedDisabilityType!.isEmpty))
//                                       ? 'Type of disability is required'
//                                       : null,
//                                 ),
//                                 items: _disabilityTypes.map((disability) {
//                                   return DropdownMenuItem<String>(
//                                     value: disability['label'],
//                                     child: Text(
//                                       disability['label']!,
//                                       overflow: TextOverflow.ellipsis,
//                                       style: TextStyle(fontSize: width * 0.038),
//                                     ),
//                                   );
//                                 }).toList(),
//                                 onChanged: (newValue) {
//                                   setState(() {
//                                     _selectedDisabilityType = newValue;
//                                     if (_formSubmitted) {
//                                       _showDisabilityTypeError =
//                                           newValue == null || newValue.isEmpty;
//                                     }
//                                   });
//                                 },
//                                 hint: Text('Select Type of Disability',
//                                     style: TextStyle(fontSize: width * 0.035)),
//                               ),
//                               SizedBox(height: height * 0.025),

//                               // Percentage of Disability field
//                               Text(
//                                 'Percentage of Disability (अपंगत्वाची टक्केवारी):',
//                                 style: TextStyle(
//                                   color: Colors.black54,
//                                   fontSize: width * 0.038,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               SizedBox(height: height * 0.012),
//                               DropdownButtonFormField<String>(
//                                 value: _selectedDisabilityPercentage,
//                                 decoration: InputDecoration(
//                                   filled: true,
//                                   fillColor: Colors.white,
//                                   contentPadding: EdgeInsets.symmetric(
//                                     horizontal: width * 0.04,
//                                     vertical: height * 0.015,
//                                   ),
//                                   border: OutlineInputBorder(
//                                     borderRadius:
//                                         BorderRadius.circular(width * 0.025),
//                                     borderSide: BorderSide(
//                                         color: (_formSubmitted &&
//                                                 _showDisabilityPercentageError)
//                                             ? Colors.red
//                                             : const Color(0xFFF76048),
//                                         width: 2),
//                                   ),
//                                   enabledBorder: OutlineInputBorder(
//                                     borderRadius:
//                                         BorderRadius.circular(width * 0.025),
//                                     borderSide: BorderSide(
//                                         color: (_formSubmitted &&
//                                                 _showDisabilityPercentageError)
//                                             ? Colors.red
//                                             : const Color(0xFFF76048),
//                                         width: 2),
//                                   ),
//                                   focusedBorder: OutlineInputBorder(
//                                     borderRadius:
//                                         BorderRadius.circular(width * 0.025),
//                                     borderSide: BorderSide(
//                                         color: (_formSubmitted &&
//                                                 _showDisabilityPercentageError)
//                                             ? Colors.red
//                                             : Colors.green,
//                                         width: 2),
//                                   ),
//                                   errorText: (_formSubmitted &&
//                                           (_selectedDisabilityPercentage ==
//                                                   null ||
//                                               _selectedDisabilityPercentage!
//                                                   .isEmpty))
//                                       ? 'Percentage of disability is required'
//                                       : null,
//                                 ),
//                                 items: _disabilityPercentages.map((percentage) {
//                                   return DropdownMenuItem<String>(
//                                     value: percentage,
//                                     child: Text(percentage,
//                                         style:
//                                             TextStyle(fontSize: width * 0.038)),
//                                   );
//                                 }).toList(),
//                                 onChanged: (newValue) {
//                                   setState(() {
//                                     _selectedDisabilityPercentage = newValue;
//                                     if (_formSubmitted) {
//                                       _showDisabilityPercentageError =
//                                           newValue == null || newValue.isEmpty;
//                                     }
//                                   });
//                                 },
//                                 hint: Text('Select Percentage',
//                                     style: TextStyle(fontSize: width * 0.035)),
//                               ),
//                             ],
//                           ],
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: height * 0.03),
//                     Container(
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(width * 0.05),
//                         border: Border.all(
//                             color: const Color(0xFFF76048), width: 2),
//                       ),
//                       padding: EdgeInsets.all(width * 0.04),
//                       child: Column(
//                         children: [
//                           _buildInfoCard('Verification Status',
//                               widget.verificationStatus, width),
//                           SizedBox(height: height * 0.035),
//                           Center(
//                             child: Builder(
//                               builder: (context) {
//                                 if (widget.verificationStatus.isEmpty) {
//                                   return ElevatedButton(
//                                     onPressed:
//                                         _isLoading ? null : _validateAndProceed,
//                                     style: ElevatedButton.styleFrom(
//                                       backgroundColor: const Color(0xFFF76048),
//                                       foregroundColor: Colors.white,
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(
//                                             width * 0.075),
//                                       ),
//                                       padding: EdgeInsets.symmetric(
//                                         horizontal: width * 0.1,
//                                         vertical: height * 0.012,
//                                       ),
//                                     ),
//                                     child: Text(
//                                       'Complete Your KYC\nतुमची केवायसी पूर्ण करा',
//                                       style: TextStyle(
//                                         color: Colors.white,
//                                         fontSize: width * 0.04,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                       textAlign: TextAlign.center,
//                                     ),
//                                   );
//                                 } else if (widget.verificationStatus ==
//                                     'Application Rejected') {
//                                   return ElevatedButton(
//                                     onPressed:
//                                         _isLoading ? null : _validateAndProceed,
//                                     style: ElevatedButton.styleFrom(
//                                       backgroundColor: const Color(0xFFF76048),
//                                       foregroundColor: Colors.white,
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(
//                                             width * 0.075),
//                                       ),
//                                       padding: EdgeInsets.symmetric(
//                                         horizontal: width * 0.1,
//                                         vertical: height * 0.012,
//                                       ),
//                                     ),
//                                     child: Text(
//                                       'Re-Complete Your KYC\nतुमची केवायसी पूर्ण करा',
//                                       style: TextStyle(
//                                         color: Colors.white,
//                                         fontSize: width * 0.04,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                       textAlign: TextAlign.center,
//                                     ),
//                                   );
//                                 } else if (widget.verificationStatus ==
//                                     'Verification In Progress') {
//                                   return ElevatedButton(
//                                     onPressed: () {},
//                                     style: ElevatedButton.styleFrom(
//                                       backgroundColor: Colors.blue,
//                                       foregroundColor: Colors.blue,
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(
//                                             width * 0.075),
//                                       ),
//                                       padding: EdgeInsets.symmetric(
//                                         horizontal: width * 0.1,
//                                         vertical: height * 0.012,
//                                       ),
//                                     ),
//                                     child: Text(
//                                       'Verification in Process\nपडताळणी प्रक्रियेत आहे',
//                                       style: TextStyle(
//                                         color: Colors.white,
//                                         fontSize: width * 0.04,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                       textAlign: TextAlign.center,
//                                     ),
//                                   );
//                                 } else if (widget.verificationStatus ==
//                                     'Application Approved') {
//                                   return ElevatedButton(
//                                     onPressed: () {
//                                       Navigator.pushAndRemoveUntil(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder: (context) =>
//                                               CertificateWebViewScreen(
//                                                   url: widget.url),
//                                         ),
//                                         (Route<dynamic> route) => false,
//                                       );
//                                     },
//                                     style: ElevatedButton.styleFrom(
//                                       backgroundColor: Colors.green,
//                                       foregroundColor: Colors.black,
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(
//                                             width * 0.075),
//                                       ),
//                                       padding: EdgeInsets.symmetric(
//                                         horizontal: width * 0.1,
//                                         vertical: height * 0.012,
//                                       ),
//                                     ),
//                                     child: Text(
//                                       'View Certificate\nप्रमाणपत्र पहा',
//                                       style: TextStyle(
//                                         color: Colors.white,
//                                         fontSize: width * 0.04,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                       textAlign: TextAlign.center,
//                                     ),
//                                   );
//                                 }
//                                 return Container();
//                               },
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             if (_isLoading)
//               Center(
//                 child: CircularProgressIndicator(
//                   strokeWidth: width * 0.01,
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoCard(String title, String value, double width) {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.all(width * 0.038),
//       decoration: BoxDecoration(
//         color: Colors.grey[200],
//         borderRadius: BorderRadius.circular(width * 0.025),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: TextStyle(
//               fontSize: width * 0.035,
//               color: Colors.grey,
//             ),
//           ),
//           SizedBox(height: width * 0.012),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: width * 0.04,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

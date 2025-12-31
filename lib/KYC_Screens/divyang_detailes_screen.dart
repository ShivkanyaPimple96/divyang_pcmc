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
  String? _storedAadhar;
  String? _storedAddress;
  String? _storedGender;
  bool _dataLoaded = false;
  bool _formSubmitted = false;

  // Validation flags
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
    _selectedGender = 'Male';
    _aadharController.text = widget.aadharNumber;
  }

  @override
  void dispose() {
    _aadharController.dispose();
    _addressController.dispose();
    _udidController.dispose();
    super.dispose();
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
    } else if (_aadharController.text.length != 12) {
      errorMessage = 'Aadhaar must be exactly 12 digits';
      isValid = false;
    } else if (_addressController.text.isEmpty) {
      errorMessage = 'Please enter your address';
      isValid = false;
    } else if (_selectedGender == null || _selectedGender!.isEmpty) {
      errorMessage = 'Please select your gender';
      isValid = false;
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
      // Prepare request body with correct field names
      final Map<String, dynamic> requestBody = {
        "AadhaarNumber": _aadharController.text,
        "Address": _addressController.text,
        "Gender": _selectedGender,
        "UDIDNumber": _udidController.text,
        "DisabilityType": _selectedDisabilityType,
        "DisabilityPercentage": _selectedDisabilityPercentage,
      };

      print('Sending request: ${json.encode(requestBody)}');

      // Make API call
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
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Divyang Details [Step-2]',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: const Color(0xFFF76048),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: const Color(0xFFF76048), width: 2),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInfoCard('Full Name', widget.fullName),
                                const SizedBox(height: 15),
                                _buildInfoCard(
                                    'Mobile Number', widget.mobileNumber),
                                const SizedBox(height: 15),

                                // Show additional fields if status is Verification In Progress or Approved
                                if ((widget.verificationStatus ==
                                            'Verification In Progress' ||
                                        widget.verificationStatus ==
                                            'Application Approved') &&
                                    _dataLoaded) ...[
                                  const SizedBox(height: 15),
                                  _buildInfoCard(
                                      'AadhaarNumber', widget.aadhaarNumber),
                                  const SizedBox(height: 15),
                                  _buildInfoCard('Addresss', widget.addresss),
                                  const SizedBox(height: 15),
                                  _buildInfoCard('Gender', widget.gender),
                                ],
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Only show these fields if verification is NOT in progress and NOT approved
                            if (widget.verificationStatus !=
                                    'Verification In Progress' &&
                                widget.verificationStatus !=
                                    'Application Approved') ...[
                              Text(
                                'Enter Your Aadhar Number(आधार क्रमांक टाका):',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: _aadharController,
                                keyboardType: TextInputType.number,
                                maxLength: 12,
                                decoration: InputDecoration(
                                  hintText:
                                      'Current Aadhar: ${widget.aadharNumber}',
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                        color: Color(0xFFF76048), width: 2),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                        color: Color(0xFFF76048), width: 2),
                                  ),
                                  errorText: _aadharController
                                              .text.isNotEmpty &&
                                          _aadharController.text.length != 12
                                      ? 'Aadhar must be exactly 12 digits'
                                      : null,
                                ),
                                onChanged: (value) {
                                  setState(() {});
                                },
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Enter Your Address( पत्ता टाका):',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextFormField(
                                controller: _addressController,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                        color: Color(0xFFF76048), width: 2),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                        color: Color(0xFFF76048), width: 2),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Enter Your Gender( लिंग टाका):',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              DropdownButtonFormField<String>(
                                value: _selectedGender,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                        color: Color(0xFFF76048), width: 2),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                        color: Color(0xFFF76048), width: 2),
                                  ),
                                ),
                                items: [
                                  DropdownMenuItem<String>(
                                    value: 'Male',
                                    child: Text('Male'),
                                  ),
                                  DropdownMenuItem<String>(
                                    value: 'Female',
                                    child: Text('Female'),
                                  ),
                                  DropdownMenuItem<String>(
                                    value: 'Transgender',
                                    child: Text('Transgender'),
                                  ),
                                ].toList(),
                                onChanged: (newValue) {
                                  setState(() {
                                    _selectedGender = newValue;
                                  });
                                },
                                hint: const Text('Select Gender'),
                              ),
                              const SizedBox(height: 20),

                              // UDID Card Number field
                              Text(
                                'Enter UDID Card Number (UDID कार्ड नंबर टाका):',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: _udidController,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  hintText: 'Enter UDID card number',
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                        color:
                                            (_formSubmitted && _showUdidError)
                                                ? Colors.red
                                                : const Color(0xFFF76048),
                                        width: 2),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                        color:
                                            (_formSubmitted && _showUdidError)
                                                ? Colors.red
                                                : const Color(0xFFF76048),
                                        width: 2),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
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
                              const SizedBox(height: 20),

                              // Type of Disability field
                              Text(
                                'Type of Disability (अपंगत्वाचा प्रकार):',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              DropdownButtonFormField<String>(
                                value: _selectedDisabilityType,
                                isExpanded: true,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                        color: (_formSubmitted &&
                                                _showDisabilityTypeError)
                                            ? Colors.red
                                            : const Color(0xFFF76048),
                                        width: 2),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                        color: (_formSubmitted &&
                                                _showDisabilityTypeError)
                                            ? Colors.red
                                            : const Color(0xFFF76048),
                                        width: 2),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
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
                                    value: disability['value'],
                                    child: Text(
                                      disability['label']!,
                                      overflow: TextOverflow.ellipsis,
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
                                hint: const Text('Select Type of Disability'),
                              ),
                              const SizedBox(height: 20),

                              // Percentage of Disability field
                              Text(
                                'Percentage of Disability (अपंगत्वाची टक्केवारी):',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              DropdownButtonFormField<String>(
                                value: _selectedDisabilityPercentage,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                        color: (_formSubmitted &&
                                                _showDisabilityPercentageError)
                                            ? Colors.red
                                            : const Color(0xFFF76048),
                                        width: 2),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                        color: (_formSubmitted &&
                                                _showDisabilityPercentageError)
                                            ? Colors.red
                                            : const Color(0xFFF76048),
                                        width: 2),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
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
                                    child: Text(percentage),
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
                                hint: const Text('Select Percentage'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: const Color(0xFFF76048), width: 2),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildInfoCard(
                              'Verification Status', widget.verificationStatus),
                          const SizedBox(height: 30),
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
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 40, vertical: 10),
                                    ),
                                    child: const Text(
                                      'Complete Your KYC\nतुमची केवायसी पूर्ण करा',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
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
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 40, vertical: 10),
                                    ),
                                    child: const Text(
                                      'Re-Complete Your KYC\nतुमची केवायसी पूर्ण करा',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
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
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 40, vertical: 10),
                                    ),
                                    child: const Text(
                                      'Verification in Process\nपडताळणी प्रक्रियेत आहे',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
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
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 40, vertical: 10),
                                    ),
                                    child: const Text(
                                      'View Certificate\nप्रमाणपत्र पहा',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
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
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
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
//   // final String bankName;

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
//     // required this.bankName,
//   });

//   @override
//   State<DivyangDetailesScreen> createState() => _DivyangDetailesScreenState();
// }

// class _DivyangDetailesScreenState extends State<DivyangDetailesScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _aadharController = TextEditingController();
//   final TextEditingController _addressController = TextEditingController();
//   bool _isLoading = false;
//   String? _selectedGender;
//   String? _storedAadhar;
//   String? _storedAddress;
//   String? _storedGender;
//   bool _dataLoaded = false;

//   @override
//   void initState() {
//     super.initState();
//     _selectedGender = 'Male';
//     _aadharController.text = widget.aadharNumber;
//     // _fetchPensionerDetails();
//   }

//   @override
//   void dispose() {
//     _aadharController.dispose();
//     _addressController.dispose();
//     super.dispose();
//   }

//   Future<void> _validateAndProceed() async {
//     // Validate form fields
//     bool isValid = true;
//     String? errorMessage;

//     if (_aadharController.text.isEmpty) {
//       errorMessage = 'Please enter Aadhaar number';
//       isValid = false;
//     } else if (_aadharController.text.length != 12) {
//       errorMessage = 'Aadhaar must be exactly 12 digits';
//       isValid = false;
//     } else if (_addressController.text.isEmpty) {
//       errorMessage = 'Please enter your address';
//       isValid = false;
//     } else if (_selectedGender == null || _selectedGender!.isEmpty) {
//       errorMessage = 'Please select your gender';
//       isValid = false;
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
//         // "PPONumber": widget.aadharNumber,
//         "AadhaarNumber": _aadharController.text,
//         "Address": _addressController.text,
//         "Gender": _selectedGender,
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
//         // msg: 'Error: ${e.toString()}',
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
//     return SafeArea(
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text(
//             'Divyang Details [Step-2]',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           backgroundColor: const Color(0xFFF76048),
//         ),
//         body: Stack(
//           children: [
//             SingleChildScrollView(
//               padding: const EdgeInsets.all(16.0),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   children: [
//                     Container(
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(
//                             color: const Color(0xFFF76048), width: 2),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.all(16.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 // _buildInfoCard(
//                                 //     'Aadhar Number', widget.aadharNumber),
//                                 // const SizedBox(height: 15),
//                                 _buildInfoCard('Full Name', widget.fullName),
//                                 const SizedBox(height: 15),
//                                 _buildInfoCard(
//                                     'Mobile Number', widget.mobileNumber),
//                                 const SizedBox(height: 15),
//                                 // _buildInfoCard(' BankName', widget.bankName),

//                                 // Show additional fields if status is Verification In Progress or Approved
//                                 if ((widget.verificationStatus ==
//                                             'Verification In Progress' ||
//                                         widget.verificationStatus ==
//                                             'Application Approved') &&
//                                     _dataLoaded) ...[
//                                   const SizedBox(height: 15),
//                                   _buildInfoCard(
//                                       'AadhaarNumber', widget.aadhaarNumber),
//                                   const SizedBox(height: 15),
//                                   _buildInfoCard('Addresss', widget.addresss),
//                                   const SizedBox(height: 15),
//                                   _buildInfoCard('Gender', widget.gender),
//                                 ],
//                               ],
//                             ),

//                             const SizedBox(height: 20),

//                             // Only show these fields if verification is NOT in progress and NOT approved
//                             if (widget.verificationStatus !=
//                                     'Verification In Progress' &&
//                                 widget.verificationStatus !=
//                                     'Application Approved') ...[
//                               Text(
//                                 'Enter Your Aadhar Number(आधार क्रमांक टाका):',
//                                 style: TextStyle(
//                                   color: Colors.black54,
//                                   fontSize: 15,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               const SizedBox(height: 10),
//                               // TextFormField(
//                               //   controller: _aadharController,
//                               //   keyboardType: TextInputType.number,
//                               //   maxLength: 12,
//                               //   decoration: InputDecoration(
//                               //     hintText: 'Enter 12-digit Aadhar number',
//                               //     filled: true,
//                               //     fillColor: Colors.white,
//                               //     border: OutlineInputBorder(
//                               //       borderRadius: BorderRadius.circular(10),
//                               //       borderSide: const BorderSide(
//                               //           color: Color(0xFFF76048), width: 2),
//                               //     ),
//                               //     focusedBorder: OutlineInputBorder(
//                               //       borderRadius: BorderRadius.circular(10),
//                               //       borderSide: const BorderSide(
//                               //           color: Color(0xFFF76048), width: 2),
//                               //     ),
//                               //     errorText: _aadharController
//                               //                 .text.isNotEmpty &&
//                               //             _aadharController.text.length != 12
//                               //         ? 'Aadhar must be exactly 12 digits'
//                               //         : null,
//                               //   ),
//                               //   onChanged: (value) {
//                               //     setState(() {});
//                               //   },
//                               // ),
//                               TextFormField(
//                                 controller:
//                                     _aadharController, // Pre-fill with existing Aadhar
//                                 keyboardType: TextInputType.number,
//                                 maxLength: 12,
//                                 decoration: InputDecoration(
//                                   hintText:
//                                       'Current Aadhar: ${widget.aadharNumber}', // Show current Aadhar as hint
//                                   filled: true,
//                                   fillColor: Colors.white,
//                                   border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(10),
//                                     borderSide: const BorderSide(
//                                         color: Color(0xFFF76048), width: 2),
//                                   ),
//                                   focusedBorder: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(10),
//                                     borderSide: const BorderSide(
//                                         color: Color(0xFFF76048), width: 2),
//                                   ),
//                                   errorText: _aadharController
//                                               .text.isNotEmpty &&
//                                           _aadharController.text.length != 12
//                                       ? 'Aadhar must be exactly 12 digits'
//                                       : null,
//                                 ),
//                                 onChanged: (value) {
//                                   setState(() {});
//                                 },
//                               ),
//                               const SizedBox(height: 20),
//                               Text(
//                                 'Enter Your Address( पत्ता टाका):',
//                                 style: TextStyle(
//                                   color: Colors.black54,
//                                   fontSize: 15,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               TextFormField(
//                                 controller: _addressController,
//                                 maxLines: 3,
//                                 decoration: InputDecoration(
//                                   filled: true,
//                                   fillColor: Colors.white,
//                                   border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(10),
//                                     borderSide: const BorderSide(
//                                         color: Color(0xFFF76048), width: 2),
//                                   ),
//                                   focusedBorder: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(10),
//                                     borderSide: const BorderSide(
//                                         color: Color(0xFFF76048), width: 2),
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(height: 20),
//                               Text(
//                                 'Enter Your Gender( लिंग टाका):',
//                                 style: TextStyle(
//                                   color: Colors.black54,
//                                   fontSize: 15,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               const SizedBox(height: 10),
//                               DropdownButtonFormField<String>(
//                                 value: _selectedGender,
//                                 decoration: InputDecoration(
//                                   filled: true,
//                                   fillColor: Colors.white,
//                                   border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(10),
//                                     borderSide: const BorderSide(
//                                         color: Color(0xFFF76048), width: 2),
//                                   ),
//                                   focusedBorder: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(10),
//                                     borderSide: const BorderSide(
//                                         color: Color(0xFFF76048), width: 2),
//                                   ),
//                                 ),
//                                 items: [
//                                   DropdownMenuItem<String>(
//                                     value: 'Male',
//                                     child: Text('Male'),
//                                   ),
//                                   DropdownMenuItem<String>(
//                                     value: 'Female',
//                                     child: Text('Female'),
//                                   ),
//                                 ].toList(),
//                                 onChanged: (newValue) {
//                                   setState(() {
//                                     _selectedGender = newValue;
//                                   });
//                                 },
//                                 hint: const Text('Select Gender'),
//                               ),
//                             ],
//                           ],
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 25),
//                     Container(
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(20),
//                         border: Border.all(
//                             color: const Color(0xFFF76048), width: 2),
//                       ),
//                       padding: const EdgeInsets.all(16),
//                       child: Column(
//                         children: [
//                           _buildInfoCard(
//                               'Verification Status', widget.verificationStatus),
//                           const SizedBox(height: 30),
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
//                                         borderRadius: BorderRadius.circular(30),
//                                       ),
//                                       padding: const EdgeInsets.symmetric(
//                                           horizontal: 40, vertical: 10),
//                                     ),
//                                     child: const Text(
//                                       'Complete Your KYC\nतुमची केवायसी पूर्ण करा',
//                                       style: TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.bold,
//                                       ),
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
//                                         borderRadius: BorderRadius.circular(30),
//                                       ),
//                                       padding: const EdgeInsets.symmetric(
//                                           horizontal: 40, vertical: 10),
//                                     ),
//                                     child: const Text(
//                                       'Re-Complete Your KYC\nतुमची केवायसी पूर्ण करा',
//                                       style: TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   );
//                                 } else if (widget.verificationStatus ==
//                                     'Verification In Progress') {
//                                   return ElevatedButton(
//                                     onPressed: () {}, // Disabled button
//                                     style: ElevatedButton.styleFrom(
//                                       backgroundColor: Colors.blue,
//                                       foregroundColor: Colors.blue,
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(30),
//                                       ),
//                                       padding: const EdgeInsets.symmetric(
//                                           horizontal: 40, vertical: 10),
//                                     ),
//                                     child: const Text(
//                                       'Verification in Process\nपडताळणी प्रक्रियेत आहे',
//                                       style: TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 16,
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
//                                         borderRadius: BorderRadius.circular(30),
//                                       ),
//                                       padding: const EdgeInsets.symmetric(
//                                           horizontal: 40, vertical: 10),
//                                     ),
//                                     child: const Text(
//                                       'View Certificate\nप्रमाणपत्र पहा',
//                                       style: TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 16,
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
//               const Center(
//                 child: CircularProgressIndicator(),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoCard(String title, String value) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(15),
//       decoration: BoxDecoration(
//         color: Colors.grey[200],
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: const TextStyle(
//               fontSize: 14,
//               color: Colors.grey,
//             ),
//           ),
//           const SizedBox(height: 5),
//           Text(
//             value,
//             style: const TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

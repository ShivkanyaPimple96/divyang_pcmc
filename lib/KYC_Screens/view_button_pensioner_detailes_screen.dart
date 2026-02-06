import 'package:divyang_pimpri_chinchwad_municipal_corporation/KYC_Screens/aadhar_verification_screen.dart';
import 'package:divyang_pimpri_chinchwad_municipal_corporation/KYC_Screens/view_certificate_screen.dart';
import 'package:flutter/material.dart';

class ViewButtonPensionerDetailesScreen extends StatefulWidget {
  final String ppoNumber;
  final String mobileNumber;
  final String fullName;
  final String verificationStatus;
  final String url;
  final String aadhaarNumber;
  final String addresss;
  final String gender;
  final String uniqueKey;
  final String disabilityType;
  final String disabilityPercentage;

  final String avakNumber;
  final String udidNumber;

  final String bankName;

  const ViewButtonPensionerDetailesScreen({
    super.key,
    required this.ppoNumber,
    required this.mobileNumber,
    required this.fullName,
    required this.verificationStatus,
    required this.url,
    required this.aadhaarNumber,
    required this.addresss,
    required this.gender,
    required this.bankName,
    required this.uniqueKey,
    required this.disabilityType,
    required this.disabilityPercentage,
    required this.avakNumber,
    required this.udidNumber,
  });

  @override
  State<ViewButtonPensionerDetailesScreen> createState() =>
      _ViewButtonPensionerDetailesScreenState();
}

class _ViewButtonPensionerDetailesScreenState
    extends State<ViewButtonPensionerDetailesScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _aadharController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();

  @override
  void dispose() {
    _aadharController.dispose();
    _addressController.dispose();
    _genderController.dispose();
    super.dispose();
  }

  void _validateAndProceed() {
    bool isValid = true;
    String? errorMessage;

    // Validate Aadhar
    if (_aadharController.text.isEmpty) {
      errorMessage = 'Please enter Aadhar number';
      isValid = false;
    } else if (_aadharController.text.length != 12) {
      errorMessage = 'Aadhar must be exactly 12 digits';
      isValid = false;
    }
    // Validate Address
    else if (_addressController.text.isEmpty) {
      errorMessage = 'Please enter your address';
      isValid = false;
    }
    // Validate Gender
    else if (_genderController.text.isEmpty) {
      errorMessage = 'Please enter your gender';
      isValid = false;
    }

    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // If all validations pass, proceed
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AadharVerificationKYCScreen(
          ppoNumber: widget.ppoNumber,
          fullName: widget.fullName,
          avakNumber: widget.avakNumber,
          mobileNumber: widget.mobileNumber,
          aadharNumber: _aadharController.text,
          addressEnter: _addressController.text,
          gender: _genderController.text,
          uniqueKey: widget.uniqueKey,
          udidNumber: widget.udidNumber,
          disabilityType: widget.disabilityType,
          disabilityPercentage: widget.disabilityPercentage,
        ),
      ),
    );
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
            ' Divyang Details [Step-2]',
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
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: const Color(0xFFF76048), width: 2),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(width * 0.04),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoCard(
                            'Aadhar Number', widget.ppoNumber, width),
                        SizedBox(height: height * 0.018),
                        _buildInfoCard('Full Name', widget.fullName, width),
                        SizedBox(height: height * 0.018),
                        _buildInfoCard(
                            'Mobile Number', widget.mobileNumber, width),
                        SizedBox(height: height * 0.03),
                        _buildInfoCard('Date of Birth', '01/01/1950', width),
                        SizedBox(height: height * 0.025),
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
                          style: TextStyle(fontSize: width * 0.04),
                          decoration: InputDecoration(
                            hintText: 'Enter 12-digit Aadhar number',
                            hintStyle: TextStyle(fontSize: width * 0.035),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Color(0xFF92B7F7), width: 2),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Color(0xFF92B7F7), width: 2),
                            ),
                            errorText: _aadharController.text.isNotEmpty &&
                                    _aadharController.text.length != 12
                                ? 'Aadhar must be exactly 12 digits'
                                : null,
                            errorStyle: TextStyle(fontSize: width * 0.03),
                          ),
                          onChanged: (value) {
                            setState(() {});
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
                        TextFormField(
                          controller: _addressController,
                          maxLines: 3,
                          style: TextStyle(fontSize: width * 0.04),
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
                        SizedBox(height: height * 0.025),
                        Text(
                          'Enter Your Gender( लिंग टाका):',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: width * 0.038,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        DropdownButtonFormField<String>(
                          value: _genderController.text.isNotEmpty
                              ? _genderController.text
                              : null,
                          style: TextStyle(
                            fontSize: width * 0.04,
                            color: Colors.black,
                          ),
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
                            labelText: ' Select Gender',
                            labelStyle: TextStyle(fontSize: width * 0.038),
                          ),
                          items: ['Male', 'Female'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _genderController.text = newValue ?? '';
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select gender';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: height * 0.03),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: const Color(0xFFF76048), width: 2),
                  ),
                  padding: EdgeInsets.all(width * 0.04),
                  child: Column(
                    children: [
                      _buildInfoCard('Verification Status',
                          widget.verificationStatus, width),
                      SizedBox(height: height * 0.037),
                      Center(
                        child: Builder(
                          builder: (context) {
                            if (widget.verificationStatus.isEmpty) {
                              return ElevatedButton(
                                onPressed: _validateAndProceed,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF76048),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
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
                                onPressed: _validateAndProceed,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF76048),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
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
                                onPressed: null, // Disabled button
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.blue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: width * 0.1,
                                    vertical: height * 0.012,
                                  ),
                                ),
                                child: Text(
                                  'Verification in Process\nसत्यापन प्रक्रियेत आहे',
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
                                    borderRadius: BorderRadius.circular(30),
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
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, double width) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(width * 0.038),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
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

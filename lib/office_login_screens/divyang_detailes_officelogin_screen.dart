import 'package:divyang_pimpri_chinchwad_municipal_corporation/office_login_screens/photo_click_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DivyangDetailesOfficeloginScreen extends StatefulWidget {
  final String userId;
  final String avakNo;
  final String adharNo;
  final String name;
  final String mobileNo;
  final String uniqueKey;
  final String lastSubmit;

  const DivyangDetailesOfficeloginScreen({
    super.key,
    required this.userId,
    required this.avakNo,
    required this.adharNo,
    required this.name,
    required this.mobileNo,
    required this.uniqueKey,
    required this.lastSubmit,
  });

  @override
  State<DivyangDetailesOfficeloginScreen> createState() =>
      _DivyangDetailesOfficeloginScreenState();
}

class _DivyangDetailesOfficeloginScreenState
    extends State<DivyangDetailesOfficeloginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _udidController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool _isLoading = false;
  String? _selectedGender;
  String? _selectedDisabilityType;
  String? _selectedDisabilityPercentage;

  // Validation flags
  bool _showUdidError = false;
  bool _showAddressError = false;
  bool _showGenderError = false;
  bool _showDisabilityTypeError = false;
  bool _showDisabilityPercentageError = false;
  bool _formSubmitted = false;

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
  void dispose() {
    _udidController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _validateAndProceed() async {
    setState(() {
      _formSubmitted = true;
    });

    // Validate form fields
    bool isValid = true;
    String? errorMessage;

    if (_udidController.text.isEmpty) {
      errorMessage = 'Please enter UDID card number';
      isValid = false;
      setState(() {
        _showUdidError = true;
      });
    } else {
      setState(() {
        _showUdidError = false;
      });
    }

    if (_addressController.text.isEmpty) {
      errorMessage ??= 'Please enter your address';
      isValid = false;
      setState(() {
        _showAddressError = true;
      });
    } else {
      setState(() {
        _showAddressError = false;
      });
    }

    if (_selectedGender == null || _selectedGender!.isEmpty) {
      errorMessage ??= 'Please select your gender';
      isValid = false;
      setState(() {
        _showGenderError = true;
      });
    } else {
      setState(() {
        _showGenderError = false;
      });
    }

    if (_selectedDisabilityType == null || _selectedDisabilityType!.isEmpty) {
      errorMessage ??= 'Please select type of disability';
      isValid = false;
      setState(() {
        _showDisabilityTypeError = true;
      });
    } else {
      setState(() {
        _showDisabilityTypeError = false;
      });
    }

    if (_selectedDisabilityPercentage == null ||
        _selectedDisabilityPercentage!.isEmpty) {
      errorMessage ??= 'Please select percentage of disability';
      isValid = false;
      setState(() {
        _showDisabilityPercentageError = true;
      });
    } else {
      setState(() {
        _showDisabilityPercentageError = false;
      });
    }

    if (!isValid) {
      Fluttertoast.showToast(
        msg: errorMessage!,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    // Show success toast
    Fluttertoast.showToast(
      msg: 'Details submitted successfully!',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );

    // Navigate to PhotoClickScreen with all data
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PhotoClickScreen(
            userId: widget.userId,
            avakNo: widget.avakNo,
            adharNo: widget.adharNo,
            name: widget.name,
            mobileNo: widget.mobileNo,
            uniqueKey: widget.uniqueKey,
            lastSubmit: "",
            udidNumber: _udidController.text,
            address: _addressController.text,
            gender: _selectedGender!,
            disabilityType: _selectedDisabilityType!,
            disabilityPercentage: _selectedDisabilityPercentage!,
          ),
        ),
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
            'Divyang Details',
            style: TextStyle(
              color: Colors.black,
              fontSize: width * 0.05,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.yellow,
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.all(width * 0.04),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Main information card
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.yellow, width: 2),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(width * 0.04),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInfoCard('Avak Number', widget.avakNo,
                                    width, height),
                                SizedBox(height: height * 0.018),
                                _buildInfoCard('Aadhar Number', widget.adharNo,
                                    width, height),
                                SizedBox(height: height * 0.018),
                                _buildInfoCard(
                                    'Name', widget.name, width, height),
                                SizedBox(height: height * 0.018),
                                _buildInfoCard('Mobile Number', widget.mobileNo,
                                    width, height),
                                SizedBox(height: height * 0.018),
                                _buildInfoCard('Unique Key', widget.uniqueKey,
                                    width, height),
                              ],
                            ),
                            SizedBox(height: height * 0.025),

                            // UDID Card Number field
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
                              style: TextStyle(fontSize: width * 0.04),
                              decoration: InputDecoration(
                                hintText: 'Enter UDID card number',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      color: (_formSubmitted && _showUdidError)
                                          ? Colors.red
                                          : Colors.yellow,
                                      width: 2),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      color: (_formSubmitted && _showUdidError)
                                          ? Colors.red
                                          : Colors.yellow,
                                      width: 2),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      color: (_formSubmitted && _showUdidError)
                                          ? Colors.red
                                          : Colors.green,
                                      width: 2),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: Colors.red, width: 2),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: width * 0.03,
                                  vertical: height * 0.015,
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

                            // Address field
                            Text(
                              'Enter Your Address (पत्ता टाका):',
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
                              style: TextStyle(fontSize: width * 0.04),
                              decoration: InputDecoration(
                                hintText: 'Enter your address',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      color:
                                          (_formSubmitted && _showAddressError)
                                              ? Colors.red
                                              : Colors.yellow,
                                      width: 2),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      color:
                                          (_formSubmitted && _showAddressError)
                                              ? Colors.red
                                              : Colors.yellow,
                                      width: 2),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      color:
                                          (_formSubmitted && _showAddressError)
                                              ? Colors.red
                                              : Colors.green,
                                      width: 2),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: Colors.red, width: 2),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: width * 0.03,
                                  vertical: height * 0.015,
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

                            // Gender field
                            Text(
                              'Select Your Gender (लिंग टाका):',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: width * 0.038,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: height * 0.012),
                            DropdownButtonFormField<String>(
                              value: _selectedGender,
                              style: TextStyle(
                                fontSize: width * 0.04,
                                color: Colors.black,
                              ),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      color:
                                          (_formSubmitted && _showGenderError)
                                              ? Colors.red
                                              : Colors.yellow,
                                      width: 2),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      color:
                                          (_formSubmitted && _showGenderError)
                                              ? Colors.red
                                              : Colors.yellow,
                                      width: 2),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      color:
                                          (_formSubmitted && _showGenderError)
                                              ? Colors.red
                                              : Colors.green,
                                      width: 2),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: Colors.red, width: 2),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: width * 0.03,
                                  vertical: height * 0.015,
                                ),
                                errorText: (_formSubmitted &&
                                        (_selectedGender == null ||
                                            _selectedGender!.isEmpty))
                                    ? 'Gender is required'
                                    : null,
                              ),
                              items: const [
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
                              hint: Text(
                                'Select Gender',
                                style: TextStyle(fontSize: width * 0.035),
                              ),
                            ),
                            SizedBox(height: height * 0.025),

                            // Type of Disability field
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
                              style: TextStyle(
                                fontSize: width * 0.035,
                                color: Colors.black,
                              ),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      color: (_formSubmitted &&
                                              _showDisabilityTypeError)
                                          ? Colors.red
                                          : Colors.yellow,
                                      width: 2),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      color: (_formSubmitted &&
                                              _showDisabilityTypeError)
                                          ? Colors.red
                                          : Colors.yellow,
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
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: Colors.red, width: 2),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: width * 0.03,
                                  vertical: height * 0.015,
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
                              hint: Text(
                                'Select Type of Disability',
                                style: TextStyle(fontSize: width * 0.035),
                              ),
                            ),
                            SizedBox(height: height * 0.025),

                            // Percentage of Disability field
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
                              style: TextStyle(
                                fontSize: width * 0.04,
                                color: Colors.black,
                              ),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      color: (_formSubmitted &&
                                              _showDisabilityPercentageError)
                                          ? Colors.red
                                          : Colors.yellow,
                                      width: 2),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      color: (_formSubmitted &&
                                              _showDisabilityPercentageError)
                                          ? Colors.red
                                          : Colors.yellow,
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
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: Colors.red, width: 2),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: width * 0.03,
                                  vertical: height * 0.015,
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
                              hint: Text(
                                'Select Percentage',
                                style: TextStyle(fontSize: width * 0.035),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.03),

                    // Submit button section
                    Center(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _validateAndProceed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
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
                          'Complete Your KYC \nतुमची केवायसी पूर्ण करा',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: width * 0.04,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(
                  color: Colors.green,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
      String title, String value, double width, double height) {
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
          SizedBox(height: height * 0.006),
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

// import 'package:divyang_pimpri_chinchwad_municipal_corporation/office_login_screens/photo_click_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';

// class DivyangDetailesOfficeloginScreen extends StatefulWidget {
//   final String userId;
//   final String avakNo;
//   final String adharNo;
//   final String name;
//   final String mobileNo;
//   final String uniqueKey;
//   final String lastSubmit;

//   const DivyangDetailesOfficeloginScreen({
//     super.key,
//     required this.userId,
//     required this.avakNo,
//     required this.adharNo,
//     required this.name,
//     required this.mobileNo,
//     required this.uniqueKey,
//     required this.lastSubmit,
//   });

//   @override
//   State<DivyangDetailesOfficeloginScreen> createState() =>
//       _DivyangDetailesOfficeloginScreenState();
// }

// class _DivyangDetailesOfficeloginScreenState
//     extends State<DivyangDetailesOfficeloginScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _addressController = TextEditingController();
//   bool _isLoading = false;
//   String? _selectedGender;
//   String? _selectedDisabilityType;
//   String? _selectedDisabilityPercentage;

//   // Validation flags
//   bool _showAddressError = false;
//   bool _showGenderError = false;
//   bool _showDisabilityTypeError = false;
//   bool _showDisabilityPercentageError = false;
//   bool _formSubmitted = false;

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
//   void dispose() {
//     _addressController.dispose();
//     super.dispose();
//   }

//   Future<void> _validateAndProceed() async {
//     setState(() {
//       _formSubmitted = true;
//     });

//     // Validate form fields
//     bool isValid = true;
//     String? errorMessage;

//     if (_addressController.text.isEmpty) {
//       errorMessage = 'Please enter your address';
//       isValid = false;
//       setState(() {
//         _showAddressError = true;
//       });
//     } else {
//       setState(() {
//         _showAddressError = false;
//       });
//     }

//     if (_selectedGender == null || _selectedGender!.isEmpty) {
//       errorMessage ??= 'Please select your gender';
//       isValid = false;
//       setState(() {
//         _showGenderError = true;
//       });
//     } else {
//       setState(() {
//         _showGenderError = false;
//       });
//     }

//     if (_selectedDisabilityType == null || _selectedDisabilityType!.isEmpty) {
//       errorMessage ??= 'Please select type of disability';
//       isValid = false;
//       setState(() {
//         _showDisabilityTypeError = true;
//       });
//     } else {
//       setState(() {
//         _showDisabilityTypeError = false;
//       });
//     }

//     if (_selectedDisabilityPercentage == null ||
//         _selectedDisabilityPercentage!.isEmpty) {
//       errorMessage ??= 'Please select percentage of disability';
//       isValid = false;
//       setState(() {
//         _showDisabilityPercentageError = true;
//       });
//     } else {
//       setState(() {
//         _showDisabilityPercentageError = false;
//       });
//     }

//     if (!isValid) {
//       Fluttertoast.showToast(
//         msg: errorMessage!,
//         toastLength: Toast.LENGTH_LONG,
//         gravity: ToastGravity.BOTTOM,
//         backgroundColor: Colors.red,
//         textColor: Colors.white,
//       );
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     // Simulate API call
//     await Future.delayed(const Duration(seconds: 2));

//     setState(() {
//       _isLoading = false;
//     });

//     // Show success toast
//     Fluttertoast.showToast(
//       msg: 'Details submitted successfully!',
//       toastLength: Toast.LENGTH_SHORT,
//       gravity: ToastGravity.BOTTOM,
//       backgroundColor: Colors.green,
//       textColor: Colors.white,
//     );

//     // Navigate to PhotoClickScreen with all data
//     if (mounted) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => PhotoClickScreen(
//             userId: widget.userId,
//             avakNo: widget.avakNo,
//             adharNo: widget.adharNo,
//             name: widget.name,
//             mobileNo: widget.mobileNo,
//             uniqueKey: widget.uniqueKey,
//             lastSubmit: widget.lastSubmit,
//             address: _addressController.text,
//             gender: _selectedGender!,
//             disabilityType: _selectedDisabilityType!,
//             disabilityPercentage: _selectedDisabilityPercentage!,
//           ),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final width = size.width;
//     final height = size.height;

//     return SafeArea(
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text(
//             'Divyang Details',
//             style: TextStyle(
//               color: Colors.black,
//               fontSize: width * 0.05,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           backgroundColor: Colors.yellow,
//         ),
//         body: Stack(
//           children: [
//             SingleChildScrollView(
//               padding: EdgeInsets.all(width * 0.04),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   children: [
//                     // Main information card
//                     Container(
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(color: Colors.yellow, width: 2),
//                       ),
//                       child: Padding(
//                         padding: EdgeInsets.all(width * 0.04),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 // _buildInfoCard(
//                                 //     'User ID', widget.userId, width, height),
//                                 // SizedBox(height: height * 0.018),
//                                 _buildInfoCard('Avak Number', widget.avakNo,
//                                     width, height),
//                                 SizedBox(height: height * 0.018),
//                                 _buildInfoCard('Aadhar Number', widget.adharNo,
//                                     width, height),
//                                 SizedBox(height: height * 0.018),
//                                 _buildInfoCard(
//                                     'Name', widget.name, width, height),
//                                 SizedBox(height: height * 0.018),
//                                 _buildInfoCard('Mobile Number', widget.mobileNo,
//                                     width, height),
//                                 SizedBox(height: height * 0.018),
//                                 _buildInfoCard('Unique Key', widget.uniqueKey,
//                                     width, height),
//                               ],
//                             ),
//                             SizedBox(height: height * 0.025),

//                             // Address field
//                             Text(
//                               'Enter Your Address (पत्ता टाका):',
//                               style: TextStyle(
//                                 color: Colors.black54,
//                                 fontSize: width * 0.038,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             SizedBox(height: height * 0.012),
//                             TextFormField(
//                               controller: _addressController,
//                               maxLines: 3,
//                               style: TextStyle(fontSize: width * 0.04),
//                               decoration: InputDecoration(
//                                 hintText: 'Enter your address',
//                                 filled: true,
//                                 fillColor: Colors.white,
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                   borderSide: BorderSide(
//                                       color:
//                                           (_formSubmitted && _showAddressError)
//                                               ? Colors.red
//                                               : Colors.yellow,
//                                       width: 2),
//                                 ),
//                                 enabledBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                   borderSide: BorderSide(
//                                       color:
//                                           (_formSubmitted && _showAddressError)
//                                               ? Colors.red
//                                               : Colors.yellow,
//                                       width: 2),
//                                 ),
//                                 focusedBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                   borderSide: BorderSide(
//                                       color:
//                                           (_formSubmitted && _showAddressError)
//                                               ? Colors.red
//                                               : Colors.green,
//                                       width: 2),
//                                 ),
//                                 errorBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                   borderSide: const BorderSide(
//                                       color: Colors.red, width: 2),
//                                 ),
//                                 contentPadding: EdgeInsets.symmetric(
//                                   horizontal: width * 0.03,
//                                   vertical: height * 0.015,
//                                 ),
//                                 errorText: (_formSubmitted &&
//                                         _addressController.text.isEmpty)
//                                     ? 'Address is required'
//                                     : null,
//                               ),
//                               onChanged: (value) {
//                                 if (_formSubmitted) {
//                                   setState(() {
//                                     _showAddressError = value.isEmpty;
//                                   });
//                                 }
//                               },
//                             ),
//                             SizedBox(height: height * 0.025),

//                             // Gender field
//                             Text(
//                               'Select Your Gender (लिंग टाका):',
//                               style: TextStyle(
//                                 color: Colors.black54,
//                                 fontSize: width * 0.038,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             SizedBox(height: height * 0.012),
//                             DropdownButtonFormField<String>(
//                               value: _selectedGender,
//                               style: TextStyle(
//                                 fontSize: width * 0.04,
//                                 color: Colors.black,
//                               ),
//                               decoration: InputDecoration(
//                                 filled: true,
//                                 fillColor: Colors.white,
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                   borderSide: BorderSide(
//                                       color:
//                                           (_formSubmitted && _showGenderError)
//                                               ? Colors.red
//                                               : Colors.yellow,
//                                       width: 2),
//                                 ),
//                                 enabledBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                   borderSide: BorderSide(
//                                       color:
//                                           (_formSubmitted && _showGenderError)
//                                               ? Colors.red
//                                               : Colors.yellow,
//                                       width: 2),
//                                 ),
//                                 focusedBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                   borderSide: BorderSide(
//                                       color:
//                                           (_formSubmitted && _showGenderError)
//                                               ? Colors.red
//                                               : Colors.green,
//                                       width: 2),
//                                 ),
//                                 errorBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                   borderSide: const BorderSide(
//                                       color: Colors.red, width: 2),
//                                 ),
//                                 contentPadding: EdgeInsets.symmetric(
//                                   horizontal: width * 0.03,
//                                   vertical: height * 0.015,
//                                 ),
//                                 errorText: (_formSubmitted &&
//                                         (_selectedGender == null ||
//                                             _selectedGender!.isEmpty))
//                                     ? 'Gender is required'
//                                     : null,
//                               ),
//                               items: const [
//                                 DropdownMenuItem<String>(
//                                   value: 'Male',
//                                   child: Text('Male'),
//                                 ),
//                                 DropdownMenuItem<String>(
//                                   value: 'Female',
//                                   child: Text('Female'),
//                                 ),
//                                 DropdownMenuItem<String>(
//                                   value: 'Transgender',
//                                   child: Text('Transgender'),
//                                 ),
//                               ],
//                               onChanged: (newValue) {
//                                 setState(() {
//                                   _selectedGender = newValue;
//                                   if (_formSubmitted) {
//                                     _showGenderError =
//                                         newValue == null || newValue.isEmpty;
//                                   }
//                                 });
//                               },
//                               hint: Text(
//                                 'Select Gender',
//                                 style: TextStyle(fontSize: width * 0.035),
//                               ),
//                             ),
//                             SizedBox(height: height * 0.025),

//                             // Type of Disability field
//                             Text(
//                               'Type of Disability (अपंगत्वाचा प्रकार):',
//                               style: TextStyle(
//                                 color: Colors.black54,
//                                 fontSize: width * 0.038,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             SizedBox(height: height * 0.012),
//                             DropdownButtonFormField<String>(
//                               value: _selectedDisabilityType,
//                               isExpanded: true,
//                               style: TextStyle(
//                                 fontSize: width * 0.035,
//                                 color: Colors.black,
//                               ),
//                               decoration: InputDecoration(
//                                 filled: true,
//                                 fillColor: Colors.white,
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                   borderSide: BorderSide(
//                                       color: (_formSubmitted &&
//                                               _showDisabilityTypeError)
//                                           ? Colors.red
//                                           : Colors.yellow,
//                                       width: 2),
//                                 ),
//                                 enabledBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                   borderSide: BorderSide(
//                                       color: (_formSubmitted &&
//                                               _showDisabilityTypeError)
//                                           ? Colors.red
//                                           : Colors.yellow,
//                                       width: 2),
//                                 ),
//                                 focusedBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                   borderSide: BorderSide(
//                                       color: (_formSubmitted &&
//                                               _showDisabilityTypeError)
//                                           ? Colors.red
//                                           : Colors.green,
//                                       width: 2),
//                                 ),
//                                 errorBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                   borderSide: const BorderSide(
//                                       color: Colors.red, width: 2),
//                                 ),
//                                 contentPadding: EdgeInsets.symmetric(
//                                   horizontal: width * 0.03,
//                                   vertical: height * 0.015,
//                                 ),
//                                 errorText: (_formSubmitted &&
//                                         (_selectedDisabilityType == null ||
//                                             _selectedDisabilityType!.isEmpty))
//                                     ? 'Type of disability is required'
//                                     : null,
//                               ),
//                               items: _disabilityTypes.map((disability) {
//                                 return DropdownMenuItem<String>(
//                                   value: disability['value'],
//                                   child: Text(
//                                     disability['label']!,
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 );
//                               }).toList(),
//                               onChanged: (newValue) {
//                                 setState(() {
//                                   _selectedDisabilityType = newValue;
//                                   if (_formSubmitted) {
//                                     _showDisabilityTypeError =
//                                         newValue == null || newValue.isEmpty;
//                                   }
//                                 });
//                               },
//                               hint: Text(
//                                 'Select Type of Disability',
//                                 style: TextStyle(fontSize: width * 0.035),
//                               ),
//                             ),
//                             SizedBox(height: height * 0.025),

//                             // Percentage of Disability field
//                             Text(
//                               'Percentage of Disability (अपंगत्वाची टक्केवारी):',
//                               style: TextStyle(
//                                 color: Colors.black54,
//                                 fontSize: width * 0.038,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             SizedBox(height: height * 0.012),
//                             DropdownButtonFormField<String>(
//                               value: _selectedDisabilityPercentage,
//                               style: TextStyle(
//                                 fontSize: width * 0.04,
//                                 color: Colors.black,
//                               ),
//                               decoration: InputDecoration(
//                                 filled: true,
//                                 fillColor: Colors.white,
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                   borderSide: BorderSide(
//                                       color: (_formSubmitted &&
//                                               _showDisabilityPercentageError)
//                                           ? Colors.red
//                                           : Colors.yellow,
//                                       width: 2),
//                                 ),
//                                 enabledBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                   borderSide: BorderSide(
//                                       color: (_formSubmitted &&
//                                               _showDisabilityPercentageError)
//                                           ? Colors.red
//                                           : Colors.yellow,
//                                       width: 2),
//                                 ),
//                                 focusedBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                   borderSide: BorderSide(
//                                       color: (_formSubmitted &&
//                                               _showDisabilityPercentageError)
//                                           ? Colors.red
//                                           : Colors.green,
//                                       width: 2),
//                                 ),
//                                 errorBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                   borderSide: const BorderSide(
//                                       color: Colors.red, width: 2),
//                                 ),
//                                 contentPadding: EdgeInsets.symmetric(
//                                   horizontal: width * 0.03,
//                                   vertical: height * 0.015,
//                                 ),
//                                 errorText: (_formSubmitted &&
//                                         (_selectedDisabilityPercentage ==
//                                                 null ||
//                                             _selectedDisabilityPercentage!
//                                                 .isEmpty))
//                                     ? 'Percentage of disability is required'
//                                     : null,
//                               ),
//                               items: _disabilityPercentages.map((percentage) {
//                                 return DropdownMenuItem<String>(
//                                   value: percentage,
//                                   child: Text(percentage),
//                                 );
//                               }).toList(),
//                               onChanged: (newValue) {
//                                 setState(() {
//                                   _selectedDisabilityPercentage = newValue;
//                                   if (_formSubmitted) {
//                                     _showDisabilityPercentageError =
//                                         newValue == null || newValue.isEmpty;
//                                   }
//                                 });
//                               },
//                               hint: Text(
//                                 'Select Percentage',
//                                 style: TextStyle(fontSize: width * 0.035),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: height * 0.03),

//                     // Submit button section
//                     Center(
//                       child: ElevatedButton(
//                         onPressed: _isLoading ? null : _validateAndProceed,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.green,
//                           foregroundColor: Colors.white,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(30),
//                           ),
//                           padding: EdgeInsets.symmetric(
//                             horizontal: width * 0.1,
//                             vertical: height * 0.012,
//                           ),
//                         ),
//                         child: Text(
//                           'Complete Your KYC \nतुमची केवायसी पूर्ण करा',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: width * 0.04,
//                             fontWeight: FontWeight.bold,
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             if (_isLoading)
//               const Center(
//                 child: CircularProgressIndicator(
//                   color: Colors.green,
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoCard(
//       String title, String value, double width, double height) {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.all(width * 0.038),
//       decoration: BoxDecoration(
//         color: Colors.grey[200],
//         borderRadius: BorderRadius.circular(10),
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
//           SizedBox(height: height * 0.006),
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

// PhotoClickScreen class definition
// class PhotoClickScreen extends StatelessWidget {
//   final String userId;
//   final String avakNo;
//   final String adharNo;
//   final String name;
//   final String mobileNo;
//   final String uniqueKey;
//   final String lastSubmit;
//   final String address;
//   final String gender;
//   final String disabilityType;
//   final String disabilityPercentage;

//   const PhotoClickScreen({
//     super.key,
//     required this.userId,
//     required this.avakNo,
//     required this.adharNo,
//     required this.name,
//     required this.mobileNo,
//     required this.uniqueKey,
//     required this.lastSubmit,
//     required this.address,
//     required this.gender,
//     required this.disabilityType,
//     required this.disabilityPercentage,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Photo Click Screen'),
//         backgroundColor: Colors.green,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'Received Data:',
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 20),
//               _buildDataRow('User ID:', userId),
//               _buildDataRow('Avak No:', avakNo),
//               _buildDataRow('Aadhar No:', adharNo),
//               _buildDataRow('Name:', name),
//               _buildDataRow('Mobile No:', mobileNo),
//               _buildDataRow('Unique Key:', uniqueKey),
//               _buildDataRow('Last Submit:', lastSubmit),
//               _buildDataRow('Address:', address),
//               _buildDataRow('Gender:', gender),
//               _buildDataRow('Disability Type:', disabilityType),
//               _buildDataRow('Disability Percentage:', disabilityPercentage),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildDataRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             label,
//             style: const TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 16,
//             ),
//           ),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(fontSize: 16),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';

// class DivyangDetailesOfficeloginScreen extends StatefulWidget {
//   final String userId;
//   final String avakNo;
//   final String adharNo;
//   final String name;
//   final String mobileNo;
//   final String uniqueKey;
//   final String lastSubmit;

//   const DivyangDetailesOfficeloginScreen({
//     super.key,
//     required this.userId,
//     required this.avakNo,
//     required this.adharNo,
//     required this.name,
//     required this.mobileNo,
//     required this.uniqueKey,
//     required this.lastSubmit,
//   });

//   @override
//   State<DivyangDetailesOfficeloginScreen> createState() =>
//       _DivyangDetailesOfficeloginScreenState();
// }

// class _DivyangDetailesOfficeloginScreenState
//     extends State<DivyangDetailesOfficeloginScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _addressController = TextEditingController();
//   bool _isLoading = false;
//   String? _selectedGender;
//   String? _selectedDisabilityType;
//   String? _selectedDisabilityPercentage;

//   // Validation flags
//   bool _showAddressError = false;
//   bool _showGenderError = false;
//   bool _showDisabilityTypeError = false;
//   bool _showDisabilityPercentageError = false;
//   bool _formSubmitted = false;

//   // Disability types list
//   final List<Map<String, String>> _disabilityTypes = [
//     {'value': '1', 'label': '१) पूर्णतः अंध (Blindness)'},
//     {'value': '2', 'label': '२) अंशतः अंध (Low Vision)'},
//     {'value': '3', 'label': '३) कर्णबधीर (Hearing Impairment)'},
//     {'value': '4', 'label': '४) वाचा दोष (Speech and Language Disability)'},
//     {'value': '5', 'label': '५) अस्थिव्यंग (Locomotor Disability)'},
//     {'value': '6', 'label': '६) मानसिक आजार (Mental Illness)'},
//     {'value': '7', 'label': '७) अध्ययन अक्षम (Learning Disability)'},
//     {'value': '8', 'label': '८) मेंदूचा पक्षाघात (Cerebral Palsy)'},
//     {'value': '9', 'label': '९) स्वमग्न (Autism)'},
//     {'value': '10', 'label': '१०) बहुविकलांग (Multiple Disability)'},
//     {'value': '11', 'label': '११) कुष्ठरोग (Leprosy Cured Persons)'},
//     {'value': '12', 'label': '१२) बुटकेपणा (Dwarfism)'},
//     {'value': '13', 'label': '१३) बौद्धिक अक्षमता (Intellectual Disability)'},
//     {'value': '14', 'label': '१४) माशपेशीय क्षरण (Muscular Disability)'},
//     {
//       'value': '15',
//       'label': '१५) मज्जासंस्थेचे तीव्र आजार (Chronic Neurological Conditions)'
//     },
//     {'value': '16', 'label': '१६) मल्टिपल स्क्लेरोसिस (Multiple Sclerosis)'},
//     {'value': '17', 'label': '१७) थॅलेसिमिया (Thalassemia)'},
//     {'value': '18', 'label': '१८) अधिक रक्तस्त्राव (Hemophilia)'},
//     {'value': '19', 'label': '१९) सिकल सेल (Sickle Cell Disease)'},
//     {'value': '20', 'label': '२०) अॅसिड अटॅक (Acid Attack Victim)'},
//     {'value': '21', 'label': '२१) कंपवात रोग (Parkinson\'s Disease)'},
//   ];

//   // Generate percentage list from 40% to 100%
//   List<String> get _disabilityPercentages {
//     return List.generate(61, (index) => '${40 + index}%');
//   }

//   @override
//   void dispose() {
//     _addressController.dispose();
//     super.dispose();
//   }

//   Future<void> _validateAndProceed() async {
//     setState(() {
//       _formSubmitted = true;
//     });

//     // Validate form fields
//     bool isValid = true;
//     String? errorMessage;

//     if (_addressController.text.isEmpty) {
//       errorMessage = 'Please enter your address';
//       isValid = false;
//       setState(() {
//         _showAddressError = true;
//       });
//     } else {
//       setState(() {
//         _showAddressError = false;
//       });
//     }

//     if (_selectedGender == null || _selectedGender!.isEmpty) {
//       if (errorMessage == null) {
//         errorMessage = 'Please select your gender';
//       }
//       isValid = false;
//       setState(() {
//         _showGenderError = true;
//       });
//     } else {
//       setState(() {
//         _showGenderError = false;
//       });
//     }

//     if (_selectedDisabilityType == null || _selectedDisabilityType!.isEmpty) {
//       if (errorMessage == null) {
//         errorMessage = 'Please select type of disability';
//       }
//       isValid = false;
//       setState(() {
//         _showDisabilityTypeError = true;
//       });
//     } else {
//       setState(() {
//         _showDisabilityTypeError = false;
//       });
//     }

//     if (_selectedDisabilityPercentage == null ||
//         _selectedDisabilityPercentage!.isEmpty) {
//       if (errorMessage == null) {
//         errorMessage = 'Please select percentage of disability';
//       }
//       isValid = false;
//       setState(() {
//         _showDisabilityPercentageError = true;
//       });
//     } else {
//       setState(() {
//         _showDisabilityPercentageError = false;
//       });
//     }

//     if (!isValid) {
//       Fluttertoast.showToast(
//         msg: errorMessage!,
//         toastLength: Toast.LENGTH_LONG,
//         gravity: ToastGravity.BOTTOM,
//         backgroundColor: Colors.red,
//         textColor: Colors.white,
//       );
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     // Simulate API call
//     await Future.delayed(const Duration(seconds: 2));

//     setState(() {
//       _isLoading = false;
//     });

//     // Handle submit logic here
//     print('Submitting details:');
//     print('User ID: ${widget.userId}');
//     print('Avak No: ${widget.avakNo}');
//     print('Aadhar No: ${widget.adharNo}');
//     print('Name: ${widget.name}');
//     print('Mobile No: ${widget.mobileNo}');
//     print('Unique Key: ${widget.uniqueKey}');
//     print('Address: ${_addressController.text}');
//     print('Gender: $_selectedGender');
//     print('Disability Type: $_selectedDisabilityType');
//     print('Disability Percentage: $_selectedDisabilityPercentage');

//     Fluttertoast.showToast(
//       msg: 'Details submitted successfully!',
//       toastLength: Toast.LENGTH_LONG,
//       gravity: ToastGravity.BOTTOM,
//       backgroundColor: Colors.green,
//       textColor: Colors.white,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final width = size.width;
//     final height = size.height;

//     return SafeArea(
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text(
//             'Divyang Details',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: width * 0.05,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           backgroundColor: Colors.green,
//         ),
//         body: Stack(
//           children: [
//             SingleChildScrollView(
//               padding: EdgeInsets.all(width * 0.04),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   children: [
//                     // Main information card
//                     Container(
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(color: Colors.yellow, width: 2),
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
//                                     'User ID', widget.userId, width, height),
//                                 SizedBox(height: height * 0.018),
//                                 _buildInfoCard('Avak Number', widget.avakNo,
//                                     width, height),
//                                 SizedBox(height: height * 0.018),
//                                 _buildInfoCard('Aadhar Number', widget.adharNo,
//                                     width, height),
//                                 SizedBox(height: height * 0.018),
//                                 _buildInfoCard(
//                                     'Name', widget.name, width, height),
//                                 SizedBox(height: height * 0.018),
//                                 _buildInfoCard('Mobile Number', widget.mobileNo,
//                                     width, height),
//                                 SizedBox(height: height * 0.018),
//                                 _buildInfoCard('Unique Key', widget.uniqueKey,
//                                     width, height),
//                               ],
//                             ),
//                             SizedBox(height: height * 0.025),

//                             // Address field
//                             Text(
//                               'Enter Your Address (पत्ता टाका):',
//                               style: TextStyle(
//                                 color: Colors.black54,
//                                 fontSize: width * 0.038,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             SizedBox(height: height * 0.012),
//                             TextFormField(
//                               controller: _addressController,
//                               maxLines: 3,
//                               style: TextStyle(fontSize: width * 0.04),
//                               decoration: InputDecoration(
//                                 hintText: 'Enter your address',
//                                 filled: true,
//                                 fillColor: Colors.white,
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                   borderSide: BorderSide(
//                                       color:
//                                           (_formSubmitted && _showAddressError)
//                                               ? Colors.red
//                                               : Colors.yellow,
//                                       width: 2),
//                                 ),
//                                 enabledBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                   borderSide: BorderSide(
//                                       color:
//                                           (_formSubmitted && _showAddressError)
//                                               ? Colors.red
//                                               : Colors.yellow,
//                                       width: 2),
//                                 ),
//                                 focusedBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                   borderSide: BorderSide(
//                                       color:
//                                           (_formSubmitted && _showAddressError)
//                                               ? Colors.red
//                                               : Colors.green,
//                                       width: 2),
//                                 ),
//                                 errorBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                   borderSide: const BorderSide(
//                                       color: Colors.red, width: 2),
//                                 ),
//                                 contentPadding: EdgeInsets.symmetric(
//                                   horizontal: width * 0.03,
//                                   vertical: height * 0.015,
//                                 ),
//                                 errorText: (_formSubmitted &&
//                                         _addressController.text.isEmpty)
//                                     ? 'Address is required'
//                                     : null,
//                               ),
//                               onChanged: (value) {
//                                 if (_formSubmitted) {
//                                   setState(() {
//                                     _showAddressError = value.isEmpty;
//                                   });
//                                 }
//                               },
//                             ),
//                             SizedBox(height: height * 0.025),

//                             // Gender field
//                             Text(
//                               'Select Your Gender (लिंग टाका):',
//                               style: TextStyle(
//                                 color: Colors.black54,
//                                 fontSize: width * 0.038,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             SizedBox(height: height * 0.012),
//                             DropdownButtonFormField<String>(
//                               value: _selectedGender,
//                               style: TextStyle(
//                                 fontSize: width * 0.04,
//                                 color: Colors.black,
//                               ),
//                               decoration: InputDecoration(
//                                 filled: true,
//                                 fillColor: Colors.white,
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                   borderSide: BorderSide(
//                                       color:
//                                           (_formSubmitted && _showGenderError)
//                                               ? Colors.red
//                                               : Colors.yellow,
//                                       width: 2),
//                                 ),
//                                 enabledBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                   borderSide: BorderSide(
//                                       color:
//                                           (_formSubmitted && _showGenderError)
//                                               ? Colors.red
//                                               : Colors.yellow,
//                                       width: 2),
//                                 ),
//                                 focusedBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                   borderSide: BorderSide(
//                                       color:
//                                           (_formSubmitted && _showGenderError)
//                                               ? Colors.red
//                                               : Colors.green,
//                                       width: 2),
//                                 ),
//                                 errorBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                   borderSide: const BorderSide(
//                                       color: Colors.red, width: 2),
//                                 ),
//                                 contentPadding: EdgeInsets.symmetric(
//                                   horizontal: width * 0.03,
//                                   vertical: height * 0.015,
//                                 ),
//                                 errorText: (_formSubmitted &&
//                                         (_selectedGender == null ||
//                                             _selectedGender!.isEmpty))
//                                     ? 'Gender is required'
//                                     : null,
//                               ),
//                               items: const [
//                                 DropdownMenuItem<String>(
//                                   value: 'Male',
//                                   child: Text('Male'),
//                                 ),
//                                 DropdownMenuItem<String>(
//                                   value: 'Female',
//                                   child: Text('Female'),
//                                 ),
//                                 DropdownMenuItem<String>(
//                                   value: 'Transgender',
//                                   child: Text('Transgender'),
//                                 ),
//                               ],
//                               onChanged: (newValue) {
//                                 setState(() {
//                                   _selectedGender = newValue;
//                                   if (_formSubmitted) {
//                                     _showGenderError =
//                                         newValue == null || newValue.isEmpty;
//                                   }
//                                 });
//                               },
//                               hint: Text(
//                                 'Select Gender',
//                                 style: TextStyle(fontSize: width * 0.035),
//                               ),
//                             ),
//                             SizedBox(height: height * 0.025),

//                             // Type of Disability field
//                             Text(
//                               'Type of Disability (अपंगत्वाचा प्रकार):',
//                               style: TextStyle(
//                                 color: Colors.black54,
//                                 fontSize: width * 0.038,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             SizedBox(height: height * 0.012),
//                             DropdownButtonFormField<String>(
//                               value: _selectedDisabilityType,
//                               isExpanded: true,
//                               style: TextStyle(
//                                 fontSize: width * 0.035,
//                                 color: Colors.black,
//                               ),
//                               decoration: InputDecoration(
//                                 filled: true,
//                                 fillColor: Colors.white,
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                   borderSide: BorderSide(
//                                       color: (_formSubmitted &&
//                                               _showDisabilityTypeError)
//                                           ? Colors.red
//                                           : Colors.yellow,
//                                       width: 2),
//                                 ),
//                                 enabledBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                   borderSide: BorderSide(
//                                       color: (_formSubmitted &&
//                                               _showDisabilityTypeError)
//                                           ? Colors.red
//                                           : Colors.yellow,
//                                       width: 2),
//                                 ),
//                                 focusedBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                   borderSide: BorderSide(
//                                       color: (_formSubmitted &&
//                                               _showDisabilityTypeError)
//                                           ? Colors.red
//                                           : Colors.green,
//                                       width: 2),
//                                 ),
//                                 errorBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                   borderSide: const BorderSide(
//                                       color: Colors.red, width: 2),
//                                 ),
//                                 contentPadding: EdgeInsets.symmetric(
//                                   horizontal: width * 0.03,
//                                   vertical: height * 0.015,
//                                 ),
//                                 errorText: (_formSubmitted &&
//                                         (_selectedDisabilityType == null ||
//                                             _selectedDisabilityType!.isEmpty))
//                                     ? 'Type of disability is required'
//                                     : null,
//                               ),
//                               items: _disabilityTypes.map((disability) {
//                                 return DropdownMenuItem<String>(
//                                   value: disability['value'],
//                                   child: Text(
//                                     disability['label']!,
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 );
//                               }).toList(),
//                               onChanged: (newValue) {
//                                 setState(() {
//                                   _selectedDisabilityType = newValue;
//                                   if (_formSubmitted) {
//                                     _showDisabilityTypeError =
//                                         newValue == null || newValue.isEmpty;
//                                   }
//                                 });
//                               },
//                               hint: Text(
//                                 'Select Type of Disability',
//                                 style: TextStyle(fontSize: width * 0.035),
//                               ),
//                             ),
//                             SizedBox(height: height * 0.025),

//                             // Percentage of Disability field
//                             Text(
//                               'Percentage of Disability (अपंगत्वाची टक्केवारी):',
//                               style: TextStyle(
//                                 color: Colors.black54,
//                                 fontSize: width * 0.038,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             SizedBox(height: height * 0.012),
//                             DropdownButtonFormField<String>(
//                               value: _selectedDisabilityPercentage,
//                               style: TextStyle(
//                                 fontSize: width * 0.04,
//                                 color: Colors.black,
//                               ),
//                               decoration: InputDecoration(
//                                 filled: true,
//                                 fillColor: Colors.white,
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                   borderSide: BorderSide(
//                                       color: (_formSubmitted &&
//                                               _showDisabilityPercentageError)
//                                           ? Colors.red
//                                           : Colors.yellow,
//                                       width: 2),
//                                 ),
//                                 enabledBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                   borderSide: BorderSide(
//                                       color: (_formSubmitted &&
//                                               _showDisabilityPercentageError)
//                                           ? Colors.red
//                                           : Colors.yellow,
//                                       width: 2),
//                                 ),
//                                 focusedBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                   borderSide: BorderSide(
//                                       color: (_formSubmitted &&
//                                               _showDisabilityPercentageError)
//                                           ? Colors.red
//                                           : Colors.green,
//                                       width: 2),
//                                 ),
//                                 errorBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                   borderSide: const BorderSide(
//                                       color: Colors.red, width: 2),
//                                 ),
//                                 contentPadding: EdgeInsets.symmetric(
//                                   horizontal: width * 0.03,
//                                   vertical: height * 0.015,
//                                 ),
//                                 errorText: (_formSubmitted &&
//                                         (_selectedDisabilityPercentage ==
//                                                 null ||
//                                             _selectedDisabilityPercentage!
//                                                 .isEmpty))
//                                     ? 'Percentage of disability is required'
//                                     : null,
//                               ),
//                               items: _disabilityPercentages.map((percentage) {
//                                 return DropdownMenuItem<String>(
//                                   value: percentage,
//                                   child: Text(percentage),
//                                 );
//                               }).toList(),
//                               onChanged: (newValue) {
//                                 setState(() {
//                                   _selectedDisabilityPercentage = newValue;
//                                   if (_formSubmitted) {
//                                     _showDisabilityPercentageError =
//                                         newValue == null || newValue.isEmpty;
//                                   }
//                                 });
//                               },
//                               hint: Text(
//                                 'Select Percentage',
//                                 style: TextStyle(fontSize: width * 0.035),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: height * 0.03),

//                     // Submit button section

//                     Center(
//                       child: ElevatedButton(
//                         onPressed: _isLoading ? null : _validateAndProceed,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.green,
//                           foregroundColor: Colors.white,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(30),
//                           ),
//                           padding: EdgeInsets.symmetric(
//                             horizontal: width * 0.1,
//                             vertical: height * 0.012,
//                           ),
//                         ),
//                         child: Text(
//                           'SUBMIT DETAILS\nतपशील सबमिट करा',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: width * 0.04,
//                             fontWeight: FontWeight.bold,
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             if (_isLoading)
//               const Center(
//                 child: CircularProgressIndicator(
//                   color: Colors.green,
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoCard(
//       String title, String value, double width, double height) {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.all(width * 0.038),
//       decoration: BoxDecoration(
//         color: Colors.grey[200],
//         borderRadius: BorderRadius.circular(10),
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
//           SizedBox(height: height * 0.006),
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

// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';

// class DivyangDetailesOfficeloginScreen extends StatefulWidget {
//   final String userId;
//   final String avakNo;
//   final String adharNo;
//   final String name;
//   final String mobileNo;
//   final String uniqueKey;
//   final String lastSubmit;

//   const DivyangDetailesOfficeloginScreen({
//     super.key,
//     required this.userId,
//     required this.avakNo,
//     required this.adharNo,
//     required this.name,
//     required this.mobileNo,
//     required this.uniqueKey,
//     required this.lastSubmit,
//   });

//   @override
//   State<DivyangDetailesOfficeloginScreen> createState() =>
//       _DivyangDetailesOfficeloginScreenState();
// }

// class _DivyangDetailesOfficeloginScreenState
//     extends State<DivyangDetailesOfficeloginScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _addressController = TextEditingController();
//   bool _isLoading = false;
//   String? _selectedGender;

//   // Validation flags
//   bool _showAddressError = false;
//   bool _showGenderError = false;
//   bool _formSubmitted = false;

//   @override
//   void dispose() {
//     _addressController.dispose();
//     super.dispose();
//   }

//   Future<void> _validateAndProceed() async {
//     setState(() {
//       _formSubmitted = true;
//     });

//     // Validate form fields
//     bool isValid = true;
//     String? errorMessage;

//     if (_addressController.text.isEmpty) {
//       errorMessage = 'Please enter your address';
//       isValid = false;
//       setState(() {
//         _showAddressError = true;
//       });
//     } else {
//       setState(() {
//         _showAddressError = false;
//       });
//     }

//     if (_selectedGender == null || _selectedGender!.isEmpty) {
//       if (errorMessage == null) {
//         errorMessage = 'Please select your gender';
//       }
//       isValid = false;
//       setState(() {
//         _showGenderError = true;
//       });
//     } else {
//       setState(() {
//         _showGenderError = false;
//       });
//     }

//     if (!isValid) {
//       Fluttertoast.showToast(
//         msg: errorMessage!,
//         toastLength: Toast.LENGTH_LONG,
//         gravity: ToastGravity.BOTTOM,
//         backgroundColor: Colors.red,
//         textColor: Colors.white,
//       );
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     // Simulate API call
//     await Future.delayed(const Duration(seconds: 2));

//     setState(() {
//       _isLoading = false;
//     });

//     // Handle submit logic here
//     print('Submitting details:');
//     print('User ID: ${widget.userId}');
//     print('Avak No: ${widget.avakNo}');
//     print('Aadhar No: ${widget.adharNo}');
//     print('Name: ${widget.name}');
//     print('Mobile No: ${widget.mobileNo}');
//     print('Unique Key: ${widget.uniqueKey}');
//     print('Address: ${_addressController.text}');
//     print('Gender: $_selectedGender');

//     Fluttertoast.showToast(
//       msg: 'Details submitted successfully!',
//       toastLength: Toast.LENGTH_LONG,
//       gravity: ToastGravity.BOTTOM,
//       backgroundColor: Colors.green,
//       textColor: Colors.white,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final width = size.width;
//     final height = size.height;

//     return SafeArea(
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text(
//             'Divyang Details',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: width * 0.05,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           backgroundColor: Colors.green,
//         ),
//         body: Stack(
//           children: [
//             SingleChildScrollView(
//               padding: EdgeInsets.all(width * 0.04),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   children: [
//                     // Main information card
//                     Container(
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(color: Colors.yellow, width: 2),
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
//                                     'User ID', widget.userId, width, height),
//                                 SizedBox(height: height * 0.018),
//                                 _buildInfoCard('Avak Number', widget.avakNo,
//                                     width, height),
//                                 SizedBox(height: height * 0.018),
//                                 _buildInfoCard('Aadhar Number', widget.adharNo,
//                                     width, height),
//                                 SizedBox(height: height * 0.018),
//                                 _buildInfoCard(
//                                     'Name', widget.name, width, height),
//                                 SizedBox(height: height * 0.018),
//                                 _buildInfoCard('Mobile Number', widget.mobileNo,
//                                     width, height),
//                                 SizedBox(height: height * 0.018),
//                                 _buildInfoCard('Unique Key', widget.uniqueKey,
//                                     width, height),
//                               ],
//                             ),
//                             SizedBox(height: height * 0.025),

//                             // Address field
//                             Text(
//                               'Enter Your Address (पत्ता टाका):',
//                               style: TextStyle(
//                                 color: Colors.black54,
//                                 fontSize: width * 0.038,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             SizedBox(height: height * 0.012),
//                             TextFormField(
//                               controller: _addressController,
//                               maxLines: 3,
//                               style: TextStyle(fontSize: width * 0.04),
//                               decoration: InputDecoration(
//                                 hintText: 'Enter your address',
//                                 filled: true,
//                                 fillColor: Colors.white,
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                   borderSide: BorderSide(
//                                       color:
//                                           (_formSubmitted && _showAddressError)
//                                               ? Colors.red
//                                               : Colors.yellow,
//                                       width: 2),
//                                 ),
//                                 enabledBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                   borderSide: BorderSide(
//                                       color:
//                                           (_formSubmitted && _showAddressError)
//                                               ? Colors.red
//                                               : Colors.yellow,
//                                       width: 2),
//                                 ),
//                                 focusedBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                   borderSide: BorderSide(
//                                       color:
//                                           (_formSubmitted && _showAddressError)
//                                               ? Colors.red
//                                               : Colors.green,
//                                       width: 2),
//                                 ),
//                                 errorBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                   borderSide: const BorderSide(
//                                       color: Colors.red, width: 2),
//                                 ),
//                                 contentPadding: EdgeInsets.symmetric(
//                                   horizontal: width * 0.03,
//                                   vertical: height * 0.015,
//                                 ),
//                                 errorText: (_formSubmitted &&
//                                         _addressController.text.isEmpty)
//                                     ? 'Address is required'
//                                     : null,
//                               ),
//                               onChanged: (value) {
//                                 if (_formSubmitted) {
//                                   setState(() {
//                                     _showAddressError = value.isEmpty;
//                                   });
//                                 }
//                               },
//                             ),
//                             SizedBox(height: height * 0.025),

//                             // Gender field
//                             Text(
//                               'Select Your Gender (लिंग टाका):',
//                               style: TextStyle(
//                                 color: Colors.black54,
//                                 fontSize: width * 0.038,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             SizedBox(height: height * 0.012),
//                             DropdownButtonFormField<String>(
//                               value: _selectedGender,
//                               style: TextStyle(
//                                 fontSize: width * 0.04,
//                                 color: Colors.black,
//                               ),
//                               decoration: InputDecoration(
//                                 filled: true,
//                                 fillColor: Colors.white,
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                   borderSide: BorderSide(
//                                       color:
//                                           (_formSubmitted && _showGenderError)
//                                               ? Colors.red
//                                               : Colors.yellow,
//                                       width: 2),
//                                 ),
//                                 enabledBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                   borderSide: BorderSide(
//                                       color:
//                                           (_formSubmitted && _showGenderError)
//                                               ? Colors.red
//                                               : Colors.yellow,
//                                       width: 2),
//                                 ),
//                                 focusedBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                   borderSide: BorderSide(
//                                       color:
//                                           (_formSubmitted && _showGenderError)
//                                               ? Colors.red
//                                               : Colors.green,
//                                       width: 2),
//                                 ),
//                                 errorBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                   borderSide: const BorderSide(
//                                       color: Colors.red, width: 2),
//                                 ),
//                                 contentPadding: EdgeInsets.symmetric(
//                                   horizontal: width * 0.03,
//                                   vertical: height * 0.015,
//                                 ),
//                                 errorText: (_formSubmitted &&
//                                         (_selectedGender == null ||
//                                             _selectedGender!.isEmpty))
//                                     ? 'Gender is required'
//                                     : null,
//                               ),
//                               items: const [
//                                 DropdownMenuItem<String>(
//                                   value: 'Male',
//                                   child: Text('Male'),
//                                 ),
//                                 DropdownMenuItem<String>(
//                                   value: 'Female',
//                                   child: Text('Female'),
//                                 ),
//                                 DropdownMenuItem<String>(
//                                   value: 'Transgender',
//                                   child: Text('Transgender'),
//                                 ),
//                               ],
//                               onChanged: (newValue) {
//                                 setState(() {
//                                   _selectedGender = newValue;
//                                   if (_formSubmitted) {
//                                     _showGenderError =
//                                         newValue == null || newValue.isEmpty;
//                                   }
//                                 });
//                               },
//                               hint: Text(
//                                 'Select Gender',
//                                 style: TextStyle(fontSize: width * 0.035),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: height * 0.03),

//                     // Submit button section

//                     // _buildInfoCard(
//                     //     'Last Submit', widget.lastSubmit, width, height),
//                     // SizedBox(height: height * 0.037),
//                     Center(
//                       child: ElevatedButton(
//                         onPressed: _isLoading ? null : _validateAndProceed,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.green,
//                           foregroundColor: Colors.white,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(30),
//                           ),
//                           padding: EdgeInsets.symmetric(
//                             horizontal: width * 0.1,
//                             vertical: height * 0.012,
//                           ),
//                         ),
//                         child: Text(
//                           'SUBMIT DETAILS\nतपशील सबमिट करा',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: width * 0.04,
//                             fontWeight: FontWeight.bold,
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             if (_isLoading)
//               const Center(
//                 child: CircularProgressIndicator(
//                   color: Colors.green,
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoCard(
//       String title, String value, double width, double height) {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.all(width * 0.038),
//       decoration: BoxDecoration(
//         color: Colors.grey[200],
//         borderRadius: BorderRadius.circular(10),
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
//           SizedBox(height: height * 0.006),
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

// import 'package:flutter/material.dart';

// class DivyangDetailesOfficeloginScreen extends StatefulWidget {
//   final String userId;
//   final String avakNo;
//   final String adharNo;
//   final String name;
//   final String mobileNo;
//   final String uniqueKey;
//   final String lastSubmit;

//   const DivyangDetailesOfficeloginScreen({
//     super.key,
//     required this.userId,
//     required this.avakNo,
//     required this.adharNo,
//     required this.name,
//     required this.mobileNo,
//     required this.uniqueKey,
//     required this.lastSubmit,
//   });

//   @override
//   State<DivyangDetailesOfficeloginScreen> createState() =>
//       _DivyangDetailesOfficeloginScreenState();
// }

// class _DivyangDetailesOfficeloginScreenState
//     extends State<DivyangDetailesOfficeloginScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text(
//             'Divyang Details',
//             style: TextStyle(color: Colors.black),
//           ),
//           backgroundColor: Colors.yellow,
//         ),
//         body: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(20.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const SizedBox(height: 20),
//                 const Text(
//                   'Office Login - Divyang Details',
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.green,
//                   ),
//                 ),
//                 const SizedBox(height: 30),

//                 // Display all the received data
//                 _buildInfoCard(),

//                 const SizedBox(height: 30),

//                 // Add your additional form fields or content here
//                 const Text(
//                   'Additional Details:',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 20),

//                 // Add more form fields as needed
//                 // Example: TextFormField, DropdownButton, etc.

//                 const SizedBox(height: 30),

//                 // Submit button
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       // Handle submit action
//                       _handleSubmit();
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.green,
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                     child: const Text(
//                       'SUBMIT DETAILS',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoCard() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16.0),
//       decoration: BoxDecoration(
//         color: Colors.grey[100],
//         borderRadius: BorderRadius.circular(8.0),
//         border: Border.all(color: Colors.yellow, width: 2),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Retrieved Information:',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.green,
//             ),
//           ),
//           const SizedBox(height: 16),
//           _buildDetailRow('User ID', widget.userId),
//           const Divider(),
//           _buildDetailRow('Avak Number', widget.avakNo),
//           const Divider(),
//           _buildDetailRow('Aadhar Number', widget.adharNo),
//           const Divider(),
//           _buildDetailRow('Name', widget.name),
//           const Divider(),
//           _buildDetailRow('Mobile Number', widget.mobileNo),
//           const Divider(),
//           _buildDetailRow('Unique Key', widget.uniqueKey),
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
//             width: 130,
//             child: Text(
//               '$label:',
//               style: const TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 15,
//               ),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(
//                 fontSize: 15,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _handleSubmit() {
//     // Implement your submit logic here
//     // You have access to all fields via widget.userId, widget.avakNo, etc.

//     print('Submitting details:');
//     print('User ID: ${widget.userId}');
//     print('Avak No: ${widget.avakNo}');
//     print('Aadhar No: ${widget.adharNo}');
//     print('Name: ${widget.name}');
//     print('Mobile No: ${widget.mobileNo}');
//     print('Unique Key: ${widget.uniqueKey}');

//     // Show success message
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Details submitted successfully!'),
//         backgroundColor: Colors.green,
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'dart:io';

import 'package:divyang_pimpri_chinchwad_municipal_corporation/KYC_Screens/response_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class UploadDivyangCertificateScreen extends StatefulWidget {
  // final String videoPath;
  // final String recordedDate;
  // final String recordedTime;
  // final String imagePath;
  final String aadhaarNumber;
  final String lastSubmit;
  // final String latitude;
  // final String longitude;
  // final String address;
  final String ppoNumber;
  final String mobileNumber;
  final String addressEnter;
  final String gender;
  final String fullName;

  const UploadDivyangCertificateScreen({
    super.key,
    // required this.videoPath,
    // required this.recordedDate,
    // required this.recordedTime,
    // required this.imagePath,
    required this.aadhaarNumber,
    required this.lastSubmit,
    required this.ppoNumber,
    required this.mobileNumber,
    required this.addressEnter,
    required this.gender,
    required this.fullName,
    // required this.latitude,
    // required this.longitude,
    // required this.address,
  });

  @override
  _UploadDivyangCertificateScreenState createState() =>
      _UploadDivyangCertificateScreenState();
}

class _UploadDivyangCertificateScreenState
    extends State<UploadDivyangCertificateScreen> {
  File? _image;
  bool _isLoading = false;

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedImage != null) {
        _image = File(pickedImage.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<File> compressImage(String imagePath) async {
    final File imageFile = File(imagePath);
    final Directory tempDir = await getTemporaryDirectory();
    final String targetPath =
        '${tempDir.path}/${basename(imagePath)}_compressed.jpg';

    final XFile? compressedImage =
        await FlutterImageCompress.compressAndGetFile(
      imageFile.absolute.path,
      targetPath,
      quality: 30, // Adjust quality as needed (0 - 100)
    );

    return compressedImage != null ? File(compressedImage.path) : imageFile;
  }

  Future<void> submitAllData(BuildContext context) async {
    bool? confirmSubmission = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.green, size: 28),
              SizedBox(width: 10),
              Text(
                'Confirm Submission',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Divider(thickness: 2.5),
              Text(
                'Are you sure you want to submit Divyang Certificate?\nतुम्हाला खात्री आहे की तुम्ही हा दिव्यांगचा दाखला सबमिट करू इच्छिता?',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              Divider(thickness: 2.5),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('Submit'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmSubmission != true) {
      return;
    }

    if (_image == null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Note'),
            content: Text(
                'Please click diyang certificate photo.\nकृपया दिव्यांग प्रमाणपत्राचा फोटो काढा'),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      File? compressedIncomeCertificateFile;
      if (_image != null) {
        compressedIncomeCertificateFile = await compressImage(_image!.path);
        final fileSize = await compressedIncomeCertificateFile.length();
        if (fileSize > 500 * 1024) {
          // If still larger than 500KB
          // Compress again with even lower quality
          compressedIncomeCertificateFile =
              await compressImage(compressedIncomeCertificateFile.path);
        }
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://divyangpcmc.altwise.in/api/aadhar/SubmitAadharData'),
      );

      // Adding fields to the request
      request.fields['AadhaarNumber'] = widget.aadhaarNumber;
      // request.fields['Latitude'] = widget.latitude;
      // request.fields['Longitude'] = widget.longitude;
      // request.fields['LiveAddress'] = widget.address;
      request.fields['LastSubmit'] = "Submitted";

      // Add compressed Income Certificate if available
      if (compressedIncomeCertificateFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'DivyangCertificate',
          compressedIncomeCertificateFile.path,
          filename: basename(compressedIncomeCertificateFile.path),
          contentType: MediaType('image', 'jpeg'),
        ));
      }

      var response = await request.send().timeout(Duration(seconds: 240));

      print('Response status: ${response.statusCode}');
      final responseString = await response.stream.bytesToString();
      print('Response body: $responseString');

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        final responseJson = json.decode(responseString);
        final verificationStatus =
            responseJson['VerificationStatus'] ?? 'Unknown Status';
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResponseScreen(
              ppoNumber: widget.ppoNumber,
              mobileNumber: widget.mobileNumber,
              addressEnter: widget.addressEnter,
              gender: widget.gender,
              fullName: widget.fullName,
              message:
                  '''You have successfully completed the process for your life certificate.
Your life certificate is currently under verification. You will receive your certificate soon. Thank you for your patience

तुम्ही तुमच्या जीवन प्रमाणपत्राची प्रक्रिया यशस्वीपणे पूर्ण केली आहे.
तुमचे जीवन प्रमाणपत्र सध्या पडताळणीखाली आहे. तुम्हाला तुमचे प्रमाणपत्र लवकरच मिळेल.
तुमच्या संयमाबद्दल धन्यवाद.''',
              success: true,
              verificationStatus: verificationStatus,
            ),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResponseScreen(
              ppoNumber: widget.ppoNumber,
              mobileNumber: widget.mobileNumber,
              addressEnter: widget.addressEnter,
              gender: widget.gender,
              fullName: widget.fullName,
              message:
                  'Failed to submit data. Please try again.\nडेटा सबमिट करण्यात अयशस्वी. कृपया पुन्हा प्रयत्न करा',
              success: false,
              verificationStatus: 'Failed',
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResponseScreen(
            ppoNumber: widget.ppoNumber,
            mobileNumber: widget.mobileNumber,
            addressEnter: widget.addressEnter,
            gender: widget.gender,
            fullName: widget.fullName,
            message:
                'Failed to submit data. Please try again.\nडेटा सबमिट करण्यात अयशस्वी. कृपया पुन्हा प्रयत्न करा',
            success: false,
            verificationStatus: 'Error',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Upload Divyang Certificate ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Color(0xFFF76048),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 30, left: 20, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text("Aadhar Number: ${widget.aadhaarNumber}"),
                  // Text("Input Field One Value: ${widget.inputFieldOneValue}"),
                  // Text(
                  //     "Selected Dropdown Value: ${widget.selectedDropdownValue ?? 'None'}"),
                  SizedBox(height: 25),
                  Center(
                    child: Text(
                      'Click Divyang Certificate Photo',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        letterSpacing: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Center(
                    child: Text(
                      'दिव्यांग दाखल्याचा फोटो काढा',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 25),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Container(
                      height: 400,
                      width: 350,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Color(0xFFF76048),
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: Center(
                              child: _image == null
                                  ? Container(
                                      width: 250,
                                      height: 250,
                                      color: Colors.blueGrey,
                                      child: Center(
                                        child: Image.asset(
                                          'assets/images/document_image.png', // Replace with your actual image path
                                          fit: BoxFit
                                              .cover, // Adjust this based on your requirement
                                        ),
                                      ),
                                    )
                                  : Image.file(
                                      _image!,
                                      height: 250,
                                      width: 250,
                                    ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              onPressed: _getImage,
                              child: const Text(
                                "Click Divyang Certificate Image\nदिव्यांग दाखल्याचा फोटो काढा",
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  _isLoading
                      ? const CircularProgressIndicator() // Show loader while uploading
                      : Padding(
                          padding: const EdgeInsets.only(
                            left: 12.0,
                            right: 12.0,
                          ),
                          child: ElevatedButton(
                            onPressed: () => submitAllData(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFF76048),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 10),
                            ),
                            child: const Text(
                              'Submit Divyang Certificate\nदिव्यांग सर्टिफिकेट सबमिट करा',
                              style: TextStyle(
                                fontSize: 18, // Adjust font size
                                fontWeight: FontWeight.bold,
                                color: Colors.white, // Text color
                              ),
                              textAlign:
                                  TextAlign.center, // Center align the text
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'dart:io';

// import 'package:divyang_pimpri_chinchwad_municipal_corporation/KYC_Screens/response_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_image_compress/flutter_image_compress.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';

// import 'package:path/path.dart';
// import 'package:path_provider/path_provider.dart';

// class DeclarationPageScreen extends StatefulWidget {
//   final String ppoNumber;
//   final String videoPath;
//   // final String recordedDate;
//   // final String recordedTime;
//   // final String imagePath;
//   final String aadhaarNumber;
//   final String lastSubmit;
//   // final String latitude;
//   // final String longitude;
//   // final String address;
//   //    final String frontImagePath;
//   // final String backImagePath;

//   final String? hasJob;

//   const DeclarationPageScreen({
//     super.key,
//     required this.videoPath,
//     // required this.recordedDate,
//     // required this.recordedTime,
//     // required this.imagePath,
//     required this.aadhaarNumber,
//     // required this.latitude,
//     // required this.longitude,
//     // required this.address,
//     // required this.inputFieldOneValue,
//     // this.selectedDropdownValue,
//     required this.ppoNumber,
//     this.hasJob,
//     required this.lastSubmit,
//   });

//   @override
//   _DeclarationPageScreenState createState() => _DeclarationPageScreenState();
// }

// class _DeclarationPageScreenState extends State<DeclarationPageScreen> {
//   File? _image;
//   bool isLoading = false;
//   String? hasJob; // Changed to String
//   String? hasSpouse;
//   String? joberrorMessage;
//   String? spouseerrorMessage;
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   final TextEditingController jobTitleController = TextEditingController();

//   final TextEditingController salaryDetailsTitleController =
//       TextEditingController();
//   final TextEditingController jobJoiningDateController =
//       TextEditingController();
//   final TextEditingController marriageLocationController =
//       TextEditingController();
//   final TextEditingController marriageDateController = TextEditingController();

//   Future<File> compressImage(String imagePath) async {
//     final File imageFile = File(imagePath);
//     final Directory tempDir = await getTemporaryDirectory();
//     final String targetPath =
//         '${tempDir.path}/${basename(imagePath)}_compressed.jpg';

//     final XFile? compressedImage =
//         await FlutterImageCompress.compressAndGetFile(
//       imageFile.absolute.path,
//       targetPath,
//       quality: 30, // Adjust quality as needed (0 - 100)
//     );

//     return compressedImage != null ? File(compressedImage.path) : imageFile;
//   }

//   void _validateAndSubmit(BuildContext context) {
//     if (_formKey.currentState!.validate()) {
//       // Proceed with submission
//       submitVideo(context);
//     }
//   }

// // Manage loading state

//   Future<void> submitVideo(BuildContext context) async {
//     bool? confirmSubmission = await showDialog<bool>(
//       context: context,
//       builder: (BuildContext dialogContext) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20.0),
//           ),
//           title: Row(
//             children: [
//               Icon(Icons.check_circle_outline, color: Colors.green, size: 28),
//               SizedBox(width: 10),
//               Text('Confirm Submission',
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//             ],
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Divider(thickness: 2.5),
//               Text(
//                 'Are you sure you want to submit this certificate?\nतुम्हाला खात्री आहे की तुम्ही सर्टिफिकेट सबमिट करू इच्छिता?',
//                 style: TextStyle(fontSize: 16),
//                 textAlign: TextAlign.center,
//               ),
//               Divider(thickness: 2.5),
//             ],
//           ),
//           actions: [
//             TextButton(
//               child: Text('Cancel', style: TextStyle(color: Colors.red)),
//               onPressed: () {
//                 Navigator.of(dialogContext).pop(false);
//               },
//             ),
//             TextButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.green,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12.0),
//                 ),
//               ),
//               onPressed: () {
//                 Navigator.of(dialogContext).pop(true);
//               },
//               child: Text('Submit'),
//             ),
//           ],
//         );
//       },
//     );

//     if (confirmSubmission != true) return;

//     setState(() {
//       isLoading = true; // Show loader on button
//     });

//     try {
//       var request = http.MultipartRequest(
//         'POST',
//         Uri.parse('https://nagpurpensioner.altwise.in/api/aadhar/submit'),
//       );

//       request.fields['isHavingJob'] = hasJob ?? "";
//       request.fields['isMarried'] = hasSpouse ?? "";
//       // request.fields['isHavingJob'] = (hasJob == 'yes') ? 'yes' : 'no';
//       // request.fields['isMarried'] = (hasSpouse == 'yes') ? 'yes' : 'no';

//       request.fields['jobTitleAddress'] = jobTitleController.text;
//       request.fields['salaryDetails'] = salaryDetailsTitleController.text;
//       request.fields['marriageLocation'] = marriageLocationController.text;
//       request.fields['jobJoiningDate'] = jobJoiningDateController.text;
//       request.fields['marriageDate'] = marriageDateController.text;
//       request.fields['PPONumber'] = widget.ppoNumber;
//       request.fields['AadhaarNumber'] = widget.aadhaarNumber;
//       request.fields['LastSubmit '] = "Submitted";
//       // request.fields['Latitude'] = widget.latitude;
//       // request.fields['Longitude'] = widget.longitude;
//       // request.fields['Address'] = widget.address;
//       // request.fields['Note1'] = widget.inputFieldOneValue;
//       // request.fields['Note2'] = widget.selectedDropdownValue ?? "";

//       // request.files.add(await http.MultipartFile.fromPath(
//       //   'KycVideo',
//       //   videoFile.path,
//       //   filename: basename(videoFile.path),
//       //   contentType: MediaType('video', 'mp4'),
//       // ));

//       // request.files.add(await http.MultipartFile.fromPath(
//       //   'Selfie',
//       //   compressedFile.path,
//       //   filename: basename(compressedFile.path),
//       //   contentType: MediaType('image', 'jpeg'),
//       // ));

//       print('Request URL: ${request.url}');
//       print('Request Headers: ${request.headers}');
//       print('Request Fields: ${request.fields}');
//       print('Request Files:');
//       request.files.forEach((file) {
//         print(
//             '  Field: ${file.field}, File: ${file.filename}, Length: ${file.length}');
//       });

//       var response = await request.send();
//       setState(() {
//         isLoading = false; // Hide loader after response
//       });

//       final responseBody = await response.stream.bytesToString();
//       print('Response Status: ${response.statusCode}');
//       print('Response Body: $responseBody');

//       if (response.statusCode == 200) {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => ResponseScreen(
//               message:
//                   '''You have successfully completed the process for your life certificate.
// Your life certificate is currently under verification. You will receive your certificate soon. Thank you for your patience

// तुम्ही तुमच्या जीवन प्रमाणपत्राची प्रक्रिया यशस्वीपणे पूर्ण केली आहे.
// तुमचे जीवन प्रमाणपत्र सध्या पडताळणीखाली आहे. तुम्हाला तुमचे प्रमाणपत्र लवकरच मिळेल.
// तुमच्या संयमाबद्दल धन्यवाद.''',
//               success: true,
//             ),
//           ),
//         );

//         // Navigator.push(
//         //   context,
//         //   MaterialPageRoute(
//         //     builder: (context) => ResponseScreen(
//         //       message:
//         //           'All data submitted successfully! \nसर्व डेटा यशस्वीरित्या सबमिट केला आहे',
//         //       success: true,
//         //     ),
//         //   ),
//         // );
//       } else {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => ResponseScreen(
//               message:
//                   'Failed to submit data. Please try again.\nडेटा सबमिट करण्यात अयशस्वी. कृपया पुन्हा प्रयत्न करा',
//               success: false,
//             ),
//           ),
//         );
//       }
//     } catch (e) {
//       setState(() {
//         isLoading = false; // Hide loader on error
//       });
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => ResponseScreen(
//             message:
//                 'Failed to submit data. Please try again.\nडेटा सबमिट करण्यात अयशस्वी. कृपया पुन्हा प्रयत्न करा',
//             success: false,
//           ),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: const Color(0xFFF76048),
//         title: Text(
//           'Declaration    [Step-5]',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // First Container - Job Status
//                 Container(
//                   padding: EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     border: Border.all(
//                       color: Color(0xFFF76048),
//                       width: 3,
//                     ),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'सेवानिवृत्तीनंतर महाराष्ट्र शासनाचे अधिपत्याखालील तसेच सार्वजनिक उपक्रम किंवा स्थानिक प्राधिकरणातील कोणतीही नोकरी स्विकारलेली आहे का ?',
//                         style: TextStyle(
//                             fontSize: 18, fontWeight: FontWeight.bold),
//                       ),
//                       SizedBox(height: 10),

//                       Row(
//                         children: [
//                           ElevatedButton(
//                             onPressed: () {
//                               setState(() {
//                                 hasJob = 'yes';
//                                 joberrorMessage =
//                                     null; // Clear error message when selected
//                               });
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor:
//                                   hasJob == 'yes' ? Colors.blue : Colors.grey,
//                             ),
//                             child: Text('Yes'),
//                           ),
//                           SizedBox(width: 16),
//                           ElevatedButton(
//                             onPressed: () {
//                               setState(() {
//                                 hasJob = 'no';
//                                 joberrorMessage =
//                                     null; // Clear error message when selected
//                               });
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor:
//                                   hasJob == 'no' ? Colors.blue : Colors.grey,
//                             ),
//                             child: Text('No'),
//                           ),
//                         ],
//                       ),

//                       SizedBox(height: 8),

// // Show error message if hasJob is not selected
//                       if (joberrorMessage != null)
//                         Text(
//                           joberrorMessage!,
//                           style: TextStyle(color: Colors.red),
//                         ),

//                       SizedBox(height: 16),

//                       // Show required fields when "Yes" is selected
//                       if (hasJob == 'yes') ...[
//                         Text(
//                           'कार्यरत असलेली संस्था / कार्यलयाचे नांव व पत्ता',
//                           style: TextStyle(
//                               fontSize: 16, fontWeight: FontWeight.bold),
//                         ),
//                         SizedBox(height: 8),
//                         TextFormField(
//                           controller: jobTitleController,
//                           decoration: InputDecoration(
//                             border: OutlineInputBorder(),
//                             hintText: 'Enter your job title and address',
//                           ),
//                           validator: (value) {
//                             if (hasJob == 'yes' && value!.isEmpty) {
//                               return 'This field is required';
//                             }
//                             return null;
//                           },
//                         ),
//                         SizedBox(height: 16),
//                         Text(
//                           'वेतन व भत्ते / मानधन इ. तपशिल',
//                           style: TextStyle(
//                               fontSize: 16, fontWeight: FontWeight.bold),
//                         ),
//                         SizedBox(height: 8),
//                         TextFormField(
//                           controller: salaryDetailsTitleController,
//                           keyboardType: TextInputType.number,
//                           decoration: InputDecoration(
//                             border: OutlineInputBorder(),
//                             hintText: 'Enter your salary details',
//                           ),
//                           validator: (value) {
//                             if (hasJob == 'yes' && value!.isEmpty) {
//                               return 'This field is required';
//                             }
//                             return null;
//                           },
//                         ),
//                         SizedBox(height: 16),
//                         Text(
//                           'नवीन नियुक्तीचा दिनांक',
//                           style: TextStyle(
//                               fontSize: 16, fontWeight: FontWeight.bold),
//                         ),
//                         SizedBox(height: 8),
//                         GestureDetector(
//                           onTap: () async {
//                             DateTime? pickedDate = await showDatePicker(
//                               context: context,
//                               initialDate: DateTime.now(),
//                               firstDate: DateTime(1900),
//                               lastDate: DateTime.now(),
//                             );
//                             if (pickedDate != null) {
//                               String formattedDate =
//                                   DateFormat('yyyy-MM-dd').format(pickedDate);
//                               setState(() {
//                                 jobJoiningDateController.text = formattedDate;
//                               });
//                             }
//                           },
//                           child: AbsorbPointer(
//                             child: TextFormField(
//                               controller: jobJoiningDateController,
//                               decoration: InputDecoration(
//                                 border: OutlineInputBorder(),
//                                 hintText: 'Select your job joining date',
//                                 suffixIcon: Icon(Icons.calendar_today),
//                               ),
//                               validator: (value) {
//                                 if (hasJob == 'yes' && value!.isEmpty) {
//                                   return 'This field is required';
//                                 }
//                                 return null;
//                               },
//                             ),
//                           ),
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),

//                 SizedBox(height: 20),
//                 Container(
//                   padding: EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     border: Border.all(
//                       color: Color(0xFFF76048),
//                       width: 3,
//                     ),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'पुनर्विवाह केला आहे का?',
//                         style: TextStyle(
//                             fontSize: 18, fontWeight: FontWeight.bold),
//                       ),
//                       SizedBox(height: 10),

//                       Row(
//                         children: [
//                           ElevatedButton(
//                             onPressed: () {
//                               setState(() {
//                                 hasSpouse = 'yes';
//                                 spouseerrorMessage =
//                                     null; // Clear error message when selected
//                               });
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: hasSpouse == 'yes'
//                                   ? Colors.blue
//                                   : Colors.grey,
//                             ),
//                             child: Text('Yes'),
//                           ),
//                           SizedBox(width: 16),
//                           ElevatedButton(
//                             onPressed: () {
//                               setState(() {
//                                 hasSpouse = 'no';
//                                 spouseerrorMessage =
//                                     null; // Clear error message when selected
//                               });
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor:
//                                   hasSpouse == 'no' ? Colors.blue : Colors.grey,
//                             ),
//                             child: Text('No'),
//                           ),
//                         ],
//                       ),

//                       SizedBox(height: 8),

// // Show error message if hasJob is not selected
//                       if (spouseerrorMessage != null)
//                         Text(
//                           spouseerrorMessage!,
//                           style: TextStyle(color: Colors.red),
//                         ),

//                       SizedBox(height: 16),

//                       // Show required fields when "Yes" is selected
//                       if (hasSpouse == 'yes') ...[
//                         Text(
//                           'ठिकाण',
//                           style: TextStyle(
//                               fontSize: 16, fontWeight: FontWeight.bold),
//                         ),
//                         SizedBox(height: 8),
//                         TextFormField(
//                           controller: marriageLocationController,
//                           decoration: InputDecoration(
//                             border: OutlineInputBorder(),
//                             hintText: 'Enter your job title and address',
//                           ),
//                           validator: (value) {
//                             if (hasSpouse == 'yes' && value!.isEmpty) {
//                               return 'This field is required';
//                             }
//                             return null;
//                           },
//                         ),
//                         SizedBox(height: 16),
//                         SizedBox(height: 16),
//                         Text(
//                           'दिनांक',
//                           style: TextStyle(
//                               fontSize: 16, fontWeight: FontWeight.bold),
//                         ),
//                         SizedBox(height: 8),
//                         GestureDetector(
//                           onTap: () async {
//                             DateTime? pickedDate = await showDatePicker(
//                               context: context,
//                               initialDate: DateTime.now(),
//                               firstDate: DateTime(1900),
//                               lastDate: DateTime.now(),
//                             );
//                             if (pickedDate != null) {
//                               String formattedDate =
//                                   DateFormat('yyyy-MM-dd').format(pickedDate);
//                               setState(() {
//                                 marriageDateController.text = formattedDate;
//                               });
//                             }
//                           },
//                           child: AbsorbPointer(
//                             child: TextFormField(
//                               controller: marriageDateController,
//                               decoration: InputDecoration(
//                                 border: OutlineInputBorder(),
//                                 hintText: 'Select your job joining date',
//                                 suffixIcon: Icon(Icons.calendar_today),
//                               ),
//                               validator: (value) {
//                                 if (hasSpouse == 'yes' && value!.isEmpty) {
//                                   return 'This field is required';
//                                 }
//                                 return null;
//                               },
//                             ),
//                           ),
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: 16),
//                 // Submit Button
//                 Center(
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Color(0xFFF76048),
//                       foregroundColor: Colors.white,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(30),
//                       ),
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 40, vertical: 10),
//                     ),
//                     onPressed: isLoading
//                         ? null
//                         : () {
//                             setState(() {
//                               if (hasJob == null) {
//                                 joberrorMessage = 'Please select Yes or No';
//                               } else {
//                                 joberrorMessage = null;
//                               }

//                               if (hasSpouse == null) {
//                                 spouseerrorMessage = 'Please select Yes or No ';
//                               } else {
//                                 spouseerrorMessage = null;
//                               }

//                               // Call submit function only if both validations are passed
//                               if (joberrorMessage == null &&
//                                   spouseerrorMessage == null) {
//                                 _validateAndSubmit(context);
//                               }
//                             });
//                           },
//                     child: isLoading
//                         ? CircularProgressIndicator(
//                             valueColor:
//                                 AlwaysStoppedAnimation<Color>(Colors.blue),
//                           )
//                         : Text(
//                             'Submit',
//                             style: TextStyle(color: Colors.white, fontSize: 20),
//                           ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     jobTitleController.dispose();
//     marriageLocationController.dispose();
//     salaryDetailsTitleController.dispose();
//     jobJoiningDateController.dispose();
//     marriageDateController.dispose();
//     super.dispose();
//   }
// }

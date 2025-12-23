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

class UploadUdidCertificateScreenLogin extends StatefulWidget {
  final String lastSubmit;
  final String adharNo;
  final String name;
  final String mobileNo;
  final String gender;

  const UploadUdidCertificateScreenLogin({
    super.key,
    required this.lastSubmit,
    required this.gender,
    required this.adharNo,
    required this.name,
    required this.mobileNo,
  });

  @override
  _UploadUdidCertificateScreenLoginState createState() =>
      _UploadUdidCertificateScreenLoginState();
}

class _UploadUdidCertificateScreenLoginState
    extends State<UploadUdidCertificateScreenLogin> {
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
      quality: 30,
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
              Expanded(
                child: Text(
                  'Confirm Submission',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
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
            ElevatedButton(
              child: Text('Submit', style: TextStyle(color: Colors.white)),
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
                'Please click divyang certificate photo.\nकृपया दिव्यांग प्रमाणपत्राचा फोटो काढा'),
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
          compressedIncomeCertificateFile =
              await compressImage(compressedIncomeCertificateFile.path);
        }
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://divyangpcmc.altwise.in/api/aadhar/SubmitAadharData'),
      );

      request.fields['AadhaarNumber'] = widget.adharNo;
      request.fields['LastSubmit'] = "Submitted";

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
              mobileNumber: widget.mobileNo,
              addressEnter: widget.adharNo,
              gender: widget.gender,
              fullName: widget.name,
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
        _navigateToErrorScreen(context, 'Failed');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _navigateToErrorScreen(context, 'Error');
    }
  }

  void _navigateToErrorScreen(BuildContext context, String status) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResponseScreen(
          mobileNumber: widget.mobileNo,
          addressEnter: widget.adharNo,
          gender: widget.gender,
          fullName: widget.name,
          message:
              'Failed to submit data. Please try again.\nडेटा सबमिट करण्यात अयशस्वी. कृपया पुन्हा प्रयत्न करा',
          success: false,
          verificationStatus: status,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Upload Divyang UDID Certificate[Step-4]',
          style: TextStyle(
            color: Colors.black,
            fontSize: width * 0.04,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.yellow,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.05,
            vertical: height * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: height * 0.02),
              Text(
                'Capture UDID Certificate Photo',
                style: TextStyle(
                  fontSize: width * 0.06,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  letterSpacing: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: height * 0.01),
              Text(
                'UDID प्रमाणपत्राचा फोटो काढा',
                style: TextStyle(
                  fontSize: width * 0.045,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: height * 0.03),
              Container(
                height: height * 0.5,
                width: width * 0.9,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.yellow,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Center(
                        child: _image == null
                            ? Container(
                                width: width * 0.65,
                                height: height * 0.3,
                                color: Colors.blueGrey,
                                child: Center(
                                  child: Image.asset(
                                    'assets/images/document_image.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  _image!,
                                  height: height * 0.35,
                                  width: width * 0.7,
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: height * 0.015),
                    Padding(
                      padding: EdgeInsets.all(width * 0.02),
                      child: ElevatedButton(
                        onPressed: _getImage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(
                            horizontal: width * 0.08,
                            vertical: height * 0.015,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Click Divyang UDID Certificate \nदिव्यांग दाखल्याचा फोटो काढा",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: width * 0.04,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: height * 0.04),
              _isLoading
                  ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
                    )
                  : SizedBox(
                      width: width * 0.85,
                      child: ElevatedButton(
                        onPressed: () => submitAllData(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: width * 0.1,
                            vertical: height * 0.018,
                          ),
                          elevation: 5,
                        ),
                        child: Text(
                          'Submit Divyang Certificate\nदिव्यांग सर्टिफिकेट सबमिट करा',
                          style: TextStyle(
                            fontSize: width * 0.045,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
              SizedBox(height: height * 0.02),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'dart:convert';
// import 'dart:io';

// import 'package:divyang_pimpri_chinchwad_municipal_corporation/KYC_Screens/response_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_image_compress/flutter_image_compress.dart';
// import 'package:http/http.dart' as http;
// import 'package:http_parser/http_parser.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:path/path.dart';
// import 'package:path_provider/path_provider.dart';

// class UploadUdidCertificateScreenLogin extends StatefulWidget {
//   // final String videoPath;
//   // final String recordedDate;
//   // final String recordedTime;
//   // final String imagePath;
//   // final String aadhaarNumber;
//   final String lastSubmit;
//   final String adharNo;
//   final String name;
//   final String mobileNo;

//   final String gender;
//   // final String fullName;

//   const UploadUdidCertificateScreenLogin({
//     super.key,
//     required this.lastSubmit,
//     required this.gender,
//     required this.adharNo,
//     required this.name,
//     required this.mobileNo,
//   });

//   @override
//   _UploadUdidCertificateScreenLoginState createState() =>
//       _UploadUdidCertificateScreenLoginState();
// }

// class _UploadUdidCertificateScreenLoginState
//     extends State<UploadUdidCertificateScreenLogin> {
//   File? _image;
//   bool _isLoading = false;

//   Future<void> _getImage() async {
//     final picker = ImagePicker();
//     final pickedImage = await picker.pickImage(source: ImageSource.camera);

//     setState(() {
//       if (pickedImage != null) {
//         _image = File(pickedImage.path);
//       } else {
//         print('No image selected.');
//       }
//     });
//   }

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

//   Future<void> submitAllData(BuildContext context) async {
//     bool? confirmSubmission = await showDialog<bool>(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20.0),
//           ),
//           title: Row(
//             children: [
//               Icon(Icons.check_circle_outline, color: Colors.green, size: 28),
//               SizedBox(width: 10),
//               Text(
//                 'Confirm Submission',
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//             ],
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Divider(thickness: 2.5),
//               Text(
//                 'Are you sure you want to submit Divyang Certificate?\nतुम्हाला खात्री आहे की तुम्ही हा दिव्यांगचा दाखला सबमिट करू इच्छिता?',
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
//                 Navigator.of(context).pop(false);
//               },
//             ),
//             TextButton(
//               child: Text('Submit'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.green,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12.0),
//                 ),
//               ),
//               onPressed: () {
//                 Navigator.of(context).pop(true);
//               },
//             ),
//           ],
//         );
//       },
//     );

//     if (confirmSubmission != true) {
//       return;
//     }

//     if (_image == null) {
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: Text('Note'),
//             content: Text(
//                 'Please click diyang certificate photo.\nकृपया दिव्यांग प्रमाणपत्राचा फोटो काढा'),
//             actions: [
//               ElevatedButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: Text('OK'),
//               ),
//             ],
//           );
//         },
//       );
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       File? compressedIncomeCertificateFile;
//       if (_image != null) {
//         compressedIncomeCertificateFile = await compressImage(_image!.path);
//         final fileSize = await compressedIncomeCertificateFile.length();
//         if (fileSize > 500 * 1024) {
//           // If still larger than 500KB
//           // Compress again with even lower quality
//           compressedIncomeCertificateFile =
//               await compressImage(compressedIncomeCertificateFile.path);
//         }
//       }

//       var request = http.MultipartRequest(
//         'POST',
//         Uri.parse('https://divyangpcmc.altwise.in/api/aadhar/SubmitAadharData'),
//       );

//       // Adding fields to the request
//       request.fields['AadhaarNumber'] = widget.adharNo;
//       // request.fields['Latitude'] = widget.latitude;
//       // request.fields['Longitude'] = widget.longitude;
//       // request.fields['LiveAddress'] = widget.address;
//       request.fields['LastSubmit'] = "Submitted";

//       // Add compressed Income Certificate if available
//       if (compressedIncomeCertificateFile != null) {
//         request.files.add(await http.MultipartFile.fromPath(
//           'DivyangCertificate',
//           compressedIncomeCertificateFile.path,
//           filename: basename(compressedIncomeCertificateFile.path),
//           contentType: MediaType('image', 'jpeg'),
//         ));
//       }

//       var response = await request.send().timeout(Duration(seconds: 240));

//       print('Response status: ${response.statusCode}');
//       final responseString = await response.stream.bytesToString();
//       print('Response body: $responseString');

//       setState(() {
//         _isLoading = false;
//       });

//       if (response.statusCode == 200) {
//         final responseJson = json.decode(responseString);
//         final verificationStatus =
//             responseJson['VerificationStatus'] ?? 'Unknown Status';
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => ResponseScreen(
//               // ppoNumber: widget.ppoNumber,
//               mobileNumber: widget.mobileNo,
//               addressEnter: widget.adharNo,
//               // aadharNumber: widget.adharNo,
//               gender: widget.gender,
//               fullName: widget.name,
//               message:
//                   '''You have successfully completed the process for your life certificate.
// Your life certificate is currently under verification. You will receive your certificate soon. Thank you for your patience

// तुम्ही तुमच्या जीवन प्रमाणपत्राची प्रक्रिया यशस्वीपणे पूर्ण केली आहे.
// तुमचे जीवन प्रमाणपत्र सध्या पडताळणीखाली आहे. तुम्हाला तुमचे प्रमाणपत्र लवकरच मिळेल.
// तुमच्या संयमाबद्दल धन्यवाद.''',
//               success: true,
//               verificationStatus: verificationStatus,
//             ),
//           ),
//         );
//       } else {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => ResponseScreen(
//               mobileNumber: widget.mobileNo,
//               addressEnter: widget.adharNo,
//               // aadharNumber: widget.adharNo,
//               gender: widget.gender,
//               fullName: widget.name,
//               // ppoNumber: widget.ppoNumber,
//               // mobileNumber: widget.mobileNumber,
//               // addressEnter: widget.addressEnter,
//               // gender: widget.gender,
//               // fullName: widget.fullName,
//               message:
//                   'Failed to submit data. Please try again.\nडेटा सबमिट करण्यात अयशस्वी. कृपया पुन्हा प्रयत्न करा',
//               success: false,
//               verificationStatus: 'Failed',
//             ),
//           ),
//         );
//       }
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => ResponseScreen(
//             mobileNumber: widget.mobileNo,
//             addressEnter: widget.adharNo,
//             // aadharNumber: widget.adharNo,
//             gender: widget.gender,
//             fullName: widget.name,
//             // ppoNumber: widget.ppoNumber,
//             // mobileNumber: widget.mobileNumber,
//             // addressEnter: widget.addressEnter,
//             // gender: widget.gender,
//             // fullName: widget.fullName,
//             message:
//                 'Failed to submit data. Please try again.\nडेटा सबमिट करण्यात अयशस्वी. कृपया पुन्हा प्रयत्न करा',
//             success: false,
//             verificationStatus: 'Error',
//           ),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Center(
//           child: Text(
//             'Upload Divyang UDID Certificate[Step-4]',
//             style: TextStyle(
//               color: Colors.black,
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//         backgroundColor: Colors.yellow,
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: const EdgeInsets.only(top: 30, left: 20, right: 20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Text("Aadhar Number: ${widget.aadhaarNumber}"),
//                   // Text("Input Field One Value: ${widget.inputFieldOneValue}"),
//                   // Text(
//                   //     "Selected Dropdown Value: ${widget.selectedDropdownValue ?? 'None'}"),
//                   SizedBox(height: 25),
//                   Center(
//                     child: Text(
//                       'Capture UDID Certificate Photo',
//                       style: TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black87,
//                         letterSpacing: 1.5,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                   ),
//                   Center(
//                     child: Text(
//                       'UDID प्रमाणपत्राचा फोटो काढा',
//                       style: TextStyle(
//                         fontSize: 18,
//                         color: Colors.black54,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                   ),
//                   SizedBox(height: 25),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(20.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Center(
//                     child: Container(
//                       height: 400,
//                       width: 350,
//                       decoration: BoxDecoration(
//                         border: Border.all(
//                           color: Colors.yellow,
//                           width: 2.0,
//                         ),
//                         borderRadius: BorderRadius.circular(15),
//                       ),
//                       child: Column(
//                         children: [
//                           Expanded(
//                             child: Center(
//                               child: _image == null
//                                   ? Container(
//                                       width: 250,
//                                       height: 250,
//                                       color: Colors.blueGrey,
//                                       child: Center(
//                                         child: Image.asset(
//                                           'assets/images/document_image.png', // Replace with your actual image path
//                                           fit: BoxFit
//                                               .cover, // Adjust this based on your requirement
//                                         ),
//                                       ),
//                                     )
//                                   : Image.file(
//                                       _image!,
//                                       height: 250,
//                                       width: 250,
//                                     ),
//                             ),
//                           ),
//                           const SizedBox(
//                             height: 10,
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: ElevatedButton(
//                               onPressed: _getImage,
//                               child: const Text(
//                                 "Click Divyang UDID Certificate \nदिव्यांग दाखल्याचा फोटो काढा",
//                                 textAlign: TextAlign.center,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   const SizedBox(
//                     height: 40,
//                   ),
//                   _isLoading
//                       ? const CircularProgressIndicator() // Show loader while uploading
//                       : Padding(
//                           padding: const EdgeInsets.only(
//                             left: 12.0,
//                             right: 12.0,
//                           ),
//                           child: ElevatedButton(
//                             onPressed: () => submitAllData(context),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.yellow,
//                               foregroundColor: Colors.white,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(30),
//                               ),
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 40, vertical: 10),
//                             ),
//                             child: const Text(
//                               'Submit Divyang Certificate\nदिव्यांग सर्टिफिकेट सबमिट करा',
//                               style: TextStyle(
//                                 fontSize: 18, // Adjust font size
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.black, // Text color
//                               ),
//                               textAlign:
//                                   TextAlign.center, // Center align the text
//                             ),
//                           ),
//                         ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

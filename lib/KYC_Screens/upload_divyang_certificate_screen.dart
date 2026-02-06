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
  final String aadhaarNumber;
  final String lastSubmit;
  final String ppoNumber;
  final String mobileNumber;
  final String addressEnter;
  final String gender;
  final String fullName;
  final String udidNumber;
  final String uniqueKey;
  final String disabilityType;
  final String disabilityPercentage;
  final String avakNumber;
  const UploadDivyangCertificateScreen({
    super.key,
    required this.aadhaarNumber,
    required this.lastSubmit,
    required this.ppoNumber,
    required this.mobileNumber,
    required this.addressEnter,
    required this.gender,
    required this.fullName,
    required this.udidNumber,
    required this.disabilityType,
    required this.disabilityPercentage,
    required this.avakNumber,
    required this.uniqueKey,
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
          compressedIncomeCertificateFile =
              await compressImage(compressedIncomeCertificateFile.path);
        }
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://divyangpcmc.altwise.in/api/aadhar/SubmitAadharData'),
      );

      request.fields['AadhaarNumber'] = widget.aadhaarNumber;
      request.fields['DisabilityType'] = widget.disabilityType;
      request.fields['DisabilityPercentage'] = widget.disabilityPercentage;
      request.fields['UDIDNumber'] = widget.udidNumber;
      request.fields['avakNo'] = widget.avakNumber;
      request.fields['Address'] = widget.addressEnter;

      // request.fields['LiveAddress'] = widget.liveAddress;

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
              aadhaarNumber: widget.aadhaarNumber,
              mobileNumber: widget.mobileNumber,
              addressEnter: widget.addressEnter,
              gender: widget.gender,
              fullName: widget.fullName,
              udidNumber: widget.udidNumber,
              uniqueKey: widget.uniqueKey,
              avakNumber: widget.avakNumber,
              disabilityType: widget.disabilityType,
              disabilityPercentage: widget.disabilityPercentage,
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
              avakNumber: widget.avakNumber,
              udidNumber: widget.udidNumber,
              uniqueKey: widget.uniqueKey,
              disabilityType: widget.disabilityType,
              disabilityPercentage: widget.disabilityPercentage,
              aadhaarNumber: widget.aadhaarNumber,
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
            udidNumber: widget.udidNumber,
            uniqueKey: widget.uniqueKey,
            avakNumber: widget.avakNumber,
            disabilityType: widget.disabilityType,
            disabilityPercentage: widget.disabilityPercentage,
            aadhaarNumber: widget.aadhaarNumber,
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
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Upload Divyang UDID Certificate ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Color(0xFFF76048),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: height * 0.01,
                    left: width * 0.05,
                    right: width * 0.05,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: height * 0.01),
                      Center(
                        child: Text(
                          'Capture UDID Certificate Photo',
                          style: TextStyle(
                            fontSize: width * 0.06,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            letterSpacing: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Center(
                        child: Text(
                          'UDID प्रमाणपत्राचा फोटो काढा',
                          style: TextStyle(
                            fontSize: width * 0.045,
                            color: Colors.black54,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: height * 0.03),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(width * 0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: Container(
                          height: height * 0.5,
                          width: width * 0.8,
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
                                          width: width * 0.60,
                                          height: height * 0.3,
                                          color: Colors.blueGrey,
                                          child: Center(
                                            child: Image.asset(
                                              'assets/images/document_image.png',
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        )
                                      : Image.file(
                                          _image!,
                                          height: height * 0.3,
                                          width: width * 0.60,
                                        ),
                                ),
                              ),
                              SizedBox(height: height * 0.01),
                              Padding(
                                padding: EdgeInsets.all(width * 0.02),
                                child: ElevatedButton(
                                  onPressed: _getImage,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: width * 0.1,
                                      vertical: height * 0.015,
                                    ),
                                  ),
                                  child: const Text(
                                    "Click Divyang UDID Certificate \nदिव्यांग दाखल्याचा फोटो काढा",
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: height * 0.03),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: width * 0.03),
                        child: ElevatedButton(
                          onPressed:
                              _isLoading ? null : () => submitAllData(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFF76048),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: width * 0.1,
                              vertical: height * 0.015,
                            ),
                          ),
                          child: _isLoading
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: width * 0.05,
                                      height: width * 0.05,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    ),
                                    SizedBox(width: width * 0.04),
                                    Text(
                                      'Please Wait...\nकृपया प्रतीक्षा करा...',
                                      style: TextStyle(
                                        fontSize: width * 0.045,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                )
                              : Text(
                                  'Submit Divyang Certificate\nदिव्यांग सर्टिफिकेट सबमिट करा',
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
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

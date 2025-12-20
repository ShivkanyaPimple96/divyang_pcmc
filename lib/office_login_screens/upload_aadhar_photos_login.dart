import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

import 'package:path/path.dart' as path;

class UploadAadharPhotosLogin extends StatefulWidget {
  // final String aadhaarNumber;
  // final String ppoNumber;
  // final String mobileNumber;
  // final String addressEnter;
  final String gender;
  // final String fullName;
  final String lastSubmit;
  final String userId;
  final String avakNo;
  final String adharNo;
  final String name;
  final String mobileNo;
  final String uniqueKey;
  // final String lastSubmit;
  // final String gender;
  final String disabilityType;
  final String disabilityPercentage;
  final String imagePath;
  // final String aadhaarNumber;
  final String latitude;
  final String longitude;
  final String address;

  const UploadAadharPhotosLogin({
    super.key,
    // required this.aadhaarNumber,
    // required this.ppoNumber,
    // required this.mobileNumber,
    // required this.addressEnter,
    required this.gender,
    // required this.fullName,
    required this.lastSubmit,
    required this.userId,
    required this.avakNo,
    required this.adharNo,
    required this.name,
    required this.mobileNo,
    required this.uniqueKey,
    required this.disabilityType,
    required this.disabilityPercentage,
    required this.imagePath,
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  @override
  _UploadAadharPhotosLoginState createState() =>
      _UploadAadharPhotosLoginState();
}

class _UploadAadharPhotosLoginState extends State<UploadAadharPhotosLogin> {
  File? _frontImage;
  File? _backImage;
  final ImagePicker _picker = ImagePicker();
  bool _isCompressing = false;

  @override
  void initState() {
    super.initState();
    // Clear any previous images when screen initializes
    _frontImage = null;
    _backImage = null;
  }

  @override
  void dispose() {
    // Clean up images when screen is disposed
    _frontImage = null;
    _backImage = null;
    super.dispose();
  }

  Future<File?> _compressImage(File file) async {
    try {
      final filePath = file.absolute.path;

      // Create output file path
      final lastIndex = filePath.lastIndexOf(RegExp(r'.jp'));
      final splitted = filePath.substring(0, (lastIndex));
      final outPath = "${splitted}_compressed${filePath.substring(lastIndex)}";

      final result = await FlutterImageCompress.compressAndGetFile(
        filePath,
        outPath,
        quality: 30, // adjust quality (0-100)
        minWidth: 1024, // adjust width as needed
        minHeight: 1024, // adjust height as needed
      );

      return result != null ? File(result.path) : file;
    } catch (e) {
      print('Error compressing image: $e');
      return file; // return original if compression fails
    }
  }

  Future<void> _pickImage(bool isFront) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() => _isCompressing = true);

      final file = File(pickedFile.path);
      final compressedFile = await _compressImage(file);

      setState(() {
        if (isFront) {
          _frontImage = compressedFile;
        } else {
          _backImage = compressedFile;
        }
        _isCompressing = false;
      });
    }
  }

  Future<void> _submitAadharPhotos() async {
    if (_frontImage == null || _backImage == null) return;

    // Show confirmation dialog first
    bool? confirmSubmission = await _showConfirmationDialog();
    if (confirmSubmission != true) return;

    setState(() => _isCompressing = true);

    try {
      // Compress images again before submission
      final compressedFront = await _compressImage(_frontImage!);
      final compressedBack = await _compressImage(_backImage!);

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://divyangpcmc.altwise.in/api/aadhar/PostOffice'),
      );

      // Add all required fields to request
      request.fields.addAll({
        // 'AadhaarNumber': widget.aadhaarNumber,
        // 'PPONumber': widget.ppoNumber,
        // 'MobileNumber': widget.mobileNumber,
        // 'Address': widget.addressEnter,
        // 'Gender': widget.gender,
        // 'FullName': widget.fullName,
        'aadharNo': widget.adharNo,
        'mobileNo': widget.mobileNo,
        'Name': widget.name,
      });

      // Add front and back images
      request.files.add(await http.MultipartFile.fromPath(
        'AadharFront',
        compressedFront?.path ?? _frontImage!.path,
        filename: path.basename(compressedFront?.path ?? _frontImage!.path),
        contentType: MediaType('image', 'jpeg'),
      ));

      request.files.add(await http.MultipartFile.fromPath(
        'AadharBack',
        compressedBack?.path ?? _backImage!.path,
        filename: path.basename(compressedBack?.path ?? _backImage!.path),
        contentType: MediaType('image', 'jpeg'),
      ));

      // Debug print request details
      debugPrint('Request fields: ${request.fields}');
      debugPrint(
          'Request files: ${request.files.map((f) => '${f.field}: ${f.filename}')}');

      // Send the request
      var response = await request.send().timeout(const Duration(seconds: 240));
      String responseBody = await response.stream.bytesToString();
      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: $responseBody');

      if (!mounted) return;

      if (response.statusCode == 200) {
        // Navigate to next screen on success
        _navigateToKYCScreen();
      } else {
        // Stop loader before showing error dialog
        setState(() => _isCompressing = false);
        await _showErrorDialog(
          'Failed to submit Aadhar photos. Please try again.\n'
          'आधार फोटो सबमिट करण्यात अयशस्वी. कृपया पुन्हा प्रयत्न करा.',
        );
      }
    } on TimeoutException {
      if (!mounted) return;
      // Stop loader before showing error dialog
      setState(() => _isCompressing = false);
      await _showErrorDialog(
        'The request timed out. Please check your internet connection and try again.\n'
        'विनंतीची मुदत संपली. कृपया तुमचे इंटरनेट कनेक्शन तपासा आणि पुन्हा प्रयत्न करा.',
        title: 'Request Timeout',
      );
    } catch (e) {
      if (!mounted) return;
      // Stop loader before showing error dialog
      setState(() => _isCompressing = false);
      await _showErrorDialog(
        'Please check your internet connection\n कृपया तुमचे इंटरनेट कनेक्शन तपासा.',
      );
      debugPrint('Error during submission: $e');
    }
    // Removed finally block since loader is stopped in each error case
    // and navigation happens in success case
  }

  // Future<void> _submitAadharPhotos() async {
  //   if (_frontImage == null || _backImage == null) return;

  //   // Show confirmation dialog first
  //   bool? confirmSubmission = await _showConfirmationDialog();
  //   if (confirmSubmission != true) return;

  //   setState(() => _isCompressing = true);

  //   try {
  //     // Compress images again before submission
  //     final compressedFront = await _compressImage(_frontImage!);
  //     final compressedBack = await _compressImage(_backImage!);

  //     var request = http.MultipartRequest(
  //       'POST',
  //       Uri.parse('https://nmcpensioner.com/api/aadhar/submit'),
  //     );

  //     // Add all required fields to request
  //     request.fields.addAll({
  //       'AadhaarNumber': widget.aadhaarNumber,
  //       'PPONumber': widget.ppoNumber,
  //       'MobileNumber': widget.mobileNumber,
  //       'Address': widget.addressEnter,
  //       'Gender': widget.gender,
  //       'FullName': widget.fullName,
  //     });

  //     // Add front and back images
  //     request.files.add(await http.MultipartFile.fromPath(
  //       'AadharFront',
  //       compressedFront?.path ?? _frontImage!.path,
  //       filename: path.basename(compressedFront?.path ?? _frontImage!.path),
  //       contentType: MediaType('image', 'jpeg'),
  //     ));

  //     request.files.add(await http.MultipartFile.fromPath(
  //       'AadharBack',
  //       compressedBack?.path ?? _backImage!.path,
  //       filename: path.basename(compressedBack?.path ?? _backImage!.path),
  //       contentType: MediaType('image', 'jpeg'),
  //     ));

  //     // Debug print request details
  //     debugPrint('Request fields: ${request.fields}');
  //     debugPrint(
  //         'Request files: ${request.files.map((f) => '${f.field}: ${f.filename}')}');

  //     // Send the request
  //     var response = await request.send().timeout(const Duration(seconds: 240));
  //     String responseBody = await response.stream.bytesToString();
  //     debugPrint('Response status: ${response.statusCode}');
  //     debugPrint('Response body: $responseBody');

  //     if (!mounted) return;

  //     if (response.statusCode == 200) {
  //       // Navigate to next screen on success
  //       _navigateToKYCScreen();
  //     } else {
  //       await _showErrorDialog(
  //         'Failed to submit Aadhar photos. Please try again.\n'
  //         'आधार फोटो सबमिट करण्यात अयशस्वी. कृपया पुन्हा प्रयत्न करा.',
  //       );
  //     }
  //   } on TimeoutException {
  //     if (!mounted) return;
  //     await _showErrorDialog(
  //       'The request timed out. Please check your internet connection and try again.\n'
  //       'विनंतीची मुदत संपली. कृपया तुमचे इंटरनेट कनेक्शन तपासा आणि पुन्हा प्रयत्न करा.',
  //       title: 'Request Timeout',
  //     );
  //   } catch (e) {
  //     if (!mounted) return;
  //     await _showErrorDialog(
  //       'Please check your internet connection\n कृपया तुमचे इंटरनेट कनेक्शन तपासा.',
  //     );
  //     debugPrint('Error during submission: $e');
  //   } finally {
  //     if (mounted) {
  //       setState(() => _isCompressing = false);
  //     }
  //   }
  // }

  Future<bool?> _showConfirmationDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          title: Row(children: [
            const Icon(Icons.check_circle_outline,
                color: Colors.green, size: 28),
            const SizedBox(width: 10),
            Text('Note',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ]),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(thickness: 2.5),
              Text(
                'Are you sure you want to submit this Aadhar photos?\nतुम्हाला खात्री आहे की तुम्ही हे आधार फोटो सबमिट करू इच्छिता?',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const Divider(thickness: 2.5),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0)),
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showErrorDialog(
    String message, {
    IconData icon = Icons.error_outline,
    Color iconColor = Colors.red,
    String title = 'Note',
  }) async {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        title: Row(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 10),
            Text(title),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(thickness: 2.5),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const Divider(thickness: 2.5),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _navigateToKYCScreen() {
    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => PhotoClickKYCScreen(
    //       aadhaarNumber: widget.aadhaarNumber,
    //       ppoNumber: widget.ppoNumber,
    //       mobileNumber: widget.mobileNumber,
    //       addressEnter: widget.addressEnter,
    //       gender: widget.gender,
    //       fullName: widget.fullName,
    //       lastSubmit: "",
    //     ),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 27, 107, 212),
        title: Text(
          'Upload Aadhar Card Photos',
          style: TextStyle(
            color: Colors.white,
            fontSize: width * 0.05,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {},
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(width * 0.05),
            child: Column(
              children: [
                Text(
                  'Click Aadhar Card Front Photo\nआधार कार्डचा समोरील फोटो काढा.',
                  style: TextStyle(
                    fontSize: width * 0.045,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: height * 0.020),

                // Front Side Upload
                _buildUploadCard(
                  isFront: true,
                  image: _frontImage,
                  onTap: () => _pickImage(true),
                  width: width,
                  height: height,
                ),
                SizedBox(height: height * 0.025),
                Text(
                  'Click Aadhar Card Back Photo\nआधार कार्डचा मागील फोटो काढा.',
                  style: TextStyle(
                    fontSize: width * 0.045,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: height * 0.020),
                // Back Side Upload
                _buildUploadCard(
                  isFront: false,
                  image: _backImage,
                  onTap: () => _pickImage(false),
                  width: width,
                  height: height,
                ),
                SizedBox(height: height * 0.04),

                // Submit Button
                ElevatedButton(
                  onPressed: _frontImage != null &&
                          _backImage != null &&
                          !_isCompressing
                      ? _submitAadharPhotos
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: width * 0.0875,
                      vertical: height * 0.01,
                    ),
                    backgroundColor: const Color.fromARGB(255, 27, 107, 212),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                    shadowColor: Colors.teal.withOpacity(0.3),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: width * 0.075,
                      vertical: height * 0.012,
                    ),
                    child: _isCompressing
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Please wait..\nकृपया प्रतीक्षा करा..",
                                style: TextStyle(
                                  fontSize: width * 0.035,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: height * 0.008),
                              SizedBox(
                                height: width * 0.06,
                                width: width * 0.06,
                                child: CircularProgressIndicator(
                                  color: Colors.blue,
                                  strokeWidth: 3,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            'Submit',
                            style: TextStyle(
                              fontSize: width * 0.05,
                              color: Colors.white,
                            ),
                          ),
                  ),

                  // child: Text(
                  //   'Submit',
                  //   style: TextStyle(
                  //     fontSize: width * 0.05,
                  //     color: Colors.white,
                  //   ),
                  // ),
                ),
              ],
            ),
          ),
          // if (_isCompressing)
          //   Container(
          //     color: Colors.black.withOpacity(0.5),
          //     child: const Center(
          //       child: CircularProgressIndicator(),
          //     ),
          //   ),
        ],
      ),
    );
  }

  Widget _buildUploadCard({
    required bool isFront,
    required File? image,
    required VoidCallback onTap,
    required double width,
    required double height,
  }) {
    return InkWell(
      onTap: _isCompressing ? null : onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        height: height * 0.22,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(
            color: const Color(0xFF92B7F7),
            width: 1.5,
          ),
        ),
        child: image == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_upload,
                    size: width * 0.125,
                    color: const Color(0xFFEAAFEA),
                  ),
                  SizedBox(height: height * 0.012),
                  Text(
                    isFront ? 'Front Side' : 'Back Side',
                    style: TextStyle(
                      fontSize: width * 0.045,
                      color: Colors.blue[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: height * 0.006),
                  Text(
                    'Tap to upload',
                    style: TextStyle(
                      fontSize: width * 0.035,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    Image.file(
                      image,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    // if (_isCompressing)
                    //   Container(
                    //     color: Colors.black.withOpacity(0.3),
                    //     child: const Center(
                    //       child: CircularProgressIndicator(),
                    //     ),
                    //   ),
                  ],
                ),
              ),
      ),
    );
  }
}

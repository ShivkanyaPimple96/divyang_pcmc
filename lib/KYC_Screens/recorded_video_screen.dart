import 'dart:async';
import 'dart:io';

import 'package:divyang_pimpri_chinchwad_municipal_corporation/KYC_Screens/upload_divyang_certificate_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerKYCScreen extends StatefulWidget {
  final String videoPath;
  final String recordedDate;
  final String recordedTime;
  final String aadhaarNumber;
  final bool isFrontCamera;
  final String ppoNumber;
  final String mobileNumber;
  final String addressEnter;
  final String gender;
  final String fullName;
  final String udidNumber;
  final String disabilityType;
  final String disabilityPercentage;
  final String lastSubmit;

  const VideoPlayerKYCScreen({
    super.key,
    required this.videoPath,
    required this.recordedDate,
    required this.recordedTime,
    required this.aadhaarNumber,
    required this.isFrontCamera,
    required this.ppoNumber,
    required this.mobileNumber,
    required this.addressEnter,
    required this.gender,
    required this.fullName,
    required this.lastSubmit,
    required this.udidNumber,
    required this.disabilityType,
    required this.disabilityPercentage,
  });

  @override
  _VideoPlayerKYCScreenState createState() => _VideoPlayerKYCScreenState();
}

class _VideoPlayerKYCScreenState extends State<VideoPlayerKYCScreen> {
  late VideoPlayerController _controller;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> submitVideo(BuildContext context) async {
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
                'Are you sure you want to submit this Video?\nतुम्हाला खात्री आहे की तुम्ही हा व्हिडिओ सबमिट करू इच्छिता?',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              Divider(thickness: 2.5),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            ElevatedButton(
              child: Text('Submit'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmSubmission != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Compress the video
      final compressedVideo = await VideoCompress.compressVideo(
        widget.videoPath,
        quality: VideoQuality.LowQuality,
        deleteOrigin: false,
      );

      if (compressedVideo == null ||
          compressedVideo.filesize! > 10 * 1024 * 1024) {
        setState(() => _isLoading = false);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Note'),
            content: Text('Video is too large. Please record a shorter video'),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
        return;
      }

      final videoFile = File(compressedVideo.path!);

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://divyangpcmc.altwise.in/api/aadhar/SubmitAadharData'),
      );

      // Adding fields to the request
      request.fields['AadhaarNumber'] = widget.aadhaarNumber;
      request.fields['RecordedDate'] = widget.recordedDate;
      request.fields['RecordedTime'] = widget.recordedTime;
      // request.fields['PPONumber'] = widget.ppoNumber;
      // request.fields['MobileNumber'] = widget.mobileNumber;
      // request.fields['Address'] = widget.addressEnter;
      // request.fields['Gender'] = widget.gender;
      // request.fields['FullName'] = widget.fullName;
      request.fields['LastSubmit'] = "";

      // Add video file
      request.files.add(await http.MultipartFile.fromPath(
        'KycVideo',
        videoFile.path,
        filename: basename(videoFile.path),
        contentType: MediaType('video', 'mp4'),
      ));

      // Debug print all fields and files
      print('Request fields: ${request.fields}');
      print('Request files count: ${request.files.length}');

      // Sending the request with timeout
      var response = await request.send().timeout(Duration(seconds: 240));

      // Read response for debugging
      String responseBody = await response.stream.bytesToString();
      print('Response status: ${response.statusCode}');
      print('Response body: $responseBody');

      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        // Navigate to DeclarationPageScreen with required parameters
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UploadDivyangCertificateScreen(
              ppoNumber: widget.ppoNumber,
              mobileNumber: widget.mobileNumber,
              addressEnter: widget.addressEnter,
              gender: widget.gender,
              fullName: widget.fullName,
              // ppoNumber: widget.ppoNumber,
              // videoPath: widget.videoPath,
              aadhaarNumber: widget.aadhaarNumber,
              udidNumber: widget.udidNumber,
              disabilityType: widget.disabilityType,
              disabilityPercentage: widget.disabilityPercentage,
              lastSubmit: "",
            ),
          ),
          // (Route<dynamic> route) => false, // This removes all previous routes
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Note'),
            content: Text(
              'Failed to submit video data. Please try again.\nव्हिडिओ सबमिट करण्यात अयशस्वी. कृपया पुन्हा प्रयत्न करा',
            ),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      }
    } on TimeoutException {
      setState(() => _isLoading = false);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Note'),
          content: Text(
            'Request video timed out. Please try again.\nविनंती व्हिडिओ कालबाह्य झाला. कृपया पुन्हा प्रयत्न करा.',
          ),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error during submission: $e');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Note'),
          content: Text(
            'Failed to submit Video: Check your Internet Connection and Please try again.\nतुमचे इंटरनेट कनेक्शन तपासा आणि कृपया पुन्हा प्रयत्न करा.',
          ),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Center(
            child: Text(
              'Upload Video [Step-5]',
              style: TextStyle(
                color: Colors.white,
                fontSize: width * 0.045,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          backgroundColor: const Color(0xFFF76048),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(width * 0.02),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Recorded Video',
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
                    'रेकॉर्ड केलेला व्हिडिओ',
                    style: TextStyle(
                      fontSize: width * 0.045,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: height * 0.010),
                Center(
                  child: Container(
                    height: height * 0.25,
                    width: width * 0.750,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDF7FD),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFFF76048),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: _controller.value.isInitialized
                          ? Stack(
                              alignment: Alignment.topCenter,
                              children: [
                                SizedBox(
                                  width: width * 0.85,
                                  height: height * 0.3,
                                  child: AspectRatio(
                                    aspectRatio: _controller.value.aspectRatio,
                                    child: widget.isFrontCamera
                                        ? Transform(
                                            alignment: Alignment.center,
                                            transform: Matrix4.rotationY(180),
                                            child: VideoPlayer(_controller),
                                          )
                                        : VideoPlayer(_controller),
                                  ),
                                ),
                                Positioned(
                                  top: height * 0.012,
                                  child: Column(
                                    children: [
                                      Text(
                                        'Recorded Date: ${widget.recordedDate}',
                                        style: TextStyle(
                                          fontSize: width * 0.04,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        'Recorded Time: ${widget.recordedTime}',
                                        style: TextStyle(
                                          fontSize: width * 0.04,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : CircularProgressIndicator(),
                    ),
                  ),
                ),
                SizedBox(height: height * 0.040),

                ElevatedButton.icon(
                  onPressed: _isLoading ? null : () => submitVideo(context),
                  icon: _isLoading
                      ? SizedBox(
                          width: width * 0.05,
                          height: width * 0.05,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.black,
                            ),
                          ),
                        )
                      : SizedBox.shrink(),
                  label: _isLoading
                      ? Text(
                          'Please Wait...\nकृपया प्रतीक्षा करा...',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: width * 0.045,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            letterSpacing: 1.2,
                          ),
                        )
                      : Text(
                          'Submit video\nव्हिडिओ सबमिट करा',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: width * 0.045,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isLoading ? Colors.grey : Color(0xFFF76048),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: width * 0.1,
                      vertical: height * 0.012,
                    ),
                    elevation: 5,
                  ),
                ),
                // ElevatedButton.icon(
                //   onPressed: _isLoading ? null : () => submitVideo(context),
                //   icon: _isLoading
                //       ? SizedBox(
                //           width: width * 0.05,
                //           height: width * 0.05,
                //           child: CircularProgressIndicator(
                //             strokeWidth: 2,
                //             valueColor: AlwaysStoppedAnimation<Color>(
                //               Colors.black,
                //             ),
                //           ),
                //         )
                //       : SizedBox.shrink(),
                //   label: Text(
                //     _isLoading
                //         ? 'Please Wait...\nकृपया प्रतीक्षा करा...'
                //         : 'Submit video\nव्हिडिओ सबमिट करा',
                //     textAlign: TextAlign.center,
                //     style: TextStyle(
                //       fontSize: width * 0.045,
                //       fontWeight: FontWeight.bold,
                //       color: Colors.white,
                //       letterSpacing: 1.2,
                //     ),
                //   ),
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor:
                //         _isLoading ? Colors.grey : Color(0xFFF76048),
                //     foregroundColor: Colors.white,
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(30),
                //     ),
                //     padding: EdgeInsets.symmetric(
                //       horizontal: width * 0.1,
                //       vertical: height * 0.012,
                //     ),
                //     elevation: 5,
                //   ),
                // ),
                SizedBox(height: height * 0.012),
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Container(
          padding: EdgeInsets.symmetric(
              horizontal: width * 0.0875, vertical: height * 0.048),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color.fromARGB(255, 243, 163, 33),
                  padding: EdgeInsets.symmetric(
                      vertical: height * 0.0145, horizontal: width * 0.04),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  'Re-Record\nव्हिडिओ परत रेकॉर्ड करा',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: width * 0.035,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              FloatingActionButton(
                onPressed: () async {
                  if (_controller.value.isInitialized) {
                    setState(() {
                      if (_controller.value.isPlaying) {
                        _controller.pause();
                      } else {
                        _controller.play();
                        _controller.setVolume(1.0);
                      }
                    });
                  }
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _controller.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                      size: width * 0.075,
                    ),
                    Text(
                      "व्हिडिओ प्ले करा",
                      style: TextStyle(fontSize: width * 0.02),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

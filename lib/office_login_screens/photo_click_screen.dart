import 'dart:io';

import 'package:divyang_pimpri_chinchwad_municipal_corporation/office_login_screens/upload_aadhar_photos_login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class PhotoClickScreen extends StatefulWidget {
  final String address;
  final String gender;
  final String disabilityType;
  final String disabilityPercentage;
  final String lastSubmit;
  final String userId;
  final String avakNo;
  final String adharNo;
  final String name;
  final String mobileNo;
  final String uniqueKey;
  final String udidNumber;

  const PhotoClickScreen({
    super.key,
    required this.lastSubmit,
    required this.userId,
    required this.avakNo,
    required this.adharNo,
    required this.name,
    required this.mobileNo,
    required this.uniqueKey,
    required this.address,
    required this.gender,
    required this.disabilityType,
    required this.disabilityPercentage,
    required this.udidNumber,
  });

  @override
  _PhotoClickScreenState createState() => _PhotoClickScreenState();
}

class _PhotoClickScreenState extends State<PhotoClickScreen> {
  File? _image;
  bool _isLoading = false;
  String? _latitude;
  String? _longitude;
  String? _address;

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
    );

    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
        _isLoading = true;
      });

      try {
        await _getCurrentLocation();
      } catch (e) {
        print('Error getting location: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      print('No image selected.');
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permissions are denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('Location permissions are permanently denied');
      return;
    }

    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _latitude = position.latitude.toString();
      _longitude = position.longitude.toString();
    });

    await _getAddressFromCoordinates(position.latitude, position.longitude);
  }

  Future<void> _getAddressFromCoordinates(
      double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        String address = '';
        if (place.street != null) address += '${place.street}, ';
        if (place.subLocality != null) address += '${place.subLocality}, ';
        if (place.locality != null) address += '${place.locality}, ';
        if (place.administrativeArea != null)
          address += '${place.administrativeArea}, ';
        if (place.postalCode != null) address += '${place.postalCode}, ';
        address = address.replaceAll(RegExp(r', $'), '');

        setState(() {
          _address = address;
        });
      } else {
        setState(() {
          _address = 'No address found for these coordinates';
        });
      }
    } catch (e) {
      print('Error getting address: $e');
      setState(() {
        _address = 'Failed to get address';
      });
    }
  }

  Future<File?> _compressImage(File imageFile) async {
    try {
      final result = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        '${imageFile.path}_compressed.jpg',
        quality: 50,
        minWidth: 800,
        minHeight: 800,
      );
      return result != null ? File(result.path) : null;
    } catch (e) {
      print('Error compressing image: $e');
      return null;
    }
  }

  Future<bool> _submitPhotoToAPI(File imageFile) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final compressedImage = await _compressImage(imageFile);
      if (compressedImage == null) {
        throw Exception('Image compression failed');
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://divyangpcmc.altwise.in/api/aadhar/PostOffice'),
      );

      request.fields['AadhaarNumber'] = widget.adharNo;
      request.fields['userId'] = widget.userId;
      request.fields['avakNo'] = widget.avakNo;
      request.fields['adharNo'] = widget.adharNo;
      request.fields['name'] = widget.name;
      request.fields['mobileNo'] = widget.mobileNo;
      request.fields['uniqueKey'] = widget.uniqueKey;
      request.fields['Latitude'] = _latitude ?? '';
      request.fields['Longitude'] = _longitude ?? '';
      request.fields['Address'] = _address ?? '';
      request.fields['LiveAddress'] = _address ?? '';
      request.fields['LastSubmit'] = "";

      request.files.add(await http.MultipartFile.fromPath(
        'Selfie',
        compressedImage.path,
      ));

      var response = await request.send().timeout(Duration(seconds: 240));
      print('Status Code: ${response.statusCode}');
      print('Headers: ${response.headers}');

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        print('API Response: $responseBody');
        return true;
      } else {
        final errorBody = await response.stream.bytesToString();
        print('API Error: ${response.statusCode} - $errorBody');
        return false;
      }
    } catch (e) {
      print('Error submitting photo: $e');
      return false;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _showSubmitPhotoDialog() async {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: Row(
            children: [
              Icon(Icons.check_circle_outline,
                  color: Colors.blue, size: width * 0.07),
              SizedBox(width: width * 0.025),
              Text(
                'Note',
                style: TextStyle(
                  fontSize: width * 0.05,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Divider(thickness: 2.5),
              SizedBox(height: width * 0.02),
              Text(
                'Are you sure you want to submit the photo?\nतुम्हाला खात्री आहे की तुम्ही हा फोटो सबमिट करू इच्छिता?',
                style: TextStyle(fontSize: width * 0.04),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: width * 0.02),
              Divider(thickness: 2.5),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: width * 0.04,
                ),
              ),
            ),
            TextButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.04,
                  vertical: width * 0.02,
                ),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                if (_image != null) {
                  final success = await _submitPhotoToAPI(_image!);
                  if (success) {
                    _navigateToVideoRecordScreen();
                  } else {
                    _showErrorDialog();
                  }
                }
              },
              child: Text(
                'Submit',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: width * 0.04,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog() {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: width * 0.07),
            SizedBox(width: width * 0.025),
            Text(
              'Note',
              style: TextStyle(
                fontSize: width * 0.05,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Divider(thickness: 2.5),
            SizedBox(height: width * 0.02),
            Text(
              'Failed to submit the photo. Please try again.\n'
              'फोटो सबमिट करण्यात अयशस्वी, कृपया पुन्हा प्रयत्न करा .',
              style: TextStyle(fontSize: width * 0.04),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: width * 0.02),
            Divider(thickness: 2.5),
          ],
        ),
        actions: [
          TextButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.04,
                vertical: width * 0.02,
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: TextStyle(fontSize: width * 0.04),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToVideoRecordScreen() {
    if (_image != null && _latitude != null && _longitude != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UploadAadharPhotosLogin(
            imagePath: _image!.path,
            userId: widget.userId,
            avakNo: widget.avakNo,
            adharNo: widget.adharNo,
            name: widget.name,
            mobileNo: widget.mobileNo,
            uniqueKey: widget.uniqueKey,
            latitude: _latitude!,
            longitude: _longitude!,
            address: _address!,
            gender: widget.gender,
            uididNumber: widget.udidNumber,
            disabilityType: widget.disabilityType,
            disabilityPercentage: widget.disabilityPercentage,
            lastSubmit: "",
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
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.yellow,
          title: Text(
            'Upload Photo [Step-2]',
            style: TextStyle(
              color: Colors.black,
              fontSize: width * 0.05,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.05,
              vertical: height * 0.02,
            ),
            child: Column(
              children: [
                SizedBox(height: height * 0.03),

                // Title Section
                Text(
                  'Capture Divyang Photo',
                  style: TextStyle(
                    fontSize: width * 0.06,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: height * 0.01),
                Text(
                  'दिव्यांग व्यक्तीचा फोटो काढा',
                  style: TextStyle(
                    fontSize: width * 0.045,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: height * 0.04),

                // Photo Container
                Container(
                  width: width * 0.9,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDF7FD),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.yellow,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: height * 0.02),

                      // Image Display
                      Container(
                        width: width * 0.7,
                        height: width * 0.7,
                        decoration: BoxDecoration(
                          color: Colors.blueGrey[50],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: _image == null
                              ? Image.asset(
                                  'assets/images/capture_image.jpeg',
                                  fit: BoxFit.contain,
                                )
                              : Image.file(
                                  _image!,
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),

                      SizedBox(height: height * 0.02),

                      // Click Photo Button
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: width * 0.05,
                          vertical: height * 0.015,
                        ),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _getImage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: width * 0.08,
                              vertical: height * 0.015,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.camera_alt, size: width * 0.06),
                              SizedBox(width: width * 0.02),
                              Text(
                                "Click Photo\nफोटो काढा",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: width * 0.04,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: height * 0.03),

                // Submit Button
                if (_image != null)
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _showSubmitPhotoDialog,
                    icon: _isLoading
                        ? SizedBox(
                            width: width * 0.06,
                            height: width * 0.06,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.black,
                              ),
                            ),
                          )
                        : Icon(Icons.send, size: width * 0.06),
                    label: Text(
                      _isLoading
                          ? 'Please Wait...\nकृपया प्रतीक्षा करा...'
                          : 'Submit Photo\nफोटो सबमिट करा',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: width * 0.045,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isLoading ? Colors.grey : Colors.yellow,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.1,
                        vertical: height * 0.015,
                      ),
                      elevation: 5,
                    ),
                  ),

                SizedBox(height: height * 0.02),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

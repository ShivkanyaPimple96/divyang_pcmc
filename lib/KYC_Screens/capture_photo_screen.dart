import 'dart:io';

import 'package:divyang_pimpri_chinchwad_municipal_corporation/KYC_Screens/vedio_record_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class PhotoClickKYCScreen extends StatefulWidget {
  final String aadhaarNumber;
  final String ppoNumber;
  final String mobileNumber;
  final String addressEnter;
  final String gender;
  final String fullName;
  final String udidNumber;
  final String disabilityType;
  final String disabilityPercentage;
  final String lastSubmit;

  const PhotoClickKYCScreen({
    super.key,
    required this.aadhaarNumber,
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
  _PhotoClickKYCScreenState createState() => _PhotoClickKYCScreenState();
}

class _PhotoClickKYCScreenState extends State<PhotoClickKYCScreen> {
  File? _image;
  bool _isLoading = false;
  String? _latitude;
  String? _longitude;
  String? _address;

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.camera);

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
        Uri.parse('https://divyangpcmc.altwise.in/api/aadhar/SubmitAadharData'),
      );

      request.fields['AadhaarNumber'] = widget.aadhaarNumber;
      request.fields['ppoNumber'] = widget.ppoNumber;
      request.fields['mobileNumber'] = widget.mobileNumber;
      request.fields['addressEnter'] = widget.addressEnter;
      request.fields['gender'] = widget.gender;
      request.fields['fullName'] = widget.fullName;
      request.fields['Latitude'] = _latitude ?? '';
      request.fields['Longitude'] = _longitude ?? '';
      request.fields['Address'] = _address ?? '';
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
            borderRadius: BorderRadius.circular(width * 0.05),
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
              const Divider(thickness: 2.5),
              Text(
                'Are you sure you want to submit the photo?\nतुम्हाला खात्री आहे की तुम्ही हा फोटो सबमिट करू इच्छिता?',
                style: TextStyle(fontSize: width * 0.04),
                textAlign: TextAlign.center,
              ),
              const Divider(thickness: 2.5),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
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
                  borderRadius: BorderRadius.circular(width * 0.03),
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
                style: TextStyle(fontSize: width * 0.04),
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
          borderRadius: BorderRadius.circular(width * 0.05),
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
            const Divider(thickness: 2.5),
            SizedBox(height: width * 0.02),
            Text(
              'Failed to submit the photo. Please try again.\n'
              'फोटो सबमिट करण्यात अयशस्वी, कृपया पुन्हा प्रयत्न करा .',
              style: TextStyle(fontSize: width * 0.04),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: width * 0.02),
            const Divider(thickness: 2.5),
          ],
        ),
        actions: [
          TextButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(width * 0.03),
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
          builder: (context) => VideoRecordKYCScreen(
            aadhaarNumber: widget.aadhaarNumber,
            ppoNumber: widget.ppoNumber,
            mobileNumber: widget.mobileNumber,
            addressEnter: widget.addressEnter,
            gender: widget.gender,
            fullName: widget.fullName,
            udidNumber: widget.udidNumber,
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
          backgroundColor: const Color(0xFFF76048),
          title: Center(
            child: Text(
              'Upload Photo [Step-4]',
              style: TextStyle(
                color: Colors.white,
                fontSize: width * 0.05,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: height * 0.06,
                  left: width * 0.05,
                  right: width * 0.05,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: height * 0.024),
                    Center(
                      child: Text(
                        'Click Divyang Photo',
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
                        'दिव्यांग व्यक्तीचा फोटो काढा',
                        style: TextStyle(
                          fontSize: width * 0.045,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(width * 0.025),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Container(
                        height: height * 0.5,
                        width: width * 0.875,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDF7FD),
                          borderRadius: BorderRadius.circular(width * 0.025),
                          border: Border.all(
                            color: const Color(0xFFF76048),
                            width: 2,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x9B9B9BC1),
                              blurRadius: 10,
                              spreadRadius: 0,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: Center(
                                child: _image == null
                                    ? Container(
                                        width: width * 0.625,
                                        height: width * 0.625,
                                        color: Colors.blueGrey,
                                        child: Center(
                                          child: Text(
                                            'No Image Captured',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: width * 0.04,
                                            ),
                                          ),
                                        ),
                                      )
                                    : Image.file(
                                        _image!,
                                        height: width * 0.625,
                                        width: width * 0.625,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(width * 0.02),
                              child: ElevatedButton(
                                onPressed: _getImage,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF76048),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(width * 0.075),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: width * 0.05,
                                    vertical: height * 0.015,
                                  ),
                                ),
                                child: Text(
                                  "Click Photo\nफोटो काढा",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: width * 0.04,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.05),
                    // SizedBox(height: height * 0.024),
                    if (_image != null)
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _showSubmitPhotoDialog,
                        icon: _isLoading
                            ? SizedBox(
                                width: width * 0.05,
                                height: width * 0.05,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : SizedBox.shrink(),
                        label: Text(
                          _isLoading
                              ? 'Please Wait...\nकृपया प्रतीक्षा करा...'
                              : 'Submit Photo\nफोटो सबमिट करा',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: width * 0.0375,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _isLoading ? Colors.grey : Color(0xFFF76048),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(width * 0.075),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: width * 0.05,
                            vertical: height * 0.024,
                          ),
                          elevation: 5,
                        ),
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

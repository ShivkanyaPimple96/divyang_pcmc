import 'package:divyang_pimpri_chinchwad_municipal_corporation/KYC_Screens/enter_aadhar_number_screen.dart';
import 'package:divyang_pimpri_chinchwad_municipal_corporation/office_login_screens/user_login_screen.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

Future<void> _requestLocationPermission(BuildContext context) async {
  bool serviceEnabled;
  LocationPermission permission;
  // Check if location services are enabled
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Show a dialog to enable location services
    _showEnableLocationDialog(context);
    return;
  }

  // Check permission status
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      _showPermissionDeniedDialog(context);
      return;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    _showPermissionDeniedDialog(context);
    return;
  }

  // If permission granted, proceed to AadharInputScreen
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => EnterAadharNumberScreen()),
  );
}

void _showEnableLocationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        title: const Row(
          children: [
            Icon(Icons.location_on, color: Colors.blue, size: 28),
            SizedBox(width: 10),
            Text(
              'Enable Location',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Divider(thickness: 2.5),
            Text(
              'Location services are disabled. Please enable location to continue.\n'
              'स्थान सेवा अक्षम आहेत. कृपया स्थान सक्षम करा.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            Divider(thickness: 2.5),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            onPressed: () async {
              await Geolocator.openLocationSettings();
              Navigator.of(context).pop();
            },
            child: const Text('Enable'),
          ),
        ],
      );
    },
  );
}

void _showPermissionDeniedDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Location Permission Denied"),
        content: const Text(
            "You have denied location access. Please allow it from app settings."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await openAppSettings();
              Navigator.pop(context);
            },
            child: const Text("Open Settings"),
          ),
        ],
      );
    },
  );
}

class _HomeScreenState extends State<HomeScreen> {
  // final InAppUpdateService _updateService = InAppUpdateService();
  bool _isCheckingUpdate = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleInitialUpdateCheck();
    });
  }

  @override
  void dispose() {
    // _updateService.dispose();
    super.dispose();
  }

  Future<void> _handleInitialUpdateCheck() async {
    if (!mounted) return;

    setState(() {
      _isCheckingUpdate = true;
    });

    try {
      // await _updateService.handleAppUpdate(context);
    } catch (e) {
      debugPrint('Error during initial update check: $e');
      if (mounted) {
        _showSnackBar('Error checking for updates');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingUpdate = false;
        });
      }
    }
  }

  Future<void> _manualUpdateCheck() async {
    if (_isCheckingUpdate) return;

    setState(() {
      _isCheckingUpdate = true;
    });

    try {
      // await _updateService.manualUpdateCheck(context);
    } catch (e) {
      _showSnackBar('Error checking for updates');
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingUpdate = false;
        });
      }
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 3),
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

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top section (40% of screen)
            Expanded(
              flex: 4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.all(
                                width * 0.025), // Responsive padding
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const UserLoginScreen()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.yellow,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'Office Login',
                                style: TextStyle(
                                    fontSize:
                                        width * 0.04, // Responsive font size
                                    color: Colors.black),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed:
                            _isCheckingUpdate ? null : _manualUpdateCheck,
                        icon: _isCheckingUpdate
                            ? SizedBox(
                                width: width * 0.04,
                                height: width * 0.04,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.blue),
                                ),
                              )
                            : const Icon(
                                Icons.refresh,
                                color: Colors.blue,
                              ),
                        tooltip: 'Check for updates',
                      ),
                    ],
                  ),
                  SizedBox(height: height * 0.006),
                  Image.asset(
                    'assets/images/pcmc_logo.jpeg',
                    height: height * 0.18,
                    width: width * 0.5,
                  ),
                  SizedBox(height: height * 0.012),
                  Text(
                    'पिंपरी चिंचवड महानगरपालिका',
                    style: TextStyle(
                      fontSize: width * 0.05,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    "पिंपरी चिंचवड- 411018",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: width * 0.045),
                  ),
                  Text(
                    "(2026-2027)",
                    style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: width * 0.0375),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: height * 0.012,
            ),
            if (_isCheckingUpdate) ...[
              Container(
                padding: EdgeInsets.all(width * 0.04),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: width * 0.025,
                      height: width * 0.025,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    ),
                    SizedBox(width: width * 0.03),
                    Text(
                      'Checking for updates...',
                      style: TextStyle(
                        fontSize: width * 0.0375,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: height * 0.006),
            ],
            Expanded(
              flex: 6,
              child: ClipPath(
                clipper: BottomWaveClipper(),
                child: Container(
                  color: const Color(0xFFF76048),
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: width * 0.05, vertical: height * 0.012),
                      child: Container(
                        padding: EdgeInsets.all(width * 0.0375),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF76048),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(height: height * 0.006),
                            Flexible(
                              child: Text(
                                'Generate Life Certificate\n(जीवन प्रमाणपत्र तैयार करा)',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: width * 0.05,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(height: height * 0.018),
                            ElevatedButton(
                              onPressed: () =>
                                  _requestLocationPermission(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: width * 0.1,
                                    vertical: height * 0.012),
                              ),
                              child: Text(
                                'Click Here\nयेथे क्लिक करा',
                                style: TextStyle(
                                    fontSize: width * 0.04,
                                    color: Colors.black),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: height * 0.01),
                            Flexible(
                              child: Text(
                                "नोट : कृपया दिव्यांग व्यक्तींनी हयातीचा दाखला \nकाढण्याच्या अगोदर त्यांचा आधार मोबाईल \nनंबर सोबत लिंक करावा हि विनंती.",
                                style: TextStyle(
                                    fontSize: width * 0.04,
                                    color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.1);
    path.cubicTo(
      size.width * 0.25,
      size.height * 0.3,
      size.width * 0.75,
      size.height * 0.05,
      size.width,
      size.height * 0.1,
    );
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

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
                      // ElevatedButton(
                      //   onPressed: () => _requestLocationPermission(context),
                      //   style: ElevatedButton.styleFrom(
                      //     backgroundColor: Colors.white,
                      //     foregroundColor: Colors.black,
                      //     shape: RoundedRectangleBorder(
                      //       borderRadius: BorderRadius.circular(0),
                      //     ),
                      //     // padding: const EdgeInsets.symmetric(
                      //     //     horizontal: 40, vertical: 10),
                      //   ),
                      //   child: const Text(
                      //     'Click Here\nयेथे क्लिक करा',
                      //     style: TextStyle(fontSize: 10, color: Colors.black),
                      //     textAlign: TextAlign.center,
                      //   ),
                      // ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
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
                              child: const Text(
                                'Office Login',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // IconButton(
                      //   onPressed: () async {
                      //     await _updateService.openPlayStore(context);
                      //   },
                      //   icon: const Icon(Icons.system_update_alt_outlined,
                      //       color: Colors.green),
                      //   tooltip: 'Open Play Store',
                      // ),
                      IconButton(
                        onPressed:
                            _isCheckingUpdate ? null : _manualUpdateCheck,
                        icon: _isCheckingUpdate
                            ? const SizedBox(
                                width: 15,
                                height: 15,
                                child: CircularProgressIndicator(
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
                  const SizedBox(height: 5),
                  Image.asset(
                    'assets/images/pcmc_logo.jpeg',
                    height: 150,
                    width: 200,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'पिंपरी चिंचवड महानगरपालिका',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const Text(
                    "पिंपरी चिंचवड- 411018",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const Text(
                    "(2026-2027)",
                    style:
                        TextStyle(fontWeight: FontWeight.normal, fontSize: 15),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            if (_isCheckingUpdate) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 10,
                      height: 10,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    ),
                    // const SizedBox(width: 12),
                    Text(
                      'Checking for updates...',
                      style: TextStyle(
                        fontSize: 5,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              // const SizedBox(height: 5),
            ],
            Expanded(
              flex: 6,
              child: ClipPath(
                clipper: BottomWaveClipper(),
                child: Container(
                  color: const Color(0xFFF76048),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF76048),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 5),
                            Flexible(
                              child: Text(
                                'Generate Life Certificate\n(जीवन प्रमाणपत्र तैयार करा)',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),
                            ElevatedButton(
                              onPressed: () =>
                                  _requestLocationPermission(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 10),
                              ),
                              child: const Text(
                                'Click Here\nयेथे क्लिक करा',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Flexible(
                              child: const Text(
                                "नोट : कृपया दिव्यांग व्यक्तींनी हयातीचा दाखला \nकाढण्याच्या अगोदर त्यांचा आधार मोबाईल \nनंबर सोबत लिंक करावा हि विनंती.",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            // const SizedBox(height: 5),
                            // Container(
                            //   padding: const EdgeInsets.all(8),
                            //   child: Text(
                            //     'Tap refresh icon to check for updates',
                            //     style: TextStyle(
                            //       fontSize: 14,
                            //       color: Colors.white,
                            //     ),
                            //     textAlign: TextAlign.center,
                            //   ),
                            // ),
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

// import 'package:divyang_pimpri_chinchwad_municipal_corporation/KYC_Screens/enter_aadhar_number_screen.dart';
// import 'package:divyang_pimpri_chinchwad_municipal_corporation/services/inAppUpdateService.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';

// import 'package:permission_handler/permission_handler.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// Future<void> _requestLocationPermission(BuildContext context) async {
//   bool serviceEnabled;
//   LocationPermission permission;
//   // Check if location services are enabled
//   serviceEnabled = await Geolocator.isLocationServiceEnabled();
//   if (!serviceEnabled) {
//     // Show a dialog to enable location services
//     _showEnableLocationDialog(context);
//     return;
//   }

//   // Check permission status
//   permission = await Geolocator.checkPermission();
//   if (permission == LocationPermission.denied) {
//     permission = await Geolocator.requestPermission();
//     if (permission == LocationPermission.denied) {
//       _showPermissionDeniedDialog(context);
//       return;
//     }
//   }

//   if (permission == LocationPermission.deniedForever) {
//     _showPermissionDeniedDialog(context);
//     return;
//   }

//   // If permission granted, proceed to AadharInputScreen
//   Navigator.push(
//     context,
//     MaterialPageRoute(builder: (context) => EnterAadharNumberScreen()),
//   );
// }

// void _showEnableLocationDialog(BuildContext context) {
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20.0), // Rounded corners
//         ),
//         title: const Row(
//           children: [
//             Icon(Icons.location_on, color: Colors.blue, size: 28), // Icon
//             SizedBox(width: 10),
//             Text(
//               'Enable Location', // Title text
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//           ],
//         ),
//         content: const Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Divider(thickness: 2.5), // Top divider
//             Text(
//               'Location services are disabled. Please enable location to continue.\n'
//               'स्थान सेवा अक्षम आहेत. कृपया स्थान सक्षम करा.',
//               style: TextStyle(fontSize: 16),
//               textAlign: TextAlign.center,
//             ),
//             Divider(thickness: 2.5), // Bottom divider
//           ],
//         ),
//         actions: <Widget>[
//           TextButton(
//             child: const Text('Cancel', style: TextStyle(color: Colors.red)),
//             onPressed: () {
//               Navigator.of(context).pop(); // Close the dialog
//             },
//           ),
//           TextButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.blue, // Button color
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12.0),
//               ),
//             ),
//             onPressed: () async {
//               await Geolocator.openLocationSettings();
//               Navigator.of(context).pop(); // Close the dialog
//             },
//             child: const Text('Enable'),
//           ),
//         ],
//       );
//     },
//   );
// }

// void _showPermissionDeniedDialog(BuildContext context) {
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: const Text("Location Permission Denied"),
//         content: const Text(
//             "You have denied location access. Please allow it from app settings."),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//             },
//             child: const Text("Cancel"),
//           ),
//           TextButton(
//             onPressed: () async {
//               await openAppSettings();
//               Navigator.pop(context);
//             },
//             child: const Text("Open Settings"),
//           ),
//         ],
//       );
//     },
//   );
// }

// class _HomeScreenState extends State<HomeScreen> {
//   final InAppUpdateService _updateService = InAppUpdateService();
//   bool _isCheckingUpdate = false;
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _handleInitialUpdateCheck();
//     });
//     // checkForUpdate();

//     Future.wait([
//       // checkForUpdate(),
//       Future.delayed(const Duration(seconds: 2)),
//     ]).then((_) {
//       // if (mounted) {
//       //   _showInfoPopup(context);
//       // }
//     });
//   }

//   Future<void> _handleInitialUpdateCheck() async {
//     if (!mounted) return;

//     setState(() {
//       _isCheckingUpdate = true;
//     });

//     try {
//       // Use the enhanced update handling
//       await _updateService.handleAppUpdate(context);
//     } catch (e) {
//       debugPrint('Error during initial update check: $e');
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isCheckingUpdate = false;
//         });
//       }
//     }
//   }

//   Future<void> _manualUpdateCheck() async {
//     if (_isCheckingUpdate) return;

//     setState(() {
//       _isCheckingUpdate = true;
//     });

//     try {
//       await _updateService.manualUpdateCheck(context);
//     } catch (e) {
//       _showSnackBar('Error checking for updates: $e');
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isCheckingUpdate = false;
//         });
//       }
//     }
//   }

//   void _showSnackBar(String message) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(message),
//           duration: const Duration(seconds: 3),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (kDebugMode) {
//       // Only show in debug mode
//       Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             ElevatedButton(
//               onPressed: () async {
//                 try {
//                   final updateInfo = await _updateService.checkForUpdate();
//                   if (updateInfo != null) {
//                     print('Update Available: ${updateInfo.updateAvailability}');
//                     print('Install Status: ${updateInfo.installStatus}');
//                     print(
//                         'Available Version Code: ${updateInfo.availableVersionCode}');
//                   } else {
//                     print('No update info or checked recently');
//                   }
//                 } catch (e) {
//                   print('Error: $e');
//                 }
//               },
//               child: Text('Test Check Update'),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 await _updateService.handleAppUpdate(context,
//                     showNoUpdateMessage: true);
//               },
//               child: Text('Test Handle Update'),
//             ),
//           ],
//         ),
//       );
//     }
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Top section (40% of screen)
//             Expanded(
//               flex: 4,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   IconButton(
//                     onPressed: _isCheckingUpdate ? null : _manualUpdateCheck,
//                     icon: _isCheckingUpdate
//                         ? const SizedBox(
//                             width: 20,
//                             height: 20,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               valueColor:
//                                   AlwaysStoppedAnimation<Color>(Colors.blue),
//                             ),
//                           )
//                         : const Row(
//                             mainAxisAlignment: MainAxisAlignment.end,
//                             children: [
//                               Padding(
//                                 padding: EdgeInsets.only(right: 20),
//                                 child: Icon(
//                                   Icons.refresh,
//                                   color: Colors.blue,
//                                 ),
//                               ),
//                             ],
//                           ),
//                     tooltip: 'Check for updates',
//                   ),
//                   SizedBox(
//                     height: 10,
//                   ),
//                   Image.asset(
//                     'assets/images/pcmc_logo.jpeg',
//                     height: 150,
//                     width: 200,
//                   ),
//                   const SizedBox(height: 10),
//                   const Text(
//                     'पिंपरी चिंचवड महानगरपालिका',
//                     style: TextStyle(
//                       fontSize: 22,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black,
//                     ),
//                   ),
//                   const Text(
//                     "पिंपरी चिंचवड- 411018",
//                     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//                   ),
//                   // const Text(
//                   //   "निवृत्ती वेतनधारक हयातीचे प्रमाणपत्र",
//                   //   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//                   // ),
//                   const Text(
//                     "(2026-2027)",
//                     style:
//                         TextStyle(fontWeight: FontWeight.normal, fontSize: 18),
//                   ),
//                 ],
//               ),
//             ),
//             if (_isCheckingUpdate) ...[
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.blue.shade50,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const SizedBox(
//                       width: 20,
//                       height: 20,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2,
//                         valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Text(
//                       'Checking for updates...',
//                       style: TextStyle(
//                         fontSize: 10,
//                         color: Colors.blue.shade700,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(height: 10),
//             ],
//             Expanded(
//               flex: 6,
//               child: ClipPath(
//                 clipper: BottomWaveClipper(),
//                 child: Container(
//                   color: Color(0xFFF76048),
//                   child: Center(
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 20,
//                           vertical: 10), // Reduced vertical padding
//                       child: Container(
//                         padding: const EdgeInsets.all(15),
//                         decoration: BoxDecoration(
//                           color: const Color(0xFFF76048),
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             const SizedBox(height: 5), // Reduced height
//                             Flexible(
//                               // Added Flexible for text
//                               child: Text(
//                                 'Generate Life Certificate\n(जीवन प्रमाणपत्र तैयार करा)',
//                                 textAlign: TextAlign.center,
//                                 style: TextStyle(
//                                   fontSize: 20, // Reduced font size
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(height: 15), // Reduced height
//                             ElevatedButton(
//                               onPressed: () =>
//                                   _requestLocationPermission(context),
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.white,
//                                 foregroundColor: Colors.black,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(30),
//                                 ),
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 40, vertical: 10),
//                               ),
//                               child: const Text(
//                                 'Click Here\nयेथे क्लिक करा',
//                                 style: TextStyle(
//                                     fontSize: 16, color: Colors.black),
//                                 textAlign: TextAlign.center,
//                               ),
//                             ),
//                             const SizedBox(height: 15), // Reduced height
//                             Flexible(
//                               // Added Flexible for long text
//                               child: const Text(
//                                 "नोट : कृपया दिव्यांग व्यक्तींनी हयातीचा दाखला \nकाढण्याच्या अगोदर त्यांचा आधार मोबाईल \nनंबर सोबत लिंक करावा हि विनंती.",
//                                 style: TextStyle(
//                                     fontSize: 16,
//                                     color: Colors.white), // Reduced font size
//                                 textAlign: TextAlign.center,
//                               ),
//                             ),
//                             const SizedBox(height: 5), // Reduced height

//                             Container(
//                               padding: const EdgeInsets.all(8),
//                               child: Text(
//                                 'Tap refresh icon to check for updates',
//                                 style: TextStyle(
//                                   fontSize: 10,
//                                   color: Colors.white,
//                                 ),
//                                 textAlign: TextAlign.center,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class BottomWaveClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     final path = Path();
//     // Move to starting point on the left edge, higher up
//     path.lineTo(0, size.height * 0.1); // increased from 0.3

//     // Create a deeper wave
//     path.cubicTo(
//       size.width * 0.25,
//       size.height * 0.3, // increased from 0.15
//       size.width * 0.75,
//       size.height * 0.05, // increased from 0.45
//       size.width,
//       size.height * 0.1, // increased from 0.3
//     );

//     path.lineTo(size.width, 0);
//     path.lineTo(size.width, size.height);
//     path.lineTo(0, size.height);
//     path.close();
//     return path;
//   }

//   @override
//   bool shouldReclip(CustomClipper<Path> oldClipper) => false;
// }

// import 'package:divyang_pimpri_chinchwad_municipal_corporation/KYC_Screens/enter_aadhar_number_screen.dart';
// import 'package:divyang_pimpri_chinchwad_municipal_corporation/services/inAppUpdateService.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';

// import 'package:permission_handler/permission_handler.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// Future<void> _requestLocationPermission(BuildContext context) async {
//   bool serviceEnabled;
//   LocationPermission permission;
//   // Check if location services are enabled
//   serviceEnabled = await Geolocator.isLocationServiceEnabled();
//   if (!serviceEnabled) {
//     // Show a dialog to enable location services
//     _showEnableLocationDialog(context);
//     return;
//   }

//   // Check permission status
//   permission = await Geolocator.checkPermission();
//   if (permission == LocationPermission.denied) {
//     permission = await Geolocator.requestPermission();
//     if (permission == LocationPermission.denied) {
//       _showPermissionDeniedDialog(context);
//       return;
//     }
//   }

//   if (permission == LocationPermission.deniedForever) {
//     _showPermissionDeniedDialog(context);
//     return;
//   }

//   // If permission granted, proceed to AadharInputScreen
//   Navigator.push(
//     context,
//     MaterialPageRoute(builder: (context) => EnterAadharNumberScreen()),
//   );
// }

// void _showEnableLocationDialog(BuildContext context) {
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20.0), // Rounded corners
//         ),
//         title: const Row(
//           children: [
//             Icon(Icons.location_on, color: Colors.blue, size: 28), // Icon
//             SizedBox(width: 10),
//             Text(
//               'Enable Location', // Title text
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//           ],
//         ),
//         content: const Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Divider(thickness: 2.5), // Top divider
//             Text(
//               'Location services are disabled. Please enable location to continue.\n'
//               'स्थान सेवा अक्षम आहेत. कृपया स्थान सक्षम करा.',
//               style: TextStyle(fontSize: 16),
//               textAlign: TextAlign.center,
//             ),
//             Divider(thickness: 2.5), // Bottom divider
//           ],
//         ),
//         actions: <Widget>[
//           TextButton(
//             child: const Text('Cancel', style: TextStyle(color: Colors.red)),
//             onPressed: () {
//               Navigator.of(context).pop(); // Close the dialog
//             },
//           ),
//           TextButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.blue, // Button color
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12.0),
//               ),
//             ),
//             onPressed: () async {
//               await Geolocator.openLocationSettings();
//               Navigator.of(context).pop(); // Close the dialog
//             },
//             child: const Text('Enable'),
//           ),
//         ],
//       );
//     },
//   );
// }

// void _showPermissionDeniedDialog(BuildContext context) {
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: const Text("Location Permission Denied"),
//         content: const Text(
//             "You have denied location access. Please allow it from app settings."),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//             },
//             child: const Text("Cancel"),
//           ),
//           TextButton(
//             onPressed: () async {
//               await openAppSettings();
//               Navigator.pop(context);
//             },
//             child: const Text("Open Settings"),
//           ),
//         ],
//       );
//     },
//   );
// }

// class _HomeScreenState extends State<HomeScreen> {
//   final InAppUpdateService _updateService = InAppUpdateService();
//   bool _isCheckingUpdate = false;
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _handleInitialUpdateCheck();
//     });
//     // checkForUpdate();

//     Future.wait([
//       // checkForUpdate(),
//       Future.delayed(const Duration(seconds: 2)),
//     ]).then((_) {
//       // if (mounted) {
//       //   _showInfoPopup(context);
//       // }
//     });
//   }

//   Future<void> _handleInitialUpdateCheck() async {
//     if (!mounted) return;

//     setState(() {
//       _isCheckingUpdate = true;
//     });

//     try {
//       // Use the enhanced update handling
//       await _updateService.handleAppUpdate(context);
//     } catch (e) {
//       debugPrint('Error during initial update check: $e');
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isCheckingUpdate = false;
//         });
//       }
//     }
//   }

//   Future<void> _manualUpdateCheck() async {
//     if (_isCheckingUpdate) return;

//     setState(() {
//       _isCheckingUpdate = true;
//     });

//     try {
//       await _updateService.manualUpdateCheck(context);
//     } catch (e) {
//       _showSnackBar('Error checking for updates: $e');
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isCheckingUpdate = false;
//         });
//       }
//     }
//   }

//   void _showSnackBar(String message) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(message),
//           duration: const Duration(seconds: 3),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (kDebugMode) {
//       // Only show in debug mode
//       Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             ElevatedButton(
//               onPressed: () async {
//                 try {
//                   final updateInfo = await _updateService.checkForUpdate();
//                   if (updateInfo != null) {
//                     print('Update Available: ${updateInfo.updateAvailability}');
//                     print('Install Status: ${updateInfo.installStatus}');
//                     print(
//                         'Available Version Code: ${updateInfo.availableVersionCode}');
//                   } else {
//                     print('No update info or checked recently');
//                   }
//                 } catch (e) {
//                   print('Error: $e');
//                 }
//               },
//               child: Text('Test Check Update'),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 await _updateService.handleAppUpdate(context,
//                     showNoUpdateMessage: true);
//               },
//               child: Text('Test Handle Update'),
//             ),
//           ],
//         ),
//       );
//     }
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Top section (40% of screen)
//             Expanded(
//               flex: 4,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   IconButton(
//                     onPressed: _isCheckingUpdate ? null : _manualUpdateCheck,
//                     icon: _isCheckingUpdate
//                         ? const SizedBox(
//                             width: 20,
//                             height: 20,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               valueColor:
//                                   AlwaysStoppedAnimation<Color>(Colors.blue),
//                             ),
//                           )
//                         : const Row(
//                             mainAxisAlignment: MainAxisAlignment.end,
//                             children: [
//                               Padding(
//                                 padding: EdgeInsets.only(right: 20),
//                                 child: Icon(
//                                   Icons.refresh,
//                                   color: Colors.blue,
//                                 ),
//                               ),
//                             ],
//                           ),
//                     tooltip: 'Check for updates',
//                   ),
//                   SizedBox(
//                     height: 10,
//                   ),
//                   Image.asset(
//                     'assets/images/pcmc_logo.jpeg',
//                     height: 150,
//                     width: 200,
//                   ),
//                   const SizedBox(height: 10),
//                   const Text(
//                     'पिंपरी चिंचवड महानगरपालिका',
//                     style: TextStyle(
//                       fontSize: 22,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black,
//                     ),
//                   ),
//                   const Text(
//                     "पिंपरी चिंचवड- 411018",
//                     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//                   ),
//                   // const Text(
//                   //   "निवृत्ती वेतनधारक हयातीचे प्रमाणपत्र",
//                   //   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//                   // ),
//                   const Text(
//                     "(2026-2027)",
//                     style:
//                         TextStyle(fontWeight: FontWeight.normal, fontSize: 18),
//                   ),
//                 ],
//               ),
//             ),
//             if (_isCheckingUpdate) ...[
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.blue.shade50,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const SizedBox(
//                       width: 20,
//                       height: 20,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2,
//                         valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Text(
//                       'Checking for updates...',
//                       style: TextStyle(
//                         fontSize: 10,
//                         color: Colors.blue.shade700,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(height: 10),
//             ],
//             Expanded(
//               flex: 6,
//               child: ClipPath(
//                 clipper: BottomWaveClipper(),
//                 child: Container(
//                   color: Color(0xFFF76048),
//                   child: Center(
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 20,
//                           vertical: 10), // Reduced vertical padding
//                       child: Container(
//                         padding: const EdgeInsets.all(15),
//                         decoration: BoxDecoration(
//                           color: const Color(0xFFF76048),
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             const SizedBox(height: 5), // Reduced height
//                             Flexible(
//                               // Added Flexible for text
//                               child: Text(
//                                 'Generate Life Certificate\n(जीवन प्रमाणपत्र तैयार करा)',
//                                 textAlign: TextAlign.center,
//                                 style: TextStyle(
//                                   fontSize: 20, // Reduced font size
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(height: 15), // Reduced height
//                             ElevatedButton(
//                               onPressed: () =>
//                                   _requestLocationPermission(context),
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.white,
//                                 foregroundColor: Colors.black,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(30),
//                                 ),
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 40, vertical: 10),
//                               ),
//                               child: const Text(
//                                 'Click Here\nयेथे क्लिक करा',
//                                 style: TextStyle(
//                                     fontSize: 16, color: Colors.black),
//                                 textAlign: TextAlign.center,
//                               ),
//                             ),
//                             const SizedBox(height: 15), // Reduced height
//                             Flexible(
//                               // Added Flexible for long text
//                               child: const Text(
//                                 "नोट : कृपया दिव्यांग व्यक्तींनी हयातीचा दाखला \nकाढण्याच्या अगोदर त्यांचा आधार मोबाईल \nनंबर सोबत लिंक करावा हि विनंती.",
//                                 style: TextStyle(
//                                     fontSize: 16,
//                                     color: Colors.white), // Reduced font size
//                                 textAlign: TextAlign.center,
//                               ),
//                             ),
//                             const SizedBox(height: 5), // Reduced height

//                             Container(
//                               padding: const EdgeInsets.all(8),
//                               child: Text(
//                                 'Tap refresh icon to check for updates',
//                                 style: TextStyle(
//                                   fontSize: 10,
//                                   color: Colors.white,
//                                 ),
//                                 textAlign: TextAlign.center,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class BottomWaveClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     final path = Path();
//     // Move to starting point on the left edge, higher up
//     path.lineTo(0, size.height * 0.1); // increased from 0.3

//     // Create a deeper wave
//     path.cubicTo(
//       size.width * 0.25,
//       size.height * 0.3, // increased from 0.15
//       size.width * 0.75,
//       size.height * 0.05, // increased from 0.45
//       size.width,
//       size.height * 0.1, // increased from 0.3
//     );

//     path.lineTo(size.width, 0);
//     path.lineTo(size.width, size.height);
//     path.lineTo(0, size.height);
//     path.close();
//     return path;
//   }

//   @override
//   bool shouldReclip(CustomClipper<Path> oldClipper) => false;
// }

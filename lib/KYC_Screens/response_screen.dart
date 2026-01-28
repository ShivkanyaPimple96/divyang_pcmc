import 'dart:convert';
import 'package:divyang_pimpri_chinchwad_municipal_corporation/KYC_Screens/divyang_detailes_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class ResponseScreen extends StatelessWidget {
  final String aadhaarNumber;
  final String mobileNumber;
  final String addressEnter;
  final String gender;
  final String fullName;
  final String message;
  final bool success;
  final String verificationStatus;
  final String udidNumber;
  final String disabilityType;
  final String disabilityPercentage;

  const ResponseScreen({
    super.key,
    required this.message,
    required this.success,
    required this.mobileNumber,
    required this.addressEnter,
    required this.gender,
    required this.fullName,
    required this.verificationStatus,
    required this.aadhaarNumber,
    required this.udidNumber,
    required this.disabilityType,
    required this.disabilityPercentage,
  });

  Future<void> _fetchUserDataAndNavigate(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      // Make API call
      final response = await http.get(
        Uri.parse(
            'https://divyangpcmc.altwise.in/api/aadhar/GetDataUsingAadhaarNumber?AadhaarNumber=$aadhaarNumber'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      // Remove loading indicator
      Navigator.of(context).pop();

      print('API Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['success'] == true && responseData['data'] != null) {
          final userData = responseData['data'];

          // Extract data from response
          String fetchedAadhaarNumber =
              userData['AadhaarNumber'] ?? aadhaarNumber;
          String fetchedAddress = userData['Address'] ?? addressEnter;
          String fetchedGender = userData['Gender'] ?? gender;
          String fetchedVerificationStatus =
              userData['VerificationStatus'] ?? verificationStatus;
          String fetchedFullName = userData['Name'] ?? fullName;
          String fetchedUniqueKey = userData['uniqueKey'] ?? fullName;
          String fetchedUDIDNumber = userData['UDIDNumber'] ?? udidNumber;
          String fetchedMobileNumber = userData['MobileNo'] ?? mobileNumber;
          String fetchedUrl = userData['avakNo'] ?? '';

          // Navigate to DivyangDetailesScreen
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => DivyangDetailesScreen(
                aadharNumber: fetchedAadhaarNumber,
                mobileNumber: fetchedMobileNumber,
                fullName: fetchedFullName,
                url: fetchedUrl,
                uniqueKey: fetchedUniqueKey,
                aadhaarNumber: fetchedAadhaarNumber,
                gender: fetchedGender,
                addresss: fetchedAddress,
                udidNumber: fetchedUDIDNumber,
                disabilityType: disabilityType,
                verificationStatus: fetchedVerificationStatus,
              ),
            ),
            (Route<dynamic> route) => false,
          );
        } else {
          Fluttertoast.showToast(
            msg: responseData['message'] ?? 'Failed to fetch data',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
      } else {
        Fluttertoast.showToast(
          msg: 'Failed to fetch user data. Status code: ${response.statusCode}',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      // Remove loading indicator if still showing
      Navigator.of(context, rootNavigator: true).pop();

      print('Error fetching data: $e');
      Fluttertoast.showToast(
        msg:
            'Error: Please check your internet connection\nकृपया तुमचे इंटरनेट कनेक्शन तपासा.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
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
        body: Center(
          child: Container(
            width: width * 0.85,
            padding: EdgeInsets.all(width * 0.04),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFF92B7F7),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      success
                          ? Icons.check_circle_outline
                          : Icons.error_outline,
                      color: success ? Colors.green : Colors.red,
                      size: width * 0.07,
                    ),
                    SizedBox(width: width * 0.025),
                    Text(
                      success ? 'Success' : 'Error',
                      style: TextStyle(
                        fontSize: width * 0.05,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: height * 0.012),
                const Divider(thickness: 2.5),
                SizedBox(height: height * 0.012),
                Text(
                  message,
                  style: TextStyle(fontSize: width * 0.04),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: height * 0.012),
                const Divider(thickness: 2.5),
                SizedBox(height: height * 0.012),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(width: width * 0.025),
                    ElevatedButton(
                      onPressed: () {
                        _fetchUserDataAndNavigate(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: success ? Colors.green : Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: width * 0.08,
                          vertical: height * 0.015,
                        ),
                      ),
                      child: Text(
                        "OK",
                        style: TextStyle(
                          fontSize: width * 0.04,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// import 'package:divyang_pimpri_chinchwad_municipal_corporation/KYC_Screens/divyang_detailes_screen.dart';
// import 'package:flutter/material.dart';

// class ResponseScreen extends StatelessWidget {
//   // final String ppoNumber;
//   final String aadhaarNumber;
//   final String mobileNumber;
//   final String addressEnter;
//   final String gender;
//   final String fullName;
//   final String message;
//   final bool success;
//   final String verificationStatus;
//   final String udidNumber;
//   final String disabilityType;
//   final String disabilityPercentage;

//   const ResponseScreen(
//       {super.key,
//       required this.message,
//       required this.success,
//       // required this.ppoNumber,
//       required this.mobileNumber,
//       required this.addressEnter,
//       required this.gender,
//       required this.fullName,
//       required this.verificationStatus,
//       required this.aadhaarNumber,
//       required this.udidNumber,
//       required this.disabilityType,
//       required this.disabilityPercentage});

//   @override
//   Widget build(BuildContext context) {
//     // Get screen dimensions
//     final size = MediaQuery.of(context).size;
//     final width = size.width;
//     final height = size.height;

//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: Colors.white, // Dim background like a dialog effect
//         body: Center(
//           child: Container(
//             width: width * 0.85, // Dialog width (85% of screen)
//             padding: EdgeInsets.all(width * 0.04),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(20.0), // Rounded corners
//               boxShadow: const [
//                 BoxShadow(
//                   color: Color(0xFF92B7F7),
//                   blurRadius: 10,
//                   spreadRadius: 2,
//                 ),
//               ],
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       success
//                           ? Icons.check_circle_outline
//                           : Icons.error_outline,
//                       color: success ? Colors.green : Colors.red,
//                       size: width * 0.07, // Responsive icon size
//                     ),
//                     SizedBox(width: width * 0.025),
//                     Text(
//                       success ? 'Success' : 'Error',
//                       style: TextStyle(
//                         fontSize: width * 0.05,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: height * 0.012),
//                 const Divider(thickness: 2.5),
//                 SizedBox(height: height * 0.012),
//                 Text(
//                   message,
//                   style: TextStyle(fontSize: width * 0.04),
//                   textAlign: TextAlign.center,
//                 ),
//                 SizedBox(height: height * 0.012),
//                 const Divider(thickness: 2.5),
//                 SizedBox(height: height * 0.012),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     SizedBox(width: width * 0.025),
//                     ElevatedButton(
//                       onPressed: () {
//                         Navigator.pushAndRemoveUntil(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => DivyangDetailesScreen(
//                               aadharNumber: aadhaarNumber,
//                               mobileNumber: mobileNumber,
//                               fullName: fullName,
//                               url: "",
//                               aadhaarNumber: '',
//                               gender: gender,
//                               addresss: addressEnter,
//                               verificationStatus: verificationStatus,
//                             ),
//                           ),
//                           (Route<dynamic> route) => false,
//                         );
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: success ? Colors.green : Colors.red,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12.0),
//                         ),
//                         padding: EdgeInsets.symmetric(
//                           horizontal: width * 0.08,
//                           vertical: height * 0.015,
//                         ),
//                       ),
//                       child: Text(
//                         "OK",
//                         style: TextStyle(
//                           fontSize: width * 0.04,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

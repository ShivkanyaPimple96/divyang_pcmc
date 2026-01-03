import 'package:divyang_pimpri_chinchwad_municipal_corporation/KYC_Screens/divyang_detailes_screen.dart';
import 'package:flutter/material.dart';

class ResponseScreen extends StatelessWidget {
  // final String ppoNumber;
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

  const ResponseScreen(
      {super.key,
      required this.message,
      required this.success,
      // required this.ppoNumber,
      required this.mobileNumber,
      required this.addressEnter,
      required this.gender,
      required this.fullName,
      required this.verificationStatus,
      required this.aadhaarNumber,
      required this.udidNumber,
      required this.disabilityType,
      required this.disabilityPercentage});

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white, // Dim background like a dialog effect
        body: Center(
          child: Container(
            width: width * 0.85, // Dialog width (85% of screen)
            padding: EdgeInsets.all(width * 0.04),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0), // Rounded corners
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
                      size: width * 0.07, // Responsive icon size
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
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DivyangDetailesScreen(
                              aadharNumber: aadhaarNumber,
                              mobileNumber: mobileNumber,
                              fullName: fullName,
                              url: "",
                              aadhaarNumber: '',
                              gender: gender,
                              addresss: addressEnter,
                              verificationStatus: verificationStatus,
                            ),
                          ),
                          (Route<dynamic> route) => false,
                        );
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

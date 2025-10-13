import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:marvis_auth/marvis_auth_method_channel.dart';
import 'package:provider/provider.dart';

import '../enums/DeviceDetection.dart';
import '../helper/CommonWidget.dart';
import '../helper/Constants.dart';
import '../helper/DeviceInfo.dart';
import '../helper/SharePreferenceHelper.dart';
import '../provider/DeviceInfoProvider.dart';
import 'helper/BottomNavigationDialogListener.dart';

class Capturepage extends StatefulWidget {
  final String title;
  final DeviceInfo? deviceInfoObject;
  final String imageFormatType;
  final int timeout;
  final int minQuality;

  const Capturepage({
    Key? key,
    required this.title,
    this.deviceInfoObject,
    this.imageFormatType = "BMP",
    this.timeout = 10000,
    this.minQuality = 60,
  }) : super(key: key);

  @override
  CapturepageState createState() => CapturepageState();
}

enum ScannerAction { Capture, MatchIRIS }

class CapturepageState extends State<Capturepage>
    implements BottomDialogRefreshListener {
  String deviceInfo = "Device Status: ";
  MethodChannel channel = const MethodChannel('PassedCallBack');

  static const String METHOD_PREVIEW = "preview";
  static const String METHOD_COMPLETE = "complete";
  final FocusNode _focusNode = FocusNode();
  bool isAutoCapture = false;
  ScannerAction scannerAction = ScannerAction.MatchIRIS;

  String messsageText = "";
  bool isMessageError = false;

  int displayImage = 0;
  late Uint8List byteImage;
  late Uint8List lastCapIrisData;

  late String imageFormatType;
  late int timeout;
  late int minQuality;
  late SharePreferenceHelper sharePreferenceHelper;
  DeviceInfo? deviceInfoObject;
  int BmpHeaderlength = 1078;

  @override
  void initState() {
    super.initState();

    // Initialize from widget parameters
    deviceInfoObject = widget.deviceInfoObject;
    imageFormatType = widget.imageFormatType;
    timeout = widget.timeout;
    minQuality = widget.minQuality;

    sharePreferenceHelper = SharePreferenceHelper();
    callBackRegister();
    displayImage = 0;

    // Get device status
    getDeviceStatusInfo();

    setLogs("Image saved successfully. You can now match iris data.", false);
  }

  String getDeviceStatusInfo() {
    String deviceName = Provider.of<DeviceInfoProvider>(context, listen: false)
        .deviceNameStatus;
    if (deviceName != "") {
      deviceInfo = deviceName;
    }
    return deviceInfo;
  }

  void callBackRegister() {
    channel.setMethodCallHandler((call) async {
      if (call.method == 'Device_Detection') {
        final splitNames = call.arguments.split(',');
        String deviceName = splitNames[0];
        String detection = splitNames[1];
        connectDisConnectView(deviceName, detection);
      } else if (call.method == METHOD_PREVIEW) {
        List<String> value = call.arguments.toString().split(",");
        int ErrorCode = int.parse(value[0]);
        String byte = value[2];

        Uint8List Image = Constants.convertBase64StringToByteArray(byte);
        try {
          if (ErrorCode == 0 && byte.isNotEmpty && Image != null) {
            setState(() {
              displayImage = 2;
              byteImage = Image;
            });
          } else {
            String Error =
                "Preview Error Code: $ErrorCode (${await MethodChannelMarvisAuth.GetErrorMessage(ErrorCode)})";
            setLogs(Error, true);
          }
        } catch (e) {
          print(e.toString());
        }
      } else if (call.method == METHOD_COMPLETE) {
        List<String> value = call.arguments.toString().split(",");
        int ErrorCode = int.parse(value[0]);
        int Quality = int.parse(value[1]);
        String byte = value[2];

        try {
          if (ErrorCode == 0) {
            String log = "Capture Success";
            String quality = "Quality: $Quality";
            setLogs("$log $quality", false);

            if (scannerAction == ScannerAction.MatchIRIS) {
              // For match iris, we proceed to matching
              matchData();
            }
          } else {
            setState(() {
              displayImage = 0;
            });
            String error =
                "CaptureComplete: $ErrorCode (${await MethodChannelMarvisAuth.GetErrorMessage(ErrorCode)})";
            setLogs(error, true);
          }
        } catch (e) {
          print(e.toString());
        }
      }
      return Future.value("");
    });
  }

  void connectDisConnectView(String deviceName, String detection) {
    String device = "";
    if (DeviceDetection.CONNECTED.name == detection) {
      setLogs("Device connected", false);
      Provider.of<DeviceInfoProvider>(context, listen: false)
          .setDeviceConnectedStatus(true);
      device = "Device Status: Connected - $deviceName";
      Provider.of<DeviceInfoProvider>(context, listen: false)
          .setDeviceNameStatus(device);
      Provider.of<DeviceInfoProvider>(context, listen: false)
          .setDeviceName(deviceName);
    } else {
      setLogs("Device Not Connected", true);
      sharePreferenceHelper.setDeviceInfo("");
      Provider.of<DeviceInfoProvider>(context, listen: false)
          .setDeviceConnectedStatus(false);
      device = "Device Status: Device Not Connected";
      Provider.of<DeviceInfoProvider>(context, listen: false)
          .setDeviceNameStatus(device);
      Provider.of<DeviceInfoProvider>(context, listen: false)
          .setDeviceName(deviceName);
      Navigator.pop(context);
    }
    setState(() {
      deviceInfo = device;
    });
  }

  @override
  void didChangeDependencies() {
    getDeviceStatusInfo();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<DeviceInfoProvider>(context, listen: false)
        .setDeviceNameStatus(deviceInfo);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Iris Preview Section
            Text(
              'Iris Preview',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12.0),

            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: getCardView(),
              ),
            ),

            const SizedBox(height: 24.0),

            // Available Operations Section
            // Text(
            //   'Available Operations',
            //   style: Theme.of(context).textTheme.titleLarge?.copyWith(
            //         fontWeight: FontWeight.bold,
            //       ),
            // ),
            // const SizedBox(height: 12.0),

            // Navigation Widget
            // ElevatedButton(
            //   onPressed: () {
            //     CommonWidget.getBottomNavigationWidget(
            //         context, deviceInfo, this);
            //   },
            //   child: Padding(
            //     padding: const EdgeInsets.all(8.0),
            //     child: Text('Show Navigation Widget'),
            //   ),
            //   style: ElevatedButton.styleFrom(
            //     elevation: 2, // Similar to the Card's elevation
            //   ),
            // ),

            const SizedBox(height: 16.0),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => StopCapture(),
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop Capture'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      CommonWidget.showLoaderDialog(
                          context, 'Please put eye on scanner');
                      Future.delayed(const Duration(milliseconds: 200), () {
                        MatchIris();
                      });
                    },
                    icon: const Icon(
                      Icons.fingerprint,
                      color: Colors.white,
                    ),
                    label: const Text('Match Iris'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16.0),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CommonWidget.getBottomNavigationWidget(
                    context, deviceInfo, this),
              ),
            ),
            // ElevatedButton(
            //   onPressed: () {
            //     CommonWidget.getBottomNavigationWidget(
            //         context, deviceInfo, this);
            //   },
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: Colors.blue[600],
            //     foregroundColor: Colors.white,
            //     padding: const EdgeInsets.symmetric(vertical: 12),
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(8),
            //     ),
            //   ),
            //   child: Padding(
            //     padding: const EdgeInsets.all(8.0),
            //     child: Text('Start Scanner Device',
            //         style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            //               color: Colors.white,
            //               fontWeight: FontWeight.bold,
            //             )),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
  // Widget build(BuildContext context) {
  //   Provider.of<DeviceInfoProvider>(context, listen: false)
  //       .setDeviceNameStatus(deviceInfo);
  //   return Scaffold(
  //     resizeToAvoidBottomInset: true,
  //     appBar: AppBar(
  //       title: Text(widget.title),
  //       backgroundColor: Colors.blue,
  //     ),
  //     // bottomNavigationBar:
  //     //     CommonWidget.getBottomNavigationWidget(context, deviceInfo, this),
  //     body: Padding(
  //       padding: const EdgeInsets.all(10.0),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.stretch,
  //         children: [
  //           const Text(
  //             'Iris Preview',
  //             style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  //           ),

  //           Expanded(
  //             child: Row(
  //               children: <Widget>[
  //                 Expanded(
  //                   child: getCardView(),
  //                 )
  //               ],
  //             ),
  //           ),
  //           // Success message

  //           // Operations section
  //           const Text(
  //             'Available Operations',
  //             style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  //           ),
  //           const SizedBox(height: 8.0),
  //           CommonWidget.getBottomNavigationWidget(context, deviceInfo, this),
  //           const SizedBox(height: 8.0),

  //           _buildButtonRow(
  //             'Stop Capture',
  //             () => StopCapture(),
  //             'Match Iris',
  //             () {
  //               CommonWidget.showLoaderDialog(
  //                   context, 'Please put eye on scanner');
  //               Future.delayed(const Duration(milliseconds: 200), () {
  //                 MatchIris();
  //               });
  //             },
  //           ),

  //           const SizedBox(height: 15.0),

  //           // Back to capture button
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildButtonRow(String buttonText1, VoidCallback onPressed1,
      String buttonText2, VoidCallback onPressed2) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
            child: ElevatedButton(
          onPressed: onPressed1,
          child: Text(buttonText1),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[400],
          ),
        )),
        const SizedBox(width: 16),
        Expanded(
            child: ElevatedButton(
          onPressed: () {
            FocusScope.of(context).requestFocus(_focusNode);
            Future.delayed(
              const Duration(milliseconds: 200),
              onPressed2,
            );
          },
          child: Text(buttonText2),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[600],
          ),
        )),
      ],
    );
  }

  Widget getCardView() {
    return SizedBox(
      height: 300,
      child: Card(
        elevation: 5,
        borderOnForeground: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0),
          side: const BorderSide(color: Colors.grey, width: 3.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: getCaptureWidget()),
        ),
      ),
    );
  }

  List<Widget> getCaptureWidget() {
    return <Widget>[
      Container(
          margin: const EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 0.0),
          child: Text(
            messsageText,
            style: TextStyle(
              color: isMessageError ? Colors.red : Colors.blue,
            ),
          )),
      onImageDynamic(),
    ];
  }

  Widget onImageDynamic() {
    if (displayImage == 0 || displayImage == 1) {
      return Container(
        padding: const EdgeInsets.all(0),
        child: Icon(
          Icons.remove_red_eye_outlined,
          size: 80,
          color: Colors.yellow[700],
        ),
      );
    } else if (displayImage == 2) {
      return Image.memory(byteImage, width: 200.0, height: 200.0);
    } else {
      return Container(
        padding: const EdgeInsets.all(0),
        child: Icon(
          Icons.remove_red_eye_outlined,
          size: 80,
          color: Colors.yellow[700],
        ),
      );
    }
  }

  // Capture functionality methods
  Future<void> StopCapture() async {
    try {
      int ret = await MethodChannelMarvisAuth.StopCapture();
      String error = await MethodChannelMarvisAuth.GetErrorMessage(ret);
      setLogs("StopCapture: $ret ($error)", false);
    } catch (e) {
      setLogs("Error", true);
    }
  }

  void setLogs(String errorMessage, bool isError) {
    setState(() {
      messsageText = errorMessage;
      if (isError) {
        isMessageError = true;
        print("Error====>$errorMessage");
      } else {
        isMessageError = false;
        print("Message====>$errorMessage");
      }
    });
  }

  void MatchIris() {
    if (deviceInfoObject == null) {
      setLogs("Please run device init first", true);
      Navigator.pop(context);
      return;
    }
    displayBlankData();
    scannerAction = ScannerAction.MatchIRIS;
    StartSyncCapture();
  }

  Future<void> displayBlankData() async {
    setLogs("", false);
    setState(() {
      displayImage = 0;
      setLogs("Matching Started", false);
    });
  }

  Future<void> StartSyncCapture() async {
    try {
      List<int> qty = [];
      int iRisX = 0;
      int iRisY = 0;
      int iRisZ = 0;

      int ret = await MethodChannelMarvisAuth.AutoCapture(
          timeout, qty, iRisX, iRisY, iRisZ);

      if (ret != -1) {
        if (ret != 0) {
          setState(() {
            displayImage = 0;
          });
          String error = await MethodChannelMarvisAuth.GetErrorMessage(ret);
          setLogs("Start Sync Capture Ret: $ret ($error)", true);
          Navigator.pop(context);
        } else {
          Navigator.pop(context);
          int quality = await MethodChannelMarvisAuth.GetQualityElement();
          setLogs("Capture Success  Quality: $quality", false);

          if (scannerAction == ScannerAction.MatchIRIS) {
            matchData(); // For MatchIRIS action
          }
        }
      }
    } catch (e) {
      setLogs("Error", true);
    }
  }

  Future<void> matchData() async {
    try {
      if (scannerAction == ScannerAction.MatchIRIS) {
        // Get the newly captured iris data
        int? width = deviceInfoObject?.Width;
        int? Height = deviceInfoObject?.Height;
        int bmpHeaderLength = BmpHeaderlength;
        int size = (width! * Height!) + bmpHeaderLength;
        Uint8List bImage = Uint8List(size);

        int ret = await MethodChannelMarvisAuth.GetImage(
            bImage, size, 0, imageFormatType);

        if (ret == 0) {
          // Get the current captured image as base64
          String currentCaptureBase64 =
              await MethodChannelMarvisAuth.GetImageBase64();
          print("Current Capture Base64 Image Data: $currentCaptureBase64");

          // Get stored iris data from API
          String? storedIrisData =
              await getStoredIrisDataFromAPI("615735525318");

          if (storedIrisData != null) {
            // Compare the iris data
            await compareIrisData(currentCaptureBase64, storedIrisData);
          } else {
            setLogs("Failed to retrieve stored iris data", true);
          }
        } else {
          setLogs(
              "Error getting current image: $ret(${await MethodChannelMarvisAuth.GetErrorMessage(ret)})",
              true);
        }
      }
    } catch (e) {
      print("matchData error: $e");
      setLogs("Error during iris matching", true);
    }
  }

  Future<String?> getStoredIrisDataFromAPI(String aadhaarNumber) async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://divyangpcmc.altwise.in/api/aadhar/GetIrisData?aadhaarNumber=$aadhaarNumber'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['Success'] == true &&
            responseData['Data'] != null &&
            responseData['Data']['IrisData'] != null) {
          String storedIrisData = responseData['Data']['IrisData'];
          print("Retrieved stored iris data from API");
          setLogs("Stored iris data retrieved successfully", false);
          return storedIrisData;
        } else {
          setLogs("No iris data found for this Aadhaar number", true);
          print("API Response: ${response.body}");
          return null;
        }
      } else {
        setLogs("API Error: ${response.statusCode}", true);
        print("API Error Response: ${response.body}");
        return null;
      }
    } catch (e) {
      setLogs("Error retrieving iris data from API", true);
      print("Exception occurred while getting iris data: $e");
      return null;
    }
  }

  Future<void> compareIrisData(
      String currentCaptureBase64, String storedIrisData) async {
    try {
      // Convert both iris data to Uint8List for comparison
      Uint8List currentCaptureBytes =
          Constants.convertBase64StringToByteArray(currentCaptureBase64);
      Uint8List storedIrisBytes;

      // Check if stored iris data is base64 encoded or plain text
      try {
        storedIrisBytes =
            Constants.convertBase64StringToByteArray(storedIrisData);
      } catch (e) {
        print("Stored iris data is not base64 encoded: $storedIrisData");

        // Simple string comparison
        if (currentCaptureBase64 == storedIrisData) {
          setLogs("Iris matched (string comparison)", false);
        } else {
          setLogs("Iris not matched (string comparison)", false);
        }
        return;
      }

      // Use the existing MatchIris method if both are byte arrays
      List<int> matchScore = [currentCaptureBytes.length];
      int ret = await MethodChannelMarvisAuth.MatchIris(
          storedIrisBytes, currentCaptureBytes, matchScore);

      if (ret < 0) {
        String error = await MethodChannelMarvisAuth.GetErrorMessage(ret);
        setLogs("Iris matching error: $ret($error)", true);
      } else {
        int matchScore = await MethodChannelMarvisAuth.GetMatchScore();
        if (matchScore >= 900) {
          setLogs("✓ Iris matched successfully! Score: $matchScore", false);
          print("Iris matching successful with score: $matchScore");

          // Show success dialog
          _showMatchResultDialog(true, matchScore);
        } else {
          setLogs("✗ Iris not matched. Score: $matchScore", true);
          print("Iris matching failed with score: $matchScore");

          // Show failure dialog
          _showMatchResultDialog(false, matchScore);
        }
      }
    } catch (e) {
      print("compareIrisData error: $e");
      setLogs("Error during iris comparison", true);
    }
  }

  void _showMatchResultDialog(bool isMatched, int score) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                isMatched ? Icons.check_circle : Icons.error,
                color: isMatched ? Colors.green : Colors.red,
                size: 30,
              ),
              const SizedBox(width: 10),
              Text(
                isMatched ? "Match Success" : "Match Failed",
                style: TextStyle(
                  color: isMatched ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isMatched
                    ? "Iris data matched successfully!"
                    : "Iris data does not match.",
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Text(
                "Match Score: $score",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isMatched ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Threshold: 900",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
            if (isMatched)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Go back to main screen
                },
                child: const Text("Back to Main"),
              ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  void refreshPage() {
    callBackRegisterForDeviceDetection();
    String name = getDeviceStatusInfo();
    setState(() {
      deviceInfo = name;
    });
  }

  @override
  void BottomDialogRefresh(bool isRefresh) {
    _reload();
    refreshPage();
  }

  String METHOD_DEVICE_DETECTION = "Device_Detection";
  void callBackRegisterForDeviceDetection() {
    channel.setMethodCallHandler((call) {
      if (call.method == METHOD_DEVICE_DETECTION) {
        final splitNames = call.arguments.split(',');
        String deviceName = splitNames[0];
        String detection = splitNames[1];
        connectDisConnectView(deviceName, detection);
      }
      return Future.value("");
    });
  }

  void _reload() {
    callBackRegisterForDeviceDetection();
    String name = getDeviceStatusInfo();
    setState(() {
      deviceInfo = name;
    });
  }
}

// // In this code when image is auto capture and clik on Save Image than save the data

// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'package:lottie/lottie.dart';
// import 'package:marvis_auth/marvis_auth_method_channel.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:provider/provider.dart';

// import '../enums/DeviceDetection.dart';
// import '../enums/ImageFormatType.dart';
// import '../helper/CommonWidget.dart';
// import '../helper/Constants.dart';
// import '../helper/DeviceInfo.dart';
// import '../helper/SharePreferenceHelper.dart';
// import '../provider/DeviceInfoProvider.dart';
// import '../provider/SettingProvider.dart';
// import 'DeviceInfoDialog.dart';
// import 'helper/BottomNavigationDialogListener.dart';

// class CapturePage extends StatefulWidget {
//   String titleNew = "Capture Page";

//   //int displayImage = 0; // Blue image
//   // int displayImage = 1; // White image
//   // int displayImage = 2; // Byte array

//   CapturePage(String title, {Key? key}) : super(key: key) {
//     titleNew = title;
//   }

//   @override
//   CapturePageState createState() => CapturePageState();
// }

// enum ScannerAction { Capture, MatchIRIS }

// class CapturePageState extends State<CapturePage>
//     implements BottomDialogRefreshListener {
//   String deviceInfo = "Device Status: ";
//   MethodChannel channel = const MethodChannel('PassedCallBack');

//   static const String METHOD_PREVIEW = "preview";
//   static const String METHOD_COMPLETE = "complete";
//   final FocusNode _focusNode = FocusNode();
//   bool isAutoCapture = false;
//   ScannerAction scannerAction = ScannerAction.Capture;
//   final Paint paint = Paint();

//   String messsageText = "";
//   bool isMessageError = false;
//   String title = "";

//   int displayImage = 0;
//   String image_path = "assets/images/img_white_image.png";
//   late Uint8List byteImage;
//   late Uint8List lastCapIrisData;

//   int minQuality = -1;
//   int timeout = -1;
//   String imageFormatType = "BMP";

//   late SharePreferenceHelper sharePreferenceHelper;
//   DeviceInfo? deviceInfoObject = null;
//   int BmpHeaderlength = 1078;
//   bool isCaptureRunning = false;

//   List<String> imageFormatDropdown = ["BMP", "RAW", "K3", "K7"];
//   String selectedValue1 = "BMP";
//   int imageType = 0;
//   String saveImageType = "";

//   TextEditingController imageQualityController = TextEditingController();
//   TextEditingController timeoutController = TextEditingController();

//   CapturePageState();

//   String getDeviceStatusInfo() {
//     String deviceName = Provider.of<DeviceInfoProvider>(context, listen: false)
//         .deviceNameStatus;
//     if (deviceName == "") {
//     } else {
//       deviceInfo = deviceName;
//     }
//     return deviceInfo;
//   }

//   void getDeviceObject() {
//     sharePreferenceHelper = SharePreferenceHelper();
//     Future<DeviceInfo?> deviceinfo = GetDeviceInfo();
//     deviceInfoObject = null;
//     if (deviceInfo != null) {
//       deviceinfo.then((value) {
//         deviceInfoObject = value;
//       });
//     }
//   }

//   @override
//   void initState() {
//     callBackReqister();
//     super.initState();
//     getDeviceObject();
//     displayImage = 0;

//     paint.style = PaintingStyle.stroke;
//     paint.strokeWidth = 2;
//     paint.isAntiAlias = true;

//     minQuality =
//         Provider.of<SettingProvider>(context, listen: false).getQuality();
//     timeout = Provider.of<SettingProvider>(context, listen: false).getTimeout();
//     imageType =
//         Provider.of<SettingProvider>(context, listen: false).getImageType();

//     if (minQuality == null || minQuality < 0 || minQuality > 100) {
//       imageQualityController.text = '60';
//     }

//     if (timeout == null) {
//       timeoutController.text = '10000';
//     }

//     if (imageType != -1) {
//       if (imageType == ImageFormatType.BMP.index) {
//         imageFormatType = ImageFormatType.BMP.name;
//       } else if (imageType == ImageFormatType.RAW.index) {
//         imageFormatType = ImageFormatType.RAW.name;
//       } else if (imageType == ImageFormatType.K3.index) {
//         imageFormatType = ImageFormatType.K3.name;
//       } else if (imageType == ImageFormatType.K7.index) {
//         imageFormatType = ImageFormatType.K7.name;
//       }
//     }

//     timeout = Provider.of<SettingProvider>(context, listen: false).getTimeout();
//     if (timeout == null || timeout == -1) {
//       timeout = int.parse(timeoutController.text);
//     }
//     timeoutController = TextEditingController(text: timeout.toString());
//     int quality =
//         Provider.of<SettingProvider>(context, listen: false).getQuality();
//     if (quality == -1) {
//       quality = int.parse(imageQualityController.text);
//     }
//     imageQualityController = TextEditingController(text: '$quality');
//   }

//   void callBackReqister() {
//     channel.setMethodCallHandler((call) async {
//       if (call.method == 'Device_Detection') {
//         final splitNames = call.arguments.split(',');
//         String deviceName = splitNames[0];
//         String detection = splitNames[1];
//         connectDisConnectView(deviceName, detection);
//       } else if (call.method == METHOD_PREVIEW) {
//         List<String> value = call.arguments.toString().split(",");
//         // 0 - ErrorCode, 1 - Quality, 2- Byte[], 3 - irisX, 4 - irisY, 5 - irisR
//         int ErrorCode = int.parse(value[0]);
//         String byte = value[2];

//         Uint8List Image = Constants.convertBase64StringToByteArray(byte);
//         try {
//           if (ErrorCode == 0 && byte.isNotEmpty && Image != null) {
//             setState(() {
//               displayImage = 2;
//               byteImage = Image;
//             });
//           } else {
//             String Error =
//                 "Preview Error Code: $ErrorCode (${await MethodChannelMarvisAuth.GetErrorMessage(ErrorCode)})";
//             setLogs(Error, true);
//           }
//         } catch (e) {
//           print(e.toString());
//         }
//       } else if (call.method == METHOD_COMPLETE) {
//         List<String> value = call.arguments.toString().split(",");
//         // 0 - ErrorCode, 1 - Quality, 2- Byte[], 3 - irisX, 4 - irisY, 5 - irisR
//         int ErrorCode = int.parse(value[0]);
//         int Quality = int.parse(value[1]);
//         String byte = value[2];

//         try {
//           if (ErrorCode == 0) {
//             String log = "Capture Success";
//             String quality = "Quality: $Quality";
//             setLogs("$log $quality", false);

//             if (scannerAction == ScannerAction.Capture) {
//               int? width = deviceInfoObject?.Width;
//               int? Height = deviceInfoObject?.Height;
//               int bmpHeaderLength = BmpHeaderlength;
//               int size = (width! * Height!) + bmpHeaderLength;
//               Uint8List bImage = Uint8List(size);

//               int ret = await MethodChannelMarvisAuth.GetImage(
//                   bImage, size, 0, imageFormatType);
//               if (ret == 0) {
//                 lastCapIrisData = Uint8List(size);
//                 String Base64 = await MethodChannelMarvisAuth.GetImageBase64();
//                 bImage = Constants.convertBase64StringToByteArray(Base64);
//                 List.copyRange(lastCapIrisData, 0, bImage, 0, bImage.length);
//               } else {
//                 setLogs(
//                     await MethodChannelMarvisAuth.GetErrorMessage(ret), true);
//               }
//             }
//           } else {
//             setState(() {
//               image_path = "assets/images/img_white_image.png";
//             });
//             String error =
//                 "CaptureComplete: $ErrorCode (${await MethodChannelMarvisAuth.GetErrorMessage(ErrorCode)})";
//             setLogs(error, true);
//           }
//         } catch (e) {
//           print(e.toString());
//         }
//       }
//       return Future.value("");
//     });
//   }

//   void saveData() async {
//     try {
//       int? width = deviceInfoObject?.Width;
//       int? Height = deviceInfoObject?.Height;
//       int bmpHeaderLength = BmpHeaderlength;

//       int size = (width! * Height!) + bmpHeaderLength;
//       Uint8List bImage1 = Uint8List(size);
//       int ret = await MethodChannelMarvisAuth.GetImage(
//           bImage1, size, 0, imageFormatType);
//       String Base64 = await MethodChannelMarvisAuth.GetImageBase64();
//       bImage1 = Constants.convertBase64StringToByteArray(Base64);
//       List<int> intArrayFromAndroid =
//           await MethodChannelMarvisAuth.GetIntArray();
//       Uint8List bImage = Uint8List(intArrayFromAndroid[0]);
//       bImage.setRange(0, intArrayFromAndroid[0], bImage1);

//       if (ret == 0) {
//         if (imageFormatType == ImageFormatType.BMP.name) {
//           WriteImageFile("Bitmap.bmp", bImage);
//         } else if (imageFormatType == ImageFormatType.K3.name) {
//           WriteImageFile("K3.iso", bImage);
//         } else if (imageFormatType == ImageFormatType.K7.name) {
//           WriteImageFile("K7.iso", bImage);
//         } else if (imageFormatType == ImageFormatType.RAW.name) {
//           WriteImageFile("Raw.raw", bImage);
//         }
//       } else {
//         String error =
//             "${"Save Image Ret: $ret (${await MethodChannelMarvisAuth.GetErrorMessage(ret)}"})";
//         setLogs(error, true);
//       }
//     } catch (e) {
//       print(e.toString());
//       saveData();
//     }
//   }

//   void WriteImageFile(String filename, Uint8List byte) async {
//     print('WriteImage ..Filename :: $filename');
//     try {
//       final directory = await getExternalStorageDirectory();
//       final dirPath = '${directory?.path}/IrisData/Image/$filename';
//       File file = File(dirPath);
//       bool isExist = false;
//       file.exists().then((result) => isExist = result);
//       file.create(recursive: true);
//       var myFile = File('$dirPath');
//       var sink = myFile.openWrite();
//       myFile.writeAsBytes(byte);
//       await sink.flush();
//       await sink.close();
//       setLogs("Image Saved", false);
//     } catch (e) {
//       print(e.toString());
//       WriteImageFile(filename, byte);
//     }
//   }

//   void connectDisConnectView(String deviceName, String detection) {
//     String device = "";
//     if (DeviceDetection.CONNECTED.name == detection) {
//       setLogs("Device connected", false);
//       Provider.of<DeviceInfoProvider>(context, listen: false)
//           .setDeviceConnectedStatus(true);
//       device = "Device Status: Connected - $deviceName";
//       Provider.of<DeviceInfoProvider>(context, listen: false)
//           .setDeviceNameStatus(device);
//       Provider.of<DeviceInfoProvider>(context, listen: false)
//           .setDeviceName(deviceName);
//     } else {
//       setLogs("Device Not Connected", true);
//       sharePreferenceHelper.setDeviceInfo("");
//       Uninit();
//       Provider.of<DeviceInfoProvider>(context, listen: false)
//           .setDeviceConnectedStatus(false);
//       device = "Device Status: Device Not Connected";
//       Provider.of<DeviceInfoProvider>(context, listen: false)
//           .setDeviceNameStatus(device);
//       Provider.of<DeviceInfoProvider>(context, listen: false)
//           .setDeviceName(deviceName);
//       Navigator.pop(context);
//     }
//     setState(() {
//       deviceInfo = device;
//     });
//   }

//   Future<void> Uninit() async {
//     String value = sharePreferenceHelper.getDeviceInfo().toString();
//     String displayStatus = "";
//     try {
//       int ret = await MethodChannelMarvisAuth.Uninit();
//       await (ret);
//       if (ret == 0) {
//         displayStatus = "UnInit Success";
//         setLogs(displayStatus, false);
//       } else {
//         String error = await MethodChannelMarvisAuth.GetErrorMessage(ret);
//         await (error);
//         displayStatus = "UnInit: $ret ($error)";
//         setLogs(displayStatus, true);
//       }
//       sharePreferenceHelper.setDeviceInfo("");
//     } catch (e) {
//       displayStatus = "Device not found";
//       setLogs("Device not found", true);
//     }
//   }

//   @override
//   void didChangeDependencies() {
//     getDeviceStatusInfo();
//     super.didChangeDependencies();
//   }

//   Widget getProgressDialog() {
//     return const Center(child: CircularProgressIndicator());
//   }

//   bool isProgressBar = false;

//   @override
//   Widget build(BuildContext context) {
//     Provider.of<DeviceInfoProvider>(context, listen: false)
//         .setDeviceNameStatus(deviceInfo);
//     return Scaffold(
//       resizeToAvoidBottomInset: true,
//       appBar: AppBar(
//         title: Text(title),
//       ),
//       bottomNavigationBar:
//           CommonWidget.getBottomNavigationWidget(context, deviceInfo, this),
//       body: Padding(
//         padding: const EdgeInsets.all(10.0),
//         child: Container(
//           constraints: const BoxConstraints.expand(),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               Expanded(
//                 child: Container(
//                   constraints: BoxConstraints(
//                     maxHeight: MediaQuery.of(context).size.height -
//                         kToolbarHeight -
//                         kBottomNavigationBarHeight,
//                   ),
//                   child: ListView(
//                     children: [
//                       Row(
//                         children: [
//                           Expanded(
//                             child: TextFormField(
//                               controller: imageQualityController,
//                               keyboardType: TextInputType.number,
//                               decoration: const InputDecoration(
//                                 labelText: 'Min Quality [1-100]',
//                                 labelStyle: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               style: const TextStyle(
//                                 color: Colors.blue,
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 16),
//                           Expanded(
//                             child: TextFormField(
//                               controller: timeoutController,
//                               keyboardType: TextInputType.number,
//                               decoration: const InputDecoration(
//                                 labelText: 'TIMEOUT (Milliseconds)',
//                                 labelStyle: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               style: const TextStyle(
//                                 color: Colors.blue,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 5.0),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const SizedBox(height: 10),
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     const Text(
//                                       'Select Image Format',
//                                       style: TextStyle(
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 10.0),
//                                     Container(
//                                       decoration: BoxDecoration(
//                                         border: Border.all(
//                                           color: Colors.blue, // Border color
//                                           width: 2.0, // Border width
//                                         ),
//                                         borderRadius:
//                                             BorderRadius.circular(8.0),
//                                       ),
//                                       child: DropdownButton<String>(
//                                         value: imageFormatType,
//                                         onChanged: (newValue) {
//                                           setState(() {
//                                             imageFormatType = newValue!;

//                                             if (imageFormatType == "RAW") {
//                                               imageType =
//                                                   ImageFormatType.RAW.index;
//                                             } else if (imageFormatType ==
//                                                 "BMP") {
//                                               imageType =
//                                                   ImageFormatType.BMP.index;
//                                             } else if (imageFormatType ==
//                                                 "K7") {
//                                               imageType =
//                                                   ImageFormatType.K7.index;
//                                             } else if (imageFormatType ==
//                                                 "K3") {
//                                               imageType =
//                                                   ImageFormatType.K3.index;
//                                             }
//                                           });
//                                         },
//                                         style: const TextStyle(
//                                           color: Colors.blue,
//                                         ),
//                                         dropdownColor: Colors.white,
//                                         items: imageFormatDropdown
//                                             .map((String value) {
//                                           return DropdownMenuItem<String>(
//                                             value: value,
//                                             child: Text(
//                                               value,
//                                               style: const TextStyle(
//                                                 color: Colors.blue,
//                                               ),
//                                             ),
//                                           );
//                                         }).toList(),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 15.0),
//                       const Text(
//                         'Perform Operations',
//                         style: TextStyle(
//                             fontSize: 16, fontWeight: FontWeight.bold),
//                       ),
//                       const SizedBox(height: 8.0),
//                       _buildButtonRow(
//                         'Start Capture',
//                         () {
//                           print(selectedValue1);
//                           StartCapture(timeout, minQuality);
//                         },
//                         'Auto Capture',
//                         () {
//                           FocusScope.of(context).requestFocus(_focusNode);
//                           CommonWidget.showLoaderDialog(
//                               context, 'Please put eye on scanner');
//                           Future.delayed(const Duration(milliseconds: 200), () {
//                             AutoCapture();
//                           });
//                         },
//                       ),
//                       const SizedBox(height: 5.0),
//                       _buildButtonRow(
//                         'Stop Capture',
//                         () => StopCature(),
//                         'Match Iris',
//                         () {
//                           CommonWidget.showLoaderDialog(
//                               context, 'Please put eye on scanner');
//                           Future.delayed(const Duration(milliseconds: 200), () {
//                             MatchIris();
//                           });
//                         },
//                       ),
//                       const SizedBox(height: 5.0),
//                       Row(
//                         children: <Widget>[
//                           Expanded(
//                             child: ElevatedButton(
//                               onPressed: () => SaveImage(),
//                               child: const Text('Save Image'),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 15.0),
//                       const Text(
//                         'Iris Preview',
//                         style: TextStyle(
//                             fontSize: 16, fontWeight: FontWeight.bold),
//                       ),
//                       const SizedBox(height: 8.0),
//                       Row(
//                         children: <Widget>[
//                           Expanded(
//                             child: getCardView(),
//                           )
//                         ],
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget getCardView() {
//     return SizedBox(
//       height: 200,
//       child: InkWell(
//         onTap: () {},
//         child: Card(
//           elevation: 5,
//           borderOnForeground: false,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(4.0),
//             side: const BorderSide(color: Colors.grey, width: 3.0),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(4.0),
//             child: Column(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: getCaptureWidget()),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildButtonRow(String buttonText1, VoidCallback onPressed1,
//       String buttonText2, VoidCallback onPressed2) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       children: [
//         Expanded(
//             child: ElevatedButton(
//           onPressed: onPressed1,
//           child: Text(buttonText1),
//         )),
//         const SizedBox(width: 16),
//         Expanded(
//             child: ElevatedButton(
//           onPressed: () {
//             FocusScope.of(context).requestFocus(_focusNode);
//             Future.delayed(
//               const Duration(milliseconds: 200),
//               onPressed2,
//             );
//           },
//           child: Text(buttonText2),
//         )),
//       ],
//     );
//   }

//   List<Widget> getCaptureWidget() {
//     return <Widget>[
//       Container(
//           margin: const EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 0.0),
//           child: Text(
//             messsageText,
//             style: TextStyle(
//               color: isMessageError ? Colors.red : Colors.blue,
//             ),
//           )),
//       onImageDynamic(),
//     ];
//   }

//   Widget onImageDynamic() {
//     if (displayImage == 0 || displayImage == 1) {
//       return Lottie.asset(
//         'assets/animations/fingerprint.json',
//         width: 150,
//         height: 150,
//         fit: BoxFit.cover,
//       );
//     } else if (displayImage == 2) {
//       return Image.memory(byteImage, width: 150.0, height: 150.0);
//     } else {
//       return Image.asset(image_path, width: 150.0, height: 100.0);
//     }
//   }

//   Future<DeviceInfo?> GetDeviceInfo() async {
//     Future<String?> value = sharePreferenceHelper.getDeviceInfo();
//     String deviceInfo = "";
//     value.then((result) {
//       deviceInfo = result!;
//     });
//     await (value);
//     String deviceValue = deviceInfo;
//     if (deviceValue == null || deviceValue == "") {
//       return null;
//     }
//     DeviceInfo deviceInfoObject =
//         CommonWidget.convertStringToDeviceInfo(deviceValue);
//     await (deviceInfoObject);
//     return deviceInfoObject;
//   }

//   // void SaveImage() {
//   //   if (deviceInfoObject == null) {
//   //     setLogs("Please run device init first", true);
//   //     return;
//   //   }
//   //   saveData();
//   // }

//   void SaveImage() async {
//     if (deviceInfoObject == null) {
//       setLogs("Please run device init first", true);
//       return;
//     }

//     try {
//       // First save the image locally
//       saveData();

//       // Then send the iris data to the API
//       await sendIrisDataToAPI();
//     } catch (e) {
//       setLogs("Error saving image or sending data: $e", true);
//     }
//   }

//   Future<void> sendIrisDataToAPI() async {
//     try {
//       // Get the captured iris data (base64 encoded)
//       String base64Image = '';

//       if (lastCapIrisData != null && lastCapIrisData.isNotEmpty) {
//         base64Image = base64Encode(lastCapIrisData);
//       } else {
//         // If no current capture, try to get the image from the device
//         int? width = deviceInfoObject?.Width;
//         int? Height = deviceInfoObject?.Height;
//         int bmpHeaderLength = BmpHeaderlength;
//         int size = (width! * Height!) + bmpHeaderLength;
//         Uint8List bImage = Uint8List(size);

//         int ret = await MethodChannelMarvisAuth.GetImage(
//             bImage, size, 0, imageFormatType);

//         if (ret == 0) {
//           String Base64 = await MethodChannelMarvisAuth.GetImageBase64();
//           bImage = Constants.convertBase64StringToByteArray(Base64);
//           base64Image = base64Encode(bImage);
//         } else {
//           setLogs(
//               "Failed to get image for API: ${await MethodChannelMarvisAuth.GetErrorMessage(ret)}",
//               true);
//           return;
//         }
//       }

//       // Prepare the request body
//       final Map<String, dynamic> requestBody = {
//         "AadhaarNumber": "615735525318", // Hardcoded as requested
//         "IrisData": base64Image, // Base64 encoded iris data
//       };

//       // Make the POST request
//       final response = await http.post(
//         Uri.parse('https://divyangpcmc.altwise.in/api/aadhar/StoreIrisData'),
//         headers: <String, String>{
//           'Content-Type': 'application/json; charset=UTF-8',
//         },
//         body: jsonEncode(requestBody),
//       );

//       if (response.statusCode == 200) {
//         // Successful request - don't show response body on screen
//         final responseData = jsonDecode(response.body);
//         setLogs("API Request Successful", false); // Changed this line
//         print("API Response Body: ${response.body}"); // Still logs to console
//       } else {
//         // Failed request - show only status code, not full response body
//         setLogs("API Error: ${response.statusCode}", true); // Changed this line
//         print("API Error Response: ${response.body}"); // Still logs to console
//       }
//     } catch (e) {
//       setLogs("Error sending data to API", true); // Generic error message
//       print("Exception occurred: $e"); // Detailed error in console
//     }
//   }

//   // Handle the response
//   //     if (response.statusCode == 200) {
//   //       // Successful request
//   //       final responseData = jsonDecode(response.body);
//   //       setLogs("API Response: ${response.body}", false);
//   //       print("API Response Body: ${response.body}");
//   //     } else {
//   //       // Failed request
//   //       setLogs("API Error: ${response.statusCode} - ${response.body}", true);
//   //       print("API Error Response: ${response.body}");
//   //     }
//   //   } catch (e) {
//   //     setLogs("Error sending data to API: $e", true);
//   //     print("Exception occurred: $e");
//   //   }
//   // }

//   Future<void> displayBlankData() async {
//     setLogs("", false);
//     setState(() {
//       image_path = "assets/images/img_white_image.png";
//       setLogs("Auto Capture Started", false);
//     });
//   }

//   // Future<void> StartSyncCapture() async {
//   //   try {
//   //     List<int> qty = [];
//   //     int iRisX = 0;
//   //     int iRisY = 0;
//   //     int iRisZ = 0;
//   //     String error;

//   //     int ret = await MethodChannelMarvisAuth.AutoCapture(
//   //         timeout, qty, iRisX, iRisY, iRisZ);

//   //     if (ret != -1) {
//   //       if (ret != 0) {
//   //         setState(() {
//   //           image_path = "assets/images/img_white_image.png";
//   //         });
//   //         String error = await MethodChannelMarvisAuth.GetErrorMessage(ret);
//   //         setLogs("Start Sync Capture Ret: $ret ($error)", true);
//   //         Navigator.pop(context);
//   //       } else {
//   //         Navigator.pop(context);
//   //         int quality = await MethodChannelMarvisAuth.GetQualityElement();
//   //         setLogs("Capture Success  Quality: $quality", false);

//   //         if (scannerAction == ScannerAction.Capture) {
//   //           int? width = deviceInfoObject?.Width;
//   //           int? Height = deviceInfoObject?.Height;
//   //           int bmpHeaderLength = BmpHeaderlength;
//   //           int size = (width! * Height!) + bmpHeaderLength;
//   //           Uint8List bImage = Uint8List(size);
//   //           int ret = await MethodChannelMarvisAuth.GetImage(
//   //               bImage, size, 0, imageFormatType);
//   //           if (ret == 0) {
//   //             lastCapIrisData = Uint8List(size);
//   //             String Base64 = await MethodChannelMarvisAuth.GetImageBase64();
//   //             // print('Base64 String: $base64');
//   //             print("Base64 Image Data nospace: $Base64");
//   //             bImage = Constants.convertBase64StringToByteArray(Base64);
//   //             List.copyRange(lastCapIrisData, 0, bImage, 0, bImage.length);
//   //           } else {
//   //             setLogs(await MethodChannelMarvisAuth.GetErrorMessage(ret), true);
//   //           }
//   //         } else {
//   //           matchData(); //  isAutoCaptureStarted = false;
//   //         }
//   //       }
//   //     }
//   //   } catch (e) {
//   //     setLogs("Error", true);
//   //   }
//   // }

//   Future<void> StartSyncCapture() async {
//     try {
//       List<int> qty = [];
//       int iRisX = 0;
//       int iRisY = 0;
//       int iRisZ = 0;
//       String error;

//       int ret = await MethodChannelMarvisAuth.AutoCapture(
//           timeout, qty, iRisX, iRisY, iRisZ);

//       if (ret != -1) {
//         if (ret != 0) {
//           setState(() {
//             image_path = "assets/images/img_white_image.png";
//           });
//           String error = await MethodChannelMarvisAuth.GetErrorMessage(ret);
//           setLogs("Start Sync Capture Ret: $ret ($error)", true);
//           Navigator.pop(context);
//         } else {
//           Navigator.pop(context);
//           int quality = await MethodChannelMarvisAuth.GetQualityElement();
//           setLogs("Capture Success  Quality: $quality", false);

//           if (scannerAction == ScannerAction.Capture) {
//             int? width = deviceInfoObject?.Width;
//             int? Height = deviceInfoObject?.Height;
//             int bmpHeaderLength = BmpHeaderlength;
//             int size = (width! * Height!) + bmpHeaderLength;
//             Uint8List bImage = Uint8List(size);
//             int ret = await MethodChannelMarvisAuth.GetImage(
//                 bImage, size, 0, imageFormatType);
//             if (ret == 0) {
//               lastCapIrisData = Uint8List(size);
//               String Base64 = await MethodChannelMarvisAuth.GetImageBase64();
//               print("Base64 Image Data nospace: $Base64");
//               bImage = Constants.convertBase64StringToByteArray(Base64);
//               List.copyRange(lastCapIrisData, 0, bImage, 0, bImage.length);
//             } else {
//               setLogs(await MethodChannelMarvisAuth.GetErrorMessage(ret), true);
//             }
//           } else {
//             matchData(); // For MatchIRIS action
//           }
//         }
//       }
//     } catch (e) {
//       setLogs("Error", true);
//     }
//   }

//   Future<void> StartCapture(int timeout, int minQuality) async {
//     timeout = int.parse(timeoutController.text);
//     minQuality = int.parse(imageQualityController.text);

//     bool isCaptureRunning = await MethodChannelMarvisAuth.IsCaptureRunning();
//     if (isCaptureRunning) {
//       setLogs("StartCapture: Capture already started", true);
//       return;
//     }
//     if (deviceInfoObject == null) {
//       setLogs("Please run device init first", true);
//       return;
//     }
//     scannerAction = ScannerAction.Capture;
//     isAutoCapture = false;
//     try {
//       setLogs("", false);
//       setState(() {
//         image_path = "assets/images/img_white_image.png";
//       });

//       int ret = await MethodChannelMarvisAuth.StartCapture(timeout, minQuality);
//       String error = await MethodChannelMarvisAuth.GetErrorMessage(ret);
//       setLogs("StartCapture Ret: $ret ($error)", ret == 0 ? false : true);
//     } catch (e) {
//       setLogs("Error", true);
//     }
//   }

//   Future<void> StopCature() async {
//     try {
//       int ret = await MethodChannelMarvisAuth.StopCapture();
//       String error = await MethodChannelMarvisAuth.GetErrorMessage(ret);
//       setLogs("StopCapture: $ret ($error)", false);
//     } catch (e) {
//       setLogs("Error", true);
//     }
//   }

//   void setLogs(String errorMessage, bool isError) {
//     setState(() {
//       messsageText = errorMessage;
//       if (isError) {
//         isMessageError = true;
//         print("Error====>$errorMessage");
//       } else {
//         isMessageError = false;
//         print("Message====>$errorMessage");
//       }
//     });
//   }

//   Future<void> AutoCapture() async {
//     bool isCaptureRunning = await MethodChannelMarvisAuth.IsCaptureRunning();
//     if (deviceInfoObject == null) {
//       setLogs("Please run device init first", true);
//       Navigator.pop(context);
//       return;
//     } else if (isCaptureRunning) {
//       int dfff = MethodChannelMarvisAuth.CAPTURE_ALREADY_STARTED;
//       String error = await MethodChannelMarvisAuth.GetErrorMessage(dfff);
//       String errorMessage = "StartCapture Ret: $dfff ($error)";
//       setLogs(errorMessage, true);
//       Navigator.pop(context);
//       return;
//     } else {
//       displayBlankData();
//       scannerAction = ScannerAction.Capture;
//       isAutoCapture = true;
//       StartSyncCapture();
//     }
//   }

//   // void MatchIris() {
//   //   if (deviceInfoObject == null) {
//   //     setLogs("Please run device init first", true);
//   //     Navigator.pop(context);
//   //     return;
//   //   } else if (lastCapIrisData == null) {
//   //     setLogs("Please run start or auto capture first!", true);
//   //     Navigator.pop(context);
//   //     return;
//   //   } else {
//   //     displayBlankData();
//   //     scannerAction = ScannerAction.MatchIRIS;
//   //     StartSyncCapture();
//   //   }
//   // }

//   void MatchIris() {
//     if (deviceInfoObject == null) {
//       setLogs("Please run device init first", true);
//       Navigator.pop(context);
//       return;
//     }
//     displayBlankData();
//     scannerAction = ScannerAction.MatchIRIS;
//     StartSyncCapture();
//   }

//   // Future<void> matchData() async {
//   //   try {
//   //     if (scannerAction == ScannerAction.MatchIRIS) {
//   //       if (lastCapIrisData == null) {
//   //         return;
//   //       }
//   //       int? width = deviceInfoObject?.Width;
//   //       int? Height = deviceInfoObject?.Height;
//   //       int bmpHeaderLength = BmpHeaderlength;
//   //       int size = (width! * Height!) + bmpHeaderLength;
//   //       Uint8List bImage = Uint8List(size);
//   //       int ret = await MethodChannelMarvisAuth.GetImage(
//   //           bImage, size, 0, imageFormatType);
//   //       if (ret == 0) {
//   //         Uint8List Verify_Image = Uint8List(size);
//   //         String BImageBase64 = await MethodChannelMarvisAuth.GetImageBase64();
//   //         bImage = Constants.convertBase64StringToByteArray(BImageBase64);

//   //         List.copyRange(Verify_Image, 0, bImage, 0, bImage.length);
//   //         List<int> matchScore = [size];
//   //         ret = await MethodChannelMarvisAuth.MatchIris(
//   //             lastCapIrisData, Verify_Image, matchScore);

//   //         if (ret < 0) {
//   //           String error = await MethodChannelMarvisAuth.GetErrorMessage(ret);
//   //           setLogs("Error: $ret($error)", true);
//   //         } else {
//   //           int matchScore = await MethodChannelMarvisAuth.GetMatchScore();
//   //           if (matchScore >= 900) {
//   //             setLogs("Iris matched with score: $matchScore", false);
//   //           } else {
//   //             setLogs("Iris not matched, score: $matchScore", false);
//   //           }
//   //         }
//   //       } else {
//   //         setLogs(
//   //             "Error: $ret(${await MethodChannelMarvisAuth.GetErrorMessage(ret)})",
//   //             true);
//   //       }
//   //     }
//   //   } catch (e) {
//   //     print("$e");
//   //   }
//   // }

//   Future<void> matchData() async {
//     try {
//       if (scannerAction == ScannerAction.MatchIRIS) {
//         // Get the newly captured iris data
//         int? width = deviceInfoObject?.Width;
//         int? Height = deviceInfoObject?.Height;
//         int bmpHeaderLength = BmpHeaderlength;
//         int size = (width! * Height!) + bmpHeaderLength;
//         Uint8List bImage = Uint8List(size);

//         int ret = await MethodChannelMarvisAuth.GetImage(
//             bImage, size, 0, imageFormatType);

//         if (ret == 0) {
//           // Get the current captured image as base64
//           String currentCaptureBase64 =
//               await MethodChannelMarvisAuth.GetImageBase64();
//           print("Current Capture Base64 Image Data: $currentCaptureBase64");

//           // Get stored iris data from API
//           String? storedIrisData =
//               await getStoredIrisDataFromAPI("615735525318");

//           if (storedIrisData != null) {
//             // Compare the iris data
//             await compareIrisData(currentCaptureBase64, storedIrisData);
//           } else {
//             setLogs("Failed to retrieve stored iris data", true);
//           }
//         } else {
//           setLogs(
//               "Error getting current image: $ret(${await MethodChannelMarvisAuth.GetErrorMessage(ret)})",
//               true);
//         }
//       }
//     } catch (e) {
//       print("matchData error: $e");
//       setLogs("Error during iris matching", true);
//     }
//   }

//   Future<String?> getStoredIrisDataFromAPI(String aadhaarNumber) async {
//     try {
//       final response = await http.get(
//         Uri.parse(
//             'http://divyangpcmc.altwise.in/api/aadhar/GetIrisData?aadhaarNumber=$aadhaarNumber'),
//         headers: <String, String>{
//           'Content-Type': 'application/json; charset=UTF-8',
//         },
//       );

//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);

//         if (responseData['Success'] == true &&
//             responseData['Data'] != null &&
//             responseData['Data']['IrisData'] != null) {
//           String storedIrisData = responseData['Data']['IrisData'];
//           print("Retrieved stored iris data from API");
//           setLogs("Stored iris data retrieved successfully", false);
//           return storedIrisData;
//         } else {
//           setLogs("No iris data found for this Aadhaar number", true);
//           print("API Response: ${response.body}");
//           return null;
//         }
//       } else {
//         setLogs("API Error: ${response.statusCode}", true);
//         print("API Error Response: ${response.body}");
//         return null;
//       }
//     } catch (e) {
//       setLogs("Error retrieving iris data from API", true);
//       print("Exception occurred while getting iris data: $e");
//       return null;
//     }
//   }

//   Future<void> compareIrisData(
//       String currentCaptureBase64, String storedIrisData) async {
//     try {
//       // Convert both iris data to Uint8List for comparison
//       Uint8List currentCaptureBytes =
//           Constants.convertBase64StringToByteArray(currentCaptureBase64);
//       Uint8List storedIrisBytes;

//       // Check if stored iris data is base64 encoded or plain text
//       try {
//         storedIrisBytes =
//             Constants.convertBase64StringToByteArray(storedIrisData);
//       } catch (e) {
//         // If it's not base64, it might be plain text or different format
//         // For demonstration, we'll treat it as string comparison
//         print("Stored iris data is not base64 encoded: $storedIrisData");

//         // Simple string comparison (you might want to implement more sophisticated matching)
//         if (currentCaptureBase64 == storedIrisData) {
//           setLogs("Iris matched (string comparison)", false);
//         } else {
//           setLogs("Iris not matched (string comparison)", false);
//         }
//         return;
//       }

//       // Use the existing MatchIris method if both are byte arrays
//       List<int> matchScore = [currentCaptureBytes.length];
//       int ret = await MethodChannelMarvisAuth.MatchIris(
//           storedIrisBytes, currentCaptureBytes, matchScore);

//       if (ret < 0) {
//         String error = await MethodChannelMarvisAuth.GetErrorMessage(ret);
//         setLogs("Iris matching error: $ret($error)", true);
//       } else {
//         int matchScore = await MethodChannelMarvisAuth.GetMatchScore();
//         if (matchScore >= 900) {
//           setLogs("Iris matched with score: $matchScore", false);
//           print("Iris matching successful with score: $matchScore");
//         } else {
//           setLogs("Iris not matched, score: $matchScore", false);
//           print("Iris matching failed with score: $matchScore");
//         }
//       }
//     } catch (e) {
//       print("compareIrisData error: $e");
//       setLogs("Error during iris comparison", true);
//     }
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   void refreshPage() {
//     callBackReqister();

//     getDeviceObject();
//     String name = getDeviceStatusInfo();
//     setState(() {
//       deviceInfo = name;
//     });
//   }

//   Widget getBottomNavigationWidget(BuildContext context, String deviceInfo) {
//     return BottomAppBar(
//       color: Colors.grey,
//       child: Padding(
//         padding: const EdgeInsets.all(10.0),
//         child: GestureDetector(
//           behavior: HitTestBehavior.translucent,
//           onTap: () {
//             showDialog(
//               context: context,
//               builder: (_) => const DeviceInfoDialog(),
//             ).then((value) => refreshPage());
//           },
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Container(
//                 decoration: BoxDecoration(
//                     color: Colors.white,
//                     border: Border.all(color: Colors.grey),
//                     borderRadius: BorderRadius.circular(5.0)),
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Text(deviceInfo,
//                       textAlign: TextAlign.center,
//                       style: const TextStyle(
//                         color: Colors.black,
//                         fontSize: 15.0,
//                       )),
//                 ),
//               ),
//               Container(
//                   margin: const EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 0.0),
//                   child: Image.asset(
//                     'assets/images/ic_device_update.png',
//                     width: 30,
//                     height: 30,
//                   ))
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   void BottomDialogRefresh(bool isRefresh) {
//     _reload();
//     refreshPage();
//   }

//   String METHOD_DEVICE_DETECTION = "Device_Detection";
//   void callBackRegister() {
//     channel.setMethodCallHandler((call) {
//       if (call.method == METHOD_DEVICE_DETECTION) {
//         final splitNames = call.arguments.split(',');
//         String deviceName = splitNames[0];
//         String detection = splitNames[1];
//         connectDisConnectView(deviceName, detection);
//       }
//       return Future.value("");
//     });
//   }

//   void _reload() {
//     callBackRegister();
//     String name = getDeviceStatusInfo();
//     setState(() {
//       deviceInfo = name;
//     });
//   }
// }

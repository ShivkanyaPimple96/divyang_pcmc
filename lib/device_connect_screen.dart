import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:divyang_pimpri_chinchwad_municipal_corporation/KYC_Screens/Home_Screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:marvis_auth/marvis_auth_method_channel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../helper/DeviceInfo.dart';
import 'CapturePage.dart';
import 'enums/DeviceDetection.dart';
import 'enums/ImageFormatType.dart';
import 'helper/BottomNavigationDialogListener.dart';
import 'helper/CommonWidget.dart';
import 'helper/Constants.dart';
import 'helper/SharePreferenceHelper.dart';
import 'provider/DeviceInfoProvider.dart';
import 'provider/SettingProvider.dart';

class DeviceConnectScreen extends StatefulWidget {
  const DeviceConnectScreen({Key? key}) : super(key: key);

  @override
  State<DeviceConnectScreen> createState() => _DeviceConnectScreenState();
}

enum ScannerAction { Capture, MatchIRIS }

class _DeviceConnectScreenState extends State<DeviceConnectScreen>
    implements BottomDialogRefreshListener {
  String deviceInfo = "Device Status: ";
  String? deviceInit = "Check Device";

  TextEditingController setKeyController = TextEditingController();
  String clientKey = "";

  FocusScopeNode node = FocusScopeNode();

  String _platformVersion = 'Unknown';
  String GET_SDK_VERSION = "SDK Version: ";
  String GET_Supported_Device_List = "Supported Devices : \n";

  late SharePreferenceHelper sharePreferenceHelper;
  MethodChannel channel = const MethodChannel('PassedCallBack');

  DeviceInfo? deviceInfoObject;
  String deviceConnectionStatus = "";

  // New variables for capture functionality
  static const String METHOD_PREVIEW = "preview";
  static const String METHOD_COMPLETE = "complete";
  final FocusNode _focusNode = FocusNode();
  bool isAutoCapture = false;
  ScannerAction scannerAction = ScannerAction.Capture;

  String messsageText = "";
  bool isMessageError = false;

  int displayImage = 0;
  String image_path = "assets/images/img_white_image.png";
  late Uint8List byteImage;
  late Uint8List lastCapIrisData;

  int minQuality = 60;
  int timeout = 10000;
  String imageFormatType = "BMP";
  int BmpHeaderlength = 1078;
  bool isCaptureRunning = false;

  // Add this variable to track dialog state
  bool isLoaderDialogShowing = false;

  @override
  void initState() {
    sharePreferenceHelper = SharePreferenceHelper();
    sharePreferenceHelper.setDeviceInfo("");
    callBackRegister();
    methodInitialize();
    GetSDKVersion();
    GetSupportedDevices();
    getDeviceObject();
    _reload();

    // Initialize capture settings
    displayImage = 0;
    minQuality =
        Provider.of<SettingProvider>(context, listen: false).getQuality();
    timeout = Provider.of<SettingProvider>(context, listen: false).getTimeout();

    if (minQuality == null || minQuality < 0 || minQuality > 100) {
      minQuality = 60;
    }
    if (timeout == null || timeout == -1) {
      timeout = 10000;
    }

    super.initState();
  }

  void getDeviceObject() {
    sharePreferenceHelper = SharePreferenceHelper();
    Future<DeviceInfo?> deviceinfo = GetDeviceInfo();
    deviceInfoObject = null;
    deviceinfo.then((value) {
      deviceInfoObject = value;
    });
  }

  Future<DeviceInfo?> GetDeviceInfo() async {
    Future<String?> value = sharePreferenceHelper.getDeviceInfo();
    String deviceInfo = "";
    value.then((result) {
      if (result != "") {
        deviceInfo = result!;
      }
    });
    await (value);
    String deviceValue = deviceInfo;
    if (deviceValue == "") {
      return null;
    }
    DeviceInfo deviceInfoObject =
        CommonWidget.convertStringToDeviceInfo(deviceValue);
    await (deviceInfoObject);
    return deviceInfoObject;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void methodInitialize() async {
    await MethodChannelMarvisAuth.GetIrisInitialize();
  }

  String getDeviceStatusInfo() {
    String deviceName = Provider.of<DeviceInfoProvider>(context, listen: false)
        .deviceNameStatus;
    if (deviceName != "") {
      deviceInfo = deviceName;
    }
    return deviceInfo;
  }

  String METHOD_DEVICE_DETECTION = "Device_Detection";

  void callBackRegister() {
    channel.setMethodCallHandler((call) async {
      if (call.method == METHOD_DEVICE_DETECTION) {
        final splitNames = call.arguments.split(',');
        String deviceName = splitNames[0];
        String detection = splitNames[1];
        clientKey = setKeyController.text;
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
            // Hide loader dialog on error
            _hideLoaderDialog();
          }
        } catch (e) {
          print(e.toString());
          // Hide loader dialog on exception
          _hideLoaderDialog();
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

            // Hide the loader dialog when capture is successful
            _hideLoaderDialog();

            if (scannerAction == ScannerAction.Capture) {
              int? width = deviceInfoObject?.Width;
              int? Height = deviceInfoObject?.Height;
              int bmpHeaderLength = BmpHeaderlength;
              int size = (width! * Height!) + bmpHeaderLength;
              Uint8List bImage = Uint8List(size);

              int ret = await MethodChannelMarvisAuth.GetImage(
                  bImage, size, 0, imageFormatType);
              if (ret == 0) {
                lastCapIrisData = Uint8List(size);
                String Base64 = await MethodChannelMarvisAuth.GetImageBase64();
                bImage = Constants.convertBase64StringToByteArray(Base64);
                List.copyRange(lastCapIrisData, 0, bImage, 0, bImage.length);
              } else {
                setLogs(
                    await MethodChannelMarvisAuth.GetErrorMessage(ret), true);
              }
            }
          } else {
            setState(() {
              displayImage = 0;
            });
            String error =
                "CaptureComplete: $ErrorCode (${await MethodChannelMarvisAuth.GetErrorMessage(ErrorCode)})";
            setLogs(error, true);
            // Hide loader dialog on error
            _hideLoaderDialog();
          }
        } catch (e) {
          print(e.toString());
          // Hide loader dialog on exception
          _hideLoaderDialog();
        }
      }
      return Future.value("");
    });
  }

  // Add method to hide loader dialog
  void _hideLoaderDialog() {
    if (isLoaderDialogShowing && mounted) {
      Navigator.of(context, rootNavigator: true).pop();
      isLoaderDialogShowing = false;
    }
  }

  void _reload() {
    callBackRegister();
    String name = getDeviceStatusInfo();
    setState(() {
      deviceInfo = name;
    });
  }

  Future<void> GetSDKVersion() async {
    String platformVersion;
    try {
      platformVersion =
          await MethodChannelMarvisAuth.GetSDKVersion ?? 'Unknown SDK version';
    } on PlatformException catch (e) {
      platformVersion =
          await MethodChannelMarvisAuth.GetSDKVersion ?? 'Unknown SDK version';
    }
    setState(() {
      _platformVersion = platformVersion;
    });
  }

  Future<void> GetSupportedDevices() async {
    List<String> supportedList = [];
    int ret = await MethodChannelMarvisAuth.GetSupportedDevices(supportedList);
    await (ret);
    if (ret == 0) {
      int count = await MethodChannelMarvisAuth.GetSupportedDevicesCount();
      if (count > 0) {
        supportedList = await MethodChannelMarvisAuth.GetSupportedDevicesList(
            supportedList);
        String commaSeperated = "";
        for (int i = 0; i < supportedList.length; i++) {
          commaSeperated = "$commaSeperated${supportedList[i]}, ";
        }
        if (commaSeperated != null && commaSeperated.isNotEmpty) {
          commaSeperated =
              commaSeperated.substring(0, commaSeperated.length - 2);
        }
        GET_Supported_Device_List = "";
        setState(() {
          GET_Supported_Device_List = "Supported Device: $commaSeperated";
        });
        setLogs("Supported Devices: $commaSeperated", false);
      } else {
        setLogs("Supported Devices Not Found", true);
      }
    } else {
      String errorMessage = await MethodChannelMarvisAuth.GetErrorMessage(ret);
      await (errorMessage);
      setLogs("Supported Devices Error:  ($errorMessage)", true);
    }
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
      IsDeviceConnected();
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
    }
    setState(() {
      deviceInfo = device;
    });
  }

  Future<void> IsDeviceConnected() async {
    String isDeviceConnected = "";
    String deviceName =
        Provider.of<DeviceInfoProvider>(context, listen: false).deviceName;
    try {
      bool ret = await MethodChannelMarvisAuth.IsDeviceConnected(deviceName);
      if (ret) {
        isDeviceConnected = "Device Connected";
      } else {
        isDeviceConnected = "Device Not Connected";
      }
    } catch (e) {
      isDeviceConnected = "Device not found";
      setLogs("Device not found", true);
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

  // Capture functionality methods
  Future<void> AutoCapture() async {
    bool isCaptureRunning = await MethodChannelMarvisAuth.IsCaptureRunning();
    if (deviceInfoObject == null) {
      setLogs("Please run device init first", true);
      return;
    } else if (isCaptureRunning) {
      int dfff = MethodChannelMarvisAuth.CAPTURE_ALREADY_STARTED;
      String error = await MethodChannelMarvisAuth.GetErrorMessage(dfff);
      String errorMessage = "StartCapture Ret: $dfff ($error)";
      setLogs(errorMessage, true);
      return;
    } else {
      displayBlankData();
      scannerAction = ScannerAction.Capture;
      isAutoCapture = true;
      StartSyncCapture();
    }
  }

  Future<void> displayBlankData() async {
    setLogs("", false);
    setState(() {
      displayImage = 0;
      setLogs("Auto Capture Started", false);
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
          // Hide loader dialog on error
          _hideLoaderDialog();
        } else {
          int quality = await MethodChannelMarvisAuth.GetQualityElement();
          setLogs("Capture Success  Quality: $quality", false);

          // Hide the loader dialog when capture is successful
          _hideLoaderDialog();

          if (scannerAction == ScannerAction.Capture) {
            int? width = deviceInfoObject?.Width;
            int? Height = deviceInfoObject?.Height;
            int bmpHeaderLength = BmpHeaderlength;
            int size = (width! * Height!) + bmpHeaderLength;
            Uint8List bImage = Uint8List(size);
            int ret = await MethodChannelMarvisAuth.GetImage(
                bImage, size, 0, imageFormatType);
            if (ret == 0) {
              lastCapIrisData = Uint8List(size);
              String Base64 = await MethodChannelMarvisAuth.GetImageBase64();
              print("Base64 Image Data: $Base64");
              bImage = Constants.convertBase64StringToByteArray(Base64);
              List.copyRange(lastCapIrisData, 0, bImage, 0, bImage.length);
            } else {
              setLogs(await MethodChannelMarvisAuth.GetErrorMessage(ret), true);
            }
          }
        }
      }
    } catch (e) {
      setLogs("Error", true);
      // Hide loader dialog on exception
      _hideLoaderDialog();
    }
  }

  Future<void> StopCapture() async {
    try {
      int ret = await MethodChannelMarvisAuth.StopCapture();
      String error = await MethodChannelMarvisAuth.GetErrorMessage(ret);
      setLogs("StopCapture: $ret ($error)", false);
      // Hide loader dialog when stopping capture
      _hideLoaderDialog();
    } catch (e) {
      setLogs("Error", true);
      // Hide loader dialog on exception
      _hideLoaderDialog();
    }
  }

  void SaveImage() async {
    if (deviceInfoObject == null) {
      setLogs("Please run device init first", true);
      return;
    }

    try {
      // First save the image locally
      saveData();

      // Then send the iris data to the API
      await sendIrisDataToAPI();

      // If both operations are successful, navigate to IrisMatchPage
      _navigateToIrisMatchPage();
    } catch (e) {
      setLogs("Error saving image or sending data: $e", true);
    }
  }

  void _navigateToIrisMatchPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Capturepage(
          title: "Iris Match",
          deviceInfoObject: deviceInfoObject,
          imageFormatType: imageFormatType,
          timeout: timeout,
          minQuality: minQuality,
        ),
      ),
    ).then((result) {
      // Refresh the current page when returning from IrisMatchPage
      refreshPage();
    });
  }

  void saveData() async {
    try {
      int? width = deviceInfoObject?.Width;
      int? Height = deviceInfoObject?.Height;
      int bmpHeaderLength = BmpHeaderlength;

      int size = (width! * Height!) + bmpHeaderLength;
      Uint8List bImage1 = Uint8List(size);
      int ret = await MethodChannelMarvisAuth.GetImage(
          bImage1, size, 0, imageFormatType);
      String Base64 = await MethodChannelMarvisAuth.GetImageBase64();
      bImage1 = Constants.convertBase64StringToByteArray(Base64);
      List<int> intArrayFromAndroid =
          await MethodChannelMarvisAuth.GetIntArray();
      Uint8List bImage = Uint8List(intArrayFromAndroid[0]);
      bImage.setRange(0, intArrayFromAndroid[0], bImage1);

      if (ret == 0) {
        if (imageFormatType == ImageFormatType.BMP.name) {
          WriteImageFile("Bitmap.bmp", bImage);
        } else if (imageFormatType == ImageFormatType.K3.name) {
          WriteImageFile("K3.iso", bImage);
        } else if (imageFormatType == ImageFormatType.K7.name) {
          WriteImageFile("K7.iso", bImage);
        } else if (imageFormatType == ImageFormatType.RAW.name) {
          WriteImageFile("Raw.raw", bImage);
        }
      } else {
        String error =
            "${"Save Image Ret: $ret (${await MethodChannelMarvisAuth.GetErrorMessage(ret)}"})";
        setLogs(error, true);
      }
    } catch (e) {
      print(e.toString());
      saveData();
    }
  }

  void WriteImageFile(String filename, Uint8List byte) async {
    print('WriteImage ..Filename :: $filename');
    try {
      final directory = await getExternalStorageDirectory();
      final dirPath = '${directory?.path}/IrisData/Image/$filename';
      File file = File(dirPath);
      bool isExist = false;
      file.exists().then((result) => isExist = result);
      file.create(recursive: true);
      var myFile = File('$dirPath');
      var sink = myFile.openWrite();
      myFile.writeAsBytes(byte);
      await sink.flush();
      await sink.close();
      setLogs("Image Saved", false);
    } catch (e) {
      print(e.toString());
      WriteImageFile(filename, byte);
    }
  }

  Future<void> sendIrisDataToAPI() async {
    try {
      String base64Image = '';

      if (lastCapIrisData != null && lastCapIrisData.isNotEmpty) {
        base64Image = base64Encode(lastCapIrisData);
      } else {
        int? width = deviceInfoObject?.Width;
        int? Height = deviceInfoObject?.Height;
        int bmpHeaderLength = BmpHeaderlength;
        int size = (width! * Height!) + bmpHeaderLength;
        Uint8List bImage = Uint8List(size);

        int ret = await MethodChannelMarvisAuth.GetImage(
            bImage, size, 0, imageFormatType);

        if (ret == 0) {
          String Base64 = await MethodChannelMarvisAuth.GetImageBase64();
          bImage = Constants.convertBase64StringToByteArray(Base64);
          base64Image = base64Encode(bImage);
        } else {
          setLogs(
              "Failed to get image for API: ${await MethodChannelMarvisAuth.GetErrorMessage(ret)}",
              true);
          throw Exception("Failed to get image for API");
        }
      }

      final Map<String, dynamic> requestBody = {
        "AadhaarNumber": "615735525318",
        "IrisData": base64Image,
      };

      final response = await http.post(
        Uri.parse('https://divyangpcmc.altwise.in/api/aadhar/StoreIrisData'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setLogs("API Request Successful", false);
        print("API Response Body: ${response.body}");
        // Success - method will return successfully allowing navigation
      } else {
        setLogs("API Error: ${response.statusCode}", true);
        print("API Error Response: ${response.body}");
        throw Exception(
            "API request failed with status: ${response.statusCode}");
      }
    } catch (e) {
      setLogs("Error sending data to API", true);
      print("Exception occurred: $e");
      throw e; // Re-throw to prevent navigation on error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: const Text(
            'Iris Capture Screen',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        backgroundColor: Colors.yellow,
        foregroundColor: Colors.black,
        elevation: 2,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: FocusScope(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Iris Preview',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20.0),

                // Preview Card Section
                Card(
                  elevation: 4,
                  child: Container(
                    padding: const EdgeInsets.all(12.0),
                    child: getCardView(),
                  ),
                ),

                const SizedBox(height: 32.0),

                // Operations Section
                Text(
                  'Scanner Operations',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20.0),

                // Primary Actions Row
                Row(
                  children: [
                    Expanded(
                      child: CommonWidget.getBottomNavigationWidget(
                          context, deviceInfo, this),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => StopCapture(),
                        icon: const Icon(Icons.stop),
                        label: const Text('Stop Scan'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow,
                          foregroundColor: Colors.black,
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

                // Capture Controls
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          FocusScope.of(context).requestFocus(_focusNode);

                          // Show the loader dialog and set the flag
                          isLoaderDialogShowing = true;
                          CommonWidget.showLoaderDialog(
                              context, 'Please put eye on scanner');

                          Future.delayed(const Duration(milliseconds: 200), () {
                            AutoCapture();
                          });
                        },
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Start Capture'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => StopCapture(),
                        icon: const Icon(Icons.stop),
                        label: const Text('Stop Capture'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow,
                          foregroundColor: Colors.black,
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

                // Save Action
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => SaveImage(),
                    icon: const Icon(Icons.save),
                    label: const Text('Save Image'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFF76048), // Background color
                    foregroundColor: Colors.white, // Text color
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(20), // Rounded corners
                    ),
                    elevation: 5, // Shadow depth
                    textStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: Text('Skip'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonRow(String buttonText1, VoidCallback onPressed1,
      String buttonText2, VoidCallback onPressed2) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
            child: ElevatedButton(
          onPressed: onPressed1,
          child: Text(buttonText1),
        )),
        const SizedBox(width: 16),
        Expanded(
            child: ElevatedButton(
          onPressed: onPressed2,
          child: Text(buttonText2),
        )),
      ],
    );
  }

  Widget getCardView() {
    return SizedBox(
      height: 200,
      child: InkWell(
        onTap: () {
          String deviceStatus = "";
          bool isConnect =
              Provider.of<DeviceInfoProvider>(context, listen: false)
                  .isDeviceConnected;
          if (isConnect) {
            deviceStatus = "Connected";
          }
          if (deviceStatus == "Connected") {
            if (deviceInfoObject == null) {
              Fluttertoast.showToast(
                msg: "Please initialize the device first",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.blue,
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Capturepage(title: "Capture Page")),
              ).then((res) => _reload());
            }
          } else {
            Fluttertoast.showToast(
              msg: "Please connect device first",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.blue,
            );
          }
        },
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: getCaptureWidget(),
            ),
          ),
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
      return Image.memory(byteImage, width: 150.0, height: 150.0);
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

  @override
  void BottomDialogRefresh(bool isRefresh) {
    if (isRefresh) {
      _reload();
      getDeviceObject();
    }
  }

  // Added to fix "refreshPage isn't defined" error
  void refreshPage() {
    setState(() {});
  }
}

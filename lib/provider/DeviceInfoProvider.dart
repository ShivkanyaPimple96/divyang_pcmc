import 'package:flutter/cupertino.dart';

class DeviceInfoProvider extends ChangeNotifier {
  String deviceNameStatus = "";
  String deviceName = "";
  bool isDeviceConnected = false;

  String SerialNo = "";
  String Make = "";
  String Model = "";
  int Width = -1;
  int Height = -1;
  int DPI = -1;

  void setDeviceNameStatus(String deviceNameStatus) {
    this.deviceNameStatus = deviceNameStatus;
  }

  void setDeviceName(String deviceName) {
    this.deviceName = deviceName;
  }

  void setDeviceConnectedStatus(bool isDeviceConnected) {
    this.isDeviceConnected = isDeviceConnected;
  }

  void setSerialNo(String SerialNo) {
    this.SerialNo = SerialNo;
  }

  void setMake(String Make) {
    this.Make = Make;
  }

  void setModel(String Model) {
    this.Model = Model;
  }

  void setWidth(int Width) {
    this.Width = Width;
  }

  void setHeight(int Height) {
    this.Height = Height;
  }


  void setDPI(int DPI) {
    this.DPI = DPI;
  }
}

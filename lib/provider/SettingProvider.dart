import 'package:flutter/cupertino.dart';

class SettingProvider extends ChangeNotifier {
  int timeOut = 10000;
  int quality = 85;
  int imageType = 0;

  void settimeOut(int timeOut) {
    this.timeOut = timeOut;
    notifyListeners();
  }

  void setQuality(int quality) {
    this.quality = quality;
    notifyListeners();
  }

  void setImageType(int imageType) {
    this.imageType = imageType;
    notifyListeners();
  }

  int getTimeout() {
    return timeOut;
  }

  int getQuality() {
    return quality;
  }

  int getImageType() {
    return imageType;
  }
}

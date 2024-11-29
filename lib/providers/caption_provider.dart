import 'package:flutter/material.dart';

class Caption with ChangeNotifier {
  String _cap = 'Creating/Updating Databases...';
  List _uploadLog = [];
  void changeCap(String data) {
    _cap = data;
    notifyListeners();
  }
  String get cap => _cap;

  updateLogs(logs){
    _uploadLog = logs;
    notifyListeners();
  }
  List get updateLog => _uploadLog;
}

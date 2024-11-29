import 'package:flutter/material.dart';
import 'package:get/get.dart';

SnackBar getSnackBar(
        String snackText, Color snackBackColor, Color snackTextColor) =>
    SnackBar(
      content: Text(
        '$snackText',
        textAlign: TextAlign.center,
        style: TextStyle(color: snackTextColor),
      ),
      duration: Duration(seconds: 3),
      backgroundColor: snackBackColor,
      behavior: SnackBarBehavior.floating,
      elevation: 10.0,
    );

showGlobalSnackbar(
    String title, String msg, Color snackbgColor, Color snacktxtColor) {
  Get.snackbar(title, msg,
      duration: Duration(seconds: 2),
      snackPosition: SnackPosition.TOP,
      backgroundColor: snackbgColor,
      colorText: snacktxtColor);
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hexcolor/hexcolor.dart';

class Constants {
  static Color appColor = Hexcolor("#C9942E");
  static Color lightgreyColor = Hexcolor("#6c6c6c");
  static Color greyColor = Hexcolor("#454545");
  static Color bgColor = Hexcolor("#fdfdfd");
  static Color blackColor = Hexcolor("#212121");
  static Color statusBGColor = Hexcolor("#fbf5e9");
  static Color cancelBGColor = Hexcolor("#fff5f4");
  static Color confirmedBGColor = Hexcolor("#f7eee7");
  static Color shippedBGColor = Hexcolor("#f8f4eb");
  static Color deliverBGColor = Hexcolor("#eaf7ee");
  static Color boldTextColor = Hexcolor("#313131");
  static Color bgGreyColor = Hexcolor("#ebebeb");
  static Color dotColor = Hexcolor("#aeaeae");
  static Color homeBGColor = Hexcolor("#ebebeb");
  static Color imageBGColor = Hexcolor("#f5f3f3");
  static Color semiboldColor = Hexcolor("#282828");
  static Color toastBGColor = Hexcolor("#282828");

  // static MaterialColor themeColor = Colors.indigo[900];

  showItemCountToast() {
    Fluttertoast.showToast(
        msg: 'Select Quantity',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Constants.toastBGColor,
        textColor: Colors.white);
  }
}

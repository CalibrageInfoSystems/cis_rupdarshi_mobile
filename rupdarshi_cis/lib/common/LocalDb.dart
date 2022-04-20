import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class LocalData {
  static const String ISLOGIN = 'ISLOGIN';
  static const String USERID = 'UserID';
  static const String CARTINFO = 'CARTDATA';
  static const String USER_NAME = 'USERNAME';
  static const String USER_MOBILENUMBER = 'MOBILENUMBER';
  static const String USER_LASTNAME = 'lastname';
  static const String USER_FIRSTNAME = 'FirstName';
  static const String USER_PASSWARD = 'PASSWARD';
  static const String USER_ROLEID = 'ROLEID';
  static const String USER_ID = 'USERID';
  static const String STATUSTYPEID = 'USERID';
  static const String USERIDSRING = 'UserIDString';
  static const String PAYMENTTYPEID = 'PAYMENTTYPEID';
  static const String PAYMENTTYPE = 'PAYMENTTYPE';
  static const String LOGISTICID = 'LOGISTICID';
  static const String ITEMTYPEID = 'ITEMTYPEID';
  static const String CART_MODEL = 'CARTMODEL';

  static const bool USER_ISACTIVE = true;
  Future<bool> getBoolValuesSF(String keyBool) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return bool
    bool boolValue = prefs.getBool(keyBool);
    return boolValue;
  }

  Future<void> addBoolToSF(String keyBool, bool istrue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(keyBool, istrue);
  }

  Future<void> addStringToSF(String keySting, String inputValue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(keySting, inputValue);
  }

  Future<String> getStringValueSF(String keyBool) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return bool
    String boolValue = prefs.getString(keyBool);
    if (boolValue == null) {
      return '';
    }

    return boolValue;
  }

  Future<void> addIntToSF(String keySting, int inputValue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(keySting, inputValue);
  }

  Future<int> getIntToSF(String keyBool) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return bool
    int boolValue = prefs.getInt(keyBool);
    if (boolValue == null) {
      return 0;
    }

    return boolValue;
  }

  Future<bool> clearLocalDta() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return bool
    bool boolValue = prefs.clear() as bool;
    return boolValue;
  }

  //  Future<void> addDict(String keySting,  PostCartModel cartModel) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   prefs.setString(keySting, cartModel.toString());
  // }

  // Future<dynamic> getDict(String keyValue) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();

  //    Map userMap = jsonDecode(prefs.getString(LocalData.CART_MODEL));
  //   PostCartModel user = PostCartModel.fromJson(userMap);
  //   print(" ---- >>> Cart Details " + user.toString());
  //   return user;
  // }

  Future<void> removeStringToSF(String keyString) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(keyString);
  }
}

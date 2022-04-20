import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  String isLogin = "islogin";

//set data into shared preferences like this
  Future<void> setIsLogin(bool islogin) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(this.isLogin, islogin);
  }

  Future<bool> getIsLogin() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    bool auth_token;
    auth_token = pref.getBool(this.isLogin) ?? null;
    return auth_token;
  }

  Future<void> setString(String strKey, String strValue) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(strKey, strValue);
  }

  Future<String> getString(String strKey) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String strOutput;
    strOutput = pref.getString(strKey) ?? null;
    return strOutput;
  }

  Future<void> setUserID(int strValue) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('userid', strValue);
  }

  Future<int> getUserId() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    int strOutput;
    strOutput = pref.getInt('userid') ?? null;
    return strOutput;
  }

  Future<void> setUserIDString(String strValue) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('useridString', strValue);
  }

  Future<String> getUserIdString() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String strOutput;
    strOutput = pref.getString('useridString') ?? null;
    return strOutput;
  }
}

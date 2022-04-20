import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:progress_dialog/progress_dialog.dart';
import 'package:rupdarshi_cis/Service/ApiService.dart';
import 'package:rupdarshi_cis/common/Constants.dart';
import 'package:rupdarshi_cis/common/LocalDb.dart';
import 'package:rupdarshi_cis/common/SessionManager.dart';
import 'package:rupdarshi_cis/screens/ForgotPassword.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/signup_screen.dart';
import 'NewHomeScreen.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  ApiService apiConnector;
  int _state = 0;
  SharedPreferences preferences;
  ProgressDialog progressHud;
  LocalData localData = new LocalData();
  final formKey = GlobalKey<FormState>();

  final scaffoldKey = GlobalKey<ScaffoldState>();

  //We have two private fields here
  String _email;
  String _password;
  bool _showPassword = true;
  void _togglevisibility() {
    setState(() {
      _showPassword = !_showPassword;
    });
  }

  void _submitCommand() {
    final form = formKey.currentState;

    if (form.validate()) {
      form.save();
      setState(() {
        if (_state == 0) {
          animateButton();
        }
      });

      _loginCommand();
    }
  }

  void animateButton() {
    setState(() {
      _state = 1;
    });
  }

  void _loginCommand() async {
    bool isNetworkavailable = await isNetAvailable();
    if (isNetworkavailable) {
      // progressHud.show();
      // Show login details in snackbar
      var baseurl = ApiService.baseUrl;
      var url = '$baseurl/User/CustomerLogin';
      print(url);

      Map data = {'UserName': _email, 'Password': _password};
      print('Request :' + data.toString());

      String body = json.encode(data);

      http.Response response = await http
          .post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      )
          .then((value) {
        // progressHud.hide();
        int statusCode = value.statusCode;
        String res = value.body;
        print(res);
        setState(() {
          _state = 0;
        });
        if (statusCode == 200) {
          var data = json.decode(res);
          if (data['IsSuccess'] == true) {
            apiConnector.globalToast(data['EndUserMessage']);
            // setState(() {
            //   _state = 2;
            // });
            // final snackbar = SnackBar(
            //   content: Text(data['EndUserMessage']),
            // );
            //scaffoldKey.currentState.showSnackBar(snackbar);
            if (data['Result']['UserInfos'] != null) {
              print(' ====> User ID id :' +
                  data['Result']['UserInfos']['Id'].toString());
              SessionManager().setUserID(data['Result']['UserInfos']['Id']);
              SessionManager()
                  .setUserIDString(data['Result']['UserInfos']['UserId']);
              SessionManager().setIsLogin(true);
              SessionManager().setString('userinfo', res);
              // SessionManager()
              //     .getString('userinfo')
              //     .then((value) => print('User data from session :$value'));
              preferences.setInt("ServiceTypeId",
                  data['Result']['UserInfos']['ServiceTypeId']);
              preferences.setInt("UserID", data['Result']['UserInfos']['Id']);

              localData.addIntToSF(
                  LocalData.USERID, data['Result']['UserInfos']['Id']);
              localData.addIntToSF(LocalData.STATUSTYPEID,
                  data['Result']['UserInfos']['ServiceTypeId']);

              localData.addIntToSF(LocalData.LOGISTICID,
                  data['Result']['UserInfos']['LogisticOparatorId']);

              localData.addStringToSF(
                  LocalData.USERIDSRING, data['Result']['UserInfos']['UserId']);
              localData.addIntToSF(LocalData.PAYMENTTYPEID,
                  data['Result']['UserInfos']['PaymentTypeid']);
              localData.addStringToSF(LocalData.PAYMENTTYPE,
                  data['Result']['UserInfos']['PaymentType']);
              localData.addStringToSF(LocalData.USER_PASSWARD,
                  data['Result']['UserInfos']['Password']);

              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (BuildContext context) => NewHomeScreen()));
              print(data['Result']['UserInfos']['UserId']);
            }
          } else {
            // setState(() {
            //   _state = 3;
            // });
            // final snackbar = SnackBar(
            //   content: Text(data['EndUserMessage']),
            // );
            // scaffoldKey.currentState.showSnackBar(snackbar);
            apiConnector.globalToast(data['EndUserMessage']);
          }
        } else {
          // setState(() {
          //   _state = 3;
          // });
          // final snackbar = SnackBar(
          //   content: Text('Something went wrong ..'),
          // );
          // scaffoldKey.currentState.showSnackBar(snackbar);
          apiConnector.globalToast(data['EndUserMessage']);
        }
      });
    } else {
      apiConnector.globalToast("Please check internet connection");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    apiConnector = new ApiService();

    userNameController.clear();
    passwordController.clear();

    getPrefs();
  }

  Future getPrefs() async {
    preferences = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    Widget setUpButtonChild() {
      if (_state == 0) {
        return Container(
          height: 55,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Text(
                "Login",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                ),
              )
            ],
          ),
        );
      } else if (_state == 1) {
        return CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        );
      } else if (_state == 3) {
        return new Container(
          height: 55,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Text(
                "Login",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                ),
              )
            ],
          ),
        );
      } else {
        return new Container(
          height: 55,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Text(
                "Login",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                ),
              )
            ],
          ),
        );
      }
    }

    var text = new RichText(
      text: new TextSpan(
        style: new TextStyle(
          fontSize: 14.0,
          color: Colors.black,
        ),
        children: <TextSpan>[
          // new TextSpan(text: 'Don\'t have an account? '),
          new TextSpan(
              text: 'New user?',
              style: new TextStyle(
                  color: Constants.lightgreyColor,
                  fontSize: 14,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w500)),
          new TextSpan(
              text: '  Sign Up',
              style: new TextStyle(
                  color: Constants.greyColor,
                  fontSize: 14,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
    return WillPopScope(
      onWillPop: () {
        SystemNavigator.pop();
      },
      child: Scaffold(
        backgroundColor: Constants.bgColor,
        key: scaffoldKey,
        // appBar: AppBar(
        //   title: Text('Vendor Login'),
        //   backgroundColor: Colors.white,
        //   automaticallyImplyLeading: false,
        // ),

        bottomNavigationBar: BottomAppBar(
          color: Colors.white,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Stack(alignment: Alignment.bottomCenter, children: <Widget>[
                GestureDetector(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                        height: 20,
                        child: Column(
                          children: [
                            text,
                          ],
                        )),
                  ),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => SignUpScreen()));
                  },
                ),
              ])
            ],
          ),
        ),
        body: Container(
          height: double.maxFinite,
          color: Colors.white54,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Image.asset(
                    'assets/logo-login.jpg',
                    height: 70,
                    // width: 250,
                    fit: BoxFit.fill,
                  ),
                ),
                SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              'Welcome Back,',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Montserrat',
                                  fontSize: 20,
                                  color: Constants.greyColor),
                            )),
                        Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              'Sign in to continue ',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Montserrat',
                                  fontSize: 14,
                                  color: Constants.lightgreyColor),
                            )),
                        SizedBox(height: 40),
                        TextFormField(
                          controller: userNameController,
                          cursorColor: Constants.appColor,
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderRadius: new BorderRadius.circular(12.0),
                              borderSide: BorderSide(
                                  color: Constants.greyColor, width: 1.5),
                            ),
                            labelText: 'Username',
                            labelStyle: TextStyle(
                                fontSize: 14,
                                color: Constants.lightgreyColor,
                                fontWeight: FontWeight.w600),
                            border: new OutlineInputBorder(
                              borderRadius: new BorderRadius.circular(12.0),
                            ),
                          ),
                          validator: (val) => val.length < 1
                              ? 'Username is required'
                              : val.length < 4
                                  ? 'Username is too short '
                                  : null,

                          // validator: (val) => !EmailValidator.Validate(val, true)
                          //     ? 'Please provide a valid email.'
                          //     : null,
                          onSaved: (val) => _email = val,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          controller: passwordController,
                          cursorColor: Constants.appColor,
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderRadius: new BorderRadius.circular(12.0),
                              borderSide: BorderSide(
                                  color: Constants.greyColor, width: 1.5),
                            ),
                            labelText: 'Password',
                            labelStyle: TextStyle(
                                color: Constants.lightgreyColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w600),
                            border: new OutlineInputBorder(
                              borderRadius: new BorderRadius.circular(12.0),
                              borderSide: new BorderSide(),
                            ),
                            suffixIcon: GestureDetector(
                              onTap: () {
                                _togglevisibility();
                              },
                              child: Icon(
                                _showPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Constants.lightgreyColor,
                              ),
                            ),
                          ),
                          validator: (val) => val.length < 1
                              ? 'Password is required'
                              : val.length < 4
                                  ? 'Password is too short'
                                  : null,
                          onSaved: (val) => _password = val,
                          obscureText: _showPassword,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: GestureDetector(
                            child: Align(
                                alignment: Alignment.bottomRight,
                                child: Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                      color: Constants.greyColor,
                                      fontFamily: 'Montserrat',
                                      // fontWeight: FontWeight.w600,
                                      fontSize: 12),
                                )),
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => ForgotPassword()));
                            },
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        new MaterialButton(
                          child: setUpButtonChild(),
                          onPressed: _submitCommand,
                          elevation: 4.0,
                          minWidth: double.infinity,
                          //  height: 48.0,
                          color: Constants.appColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> isNetAvailable() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }
    return false;
  }
}

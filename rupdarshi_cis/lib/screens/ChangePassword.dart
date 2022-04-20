import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rupdarshi_cis/Model/ForgotPasswordResponse.dart';
import 'package:rupdarshi_cis/Service/ApiService.dart';
import 'package:rupdarshi_cis/common/Constants.dart';
import 'package:rupdarshi_cis/common/LocalDb.dart';
import 'package:rupdarshi_cis/common/SessionManager.dart';
import 'package:rupdarshi_cis/screens/login_screen.dart';

extension CapExtension1 on String {
  String get inCapsF => '${this[0].toUpperCase()}${this.substring(1)}';
  String get allInCapsF => this.toUpperCase();
}

Pattern passwordPattern = r'^(?=.*[0-9]+.*)(?=.*[a-zA-Z]+.*)[0-9a-zA-Z]{6,}$';
RegExp regex = new RegExp(passwordPattern);

class ChangePassword extends StatefulWidget {
  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  TextEditingController oldPasswordController = new TextEditingController();
  TextEditingController newPasswordController = new TextEditingController();
  TextEditingController confirmPasswordController = new TextEditingController();

  final formKey = GlobalKey<FormState>();
  LocalData localData = new LocalData();
  String userPassword = "";
  int _state = 0;

  ApiService apiConnector;
  ForgotPasswordResponse forgotPasswordResponse;
  String userid;
  bool _showOldPassword = true;
  void _togglevisibility1() {
    setState(() {
      _showOldPassword = !_showOldPassword;
    });
  }

  bool _showNewPassword = true;
  void _togglevisibility2() {
    setState(() {
      _showNewPassword = !_showNewPassword;
    });
  }

  bool _showConPassword = true;
  void _togglevisibility3() {
    setState(() {
      _showConPassword = !_showConPassword;
    });
  }

  @override
  void initState() {
    super.initState();
    userPassword = "";
    apiConnector = new ApiService();
    localData = new LocalData();
    forgotPasswordResponse = new ForgotPasswordResponse();

    SessionManager().getUserIdString().then((value) {
      userid = value.toString();
      print('User ID from Profile :' + userid.toString());
    });

    localData.getStringValueSF(LocalData.USER_PASSWARD).then((value) {
      setState(() {
        userPassword = value;
        print('user Password :' + userPassword);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    bool validateStructure(String value) {
      String pattern =
          r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{6,}$';
      RegExp regExp = new RegExp(pattern);
      return regExp.hasMatch(value);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Change Password',
            style: TextStyle(fontSize: 18, color: Colors.white),
            overflow: TextOverflow.ellipsis,
            maxLines: 1),
        backgroundColor: Constants.appColor,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
            // Navigator.of(context, rootNavigator: true).pop();
            // Navigator.of(context).pushReplacement(
            //     new MaterialPageRoute(builder: (context) => HomeScreen()));
          },
          child: Icon(
            Icons.keyboard_arrow_left,
            size: 35,
            color: Colors.white, // add custom icons also
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: formKey,
              child: Container(
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/change-password.png',
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 30.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Please enter current and new password',
                              style: TextStyle(
                                fontSize: 18,
                              )),
                        ],
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 30.0, left: 10, right: 10),
                      child: Column(
                        children: [
                          TextFormField(
                            keyboardType: TextInputType.text,
                            controller: oldPasswordController,
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderRadius: new BorderRadius.circular(8.0),
                                borderSide: BorderSide(
                                    color: Constants.blackColor, width: 1.5),
                              ),
                              labelText: 'Current Password*',
                              labelStyle: TextStyle(
                                color: Constants.greyColor,
                                // fontWeight: FontWeight.bold
                              ),
                              border: new OutlineInputBorder(
                                borderRadius: new BorderRadius.circular(8.0),
                              ),
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  _togglevisibility1();
                                },
                                child: Icon(
                                  _showOldPassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Constants.greyColor,
                                ),
                              ),
                            ),
                            obscureText: _showOldPassword,
                            validator: (val) => val.length < 1
                                ? 'Current Password is required'
                                : val.length < 4
                                    ? 'Current Password is too short'
                                    : null,
                          ),
                          Container(
                            height: 10,
                          ),
                          TextFormField(
                            keyboardType: TextInputType.text,
                            obscureText: _showNewPassword,
                            controller: newPasswordController,
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderRadius: new BorderRadius.circular(8.0),
                                borderSide: BorderSide(
                                    color: Constants.blackColor, width: 1.5),
                              ),
                              labelText: 'New Password* (example: Abcd@123)',
                              labelStyle: TextStyle(
                                color: Constants.greyColor,
                                // fontWeight: FontWeight.bold
                              ),
                              border: new OutlineInputBorder(
                                borderRadius: new BorderRadius.circular(8.0),
                              ),
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  _togglevisibility2();
                                },
                                child: Icon(
                                  _showNewPassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Constants.greyColor,
                                ),
                              ),
                            ),
                            validator: (val) {
                              if (val.length < 1) {
                                return 'New Password is required';
                              } else if (!validateStructure(val)) {
                                return 'Min 6 letters with Numeric and One Special Charector Atleast';
                              } else {
                                return null;
                              }
                            },
                          ),
                          Container(
                            height: 10,
                          ),
                          TextFormField(
                            keyboardType: TextInputType.text,
                            obscureText: _showConPassword,
                            controller: confirmPasswordController,
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderRadius: new BorderRadius.circular(8.0),
                                borderSide: BorderSide(
                                    color: Constants.blackColor, width: 1.5),
                              ),
                              labelText: 'Confirm Password*',
                              labelStyle: TextStyle(
                                color: Constants.greyColor,
                                // fontWeight: FontWeight.bold
                              ),
                              border: new OutlineInputBorder(
                                borderRadius: new BorderRadius.circular(8.0),
                              ),
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  _togglevisibility3();
                                },
                                child: Icon(
                                  _showConPassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Constants.greyColor,
                                ),
                              ),
                            ),
                            validator: (val) => val.length < 1
                                ? 'Confirm Password is required'
                                : val.length < 4
                                    ? 'Confirm Password is too short'
                                    : null,
                          ),
                          Container(
                            width: double.infinity,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 4.0, right: 4.0, top: 30),
                              child: RaisedButton(
                                  color: Constants.appColor,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Text(
                                      " Change Password ",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  onPressed: () {
                                    if (formKey.currentState.validate()) {
                                      //                                   setState(() {
                                      //   if (_state == 0) {
                                      //     animateButton();
                                      //   }
                                      // });
                                      if (oldPasswordController.text ==
                                          userPassword) {
                                        if (newPasswordController.text ==
                                            confirmPasswordController.text) {
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return Center(
                                                  child: Container(
                                                    // color: Colors.red,
                                                    height: 20,
                                                    width: 20,
                                                    child:
                                                        CircularProgressIndicator(),
                                                  ),
                                                );
                                              });
                                          changePasswordAPICall();
                                        } else {
                                          apiConnector.globalToast(
                                              'New Password & Confirm Password Must Match');
                                        }
                                      } else {
                                        apiConnector.globalToast(
                                            'Invalid Current Password');
                                      }
                                    }
                                  }),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void animateButton() {
    setState(() {
      _state = 1;
    });
  }

  changePasswordAPICall() async {
    String finalUrl = ApiService.baseUrl + ApiService.changePasswordURL;

    Map<String, dynamic> data = {
      "UserId": userid,
      "OldPassword": oldPasswordController.text,
      "NewPassword": newPasswordController.text,
      "ConfirmPassword": confirmPasswordController.text
    };

    print('Request Data :' + data.toString());

    apiConnector.postAPICall(finalUrl, data).then((response) {
      print(response);
      Navigator.of(context, rootNavigator: true).pop();
      if (response["IsSuccess"] == true) {
        print('++++++++++++++++++++++++ ' + response["EndUserMessage"]);
        apiConnector.globalToast(response['EndUserMessage']);
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => LoginPage()));
      } else {
        apiConnector.globalToast(response['EndUserMessage']);
      }
    });
  }
}

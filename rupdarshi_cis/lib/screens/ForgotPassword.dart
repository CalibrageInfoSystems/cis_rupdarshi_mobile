import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rupdarshi_cis/Model/ForgotPasswordResponse.dart';
import 'package:rupdarshi_cis/Service/ApiService.dart';
import 'package:rupdarshi_cis/common/Constants.dart';
import 'package:rupdarshi_cis/common/SessionManager.dart';
import 'package:rupdarshi_cis/screens/login_screen.dart';

extension CapExtension1 on String {
  String get inCapsF => '${this[0].toUpperCase()}${this.substring(1)}';
  String get allInCapsF => this.toUpperCase();
}

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController textController = new TextEditingController();
  ApiService apiConnector;
  ForgotPasswordResponse forgotPasswordResponse;
  String userid;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    apiConnector = new ApiService();
    forgotPasswordResponse = new ForgotPasswordResponse();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forgot Password',
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
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/forgot-password.png',
                    // height: 14,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Forgot Password?',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Constants.boldTextColor)),
                        Text(
                            'Please enter your email address to get your password.',
                            style: TextStyle(
                              fontSize: 16,
                            )),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30.0),
                    child: TextFormField(
                      keyboardType: TextInputType.text,
                      controller: textController,
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(8.0),
                          borderSide: BorderSide(
                              color: Constants.blackColor, width: 1.5),
                        ),
                        labelText: 'Enter Email/User Name*',
                        labelStyle: TextStyle(
                          color: Constants.lightgreyColor,
                          // fontWeight: FontWeight.bold
                        ),
                        border: new OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(12.0),
                        ),
                      ),
                      validator: (val) => val.length < 1
                          ? 'User name is required'
                          : val.length < 2
                              ? 'User name is too short'
                              : null,
                    ),
                  ),
                  Container(
                    height: 20,
                  ),
                  Container(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: RaisedButton(
                          color: Constants.appColor,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              " Submit ",
                              style: TextStyle(
                                // fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          onPressed: () {
                            //                        CircularProgressIndicator(
                            //   valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            // );
                            if (formKey.currentState.validate()) {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Center(
                                      child: Container(
                                        // color: Colors.red,
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  });
                              forgotPasswordAPICall(textController.text);
                            }
                          }),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  forgotPasswordAPICall(String userID) async {
    String finalUrl =
        ApiService.baseUrl + ApiService.forgotPasswordURL + userID + '/';

    await apiConnector.getAPICall(finalUrl).then((response) {
      forgotPasswordResponse = ForgotPasswordResponse.fromJson(response);
      if (forgotPasswordResponse.isSuccess == true) {
        print('Successs code ---------- ' + userID);
        Navigator.of(context, rootNavigator: true).pop();
        apiConnector.globalToast(forgotPasswordResponse.endUserMessage.inCapsF);
        print('Successs ---------- ' + userID);
        Navigator.of(context)
            .push(new MaterialPageRoute(builder: (context) => new LoginPage()));
      } else {
        Navigator.of(context, rootNavigator: true).pop();
        apiConnector.globalToast(forgotPasswordResponse.endUserMessage);
      }
    });
  }
}

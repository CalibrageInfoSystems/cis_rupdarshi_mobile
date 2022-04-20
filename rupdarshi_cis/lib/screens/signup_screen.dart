import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:progress_dialog/progress_dialog.dart';
import 'package:rupdarshi_cis/Model/StatesResModel.dart';
import 'package:rupdarshi_cis/Service/ApiService.dart';
import 'package:rupdarshi_cis/common/Constants.dart';
import 'package:rupdarshi_cis/common/SessionManager.dart';
import 'package:rupdarshi_cis/screens/login_screen.dart';
import 'package:rupdarshi_cis/Model/LogisticResponse.dart';

class SignUpScreen extends StatefulWidget {
  SignUpScreen({Key key}) : super(key: key);

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  TextEditingController firstnameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController middileNameController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController emaileController = TextEditingController();
  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController companyNameController = TextEditingController();
  TextEditingController gstNoController = TextEditingController();
  TextEditingController address1Controller = TextEditingController();
  TextEditingController address2Controller = TextEditingController();
  TextEditingController landMarkController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController districtController = TextEditingController();
  TextEditingController pincodeController = TextEditingController();
  TextEditingController billingNameController = TextEditingController();
  TextEditingController billingMobileNoController = TextEditingController();
  TextEditingController billingAddrs1Controller = TextEditingController();
  TextEditingController billingAddrs2Controller = TextEditingController();
  TextEditingController billinglanMarkController = TextEditingController();
  TextEditingController billingcityController = TextEditingController();
  TextEditingController billingdistrictController = TextEditingController();
  TextEditingController billingpincodeController = TextEditingController();
  TextEditingController shippingNameController = TextEditingController();
  TextEditingController shippingMobileNoController = TextEditingController();
  TextEditingController shippingAddrs1Controller = TextEditingController();
  TextEditingController shippingAddrs2Controller = TextEditingController();
  TextEditingController shippinglanMarkController = TextEditingController();
  TextEditingController shippingcityController = TextEditingController();
  TextEditingController shippingdistrictController = TextEditingController();
  TextEditingController shippingpincodeController = TextEditingController();

  bool checkBoxValue = false;
  ApiService apiConnector;
  String stateError;
  String billingStError;
  String shippingStError;
  String logisticError;
  bool complete = false;
  _validateForm() {
    bool _isValid = _key.currentState.validate();
    if (selectedState == null) {
      setState(() => stateError = "State is required");
      _isValid = false;
    }
    if (selectedBillingState == null) {
      setState(() => billingStError = "State is required");
      _isValid = false;
    }
    if (selectedShippingState == null) {
      setState(() => shippingStError = "State is required");
      _isValid = false;
    }
    if (logisticListResult == null) {
      setState(() => logisticError = "Logistics is required");
      _isValid = false;
    }
  }

  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  ProgressDialog progressHud;
  SessionManager pref = new SessionManager();
  var stateresModel = null;
  List<ListResult> states = [];
  LogisticResponse logisticResponse;
  LogisticListResult logisticListResult;
  List<LogisticListResult> logistics;
  ListResult selectedState;
  ListResult selectedBillingState;
  ListResult selectedShippingState;
  int _state = 1;
  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _agreedToTOS = true;
  int currentstep = 0;
  int stepCount = 1;
  String _firstName,
      _middleName,
      _lastname,
      _userName,
      _contactNumber,
      _mobileNumber,
      _email,
      _businessName,
      _gSTIN,
      _country,
      _statestr,
      _city,
      _district,
      _address1,
      _address2,
      _address3,
      _landmark,
      _password,
      _confirmPassword,
      _pincode,
      _stateError,
      _stateName,
      _billingName,
      _billingMobileNumber,
      _billngAddrs1,
      _billngAddrs2,
      _billnglandMark,
      _billngACity,
      _billngDistrict,
      _billngstateName,
      _billngPincode,
      _shippingName,
      _shippingMobileNumber,
      _shippingAddrs1,
      _shippingAddrs2,
      _shippinglandMark,
      _shippingACity,
      _shippingDistrict,
      _shippingstateName,
      _shippingPincode;
  int _roleid = 1, _serviceTypeId = 4;
  int billingStateID = 0, shippingStateID = 0;
  void _setAgreedToTOS(bool newValue) {
    setState(() {
      _agreedToTOS = newValue;
    });
  }

  @override
  void initState() {
    super.initState();
    stepCount = 1;
    selectedState = null;
    stateresModel = null;
    selectedBillingState = null;
    selectedShippingState = null;
    checkBoxValue = false;
    apiConnector = new ApiService();
    logisticResponse = new LogisticResponse();
    logisticListResult = null;

    logistics = new List<LogisticListResult>();

    _getstates();
    getLoggisticOparaters();
  }

  void _getstates() {
    ApiService.getStates().then((res) {
      // print(res);
      setState(() {
        states = statesResModelFromJson(res.body).listResult;
        print("states comming => " + states.length.toString());
      });
    });
  }

  void _submitCommand() {
    final form = formKey.currentState;

    if (_validateForm() != false && form.validate() && _stateName != "") {
      setState(() {
        _state = 1;
      });
      form.save();
      setState(() {
        if (_state == 0) {
          animateButton();
        }
      });
      if (null != selectedState) {
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
        _signUpCommand();
      } else {
        apiConnector.globalToast('Please Select State ..');
        // final snackbar = SnackBar(
        //   content: Text('Please Select State ..'),
        // );
        // scaffoldKey.currentState.showSnackBar(snackbar);
      }
    }
  }

  void animateButton() {
    setState(() {
      _state = 1;
    });
  }

  void _signUpCommand() async {
    bool isNetworkavailable = await isNetAvailable();
    if (isNetworkavailable) {
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
      // progressHud.show();
      // Show login details in snackbar
      var baseurl = ApiService.baseUrl;
      var url = '$baseurl/User/Register';
      print(url);

      Map data = {
        "Id": 0,
        "FirstName": firstnameController.text,
        "MiddleName": middileNameController.text == ""
            ? null
            : middileNameController.text,
        "LastName": lastNameController.text,
        "UserName": usernameController.text,
        "MobileNumber": mobileNumberController.text,
        "Email": emaileController.text,
        "BusinessName": companyNameController.text,
        "GSTIN": gstNoController.text,
        "Address1": address1Controller.text,
        "Address2": address2Controller.text,
        "Landmark": landMarkController.text,
        "Pincode": pincodeController.text,
        "StateId": selectedState.id,
        "District": districtController.text,
        "City": cityController.text,
        "ServiceTypeId": 6,
        "PreferlogisticOparatorId": logisticListResult.id,
        "PaymentTypeId": 1,
        "CreatedByUserId": 1,
        "UpdatedByUserId": 1,
        "Password": passwordController.text,
        "ConfirmPassword": confirmPasswordController.text,
        "Addresses": [
          {
            "Id": 0,
            "VendorId": 0,
            "StateId": billingStateID,
            "District": billingdistrictController.text,
            "City": billingcityController.text,
            "Landmark": billinglanMarkController.text,
            "Address1": billingAddrs1Controller.text,
            "Address2": billingAddrs2Controller.text,
            "Pincode": billingpincodeController.text,
            "MobileNumber": billingMobileNoController.text,
            "IsActive": true,
            "Name": billingNameController.text,
            "AddressTypeId": 20,
            "Aproved": 1
          },
          {
            "Id": 0,
            "VendorId": 0,
            "StateId": checkBoxValue == true ? billingStateID : shippingStateID,
            "District": checkBoxValue == true
                ? billingdistrictController.text
                : shippingdistrictController.text,
            "City": checkBoxValue == true
                ? billingcityController.text
                : shippingcityController.text,
            "Landmark": checkBoxValue == true
                ? billinglanMarkController.text
                : shippinglanMarkController.text,
            "Address1": checkBoxValue == true
                ? billingAddrs1Controller.text
                : shippingAddrs1Controller.text,
            "Address2": checkBoxValue == true
                ? billingAddrs2Controller.text
                : shippingAddrs2Controller.text,
            "Pincode": checkBoxValue == true
                ? billingpincodeController.text
                : shippingpincodeController.text,
            "MobileNumber": checkBoxValue == true
                ? billingMobileNoController.text
                : shippingMobileNoController.text,
            "IsActive": true,
            "Name": checkBoxValue == true
                ? billingNameController.text
                : shippingNameController.text,
            "AddressTypeId": 21,
            "Aproved": 1
          }
        ]
      };

      print('Request Data :' + data.toString());
      String body = json.encode(data);
      print('Request Data :' + body);
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
        Navigator.of(context, rootNavigator: true).pop();
        if (statusCode == 200) {
          var data = json.decode(res);
          if (data['IsSuccess'] == true) {
            _key.currentState.reset();
            setState(() {
              _state = 1;
            });

            apiConnector.globalToast(data['EndUserMessage']);
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => LoginPage()));
          } else {
            apiConnector.globalToast(data['EndUserMessage']);
          }
        } else {
          apiConnector.globalToast("Something went wrong ..");
        }
      });
      // Navigator.of(context, rootNavigator: true).pop();
    } else {
      apiConnector.globalToast("Please check internet connection");
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  getLoggisticOparaters() {
    String loggisticURL = ApiService.baseUrl + ApiService.logisticOperatorURL;

    apiConnector.getAPICall(loggisticURL).then((response) {
      logisticResponse = LogisticResponse.fromJson(response);
      print('Logistic uRl ' + loggisticURL);

      if (logisticResponse.isSuccess == true) {
        setState(() {
          logistics = logisticResponse.listResult;
          //  logisticListResult = logisticResponse.listResult;
        });
      }
    });
  }

  next() {
    if (_validateForm() != false && _key.currentState.validate()) {
      print(" -- > " + "Steps Completed");

      if (currentstep + 1 == 3) {
        print(" -- > " + "Steps Completed");
        _signUpCommand();
      } else {
        goto(currentstep + 1);
        setState(() => complete = true);
        setState(() {
          // stateError = null;
          billingStError = null;
          logisticError = null;
          shippingStError = null;
        });
      }
    }
    // goto(currentstep + 1);
    // setState(() => true);
  }

  goto(int step) {
    setState(() => currentstep = step);
  }

  cancel() {
    // if (_key.currentState.validate()) {
    setState(() {
      if (currentstep > 0) {
        currentstep = currentstep - 1;
      } else {
        currentstep = 0;
      }
    });
    // }
  }

  @override
  Widget build(BuildContext context) {
    bool validateStructure(String value) {
      String pattern =
          r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
      RegExp regExp = new RegExp(pattern);
      return regExp.hasMatch(value);
    }

    List<Step> steps = [
      Step(
          // state: StepState.indexed,
          isActive: currentstep >= 0,
          title: const Text(''),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "BASIC DETAILS",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                inputFormatters: [
                  // ignore: deprecated_member_use
                  new WhitelistingTextInputFormatter(RegExp("[a-zA-Z]")),
                ],
                keyboardType: TextInputType.text,
                controller: firstnameController,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(12.0),
                    borderSide:
                        BorderSide(color: Constants.greyColor, width: 1),
                  ),
                  labelText: 'First Name*',
                  labelStyle: TextStyle(
                      fontSize: 14,
                      color: Constants.lightgreyColor,
                      fontWeight: FontWeight.w600),
                  border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(8.0),
                  ),
                ),
                validator: (val) => val.length < 1
                    ? 'First Name is required'
                    : val.length < 4
                        ? 'First Name is too short.. '
                        : null,
                // onSaved: (val) => _firstName = val,
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      inputFormatters: [
                        // ignore: deprecated_member_use
                        new WhitelistingTextInputFormatter(RegExp("[a-zA-Z]")),
                      ],
                      keyboardType: TextInputType.text,
                      controller: middileNameController,
                      decoration: InputDecoration(
                        labelText: 'Middle Name',
                        focusedBorder: OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(12.0),
                          borderSide:
                              BorderSide(color: Constants.greyColor, width: 1),
                        ),
                        labelStyle: TextStyle(
                            fontSize: 14,
                            color: Constants.lightgreyColor,
                            fontWeight: FontWeight.w600),
                        border: new OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(8.0),
                          borderSide: new BorderSide(
                            color: Constants.lightgreyColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: TextFormField(
                      inputFormatters: [
                        // ignore: deprecated_member_use
                        new WhitelistingTextInputFormatter(RegExp("[a-zA-Z]")),
                      ],
                      keyboardType: TextInputType.text,
                      controller: lastNameController,
                      decoration: InputDecoration(
                        labelText: 'Last Name*',
                        labelStyle: TextStyle(
                            fontSize: 14,
                            color: Constants.lightgreyColor,
                            fontWeight: FontWeight.w600),
                        border: new OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(8.0),
                          borderSide: new BorderSide(
                            color: Constants.lightgreyColor,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(12.0),
                          borderSide:
                              BorderSide(color: Constants.greyColor, width: 1),
                        ),
                      ),

                      validator: (val) => val.length < 1
                          ? 'Last Name is required'
                          : val.length < 4
                              ? 'Last Name is too short.. '
                              : null,
                      // onSaved: (val) => _lastname = val,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              TextFormField(
                keyboardType: TextInputType.text,
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: 'User Name*',
                  labelStyle: TextStyle(
                      fontSize: 14,
                      color: Constants.lightgreyColor,
                      fontWeight: FontWeight.w600),
                  border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(8.0),
                    borderSide: new BorderSide(
                      color: Constants.lightgreyColor,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(12.0),
                    borderSide:
                        BorderSide(color: Constants.greyColor, width: 1),
                  ),
                ),
                validator: (val) => val.length < 1
                    ? 'User Name is required'
                    : val.length < 4
                        ? 'User Name is too short.. '
                        : null,
                // onSaved: (val) => _userName = val,
              ),
              SizedBox(
                height: 5,
              ),
              TextFormField(
                keyboardType: TextInputType.text,
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Password * (example: Abcd@123)',
                  labelStyle: TextStyle(
                      fontSize: 14,
                      color: Constants.lightgreyColor,
                      fontWeight: FontWeight.w600),
                  border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(8.0),
                    borderSide: new BorderSide(
                      color: Constants.lightgreyColor,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(12.0),
                    borderSide:
                        BorderSide(color: Constants.greyColor, width: 1),
                  ),
                ),
                validator: (val) {
                  if (val.length < 1) {
                    return 'Password is required';
                  } else if (!validateStructure(val)) {
                    return 'min 6 letters with Numeric and One Special Charector Atleast';
                  } else {
                    _password = val;
                    return null;
                  }
                },
                obscureText: true,
              ),
              SizedBox(
                height: 5,
              ),
              TextFormField(
                keyboardType: TextInputType.text,
                controller: confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm Password*',
                  labelStyle: TextStyle(
                      fontSize: 14,
                      color: Constants.lightgreyColor,
                      fontWeight: FontWeight.w600),
                  border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(8.0),
                    borderSide: new BorderSide(
                      color: Constants.lightgreyColor,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(12.0),
                    borderSide:
                        BorderSide(color: Constants.greyColor, width: 1),
                  ),
                ),
                validator: (val) {
                  if (val.length < 1) {
                    return 'Confirm Password is required';
                  } else if (val != _password) {
                    print('Password :$_password and Confirm password : $val');
                    return 'Your Confirm Password Must Match with password..';
                  } else {
                    return null;
                  }
                },
                // onSaved: (val) => _confirmPassword = val,
                obscureText: true,
              ),
              SizedBox(
                height: 5,
              ),
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                controller: emaileController,
                decoration: InputDecoration(
                  labelText: 'Email*',
                  // labelStyle: TextStyle(
                  //   color: Constants.boldTextColor,
                  // ),
                  labelStyle: TextStyle(
                      fontSize: 14,
                      color: Constants.lightgreyColor,
                      fontWeight: FontWeight.w600),
                  border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(8.0),
                    borderSide: new BorderSide(
                      color: Constants.lightgreyColor,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(12.0),
                    borderSide:
                        BorderSide(color: Constants.greyColor, width: 1),
                  ),
                ),
                validator: (val) => val.length < 1
                    ? 'Email is required'
                    : val.length < 4
                        ? 'Email is too short.. '
                        : null,
                // onSaved: (val) => _email = val,
              ),
              SizedBox(
                height: 5,
              ),
              TextFormField(
                keyboardType: TextInputType.text,
                inputFormatters: <TextInputFormatter>[
                  WhitelistingTextInputFormatter.digitsOnly
                ],
                controller: mobileNumberController,
                maxLength: 10,
                decoration: InputDecoration(
                  counterText: "",
                  labelText: 'Mobile Number*',
                  labelStyle: TextStyle(
                      fontSize: 14,
                      color: Constants.lightgreyColor,
                      fontWeight: FontWeight.w600),
                  border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(8.0),
                    borderSide: new BorderSide(
                      color: Constants.lightgreyColor,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(12.0),
                    borderSide:
                        BorderSide(color: Constants.greyColor, width: 1),
                  ),
                ),
                validator: (val) => val.length < 1
                    ? 'Mobile Number is required'
                    : val.length < 10
                        ? 'Mobile Number should be 10 digit '
                        : null,
                //  onSaved: (val) => _mobileNumber = val,
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'BUSINESS DETAILS',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 5,
              ),
              TextFormField(
                keyboardType: TextInputType.text,
                controller: companyNameController,
                decoration: InputDecoration(
                  labelText: 'Company/Business Name*',
                  labelStyle: TextStyle(
                      fontSize: 14,
                      color: Constants.lightgreyColor,
                      fontWeight: FontWeight.w600),
                  border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(8.0),
                    borderSide: new BorderSide(
                      color: Constants.lightgreyColor,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(12.0),
                    borderSide:
                        BorderSide(color: Constants.greyColor, width: 1),
                  ),
                ),
                validator: (val) => val.length < 1
                    ? 'Company/Business Name is required'
                    : val.length < 3
                        ? 'Company/Business Name is too short.. '
                        : null,
                // onSaved: (val) => _businessName = val,
              ),
              SizedBox(
                height: 5,
              ),
              TextFormField(
                controller: gstNoController,
                decoration: InputDecoration(
                  labelText: 'GST No *',
                  labelStyle: TextStyle(
                      fontSize: 14,
                      color: Constants.lightgreyColor,
                      fontWeight: FontWeight.w600),
                  border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(8.0),
                    borderSide: new BorderSide(
                      color: Constants.lightgreyColor,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(12.0),
                    borderSide:
                        BorderSide(color: Constants.greyColor, width: 1),
                  ),
                ),
                validator: (val) => val.length < 1
                    ? 'GST is required'
                    : val.length < 4
                        ? 'GST No  is too short.. '
                        : null,
                //  onSaved: (val) => _gSTIN = val,
              ),
              SizedBox(
                height: 5,
              ),
              TextFormField(
                controller: address1Controller,
                decoration: InputDecoration(
                  labelText: 'Address1 *',
                  labelStyle: TextStyle(
                      fontSize: 14,
                      color: Constants.lightgreyColor,
                      fontWeight: FontWeight.w600),
                  border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(8.0),
                    borderSide: new BorderSide(
                      color: Constants.lightgreyColor,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(12.0),
                    borderSide:
                        BorderSide(color: Constants.greyColor, width: 1),
                  ),
                ),
                validator: (val) => val.length < 1
                    ? 'Address1 is required'
                    : val.length < 4
                        ? 'Address1  is too short.. '
                        : null,
                // onSaved: (val) => _address1 = val,
              ),
              SizedBox(
                height: 5,
              ),
              TextFormField(
                controller: address2Controller,
                decoration: InputDecoration(
                  labelText: 'Address2 ',
                  labelStyle: TextStyle(
                      fontSize: 14,
                      color: Constants.lightgreyColor,
                      fontWeight: FontWeight.w600),
                  border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(8.0),
                    borderSide: new BorderSide(
                      color: Constants.lightgreyColor,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(12.0),
                    borderSide:
                        BorderSide(color: Constants.greyColor, width: 1),
                  ),
                ),
                // onSaved: (val) => _address2 = val,
              ),
              SizedBox(
                height: 5,
              ),
              TextFormField(
                controller: landMarkController,
                decoration: InputDecoration(
                  labelText: 'Landmark',
                  labelStyle: TextStyle(
                      fontSize: 14,
                      color: Constants.lightgreyColor,
                      fontWeight: FontWeight.w600),
                  border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(8.0),
                    borderSide: new BorderSide(
                      color: Constants.lightgreyColor,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(12.0),
                    borderSide:
                        BorderSide(color: Constants.greyColor, width: 1),
                  ),
                ),
                //  onSaved: (val) => _landmark = val,
              ),
              SizedBox(
                height: 5,
              ),
              TextFormField(
                controller: cityController,
                decoration: InputDecoration(
                  labelText: 'City/Village *',
                  labelStyle: TextStyle(
                      fontSize: 14,
                      color: Constants.lightgreyColor,
                      fontWeight: FontWeight.w600),
                  border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(8.0),
                    borderSide: new BorderSide(
                      color: Constants.lightgreyColor,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(12.0),
                    borderSide:
                        BorderSide(color: Constants.greyColor, width: 1),
                  ),
                ),
                validator: (val) => val.length < 1
                    ? 'City / Village is required'
                    : val.length < 3
                        ? 'City / Village  is too short.. '
                        : null,
                // onSaved: (val) => _city = val,
              ),
              SizedBox(
                height: 5,
              ),
              TextFormField(
                controller: districtController,
                decoration: InputDecoration(
                  labelText: 'District',
                  labelStyle: TextStyle(
                      fontSize: 14,
                      color: Constants.lightgreyColor,
                      fontWeight: FontWeight.w600),
                  border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(8.0),
                    borderSide: new BorderSide(
                      color: Constants.lightgreyColor,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(12.0),
                    borderSide:
                        BorderSide(color: Constants.greyColor, width: 1),
                  ),
                ),
                // validator: (val) => val.length < 1
                //     ? 'District is required'
                //     : val.length < 4
                //         ? 'District  is too short.. '
                //         : null,
                // onSaved: (val) => _district = val,
              ),
              SizedBox(
                height: 5,
              ),
              DropdownButtonHideUnderline(
                child: states == null
                    ? Container()
                    : DropdownButtonFormField(
                        decoration: InputDecoration(
                          enabledBorder: new OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(
                                color: stateError == null
                                    ? Colors.grey
                                    : Colors.red),
                          ),
                          labelText: 'State *',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            // borderSide: new BorderSide(
                            //   color: Colors.grey,
                            // ),
                          ),
                        ),
                        value: selectedState,
                        isDense: true,
                        onChanged: (newValue) {
                          setState(() {
                            selectedState = newValue;
                            print('Select');
                            _stateName = selectedState.name;
                            stateError = null;
                          });
                        },
                        items: states.map((value) {
                          return DropdownMenuItem(
                            value: value,
                            child: new Text(value.name),
                          );
                        }).toList(),
                      ),
              ),
              Padding(
                padding: stateError == null
                    ? const EdgeInsets.only(left: 0)
                    : const EdgeInsets.only(left: 10, top: 5, bottom: 5),
                child: stateError == null
                    ? SizedBox.shrink()
                    : Text(
                        stateError ?? "",
                        style: TextStyle(color: Colors.red[700], fontSize: 13),
                      ),
              ),
              SizedBox(
                height: 5,
              ),
              TextFormField(
                controller: pincodeController,
                keyboardType: TextInputType.text,
                maxLength: 6,
                inputFormatters: <TextInputFormatter>[
                  WhitelistingTextInputFormatter.digitsOnly
                ],
                decoration: InputDecoration(
                  counterText: "",
                  labelText: 'Pincode *',
                  labelStyle: TextStyle(
                      fontSize: 14,
                      color: Constants.lightgreyColor,
                      fontWeight: FontWeight.w600),
                  border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(8.0),
                    borderSide: new BorderSide(
                      color: Constants.lightgreyColor,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(12.0),
                    borderSide:
                        BorderSide(color: Constants.greyColor, width: 1),
                  ),
                ),
                validator: (val) => val.length < 1
                    ? 'Pincode is required'
                    : val.length < 6
                        ? 'Pincode is too short.. '
                        : null,
                //  onSaved: (val) => _pincode = val,
              ),
              SizedBox(
                height: 5,
              ),
              DropdownButtonHideUnderline(
                child: logistics == null
                    ? Container()
                    : DropdownButtonFormField(
                        decoration: InputDecoration(
                          enabledBorder: new OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(
                                color: logisticError == null
                                    ? Colors.grey
                                    : Colors.red),
                          ),
                          labelText: 'Logistics *',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0)),
                        ),
                        // hint: Text("Logistics *"),
                        value: logisticListResult,
                        isDense: true,
                        onChanged: (newValue) {
                          setState(() {
                            logisticListResult = newValue;
                            logisticError = null;
                          });
                        },
                        items: logistics.map((value) {
                          return DropdownMenuItem(
                            value: value,
                            child: new Text(value.name),
                          );
                        }).toList(),
                      ),
              ),
              Padding(
                padding: logisticError == null
                    ? const EdgeInsets.only(left: 0)
                    : const EdgeInsets.only(left: 10, top: 5, bottom: 5),
                child: logisticError == null
                    ? SizedBox.shrink()
                    : Text(
                        logisticError ?? "",
                        style: TextStyle(color: Colors.red[700], fontSize: 13),
                      ),
              ),
            ],
          )),
      Step(
        //  state: StepState.indexed,
        isActive: currentstep >= 1,
        title: const Text(''),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "BILLING ADDRESS",
              textAlign: TextAlign.start,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10,
            ),
            TextFormField(
              controller: billingNameController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: 'Name*',
                labelStyle: TextStyle(
                    fontSize: 14,
                    color: Constants.lightgreyColor,
                    fontWeight: FontWeight.w600),
                border: new OutlineInputBorder(
                  borderRadius: new BorderRadius.circular(8.0),
                  borderSide: new BorderSide(
                    color: Constants.lightgreyColor,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: new BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: Constants.greyColor, width: 1),
                ),
              ),
              validator: (val) => val.length < 1
                  ? 'Name is required'
                  : val.length < 3
                      ? 'Name is too short.. '
                      : null,
              //  onSaved: (val) => _billingName = val,
            ),
            SizedBox(
              height: 5,
            ),
            TextFormField(
              controller: billingMobileNoController,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              decoration: InputDecoration(
                counterText: "",
                labelText: 'Mobile Number*',
                labelStyle: TextStyle(
                    fontSize: 14,
                    color: Constants.lightgreyColor,
                    fontWeight: FontWeight.w600),
                border: new OutlineInputBorder(
                  borderRadius: new BorderRadius.circular(8.0),
                  borderSide: new BorderSide(
                    color: Constants.lightgreyColor,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: new BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: Constants.greyColor, width: 1),
                ),
              ),
              validator: (val) => val.length < 1
                  ? 'Mobile Number is required'
                  : val.length < 10
                      ? 'Mobile Number should be 10 digit '
                      : null,
              //  onSaved: (val) => _billingMobileNumber = val,
            ),
            SizedBox(
              height: 5,
            ),
            TextFormField(
              controller: billingAddrs1Controller,
              decoration: InputDecoration(
                labelText: 'Address1 *',
                labelStyle: TextStyle(
                    fontSize: 14,
                    color: Constants.lightgreyColor,
                    fontWeight: FontWeight.w600),
                border: new OutlineInputBorder(
                  borderRadius: new BorderRadius.circular(8.0),
                  borderSide: new BorderSide(
                    color: Constants.lightgreyColor,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: new BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: Constants.greyColor, width: 1),
                ),
              ),
              validator: (val) => val.length < 1
                  ? 'Address1 is required'
                  : val.length < 4
                      ? 'Address1  is too short.. '
                      : null,
              // onSaved: (val) => _billngAddrs1 = val,
            ),
            SizedBox(
              height: 5,
            ),
            TextFormField(
              controller: billingAddrs2Controller,
              decoration: InputDecoration(
                labelText: 'Address2 ',
                labelStyle: TextStyle(
                    fontSize: 14,
                    color: Constants.lightgreyColor,
                    fontWeight: FontWeight.w600),
                border: new OutlineInputBorder(
                  borderRadius: new BorderRadius.circular(8.0),
                  borderSide: new BorderSide(
                    color: Constants.lightgreyColor,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: new BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: Constants.greyColor, width: 1),
                ),
              ),
              //  onSaved: (val) => _billngAddrs2 = val,
            ),
            SizedBox(
              height: 5,
            ),
            TextFormField(
              controller: billinglanMarkController,
              decoration: InputDecoration(
                labelText: 'Landmark',
                labelStyle: TextStyle(
                    fontSize: 14,
                    color: Constants.lightgreyColor,
                    fontWeight: FontWeight.w600),
                border: new OutlineInputBorder(
                  borderRadius: new BorderRadius.circular(8.0),
                  borderSide: new BorderSide(
                    color: Constants.lightgreyColor,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: new BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: Constants.greyColor, width: 1),
                ),
              ),
              //  onSaved: (val) => _billnglandMark = val,
            ),
            SizedBox(
              height: 5,
            ),
            TextFormField(
              controller: billingcityController,
              decoration: InputDecoration(
                labelText: 'City/Village *',
                labelStyle: TextStyle(
                    fontSize: 14,
                    color: Constants.lightgreyColor,
                    fontWeight: FontWeight.w600),
                border: new OutlineInputBorder(
                  borderRadius: new BorderRadius.circular(8.0),
                  borderSide: new BorderSide(
                    color: Constants.lightgreyColor,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: new BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: Constants.greyColor, width: 1),
                ),
              ),
              validator: (val) => val.length < 1
                  ? 'City / Village is required'
                  : val.length < 3
                      ? 'City / Village  is too short.. '
                      : null,
              //  onSaved: (val) => _billngACity = val,
            ),
            SizedBox(
              height: 5,
            ),
            TextFormField(
              controller: billingdistrictController,
              decoration: InputDecoration(
                labelText: 'District',
                labelStyle: TextStyle(
                    fontSize: 14,
                    color: Constants.lightgreyColor,
                    fontWeight: FontWeight.w600),
                border: new OutlineInputBorder(
                  borderRadius: new BorderRadius.circular(8.0),
                  borderSide: new BorderSide(
                    color: Constants.lightgreyColor,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: new BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: Constants.greyColor, width: 1),
                ),
              ),
              // validator: (val) => val.length < 1
              //     ? 'District is required'
              //     : val.length < 4
              //         ? 'District  is too short.. '
              //         : null,
              // onSaved: (val) => _billngDistrict = val,
            ),
            SizedBox(
              height: 5,
            ),
            DropdownButtonHideUnderline(
              child: states == null
                  ? Container()
                  : DropdownButtonFormField(
                      decoration: InputDecoration(
                        enabledBorder: new OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(
                              color: billingStError == null
                                  ? Colors.grey
                                  : Colors.red),
                        ),
                        labelText: 'State *',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0)),
                      ),
                      // hint: Text("State *"),
                      value: selectedBillingState,
                      isDense: true,
                      onChanged: (newValue) {
                        setState(() {
                          selectedBillingState = newValue;
                          print('Select');
                          _billngstateName = selectedBillingState.name;
                          print(_billngstateName);
                          billingStateID = selectedBillingState.id;
                          billingStError = null;
                        });
                      },
                      items: states.map((value) {
                        return DropdownMenuItem(
                          value: value,
                          child: new Text(value.name),
                        );
                      }).toList(),
                    ),
            ),
            Padding(
              padding: billingStError == null
                  ? const EdgeInsets.only(left: 0)
                  : const EdgeInsets.only(left: 10, top: 5, bottom: 5),
              child: billingStError == null
                  ? SizedBox.shrink()
                  : Text(
                      billingStError ?? "",
                      style: TextStyle(color: Colors.red[700], fontSize: 13),
                    ),
            ),
            SizedBox(
              height: 5,
            ),
            TextFormField(
              keyboardType: TextInputType.number,
              maxLength: 6,
              inputFormatters: <TextInputFormatter>[
                WhitelistingTextInputFormatter.digitsOnly
              ],
              controller: billingpincodeController,
              decoration: InputDecoration(
                counterText: "",
                labelText: 'Pincode *',
                labelStyle: TextStyle(
                    fontSize: 14,
                    color: Constants.lightgreyColor,
                    fontWeight: FontWeight.w600),
                border: new OutlineInputBorder(
                  borderRadius: new BorderRadius.circular(8.0),
                  borderSide: new BorderSide(
                    color: Constants.lightgreyColor,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: new BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: Constants.greyColor, width: 1),
                ),
              ),
              validator: (val) => val.length < 1
                  ? 'Pincode is required'
                  : val.length < 6
                      ? 'Pincode is too short.. '
                      : null,
              // onSaved: (val) => _billngPincode = val,
            ),
          ],
        ),
      ),
      Step(
        state: StepState.indexed,
        isActive: currentstep >= 2,
        title: const Text(''),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "SHIPPING ADDRESS",
              textAlign: TextAlign.start,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            Row(
              children: <Widget>[
                Checkbox(
                    activeColor: Constants.appColor,
                    value: checkBoxValue,
                    onChanged: (bool newValue) {
                      setState(() {
                        checkBoxValue = newValue;

                        setState(() {
                          checkBoxValue == true
                              ? shippingNameController.text =
                                  billingNameController.text
                              : shippingNameController.text = "";

                          checkBoxValue == true
                              ? shippingdistrictController.text =
                                  billingdistrictController.text
                              : shippingdistrictController.text = "";
                          checkBoxValue == true
                              ? shippingcityController.text =
                                  billingcityController.text
                              : shippingcityController.text = "";
                          checkBoxValue == true
                              ? shippinglanMarkController.text =
                                  billinglanMarkController.text
                              : shippinglanMarkController.text = "";
                          checkBoxValue == true
                              ? shippingAddrs1Controller.text =
                                  billingAddrs1Controller.text
                              : shippingAddrs1Controller.text = "";
                          checkBoxValue == true
                              ? shippingAddrs2Controller.text =
                                  billingAddrs2Controller.text
                              : shippingAddrs2Controller.text = "";
                          checkBoxValue == true
                              ? shippingpincodeController.text =
                                  billingpincodeController.text
                              : shippingpincodeController.text = "";
                          checkBoxValue == true
                              ? shippingMobileNoController.text =
                                  billingMobileNoController.text
                              : shippingMobileNoController.text = "";

                          checkBoxValue == true
                              ? shippingStateID = billingStateID
                              : shippingStateID = 0;

                          checkBoxValue == true
                              ? selectedShippingState = selectedBillingState
                              : selectedShippingState = null;

                          if (checkBoxValue == true) {
                            shippingStError = null;

                            selectedShippingState = selectedBillingState;
                            print(selectedShippingState.name);
                          } else {
                            selectedShippingState = null;
                          }

                          print(shippingStateID);
                        });
                      });
                    }),
                Text("Is Shipping address is same as Billing address"),
              ],
            ),
            Container(
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: shippingNameController,
                    enabled: checkBoxValue == true ? false : true,
                    keyboardType: TextInputType.text,

                    decoration: InputDecoration(
                      labelText: 'Name*',
                      labelStyle: TextStyle(
                          fontSize: 14,
                          color: Constants.lightgreyColor,
                          fontWeight: FontWeight.w600),
                      border: new OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(8.0),
                        borderSide: new BorderSide(
                          color: Constants.lightgreyColor,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(12.0),
                        borderSide:
                            BorderSide(color: Constants.greyColor, width: 1),
                      ),
                    ),
                    validator: (val) => val.length < 1
                        ? 'Name is required'
                        : val.length < 3
                            ? 'Name is too short.. '
                            : null,
                    //  onSaved: (val) => _shippingName = val,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  TextFormField(
                    controller: shippingMobileNoController,
                    enabled: checkBoxValue == true ? false : true,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    decoration: InputDecoration(
                      counterText: "",
                      labelText: 'Mobile Number*',
                      labelStyle: TextStyle(
                          fontSize: 14,
                          color: Constants.lightgreyColor,
                          fontWeight: FontWeight.w600),
                      border: new OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(8.0),
                        borderSide: new BorderSide(
                          color: Constants.lightgreyColor,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(12.0),
                        borderSide:
                            BorderSide(color: Constants.greyColor, width: 1),
                      ),
                    ),
                    validator: (val) => val.length < 1
                        ? 'Mobile Number is required'
                        : val.length < 10
                            ? 'Mobile Number should be 10 digit '
                            : null,
                    //  onSaved: (val) => _shippingMobileNumber = val,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  TextFormField(
                    controller: shippingAddrs1Controller,
                    enabled: checkBoxValue == true ? false : true,
                    decoration: InputDecoration(
                      labelText: 'Address1 *',
                      labelStyle: TextStyle(
                          fontSize: 14,
                          color: Constants.lightgreyColor,
                          fontWeight: FontWeight.w600),
                      border: new OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(8.0),
                        borderSide: new BorderSide(
                          color: Constants.lightgreyColor,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(12.0),
                        borderSide:
                            BorderSide(color: Constants.greyColor, width: 1),
                      ),
                    ),
                    validator: (val) => val.length < 1
                        ? 'Address1 is required'
                        : val.length < 4
                            ? 'Address1  is too short.. '
                            : null,
                    // onSaved: (val) => _shippingAddrs1 = val,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  TextFormField(
                    controller: shippingAddrs2Controller,
                    enabled: checkBoxValue == true ? false : true,
                    decoration: InputDecoration(
                      labelText: 'Address2 ',
                      labelStyle: TextStyle(
                          fontSize: 14,
                          color: Constants.lightgreyColor,
                          fontWeight: FontWeight.w600),
                      border: new OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(8.0),
                        borderSide: new BorderSide(
                          color: Constants.lightgreyColor,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(12.0),
                        borderSide:
                            BorderSide(color: Constants.greyColor, width: 1),
                      ),
                    ),
                    onSaved: (val) => _shippingAddrs2 = val,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  TextFormField(
                    controller: shippinglanMarkController,
                    enabled: checkBoxValue == true ? false : true,
                    decoration: InputDecoration(
                      labelText: 'Landmark',
                      labelStyle: TextStyle(
                          fontSize: 14,
                          color: Constants.lightgreyColor,
                          fontWeight: FontWeight.w600),
                      border: new OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(8.0),
                        borderSide: new BorderSide(
                          color: Constants.lightgreyColor,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(12.0),
                        borderSide:
                            BorderSide(color: Constants.greyColor, width: 1),
                      ),
                    ),
                    // onSaved: (val) => _shippinglandMark = val,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  TextFormField(
                    controller: shippingcityController,
                    enabled: checkBoxValue == true ? false : true,
                    decoration: InputDecoration(
                      labelText: 'City/Village *',
                      labelStyle: TextStyle(
                          fontSize: 14,
                          color: Constants.lightgreyColor,
                          fontWeight: FontWeight.w600),
                      border: new OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(8.0),
                        borderSide: new BorderSide(
                          color: Constants.lightgreyColor,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(12.0),
                        borderSide:
                            BorderSide(color: Constants.greyColor, width: 1),
                      ),
                    ),
                    validator: (val) => val.length < 1
                        ? 'City / Village is required'
                        : val.length < 3
                            ? 'City / Village  is too short.. '
                            : null,
                    //  onSaved: (val) => _shippingACity = val,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  TextFormField(
                    controller: shippingdistrictController,
                    enabled: checkBoxValue == true ? false : true,
                    decoration: InputDecoration(
                      labelText: 'District',
                      labelStyle: TextStyle(
                          fontSize: 14,
                          color: Constants.lightgreyColor,
                          fontWeight: FontWeight.w600),
                      border: new OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(8.0),
                        borderSide: new BorderSide(
                          color: Constants.lightgreyColor,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(12.0),
                        borderSide:
                            BorderSide(color: Constants.greyColor, width: 1),
                      ),
                    ),
                    // validator: (val) => val.length < 1
                    //     ? 'District is required'
                    //     : val.length < 4
                    //         ? 'District  is too short.. '
                    //         : null,
                    // onSaved: (val) => _shippingDistrict = val,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  DropdownButtonHideUnderline(
                    child: states == null
                        ? Container()
                        : DropdownButtonFormField(
                            decoration: InputDecoration(
                              enabledBorder: new OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide(
                                    color: shippingStError == null
                                        ? Colors.grey
                                        : Colors.red),
                              ),
                              // labelText: checkBoxValue == true
                              //     ? _billngstateName
                              //     : 'State *',
                              labelText: 'State *',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0)),
                            ),
                            hint: checkBoxValue == true
                                ? Text(_billngstateName,
                                    style: TextStyle(color: Colors.black))
                                : Text("",
                                    style: TextStyle(color: Colors.grey)),
                            value: selectedShippingState,
                            isDense: true,
                            onChanged: checkBoxValue == true
                                ? null
                                : (newValue) {
                                    setState(() {
                                      selectedShippingState = newValue;
                                      print('Select');
                                      _shippingstateName =
                                          selectedShippingState.name;
                                      shippingStateID =
                                          selectedShippingState.id;
                                      shippingStError = null;
                                    });
                                  },
                            items: states.map((value) {
                              return DropdownMenuItem(
                                value: value,
                                child: new Text(value.name),
                              );
                            }).toList(),
                          ),
                  ),
                  checkBoxValue == true
                      ? Container()
                      : Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: shippingStError == null
                                ? const EdgeInsets.only(left: 0)
                                : const EdgeInsets.only(
                                    left: 10, top: 5, bottom: 5),
                            child: shippingStError == null
                                ? SizedBox.shrink()
                                : Text(
                                    shippingStError ?? "",
                                    style: TextStyle(
                                        color: Colors.red[700], fontSize: 13),
                                  ),
                          ),
                        ),
                  SizedBox(
                    height: 5,
                  ),
                  TextFormField(
                    controller: shippingpincodeController,
                    enabled: checkBoxValue == true ? false : true,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    inputFormatters: <TextInputFormatter>[
                      WhitelistingTextInputFormatter.digitsOnly
                    ],
                    decoration: InputDecoration(
                      counterText: "",
                      labelText: 'Pincode *',
                      labelStyle: TextStyle(
                          fontSize: 14,
                          color: Constants.lightgreyColor,
                          fontWeight: FontWeight.w600),
                      border: new OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(8.0),
                        borderSide: new BorderSide(
                          color: Constants.lightgreyColor,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(12.0),
                        borderSide:
                            BorderSide(color: Constants.greyColor, width: 1),
                      ),
                    ),
                    validator: (val) => val.length < 1
                        ? 'Pincode is required'
                        : val.length < 6
                            ? 'Pincode is too short.. '
                            : null,
                    //  onSaved: (val) => _shippingPincode = val,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ];

    return Form(
      key: _key,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Sign Up',
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
        body: Stack(children: [
          Column(
            children: [
              Expanded(
                child: Theme(
                  data: ThemeData(
                    primaryColor: Constants.appColor,
                  ),
                  child: Stepper(
                    steps: steps,
                    currentStep: currentstep,
                    onStepContinue: next,
                    onStepCancel: cancel,
                    type: StepperType.horizontal,
                    controlsBuilder: (BuildContext context,
                        {VoidCallback onStepContinue,
                        VoidCallback onStepCancel}) {
                      return Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: currentstep == 0
                                      ? Container()
                                      : Container(
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Constants.appColor,
                                                  width: 2)),
                                          child: RaisedButton(
                                            color: Constants.bgColor,
                                            child: Padding(
                                              padding: const EdgeInsets.all(14),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.arrow_back,
                                                    color:
                                                        Constants.boldTextColor,
                                                    size: 15,
                                                  ),
                                                  Text(
                                                    " Previous",
                                                    style: TextStyle(
                                                      //  fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            onPressed: onStepCancel,
                                          ),
                                        ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(),
                                    child: RaisedButton(
                                      color: Constants.appColor,
                                      child: Padding(
                                        padding: const EdgeInsets.all(15),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              currentstep == 2
                                                  ? "Submit"
                                                  : "Next  ",
                                              style: TextStyle(
                                                // fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Icon(
                                              Icons.arrow_forward,
                                              color: Constants.bgColor,
                                              size: 15,
                                            ),
                                          ],
                                        ),
                                      ),
                                      onPressed: onStepContinue,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              )
            ],
          ),
        ]),
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

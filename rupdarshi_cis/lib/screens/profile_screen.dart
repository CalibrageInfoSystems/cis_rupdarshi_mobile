import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:progress_dialog/progress_dialog.dart';
import 'package:rupdarshi_cis/Model/StatesResModel.dart';
import 'package:rupdarshi_cis/Model/UserLoginRes.dart';
import 'package:rupdarshi_cis/Service/ApiService.dart';
import 'package:rupdarshi_cis/common/Constants.dart';
import 'package:rupdarshi_cis/common/SessionManager.dart';
import 'package:rupdarshi_cis/Model/VendorProfile.dart' as vendor;
import 'package:rupdarshi_cis/screens/Home_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String patttern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
  String pinPatttern = r'(^[1-9]{1}[0-9]{2}\s{0,1}[0-9]{3}$)';
  ApiService apiConnector;
  ProgressDialog progressHud;
  bool firstLoading = true;
  SessionManager pref = new SessionManager();
  String errorMsg = "";
  var stateresModel = null;
  List<ListResult> states = [];
  ListResult selectedState;
  vendor.VendorProfile vendorinfo;
  int _state = 1, userid;
  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _agreedToTOS = true;
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
      _pincode;
  int _roleid = 1, _serviceTypeId = 4;
  void _setAgreedToTOS(bool newValue) {
    setState(() {
      _agreedToTOS = newValue;
    });
  }

  @override
  void initState() {
    super.initState();
    firstLoading = true;
    apiConnector = new ApiService();
    SessionManager().getUserId().then((value) {
      userid = value;
      print('User ID from Profile :' + userid.toString());
      _getProfileData();
    });
    selectedState = null;
    stateresModel = null;
    vendor.VendorProfile vendorinfo = null;
  }

  void _getstates() {
    ApiService.getStates().then((res) {
      // progressHud.hide();
      print(res);
      setState(() {
        states = statesResModelFromJson(res.body).listResult;
        if (vendorinfo != null) {
          selectedState = states
              .firstWhere((x) => x.id == vendorinfo.listResult[0].stateId);
          print('Selected State :' + selectedState.name);
        }
        print("states comming => " + states.length.toString());
      });
    });
  }

  void _submitCommand() {
    final form = formKey.currentState;
    if (form.validate()) {
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
        _loginCommand();
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

  void _getProfileData() async {
    // progressHud.show();
    var baseurl = ApiService.baseUrl;
    var url = '$baseurl/User/GetVendorInfo';

    Map data = {
      "VendorId": userid,
      "ServiceTypeId": null,
      "StatusTypeId": null,
      "FromDate": null,
      "ToDate": null
    };
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
      firstLoading = false;
      int statusCode = value.statusCode;
      String res = value.body;
      vendorinfo = vendor.vendorProfileFromJson(res);

      errorMsg = vendorinfo.listResult == null ? "No data found" : "";

      // print("Vendor data :" + vendorinfo.listResult[0].vendorName);

      _getstates();
    });
  }

  void _loginCommand() async {
    // Show login details in snackbar
    var baseurl = ApiService.baseUrl;
    var url = '$baseurl/User/VendorUpdate';

    Map data = {
      "Id": vendorinfo.listResult[0].id,
      "FirstName": _firstName,
      "MiddleName": _middleName,
      "LastName": _lastname,
      "MobileNumber": _mobileNumber,
      "Email": _email,
      "BusinessName": _businessName,
      "GSTIN": _gSTIN,
      "Address1": _address1,
      "Address2": _address2,
      "Landmark": _landmark,
      "Pincode": int.parse(_pincode),
      "StateId": selectedState.id,
      "District": _district,
      "City": _city,
      "ServiceTypeId": vendorinfo.listResult[0].serviceTypeId,
      "CreatedByUserId": vendorinfo.listResult[0].createdbyUserId,
      "UpdatedByUserId": vendorinfo.listResult[0].createdbyUserId
    };

    String body = json.encode(data);
    print('Request Data :' + body);
    http.Response response = await http
        .post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    )
        .then((value) {
      int statusCode = value.statusCode;
      String res = value.body;
      print(res);
      if (statusCode == 200) {
        var data = json.decode(res);
        if (data['IsSuccess'] == true) {
          if (data['Result']['UserInfos'] != null) {
            pref.setString('userinfo', res);
            pref.getString('userinfo').then((value) {
              print('User info from Session After Update :' + value);
            });
          }
          apiConnector.globalToast(data['EndUserMessage']);

          Navigator.push(
              context, MaterialPageRoute(builder: (context) => HomeScreen()));

          formKey.currentState.reset();
          setState(() {
            _state = 1;
          });

          // final snackbar = SnackBar(
          //   content: Text(data['EndUserMessage']),
          // );
          // scaffoldKey.currentState.showSnackBar(snackbar);
        } else {
          setState(() {
            _state = 1;
          });
          // final snackbar = SnackBar(
          //   content: Text(data['EndUserMessage']),
          // );
          // scaffoldKey.currentState.showSnackBar(snackbar);
          apiConnector.globalToast(data['EndUserMessage']);
        }
      } else {
        setState(() {
          _state = 1;
        });
        // final snackbar = SnackBar(
        //   content: Text('Something went wrong ..'),
        // );
        // scaffoldKey.currentState.showSnackBar(snackbar);
        apiConnector.globalToast("Something went wrong ..");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    RegExp regExp = new RegExp(patttern);
    RegExp pinregExp = new RegExp(pinPatttern);
    bool validateStructure(String value) {
      String pattern =
          r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
      RegExp regExp = new RegExp(pattern);
      return regExp.hasMatch(value);
    }

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('Profile',
            style: TextStyle(fontSize: 18, color: Colors.white),
            overflow: TextOverflow.ellipsis,
            maxLines: 1),
        backgroundColor: Constants.appColor,
        leading: GestureDetector(
          onTap: () {
            // Navigator.pop(context);
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => HomeScreen()));
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
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Constants.appColor,
        elevation: 4.0,
        label: _state == 1
            ? Text('    Update     ',
                style: TextStyle(fontSize: 18, color: Colors.white))
            : CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
        onPressed: _submitCommand,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: firstLoading == true
          ? Container(
              child: Center(
                child: Container(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(),
                ),
              ),
            )
          : Container(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: vendorinfo == null
                      ? Center(
                          child: Text(errorMsg),
                        )
                      : Form(
                          key: formKey,
                          child: Column(
                            children: <Widget>[
                              Container(
                                child: Column(
                                  children: [
                                    Column(
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            'Basic Details',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w700),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        new Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: TextFormField(
                                                initialValue: vendorinfo
                                                    .listResult[0].firstName,
                                                decoration: InputDecoration(
                                                  labelText: 'First Name *',
                                                  border:
                                                      new OutlineInputBorder(
                                                    borderRadius:
                                                        new BorderRadius
                                                            .circular(8.0),
                                                    borderSide:
                                                        new BorderSide(),
                                                  ),
                                                ),
                                                validator: (val) => val.length <
                                                        4
                                                    ? 'First Name is too short'
                                                    : null,
                                                onSaved: (val) =>
                                                    _firstName = val,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Expanded(
                                              child: TextFormField(
                                                initialValue: vendorinfo
                                                    .listResult[0].middleName,
                                                decoration: InputDecoration(
                                                  labelText: 'Middle Name',
                                                  border:
                                                      new OutlineInputBorder(
                                                    borderRadius:
                                                        new BorderRadius
                                                            .circular(8.0),
                                                    borderSide:
                                                        new BorderSide(),
                                                  ),
                                                ),
                                                onSaved: (val) =>
                                                    _middleName = val,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Expanded(
                                              child: TextFormField(
                                                initialValue: vendorinfo
                                                    .listResult[0].lastName,
                                                decoration: InputDecoration(
                                                  labelText: 'Last Name *',
                                                  border:
                                                      new OutlineInputBorder(
                                                    borderRadius:
                                                        new BorderRadius
                                                            .circular(8.0),
                                                    borderSide:
                                                        new BorderSide(),
                                                  ),
                                                ),
                                                validator: (val) => val.length <
                                                        4
                                                    ? 'Last Name is too short'
                                                    : null,
                                                onSaved: (val) =>
                                                    _lastname = val,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        TextFormField(
                                          readOnly: true,
                                          initialValue:
                                              vendorinfo.listResult[0].userName,
                                          decoration: InputDecoration(
                                            labelText: 'User Name *',
                                            border: new OutlineInputBorder(
                                              borderRadius:
                                                  new BorderRadius.circular(
                                                      8.0),
                                              borderSide: new BorderSide(),
                                            ),
                                          ),
                                          validator: (val) => val.length < 4
                                              ? 'User Name is too short'
                                              : null,
                                          onSaved: (val) => _userName = val,
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        TextFormField(
                                          readOnly: true,
                                          initialValue:
                                              vendorinfo.listResult[0].email,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          decoration: InputDecoration(
                                            labelText: 'Email *',
                                            border: new OutlineInputBorder(
                                              borderRadius:
                                                  new BorderRadius.circular(
                                                      8.0),
                                              borderSide: new BorderSide(),
                                            ),
                                          ),
                                          validator: (val) => val.length < 4
                                              ? 'Email is too short.. '
                                              : null,
                                          onSaved: (val) => _email = val,
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        TextFormField(
                                          readOnly: true,
                                          initialValue: vendorinfo
                                              .listResult[0].mobileNumber,
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            labelText: 'Mobile Number *',
                                            border: new OutlineInputBorder(
                                              borderRadius:
                                                  new BorderRadius.circular(
                                                      8.0),
                                              borderSide: new BorderSide(),
                                            ),
                                          ),
                                          validator: (val) => val.length < 4
                                              ? 'Mobile Number  is too short'
                                              : !regExp.hasMatch(val)
                                                  ? 'Please enter valid mobile number'
                                                  : null,
                                          onSaved: (val) => _mobileNumber = val,
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            'Business Details',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w700),
                                          ),
                                        ),
                                        TextFormField(
                                          initialValue: vendorinfo
                                              .listResult[0].businessName,
                                          decoration: InputDecoration(
                                            labelText:
                                                'Company/Business name *',
                                            border: new OutlineInputBorder(
                                              borderRadius:
                                                  new BorderRadius.circular(
                                                      8.0),
                                              borderSide: new BorderSide(),
                                            ),
                                          ),
                                          validator: (val) => val.length < 4
                                              ? 'Company/Business Name is too short'
                                              : null,
                                          onSaved: (val) => _businessName = val,
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        TextFormField(
                                          initialValue:
                                              vendorinfo.listResult[0].gstin,
                                          decoration: InputDecoration(
                                            labelText: 'GST No *',
                                            border: new OutlineInputBorder(
                                              borderRadius:
                                                  new BorderRadius.circular(
                                                      8.0),
                                              borderSide: new BorderSide(),
                                            ),
                                          ),
                                          validator: (val) => val.length < 4
                                              ? 'GST No  is too short'
                                              : null,
                                          onSaved: (val) => _gSTIN = val,
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    TextFormField(
                                      initialValue:
                                          vendorinfo.listResult[0].address1,
                                      decoration: InputDecoration(
                                        labelText: 'Address1 *',
                                        border: new OutlineInputBorder(
                                          borderRadius:
                                              new BorderRadius.circular(8.0),
                                          borderSide: new BorderSide(),
                                        ),
                                      ),
                                      validator: (val) => val.length < 4
                                          ? 'Address1  is too short'
                                          : null,
                                      onSaved: (val) => _address1 = val,
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    TextFormField(
                                      initialValue:
                                          vendorinfo.listResult[0].address2,
                                      decoration: InputDecoration(
                                        labelText: 'Address2 ',
                                        border: new OutlineInputBorder(
                                          borderRadius:
                                              new BorderRadius.circular(8.0),
                                          borderSide: new BorderSide(),
                                        ),
                                      ),
                                      onSaved: (val) => _address2 = val,
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    TextFormField(
                                      initialValue:
                                          vendorinfo.listResult[0].landmark,
                                      decoration: InputDecoration(
                                        labelText: 'Landmark',
                                        border: new OutlineInputBorder(
                                          borderRadius:
                                              new BorderRadius.circular(8.0),
                                          borderSide: new BorderSide(),
                                        ),
                                      ),
                                      onSaved: (val) => _landmark = val,
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    TextFormField(
                                      initialValue:
                                          vendorinfo.listResult[0].city,
                                      decoration: InputDecoration(
                                        labelText: 'City/Village *',
                                        border: new OutlineInputBorder(
                                          borderRadius:
                                              new BorderRadius.circular(8.0),
                                          borderSide: new BorderSide(),
                                        ),
                                      ),
                                      validator: (val) => val.length < 4
                                          ? 'City / Village  is too short'
                                          : null,
                                      onSaved: (val) => _city = val,
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    TextFormField(
                                      initialValue:
                                          vendorinfo.listResult[0].district,
                                      decoration: InputDecoration(
                                        labelText: 'District',
                                        border: new OutlineInputBorder(
                                          borderRadius:
                                              new BorderRadius.circular(8.0),
                                          borderSide: new BorderSide(),
                                        ),
                                      ),
                                      // validator: (val) => val.length < 4
                                      //     ? 'District  is too short'
                                      //     : null,
                                      onSaved: (val) => _district = val,
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    DropdownButtonHideUnderline(
                                      child: states == null
                                          ? Container()
                                          : DropdownButtonFormField(
                                              decoration: InputDecoration(
                                                labelText: vendorinfo
                                                    .listResult[0].stateName,
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5.0)),
                                              ),
                                              // hint: Text(vendorinfo
                                              //     .listResult[0].stateName),
                                              value: selectedState,
                                              isDense: true,
                                              onChanged: (newValue) {
                                                setState(() {
                                                  selectedState = newValue;
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
                                    SizedBox(
                                      height: 5,
                                    ),
                                    TextFormField(
                                      initialValue:
                                          vendorinfo.listResult[0].pincode,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: 'Pincode *',
                                        border: new OutlineInputBorder(
                                          borderRadius:
                                              new BorderRadius.circular(8.0),
                                          borderSide: new BorderSide(),
                                        ),
                                      ),
                                      validator: (val) => val.length < 4
                                          ? 'Pincode  is too short'
                                          : !pinregExp.hasMatch(val)
                                              ? 'Please enter valid Pincode'
                                              : null,
                                      onSaved: (val) => _pincode = val,
                                    ),
                                    SizedBox(
                                      height: 45,
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
    );
  }
}

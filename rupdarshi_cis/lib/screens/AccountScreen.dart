import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:progress_dialog/progress_dialog.dart';
import 'package:rupdarshi_cis/Model/StatesResModel.dart';
import 'package:rupdarshi_cis/Service/ApiService.dart';
import 'package:rupdarshi_cis/common/Constants.dart';
import 'package:rupdarshi_cis/common/LocalDb.dart';
import 'package:rupdarshi_cis/common/SessionManager.dart';
import 'package:rupdarshi_cis/Model/VendorProfile.dart' as vendor;
import 'package:rupdarshi_cis/screens/ChangePassword.dart';
import 'package:rupdarshi_cis/screens/Home_screen.dart';
import 'package:rupdarshi_cis/screens/MyAddress.dart';
import 'package:rupdarshi_cis/screens/ProfileDetailsScreen.dart';

extension CapExtension1 on String {
  String get inCaps2 => '${this[0].toUpperCase()}${this.substring(1)}';
  String get allInCaps2 => this.toUpperCase();
}

class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  LocalData localData = new LocalData();
  FocusNode myFocusNode;
  bool isEditVisible = false;
  String patttern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
  String pinPatttern = r'(^[1-9]{1}[0-9]{2}\s{0,1}[0-9]{3}$)';
  ApiService apiConnector;
  ProgressDialog progressHud;
  bool firstLoading = true;
  SessionManager pref = new SessionManager();
  String errorMsg = "";
  var stateresModel;
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
      _logisticName,
      _pincode;
  int _roleid = 1, _serviceTypeId = 4;
  void _setAgreedToTOS(bool newValue) {
    setState(() {
      _agreedToTOS = newValue;
    });
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    myFocusNode.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    stateresModel = null;
    myFocusNode = FocusNode();
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
      setState(() {
        localData.addIntToSF(
            LocalData.LOGISTICID, vendorinfo.listResult[0].logisticOparatorId);
      });

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
      "BusinessName": vendorinfo.listResult[0].businessName,
      "GSTIN": vendorinfo.listResult[0].gstin,
      "Address1": vendorinfo.listResult[0].address1,
      "Address2": vendorinfo.listResult[0].address2,
      "Landmark": vendorinfo.listResult[0].landmark,
      "Pincode": vendorinfo.listResult[0].pincode,
      "StateId": selectedState.id,
      "District": vendorinfo.listResult[0].district,
      "City": vendorinfo.listResult[0].city,
      "CreatedByUserId": vendorinfo.listResult[0].createdbyUserId,
      "UpdatedByUserId": vendorinfo.listResult[0].createdbyUserId,
      "PreferlogisticOparatorId": 53
    };

    print('Request Data :' + data.toString());

    String body = json.encode(data);

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
        } else {
          setState(() {
            _state = 1;
          });         
          apiConnector.globalToast(data['EndUserMessage']);
        }
      } else {
        setState(() {
          _state = 1;
        });       
        apiConnector.globalToast("Something went wrong ..");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var halfOfScreen = MediaQuery.of(context).size.height / 3.5;
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
            style: TextStyle(fontSize: 18, color: Colors.black),
            overflow: TextOverflow.ellipsis,
            maxLines: 1),
        backgroundColor: Constants.bgColor,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
            // Navigator.of(context, rootNavigator: true).pop();           
          },
          child: Icon(
            Icons.keyboard_arrow_left,
            size: 35,
            color: Colors.black, // add custom icons also
          ),
        ),
        
      ),
      floatingActionButton: Visibility(
        visible: isEditVisible,
        child: FloatingActionButton.extended(
          backgroundColor: Constants.appColor,
          elevation: 4.0,
          label:
              // _state == 1
              //     ?
              Text('    Update     ',
                  style: TextStyle(fontSize: 18, color: Colors.white)),
          // : CircularProgressIndicator(
          //     valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          //   ),
          onPressed: _submitCommand,
        ),
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
          : vendorinfo == null
              ? Center(
                  child: Text(errorMsg),
                )
              : Container(
                  height: double.infinity,
                  child: Stack(alignment: Alignment.topRight, children: [
                    Container(
                      height: double.infinity,
                      child: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Image(
                            image: AssetImage("assets/profile-bg.jpg"),
                            height: MediaQuery.of(context).size.height,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            top: 10,
                            left: 10,
                            right: 10,
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.grey.shade300,
                                      border: Border.all(
                                          color: Colors.white, width: 4)),
                                  child: Image(
                                    height: 60,
                                    image:
                                        AssetImage("assets/user-male-64.png"),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                Text(
                                  vendorinfo.listResult[0].vendorName != null ||
                                          vendorinfo.listResult[0].vendorName !=
                                              ""
                                      ? vendorinfo
                                          .listResult[0].vendorName.inCaps2
                                      : "",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  vendorinfo.listResult[0].email,
                                  style: TextStyle(color: Colors.white),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(40.0),
                              topLeft: Radius.circular(40.0)),
                          color: Colors.white,
                        ),
                        height: MediaQuery.of(context).size.height / 1.5,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 15, bottom: 8, left: 2, right: 2),
                          child: ListView(children: [
                            Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: GestureDetector(
                                    child: Card(
                                        elevation: 5,
                                        child: Container(
                                            child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  // color: Constants.appColor,
                                                ),
                                                child: Row(
                                                  children: <Widget>[
                                                    Image(
                                                      // color: Constants.wh,
                                                      image: AssetImage(
                                                        "assets/male-user.png",
                                                      ),
                                                      fit: BoxFit.contain,
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 5),
                                                      child: Text(
                                                        "Personal Details",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 17),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child:
                                                  Icon(Icons.arrow_forward_ios),
                                            )
                                          ],
                                        ))),
                                    onTap: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ProfileDetails()));
                                    },
                                  ),
                                ),

                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: GestureDetector(
                                     onTap: () {
                                                   Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => MyAddress(
               
                )));
                                                },
                                                                      child: Card(
                                        elevation: 5,
                                        child: Container(
                                            child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  // color: Constants.appColor,
                                                ),
                                                child: Row(
                                                  children: <Widget>[
                                                    Image(
                                                      // color: Constants.wh,
                                                      image: AssetImage(
                                                        "assets/home-address.png",
                                                      ),
                                                      fit: BoxFit.contain,
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 5),
                                                      child: Text(
                                                        "My Addresses",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 17),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child:
                                                  Icon(Icons.arrow_forward_ios),
                                            )
                                          ],
                                        ))),
                                  ),
                                ),
                              Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: GestureDetector(
                                     onTap: () {
                                                   Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ChangePassword(
               
                )));
                                                },
                                                                      child: Card(
                                        elevation: 5,
                                        child: Container(
                                            child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  // color: Constants.appColor,
                                                ),
                                                child: Row(
                                                  children: <Widget>[
                                                    Image(
                                                      // color: Constants.wh,
                                                      image: AssetImage(
                                                        "assets/home-address.png",
                                                      ),
                                                      fit: BoxFit.contain,
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 5),
                                                      child: Text(
                                                        "Change Password",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 17),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child:
                                                  Icon(Icons.arrow_forward_ios),
                                            )
                                          ],
                                        ))),
                                  ),
                                ),
                             
                              ],
                            ),
                          ]),
                        ),
                      ),
                    )
                  ]),
                ),
     
    );
  }
}

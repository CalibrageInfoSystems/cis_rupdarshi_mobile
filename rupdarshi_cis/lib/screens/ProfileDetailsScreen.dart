import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:progress_dialog/progress_dialog.dart';
import 'package:rupdarshi_cis/Model/LogisticResponse.dart';
import 'package:rupdarshi_cis/Model/StatesResModel.dart';
import 'package:rupdarshi_cis/Service/ApiService.dart';
import 'package:rupdarshi_cis/common/Constants.dart';
import 'package:rupdarshi_cis/common/LocalDb.dart';
import 'package:rupdarshi_cis/common/SessionManager.dart';
import 'package:rupdarshi_cis/Model/VendorProfile.dart' as vendor;
import 'package:rupdarshi_cis/screens/AccountScreen.dart';
import 'package:rupdarshi_cis/screens/Home_screen.dart';
import 'package:rupdarshi_cis/screens/NewHomeScreen.dart';

extension CapExtension1 on String {
  String get inCaps3 => '${this[0].toUpperCase()}${this.substring(1)}';
  String get allInCaps3 => this.toUpperCase();
}

class ProfileDetails extends StatefulWidget {
  @override
  _ProfileDetailsState createState() => _ProfileDetailsState();
}

class _ProfileDetailsState extends State<ProfileDetails> {
  int logisticID = 0;
  LogisticListResult logisticListResult;
  LogisticResponse logisticResponse;
  List<LogisticListResult> logistics;
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
      _logisticName,
      _pincode;
  int _roleid = 1, _serviceTypeId = 4;
  void _setAgreedToTOS(bool newValue) {
    setState(() {
      _agreedToTOS = newValue;
    });
  }

  int paymentID;
  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    myFocusNode.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    localData.getIntToSF(LocalData.PAYMENTTYPEID).then((paymentid) {
      setState(() {
        paymentID = paymentid;
        print('object payyyyyyyyyment id' + paymentID.toString());
      });
    });
    logisticResponse = new LogisticResponse();
    // logisticListResult = new LogisticListResult();

    logistics = new List<LogisticListResult>();
    myFocusNode = FocusNode();
    firstLoading = true;
    apiConnector = new ApiService();
    getLoggisticOparaters();
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
        _updateProfile();
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

  getLoggisticOparaters() {
    String loggisticURL = ApiService.baseUrl + ApiService.logisticOperatorURL;

    apiConnector.getAPICall(loggisticURL).then((response) {
      logisticResponse = LogisticResponse.fromJson(response);

      if (logisticResponse.isSuccess == true) {
        setState(() {
          logistics = logisticResponse.listResult;
        });
      }
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

        logisticID = vendorinfo.listResult[0].logisticOparatorId;
      });
      errorMsg = vendorinfo.listResult == null ? "No data found" : "";
      _getstates();
    });
  }

  void _updateProfile() async {
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
      "ServiceTypeId": vendorinfo.listResult[0].serviceTypeId,
      "CreatedByUserId": vendorinfo.listResult[0].createdbyUserId,
      "UpdatedByUserId": vendorinfo.listResult[0].createdbyUserId,
      "PreferlogisticOparatorId": logisticID,
      "PaymentTypeId": paymentID
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

          //  Navigator.pop(context);
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => NewHomeScreen()));

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
        title: Text('Personal Details',
            style: TextStyle(fontSize: 18, color: Colors.black),
            overflow: TextOverflow.ellipsis,
            maxLines: 1),
        backgroundColor: Constants.bgColor,
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
            color: Colors.black, // add custom icons also
          ),
        ),
        actions: [],
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
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(40.0),
                          topLeft: Radius.circular(40.0)),
                      color: Colors.white,
                    ),
                    height: MediaQuery.of(context).size.height / 1.5,
                    child: ListView(children: [
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Row(
                              // mainAxisAlignment:
                              //     MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Constants.appColor,
                                  ),
                                  child: Image(
                                    // color: Constants.wh,
                                    image: AssetImage(
                                      "assets/details-24.png",
                                    ),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '   Basic Details',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                isEditVisible = true;
                                                myFocusNode.requestFocus();
                                              });
                                            },
                                            child: Icon(
                                              Icons.edit,
                                              color: Constants.appColor,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    Text(
                                      '   Edit and manage your account details',
                                      style:
                                          TextStyle(color: Constants.greyColor),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: vendorinfo == null
                                ? Center(
                                    child: Text(errorMsg),
                                  )
                                : Form(
                                    key: formKey,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: <BoxShadow>[
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.1),
                                            blurRadius: 1,
                                            offset: Offset(
                                              2,
                                              2,
                                            ),
                                          ),
                                        ],
                                      ),
                                      child: Card(
                                        elevation: 2,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'First Name',
                                                style: TextStyle(
                                                    color: Constants.greyColor,
                                                    fontSize: 12),
                                              ),
                                              TextFormField(
                                                autofocus: false,
                                                cursorColor: Constants.appColor,
                                                focusNode: myFocusNode,
                                                inputFormatters: [
                                                  // ignore: deprecated_member_use
                                                  new WhitelistingTextInputFormatter(
                                                      RegExp("[a-zA-Z]")),
                                                ],
                                                enabled: isEditVisible == true
                                                    ? true
                                                    : false,
                                                decoration: InputDecoration(
                                                  isDense: true,
                                                  border: InputBorder.none,
                                                ),
                                                initialValue: vendorinfo
                                                                .listResult[0]
                                                                .firstName !=
                                                            null ||
                                                        vendorinfo.listResult[0]
                                                                .firstName !=
                                                            ""
                                                    ? vendorinfo
                                                        .listResult[0].firstName
                                                    : "",
                                                validator: (val) => val.length <
                                                        1
                                                    ? 'First Name is required '
                                                    : val.length < 2
                                                        ? 'First Name is too short.. '
                                                        : null,
                                                onSaved: (val) =>
                                                    _firstName = val,
                                                style: TextStyle(
                                                    color:
                                                        Constants.boldTextColor,
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Divider(
                                                color: Colors.grey[300],
                                                thickness: 1.5,
                                              ),
                                              Text(
                                                'Middle Name',
                                                style: TextStyle(
                                                    color: Constants.greyColor,
                                                    fontSize: 12),
                                              ),
                                              TextFormField(
                                                inputFormatters: [
                                                  // ignore: deprecated_member_use
                                                  new WhitelistingTextInputFormatter(
                                                      RegExp("[a-zA-Z]")),
                                                ],
                                                enabled: isEditVisible == true
                                                    ? true
                                                    : false,
                                                decoration: InputDecoration(
                                                  isDense: true,
                                                  border: InputBorder.none,
                                                ),
                                                initialValue: vendorinfo
                                                                .listResult[0]
                                                                .middleName !=
                                                            null ||
                                                        vendorinfo.listResult[0]
                                                                .middleName !=
                                                            ""
                                                    ? vendorinfo.listResult[0]
                                                        .middleName
                                                    : "",
                                                onSaved: (val) =>
                                                    _middleName = val,
                                                style: TextStyle(
                                                    color:
                                                        Constants.boldTextColor,
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Divider(
                                                color: Colors.grey[300],
                                                thickness: 1.5,
                                              ),
                                              Text(
                                                'Last Name',
                                                style: TextStyle(
                                                    color: Constants.greyColor,
                                                    fontSize: 12),
                                              ),
                                              TextFormField(
                                                inputFormatters: [
                                                  // ignore: deprecated_member_use
                                                  new WhitelistingTextInputFormatter(
                                                      RegExp("[a-zA-Z]")),
                                                ],
                                                enabled: isEditVisible == true
                                                    ? true
                                                    : false,
                                                decoration: InputDecoration(
                                                  isDense: true,
                                                  border: InputBorder.none,
                                                ),
                                                initialValue: vendorinfo
                                                                .listResult[0]
                                                                .lastName !=
                                                            null ||
                                                        vendorinfo.listResult[0]
                                                                .lastName !=
                                                            ""
                                                    ? vendorinfo
                                                        .listResult[0].lastName
                                                    : "",
                                                validator: (val) => val.length <
                                                        1
                                                    ? 'Last Name is required '
                                                    : val.length < 2
                                                        ? 'Last Name is too short'
                                                        : null,
                                                onSaved: (val) =>
                                                    _lastname = val,
                                                style: TextStyle(
                                                    color:
                                                        Constants.boldTextColor,
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Divider(
                                                color: Colors.grey[300],
                                                thickness: 1.5,
                                              ),
                                              Text(
                                                'User Name',
                                                style: TextStyle(
                                                    color: Constants.greyColor,
                                                    fontSize: 12),
                                              ),
                                              TextFormField(
                                                enabled: false,
                                                decoration: InputDecoration(
                                                  isDense: true,
                                                  border: InputBorder.none,
                                                ),
                                                initialValue: vendorinfo
                                                                .listResult[0]
                                                                .userName !=
                                                            null ||
                                                        vendorinfo.listResult[0]
                                                                .userName !=
                                                            ""
                                                    ? vendorinfo
                                                        .listResult[0].userName
                                                    : "",
                                                validator: (val) => val.length <
                                                        1
                                                    ? 'User Name is required '
                                                    : val.length < 4
                                                        ? 'User Name is too short'
                                                        : null,
                                                onSaved: (val) =>
                                                    _userName = val,
                                                style: TextStyle(
                                                    color:
                                                        Constants.boldTextColor,
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Divider(
                                                color: Colors.grey[300],
                                                thickness: 1.5,
                                              ),
                                              Text(
                                                'Phone',
                                                style: TextStyle(
                                                    color: Constants.greyColor,
                                                    fontSize: 12),
                                              ),
                                              TextFormField(
                                                maxLength: isEditVisible == true
                                                    ? 10
                                                    : null,
                                                keyboardType:
                                                    TextInputType.text,
                                                inputFormatters: <
                                                    TextInputFormatter>[
                                                  WhitelistingTextInputFormatter
                                                      .digitsOnly
                                                ],
                                                enabled: isEditVisible == true
                                                    ? true
                                                    : false,
                                                decoration: InputDecoration(
                                                  counterText: "",
                                                  isDense: true,
                                                  border: InputBorder.none,
                                                ),
                                                initialValue: vendorinfo
                                                    .listResult[0].mobileNumber,
                                                validator: (val) => val.length <
                                                        1
                                                    ? 'Mobile number is required '
                                                    : val.length < 10
                                                        ? 'Mobile number should be 10 digits'
                                                        : null,
                                                onSaved: (val) =>
                                                    _mobileNumber = val,
                                                style: TextStyle(
                                                    color:
                                                        Constants.boldTextColor,
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Divider(
                                                color: Colors.grey[300],
                                                thickness: 1.5,
                                              ),
                                              Text(
                                                'Email',
                                                style: TextStyle(
                                                    color: Constants.greyColor,
                                                    fontSize: 12),
                                              ),
                                              TextFormField(
                                                keyboardType:
                                                    TextInputType.emailAddress,
                                                enabled: isEditVisible == true
                                                    ? true
                                                    : false,
                                                decoration: InputDecoration(
                                                  isDense: true,
                                                  border: InputBorder.none,
                                                ),
                                                initialValue: vendorinfo
                                                    .listResult[0].email,
                                                validator: (val) =>
                                                    val.length < 1
                                                        ? 'Email is required '
                                                        : val.length < 4
                                                            ? ''
                                                            : null,
                                                onSaved: (val) => _email = val,
                                                style: TextStyle(
                                                    color:
                                                        Constants.boldTextColor,
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Row(
                              // mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Constants.appColor,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(3.0),
                                    child: Image(
                                      // color: Constants.wh,
                                      image: AssetImage(
                                        "assets/business-24.png",
                                      ),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '   Bussiness Details',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    Text(
                                      '   View your business details',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    blurRadius: 1,
                                    offset: Offset(
                                      2,
                                      2,
                                    ),
                                  ),
                                ],
                              ),
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Company/Business Name',
                                        style: TextStyle(
                                            color: Constants.greyColor,
                                            fontSize: 12),
                                      ),
                                      TextFormField(
                                        enabled: false,
                                        decoration: InputDecoration(
                                          isDense: true,
                                          border: InputBorder.none,
                                        ),
                                        initialValue: vendorinfo.listResult[0]
                                                        .businessName !=
                                                    null ||
                                                vendorinfo.listResult[0]
                                                        .businessName !=
                                                    ""
                                            ? vendorinfo
                                                .listResult[0].businessName
                                            : "",
                                        onSaved: (val) => _businessName = val,
                                        style: TextStyle(
                                            color: Constants.boldTextColor,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Divider(
                                        color: Colors.grey[300],
                                        thickness: 1.5,
                                      ),
                                      Text('GST Number',
                                          style: TextStyle(
                                              color: Constants.greyColor,
                                              fontSize: 12)),
                                      TextFormField(
                                        enabled: false,
                                        decoration: InputDecoration(
                                          isDense: true,
                                          border: InputBorder.none,
                                        ),
                                        initialValue:
                                            vendorinfo.listResult[0].gstin,
                                        onSaved: (val) => _gSTIN = val,
                                        style: TextStyle(
                                            color: Constants.boldTextColor,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Divider(
                                        color: Colors.grey[300],
                                        thickness: 1.5,
                                      ),
                                      Text('Address1',
                                          style: TextStyle(
                                              color: Constants.greyColor,
                                              fontSize: 12)),
                                      TextFormField(
                                        enabled: false,
                                        decoration: InputDecoration(
                                          isDense: true,
                                          border: InputBorder.none,
                                        ),
                                        initialValue: vendorinfo.listResult[0]
                                                        .address1 !=
                                                    "" ||
                                                vendorinfo.listResult[0]
                                                        .address1 !=
                                                    null
                                            ? vendorinfo.listResult[0].address1
                                            : "",
                                        onSaved: (val) => _address1 = val,
                                        style: TextStyle(
                                            color: Constants.boldTextColor,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Divider(
                                        color: Colors.grey[300],
                                        thickness: 1.5,
                                      ),
                                      Text('Address2',
                                          style: TextStyle(
                                              color: Constants.greyColor,
                                              fontSize: 12)),
                                      TextFormField(
                                        enabled: false,
                                        decoration: InputDecoration(
                                          isDense: true,
                                          border: InputBorder.none,
                                        ),
                                        initialValue: vendorinfo.listResult[0]
                                                        .address2 !=
                                                    "" ||
                                                vendorinfo.listResult[0]
                                                        .address2 !=
                                                    null
                                            ? vendorinfo.listResult[0].address2
                                            : "",
                                        onSaved: (val) => _address2 = val,
                                        style: TextStyle(
                                            color: Constants.boldTextColor,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Divider(
                                        color: Colors.grey[300],
                                        thickness: 1.5,
                                      ),
                                      Text('Landmark',
                                          style: TextStyle(
                                              color: Constants.greyColor,
                                              fontSize: 12)),
                                      TextFormField(
                                        enabled: false,
                                        decoration: InputDecoration(
                                          isDense: true,
                                          border: InputBorder.none,
                                        ),
                                        initialValue: vendorinfo.listResult[0]
                                                        .landmark !=
                                                    null ||
                                                vendorinfo.listResult[0]
                                                        .landmark !=
                                                    ""
                                            ? vendorinfo.listResult[0].landmark
                                            : "",
                                        onSaved: (val) => _landmark = val,
                                        style: TextStyle(
                                            color: Constants.boldTextColor,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Divider(
                                        color: Colors.grey[300],
                                        thickness: 1.5,
                                      ),
                                      Text('City/Village',
                                          style: TextStyle(
                                              color: Constants.greyColor,
                                              fontSize: 12)),
                                      TextFormField(
                                        enabled: false,
                                        decoration: InputDecoration(
                                          isDense: true,
                                          border: InputBorder.none,
                                        ),
                                        initialValue: vendorinfo
                                                        .listResult[0].city !=
                                                    null ||
                                                vendorinfo.listResult[0].city !=
                                                    ""
                                            ? vendorinfo.listResult[0].city
                                            : "",
                                        onSaved: (val) => _city = val,
                                        style: TextStyle(
                                            color: Constants.boldTextColor,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Divider(
                                        color: Colors.grey[300],
                                        thickness: 1.5,
                                      ),
                                      Text('District',
                                          style: TextStyle(
                                              color: Constants.greyColor,
                                              fontSize: 12)),
                                      TextFormField(
                                        enabled: false,
                                        decoration: InputDecoration(
                                          isDense: true,
                                          border: InputBorder.none,
                                        ),
                                        initialValue: vendorinfo.listResult[0]
                                                        .district !=
                                                    null ||
                                                vendorinfo.listResult[0]
                                                        .district !=
                                                    ""
                                            ? vendorinfo.listResult[0].district
                                            : "",
                                        onSaved: (val) => _district = val,
                                        style: TextStyle(
                                            color: Constants.boldTextColor,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Divider(
                                        color: Colors.grey[300],
                                        thickness: 1.5,
                                      ),
                                      Text('State',
                                          style: TextStyle(
                                              color: Constants.greyColor,
                                              fontSize: 12)),
                                      TextFormField(
                                        enabled: false,
                                        decoration: InputDecoration(
                                          isDense: true,
                                          border: InputBorder.none,
                                        ),
                                        initialValue:
                                            vendorinfo.listResult[0].stateName,
                                        onSaved: (val) =>
                                            selectedState.name = val,
                                        style: TextStyle(
                                            color: Constants.boldTextColor,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Divider(
                                        color: Colors.grey[300],
                                        thickness: 1.5,
                                      ),
                                      Text('Pincode',
                                          style: TextStyle(
                                              color: Constants.greyColor,
                                              fontSize: 12)),
                                      TextFormField(
                                        enabled: false,
                                        decoration: InputDecoration(
                                          isDense: true,
                                          border: InputBorder.none,
                                        ),
                                        initialValue:
                                            vendorinfo.listResult[0].pincode,
                                        onSaved: (val) => _pincode = val,
                                        style: TextStyle(
                                            color: Constants.boldTextColor,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Divider(
                                        color: Colors.grey[300],
                                        thickness: 1.5,
                                      ),
                                      Text('Logistic Operator Name',
                                          style: TextStyle(
                                              color: Constants.greyColor,
                                              fontSize: 12)),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      logistics == null
                                          ? Container()
                                          : DropdownButtonFormField(
                                              decoration: InputDecoration(
                                                enabledBorder:
                                                    new OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  borderSide: BorderSide(
                                                      color: Colors.grey),
                                                ),
                                                // labelText: 'Logistics *',
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5.0)),
                                              ),
                                              hint: Text(
                                                vendorinfo.listResult[0]
                                                    .logisticOparatorName,
                                                style: TextStyle(
                                                    color:
                                                        Constants.boldTextColor,
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              value: logisticListResult,
                                              isDense: true,
                                              isExpanded: true,
                                              onChanged: isEditVisible != true
                                                  ? null
                                                  : (newValue) {
                                                      setState(() {
                                                        logisticListResult =
                                                            newValue;
                                                        logisticID =
                                                            logisticListResult
                                                                .id;
                                                      });
                                                    },
                                              items: logistics.map((value) {
                                                return DropdownMenuItem(
                                                  value: value,
                                                  child: new Text(
                                                    value.name,
                                                    style: TextStyle(
                                                        color: Constants
                                                            .boldTextColor,
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ]),
                  ),
                ),
    );
  }
}

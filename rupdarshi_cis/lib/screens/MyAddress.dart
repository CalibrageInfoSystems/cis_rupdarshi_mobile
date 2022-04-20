import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rupdarshi_cis/Model/GetCartResponse.dart';
import 'package:rupdarshi_cis/Model/StatesResModel.dart';
import 'package:rupdarshi_cis/Model/VendorAddressReponse.dart';
import 'package:rupdarshi_cis/Service/ApiService.dart';
import 'package:rupdarshi_cis/common/Constants.dart';
import 'package:rupdarshi_cis/common/SessionManager.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:rupdarshi_cis/Model/VendorProfile.dart' as vendor;
import 'package:http/http.dart' as http;
import 'package:rupdarshi_cis/screens/AddressDetails.dart';

extension CapExtension1 on String {
  String get inCaps1 => '${this[0].toUpperCase()}${this.substring(1)}';
  String get allInCaps1 => this.toUpperCase();
}

final GlobalKey<State> _keyLoader = new GlobalKey<State>();
ProgressDialog pr;

class MyAddress extends StatefulWidget {
  @override
  _MyAddressState createState() => _MyAddressState();
}

class _MyAddressState extends State<MyAddress> {
  final formKey = GlobalKey<FormState>();
  List<ListResult> states = [];
  ListResult selectedState;
  int stateID = 0;

  String patttern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
  String pinPatttern = r'(^[1-9]{1}[0-9]{2}\s{0,1}[0-9]{3}$)';
  TextEditingController nameController = new TextEditingController();
  TextEditingController mobileNoController = new TextEditingController();
  TextEditingController pincodeController = new TextEditingController();
  TextEditingController address1Controller = new TextEditingController();
  TextEditingController address2Controller = new TextEditingController();
  TextEditingController cityController = new TextEditingController();
  TextEditingController landmarkController = new TextEditingController();
  TextEditingController districController = new TextEditingController();

  String _stateError;
  _validateForm() {
    bool _isValid = formKey.currentState.validate();
    if (_stateError == null || _stateError == "") {
      setState(() => _stateError = "State is required");
      _isValid = false;
    }
    if (_isValid) {
      //form is valid
    }
  }

  bool isFromEdit = false;
  bool isEditVisible = false;
  int _radioValue1 = -1;
  int _radioValue2 = -1;
  bool isAddressText = false;
  int oldIndex = 0;
  List<ListResultAddress> shippingAddreses;
  List<ListResultAddress> billingAddreses;
  void _handleRadioValueChange1(int value) {
    setState(() {
      _radioValue1 = value;
    });
  }

  void _handleRadioValueChange2(int value) {
    setState(() {
      _radioValue2 = value;
    });
  }

  SessionManager pref = new SessionManager();
  var discountedPrice = 0.0;
  int shippingaddressID = 0;
  int billingaddressID = 0;
  String errorMsg = "";
  vendor.VendorProfile vendorinfo;
  int userid;
  var totalPrice = 0.0;
  String errorMessage = "";
  var gstPrice = 0.0;
  bool islogin = false;
  bool firstLoading = true;
  bool isAddressVisible = true;
  ScrollController controller;
  ApiService api;
  GetCartResponse getCartResponse;
  VendorAddressReponse vendorAddressReponse;

  refresh() async {
    setState(() {
      print('Refresh ChangeAddress');

      SessionManager().getUserId().then((value) {
        userid = value;
        getAddressDetails(userid.toString());
      });
    });
  }

  @override
  void initState() {
    super.initState();
    firstLoading = true;
    isFromEdit = false;
    _radioValue1 = 1;
    oldIndex = 0;
    // isAddressVisible = false;
    isEditVisible = false;
    api = new ApiService();
    getCartResponse = new GetCartResponse();
    vendorAddressReponse = new VendorAddressReponse();
    shippingAddreses = List<ListResultAddress>();
    billingAddreses = List<ListResultAddress>();
    SessionManager().getUserId().then((value) {
      userid = value;
      getAddressDetails(userid.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double itemHeight = (size.height) / 3.5;
    final double itemWidth = size.width / 2;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return true;
      },
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          //resizeToAvoidBottomInset: false,
          appBar: AppBar(
            bottom: TabBar(indicatorColor: Constants.appColor, tabs: [
              Tab(
                  child: Text('Billing',
                      style: TextStyle(
                          color: Constants.boldTextColor, fontSize: 16))),
              Tab(
                  child: Text('Shipping',
                      style: TextStyle(
                          color: Constants.boldTextColor, fontSize: 16))),
            ]),
            title: Text(
              'Addresses',
              style: TextStyle(
                color: Constants.greyColor,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            backgroundColor: Constants.bgColor,
            leading: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.keyboard_arrow_left,
                size: 35,
                color: Constants.greyColor, // add custom icons also
              ),
            ),
          ),

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
              : TabBarView(
                  children: [
                    Column(
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Container(
                              child: RaisedButton(
                                color: Colors.yellow[50],
                                child: Text(
                                  " + Add New Address",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Constants.blackColor,
                                  ),
                                  overflow: TextOverflow.clip,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(1),
                                  side: BorderSide(
                                    width: 1,
                                    color: Constants.appColor,
                                  ),
                                ),
                                textColor: Constants.appColor,
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => AddressDetails(
                                            isfromEdit: false,
                                            addresstypeID: 20,
                                            address: null,
                                            refresh: refresh,
                                          )));
                                },
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                              itemCount: billingAddreses.length,
                              itemBuilder: (context, index) {
                                return new Card(
                                  elevation: 2,
                                  color: Colors.white,
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: <Widget>[
                                                            Align(
                                                              alignment:
                                                                  Alignment
                                                                      .topLeft,
                                                              child:
                                                                  billingAddreses ==
                                                                          null
                                                                      ? Container()
                                                                      : Text(
                                                                          "Address" +
                                                                              (index + 1).toString(),
                                                                          style: TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              color: Constants.boldTextColor,
                                                                              fontSize: 16.0),
                                                                          maxLines:
                                                                              2,
                                                                          overflow:
                                                                              TextOverflow.clip,
                                                                        ),
                                                            ),
                                                            Row(
                                                              children: [
                                                                GestureDetector(
                                                                  child: Icon(
                                                                    Icons.edit,
                                                                    color: Constants
                                                                        .lightgreyColor,
                                                                  ),
                                                                  //  Text(
                                                                  //   " Edit ",
                                                                  //   style:
                                                                  //       TextStyle(
                                                                  //     // fontSize:
                                                                  //     //     16,
                                                                  //     fontWeight:
                                                                  //         FontWeight
                                                                  //             .bold,
                                                                  //     color: Constants
                                                                  //         .appColor,
                                                                  //   ),
                                                                  // ),
                                                                  onTap: () {
                                                                    setState(
                                                                        () {
                                                                      print(
                                                                          'Billing');
                                                                      // isFromEdit = false;
                                                                      // addNewAddress(context, 0,0, null);
                                                                      Navigator.of(context).push(MaterialPageRoute(
                                                                          builder: (context) => AddressDetails(
                                                                                isfromEdit: true,
                                                                                addresstypeID: 20,
                                                                                address: billingAddreses[index],
                                                                                refresh: refresh,
                                                                              )));
                                                                    });
                                                                    //   isFromEdit = true;
                                                                    //  addNewAddress(context, 20, index, null);
                                                                  },
                                                                ),
                                                                SizedBox(
                                                                  width: 5,
                                                                ),
                                                                GestureDetector(
                                                                  child: Icon(
                                                                    Icons
                                                                        .delete_outline,
                                                                    color: Constants
                                                                        .appColor,
                                                                  ),
                                                                  // Text(
                                                                  //   " Delete ",
                                                                  //   style:
                                                                  //       TextStyle(
                                                                  //     // fontSize:
                                                                  //     //     16,
                                                                  //     fontWeight:
                                                                  //         FontWeight
                                                                  //             .bold,
                                                                  //     color: Colors.red
                                                                  //         ,
                                                                  //   ),
                                                                  // ),
                                                                  onTap: () {
                                                                    setState(
                                                                        () {
                                                                      if (billingAddreses
                                                                              .length >
                                                                          1) {
                                                                        print('Billing ' +
                                                                            billingAddreses[index].id.toString());

                                                                        _deleteAddress(
                                                                            billingAddreses[index].id);
                                                                      } else {
                                                                        api.globalToast(
                                                                            "Atlease one Billing address should be there");
                                                                      }
                                                                    });
                                                                    //   isFromEdit = true;
                                                                    //  addNewAddress(context, 20, index, null);
                                                                  },
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                        Divider(
                                                          color:
                                                              Colors.grey[300],
                                                          thickness: 1.5,
                                                        ),
                                                        // SizedBox(
                                                        //   height: 5,
                                                        // ),
                                                        Align(
                                                          alignment:
                                                              Alignment.topLeft,
                                                          child: billingAddreses[
                                                                          index]
                                                                      .addressName ==
                                                                  null
                                                              ? Container()
                                                              : Text(
                                                                  billingAddreses[
                                                                          index]
                                                                      .addressName
                                                                      .inCaps1,
                                                                  style:
                                                                      TextStyle(
                                                                    // fontWeight: FontWeight.w600,
                                                                    color: Constants
                                                                        .semiboldColor,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    // fontSize: 12.0
                                                                  ),
                                                                  maxLines: 2,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .clip,
                                                                ),
                                                        ),
                                                        SizedBox(
                                                          height: 2,
                                                        ),
                                                        Align(
                                                          alignment:
                                                              Alignment.topLeft,
                                                          child: billingAddreses[
                                                                          index]
                                                                      .mobilenumber ==
                                                                  null
                                                              ? Container()
                                                              : Text(
                                                                  billingAddreses[
                                                                          index]
                                                                      .mobilenumber,
                                                                  style:
                                                                      TextStyle(
                                                                    // fontWeight: FontWeight.w600,
                                                                    color: Constants
                                                                        .semiboldColor,
                                                                    // fontSize: 12.0
                                                                  ),
                                                                  maxLines: 2,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .clip,
                                                                ),
                                                        ),
                                                        Align(
                                                          alignment:
                                                              Alignment.topLeft,
                                                          child:
                                                              billingAddreses ==
                                                                      null
                                                                  ? Container()
                                                                  : Text(
                                                                      billingAddreses[
                                                                              index]
                                                                          .address1
                                                                          .inCaps1,
                                                                      style:
                                                                          TextStyle(
                                                                        // fontWeight: FontWeight.w600,
                                                                        color: Constants
                                                                            .semiboldColor,
                                                                        // fontSize: 12.0
                                                                      ),
                                                                      maxLines:
                                                                          2,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .clip,
                                                                    ),
                                                        ),
                                                        Align(
                                                          alignment:
                                                              Alignment.topLeft,
                                                          child: billingAddreses ==
                                                                  null
                                                              ? Container()
                                                              : billingAddreses[index]
                                                                              .address2 ==
                                                                          null ||
                                                                      billingAddreses[index]
                                                                              .address2 ==
                                                                          ""
                                                                  ? Container()
                                                                  : Text(
                                                                      billingAddreses[
                                                                              index]
                                                                          .address2
                                                                          .inCaps1,
                                                                      style:
                                                                          TextStyle(
                                                                        // fontWeight: FontWeight.w600,
                                                                        color: Constants
                                                                            .semiboldColor,
                                                                        // fontSize: 12.0
                                                                      ),
                                                                      maxLines:
                                                                          2,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .clip,
                                                                    ),
                                                        ),
                                                        Align(
                                                          alignment:
                                                              Alignment.topLeft,
                                                          child: billingAddreses ==
                                                                  null
                                                              ? Container()
                                                              : billingAddreses[index]
                                                                              .landmark ==
                                                                          null ||
                                                                      billingAddreses[index]
                                                                              .landmark ==
                                                                          ""
                                                                  ? Container()
                                                                  : Text(
                                                                      billingAddreses[
                                                                              index]
                                                                          .landmark
                                                                          .inCaps1,
                                                                      style:
                                                                          TextStyle(
                                                                        color: Constants
                                                                            .semiboldColor,
                                                                      ),
                                                                      maxLines:
                                                                          2,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .clip,
                                                                    ),
                                                        ),
                                                        Align(
                                                          alignment:
                                                              Alignment.topLeft,
                                                          child: Row(
                                                            children: [
                                                              billingAddreses ==
                                                                      null
                                                                  ? Container()
                                                                  : Text(
                                                                      billingAddreses[index]
                                                                              .city
                                                                              .inCaps1 +
                                                                          ", " +
                                                                          billingAddreses[index]
                                                                              .district,
                                                                      style:
                                                                          TextStyle(
                                                                        // fontWeight: FontWeight.w600,
                                                                        color: Constants
                                                                            .semiboldColor,
                                                                        // fontSize: 12.0
                                                                      ),
                                                                      maxLines:
                                                                          2,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .clip,
                                                                    ),
                                                            ],
                                                          ),
                                                        ),
                                                        Align(
                                                          alignment:
                                                              Alignment.topLeft,
                                                          child:
                                                              billingAddreses ==
                                                                      null
                                                                  ? Container()
                                                                  : Text(
                                                                      billingAddreses[index]
                                                                              .name
                                                                              .inCaps1 +
                                                                          ' - ' +
                                                                          billingAddreses[index]
                                                                              .pincode,
                                                                      style:
                                                                          TextStyle(
                                                                        // fontWeight: FontWeight.w600,
                                                                        color: Constants
                                                                            .semiboldColor,
                                                                        // fontSize: 13.0
                                                                      ),
                                                                      maxLines:
                                                                          2,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .clip,
                                                                    ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Container(
                              child: RaisedButton(
                                color: Colors.yellow[50],
                                child: Text(
                                  " + Add New Address",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Constants.blackColor,
                                  ),
                                  overflow: TextOverflow.clip,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(1),
                                  side: BorderSide(
                                    width: 1,
                                    color: Constants.appColor,
                                  ),
                                ),
                                textColor: Constants.appColor,
                                onPressed: () {
                                  setState(() {
                                    isFromEdit = false;
                                    // addNewAddress(context, 0,0, null);
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                AddressDetails(
                                                  isfromEdit: false,
                                                  addresstypeID: 21,
                                                  refresh: refresh,
                                                )));
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: shippingAddreses.length,
                            itemBuilder: (context, index) {
                              return Card(
                                elevation: 2,
                                color: Colors.white,
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: <Widget>[
                                                          Align(
                                                            alignment: Alignment
                                                                .topLeft,
                                                            child:
                                                                shippingAddreses ==
                                                                        null
                                                                    ? Container()
                                                                    : Text(
                                                                        "Address" +
                                                                            (index + 1).toString(),
                                                                        style: TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            color: Constants.boldTextColor,
                                                                            fontSize: 16.0),
                                                                        maxLines:
                                                                            2,
                                                                        overflow:
                                                                            TextOverflow.clip,
                                                                      ),
                                                          ),
                                                          Row(
                                                            children: [
                                                              GestureDetector(
                                                                child: Icon(
                                                                  Icons.edit,
                                                                  color: Constants
                                                                      .lightgreyColor,
                                                                ),
                                                                onTap: () {
                                                                  setState(() {
                                                                    print(
                                                                        'Shipping 21');
                                                                    Navigator.of(
                                                                            context)
                                                                        .push(MaterialPageRoute(
                                                                            builder: (context) => AddressDetails(
                                                                                  isfromEdit: true,
                                                                                  addresstypeID: 21,
                                                                                  address: shippingAddreses[index],
                                                                                  refresh: refresh,
                                                                                )));
                                                                    // _stateError = null;
                                                                  });
                                                                },
                                                              ),
                                                              SizedBox(
                                                                width: 5,
                                                              ),
                                                              GestureDetector(
                                                                child: Icon(
                                                                  Icons
                                                                      .delete_outline,
                                                                  color: Constants
                                                                      .appColor,
                                                                ),
                                                                onTap: () {
                                                                  setState(() {
                                                                    if (shippingAddreses
                                                                            .length >
                                                                        1) {
                                                                      print('Shipping ' +
                                                                          shippingAddreses[index]
                                                                              .id
                                                                              .toString());

                                                                      _deleteAddress(
                                                                          shippingAddreses[index]
                                                                              .id);
                                                                    } else {
                                                                      api.globalToast(
                                                                          "Atlease one Shipping address should be there");
                                                                    }
                                                                  });
                                                                  //   isFromEdit = true;
                                                                  //  addNewAddress(context, 20, index, null);
                                                                },
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                      Divider(
                                                        color: Colors.grey[300],
                                                        thickness: 1.5,
                                                      ),
                                                      // SizedBox(
                                                      //   height: 5,
                                                      // ),
                                                      Align(
                                                        alignment:
                                                            Alignment.topLeft,
                                                        child:
                                                            shippingAddreses ==
                                                                    null
                                                                ? Container()
                                                                : Text(
                                                                    shippingAddreses[
                                                                            index]
                                                                        .addressName
                                                                        .inCaps1,
                                                                    style:
                                                                        TextStyle(
                                                                      // fontWeight: FontWeight.w600,
                                                                      color: Constants
                                                                          .semiboldColor,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      // fontSize: 12.0
                                                                    ),
                                                                    maxLines: 2,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .clip,
                                                                  ),
                                                      ),
                                                      SizedBox(
                                                        height: 2,
                                                      ),
                                                      Align(
                                                        alignment:
                                                            Alignment.topLeft,
                                                        child:
                                                            shippingAddreses ==
                                                                    null
                                                                ? Container()
                                                                : Text(
                                                                    shippingAddreses[
                                                                            index]
                                                                        .mobilenumber,
                                                                    style:
                                                                        TextStyle(
                                                                      // fontWeight: FontWeight.w600,
                                                                      color: Constants
                                                                          .semiboldColor,
                                                                      // fontSize: 12.0
                                                                    ),
                                                                    maxLines: 2,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .clip,
                                                                  ),
                                                      ),
                                                      Align(
                                                        alignment:
                                                            Alignment.topLeft,
                                                        child:
                                                            shippingAddreses ==
                                                                    null
                                                                ? Container()
                                                                : Text(
                                                                    shippingAddreses[
                                                                            index]
                                                                        .address1
                                                                        .inCaps1,
                                                                    style:
                                                                        TextStyle(
                                                                      // fontWeight: FontWeight.w600,
                                                                      color: Constants
                                                                          .semiboldColor,
                                                                      // fontSize: 12.0
                                                                    ),
                                                                    maxLines: 2,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .clip,
                                                                  ),
                                                      ),
                                                      Align(
                                                        alignment:
                                                            Alignment.topLeft,
                                                        child: shippingAddreses ==
                                                                null
                                                            ? Container()
                                                            : shippingAddreses[index]
                                                                            .address2 ==
                                                                        "" ||
                                                                    shippingAddreses[index]
                                                                            .address2 ==
                                                                        null
                                                                ? Container()
                                                                : Text(
                                                                    shippingAddreses[
                                                                            index]
                                                                        .address2
                                                                        .inCaps1,
                                                                    style:
                                                                        TextStyle(
                                                                      // fontWeight: FontWeight.w600,
                                                                      color: Constants
                                                                          .semiboldColor,
                                                                      // fontSize: 12.0
                                                                    ),
                                                                    maxLines: 2,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .clip,
                                                                  ),
                                                      ),
                                                      Align(
                                                        alignment:
                                                            Alignment.topLeft,
                                                        child: shippingAddreses ==
                                                                null
                                                            ? Container()
                                                            : shippingAddreses[index]
                                                                            .landmark ==
                                                                        "" ||
                                                                    shippingAddreses[index]
                                                                            .landmark ==
                                                                        null
                                                                ? Container()
                                                                : Text(
                                                                    shippingAddreses[index].landmark ==
                                                                                null ||
                                                                            shippingAddreses[index].landmark ==
                                                                                ""
                                                                        ? ""
                                                                        : shippingAddreses[index]
                                                                            .landmark
                                                                            .inCaps1,
                                                                    style:
                                                                        TextStyle(
                                                                      color: Constants
                                                                          .semiboldColor,
                                                                    ),
                                                                    maxLines: 2,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .clip,
                                                                  ),
                                                      ),
                                                      Align(
                                                        alignment:
                                                            Alignment.topLeft,
                                                        child: Row(
                                                          children: [
                                                            shippingAddreses ==
                                                                    null
                                                                ? Container()
                                                                : Text(
                                                                    shippingAddreses[index]
                                                                            .city
                                                                            .inCaps1 +
                                                                        ", " +
                                                                        shippingAddreses[index]
                                                                            .district,
                                                                    style:
                                                                        TextStyle(
                                                                      // fontWeight: FontWeight.w600,
                                                                      color: Constants
                                                                          .semiboldColor,
                                                                      // fontSize: 12.0
                                                                    ),
                                                                    maxLines: 2,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .clip,
                                                                  ),
                                                          ],
                                                        ),
                                                      ),
                                                      Align(
                                                        alignment:
                                                            Alignment.topLeft,
                                                        child:
                                                            shippingAddreses ==
                                                                    null
                                                                ? Container()
                                                                : Text(
                                                                    shippingAddreses[index]
                                                                            .name
                                                                            .inCaps1 +
                                                                        ' - ' +
                                                                        shippingAddreses[index]
                                                                            .pincode,
                                                                    style:
                                                                        TextStyle(
                                                                      // fontWeight: FontWeight.w600,
                                                                      color: Constants
                                                                          .semiboldColor,
                                                                      // fontSize: 13.0
                                                                    ),
                                                                    maxLines: 2,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .clip,
                                                                  ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
          // ]),
        ),
      ),
      // ),
    );
  }

  Widget address1() {
    return ListView.builder(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        itemCount: vendorAddressReponse == null
            ? 0
            : vendorAddressReponse.listResult.length,
        itemBuilder: (BuildContext context, int index) {
          var size = MediaQuery.of(context).size;
          final double itemHeight = (size.height) / 3.5;
          final double itemWidth = size.width / 2.2;
          return Padding(
              padding: const EdgeInsets.all(1.0),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 2,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: new Card(
                  elevation: 2,
                  color: Colors.white,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: [
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Radio(
                                      activeColor: Constants.appColor,
                                      value: index + 1,
                                      groupValue: _radioValue1,
                                      onChanged: (value) {
                                        setState(() {
                                          print('Radio $value');

                                          print(oldIndex);

                                          _handleRadioValueChange1(value);
                                          shippingaddressID =
                                              vendorAddressReponse
                                                  .listResult[index].id;

                                          print(vendorAddressReponse
                                              .listResult[index].id);

                                          if (oldIndex != index) {
                                            print("wwwwwwwwww " +
                                                oldIndex.toString());
                                            vendorAddressReponse
                                                .listResult[oldIndex]
                                                .isAddressSelected = false;
                                          }
                                          oldIndex = index;
                                          if (vendorAddressReponse
                                                  .listResult[index]
                                                  .isAddressSelected ==
                                              true) {
                                            vendorAddressReponse
                                                .listResult[index]
                                                .isAddressSelected = false;
                                          } else {
                                            print("tttttttttttttt");
                                            vendorAddressReponse
                                                .listResult[index]
                                                .isAddressSelected = true;
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Align(
                                          alignment: Alignment.topLeft,
                                          child: vendorAddressReponse
                                                      .listResult ==
                                                  null
                                              ? Container()
                                              : Text(
                                                  vendorAddressReponse
                                                      .listResult[index]
                                                      .addressName
                                                      .inCaps1,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          Constants.blackColor,
                                                      fontSize: 14.0),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.clip,
                                                ),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Align(
                                          alignment: Alignment.topLeft,
                                          child: Text(
                                            vendorAddressReponse.listResult ==
                                                    null
                                                ? ""
                                                : vendorAddressReponse
                                                    .listResult[index]
                                                    .address1
                                                    .inCaps1,
                                            style: TextStyle(
                                              // fontWeight: FontWeight.w600,
                                              color: Constants.semiboldColor,
                                              // fontSize: 12.0
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.clip,
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.topLeft,
                                          child: vendorAddressReponse
                                                          .listResult[index]
                                                          .address2 ==
                                                      null ||
                                                  vendorAddressReponse
                                                          .listResult[index]
                                                          .address2 ==
                                                      ""
                                              ? null
                                              : Text(
                                                  vendorAddressReponse
                                                      .listResult[index]
                                                      .address2
                                                      .inCaps1,
                                                  style: TextStyle(
                                                    // fontWeight: FontWeight.w600,
                                                    color:
                                                        Constants.semiboldColor,
                                                    // fontSize: 12.0
                                                  ),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.clip,
                                                ),
                                        ),
                                        Align(
                                          alignment: Alignment.topLeft,
                                          child: vendorAddressReponse
                                                          .listResult[index]
                                                          .landmark ==
                                                      null ||
                                                  vendorAddressReponse
                                                          .listResult[index]
                                                          .landmark ==
                                                      ""
                                              ? null
                                              : Text(
                                                  vendorAddressReponse
                                                      .listResult[index]
                                                      .landmark
                                                      .inCaps1,
                                                  style: TextStyle(
                                                    // fontWeight: FontWeight.w600,
                                                    color:
                                                        Constants.semiboldColor,
                                                    // fontSize: 12.0
                                                  ),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.clip,
                                                ),
                                        ),
                                        Align(
                                          alignment: Alignment.topLeft,
                                          child: Row(
                                            children: [
                                              Text(
                                                vendorAddressReponse
                                                            .listResult ==
                                                        null
                                                    ? ""
                                                    : vendorAddressReponse
                                                            .listResult[index]
                                                            .city
                                                            .inCaps1 +
                                                        ', ' +
                                                        vendorAddressReponse
                                                            .listResult[index]
                                                            .district
                                                            .inCaps1,
                                                style: TextStyle(
                                                  // fontWeight: FontWeight.w600,
                                                  color:
                                                      Constants.semiboldColor,
                                                  // fontSize: 12.0
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.clip,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.topLeft,
                                          child: Text(
                                            vendorAddressReponse.listResult ==
                                                    null
                                                ? ""
                                                : vendorAddressReponse
                                                        .listResult[index]
                                                        .name
                                                        .inCaps1 +
                                                    ' - ' +
                                                    vendorAddressReponse
                                                        .listResult[index]
                                                        .pincode,
                                            style: TextStyle(
                                              // fontWeight: FontWeight.w600,
                                              color: Constants.semiboldColor,
                                              // fontSize: 13.0
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.clip,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ));
        });
  }

  selectAddress() {
    Container(
      color: Colors.red,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            child: RaisedButton(
              color: Colors.yellow[50],
              child: Text(
                "Back",
                style: TextStyle(
                  fontSize: 12,
                  //fontWeight: FontWeight.bold,
                  color: Constants.blackColor,
                ),
                overflow: TextOverflow.clip,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(1),
                side: BorderSide(
                  width: 1,
                  color: Constants.appColor,
                ),
              ),
              textColor: Constants.appColor,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Container(
              // color: Colors.red,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    " Select Shipping Address",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Constants.blackColor,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Container(
                      child: RaisedButton(
                        color: Colors.yellow[50],
                        child: Text(
                          " + Add New Address",
                          style: TextStyle(
                            fontSize: 12,
                            //fontWeight: FontWeight.bold,
                            color: Constants.blackColor,
                          ),
                          overflow: TextOverflow.clip,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(1),
                          side: BorderSide(
                            width: 1,
                            color: Constants.appColor,
                          ),
                        ),
                        textColor: Constants.appColor,
                        onPressed: () {},
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          addressList(shippingAddreses),
          Align(
            alignment: Alignment.bottomCenter,
            child: Material(
              child: GestureDetector(
                child: Container(
                    height: 50,
                    color: Constants.appColor,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        " Continue ",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 15.0),
                      ),
                    )),
                onTap: () {
                  // _createAddress(addressTypeID);
                  // if (_validateForm() != false &&
                  //     formKey.currentState.validate()) {
                  //   _createAddress(addressTypeID);
                  // }
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget addressList(List<ListResultAddress> shippingAddreses) {
    var size = MediaQuery.of(context).size;
    final double itemHeight = (size.height);
    return Container(
      color: Colors.white,
      height: itemHeight - 200,
      child: ListView.builder(
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          itemCount: shippingAddreses == null ? 0 : shippingAddreses.length,
          itemBuilder: (BuildContext context, int index) {
            var size = MediaQuery.of(context).size;
            final double itemHeight = (size.height) / 3.5;
            final double itemWidth = size.width / 2.2;
            return Padding(
                padding: const EdgeInsets.all(5.0),
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 2,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  child: new Card(
                    elevation: 2,
                    color: Colors.white,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: [
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Radio(
                                        activeColor: Constants.appColor,
                                        value: index + 1,
                                        groupValue: _radioValue1,
                                        onChanged: (value) {
                                          setState(() {
                                            print('Radio $value');

                                            print(oldIndex);

                                            _handleRadioValueChange2(value);
                                          });
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Align(
                                            alignment: Alignment.topLeft,
                                            child: shippingAddreses == null
                                                ? Container()
                                                : Text(
                                                    shippingAddreses[index]
                                                        .addressName
                                                        .inCaps1,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Constants
                                                            .blackColor,
                                                        fontSize: 14.0),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.clip,
                                                  ),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Align(
                                            alignment: Alignment.topLeft,
                                            child: Text(
                                              shippingAddreses == null
                                                  ? ""
                                                  : shippingAddreses[index]
                                                      .address1
                                                      .inCaps1,
                                              style: TextStyle(
                                                // fontWeight: FontWeight.w600,
                                                color: Constants.semiboldColor,
                                                // fontSize: 12.0
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.clip,
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.topLeft,
                                            child: shippingAddreses[index]
                                                            .address2 ==
                                                        null ||
                                                    shippingAddreses[index]
                                                            .address2 ==
                                                        ""
                                                ? Container()
                                                : Text(
                                                    shippingAddreses[index]
                                                        .address2
                                                        .inCaps1,
                                                    style: TextStyle(
                                                      // fontWeight: FontWeight.w600,
                                                      color: Constants
                                                          .semiboldColor,
                                                      // fontSize: 12.0
                                                    ),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.clip,
                                                  ),
                                          ),
                                          Align(
                                            alignment: Alignment.topLeft,
                                            child: shippingAddreses[index]
                                                            .landmark ==
                                                        null ||
                                                    shippingAddreses[index]
                                                            .landmark ==
                                                        ""
                                                ? null
                                                : Text(
                                                    shippingAddreses[index]
                                                        .landmark
                                                        .inCaps1,
                                                    style: TextStyle(
                                                      // fontWeight: FontWeight.w600,
                                                      color: Constants
                                                          .semiboldColor,
                                                      // fontSize: 12.0
                                                    ),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.clip,
                                                  ),
                                          ),
                                          Align(
                                            alignment: Alignment.topLeft,
                                            child: Row(
                                              children: [
                                                Text(
                                                  shippingAddreses == null
                                                      ? ""
                                                      : shippingAddreses[index]
                                                              .city
                                                              .inCaps1 +
                                                          ', ' +
                                                          shippingAddreses[
                                                                  index]
                                                              .district
                                                              .inCaps1,
                                                  style: TextStyle(
                                                    // fontWeight: FontWeight.w600,
                                                    color:
                                                        Constants.semiboldColor,
                                                    // fontSize: 12.0
                                                  ),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.clip,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.topLeft,
                                            child: Text(
                                              shippingAddreses == null
                                                  ? ""
                                                  : shippingAddreses[index]
                                                          .name
                                                          .inCaps1 +
                                                      ' - ' +
                                                      shippingAddreses[index]
                                                          .pincode,
                                              style: TextStyle(
                                                // fontWeight: FontWeight.w600,
                                                color: Constants.semiboldColor,
                                                // fontSize: 13.0
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.clip,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ));
          }),
    );
  }

  addNewAddress(BuildContext context, int addressTypeID, int index,
      ListResultAddress address) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          var size = MediaQuery.of(context).size;
          final double itemHeight = (size.height);
          RegExp regExp = new RegExp(patttern);
          RegExp pinregExp = new RegExp(pinPatttern);
          if (addressTypeID == 20) {
            nameController.text = billingAddreses[index].addressName.toString();
            mobileNoController.text =
                billingAddreses[index].mobilenumber.toString();
            address1Controller.text =
                billingAddreses[index].address1.toString();
            address2Controller.text =
                billingAddreses[index].address2.toString();
            landmarkController.text =
                billingAddreses[index].landmark.toString();
            cityController.text = billingAddreses[index].city.toString();
            districController.text = billingAddreses[index].district.toString();
            pincodeController.text = billingAddreses[index].pincode.toString();
            selectedState = states
                .firstWhere((x) => x.id == billingAddreses[index].stateid);
          } else if (addressTypeID == 21) {
            nameController.text =
                shippingAddreses[index].addressName.toString();
            mobileNoController.text =
                shippingAddreses[index].mobilenumber.toString();
            address1Controller.text =
                shippingAddreses[index].address1.toString();
            address2Controller.text =
                shippingAddreses[index].address2.toString();
            landmarkController.text =
                shippingAddreses[index].landmark.toString();
            cityController.text = shippingAddreses[index].city.toString();
            districController.text =
                shippingAddreses[index].district.toString();
            pincodeController.text = shippingAddreses[index].pincode.toString();
          } else {}

          return SizedBox.expand(
              child: Container(
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Stack(children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: <Widget>[
                        Container(
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: GestureDetector(
                              child: Icon(Icons.arrow_back_ios),
                              onTap: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              child: Text(
                                'Add address',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Constants.greyColor,
                                    fontSize: 15.0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider()
                ]),
                Container(
                  height: itemHeight - 120,
                  child: SingleChildScrollView(
                    child: Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: Colors.white,
                                blurRadius: 2,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: <Widget>[
                              Card(
                                elevation: 2,
                                color: Colors.white,
                                child: Form(
                                  key: formKey,
                                  child: Column(
                                    children: <Widget>[
                                      TextFormField(
                                        keyboardType: TextInputType.text,
                                        controller: nameController,
                                        decoration: InputDecoration(
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                new BorderRadius.circular(8.0),
                                            borderSide: BorderSide(
                                                color: Constants.blackColor,
                                                width: 1.5),
                                          ),
                                          labelText: 'Name*',
                                          labelStyle: TextStyle(
                                            color: Constants.lightgreyColor,
                                            // fontWeight: FontWeight.bold
                                          ),
                                          border: new OutlineInputBorder(
                                            borderRadius:
                                                new BorderRadius.circular(8.0),
                                          ),
                                        ),
                                        validator: (val) => val.length < 1
                                            ? 'Name is Required'
                                            : val.length < 2
                                                ? 'Name is too short'
                                                : null,
                                        onFieldSubmitted: (value) {
                                          setState(() {
                                            nameController.text = value;
                                          });
                                        },
                                        // onSaved: (val) => _userName = val,
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      TextFormField(
                                        controller: mobileNoController,
                                        keyboardType: TextInputType.number,
                                        maxLength: 10,
                                        // initialValue:
                                        // //  vendorAddressReponse != null?
                                        //      vendorinfo.listResult[0].mobileNumber,
                                        //     // : "",
                                        decoration: InputDecoration(
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                new BorderRadius.circular(8.0),
                                            borderSide: BorderSide(
                                                color: Constants.blackColor,
                                                width: 1.5),
                                          ),
                                          labelText: 'Mobile Number*',
                                          labelStyle: TextStyle(
                                            color: Constants.lightgreyColor,
                                            // fontWeight: FontWeight.bold
                                          ),
                                          border: new OutlineInputBorder(
                                            borderRadius:
                                                new BorderRadius.circular(8.0),
                                          ),
                                        ),
                                        validator: (val) => val.length < 1
                                            ? 'Mobile Number is Required'
                                            : val.length < 10
                                                ? 'Mobile Number Should be 10 digits'
                                                : !regExp.hasMatch(val)
                                                    ? 'Please enter valid mobile number'
                                                    : null,
                                        // onSaved: (val) => _mobileNumber = val,
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      TextFormField(
                                        controller: address1Controller,
                                        maxLines: 1,
                                        // initialValue:
                                        // //  vendorAddressReponse == null?
                                        //      vendorinfo.listResult[0].address1,
                                        //     // : "",
                                        decoration: InputDecoration(
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                new BorderRadius.circular(8.0),
                                            borderSide: BorderSide(
                                                color: Constants.blackColor,
                                                width: 1.5),
                                          ),
                                          labelText: 'Address1*',
                                          labelStyle: TextStyle(
                                              color: Constants.lightgreyColor
                                              // fontWeight: FontWeight.bold
                                              ),
                                          border: new OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Constants.blackColor),
                                            borderRadius:
                                                new BorderRadius.circular(8.0),
                                          ),
                                        ),
                                        validator: (val) => val.length < 1
                                            ? 'Address1 is Required'
                                            : val.length < 4
                                                ? 'Address1 is too short.. '
                                                : null,
                                        // onSaved: (val) => _address1 = val,
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      TextFormField(
                                        controller: address2Controller,
                                        // maxLines: 2,
                                        // initialValue: vendorAddressReponse == null
                                        //     ? vendorinfo.listResult[0].address2
                                        //     : "",
                                        decoration: InputDecoration(
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                new BorderRadius.circular(8.0),
                                            borderSide: BorderSide(
                                                color: Constants.blackColor,
                                                width: 1.5),
                                          ),
                                          labelText: 'Address2',
                                          labelStyle: TextStyle(
                                              color: Constants.lightgreyColor
                                              // fontWeight: FontWeight.bold
                                              ),
                                          border: new OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Constants.blackColor),
                                            borderRadius:
                                                new BorderRadius.circular(8.0),
                                          ),
                                        ),
                                        // validator: (val) => val.length < 1
                                        // ? 'Address is Required' :
                                        //  val.length < 4
                                        //     ? 'Address is too short.. '
                                        //     : null,
                                        // onSaved: (val) => _address2 = val,
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      TextFormField(
                                        controller: landmarkController,
                                        // initialValue:
                                        // //  vendorAddressReponse == null?
                                        //      vendorinfo.listResult[0].landmark,
                                        //     // : "",
                                        decoration: InputDecoration(
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                new BorderRadius.circular(8.0),
                                            borderSide: BorderSide(
                                                color: Constants.blackColor,
                                                width: 1.5),
                                          ),
                                          labelText: 'Landmark',
                                          labelStyle: TextStyle(
                                            color: Constants.lightgreyColor,
                                            // fontWeight: FontWeight.bold
                                          ),
                                          border: new OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Constants.blackColor,
                                                width: 1.5),
                                            borderRadius:
                                                new BorderRadius.circular(8.0),
                                          ),
                                        ),
                                        //   validator: (val) => val.length < 1
                                        // ? 'Landmark is Required' :
                                        //  val.length < 4
                                        //     ? 'Landmark is too short.. '
                                        //     : null,
                                        // onSaved: (val) => _landmark = val,
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      TextFormField(
                                        controller: cityController,
                                        // initialValue:
                                        // //  vendorAddressReponse == null ?
                                        //      vendorinfo.listResult[0].city,
                                        //     // : "",
                                        decoration: InputDecoration(
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                new BorderRadius.circular(8.0),
                                            borderSide: BorderSide(
                                                color: Constants.blackColor,
                                                width: 1.5),
                                          ),
                                          labelText: 'City*',
                                          labelStyle: TextStyle(
                                            color: Constants.lightgreyColor,
                                            // fontWeight: FontWeight.bold
                                          ),
                                          border: new OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Constants.blackColor),
                                            borderRadius:
                                                new BorderRadius.circular(8.0),
                                          ),
                                        ),
                                        validator: (val) => val.length < 1
                                            ? 'City is Required'
                                            : val.length < 4
                                                ? 'City is too short.. '
                                                : null,
                                        //  onSaved: (val) => _city = val,
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      TextFormField(
                                        controller: districController,
                                        // initialValue:
                                        // //  vendorAddressReponse == null ?
                                        //      vendorinfo.listResult[0].city,
                                        //     // : "",
                                        decoration: InputDecoration(
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                new BorderRadius.circular(8.0),
                                            borderSide: BorderSide(
                                                color: Constants.blackColor,
                                                width: 1.5),
                                          ),
                                          labelText: 'District',
                                          labelStyle: TextStyle(
                                            color: Constants.lightgreyColor,
                                            // fontWeight: FontWeight.bold
                                          ),
                                          border: new OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Constants.blackColor),
                                            borderRadius:
                                                new BorderRadius.circular(8.0),
                                          ),
                                        ),
                                        // validator: (val) => val.length < 1
                                        //     ? 'District is Required'
                                        //     : val.length < 4
                                        //         ? 'District is too short.. '
                                        //         : null,
                                        //  onSaved: (val) => _city = val,
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      DropdownButtonHideUnderline(
                                          child: states == null
                                              ? Container()
                                              : DropdownButtonFormField(
                                                  decoration: InputDecoration(
                                                    enabledBorder:
                                                        new OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                      borderSide: BorderSide(
                                                          color: _stateError ==
                                                                  null
                                                              ? Colors.grey
                                                              : Colors.red),
                                                    ),
                                                    labelText: 'State *',
                                                    border: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5.0)),
                                                  ),
                                                  // hint: Text("State*"),
                                                  value: selectedState,
                                                  isDense: true,
                                                  onChanged: (newValue) {
                                                    setState(() {
                                                      selectedState = newValue;
                                                      stateID =
                                                          selectedState.id;
                                                      _stateError = null;
                                                      print('----' +
                                                          selectedState.name);
                                                    });
                                                  },
                                                  items: states.map((value) {
                                                    return DropdownMenuItem(
                                                      value: value,
                                                      child:
                                                          new Text(value.name),
                                                    );
                                                  }).toList(),
                                                )),
                                      Padding(
                                        padding: _stateError == null
                                            ? const EdgeInsets.only(left: 0)
                                            : const EdgeInsets.only(
                                                left: 10, top: 5, bottom: 5),
                                        child: _stateError == null
                                            ? SizedBox.shrink()
                                            : Text(
                                                _stateError ?? "",
                                                style: TextStyle(
                                                    color: Colors.red[700],
                                                    fontSize: 13),
                                              ),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      TextFormField(
                                        controller: pincodeController,
                                        keyboardType: TextInputType.number,
                                        maxLength: 6,
                                        // initialValue:
                                        // //  vendorAddressReponse == null?
                                        //     vendorinfo.listResult[0].pincode,
                                        //     // : "",
                                        decoration: InputDecoration(
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                new BorderRadius.circular(8.0),
                                            borderSide: BorderSide(
                                                color: Constants.blackColor,
                                                width: 1.5),
                                          ),
                                          labelText: 'Pincode*',
                                          labelStyle: TextStyle(
                                            color: Constants.lightgreyColor,
                                            // fontWeight: FontWeight.bold
                                          ),
                                          border: new OutlineInputBorder(
                                            borderRadius:
                                                new BorderRadius.circular(8.0),
                                          ),
                                        ),
                                        validator: (val) => val.length < 1
                                            ? 'Pincode is Required'
                                            : val.length < 6
                                                ? 'Pincode is too short'
                                                : !pinregExp.hasMatch(val)
                                                    ? 'Please enter valid Pincode'
                                                    : null,
                                        // onSaved: (val) => _pincode = val,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Material(
                        child: GestureDetector(
                          child: Container(
                              decoration: BoxDecoration(
                                  color: Constants.appColor,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5))),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Text(
                                  isFromEdit != true ? " Submit " : "Update",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 12.0),
                                ),
                              )),
                          onTap: () {
                            // _createAddress(addressTypeID);
                            if (_validateForm() != false &&
                                formKey.currentState.validate()) {
                              _createAddress(addressTypeID);
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ));
        });
  }

  void _deleteAddress(int addressID) async {
    var baseurl = ApiService.baseUrl;
    var url = baseurl + ApiService.deleteAddress;

    Map data = {"AddressId": addressID, "IsActive": false};

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
          api.globalToast(data['EndUserMessage']);
          getAddressDetails(userid.toString());
        } else {
          api.globalToast(data['EndUserMessage']);
        }
      } else {
        api.globalToast('Something went wrong ..');
      }
    });
  }

  void _createAddress(int addressID) async {
    var baseurl = ApiService.baseUrl;
    var url = baseurl + ApiService.addUpdateAddress;

    Map data = {
      "Id": 0,
      "VendorId": userid,
      "StateId": stateID,
      "District": districController.text,
      "City": cityController.text,
      "Landmark": landmarkController.text,
      "Address1": address1Controller.text,
      "Address2": address2Controller.text,
      "Pincode": pincodeController.text,
      "MobileNumber": mobileNoController.text,
      "IsActive": true,
      "Name": nameController.text,
      "AddressTypeId": addressID,
      "Aproved": false
    };

    print('Request Data :' + data.toString());
  }

  showAddress(BuildContext context, int addressTypeID,
      List<ListResultAddress> addreses) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          var size = MediaQuery.of(context).size;
          final double itemHeight = (size.height) / 4.5;

          return SizedBox.expand(
              child: Container(
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 15, left: 8),
                  child: Container(
                    color: Colors.white,
                    width: double.infinity,
                    child: Container(
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: [
                              Align(
                                alignment: Alignment.bottomLeft,
                                child: GestureDetector(
                                  child: Icon(Icons.arrow_back_ios),
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomLeft,
                                child: Material(
                                  child: Text(
                                    'Choose Address',
                                    style: TextStyle(
                                      color: Constants.greyColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Divider(
                            color: Constants.lightgreyColor,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Material(
                    child: Container(
                      color: Colors.white,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            addressTypeID == 21
                                ? "Select Shipping Address"
                                : "Select Billing Address",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Constants.blackColor,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Container(
                              child: RaisedButton(
                                color: Colors.yellow[50],
                                child: Text(
                                  " + Add New Address",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Constants.blackColor,
                                  ),
                                  overflow: TextOverflow.clip,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(3),
                                  side: BorderSide(
                                    width: 1,
                                    color: Constants.appColor,
                                  ),
                                ),
                                textColor: Constants.appColor,
                                onPressed: () {
                                  setState(() {
                                    _stateError = null;
                                  });
                                  addNewAddress(context, addressTypeID, 0,
                                      billingAddreses[0]);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                addressList(addreses),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Material(
                        child: GestureDetector(
                          child: Container(
                              decoration: BoxDecoration(
                                  color: Constants.appColor,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5))),
                              // height: 50,
                              // color: Constants.appColor,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  " Continue ",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 15.0),
                                ),
                              )),
                          onTap: () {},
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ));
        });
  }

  getAddressDetails(String userID) async {
    print(" selected Userid -- > " + userID);
    String finalUrl = ApiService.baseUrl + "Order/GetAddressesByVendorId";

    Map<String, dynamic> data = {
      "VendorId": userID,
      "Aproved": null,
      "ISActive": true
    };

    await api.postAPICall(finalUrl, data).then((response) {
      print(" GetAddressByUserID -- > " + response.toString());
      setState(() {
        shippingAddreses = List<ListResultAddress>();
        billingAddreses = List<ListResultAddress>();
        firstLoading = false;
        vendorAddressReponse = VendorAddressReponse.fromJson(response);
        print(" VenderAddressResponse -- > " +
            vendorAddressReponse.toJson().toString());
        if (vendorAddressReponse.listResult != null) {
          // vendorAddressReponse.listResult[0].isAddressSelected = true;
          setState(() {
            for (int i = 0; i < vendorAddressReponse.listResult.length; i++) {
              if (vendorAddressReponse.listResult[i].addressTypeId == 21) {
                shippingAddreses.add(vendorAddressReponse.listResult[i]);
                if (shippingAddreses.length > 0) {
                  setState(() {
                    shippingaddressID = shippingAddreses[0].addressTypeId;
                  });
                }
              } else {
                billingAddreses.add(vendorAddressReponse.listResult[i]);

                if (billingAddreses.length > 0) {
                  setState(() {
                    billingaddressID = billingAddreses[0].addressTypeId;
                  });
                }
              }
            }

            // print(shippingAddreses[0].addressName);
          });
        } else {
          setState(() {});
        }
      });
      _getstates();
    });
  }

  void _getstates() {
    ApiService.getStates().then((res) {
      // print(res.toString());
      setState(() {
        states = statesResModelFromJson(res.body).listResult;
        if (vendorinfo != null) {
          // selectedState = null;
          selectedState = states.firstWhere(
              (x) => x.id == vendorAddressReponse.listResult[0].stateid);
          print('Selected State :' + selectedState.name);
        }
        // if (this.widget.isfromEdit == true) {
        //   selectedState =
        //       states.firstWhere((x) => x.id == widget.address.stateid);
        // }
        print("states comming => " + states.length.toString());
      });
    });
  }
}

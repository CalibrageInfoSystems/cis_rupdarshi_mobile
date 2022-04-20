import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rupdarshi_cis/Model/Requests/PlaceOerderRequest.dart';
import 'package:rupdarshi_cis/Model/StatesResModel.dart';
import 'package:rupdarshi_cis/Model/VendorAddressReponse.dart';
import 'package:rupdarshi_cis/Service/ApiService.dart';
import 'package:rupdarshi_cis/common/Constants.dart';
import 'package:rupdarshi_cis/common/SessionManager.dart';

import 'package:progress_dialog/progress_dialog.dart';
import 'package:rupdarshi_cis/Model/VendorProfile.dart' as vendor;
import 'package:rupdarshi_cis/screens/Address.dart';
import 'package:rupdarshi_cis/common/LocalDb.dart';
import 'AddressDetails.dart';

final GlobalKey<State> _keyLoader = new GlobalKey<State>();
ProgressDialog pr;

extension CapExtension1 on String {
  String get inCaps5 => '${this[0].toUpperCase()}${this.substring(1)}';
  String get allInCaps5 => this.toUpperCase();
}

class ChangeAddress extends StatefulWidget {
  final List<ListResultAddress> addressess;
  final int addressTypeId;
  final bool isfromCart;
  final List<Product> products;
  final bool isFromItemDetails;
  final Function refresh;
  final bool isFromAddress;
  const ChangeAddress(
      {this.addressess,
      this.addressTypeId,
      this.isfromCart,
      this.products,
      this.isFromItemDetails,
      this.refresh,
      this.isFromAddress});
  @override
  _ChangeAddressState createState() => _ChangeAddressState();
}

class _ChangeAddressState extends State<ChangeAddress> {
  LocalData localData = new LocalData();
  int billingSelectedIndex = 0;
  int shippingSelectedIndex = 0;
  int _radioValue1 = -1;
  int _radioValue2 = -1;
  int shippingOldIndex = 0;
  int billingOldIndex = 0;
  List<ListResultAddress> shippingAddreses;
  List<ListResultAddress> billingAddreses;
  int shippingaddressID = 0;
  int billingaddressID = 0;
  String patttern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
  String pinPatttern = r'(^[1-9]{1}[0-9]{2}\s{0,1}[0-9]{3}$)';

  bool firstLoading = true;

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
  String errorMsg = "";
  vendor.VendorProfile vendorinfo;
  int userid;
  List<ListResult> states = [];
  ListResult selectedState;
  VendorAddressReponse vendorAddressReponse;
  int stateID = 0;
  bool islogin = false;
  ProgressDialog progressHud;
  ScrollController controller;
  ApiService apiConnector;

  refresh() async {
    setState(() {
      print('Refresh ChangeAddress');
      vendorAddressReponse = new VendorAddressReponse();
      shippingAddreses = List<ListResultAddress>();
      billingAddreses = List<ListResultAddress>();
      SessionManager().getUserId().then((value) {
        userid = value;
        print('User ID from Profile :' + userid.toString());

        // _getProfileData();
        getAddressDetails(userid.toString());
      });
    });
  }

  @override
  void initState() {
    super.initState();
    billingSelectedIndex = 0;
    shippingSelectedIndex = 0;
    firstLoading = true;
    shippingOldIndex = 0;
    billingOldIndex = 0;
    _radioValue1 = 0;
    _radioValue2 = 0;

    //  _getstates();
    vendorAddressReponse = new VendorAddressReponse();
    shippingAddreses = List<ListResultAddress>();
    billingAddreses = List<ListResultAddress>();
    apiConnector = new ApiService();
    SessionManager().getUserId().then((value) {
      userid = value;
      print('User ID from Profile :' + userid.toString());

      // _getProfileData();
      getAddressDetails(userid.toString());
    });

    //  selectedState = null;

    //  print('==============' + widget.address.toJson().toString());
    print("**********************");
    print(this.widget.isfromCart);
    print(this.widget.isFromItemDetails);
    print("**********************");
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double itemHeight = (size.height) / 4;
    final double itemWidth = size.width / 2;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Choose Address',
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
        body: SingleChildScrollView(
          child: Column(children: <Widget>[
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 10.0),
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
                      print(this.widget.isfromCart);
                      print(this.widget.isFromItemDetails);

                      bool fmID;
                      bool fmCat;

                      if (this.widget.isfromCart == true) {
                        setState(() {
                          fmID = false;
                          fmCat = true;
                        });
                      }
                      if (this.widget.isFromItemDetails == true) {
                        setState(() {
                          fmID = true;
                          fmCat = false;
                        });
                      }

                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => AddressDetails(
                                isfromEdit: false,
                                isFromCart: fmCat,
                                addresstypeID: widget.addressTypeId,
                                address: null,
                                isFromItemDetails: fmID,
                                products: this.widget.products,
                                refresh: refresh,
                              )));
                    },
                  ),
                ),
              ),
            ),
            this.widget.addressTypeId == 20
                ? billingAddressList(this.widget.addressess)
                : shippingAddressList(this.widget.addressess),
          ]),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(0.0),
          child: Container(
            // height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey[300]),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Expanded(
                  child: Container(
                    // height: 48,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: RaisedButton(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            " Cancel",
                            style: TextStyle(
                              // fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Constants.blackColor,
                            ),
                            overflow: TextOverflow.clip,
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 2,
                            color: Constants.appColor,
                          ),
                        ),
                        textColor: Constants.appColor,
                        color: Colors.white,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Container(
                    // height: 48,
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
                            print(this.widget.isfromCart);
                            print(this.widget.isFromItemDetails);

                            bool fmID;
                            bool fmCat;

                            if (this.widget.isfromCart == true) {
                              setState(() {
                                fmID = false;
                                fmCat = true;
                              });
                            }
                            if (this.widget.isFromItemDetails == true) {
                              setState(() {
                                fmID = true;
                                fmCat = false;
                              });
                            }

                            if (widget.addressTypeId == 20) {
                              print(widget.addressTypeId);
                              localData.addIntToSF(
                                  "billingSelectedIndex", billingSelectedIndex);
                              //  widget.refresh();
                              Navigator.pop(context);
                              Navigator.of(context)
                                  .pushReplacement(MaterialPageRoute(
                                      builder: (context) => AddressScreen(
                                            isFromCart: fmCat,
                                            isFromChooseAddress: true,
                                            addressID: billingSelectedIndex,
                                            isFromBilling: true,
                                            products: this.widget.products,
                                            isFromItemDetails: fmID,
                                          )));
                              print('change Adresses ' +
                                  billingSelectedIndex.toString());
                            } else {
                              localData.addIntToSF("shippingSelectedIndex",
                                  shippingSelectedIndex);
                              //widget.refresh();
                              Navigator.pop(context);
                              // Navigator.pop(context);
                              Navigator.of(context)
                                  .pushReplacement(MaterialPageRoute(
                                      builder: (context) => AddressScreen(
                                            isFromCart: fmCat,
                                            isFromChooseAddress: true,
                                            addressID: shippingSelectedIndex,
                                            isFromShipping: true,
                                            products: this.widget.products,
                                            isFromItemDetails: fmID,
                                          )));
                            }
                          }),
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

  Widget billingAddressList(List<ListResultAddress> addreses) {
    var size = MediaQuery.of(context).size;
    final double itemHeight = (size.height);
    return Container(
      color: Colors.white,
      height: itemHeight - 200,
      child: ListView.builder(
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          itemCount: billingAddreses == null ? 0 : billingAddreses.length,
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
                                        value: index,
                                        groupValue: _radioValue1,
                                        onChanged: (value) {
                                          setState(() {
                                            print('Radio $value');
                                            print(billingOldIndex);
                                            billingSelectedIndex = value;
                                            _handleRadioValueChange1(value);
                                            // shippingaddressID =shippingAddreses[index].id;

                                            print(billingAddreses.length);

                                            if (billingOldIndex != index) {
                                              print("wwwwwwwwww " +
                                                  billingSelectedIndex
                                                      .toString());
                                              billingAddreses[billingOldIndex]
                                                  .isAddressSelected = false;
                                            }
                                            billingOldIndex = index;
                                            if (billingAddreses[index]
                                                    .isAddressSelected ==
                                                true) {
                                              billingAddreses[index]
                                                  .isAddressSelected = false;
                                            } else {
                                              print("tttttttttttttt");
                                              billingAddreses[index]
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
                                            child: billingAddreses == null
                                                ? Container()
                                                : Text(
                                                    billingAddreses[index]
                                                        .addressName
                                                        .inCaps5,
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
                                            height: 2,
                                          ),
                                          Align(
                                            alignment: Alignment.topLeft,
                                            child: billingAddreses == null
                                                ? Container()
                                                : Text(
                                                    billingAddreses[index]
                                                        .mobilenumber,
                                                    style: TextStyle(
                                                      color:
                                                          Constants.blackColor,
                                                    ),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.clip,
                                                  ),
                                          ),
                                          Align(
                                            alignment: Alignment.topLeft,
                                            child: Text(
                                              billingAddreses == null
                                                  ? ""
                                                  : billingAddreses[index]
                                                      .address1
                                                      .inCaps5,
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
                                            child: billingAddreses[index]
                                                            .address2 ==
                                                        null ||
                                                    billingAddreses[index]
                                                            .address2 ==
                                                        ""
                                                ? Container()
                                                : Text(
                                                    billingAddreses[index]
                                                        .address2
                                                        .inCaps5,
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
                                            child: billingAddreses[index]
                                                            .landmark ==
                                                        null ||
                                                    billingAddreses[index]
                                                            .landmark ==
                                                        ""
                                                ? null
                                                : Text(
                                                    billingAddreses[index]
                                                        .landmark
                                                        .inCaps5,
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
                                                  billingAddreses == null
                                                      ? ""
                                                      : billingAddreses[index]
                                                              .city
                                                              .inCaps5 +
                                                          ', ' +
                                                          billingAddreses[index]
                                                              .district,
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
                                              billingAddreses == null
                                                  ? ""
                                                  : billingAddreses[index]
                                                          .name
                                                          .inCaps5 +
                                                      ' - ' +
                                                      billingAddreses[index]
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

  Widget shippingAddressList(List<ListResultAddress> addreses) {
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
                                        value: index,
                                        groupValue: _radioValue2,
                                        onChanged: (value) {
                                          setState(() {
                                            print('Radio $value');
                                            shippingSelectedIndex = value;

                                            print(shippingOldIndex);

                                            _handleRadioValueChange2(value);
                                            // shippingaddressID =shippingAddreses[index].id;

                                            print(shippingAddreses.length);

                                            if (shippingOldIndex != index) {
                                              print("Shipping " +
                                                  shippingOldIndex.toString());
                                              shippingAddreses[shippingOldIndex]
                                                  .isAddressSelected = false;
                                            }
                                            shippingOldIndex = index;
                                            if (shippingAddreses[index]
                                                    .isAddressSelected ==
                                                true) {
                                              shippingAddreses[index]
                                                  .isAddressSelected = false;
                                            } else {
                                              print("tttttttttttttt");
                                              shippingAddreses[index]
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
                                            child: shippingAddreses == null
                                                ? Container()
                                                : Text(
                                                    shippingAddreses[index]
                                                        .addressName
                                                        .inCaps5,
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
                                            height: 2,
                                          ),
                                          Align(
                                            alignment: Alignment.topLeft,
                                            child: shippingAddreses == null
                                                ? Container()
                                                : Text(
                                                    shippingAddreses[index]
                                                        .mobilenumber,
                                                    style: TextStyle(
                                                      color:
                                                          Constants.blackColor,
                                                    ),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.clip,
                                                  ),
                                          ),
                                          Align(
                                            alignment: Alignment.topLeft,
                                            child: Text(
                                              shippingAddreses == null
                                                  ? ""
                                                  : shippingAddreses[index]
                                                      .address1
                                                      .inCaps5,
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
                                                        .inCaps5,
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
                                                        .inCaps5,
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
                                                              .inCaps5 +
                                                          ', ' +
                                                          shippingAddreses[
                                                                  index]
                                                              .district,
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
                                                          .inCaps5 +
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

  getAddressDetails(String userID) async {
    print(" selected Userid -- > " + userID);
    String finalUrl = ApiService.baseUrl + "Order/GetAddressesByVendorId";

    Map<String, dynamic> data = {
      "VendorId": userID,
      "Aproved": null,
      "ISActive": true
    };

    await apiConnector.postAPICall(finalUrl, data).then((response) {
      print(" GetAddressByUserID -- > " + response.toString());
      setState(() {
        vendorAddressReponse = VendorAddressReponse.fromJson(response);
        print(" VenderAddressResponse -- > " +
            vendorAddressReponse.toJson().toString());
        if (vendorAddressReponse.listResult != null) {
          // vendorAddressReponse.listResult[0].isAddressSelected = true;
          setState(() {
            // shippingAddreses.addAll(vendorAddressReponse.listResult
            //     .where((element) => element.addressTypeId == 21));
            // // billingAddreses = vendorAddressReponse.listResult
            // //     .where((element) => element.addressTypeId == 21);

            for (int i = 0; i < vendorAddressReponse.listResult.length; i++) {
              if (vendorAddressReponse.listResult[i].addressTypeId == 21) {
                shippingAddreses.add(vendorAddressReponse.listResult[i]);
                if (shippingAddreses.length > 0) {
                  setState(() {
                    shippingaddressID = shippingAddreses[0].id;
                  });
                }
              } else {
                billingAddreses.add(vendorAddressReponse.listResult[i]);

                if (billingAddreses.length > 0) {
                  setState(() {
                    billingaddressID = billingAddreses[0].id;
                  });
                }
              }
            }

            if (shippingaddressID == 0) {
              setState(() {
                shippingaddressID = billingaddressID;
              });
            }

            if (billingaddressID == 0) {
              setState(() {
                billingaddressID = shippingaddressID;
              });
            }

            // print(shippingAddreses[0].addressName);
          });
        } else {
          setState(() {});
        }
      });
    });
  }
}

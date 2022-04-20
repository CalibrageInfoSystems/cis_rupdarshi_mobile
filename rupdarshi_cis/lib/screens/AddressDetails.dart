import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rupdarshi_cis/Model/Requests/PlaceOerderRequest.dart';
import 'package:rupdarshi_cis/Model/StatesResModel.dart';
import 'package:rupdarshi_cis/Model/VendorAddressReponse.dart';
import 'package:rupdarshi_cis/Service/ApiService.dart';
import 'package:rupdarshi_cis/common/Constants.dart';
import 'package:rupdarshi_cis/common/SessionManager.dart';

import 'package:rupdarshi_cis/screens/ItemDetailsScreen.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:rupdarshi_cis/Model/VendorProfile.dart' as vendor;
import 'package:http/http.dart' as http;

final GlobalKey<State> _keyLoader = new GlobalKey<State>();
ProgressDialog pr;

class AddressDetails extends StatefulWidget {
  final ListResultAddress address;
  final int addresstypeID;
  final bool isfromEdit;
  final bool isFromCart;
  final List<Product> products;
  final int itemID;
  final bool isFromItemDetails;
  final Function refresh;

  const AddressDetails(
      {this.address,
      this.addresstypeID,
      this.isfromEdit,
      this.isFromCart,
      this.products,
      this.itemID,
      this.isFromItemDetails,
      this.refresh});
  @override
  _AddressDetailsState createState() => _AddressDetailsState();
}

class _AddressDetailsState extends State<AddressDetails> {
  List<ListResultAddress> shippingAddreses;
  List<ListResultAddress> billingAddreses;
  int shippingaddressID = 0;
  int billingaddressID = 0;
  String patttern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
  String pinPatttern = r'(^[1-9]{1}[0-9]{2}\s{0,1}[0-9]{3}$)';

  bool firstLoading = true;

  String _stateError;
  final formKey = GlobalKey<FormState>();
  TextEditingController nameController = new TextEditingController();
  TextEditingController mobileNoController = new TextEditingController();
  TextEditingController pincodeController = new TextEditingController();
  TextEditingController address1Controller = new TextEditingController();
  TextEditingController address2Controller = new TextEditingController();
  TextEditingController cityController = new TextEditingController();
  TextEditingController landmarkController = new TextEditingController();
  TextEditingController districController = new TextEditingController();

  _validateForm() {
    bool _isValid = formKey.currentState.validate();
    if (selectedState == null) {
      setState(() => _stateError = "State is required");
      _isValid = false;
    }
    if (_isValid) {
      //form is valid
    }
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

  @override
  void initState() {
    super.initState();
    firstLoading = true;
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
//  print('==============' + widget.address.toJson().toString());
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double itemHeight = (size.height) / 4;
    final double itemWidth = size.width / 2;

    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              'Add Address',
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
              : SingleChildScrollView(
                  // scrollDirection: Axis.vertical,
                  child: Column(children: <Widget>[
                    addNewAddress(),
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
                              if (_validateForm() != false &&
                                  formKey.currentState.validate()) {
                                if (this.widget.isfromEdit == true) {
                                  _updateCommand();
                                  print("Updating addres");
                                } else {
                                  print("new address create" +
                                      this.widget.addresstypeID.toString());
                                  print(this.widget.isFromCart);
                                  print(this.widget.isFromItemDetails);
                                  _createAddress(this.widget.addresstypeID);
                                  //                 Navigator.of(context)
                                  // .push(MaterialPageRoute(builder: (context) => AddressScreen()));
                                }
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
      ),
    );
  }

  Widget addNewAddress() {
    RegExp regExp = new RegExp(patttern);
    RegExp pinregExp = new RegExp(pinPatttern);
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
          child: Card(
            elevation: 2,
            color: Colors.white,
            child: Row(
              children: <Widget>[
                Form(
                  key: formKey,
                  child: Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                'Add address'.inCaps,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Constants.greyColor,
                                    fontSize: 18.0),
                              ),
                            ),
                          ),
                          Divider(
                            color: Colors.black,
                          ),
                          TextFormField(
                            keyboardType: TextInputType.text,
                            controller: nameController,
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderRadius: new BorderRadius.circular(8.0),
                                borderSide: BorderSide(
                                    color: Constants.blackColor, width: 1.5),
                              ),
                              labelText: 'Name*',
                              labelStyle: TextStyle(
                                color: Constants.lightgreyColor,
                                // fontWeight: FontWeight.bold
                              ),
                              border: new OutlineInputBorder(
                                borderRadius: new BorderRadius.circular(8.0),
                              ),
                            ),
                            validator: (val) => val.length < 1
                                ? 'Name is Required'
                                : val.length < 2
                                    ? 'Name is too short'
                                    : null,
                            // onSaved: (val) => _userName = val,
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          TextFormField(
                            controller: mobileNoController,
                            keyboardType: TextInputType.number,
                            maxLength: 10,
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderRadius: new BorderRadius.circular(8.0),
                                borderSide: BorderSide(
                                    color: Constants.blackColor, width: 1.5),
                              ),
                              labelText: 'Mobile Number*',
                              labelStyle: TextStyle(
                                color: Constants.lightgreyColor,
                                // fontWeight: FontWeight.bold
                              ),
                              border: new OutlineInputBorder(
                                borderRadius: new BorderRadius.circular(8.0),
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
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderRadius: new BorderRadius.circular(8.0),
                                borderSide: BorderSide(
                                    color: Constants.blackColor, width: 1.5),
                              ),
                              labelText: 'Address1*',
                              labelStyle:
                                  TextStyle(color: Constants.lightgreyColor
                                      // fontWeight: FontWeight.bold
                                      ),
                              border: new OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Constants.blackColor),
                                borderRadius: new BorderRadius.circular(8.0),
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
                                borderRadius: new BorderRadius.circular(8.0),
                                borderSide: BorderSide(
                                    color: Constants.blackColor, width: 1.5),
                              ),
                              labelText: 'Address2',
                              labelStyle:
                                  TextStyle(color: Constants.lightgreyColor
                                      // fontWeight: FontWeight.bold
                                      ),
                              border: new OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Constants.blackColor),
                                borderRadius: new BorderRadius.circular(8.0),
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
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderRadius: new BorderRadius.circular(8.0),
                                borderSide: BorderSide(
                                    color: Constants.blackColor, width: 1.5),
                              ),
                              labelText: 'Landmark',
                              labelStyle: TextStyle(
                                color: Constants.lightgreyColor,
                                // fontWeight: FontWeight.bold
                              ),
                              border: new OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Constants.blackColor, width: 1.5),
                                borderRadius: new BorderRadius.circular(8.0),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          TextFormField(
                            controller: cityController,
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderRadius: new BorderRadius.circular(8.0),
                                borderSide: BorderSide(
                                    color: Constants.blackColor, width: 1.5),
                              ),
                              labelText: 'City*',
                              labelStyle: TextStyle(
                                color: Constants.lightgreyColor,
                                // fontWeight: FontWeight.bold
                              ),
                              border: new OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Constants.blackColor),
                                borderRadius: new BorderRadius.circular(8.0),
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
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderRadius: new BorderRadius.circular(8.0),
                                borderSide: BorderSide(
                                    color: Constants.blackColor, width: 1.5),
                              ),
                              labelText: 'District',
                              labelStyle: TextStyle(
                                color: Constants.lightgreyColor,
                                // fontWeight: FontWeight.bold
                              ),
                              border: new OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Constants.blackColor),
                                borderRadius: new BorderRadius.circular(8.0),
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
                                        enabledBorder: new OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                              color: _stateError == null
                                                  ? Colors.grey
                                                  : Colors.red),
                                        ),
                                        labelText: 'State *',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: new BorderSide(
                                            color: _stateError == null
                                                ? Colors.grey
                                                : Colors.red,
                                          ),
                                        ),
                                      ),
                                      // hint: widget.isfromEdit == true
                                      //     ? Text(widget.address.name)
                                      //     : Text('State*'),
                                      value: selectedState,
                                      isDense: true,
                                      onChanged: (newValue) {
                                        setState(() {
                                          selectedState = newValue;
                                          stateID = selectedState.id;
                                          _stateError = null;
                                        });
                                      },
                                      items: states.map((value) {
                                        return DropdownMenuItem(
                                          value: value,
                                          child: new Text(value.name),
                                        );
                                      }).toList(),
                                    )),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: _stateError == null
                                  ? const EdgeInsets.only(left: 0)
                                  : const EdgeInsets.only(
                                      left: 10, top: 5, bottom: 5),
                              child: _stateError == null
                                  ? SizedBox.shrink()
                                  : this.widget.isfromEdit == true
                                      ? Text("")
                                      : Text(
                                          _stateError ?? "",
                                          style: TextStyle(
                                              color: Colors.red[700],
                                              fontSize: 13),
                                        ),
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          TextFormField(
                            controller: pincodeController,
                            keyboardType: TextInputType.text,
                            inputFormatters: <TextInputFormatter>[
                              WhitelistingTextInputFormatter.digitsOnly
                            ],
                            maxLength: 6,
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderRadius: new BorderRadius.circular(8.0),
                                borderSide: BorderSide(
                                    color: Constants.blackColor, width: 1.5),
                              ),
                              labelText: 'Pincode*',
                              labelStyle: TextStyle(
                                color: Constants.lightgreyColor,
                                // fontWeight: FontWeight.bold
                              ),
                              border: new OutlineInputBorder(
                                borderRadius: new BorderRadius.circular(8.0),
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
                ),
              ],
            ),
          ),
        ));
  }

  void _getstates() {
    ApiService.getStates().then((res) {
      // print(res.toString());
      setState(() {
        states = statesResModelFromJson(res.body).listResult;
        if (this.widget.isfromEdit == true) {
          selectedState =
              states.firstWhere((x) => x.id == widget.address.stateid);
        }
        print("states comming => " + states.length.toString());
      });
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

    await apiConnector.postAPICall(finalUrl, data).then((response) {
      print(" GetAddressByUserID -- > " + response.toString());
      setState(() {
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
            if (this.widget.isfromEdit == true) {
              setState(() {
                nameController.text = widget.address.addressName.inCaps;
                mobileNoController.text = widget.address.mobilenumber;
                address1Controller.text = widget.address.address1.toString();
                address2Controller.text = widget.address.address2 == null ||
                        widget.address.address2 == ""
                    ? ""
                    : widget.address.address2;
                landmarkController.text = widget.address.landmark == null ||
                        widget.address.landmark == ""
                    ? ""
                    : widget.address.landmark;
                cityController.text = widget.address.city.toString();
                districController.text = widget.address.district.toString();
                pincodeController.text = widget.address.pincode;
                // _stateError = null;
              });
            } else {}
          });
        } else {
          setState(() {});
        }
      });
      _getstates();
    });
  }

  void _getProfileData() async {
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
      setState(() {
        firstLoading = false;
      });
      int statusCode = value.statusCode;
      String res = value.body;
      vendorinfo = vendor.vendorProfileFromJson(res);
      print(
        'Address -----' + vendorinfo.toJson().toString(),
      );
      if (vendorAddressReponse.listResult == null) {
        setState(() {
          nameController.text = vendorinfo.listResult[0].firstName +
              " " +
              vendorinfo.listResult[0].middleName +
              " " +
              vendorinfo.listResult[0].lastName;
          mobileNoController.text = vendorinfo.listResult[0].mobileNumber;
          pincodeController.text = vendorinfo.listResult[0].pincode;
          address1Controller.text = vendorinfo.listResult[0].address1;
          address2Controller.text = vendorinfo.listResult[0].address2;
          cityController.text = vendorinfo.listResult[0].city;
          districController.text = vendorinfo.listResult[0].district;
          landmarkController.text = vendorinfo.listResult[0].landmark;
          stateID = vendorinfo.listResult[0].stateId;
        });
      } else {
        return null;
      }

      print('Mobile from profile' + mobileNoController.text);
      _getstates();
    });
  }

  void _createAddress(int addressID) async {
    var baseurl = ApiService.baseUrl;
    var url = baseurl + ApiService.addUpdateAddress;

    List<Map<String, dynamic>> data = [
      {
        "Id": 0,
        "VendorId": userid,
        "StateId": stateID,
        "District": districController.text,
        "City": cityController.text,
        "Landmark":
            landmarkController.text == "" ? null : landmarkController.text,
        "Address1": address1Controller.text,
        "Address2":
            address2Controller.text == "" ? null : address2Controller.text,
        "Pincode": pincodeController.text,
        "MobileNumber": mobileNoController.text,
        "IsActive": true,
        "Name": nameController.text,
        "AddressTypeId": this.widget.addresstypeID,
        "Aproved": 1
      }
    ];

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
          if (this.widget.isFromCart == true) {
            print('is from cart');
            print('Refresh Change Address');
            widget.refresh(); // just refresh() if its statelesswidget
            Navigator.pop(context);
          } else if (this.widget.isFromItemDetails == true) {
            print('is from Item details');
            print('Refresh Change Address');
            widget.refresh(); // just refresh() if its statelesswidget
            Navigator.pop(context);
          } else {
            print('Refresh My Address');
            widget.refresh(); // just refresh() if its statelesswidget
            Navigator.pop(context);
          }

          apiConnector.globalToast(data['EndUserMessage']);
        } else {
          setState(() {
            // _state = 1;
          });
          final snackbar = SnackBar(
            content: Text(data['EndUserMessage']),
          );
        }
      } else {
        setState(() {
          // _state = 1;
        });
        final snackbar = SnackBar(
          content: Text('Something went wrong ..'),
        );
      }
    });
  }

  void _updateCommand() async {
    var baseurl = ApiService.baseUrl;
    var url = baseurl + ApiService.addUpdateAddress;

    List<Map<String, Object>> data = [
      {
        "Id": this.widget.address.id,
        "VendorId": userid,
        "StateId": selectedState.id,
        "District": districController.text,
        "City": cityController.text,
        "Landmark":
            landmarkController.text == "" ? null : landmarkController.text,
        "Address1": address1Controller.text,
        "Address2":
            address2Controller.text == "" ? null : address2Controller.text,
        "Pincode": pincodeController.text,
        "MobileNumber": mobileNoController.text,
        "IsActive": true,
        "Name": nameController.text,
        "AddressTypeId": this.widget.addresstypeID,
        "Aproved": 1
      }
    ];

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
          apiConnector.globalToast(data['EndUserMessage']);
          widget.refresh(); // just refresh() if its statelesswidget
          Navigator.pop(context);
          //  Navigator.of(context, rootNavigator: true).pop(context);
          // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MyAddress(
          //                                                                         )));

        } else {
          apiConnector.globalToast(data['EndUserMessage']);
        }
      } else {
        apiConnector.globalToast('Something went wrong ..');
      }
    });
  }
}

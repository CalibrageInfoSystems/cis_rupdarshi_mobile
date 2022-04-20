import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rupdarshi_cis/Model/GetCartResponse.dart';
import 'package:rupdarshi_cis/Model/PaymentModeResponse.dart';
import 'package:rupdarshi_cis/Model/StatesResModel.dart';
import 'package:rupdarshi_cis/Model/VendorAddressReponse.dart';
import 'package:rupdarshi_cis/Service/ApiService.dart';
import 'package:rupdarshi_cis/common/Constants.dart';
import 'package:rupdarshi_cis/common/LocalDb.dart';
import 'package:rupdarshi_cis/common/SessionManager.dart';
import 'package:rupdarshi_cis/screens/CartScreen.dart';
import 'package:rupdarshi_cis/screens/ChangeAddress.dart';
import 'package:rupdarshi_cis/screens/ItemDetailsScreen.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:rupdarshi_cis/Model/VendorProfile.dart' as vendor;
import 'package:http/http.dart' as http;
import 'package:rupdarshi_cis/Model/Requests/PlaceOerderRequest.dart';
import 'package:rupdarshi_cis/screens/Thankyou.dart';

extension CapExtension1 on String {
  String get inCaps1 => '${this[0].toUpperCase()}${this.substring(1)}';
  String get allInCaps1 => this.toUpperCase();
}

final GlobalKey<State> _keyLoader = new GlobalKey<State>();
ProgressDialog pr;

class AddressScreen extends StatefulWidget {
  final bool isFromCart;
  final List<Product> products;
  final int itemID;
  final bool isFromChooseAddress;
  final int addressID;
  final bool isFromShipping;
  final bool isFromBilling;
  final bool isFromItemDetails;
  final Function refresh;

  AddressScreen(
      {this.isFromCart,
      this.products,
      this.itemID,
      this.isFromChooseAddress,
      this.addressID,
      this.isFromShipping,
      this.isFromBilling,
      this.isFromItemDetails,
      this.refresh});
  @override
  _AddressScreenState createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  bool shippingVisible = true;
  bool checkBoxValue = false;
  List<Product> cartProducts;
  PlaceOerderRequestModel placeOerderRequestModel;
  final formKey = GlobalKey<FormState>();
  List<ListResult> states = [];
  ListResult selectedState;
  int stateID = 0;
  int logisticID = 0;
  int totalQTY = 0;
  double paymentDiscount = 0.0;
  int paymentID = 0;
  PaymentModeResponse paymentModeResponse;
  List<PaymentListResult> paymentListResult;
  double dicountvalue = 0.0;
  double totalItemDiscount = 0.0;

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
    if (selectedState == null) {
      setState(() => _stateError = "State is required");
      _isValid = false;
    }
    if (_isValid) {
      //form is valid
    }
  }

  bool isEditVisible = false;
  int _radioValue1 = -1;
  int _radioValue2 = -1;
  bool isAddressText = false;
  int shippingOldIndex = 0;
  int oldIndex = 0;
  int billingOldIndex = 0;
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
  String userIDString;
  var totalPrice = 0.0;
  var totaldiscountPrice = 0.0;
  String errorMessage = "";
  var gstPrice = 0.0;
  bool islogin = false;
  bool firstLoading = true;
  bool isAddressVisible = true;
  ScrollController controller;
  ApiService api;
  GetCartResponse getCartResponse;
  VendorAddressReponse vendorAddressReponse;
  int paymentType = 0;
  String paymentTypeStr = "";
  int statusTypeID = 0;
  LocalData localData = new LocalData();
  int billingSelectedIndex = 0;
  int shippingSelectedIndex = 0;
  int discountPercentage = 0;

  // shippingRefresh() async {
  //   setState(() {
  //     isrefreshes = true;
  //     // getAddressDetails(userid.toString());
  //     print('Refresh Shipping Address');
  //     localData.getIntToSF("shippingSelectedIndex").then((value) {
  //       setState(() {
  //         shippingSelectedIndex = value;
  //         print("shippingSelectedIndex " + value.toString());
  //       });
  //     });
  //   });
  // }

  refresh() async {
    setState(() {
      // isrefreshes = true;
      // // getAddressDetails(userid.toString());
      // print('Refresh Address');
      // localData.getIntToSF("billingSelectedIndex").then((value) {
      //   setState(() {
      //     billingSelectedIndex = value;
      //     print("billingSelectedIndex " + value.toString());
      //   });
      // });
    });
  }

  @override
  void initState() {
    super.initState();
    billingSelectedIndex = 0;
    shippingSelectedIndex = 0;
    shippingVisible = true;
    checkBoxValue = false;
    firstLoading = true;
    _radioValue1 = 1;
    shippingOldIndex = 0;
    oldIndex = 0;
    paymentType = 0;
    paymentTypeStr = "";
    statusTypeID = 0;
    // isAddressVisible = false;
    isEditVisible = false;
    api = new ApiService();
    cartProducts = new List<Product>();
    placeOerderRequestModel = new PlaceOerderRequestModel();
    getCartResponse = new GetCartResponse();
    vendorAddressReponse = new VendorAddressReponse();
    shippingAddreses = List<ListResultAddress>();
    billingAddreses = List<ListResultAddress>();
    paymentModeResponse = new PaymentModeResponse();

    // localData.getIntToSF(LocalData.PAYMENTTYPEID).then((paymentid) {
    //   setState(() {
    //     paymentID = paymentid;
    //     print('object payyyyyyyyyment id' + paymentID.toString());
    //   });
    // });

    localData.getStringValueSF(LocalData.USERIDSRING).then((value) {
      setState(() {
        userIDString = value;
        print('User ID String  :' + userIDString.toString());
      });
    });

    localData.getIntToSF(LocalData.STATUSTYPEID).then((value) {
      setState(() {
        statusTypeID = value;
      });
    });
    localData.getIntToSF(LocalData.LOGISTICID).then((value) {
      setState(() {
        logisticID = value;
      });
    });

    localData.getIntToSF("billingSelectedIndex").then((value) {
      setState(() {
        if (widget.isFromChooseAddress == true) {
          billingSelectedIndex = value;
          print("billingSelectedIndex " + value.toString());
        } else if (widget.isFromCart == true) {
          billingSelectedIndex = 0;
          print(
              "billingSelectedIndex value " + billingSelectedIndex.toString());
        }
      });
    });

    localData.getIntToSF("shippingSelectedIndex").then((value) {
      setState(() {
        if (widget.isFromChooseAddress == true) {
          shippingSelectedIndex = value;
          print("shippingSelectedIndex " + value.toString());
        } else if (widget.isFromCart == true) {
          shippingSelectedIndex = 0;
          localData.addIntToSF("shippingSelectedIndex", shippingSelectedIndex);
          print("shippingSelectedIndex value " +
              shippingSelectedIndex.toString());
        }
      });
    });

    // localData.getIntToSF(LocalData.PAYMENTTYPEID).then((value) {
    //   setState(() {
    //     paymentType = value;
    //     print("paymentType " + paymentType.toString());
    //   });
    // });
    // localData.getStringValueSF(LocalData.PAYMENTTYPE).then((value) {
    //   setState(() {
    //     paymentTypeStr = value;
    //     print("paymentTypeStr " + paymentTypeStr.toString());
    //   });
    // });
    print('User ID Int  :' + userid.toString());
    SessionManager().getUserId().then((value) {
      userid = value;
      print('User ID from Profile :' + userid.toString());
      print('Came from Item :');
      print(this.widget.isFromCart);
      print(this.widget.isFromItemDetails);
      _getProfileData(userid.toString());

      if (this.widget.isFromCart == true) {
        // getCartDetails(userid.toString());
      } else {
        print("Came from Item details");
        int totalQtyIndex = 0;
        double aaa = 0.0;
        for (int i = 0; i < this.widget.products.length; i++) {
          double item = this.widget.products[i].price.toDouble() *
              this.widget.products[i].quantity;
          totalQtyIndex += this.widget.products[i].quantity;
          double disc = (((this.widget.products[i].price.toDouble()) / 100.00) *
                  this.widget.products[i].discount.toDouble()) *
              this.widget.products[i].quantity.toDouble();

          totalPrice += item;
          //  totalItemDiscount += disc;
          totalQTY = totalQtyIndex;

          aaa = (((this.widget.products[i].price.toDouble() - (dicountvalue)) /
                      100.00) *
                  this.widget.products[i].gst.toDouble()) *
              this.widget.products[i].quantity.toDouble();

          print('g s t  g s t' + aaa.toString());
        }
        if (this.widget.isFromItemDetails != true) {
          setState(() {
            gstPrice = aaa;
          });
        }

        firstLoading = false;
        // getCartDetails(userid.toString());
      }
      print("totalQTY - > " + totalQTY.toString());
      print("TotalPrice - > " + totalPrice.toString());
      print("totalItemDiscount - > " + totalItemDiscount.toString());
      getAddressDetails(userid.toString());
      _getstates();
      //  getCartDetails(userid.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double itemHeight = (size.height) / 3.1;
    final double bottomitemHeight = (size.height) / 2.8;
    final double itemWidth = size.width / 2;

    return WillPopScope(
      onWillPop: () {
        backnavigation();
      },
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
          //resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: Text(
              'Address',
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
                // Navigator.of(context).pop(true);
                if (this.widget.isFromCart == true) {
                  //      print('Cart screen');
                  // this.widget.refresh(); // just refresh() if its statelesswidget
                  //  Navigator.pop(context);
                  Navigator.of(context).pop(true);
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              CartScreen(userID: userid.toString())));
                } else if (this.widget.isFromItemDetails == true) {
                  localData.getIntToSF("itemID").then((value) {
                    Navigator.of(context).pop(true);
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ItemDetailsScreen(itemID: value.toString())));
                  });
                } else {
                  Navigator.pop(context);
                }
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
                  child: vendorAddressReponse.listResult == null
                      ? Container(
                          child: Column(
                            children: [
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(),
                                      Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Container(),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      : Column(children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(),
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Container(),
                              ),
                            ],
                          ),
                          Container(
                              child: Column(
                            children: [
                              billingAddreses.length == 0 ||
                                      shippingAddreses.length == 0
                                  ? Container()
                                  : Container(
                                      child: new Card(
                                        elevation: 2,
                                        color: Colors.white,
                                        child: Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
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
                                                                children: <
                                                                    Widget>[
                                                                  Align(
                                                                    alignment:
                                                                        Alignment
                                                                            .topLeft,
                                                                    child: billingAddreses.length ==
                                                                            0
                                                                        ? Container()
                                                                        : Text(
                                                                            "Billing Address",
                                                                            style: TextStyle(
                                                                                fontWeight: FontWeight.bold,
                                                                                color: Constants.greyColor,
                                                                                fontSize: 14.0),
                                                                            maxLines:
                                                                                2,
                                                                            overflow:
                                                                                TextOverflow.clip,
                                                                          ),
                                                                  ),
                                                                  GestureDetector(
                                                                    child: Text(
                                                                      "Change ",
                                                                      style:
                                                                          TextStyle(
                                                                        // fontSize:
                                                                        //     16,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color: Constants
                                                                            .appColor,
                                                                      ),
                                                                    ),
                                                                    onTap: () {
                                                                      print(this
                                                                          .widget
                                                                          .isFromCart);
                                                                      print(this
                                                                          .widget
                                                                          .isFromItemDetails);
                                                                      Navigator.of(context).push(MaterialPageRoute(
                                                                          builder: (context) => ChangeAddress(
                                                                                isfromCart: this.widget.isFromCart,
                                                                                addressTypeId: billingAddreses[0].addressTypeId,
                                                                                products: this.widget.products,
                                                                                isFromItemDetails: this.widget.isFromItemDetails,
                                                                              )));
                                                                    },
                                                                  ),
                                                                ],
                                                              ),
                                                              SizedBox(
                                                                height: 10,
                                                              ),
                                                              Align(
                                                                alignment:
                                                                    Alignment
                                                                        .topLeft,
                                                                child: billingAddreses
                                                                            .length ==
                                                                        0
                                                                    ? Container()
                                                                    : Text(
                                                                        widget.isFromChooseAddress == true &&
                                                                                widget.isFromBilling == true
                                                                            ? billingAddreses[billingSelectedIndex].addressName.inCaps1
                                                                            : billingAddreses[billingSelectedIndex].addressName.inCaps1,
                                                                        style:
                                                                            TextStyle(
                                                                          // fontWeight: FontWeight.w600,
                                                                          color:
                                                                              Constants.semiboldColor,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          // fontSize: 12.0
                                                                        ),
                                                                        maxLines:
                                                                            2,
                                                                        overflow:
                                                                            TextOverflow.clip,
                                                                      ),
                                                              ),
                                                              SizedBox(
                                                                height: 2,
                                                              ),
                                                              Align(
                                                                alignment:
                                                                    Alignment
                                                                        .topLeft,
                                                                child: billingAddreses
                                                                            .length ==
                                                                        0
                                                                    ? Container()
                                                                    : Text(
                                                                        widget.isFromChooseAddress == true &&
                                                                                widget.isFromBilling == true
                                                                            ? billingAddreses[billingSelectedIndex].mobilenumber
                                                                            : billingAddreses[billingSelectedIndex].mobilenumber,
                                                                        style:
                                                                            TextStyle(
                                                                          // fontWeight: FontWeight.w600,
                                                                          color:
                                                                              Constants.semiboldColor,
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          // fontSize: 12.0
                                                                        ),
                                                                        maxLines:
                                                                            2,
                                                                        overflow:
                                                                            TextOverflow.clip,
                                                                      ),
                                                              ),
                                                              // SizedBox(
                                                              //   height: 5,
                                                              // ),
                                                              Align(
                                                                alignment:
                                                                    Alignment
                                                                        .topLeft,
                                                                child: billingAddreses
                                                                            .length ==
                                                                        0
                                                                    ? Container()
                                                                    : Text(
                                                                        widget.isFromChooseAddress == true &&
                                                                                widget.isFromBilling == true
                                                                            ? billingAddreses[billingSelectedIndex].address1.inCaps1
                                                                            : billingAddreses[billingSelectedIndex].address1.inCaps1,
                                                                        style:
                                                                            TextStyle(
                                                                          // fontWeight: FontWeight.w600,
                                                                          color:
                                                                              Constants.semiboldColor,
                                                                          // fontSize: 12.0
                                                                        ),
                                                                        maxLines:
                                                                            2,
                                                                        overflow:
                                                                            TextOverflow.clip,
                                                                      ),
                                                              ),
                                                              Align(
                                                                alignment:
                                                                    Alignment
                                                                        .topLeft,
                                                                child: billingAddreses
                                                                            .length <
                                                                        1
                                                                    ? Container()
                                                                    : billingAddreses[billingSelectedIndex].address2 ==
                                                                                "" ||
                                                                            billingAddreses[billingSelectedIndex].address2 ==
                                                                                null
                                                                        ? Container()
                                                                        : Text(
                                                                            // billingAddreses.length == null || billingAddreses.length < 0  || billingAddreses[0].address2 == null || billingAddreses[0].address2 == ""
                                                                            //      || billingAddreses == null  ? ""  :
                                                                            widget.isFromChooseAddress == true && widget.isFromBilling == true
                                                                                ? billingAddreses[billingSelectedIndex].address2 == null || billingAddreses[billingSelectedIndex].address2 == ""
                                                                                    ? ""
                                                                                    : billingAddreses[billingSelectedIndex].address2.inCaps1
                                                                                : billingAddreses[billingSelectedIndex].address2.inCaps1,
                                                                            style:
                                                                                TextStyle(
                                                                              // fontWeight: FontWeight.w600,
                                                                              color: Constants.semiboldColor,
                                                                              // fontSize: 12.0
                                                                            ),
                                                                            maxLines:
                                                                                2,
                                                                            overflow:
                                                                                TextOverflow.clip,
                                                                          ),
                                                              ),
                                                              Align(
                                                                alignment:
                                                                    Alignment
                                                                        .topLeft,
                                                                child: billingAddreses
                                                                            .length ==
                                                                        0
                                                                    ? Container()
                                                                    : billingAddreses[billingSelectedIndex].landmark == "" ||
                                                                            billingAddreses[billingSelectedIndex].landmark ==
                                                                                null ||
                                                                            billingAddreses.length ==
                                                                                null ||
                                                                            billingAddreses.length <
                                                                                0
                                                                        ? Container()
                                                                        : Text(
                                                                            billingAddreses.length == null || billingAddreses[billingSelectedIndex].landmark == null || billingAddreses[billingSelectedIndex].landmark == ""
                                                                                // || billingAddreses[widget.addressID]
                                                                                //   .landmark == null || billingAddreses[widget.addressID]
                                                                                //   .landmark == ""
                                                                                ? ""
                                                                                : widget.isFromChooseAddress == true && widget.isFromBilling == true
                                                                                    ? billingAddreses[billingSelectedIndex].landmark == null || billingAddreses[billingSelectedIndex].landmark == ""
                                                                                        ? ""
                                                                                        : billingAddreses[billingSelectedIndex].landmark.inCaps1
                                                                                    : billingAddreses[billingSelectedIndex].landmark.inCaps1,
                                                                            style:
                                                                                TextStyle(
                                                                              color: Constants.semiboldColor,
                                                                            ),
                                                                            maxLines:
                                                                                2,
                                                                            overflow:
                                                                                TextOverflow.clip,
                                                                          ),
                                                              ),
                                                              Align(
                                                                alignment:
                                                                    Alignment
                                                                        .topLeft,
                                                                child: Row(
                                                                  children: [
                                                                    billingAddreses.length ==
                                                                            0
                                                                        ? Container()
                                                                        : Text(
                                                                            widget.isFromChooseAddress == true && widget.isFromBilling == true
                                                                                ? billingAddreses[billingSelectedIndex].city.inCaps1
                                                                                : billingAddreses[billingSelectedIndex].city.inCaps1 + ", " + billingAddreses[billingSelectedIndex].district,
                                                                            style:
                                                                                TextStyle(
                                                                              // fontWeight: FontWeight.w600,
                                                                              color: Constants.semiboldColor,
                                                                              // fontSize: 12.0
                                                                            ),
                                                                            maxLines:
                                                                                2,
                                                                            overflow:
                                                                                TextOverflow.clip,
                                                                          ),
                                                                  ],
                                                                ),
                                                              ),
                                                              Align(
                                                                alignment:
                                                                    Alignment
                                                                        .topLeft,
                                                                child: billingAddreses
                                                                            .length ==
                                                                        0
                                                                    ? Container()
                                                                    : Text(
                                                                        widget.isFromChooseAddress == true && widget.isFromBilling == true
                                                                            ? billingAddreses[billingSelectedIndex]
                                                                                .name
                                                                                .inCaps1
                                                                            : billingAddreses[billingSelectedIndex].name.inCaps1 +
                                                                                ' - ' +
                                                                                billingAddreses[billingSelectedIndex].pincode,
                                                                        style:
                                                                            TextStyle(
                                                                          // fontWeight: FontWeight.w600,
                                                                          color:
                                                                              Constants.semiboldColor,
                                                                          // fontSize: 13.0
                                                                        ),
                                                                        maxLines:
                                                                            2,
                                                                        overflow:
                                                                            TextOverflow.clip,
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
                                              ? shippingVisible = false
                                              : shippingVisible = true;
                                        });
                                      });
                                    },
                                  ),
                                  Text(
                                      "Is Shipping address is same as Billing address"),
                                ],
                              ),
                              Visibility(
                                visible: shippingVisible,
                                child: shippingAddreses.length == 0
                                    ? Container()
                                    : Container(
                                        child: new Card(
                                          elevation: 2,
                                          color: Colors.white,
                                          child: Row(
                                            children: <Widget>[
                                              Expanded(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
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
                                                                  children: <
                                                                      Widget>[
                                                                    Align(
                                                                      alignment:
                                                                          Alignment
                                                                              .topLeft,
                                                                      child: shippingAddreses.length ==
                                                                              0
                                                                          ? Container()
                                                                          : Text(
                                                                              "Shipping Address",
                                                                              style: TextStyle(fontWeight: FontWeight.bold, color: Constants.greyColor, fontSize: 14.0),
                                                                              maxLines: 2,
                                                                              overflow: TextOverflow.clip,
                                                                            ),
                                                                    ),
                                                                    GestureDetector(
                                                                      child:
                                                                          Text(
                                                                        "Change ",
                                                                        style:
                                                                            TextStyle(
                                                                          // fontSize:
                                                                          //     16,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          color:
                                                                              Constants.appColor,
                                                                        ),
                                                                      ),
                                                                      onTap:
                                                                          () {
                                                                        print(shippingAddreses[0]
                                                                            .addressTypeId);
                                                                        print(this
                                                                            .widget
                                                                            .isFromCart);
                                                                        print(this
                                                                            .widget
                                                                            .isFromItemDetails);
                                                                        Navigator.of(context).push(MaterialPageRoute(
                                                                            builder: (context) => ChangeAddress(
                                                                                  addressTypeId: shippingAddreses[0].addressTypeId,
                                                                                  products: this.widget.products,
                                                                                  isFromItemDetails: this.widget.isFromItemDetails,
                                                                                  isfromCart: this.widget.isFromCart,
                                                                                )));
                                                                      },
                                                                    ),
                                                                  ],
                                                                ),
                                                                SizedBox(
                                                                  height: 10,
                                                                ),
                                                                Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .topLeft,
                                                                  child: shippingAddreses.length ==
                                                                              0 ||
                                                                          shippingAddreses ==
                                                                              null
                                                                      ? Container()
                                                                      : Text(
                                                                          shippingAddreses[shippingSelectedIndex].addressName == null || shippingAddreses[shippingSelectedIndex].addressName == ""
                                                                              ? ""
                                                                              : widget.isFromChooseAddress == true && widget.isFromShipping == true
                                                                                  ? shippingAddreses[shippingSelectedIndex].addressName.inCaps1
                                                                                  : shippingAddreses[shippingSelectedIndex].addressName.inCaps1,
                                                                          style:
                                                                              TextStyle(
                                                                            // fontWeight: FontWeight.w600,
                                                                            color:
                                                                                Constants.semiboldColor,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            // fontSize: 12.0
                                                                          ),
                                                                          maxLines:
                                                                              2,
                                                                          overflow:
                                                                              TextOverflow.clip,
                                                                        ),
                                                                ),
                                                                SizedBox(
                                                                  height: 2,
                                                                ),
                                                                Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .topLeft,
                                                                  child: shippingAddreses.length ==
                                                                              0 ||
                                                                          shippingAddreses ==
                                                                              null
                                                                      ? Container()
                                                                      : Text(
                                                                          shippingAddreses[shippingSelectedIndex].mobilenumber == null || shippingAddreses[shippingSelectedIndex].mobilenumber == ""
                                                                              ? ""
                                                                              : widget.isFromChooseAddress == true && widget.isFromShipping == true
                                                                                  ? shippingAddreses[shippingSelectedIndex].mobilenumber
                                                                                  : shippingAddreses[shippingSelectedIndex].mobilenumber,
                                                                          style:
                                                                              TextStyle(
                                                                            // fontWeight: FontWeight.w600,
                                                                            color:
                                                                                Constants.semiboldColor,
                                                                            // fontWeight: FontWeight.w500,
                                                                            // fontSize: 12.0
                                                                          ),
                                                                          maxLines:
                                                                              2,
                                                                          overflow:
                                                                              TextOverflow.clip,
                                                                        ),
                                                                ),
                                                                Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .topLeft,
                                                                  child: shippingAddreses
                                                                              .length ==
                                                                          0
                                                                      ? Container()
                                                                      : Text(
                                                                          widget.isFromChooseAddress == true && widget.isFromShipping == true
                                                                              ? shippingAddreses[shippingSelectedIndex].address1.inCaps1
                                                                              : shippingAddreses[shippingSelectedIndex].address1.inCaps1,
                                                                          style:
                                                                              TextStyle(
                                                                            // fontWeight: FontWeight.w600,
                                                                            color:
                                                                                Constants.semiboldColor,
                                                                            // fontSize: 12.0
                                                                          ),
                                                                          maxLines:
                                                                              2,
                                                                          overflow:
                                                                              TextOverflow.clip,
                                                                        ),
                                                                ),
                                                                Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .topLeft,
                                                                  child: shippingAddreses
                                                                              .length ==
                                                                          0
                                                                      ? Container()
                                                                      : shippingAddreses[shippingSelectedIndex].address2 == "" ||
                                                                              shippingAddreses[shippingSelectedIndex].address2 == null
                                                                          ? Container()
                                                                          : Text(
                                                                              widget.isFromChooseAddress == true && widget.isFromShipping == true ? shippingAddreses[shippingSelectedIndex].address2.inCaps1 : shippingAddreses[shippingSelectedIndex].address2.inCaps1,
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
                                                                  alignment:
                                                                      Alignment
                                                                          .topLeft,
                                                                  child: shippingAddreses
                                                                              .length ==
                                                                          0
                                                                      ? Container()
                                                                      : shippingAddreses[shippingSelectedIndex].landmark == "" ||
                                                                              shippingAddreses[shippingSelectedIndex].landmark == null
                                                                          ? Container()
                                                                          : Text(
                                                                              widget.isFromChooseAddress == true && widget.isFromShipping == true ? shippingAddreses[shippingSelectedIndex].landmark.inCaps1 : shippingAddreses[shippingSelectedIndex].landmark.inCaps1,
                                                                              style: TextStyle(
                                                                                color: Constants.semiboldColor,
                                                                              ),
                                                                              maxLines: 2,
                                                                              overflow: TextOverflow.clip,
                                                                            ),
                                                                ),
                                                                Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .topLeft,
                                                                  child: Row(
                                                                    children: [
                                                                      shippingAddreses.length ==
                                                                              0
                                                                          ? Container()
                                                                          : Text(
                                                                              widget.isFromChooseAddress == true && widget.isFromShipping == true ? shippingAddreses[shippingSelectedIndex].city.inCaps1 : shippingAddreses[shippingSelectedIndex].city.inCaps1 + ", " + shippingAddreses[shippingSelectedIndex].district,
                                                                              style: TextStyle(
                                                                                // fontWeight: FontWeight.w600,
                                                                                color: Constants.semiboldColor,
                                                                                // fontSize: 12.0
                                                                              ),
                                                                              maxLines: 2,
                                                                              overflow: TextOverflow.clip,
                                                                            ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .topLeft,
                                                                  child: shippingAddreses
                                                                              .length ==
                                                                          0
                                                                      ? Container()
                                                                      : Text(
                                                                          widget.isFromChooseAddress == true && widget.isFromShipping == true
                                                                              ? shippingAddreses[shippingSelectedIndex].name.inCaps1
                                                                              : shippingAddreses[shippingSelectedIndex].name.inCaps1 + ' - ' + shippingAddreses[shippingSelectedIndex].pincode,
                                                                          style:
                                                                              TextStyle(
                                                                            // fontWeight: FontWeight.w600,
                                                                            color:
                                                                                Constants.semiboldColor,
                                                                            // fontSize: 13.0
                                                                          ),
                                                                          maxLines:
                                                                              2,
                                                                          overflow:
                                                                              TextOverflow.clip,
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
                                      ),
                              ),
                            ],
                          )),
                        ]),
                ),
          bottomNavigationBar: getCartResponse.result != null ||
                  this.widget.products != null
              ? Stack(children: <Widget>[
                  Container(
                    height: bottomitemHeight,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey[300]),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 13.0),
                                child: Text(
                                  'Payment Type',
                                  style: new TextStyle(
                                      color: Constants.blackColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 13.0),
                                child: Text(
                                  paymentTypeStr,
                                  style: new TextStyle(
                                      color: Constants.blackColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),
                        priceDetails(),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    "Total",
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Constants.greyColor,
                                    ),
                                    overflow: TextOverflow.clip,
                                  ),
                                  Text(
                                    // "₹ ${value.wholeSalePrice}",
                                    '₹' +
                                        ((totalPrice -
                                                    (totalItemDiscount +
                                                        dicountvalue)) +
                                                gstPrice)
                                            .toStringAsFixed(2)
                                            .replaceAllMapped(reg, mathFunc),
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Constants.greyColor,
                                    ),
                                    overflow: TextOverflow.clip,
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: Container(
                                // height: 48,
                                // width: 160,
                                child: RaisedButton(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    side: BorderSide(
                                      width: 1,
                                      color: Constants.appColor,
                                    ),
                                  ),
                                  color: Constants.appColor,
                                  child: Text(
                                    "    Place Order    ",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  onPressed: () {
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
                                    if (this.widget.isFromCart == true) {
                                      placeOrderFromCart();
                                    } else {
                                      placeOrderFromItemDetails();
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ])
              : Text(''),
        ),
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
                                        value: index,
                                        groupValue: _radioValue1,
                                        onChanged: (value) {
                                          setState(() {
                                            print('Radio $value');
                                            print("Shipping");

                                            print(shippingOldIndex);

                                            _handleRadioValueChange1(value);
                                            shippingaddressID =
                                                shippingAddreses[index].id;

                                            print(shippingAddreses[index].id);

                                            if (shippingOldIndex != index) {
                                              print("wwwwwwwwww " +
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

  Widget priceDetails() {
    return Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
          child: Column(
            children: <Widget>[
              Divider(
                color: Colors.grey[400],
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: [
                          Text(
                            'Total Price ',
                            style: new TextStyle(
                                color: Constants.blackColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                            overflow: TextOverflow.clip,
                          ),
                          Text(
                            this.widget.isFromCart == true ||
                                    this.widget.isFromItemDetails == true
                                ? '(' + totalQTY.toString()
                                : '(' + this.widget.products.length.toString(),
                            style: TextStyle(
                                color: Constants.blackColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                            overflow: TextOverflow.clip,
                          ),
                          Text(
                            totalQTY == 1 ? ' Piece)' : ' Pieces)',
                            style: TextStyle(
                              color: Constants.blackColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.clip,
                          ),
                        ],
                      ),
                      Text(
                        '₹' +
                            totalPrice
                                .toStringAsFixed(2)
                                .replaceAllMapped(reg, mathFunc),
                        style: TextStyle(
                            color: Constants.blackColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      )
                    ]),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Discount',
                        style: TextStyle(
                            color: Constants.blackColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      ),
                      Row(
                        children: [
                          Text(
                            '- ₹' +
                                dicountvalue
                                    .toStringAsFixed(2)
                                    .replaceAllMapped(reg, mathFunc),
                            style: TextStyle(
                                color: Constants.blackColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                          ),
                          Text(
                            ' (' +
                                discountPercentage
                                    .toStringAsFixed(0)
                                    .replaceAllMapped(reg, mathFunc) +
                                ' %)',
                            style: TextStyle(
                                color: Constants.blackColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                          )
                        ],
                      ),
                    ]),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'GST',
                        style: TextStyle(
                            color: Constants.blackColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '₹' +
                            gstPrice
                                .toStringAsFixed(2)
                                .replaceAllMapped(reg, mathFunc),
                        style: TextStyle(
                            color: Constants.blackColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      )
                    ]),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Delivery Fee',
                        style: TextStyle(
                            color: Constants.blackColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Free',
                        style: TextStyle(
                            color: Constants.appColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      )
                    ]),
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Total Amount',
                      style: TextStyle(
                          color: Constants.blackColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '₹' +
                          ((totalPrice - (totalItemDiscount + dicountvalue)) +
                                  gstPrice)
                              .toStringAsFixed(2)
                              .replaceAllMapped(reg, mathFunc),
                      style: TextStyle(
                          color: Constants.blackColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    )
                  ]),
              Divider(
                color: Colors.grey[400],
              ),
            ],
          ),
        ));
  }

  getCartDetails(String userID) async {
    double aaa = 0.0;
    totalItemDiscount = 0.0;
    // progressHud.show();
    print(" selected Userid -- > " + userID);
    String finalUrl = ApiService.baseUrl + ApiService.getCartURL + userID;
    print(" finalUrl -- > " + finalUrl);
    await api.getCartApiCall(finalUrl).then((response) {
      print(" GetCartByUserID -- > " + response.toString());

      setState(() {
        firstLoading = false;
        getCartResponse = GetCartResponse.fromJson(response);
        if (getCartResponse != null && getCartResponse.result != null) {
          print(" CartDetailsResponse -- > " +
              getCartResponse.toJson().toString());
          double productCost = 0.0;
          int totalQtyIndex = 0;
          double priceWithoutGST = 0.0;

          for (int i = 0; i < getCartResponse.result.productsList.length; i++) {
            var finalPrie = 0.0;
            double singleItemGST = (((getCartResponse
                        .result.productsList[i].discountPrince
                        .toDouble()) /
                    100.00) *
                getCartResponse.result.productsList[i].gst.toDouble());

            print('g s t  g s t' + singleItemGST.toString());
            finalPrie = getCartResponse.result.productsList[i].discountPrince +
                singleItemGST;

            cartProducts.add(new Product(
                itemId: getCartResponse.result.productsList[i].id,
                price: getCartResponse.result.productsList[i].discountPrince,
                finalPrice: finalPrie,
                gst: getCartResponse.result.productsList[i].gst,
                discount: getCartResponse.result.productsList[i].discount,
                quantity: getCartResponse.result.productsList[i].quantity,
                sizeId: getCartResponse.result.productsList[i].sizeIds,
                colourId: getCartResponse.result.productsList[i].colourids));

            print('finalPrie   ' + finalPrie.toString());

            double item = getCartResponse.result.productsList[i].discountPrince
                    .toDouble() *
                getCartResponse.result.productsList[i].quantity;
            productCost += item;

            totalQtyIndex += getCartResponse.result.productsList[i].quantity;
          }

          setState(() {
            totalPrice = productCost;
            setState(() {
              print('paymentDiscount  -> ' + paymentDiscount.toString());
              dicountvalue = ((totalPrice / 100) * paymentDiscount);
              print('dicountvalue -> ' + dicountvalue.toString());
              print('dicountvalue -> ' +
                  ((totalPrice / 100) * paymentDiscount).toString());
            });

            priceWithoutGST = totalPrice - (dicountvalue);

            print('priceWithoutGST -> ' + priceWithoutGST.toString());
          });

          setState(() {
            gstPrice = (((priceWithoutGST) / 100.00) *
                getCartResponse.result.productsList[0].gst.toDouble());
            print('gstPrice -> ' + gstPrice.toString());
          });

          print('totalItemDiscount   ' + totalItemDiscount.toString());
          print('totalPrice   ' + totalPrice.toString());
          print('paymentDiscount   ' + paymentDiscount.toString());
          print('dicountvalue   ' + dicountvalue.toString());
          // print('priceWithoutGST   ' + priceWithoutGST.toString());
          print('g s t  g s t -> ' + gstPrice.toString());
          totalQTY = totalQtyIndex;
        } else {
          errorMessage = "Cart is empty";
        }
      });
    }).catchError((onError) {});
  }

  paymentModeAPICall() {
    String paymentURL = ApiService.baseUrl + ApiService.getPaymentModeURL;

    Map<String, dynamic> parameters = {"Id": paymentID, "IsActive": true};
    api.postAPICall(paymentURL, parameters).then((response) {
      print(response);
      if (response["IsSuccess"] == true) {
        paymentModeResponse = PaymentModeResponse.fromJson(response);

        if (paymentModeResponse.listResult.length > 0) {
          setState(() {
            paymentDiscount =
                paymentModeResponse.listResult[0].discount.toDouble();
            discountPercentage = paymentModeResponse.listResult[0].discount;
            print('paymentDiscount --- ' + paymentDiscount.toString());
          });

          //   dicountvalue = ((totalPrice / 100) * paymentDiscount);

          if (this.widget.isFromItemDetails == true) {
            dicountvalue = ((totalPrice / 100) * paymentDiscount);
            double aaa =
                (((totalPrice - (totalItemDiscount + dicountvalue)) / 100.00) *
                    this.widget.products[0].gst.toDouble());

            gstPrice = aaa;
            print('totalPrice --- ' + totalPrice.toString());
            print('PaymentDiscount %--- ' + discountPercentage.toString());

            print('totalItemDiscount -- ' + totalItemDiscount.toString());
            print('dicountvalue --- ' + dicountvalue.toString());
            print('from item details GST   ' + gstPrice.toString());
          } else {}

          if (this.widget.isFromCart == true) {
            getCartDetails(userid.toString());
          }
        }
      }
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
      setState(() {
        vendorAddressReponse = VendorAddressReponse.fromJson(response);
        if (vendorAddressReponse.listResult != null) {
          // vendorAddressReponse.listResult[0].isAddressSelected = true;
          setState(() {
            // shippingAddreses.addAll(vendorAddressReponse.listResult
            //     .where((element) => element.addressTypeId == 21));
            // // billingAddreses = vendorAddressReponse.listResult
            // //     .where((element) => element.addressTypeId == 21);

            print("Address count ->  " +
                vendorAddressReponse.listResult.length.toString());

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

            // if (widget.isFromChooseAddress == true &&
            //     widget.isFromShipping == true) {
            //   // shippingAddreses.removeAt(widget.addressID);
            //   setState(() {
            //     shippingAddreses.insert(0, shippingAddreses[widget.addressID]);
            //     print(shippingAddreses[0].addressName);
            //   });
            // }

            // if (widget.isFromChooseAddress == true &&
            //     widget.isFromBilling == true) {
            //   // shippingAddreses.removeAt(widget.addressID);
            //   setState(() {
            //     billingAddreses.insert(0, billingAddreses[widget.addressID]);
            //     print(billingAddreses[0].addressName);
            //   });
            // }

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

  placeOrderFromCart() {
    print("paymentID - > " + paymentID.toString());
    placeOerderRequestModel.order = new Order(
      vendorId: userid,
      totalPrice: ((totalPrice - (totalItemDiscount + dicountvalue)) + gstPrice)
          .toDouble(),
      statusTypeid: statusTypeID,
      createdbyUserId: userIDString.toString(),
      updatedbyUserId: userIDString.toString(),
      billingAddressId:
          widget.isFromChooseAddress == true && widget.isFromBilling == true
              ? billingAddreses[billingSelectedIndex].id
              : billingAddreses[billingSelectedIndex].id,
      shippingAddressId:
          widget.isFromChooseAddress == true && widget.isFromShipping == true
              ? shippingAddreses[shippingSelectedIndex].id
              : shippingVisible == false
                  ? billingAddreses[billingSelectedIndex].id
                  : shippingAddreses[shippingSelectedIndex].id,
      preferLogisticOparatorId: logisticID,
      paymentType: paymentID,
      discount: discountPercentage,
    );
    placeOerderRequestModel.products = cartProducts;

    String jsonBody = json.encode(placeOerderRequestModel.toJson());
    print(jsonBody);
    print(shippingAddreses.toString());
    api.placeOrder(placeOerderRequestModel).then((response) {
      // print('}}}}}}}}}}}}}}}}}}}}}}  ' + jsonBody);
      // print(response["Result"]["Code"]);
      Navigator.of(context, rootNavigator: true).pop();
      if (response["IsSuccess"] == true) {
        deleteCart(userid.toString());

        Navigator.of(context).push(new MaterialPageRoute(
            builder: (context) => new Thankyou(
                  orderID: response["Result"]["Code"],
                )));
      } else {
        api.globalToast(response["EndUserMessage"]);
      }
    });
  }

  placeOrderFromItemDetails() {
    print("paymentID - > " + paymentID.toString());
    placeOerderRequestModel.order = new Order(
        vendorId: userid,
        totalPrice:
            ((totalPrice - (totalItemDiscount + dicountvalue)) + gstPrice)
                .toDouble(),
        statusTypeid: statusTypeID,
        createdbyUserId: userIDString.toString(),
        updatedbyUserId: userIDString.toString(),
        billingAddressId:
            widget.isFromChooseAddress == true && widget.isFromBilling == true
                ? billingAddreses[billingSelectedIndex].id
                : billingAddreses[billingSelectedIndex].id,
        shippingAddressId:
            widget.isFromChooseAddress == true && widget.isFromShipping == true
                ? shippingAddreses[shippingSelectedIndex].id
                : shippingVisible == false
                    ? billingAddreses[billingSelectedIndex].id
                    : shippingAddreses[shippingSelectedIndex].id,
        preferLogisticOparatorId: logisticID,
        paymentType: paymentID,
        discount: discountPercentage);
    placeOerderRequestModel.products = this.widget.products;

    String jsonBody = json.encode(placeOerderRequestModel.toJson());
    print(jsonBody);

    api.placeOrder(placeOerderRequestModel).then((response) {
      print(response["EndUserMessage"]);
      Navigator.of(context, rootNavigator: true).pop();
      if (response["IsSuccess"] == true) {
        Navigator.of(context).push(new MaterialPageRoute(
            builder: (context) => new Thankyou(
                  orderID: response["Result"]["Code"],
                )));
      } else {
        api.globalToast(response["EndUserMessage"]);
      }
    });
  }

  deleteCart(String loginID) async {
    print(" selected Userid -- > " + loginID.toString());
    String finalUrl =
        ApiService.baseUrl + "/Cart/DeleteCartByUserId/" + loginID;
    await api.deleteCartApiCall(finalUrl).then((response) {
      print(" DeleteCartByUserID -- > " + response.toString());
      setState(() {
        print(response["EndUserMessage"]);
        // deleteCartResponse = DeleteCartResponse.fromJson(response);
        // getCartResponse.result.productsList[0] = null;
        // cartitemcount=getCartResponse.result.productsList[0].quantity;
        print(" DeleteCartByUser -- > " + response.toString());
      });
    });
  }

  void _getstates() {
    ApiService.getStates().then((res) {
      // print(res.toString());
      setState(() {
        states = statesResModelFromJson(res.body).listResult;
        if (vendorinfo != null) {
          // selectedState = null;
          selectedState = states
              .firstWhere((x) => x.id == vendorinfo.listResult[0].stateId);
          print('Selected State :' + selectedState.name);
        }
        print("states comming => " + states.length.toString());
      });
    });
  }

  void backnavigation() {
    if (this.widget.isFromCart == true) {
      //      print('Home screen');
      // this.widget.refresh(); // just refresh() if its statelesswidget
      //  Navigator.pop(context);
      Navigator.of(context).pop(true);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => CartScreen(userID: userid.toString())));
    } else if (this.widget.isFromItemDetails == true) {
      localData.getIntToSF("itemID").then((value) {
        Navigator.of(context).pop(true);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ItemDetailsScreen(itemID: value.toString())));
      });
    } else {
      Navigator.pop(context);
    }
  }

  void _getProfileData(String userid) async {
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
        paymentID = vendorinfo.listResult[0].paymentTypeid;
        paymentTypeStr = vendorinfo.listResult[0].paymentType;

        print("paymentID - > " + paymentID.toString());

        paymentModeAPICall();
      });
    });
  }
}

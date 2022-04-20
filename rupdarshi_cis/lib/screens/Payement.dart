import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rupdarshi_cis/Model/PaymentTypeResponse.dart';
import 'package:rupdarshi_cis/Model/Requests/PlaceOerderRequest.dart';
import 'package:rupdarshi_cis/Service/ApiService.dart';
import 'package:rupdarshi_cis/common/Constants.dart';
import 'package:rupdarshi_cis/common/SessionManager.dart';
import 'package:rupdarshi_cis/screens/ItemDetailsScreen.dart';
import 'package:rupdarshi_cis/screens/PlaceOrderScreen.dart';
import 'package:rupdarshi_cis/screens/WishList.dart';

import '../Model/GetCartResponse.dart';
import '../Service/ApiService.dart';
import '../common/LocalDb.dart';
import 'Thankyou.dart';

final GlobalKey<State> _keyLoader = new GlobalKey<State>();

class PaymentScreen extends StatefulWidget {
  final bool isFromCart;
  final List<Product> products;
  final int shippingAddressID;
  final int billingAddressID;
  PaymentScreen(
      {this.isFromCart,
      this.products,
      this.shippingAddressID,
      this.billingAddressID});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  LocalData localData = new LocalData();
  int logisticID = 0;
  ApiService apiConnecter;
  Order order;
  List<Product> cartProducts;
  PlaceOerderRequestModel placeOerderRequestModel;
  SessionManager pref = new SessionManager();
  GetCartResponse getCartResponse;
  PaymentTypeResponse paymentTypeResponse;
  int loginID;
  String userid;
  int paymentType = 0;
  int statusTypeID = 0;
  var totalPrice = 0.0;
  String errorMessage = "";
  var gstPrice = 0.0;
  bool islogin = false;
  bool firstLoading = true;
  int _radioValue1 = 0;
  int _radioValue2 = -1;
  int _radioValue3 = -1;
  ScrollController controller;

  void _handleRadioValueChange1(int value) {
    setState(() {
      _radioValue1 = value;
      switch (_radioValue1) {
        case 0:
          _radioValue1 = 0;
          _radioValue2 = -1;
          _radioValue3 = -1;
          break;
      }
    });
  }

  void _handleRadioValueChange2(int value) {
    setState(() {
      _radioValue2 = value;
      switch (_radioValue2) {
        case 0:
          _radioValue2 = 0;
          _radioValue1 = -1;
          _radioValue3 = -1;
          break;
      }
    });
  }

  void _handleRadioValueChange3(int value) {
    setState(() {
      _radioValue3 = value;
      switch (_radioValue3) {
        case 0:
          _radioValue3 = 0;
          _radioValue1 = -1;
          _radioValue2 = -1;
          break;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    apiConnecter = new ApiService();
    getCartResponse = new GetCartResponse();
    placeOerderRequestModel = new PlaceOerderRequestModel();
    paymentTypeResponse = new PaymentTypeResponse();
    paymentType = 0;
    statusTypeID = 0;

    cartProducts = new List<Product>();
    SessionManager().getUserId().then((value) {
      loginID = value;
      print('User ID from Profile :' + loginID.toString());

      getPaymentTypes();

      if (this.widget.isFromCart == true) {
        getCartDetails(loginID.toString());
      } else {
        print("Came from Item details");

        for (int i = 0; i < this.widget.products.length; i++) {
          double item = this.widget.products[i].price.toDouble() *
              this.widget.products[i].quantity;

          double aaa = (((this.widget.products[i].price.toDouble()) / 100.00) *
                  this.widget.products[i].gst.toDouble()) *
              this.widget.products[i].quantity.toDouble();
          print('g s t  g s t' + aaa.toString());
          gstPrice += aaa;
          totalPrice += item;
        }
      }
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

    SessionManager().getUserIdString().then((value) {
      userid = value;
      print('User ID from Profile :' + userid.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double itemHeight = (size.height) / 3.5;
    final double itemWidth = size.width / 2;

    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(
        textTheme: GoogleFonts.latoTextTheme(
          Theme.of(context).textTheme.apply(),
        ),
      ),
      home: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Payment',
                style: TextStyle(
                  color: Constants.greyColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1),
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
            // scrollDirection: Axis.vertical,
            child:
                // vendorinfo == null
                //     ? Center(
                //         child: CircularProgressIndicator(),
                //       ):
                Column(children: <Widget>[payementInformation()]),
          ),
          bottomNavigationBar: getCartResponse.result != null ||
                  this.widget.products != null
              ? Stack(children: <Widget>[
                  Container(
                    height: 55,
                    color: Colors.white,
                    // decoration: BoxDecoration(
                    //   color: Colors.white,
                    //   border: Border.all(color: Colors.grey[300]),
                    // ),
                    child: Column(
                      children: [
                        // priceDetails(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Container(
                                // height: 48,
                                child: Column(
                                  // mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Divider()
                                    // Text(
                                    //   "",
                                    //   style: TextStyle(
                                    //     fontSize: 11,
                                    //     fontWeight: FontWeight.bold,
                                    //     color: Constants.greyColor,
                                    //   ),
                                    //   overflow: TextOverflow.clip,
                                    // ),
                                    // Text(
                                    //   // "₹ ${value.wholeSalePrice}",
                                    //   '₹' +
                                    //       (totalPrice + gstPrice)
                                    //           .toStringAsFixed(2)
                                    //           .replaceAllMapped(reg, mathFunc),
                                    //   style: TextStyle(
                                    //     fontSize: 15,
                                    //     fontWeight: FontWeight.bold,
                                    //     color: Constants.greyColor,
                                    //   ),
                                    //   overflow: TextOverflow.clip,
                                    // ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: Container(
                                // height: 48,
                                // width: 160,
                                child: RaisedButton(
                                  color: Constants.appColor,
                                  child: Text(
                                    "Place Order",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  onPressed: () {
                                    // PlaceOrderScreen
                                    print(
                                        "Check out Clicked and payment type is : " +
                                            paymentType.toString());

                                    Navigator.of(context).push(
                                        new MaterialPageRoute(
                                            builder: (context) =>
                                                new PlaceOrderScreen()));

                                    // if (this.widget.isFromCart == true) {
                                    //   placeOrderFromCart();
                                    // } else {
                                    //   placeOrderFromItemDetails();
                                    // }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ])
              : Container(),
        ),
      ),
    );
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
                            'Price ',
                            style: new TextStyle(
                                color: Constants.blackColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                            overflow: TextOverflow.clip,
                          ),
                          Text(
                            this.widget.isFromCart == true
                                ? '(' +
                                    getCartResponse.result.productsList.length
                                        .toString() +
                                    ' Items)'
                                : '(' +
                                    this.widget.products.length.toString() +
                                    ' Items)',
                            style: TextStyle(
                                color: Constants.blackColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
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
              // SizedBox(
              //   height: 10,
              // ),
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
              // SizedBox(
              //   height: 10,
              // ),
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
              // Divider(
              //   color: Colors.grey[400],
              // ),
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
                          (totalPrice + gstPrice)
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

  Widget payementInformation() {
    return
        // categoryListResult == null
        //     ? Center(
        //         child: Text('No Data ..'),
        //       )
        //     :

        // decoration: BoxDecoration(
        //     borderRadius: BorderRadius.circular(100), shape: BoxShape.rectangle),
        Padding(
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
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Column(
                                  children: [
                                    Text(
                                      'Payment Information'.inCaps,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          color: Constants.blackColor,
                                          fontSize: 17.0),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 8.0,
                                      ),
                                      child: Text(
                                        'Choose your payment option'.inCaps,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Constants.lightgreyColor,
                                            fontSize: 12.0),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Divider(
                              color: Colors.grey,
                            ),
                            Container(
                              //height: 75,
                              decoration: BoxDecoration(
                                  color: paymentType != 0
                                      ? paymentType ==
                                              paymentTypeResponse
                                                  .listResult[0].typeCdId
                                          ? Colors.yellow[50]
                                          : Colors.grey[100]
                                      : Colors.yellow[50],
                                  border: Border.all(
                                      color: paymentType != 0
                                          ? paymentType ==
                                                  paymentTypeResponse
                                                      .listResult[0].typeCdId
                                              ? Constants.appColor
                                              : Constants.lightgreyColor
                                          : Constants.lightgreyColor,
                                      width: 1.5)),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: <Widget>[
                                          new Radio(
                                              activeColor: Constants.appColor,
                                              value: 0,
                                              groupValue: _radioValue1,
                                              onChanged: (value) {
                                                print(paymentTypeResponse
                                                    .listResult[0].typeCdId);
                                                paymentType =
                                                    paymentTypeResponse
                                                        .listResult[0].typeCdId;
                                                _handleRadioValueChange1(value);
                                              }),
                                          Text(
                                            "Net 30",
                                            style: new TextStyle(
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.bold,
                                                color: Constants.blackColor),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 50.0, bottom: 10),
                                        child: Text(
                                          "Pay after 30 days",
                                          style: new TextStyle(
                                              fontSize: 12.0,
                                              fontWeight: FontWeight.w600,
                                              color: Constants.lightgreyColor),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today,
                                          size: 18,
                                          color: Constants.lightgreyColor),
                                      Text(
                                        "30",
                                        style: new TextStyle(
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.w600,
                                            color: Constants.blackColor),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 10.0),
                                        child: Text(
                                          "/d",
                                          style: new TextStyle(
                                              fontSize: 12.0,
                                              fontWeight: FontWeight.w600,
                                              color: Constants.lightgreyColor),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Container(
                              //  height: 75,
                              decoration: BoxDecoration(
                                  color: paymentType != 0
                                      ? paymentType ==
                                              paymentTypeResponse
                                                  .listResult[1].typeCdId
                                          ? Colors.yellow[50]
                                          : Colors.grey[100]
                                      : Colors.grey[100],
                                  border: Border.all(
                                      color: paymentType != 0
                                          ? paymentType ==
                                                  paymentTypeResponse
                                                      .listResult[1].typeCdId
                                              ? Constants.appColor
                                              : Constants.lightgreyColor
                                          : Constants.lightgreyColor,
                                      width: 1.5)),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: <Widget>[
                                          new Radio(
                                            activeColor: Constants.appColor,
                                            value: 0,
                                            groupValue: _radioValue2,
                                            onChanged: (value) {
                                              paymentType = paymentTypeResponse
                                                  .listResult[1].typeCdId;
                                              _handleRadioValueChange2(value);
                                              print(paymentTypeResponse
                                                  .listResult[1].typeCdId);
                                            },
                                          ),
                                          Text(
                                            "Net 60",
                                            style: new TextStyle(
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.bold,
                                                color: Constants.blackColor),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 50.0, bottom: 10),
                                        child: Text(
                                          "Pay after 60 days",
                                          style: new TextStyle(
                                              fontSize: 12.0,
                                              fontWeight: FontWeight.w600,
                                              color: Constants.lightgreyColor),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today,
                                          size: 18,
                                          color: Constants.lightgreyColor),
                                      Text(
                                        "60",
                                        style: new TextStyle(
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.w600,
                                            color: Constants.blackColor),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 10.0),
                                        child: Text(
                                          "/d",
                                          style: new TextStyle(
                                              fontSize: 12.0,
                                              fontWeight: FontWeight.w600,
                                              color: Constants.lightgreyColor),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Container(
                              // height: 75,
                              decoration: BoxDecoration(
                                  color: paymentType != 0
                                      ? paymentType ==
                                              paymentTypeResponse
                                                  .listResult[2].typeCdId
                                          ? Colors.yellow[50]
                                          : Colors.grey[100]
                                      : Colors.grey[100],
                                  border: Border.all(
                                      color: paymentType != 0
                                          ? paymentType ==
                                                  paymentTypeResponse
                                                      .listResult[2].typeCdId
                                              ? Constants.appColor
                                              : Constants.lightgreyColor
                                          : Constants.lightgreyColor,
                                      width: 1.5)),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: <Widget>[
                                          new Radio(
                                            activeColor: Constants.appColor,
                                            value: 0,
                                            groupValue: _radioValue3,
                                            onChanged: (value) {
                                              paymentType = paymentTypeResponse
                                                  .listResult[2].typeCdId;
                                              print(paymentTypeResponse
                                                  .listResult[2].typeCdId);
                                              _handleRadioValueChange3(value);
                                            },
                                          ),
                                          Text(
                                            "Cash",
                                            style: new TextStyle(
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.bold,
                                                color: Constants.blackColor),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 50.0, bottom: 10),
                                        child: Text(
                                          "Pay by Cash",
                                          style: new TextStyle(
                                              fontSize: 12.0,
                                              fontWeight: FontWeight.w600,
                                              color: Constants.lightgreyColor),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ));
  }

  getCartDetails(String userID) async {
    gstPrice = 0.0;
    // progressHud.show();
    print(" selected Userid -- > " + userID);
    String finalUrl = ApiService.baseUrl + ApiService.getCartURL + userID;
    print(" finalUrl -- > " + finalUrl);
    await apiConnecter.getCartApiCall(finalUrl).then((response) {
      print(" GetCartByUserID -- > " + response.toString());

      setState(() {
        firstLoading = false;
        getCartResponse = GetCartResponse.fromJson(response);
        if (getCartResponse != null && getCartResponse.result != null) {
          // cartitemcount = getCartResponse.result.productsList.length;
          // cartID = getCartResponse.result.cart.id;
          // print(" QUANTITY -- > " + cartitemcount.toString());
          print(" CartDetailsResponse -- > " +
              getCartResponse.toJson().toString());
          double productCost = 0.0;

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

            print('finalPrie' + finalPrie.toString());

            cartProducts.add(new Product(
                itemId: getCartResponse.result.productsList[i].id,
                price: getCartResponse.result.productsList[i].discountPrince,
                finalPrice: finalPrie,
                gst: getCartResponse.result.productsList[i].gst,
                discount: getCartResponse.result.productsList[i].discount,
                quantity: getCartResponse.result.productsList[i].quantity,
                sizeId: getCartResponse.result.productsList[i].sizeIds,
                colourId: getCartResponse.result.productsList[i].colourids));

            double item = getCartResponse.result.productsList[i].discountPrince
                    .toDouble() *
                getCartResponse.result.productsList[i].quantity;

            double aaa = (((getCartResponse
                            .result.productsList[i].discountPrince
                            .toDouble()) /
                        100.00) *
                    getCartResponse.result.productsList[i].gst.toDouble()) *
                getCartResponse.result.productsList[i].quantity.toDouble();
            print('g s t  g s t' + aaa.toString());
            gstPrice += aaa;
            productCost += item;
            // int itemsQuantity=getCartResponse.result.productsList[i].quantity.toString();
          }
          totalPrice = productCost;
          // gstPrice = gst;

          //  totalSavingPrice = totItemsSavingPrice;
        } else {
          errorMessage = "Cart is empty";
        }
      });
    }).catchError((onError) {});
  }

  getPaymentTypes() async {
    String finalUrl = ApiService.baseUrl + ApiService.getPaymentTypeURL;
    print(" finalUrl -- > " + finalUrl);
    await apiConnecter.getAPICall(finalUrl).then((response) {
      print(" getPaymentTypes -- > " + response.toString());
      setState(() {
        paymentTypeResponse = PaymentTypeResponse.fromJson(response);

        if (paymentTypeResponse.isSuccess == true) {
          setState(() {
            paymentType = paymentTypeResponse.listResult[0].typeCdId;
          });
        } else {
          print(paymentTypeResponse.endUserMessage);
        }
      });
    });
  }

  placeOrderFromCart() {
    placeOerderRequestModel.order = new Order(
        vendorId: loginID,
        totalPrice: totalPrice + gstPrice,
        statusTypeid: statusTypeID,
        createdbyUserId: userid.toString(),
        updatedbyUserId: userid.toString(),
        billingAddressId: this.widget.billingAddressID,
        shippingAddressId: this.widget.shippingAddressID,
        preferLogisticOparatorId: logisticID,
        paymentType: paymentType);
    placeOerderRequestModel.products = cartProducts;

    String jsonBody = json.encode(placeOerderRequestModel.toJson());
    print(jsonBody);

    apiConnecter.placeOrder(placeOerderRequestModel).then((response) {
      // print(response["EndUserMessage"]);
      // print(response["Result"]["Code"]);

      if (response["IsSuccess"] == true) {
        deleteCart(loginID.toString());
        Navigator.of(context).push(new MaterialPageRoute(
            builder: (context) => new Thankyou(
                  orderID: response["Result"]["Code"],
                )));
      } else {
        apiConnecter.globalToast(response["EndUserMessage"]);
      }
    });
  }

  placeOrderFromItemDetails() {
    placeOerderRequestModel.order = new Order(
        vendorId: loginID,
        totalPrice: totalPrice,
        statusTypeid: statusTypeID,
        createdbyUserId: userid.toString(),
        updatedbyUserId: userid.toString(),
        shippingAddressId: this.widget.shippingAddressID,
        billingAddressId: this.widget.billingAddressID,
        preferLogisticOparatorId: logisticID,
        paymentType: paymentType);
    placeOerderRequestModel.products = this.widget.products;

    apiConnecter.placeOrder(placeOerderRequestModel).then((response) {
      print(response["EndUserMessage"]);
      if (response["IsSuccess"] == true) {
        Navigator.of(context).push(new MaterialPageRoute(
            builder: (context) => new Thankyou(
                  orderID: response["Result"]["Code"],
                )));
      } else {
        apiConnecter.globalToast(response["EndUserMessage"]);
      }
    });
  }

  deleteCart(String loginID) async {
    print(" selected Userid -- > " + loginID.toString());
    String finalUrl =
        ApiService.baseUrl + "/Cart/DeleteCartByUserId/" + loginID;
    await apiConnecter.deleteCartApiCall(finalUrl).then((response) {
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
}

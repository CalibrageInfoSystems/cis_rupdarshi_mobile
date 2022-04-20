import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:rupdarshi_cis/Service/ApiService.dart';
import 'package:rupdarshi_cis/common/Constants.dart';
import 'package:rupdarshi_cis/common/SessionManager.dart';
import 'package:rupdarshi_cis/screens/ItemDetailsScreen.dart';

final GlobalKey<State> _keyLoader = new GlobalKey<State>();

class OrderConfirmation extends StatefulWidget {
  // final String userID;

  // const AddressScreen({@required this.userID});
  @override
  _OrderConfirmationState createState() => _OrderConfirmationState();
}

class _OrderConfirmationState extends State<OrderConfirmation> {
  SessionManager pref = new SessionManager();
  int _radioValue1 = -1;
  int _radioValue2 = -1;
  int _radioValue3 = -1;
  int userid;
  bool islogin = false;
  ScrollController controller;
  ApiService api;

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

  @override
  void initState() {
    super.initState();
    SessionManager().getUserId().then((value) {
      userid = value;
      print('User ID from Profile :' + userid.toString());
    });
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
            title: Text('Order Confirmation',
                style: TextStyle(
                    color: Constants.greyColor, fontWeight: FontWeight.bold),
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
                Column(children: <Widget>[
              SizedBox(
                height: 10,
              ),
              deliveryAddress(),
              payementDetails(),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Estimated Delivery :',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '3 - 5 Days',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Constants.lightgreyColor),
                    ),
                  ],
                ),
              ),
              priceDetails()
            ]),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(0.0),
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey[300]),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Container(
                      height: 48,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Total",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Constants.greyColor,
                            ),
                            // overflow: TextOverflow.clip,
                          ),
                          Text(
                            // "₹ ${value.wholeSalePrice}",
                            "₹ 5655",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Constants.greyColor,
                            ),
                            overflow: TextOverflow.clip,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 48,
                      width: 160,
                      child: RaisedButton(
                        color: Constants.appColor,
                        child: Text(
                          "Place Order",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                              context, MaterialPageRoute(builder: null));
                        },
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

  Widget priceDetails() {
    return Container(
        color: Colors.white,
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
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Sub Total (3 Items)',
                            style: TextStyle(
                                color: Constants.blackColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w500),
                          ),
                          Text(
                            '₹ 567',
                            style: TextStyle(
                                color: Constants.blackColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w500),
                          )
                        ]),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'GST',
                            style: TextStyle(
                                color: Constants.blackColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w500),
                          ),
                          Text(
                            '33',
                            style: TextStyle(
                                color: Constants.blackColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w500),
                          )
                        ]),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Delivery Fee',
                            style: TextStyle(
                                color: Constants.blackColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w500),
                          ),
                          Text(
                            'Free',
                            style: TextStyle(
                                color: Constants.appColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w500),
                          )
                        ]),
                  ),
                  Divider(
                    color: Colors.grey[400],
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'Amount Payable',
                          style: TextStyle(
                              color: Constants.blackColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w500),
                        ),
                        Text(
                          '₹988',
                          style: TextStyle(
                              color: Constants.blackColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w500),
                        )
                      ]),
                ],
              ),
            ),
          ),
        ));
  }

  Widget deliveryAddress() {
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
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Delivery Address'.inCaps,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Constants.blackColor,
                                          fontSize: 18.0),
                                    ),
                                    Icon(Icons.edit)
                                  ],
                                ),
                              ),
                            ),
                            Divider(
                              color: Colors.grey,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(
                                "Flat No.406, Western Colony, Jal Vayu Vihar, Addagutta Society, KPHB Colony ",
                                style: new TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w600,
                                    color: Constants.blackColor),
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

  Widget payementDetails() {
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
                              padding: const EdgeInsets.all(5.0),
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Delivery Address'.inCaps,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Constants.blackColor,
                                          fontSize: 18.0),
                                    ),
                                    Icon(Icons.edit)
                                  ],
                                ),
                              ),
                            ),
                            Divider(
                              color: Colors.grey,
                            ),
                            Container(
                              height: 70,
                              decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  border: Border.all(
                                      color: Constants.lightgreyColor,
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
                                            onChanged: _handleRadioValueChange1,
                                          ),
                                          Text(
                                            "Net 40",
                                            style: new TextStyle(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold,
                                                color: Constants.blackColor),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 50.0),
                                        child: Text(
                                          "Pay after 40 days",
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
                                        "40",
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
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ));
  }
}

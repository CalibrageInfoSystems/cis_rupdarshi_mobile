import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:rupdarshi_cis/Model/VendorAddressReponse.dart';
import 'package:rupdarshi_cis/common/Constants.dart';

class SelectAddress extends StatefulWidget {
  final List<ListResultAddress> shippingAddreses;
  final List<ListResultAddress> billingAddreses;
  final bool isShippingAdds;

  SelectAddress(
      {this.shippingAddreses, this.billingAddreses, this.isShippingAdds});

  @override
  _SelectAddressState createState() => _SelectAddressState();
}

class _SelectAddressState extends State<SelectAddress> {
  int _radioValue2 = 1;
  int oldIndex = 0;

  void _handleRadioValueChange2(int value) {
    setState(() {
      _radioValue2 = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: new ThemeData(
            // textTheme: GoogleFonts.latoTextTheme(
            //   Theme.of(context).textTheme.apply(),
            // ),
            ),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
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
          body: Container(
            child: Column(
              children: <Widget>[
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
              ],
            ),
          ),
        ));
  }
}

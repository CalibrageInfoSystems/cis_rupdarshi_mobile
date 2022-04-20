import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rupdarshi_cis/common/Constants.dart';

class PlaceOrderScreen extends StatefulWidget {
  @override
  _PlaceOrderScreenState createState() => _PlaceOrderScreenState();
}

class _PlaceOrderScreenState extends State<PlaceOrderScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(
        textTheme: GoogleFonts.latoTextTheme(
          Theme.of(context).textTheme.apply(),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text("Order confirmation",
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
          child: Container(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
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
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Align(
                                                alignment: Alignment.topLeft,
                                                child: Text(
                                                  "Delivery Address",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          Constants.greyColor,
                                                      fontSize: 14.0),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.clip,
                                                ),
                                              ),
                                              GestureDetector(
                                                child: Text(
                                                  "",
                                                  style: TextStyle(
                                                    // fontSize:
                                                    //     16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Constants.appColor,
                                                  ),
                                                ),
                                                onTap: () {
                                                  // selectAddress();

                                                  // Navigator.of(
                                                  //         context)
                                                  //     .pushReplacement(MaterialPageRoute(
                                                  //         builder: (context) => SelectAddress(
                                                  //               isShippingAdds: true,
                                                  //               shippingAddreses: shippingAddreses,
                                                  //             )));
                                                },
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Align(
                                            alignment: Alignment.topLeft,
                                            child: Text(
                                              "",
                                              style: TextStyle(
                                                // fontWeight: FontWeight.w600,
                                                color: Constants.semiboldColor,
                                                fontWeight: FontWeight.bold,
                                                // fontSize: 12.0
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.clip,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 8,
                                          ),
                                          Align(
                                            alignment: Alignment.topLeft,
                                            child: Text(
                                              "",
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
                                            child: Text(
                                              "",
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
                                            child: Text(
                                              "",
                                              style: TextStyle(
                                                color: Constants.semiboldColor,
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
                                                  "",
                                                  // shippingAddreses[0].city.inCaps1 + ", " + shippingAddreses[0].district.inCaps1,
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
                                              "shippingAddreses[0].name.inCaps1" +
                                                  ' - ' +
                                                  "shippingAddreses[0].pincode",
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
                ),
                Card(
                  child: Column(
                    children: <Widget>[
                      Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "Payment Details",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Constants.greyColor,
                                  fontSize: 14.0),
                              maxLines: 2,
                              overflow: TextOverflow.clip,
                            ),
                          )),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          //height: 75,
                          decoration: BoxDecoration(
                              color: Colors.yellow[50],
                              border: Border.all(
                                  color: Constants.appColor, width: 1.5)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: <Widget>[
                                      new Radio(
                                          activeColor: Constants.appColor,
                                          value: 0,
                                          groupValue: 0,
                                          onChanged: (value) {}),
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
                                    padding: const EdgeInsets.only(right: 10.0),
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
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:rupdarshi_cis/screens/MyOrder.dart';
import 'package:rupdarshi_cis/screens/NewHomeScreen.dart';
import '../common/Constants.dart';

class Thankyou extends StatefulWidget {
  final String orderID;
  Thankyou({this.orderID});
  @override
  _ThankyouState createState() => _ThankyouState();
}

class _ThankyouState extends State<Thankyou> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double itemHeight = (size.height) / 4;
    final double itemWidth = size.width / 1;
    return new MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            body: Column(children: <Widget>[
              SizedBox(
                height: 100,
              ),
              Center(
                  child: Column(
                children: [
                  Image.asset(
                    'assets/Bag.png',
                    fit: BoxFit.fill,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Thank you...!',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Constants.lightgreyColor,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Your order has been placed',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Constants.lightgreyColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    'Your order ID is ' + this.widget.orderID.toString(),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Constants.lightgreyColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              )),
            ]),
            bottomNavigationBar: Container(
              height: itemHeight,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      width: double.infinity,
                      child: RaisedButton(
                        color: Constants.appColor,
                        child: Text(
                          "Go to Orders",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 2,
                            color: Constants.appColor,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => MyOrderScreen()));
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      width: double.infinity,
                      child: RaisedButton(
                        color: Colors.white,
                        child: Text(
                          "Continue shopping",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Constants.lightgreyColor,
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 2,
                            color: Constants.appColor,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(new MaterialPageRoute(
                              builder: (context) => new NewHomeScreen()));
                        },
                      ),
                    ),
                  )
                ],
              ),
            )));
  }
}

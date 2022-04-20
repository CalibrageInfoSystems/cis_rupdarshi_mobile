import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rupdarshi_cis/Model/GetCartResponse.dart';
import 'package:rupdarshi_cis/Model/GetOrdersResponse.dart';
import 'package:rupdarshi_cis/Model/OrderDetailsResponse.dart';
import 'package:rupdarshi_cis/Model/PaymentModeResponse.dart';
import 'package:rupdarshi_cis/Model/TrackHistoryResponse.dart';
import 'package:rupdarshi_cis/Model/TrackOrderResponse.dart';
import 'package:rupdarshi_cis/Service/ApiService.dart';
import 'package:rupdarshi_cis/common/Constants.dart';
import 'package:rupdarshi_cis/common/LocalDb.dart';
import 'package:rupdarshi_cis/common/SessionManager.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:rupdarshi_cis/screens/MyOrder.dart';
import 'package:intl/intl.dart';
import 'package:rupdarshi_cis/Model/ShippingReceiptResponse.dart';
import 'package:pdf_flutter/pdf_flutter.dart';
import 'package:rupdarshi_cis/screens/PDF.dart';

extension CapExtension on String {
  String get inCapsO => '${this[0].toUpperCase()}${this.substring(1)}';
  String get allInCapsO => this.toUpperCase();
}

RegExp reg = new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
Function mathFunc = (Match match) => '${match[1]},';
final GlobalKey<State> _keyLoader = new GlobalKey<State>();
ProgressDialog pr;
TrackListResult trackListResult;

class OrderDetailsScreen extends StatefulWidget {
  final int orderID;
  final String status;
  final int statusID;
  final String orderCode;
  final String fileLocation;
  final String fileName;
  final int discount;
  final double totalPrice;
  final double payableAmount;

  OrderDetailsScreen(
      {this.orderID,
      this.status,
      this.statusID,
      this.orderCode,
      this.fileLocation,
      this.fileName,
      this.discount,
      this.totalPrice,
      this.payableAmount});
  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  List _elements = [
    // {'name': 'John', 'group': 'Team A'},
    // {'name': 'Will', 'group': 'Team B'},
    // {'name': 'Beth', 'group': 'Team A'},
    // {'name': 'Miranda', 'group': 'Team B'},
    // {'name': 'Mike', 'group': 'Team C'},
    // {'name': 'Danny', 'group': 'Team C'},
  ];

  var formatter = new DateFormat("dd-MM-yyyy");
  int _radioValue1 = -1;
  int _radioValue2 = -1;
  int _radioValue3 = -1;

  int statusTypeID = 0;
  OrderDetailsResponse orderDetailsResponse;
  TrackOrderResponse trackOrderResponse;
  // TrackListResult trackListResult;
  TrackHistoryResponse trackHistoryResponse;
  DateTime orderDate;
  String ordersDateStr;
  bool firstLoading = true;
  GetOrdersResponse getOrdersResponse;
  List<OrderDetails> orderDetails;
  List<OrderDetails> shippedorderDetails;
  List<OrderDetails> confirmedorderDetails;
  List<OrderDetails> canceledorderDetails;
  List<OrderDetails> deliverdorderDetails;
  ShippingReceiptResponse shippingReceiptResponse;
  PaymentModeResponse paymentModeResponse;
  List sections = [];
  var discountedPrice = 0.0;
  var totalPrice = 0.0;
  var totalItemDiscount = 0.0;
  var gstPrice = 0.0;
  bool islogin = false;
  ProgressDialog progressHud;
  ScrollController controller;
  LocalData localData = new LocalData();
  var _itemCount = 0;
  int loginUserID = 0;
  String userID;
  ApiService api;
  GetCartResponse getCartResponse;
  int totalQTY = 0;
  int paymentID = 0;
  int discountPercentage = 0;
  double paymentDiscount = 0.0;
  var totaldiscountPrice = 0.0;
  double dicountvalue = 0.0;

  @override
  void initState() {
    firstLoading = true;
    super.initState();

    totalQTY = 0;
    formatter = new DateFormat("dd-MM-yyyy");
    orderDetailsResponse = new OrderDetailsResponse();
    trackOrderResponse = new TrackOrderResponse();
    trackListResult = new TrackListResult();
    orderDetails = new List<OrderDetails>();
    shippedorderDetails = new List<OrderDetails>();
    confirmedorderDetails = new List<OrderDetails>();
    canceledorderDetails = new List<OrderDetails>();
    deliverdorderDetails = new List<OrderDetails>();
    shippingReceiptResponse = new ShippingReceiptResponse();
    trackHistoryResponse = new TrackHistoryResponse();
    sections = [];
    api = new ApiService();
    pr = new ProgressDialog(context);
    orderDate = DateTime.now();
    ordersDateStr = "";

    getTrackDetailsAPICall(widget.orderID);
    SessionManager().getIsLogin().then((value) {
      islogin = value;
      print('is login new splash $islogin');
    });

    localData.getIntToSF(LocalData.PAYMENTTYPEID).then((paymentid) {
      setState(() {
        paymentID = paymentid;
        print('object payyyyyyyyyment id' + paymentID.toString());
        paymentModeAPICall();
      });
    });
    localData.getStringValueSF(LocalData.USERIDSRING).then((userid) {
      setState(() {
        userID = userid;
        getOrderDetailsAPICall(widget.orderID);
        print('USERid ' + userID.toString());
      });
    });
    print('StatusTypeId ' + widget.statusID.toString());
    print('OrderId ' + widget.orderID.toString());
    print('OrderCode ' + widget.orderCode.toString());
    statusTypeID = 0;
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double itemHeight = (size.height) / 4;
    final double bottomHeight = (size.height) / 2.8;
    final double itemWidth = size.width / 2;

    return WillPopScope(
      onWillPop: () {
        backnavigation();
      },
      child: DefaultTabController(
        length: 5,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Order Details',
                style: TextStyle(
                    color: Constants.blackColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 16),
                overflow: TextOverflow.ellipsis,
                maxLines: 1),
            backgroundColor: Constants.bgColor,
            leading: GestureDetector(
              onTap: () {
                // Navigator.pop(context);
                Navigator.of(context).push(new MaterialPageRoute(
                    builder: (context) => new MyOrderScreen()));
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
                  child: Column(children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 8.0, left: 8.0, right: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Order ID #',
                                style: TextStyle(
                                  color: Constants.lightgreyColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                widget.orderCode.toString(),
                                style: TextStyle(
                                  color: Constants.blackColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: Container(
                                // width: 100,
                                decoration: BoxDecoration(
                                  color: this.widget.statusID == 11
                                      ? Constants.confirmedBGColor
                                      : this.widget.statusID == 12
                                          ? Constants.shippedBGColor
                                          : this.widget.statusID == 13
                                              ? Constants.cancelBGColor
                                              : this.widget.statusID == 14
                                                  ? Constants.deliverBGColor
                                                  : Colors.red,
                                  // border: Border.all(color: Colors.green[100]),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                      width: 1.5,
                                      color: this.widget.statusID == 11
                                          ? Colors.orange[900]
                                          : this.widget.statusID == 12
                                              ? Constants.appColor
                                              : this.widget.statusID == 13
                                                  ? Colors.red
                                                  : this.widget.statusID == 14
                                                      ? Colors.green
                                                      : Colors.red),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Center(
                                    child: Row(
                                      // mainAxisAlignment:
                                      //     MainAxisAlignment
                                      //         .spaceBetween,
                                      children: <Widget>[
                                        Image.asset(
                                          this.widget.statusID == 11
                                              ? 'assets/checked-24.png'
                                              : this.widget.statusID == 12
                                                  ? 'assets/in-transit-24.png'
                                                  : this.widget.statusID == 13
                                                      ? 'assets/cancel-24.png'
                                                      : this.widget.statusID ==
                                                              14
                                                          ? 'assets/delivered-box-24.png'
                                                          : 'assets/delivered-box-24.png',
                                          // fit: BoxFit.fill,
                                          height: 12,
                                        ),
                                        Text(
                                          "  " + this.widget.status,
                                          style: TextStyle(
                                              // fontSize: 10,
                                              color: this.widget.statusID == 11
                                                  ? Colors.orange[900]
                                                  : this.widget.statusID == 12
                                                      ? Constants.appColor
                                                      : this.widget.statusID ==
                                                              13
                                                          ? Colors.red
                                                          : this
                                                                      .widget
                                                                      .statusID ==
                                                                  14
                                                              ? Colors.green
                                                              : Colors.red,
                                              fontWeight: FontWeight.w700),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                )),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Divider(
                      color: Constants.lightgreyColor,
                      // thickness: 0.5,
                    ),
                    ordersDetails(),
                    SizedBox(
                      height: 5,
                      child: Container(
                        color: Constants.imageBGColor,
                      ),
                    ),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                'Payment Information',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 12),
                              )),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Align(
                              alignment: Alignment.topLeft,
                              child: Row(
                                children: [
                                  Text(
                                    orderDetailsResponse == null ||
                                            orderDetailsResponse.listResult ==
                                                null
                                        ? ""
                                        : orderDetailsResponse.listResult[0]
                                                    .paymentTypeId ==
                                                16
                                            ? "Pay 30"
                                            : orderDetailsResponse.listResult[0]
                                                        .paymentTypeId ==
                                                    17
                                                ? "Pay 60"
                                                : "Pay Cash",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 11,
                                        color: Constants.appColor),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    orderDetailsResponse == null ||
                                            orderDetailsResponse.listResult ==
                                                null
                                        ? ""
                                        : '(Pay after delivery)',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 9),
                                  ),
                                ],
                              )),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Divider(
                      color: Constants.lightgreyColor,
                      // thickness: 0.5,
                    ),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 2, left: 8),
                          child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                'Billing Address',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 12),
                              )),
                        ),
                        orderDetailsResponse.listResult == null ||
                                orderDetailsResponse
                                        .listResult[0].billingAddress ==
                                    null
                            ? Container()
                            : Padding(
                                padding: const EdgeInsets.only(top: 5, left: 8),
                                child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      orderDetailsResponse == null ||
                                              orderDetailsResponse.listResult ==
                                                  null
                                          ? ""
                                          : orderDetailsResponse.listResult[0]
                                              .billingAddress.inCapsO,
                                      style: TextStyle(
                                          color: Constants.greyColor,
                                          // fontWeight: FontWeight.w600,
                                          fontSize: 11),
                                      overflow: TextOverflow.clip,
                                    )),
                              ),
                        Divider(
                          color: Constants.lightgreyColor,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 2, left: 8),
                          child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                'Shipping Address',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 12),
                              )),
                        ),
                        orderDetailsResponse.listResult == null ||
                                orderDetailsResponse
                                        .listResult[0].shippingAddress ==
                                    null
                            ? Container()
                            : Padding(
                                padding: const EdgeInsets.only(top: 5, left: 8),
                                child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      orderDetailsResponse == null ||
                                              orderDetailsResponse.listResult ==
                                                  null
                                          ? ""
                                          : orderDetailsResponse.listResult[0]
                                              .shippingAddress.inCapsO,
                                      style: TextStyle(
                                          color: Constants.greyColor,
                                          // fontWeight: FontWeight.w600,
                                          fontSize: 11),
                                      overflow: TextOverflow.clip,
                                    )),
                              ),
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Divider(
                      color: Constants.lightgreyColor,
                      // thickness: 0.5,
                    ),
                  ]),
                ),
          bottomNavigationBar: orderDetailsResponse.listResult != null
              ? Stack(children: <Widget>[
                  Container(
                    height: bottomHeight,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey[300]),
                    ),
                    child: Column(
                      children: [
                        priceDetails(),
                        Divider(),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              // height: 48,
                              child: Column(
                                children: <Widget>[],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Container(
                                child: RaisedButton(
                                  color: Constants.appColor,
                                  child: Text(
                                    'Download Invoice',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  onPressed: () async {
                                    print('Satustype id' +
                                        statusTypeID.toString());

                                    if (Platform.isAndroid) {
                                      final status =
                                          await Permission.storage.request();

                                      if (status.isGranted) {
                                        api.globalToast('Invoice Downloaded');

                                        final externalDir =
                                            await getExternalStorageDirectory();

                                        final id =
                                            await FlutterDownloader.enqueue(
                                          // url : "http://183.82.111.111/RupdarshiFileRepository/FileRepository/2020/09/23/Invoice/20200923022144050.pdf",
                                          url: this.widget.fileLocation,
                                          savedDir: externalDir.path,
                                          showNotification: true,
                                          fileName: 'invoice',
                                          openFileFromNotification: true,
                                        );
                                      } else {
                                        print('Permission denied');
                                      }
                                    } else {
                                      print("this is not available in iOS");

                                      Navigator.of(context).push(
                                          new MaterialPageRoute(
                                              builder: (context) => new PdfApp(
                                                  pdfURL: this
                                                      .widget
                                                      .fileLocation)));
                                    }
                                  },
                                ),
                              ),
                            )
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
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.only(top: 10, right: 10, left: 10),
            child: Column(
              children: <Widget>[
                Divider(
                  color: Colors.grey[400],
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 5),
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
                              '(' + totalQTY.toString(),
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
                                  fontWeight: FontWeight.w600),
                              overflow: TextOverflow.clip,
                            ),
                          ],
                        ),
                        Text(
                          '₹ ' +
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
                  padding: const EdgeInsets.only(bottom: 5),
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
                              '- ₹ ' +
                                  dicountvalue
                                      .toStringAsFixed(2)
                                      .replaceAllMapped(reg, mathFunc),
                              style: TextStyle(
                                  color: Constants.blackColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600),
                            ),
                            Text(
                              ' (' + this.widget.discount.toString() + '%)',
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
                  padding: const EdgeInsets.only(bottom: 5),
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
                          '₹ ' +
                              gstPrice
                                  .toStringAsFixed(2)
                                  .replaceAllMapped(reg, mathFunc),
                          // '₹ ' + gstPrice.toStringAsFixed(0),
                          style: TextStyle(
                              color: Constants.blackColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        )
                      ]),
                ),

                Padding(
                  padding: const EdgeInsets.only(bottom: 5),
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
                Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'Total',
                          style: TextStyle(
                              color: Constants.blackColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                        ),
                        Text(
                          this
                              .widget
                              .totalPrice
                              .toStringAsFixed(2)
                              .replaceAllMapped(reg, mathFunc),
                          style: TextStyle(
                              color: Constants.blackColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                        )
                      ]),
                ),
                //  SizedBox(height: 5,),
                Divider(
                  color: Colors.grey[400],
                ),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //  crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Payable Amount',
                        style: TextStyle(
                            color: Constants.blackColor,
                            // fontSize: 12,
                            fontWeight: FontWeight.w700),
                        overflow: TextOverflow.ellipsis,
                      ),
                      // Text(
                      //   this.widget.payableAmount == null
                      //       ? '₹ 0.0'
                      //       : '₹ ' +
                      //           this
                      //               .widget
                      //               .totalPrice
                      //               .toStringAsFixed(2)
                      //               .replaceAllMapped(reg, mathFunc),
                      //   style: TextStyle(
                      //       color: Constants.blackColor,
                      //       // fontSize: 12,
                      //       fontWeight: FontWeight.bold),
                      // )

                      Text(
                        this.widget.payableAmount.toString(),
                        style: TextStyle(
                            color: Constants.blackColor,
                            // fontSize: 12,

                            fontWeight: FontWeight.bold),
                      )
                    ]),
              ],
            ),
          ),
        ));
  }

  Widget ordersDetails() {
    return Column(
      children: <Widget>[
        shippedorderDetails.length <= 0
            ? Container()
            : Card(
                child: Container(
                  // color: Colors.red,
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Shipped Item " +
                                      "(" +
                                      shippedorderDetails.length.toString() +
                                      ")",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Constants.blackColor,
                                      fontSize: 13.0),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: GestureDetector(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                    padding: const EdgeInsets.all(1.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          border: Border.all(
                                              color: Constants.appColor)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Text(
                                          "Received",
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Constants.appColor,
                                              fontWeight: FontWeight.w600),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  String idsString = "";
                                  List<int> idsArry = [];
                                  print(
                                      'Satustype id' + statusTypeID.toString());
                                  setState(() {
                                    statusTypeID = 14;

                                    print(statusTypeID);
                                  });

                                  for (int i = 0;
                                      i < shippedorderDetails.length;
                                      i++) {
                                    idsArry.add(shippedorderDetails[i].id);
                                  }

                                  idsString = idsArry
                                      .map((i) => i.toString())
                                      .join(",");

                                  print(idsString);

                                  showAlertDialog(
                                      context,
                                      idsString,
                                      shippedorderDetails[0].orderId,
                                      statusTypeID,
                                      "received order");
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        color: Constants.lightgreyColor,
                        // thickness: 0.5,
                      ),
                      ListView.builder(
                          shrinkWrap: true,
                          physics: ClampingScrollPhysics(),
                          itemCount: shippedorderDetails.length,
                          itemBuilder: (BuildContext context, int index) {
                            var size = MediaQuery.of(context).size;
                            final double itemHeight = (size.height) / 11;
                            final double itemWidth = size.width / 8;
                            //  discountedPrice = value.wholeSalePrice * (value.discount);
                            //         totalPrice = value.wholeSalePrice - discountedPrice;
                            return Container(
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      GestureDetector(
                                        onTap: () {},
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            width: itemWidth,
                                            height: itemHeight,
                                            child: ClipRRect(
                                                child: shippedorderDetails[
                                                                index]
                                                            .filePath !=
                                                        null
                                                    ? CachedNetworkImage(
                                                        fit: BoxFit.cover,
                                                        imageUrl:
                                                            // 'http://183.82.111.111/RupdarshiFileRepository/FileRepository/' +
                                                            shippedorderDetails[
                                                                    index]
                                                                .filePath,
                                                        placeholder: (context,
                                                                url) =>
                                                            Center(
                                                                child:
                                                                    Container(
                                                          height: 20,
                                                          width: 20,
                                                          child:
                                                              CircularProgressIndicator(),
                                                        )),
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            new Image.asset(
                                                                'assets/Rupdarshi.jpg'),
                                                      )
                                                    : Image.asset(
                                                        'assets/Rupdarshi.jpg')),
                                          ),
                                        ),
                                      ),

                                      // SizedBox(width: 10),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            // crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      shippedorderDetails[index]
                                                          .name,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Constants
                                                              .blackColor,
                                                          fontSize: 11.0),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 4,
                                                    ),
                                                  ),
                                                  shippedorderDetails[index]
                                                              .price !=
                                                          null
                                                      ? Row(
                                                          // mainAxisAlignment:
                                                          //     MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Text(
                                                              "₹ " +
                                                                  ((shippedorderDetails[index]
                                                                              .price) *
                                                                          (shippedorderDetails[index]
                                                                              .quantity))
                                                                      .toStringAsFixed(
                                                                          2)
                                                                      .replaceAllMapped(
                                                                          reg,
                                                                          mathFunc),
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color: Constants
                                                                      .blackColor,
                                                                  fontSize:
                                                                      11.0),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxLines: 2,
                                                            ),
                                                          ],
                                                        )
                                                      : Container(),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      shippedorderDetails[index]
                                                                  .colour !=
                                                              null
                                                          ? Row(
                                                              children: [
                                                                shippedorderDetails[index]
                                                                            .colour !=
                                                                        null
                                                                    ? Text(
                                                                        shippedorderDetails[index]
                                                                            .colour,
                                                                        style: TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                            color: Constants.blackColor,
                                                                            fontSize: 11.0),
                                                                      )
                                                                    : "",
                                                                shippedorderDetails[index]
                                                                            .size !=
                                                                        null
                                                                    ? Text(
                                                                        " - ",
                                                                        style: TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                            color: Constants.blackColor,
                                                                            fontSize: 11.0),
                                                                      )
                                                                    : Container(),
                                                                Text(
                                                                  shippedorderDetails[index]
                                                                              .size !=
                                                                          null
                                                                      ? shippedorderDetails[
                                                                              index]
                                                                          .size
                                                                      : "",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      color: Constants
                                                                          .blackColor,
                                                                      fontSize:
                                                                          11.0),
                                                                ),
                                                              ],
                                                            )
                                                          : Container(),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: <Widget>[
                                                  shippedorderDetails[index]
                                                              .quantity !=
                                                          null
                                                      ? Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Row(
                                                              children: <
                                                                  Widget>[
                                                                Text(
                                                                  "Qty: ",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      color: Constants
                                                                          .blackColor,
                                                                      fontSize:
                                                                          11.0),
                                                                ),
                                                                Text(
                                                                  shippedorderDetails[
                                                                          index]
                                                                      .quantity
                                                                      .toString(),
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      color: Constants
                                                                          .blackColor,
                                                                      fontSize:
                                                                          11.0),
                                                                ),
                                                              ],
                                                            ),
                                                            shippedorderDetails[index]
                                                                            .statusTypeId ==
                                                                        11 ||
                                                                    shippedorderDetails[index]
                                                                            .statusTypeId ==
                                                                        12
                                                                ? Column(
                                                                    children: [
                                                                      Container(
                                                                        child:
                                                                            Padding(
                                                                          padding:
                                                                              const EdgeInsets.only(left: 4.0),
                                                                          child:
                                                                              Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceBetween,
                                                                            children: <Widget>[],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        height:
                                                                            5,
                                                                      )
                                                                    ],
                                                                  )
                                                                : Container(),
                                                          ],
                                                        )
                                                      : Container(),
                                                  GestureDetector(
                                                    child: Align(
                                                      alignment:
                                                          Alignment.centerRight,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(1.0),
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                              shape: BoxShape
                                                                  .rectangle,
                                                              border: Border.all(
                                                                  color: Constants
                                                                      .appColor)),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(5.0),
                                                            child: Text(
                                                              "Received",
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  color: Constants
                                                                      .appColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    onTap: () {
                                                      print('Satustype id' +
                                                          statusTypeID
                                                              .toString());
                                                      setState(() {
                                                        statusTypeID = 14;

                                                        print(statusTypeID);
                                                      });

                                                      showAlertDialog(
                                                          context,
                                                          shippedorderDetails[
                                                                  index]
                                                              .id
                                                              .toString(),
                                                          shippedorderDetails[0]
                                                              .orderId,
                                                          statusTypeID,
                                                          "received item");
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8.0, right: 8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        GestureDetector(
                                          child: Text("Track shipment",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: Constants.appColor,
                                                  fontSize: 13.0)),
                                          onTap: () {
                                            trackShipmetHistoryAPI(
                                                shippedorderDetails[index].id,
                                                shippedorderDetails[index]
                                                    .statusTypeId);
                                          },
                                        ),
                                        GestureDetector(
                                          child: Text("Shipment receipt",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: Constants.appColor,
                                                  fontSize: 13.0)),
                                          onTap: () {
                                            if (shippedorderDetails[0]
                                                    .shippingId !=
                                                null) {
                                              getShipmetReceiptAPICall(
                                                  shippedorderDetails[0]
                                                      .shippingId);
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  Divider(
                                    color: Constants.lightgreyColor,
                                    // thickness: 0.5,
                                  ),
                                ],
                              ),
                            );
                          }),
                    ],
                  ),
                ),
              ),
        confirmedorderDetails.length <= 0
            ? Container()
            : Card(
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                  "Confirmed Item " +
                                      "(" +
                                      confirmedorderDetails.length.toString() +
                                      ")",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Constants.blackColor,
                                      fontSize: 13.0)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: GestureDetector(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Padding(
                                  padding: const EdgeInsets.all(1.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        border: Border.all(
                                            color: Constants.appColor)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Text(
                                        'Cancel order',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Constants.appColor,
                                            fontWeight: FontWeight.w600),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              onTap: () {
                                String idsString = "";
                                List<int> idsArry = [];
                                print('Satustype id' + statusTypeID.toString());
                                setState(() {
                                  statusTypeID = 13;

                                  print(confirmedorderDetails[0].statusTypeId);
                                  print(statusTypeID);
                                });

                                for (int i = 0;
                                    i < confirmedorderDetails.length;
                                    i++) {
                                  idsArry.add(confirmedorderDetails[i].id);
                                }

                                idsString =
                                    idsArry.map((i) => i.toString()).join(",");
                                print(idsString);

                                showAlertDialog(
                                    context,
                                    idsString,
                                    confirmedorderDetails[0].orderId,
                                    statusTypeID,
                                    "cancel order");
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      color: Constants.lightgreyColor,
                      // thickness: 0.5,
                    ),
                    ListView.builder(
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        itemCount: confirmedorderDetails.length,
                        itemBuilder: (BuildContext context, int index) {
                          var size = MediaQuery.of(context).size;
                          final double itemHeight = (size.height) / 11;
                          final double itemWidth = size.width / 8;
                          //  discountedPrice = value.wholeSalePrice * (value.discount);
                          //         totalPrice = value.wholeSalePrice - discountedPrice;
                          return Container(
                            child: Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    GestureDetector(
                                      onTap: () {},
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          width: itemWidth,
                                          height: itemHeight,
                                          child: ClipRRect(
                                              child: confirmedorderDetails[
                                                              index]
                                                          .filePath !=
                                                      null
                                                  ? CachedNetworkImage(
                                                      fit: BoxFit.cover,
                                                      imageUrl:
                                                          // 'http://183.82.111.111/RupdarshiFileRepository/FileRepository/' +
                                                          confirmedorderDetails[
                                                                  index]
                                                              .filePath,
                                                      placeholder: (context,
                                                              url) =>
                                                          Center(
                                                              child: Container(
                                                        height: 20,
                                                        width: 20,
                                                        child:
                                                            CircularProgressIndicator(),
                                                      )),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          new Image.asset(
                                                              'assets/Rupdarshi.jpg'),
                                                    )
                                                  : Image.asset(
                                                      'assets/Rupdarshi.jpg')),
                                        ),
                                      ),
                                    ),

                                    // SizedBox(width: 10),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          // crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    confirmedorderDetails[index]
                                                        .name,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Constants
                                                            .blackColor,
                                                        fontSize: 11.0),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 4,
                                                  ),
                                                ),
                                                confirmedorderDetails[index]
                                                            .price !=
                                                        null
                                                    ? Row(
                                                        // mainAxisAlignment:
                                                        //     MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Text(
                                                            "₹ " +
                                                                ((confirmedorderDetails[index]
                                                                            .price) *
                                                                        (confirmedorderDetails[index]
                                                                            .quantity))
                                                                    .toStringAsFixed(
                                                                        2)
                                                                    .replaceAllMapped(
                                                                        reg,
                                                                        mathFunc),
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: Constants
                                                                    .blackColor,
                                                                fontSize: 11.0),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 2,
                                                          ),
                                                        ],
                                                      )
                                                    : Container(),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    confirmedorderDetails[index]
                                                                .colour !=
                                                            null
                                                        ? Row(
                                                            children: [
                                                              confirmedorderDetails[
                                                                              index]
                                                                          .colour !=
                                                                      null
                                                                  ? Text(
                                                                      confirmedorderDetails[
                                                                              index]
                                                                          .colour,
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .w500,
                                                                          color: Constants
                                                                              .blackColor,
                                                                          fontSize:
                                                                              11.0),
                                                                    )
                                                                  : "",
                                                              confirmedorderDetails[
                                                                              index]
                                                                          .size !=
                                                                      null
                                                                  ? Text(
                                                                      " - ",
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .w500,
                                                                          color: Constants
                                                                              .blackColor,
                                                                          fontSize:
                                                                              11.0),
                                                                    )
                                                                  : Container(),
                                                              Text(
                                                                confirmedorderDetails[index]
                                                                            .size !=
                                                                        null
                                                                    ? confirmedorderDetails[
                                                                            index]
                                                                        .size
                                                                    : "",
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color: Constants
                                                                        .blackColor,
                                                                    fontSize:
                                                                        11.0),
                                                              ),
                                                            ],
                                                          )
                                                        : Container(),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                confirmedorderDetails[index]
                                                            .quantity !=
                                                        null
                                                    ? Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Row(
                                                            children: <Widget>[
                                                              Text(
                                                                "Qty: ",
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    color: Constants
                                                                        .blackColor,
                                                                    fontSize:
                                                                        11.0),
                                                              ),
                                                              Text(
                                                                confirmedorderDetails[
                                                                        index]
                                                                    .quantity
                                                                    .toString(),
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    color: Constants
                                                                        .blackColor,
                                                                    fontSize:
                                                                        11.0),
                                                              ),
                                                            ],
                                                          ),
                                                          confirmedorderDetails[
                                                                              index]
                                                                          .statusTypeId ==
                                                                      11 ||
                                                                  confirmedorderDetails[
                                                                              index]
                                                                          .statusTypeId ==
                                                                      12
                                                              ? Column(
                                                                  children: [
                                                                    Container(
                                                                      //  height: 50,
                                                                      // color:
                                                                      //     Constants.statusBGColor,
                                                                      child:
                                                                          Padding(
                                                                        padding:
                                                                            const EdgeInsets.only(left: 4.0),
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: <
                                                                              Widget>[],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      height: 5,
                                                                    )
                                                                  ],
                                                                )
                                                              : Container(),
                                                        ],
                                                      )
                                                    : Container(),
                                                GestureDetector(
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              1.0),
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                            shape: BoxShape
                                                                .rectangle,
                                                            border: Border.all(
                                                                color: Constants
                                                                    .appColor)),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(5.0),
                                                          child: Text(
                                                            'Cancel Item',
                                                            style: TextStyle(
                                                                fontSize: 12,
                                                                color: Constants
                                                                    .appColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    print('Satustype id' +
                                                        statusTypeID
                                                            .toString());
                                                    setState(() {
                                                      statusTypeID = 13;

                                                      print(
                                                          confirmedorderDetails[
                                                                  0]
                                                              .statusTypeId);
                                                      print(statusTypeID);
                                                    });

                                                    showAlertDialog(
                                                        context,
                                                        confirmedorderDetails[
                                                                index]
                                                            .id
                                                            .toString(),
                                                        confirmedorderDetails[0]
                                                            .orderId,
                                                        statusTypeID,
                                                        "cancel item");
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Align(
                                    alignment: Alignment.bottomLeft,
                                    child: GestureDetector(
                                      child: Text("Track shipment",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Constants.appColor,
                                              fontSize: 13.0)),
                                      onTap: () {
                                        trackShipmetHistoryAPI(
                                            confirmedorderDetails[index].id,
                                            confirmedorderDetails[index]
                                                .statusTypeId);
                                      },
                                    ),
                                  ),
                                ),
                                Divider(
                                  color: Constants.lightgreyColor,
                                  // thickness: 0.5,
                                ),
                              ],
                            ),
                          );
                        }),
                  ],
                ),
              ),
        canceledorderDetails.length <= 0
            ? Container()
            : Card(
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                              "Canceled Item " +
                                  "(" +
                                  canceledorderDetails.length.toString() +
                                  ")",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Constants.blackColor,
                                  fontSize: 13.0)),
                        ),
                      ),
                    ),
                    Divider(
                      color: Constants.lightgreyColor,
                      // thickness: 0.5,
                    ),
                    ListView.builder(
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        itemCount: canceledorderDetails.length,
                        itemBuilder: (BuildContext context, int index) {
                          var size = MediaQuery.of(context).size;
                          final double itemHeight = (size.height) / 11;
                          final double itemWidth = size.width / 8;
                          //  discountedPrice = value.wholeSalePrice * (value.discount);
                          //         totalPrice = value.wholeSalePrice - discountedPrice;
                          return Container(
                            child: Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    GestureDetector(
                                      onTap: () {},
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          width: itemWidth,
                                          height: itemHeight,
                                          child: ClipRRect(
                                              child: canceledorderDetails[index]
                                                          .filePath !=
                                                      null
                                                  ? CachedNetworkImage(
                                                      fit: BoxFit.cover,
                                                      imageUrl:
                                                          // 'http://183.82.111.111/RupdarshiFileRepository/FileRepository/' +
                                                          canceledorderDetails[
                                                                  index]
                                                              .filePath,
                                                      placeholder: (context,
                                                              url) =>
                                                          Center(
                                                              child: Container(
                                                        height: 20,
                                                        width: 20,
                                                        child:
                                                            CircularProgressIndicator(),
                                                      )),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          new Image.asset(
                                                              'assets/Rupdarshi.jpg'),
                                                    )
                                                  : Image.asset(
                                                      'assets/Rupdarshi.jpg')),
                                        ),
                                      ),
                                    ),

                                    // SizedBox(width: 10),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          // crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    // "Saaree dfjkfdkf rfjrdfgrjgvk clvckljckl dfd clvjckljl",
                                                    canceledorderDetails[index]
                                                        .name,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Constants
                                                            .blackColor,
                                                        fontSize: 11.0),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 4,
                                                  ),
                                                ),
                                                canceledorderDetails[index]
                                                            .price !=
                                                        null
                                                    ? Row(
                                                        // mainAxisAlignment:
                                                        //     MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Text(
                                                            "₹ " +
                                                                ((canceledorderDetails[index]
                                                                            .price) *
                                                                        (canceledorderDetails[index]
                                                                            .quantity))
                                                                    .toStringAsFixed(
                                                                        2)
                                                                    .replaceAllMapped(
                                                                        reg,
                                                                        mathFunc),
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: Constants
                                                                    .blackColor,
                                                                fontSize: 11.0),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 2,
                                                          ),
                                                        ],
                                                      )
                                                    : Container(),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    canceledorderDetails[index]
                                                                .colour !=
                                                            null
                                                        ? Row(
                                                            children: [
                                                              canceledorderDetails[
                                                                              index]
                                                                          .colour !=
                                                                      null
                                                                  ? Text(
                                                                      canceledorderDetails[
                                                                              index]
                                                                          .colour,
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .w500,
                                                                          color: Constants
                                                                              .blackColor,
                                                                          fontSize:
                                                                              11.0),
                                                                    )
                                                                  : "",
                                                              canceledorderDetails[
                                                                              index]
                                                                          .size !=
                                                                      null
                                                                  ? Text(
                                                                      " - ",
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .w500,
                                                                          color: Constants
                                                                              .blackColor,
                                                                          fontSize:
                                                                              11.0),
                                                                    )
                                                                  : Container(),
                                                              Text(
                                                                canceledorderDetails[index]
                                                                            .size !=
                                                                        null
                                                                    ? canceledorderDetails[
                                                                            index]
                                                                        .size
                                                                    : "",
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color: Constants
                                                                        .blackColor,
                                                                    fontSize:
                                                                        11.0),
                                                              ),
                                                            ],
                                                          )
                                                        : Container(),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            canceledorderDetails[index]
                                                        .quantity !=
                                                    null
                                                ? Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Row(
                                                        children: <Widget>[
                                                          Text(
                                                            "Qty: ",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                color: Constants
                                                                    .blackColor,
                                                                fontSize: 11.0),
                                                          ),
                                                          Text(
                                                            canceledorderDetails[
                                                                    index]
                                                                .quantity
                                                                .toString(),
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: Constants
                                                                    .blackColor,
                                                                fontSize: 11.0),
                                                          ),
                                                        ],
                                                      ),
                                                      canceledorderDetails[
                                                                          index]
                                                                      .statusTypeId ==
                                                                  11 ||
                                                              canceledorderDetails[
                                                                          index]
                                                                      .statusTypeId ==
                                                                  12
                                                          ? Column(
                                                              children: [
                                                                Container(
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            4.0),
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: <
                                                                          Widget>[],
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: 5,
                                                                )
                                                              ],
                                                            )
                                                          : Container(),
                                                    ],
                                                  )
                                                : Container(),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Align(
                                    alignment: Alignment.bottomLeft,
                                    child: GestureDetector(
                                      child: Text("Track shipment",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Constants.appColor,
                                              fontSize: 13.0)),
                                      onTap: () {
                                        trackShipmetHistoryAPI(
                                            canceledorderDetails[index].id,
                                            canceledorderDetails[index]
                                                .statusTypeId);
                                      },
                                    ),
                                  ),
                                ),
                                Divider(
                                  color: Constants.lightgreyColor,
                                  // thickness: 0.5,
                                ),
                              ],
                            ),
                          );
                        }),
                    Container(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
        deliverdorderDetails.length <= 0
            ? Container()
            : Card(
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                              "Delivered Item " +
                                  "(" +
                                  deliverdorderDetails.length.toString() +
                                  ")",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Constants.blackColor,
                                  fontSize: 13.0)),
                        ),
                      ),
                    ),
                    Divider(
                      color: Constants.lightgreyColor,
                      // thickness: 0.5,
                    ),
                    ListView.builder(
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        itemCount: deliverdorderDetails.length,
                        itemBuilder: (BuildContext context, int index) {
                          var size = MediaQuery.of(context).size;
                          final double itemHeight = (size.height) / 11;
                          final double itemWidth = size.width / 8;
                          //  discountedPrice = value.wholeSalePrice * (value.discount);
                          //         totalPrice = value.wholeSalePrice - discountedPrice;
                          return Container(
                            child: Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    GestureDetector(
                                      onTap: () {},
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          width: itemWidth,
                                          height: itemHeight,
                                          child: ClipRRect(
                                              child: deliverdorderDetails[index]
                                                          .filePath !=
                                                      null
                                                  ? CachedNetworkImage(
                                                      fit: BoxFit.cover,
                                                      imageUrl:
                                                          // 'http://183.82.111.111/RupdarshiFileRepository/FileRepository/' +
                                                          deliverdorderDetails[
                                                                  index]
                                                              .filePath,
                                                      placeholder: (context,
                                                              url) =>
                                                          Center(
                                                              child: Container(
                                                        height: 20,
                                                        width: 20,
                                                        child:
                                                            CircularProgressIndicator(),
                                                      )),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          new Image.asset(
                                                              'assets/Rupdarshi.jpg'),
                                                    )
                                                  : Image.asset(
                                                      'assets/Rupdarshi.jpg')),
                                        ),
                                      ),
                                    ),

                                    // SizedBox(width: 10),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          // crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    // "Saaree dfjkfdkf rfjrdfgrjgvk clvckljckl dfd clvjckljl",
                                                    deliverdorderDetails[index]
                                                        .name,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Constants
                                                            .blackColor,
                                                        fontSize: 11.0),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 4,
                                                  ),
                                                ),
                                                deliverdorderDetails[index]
                                                            .price !=
                                                        null
                                                    ? Row(
                                                        // mainAxisAlignment:
                                                        //     MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Text(
                                                            "₹ " +
                                                                ((deliverdorderDetails[index]
                                                                            .price) *
                                                                        (deliverdorderDetails[index]
                                                                            .quantity))
                                                                    .toStringAsFixed(
                                                                        2)
                                                                    .replaceAllMapped(
                                                                        reg,
                                                                        mathFunc),
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: Constants
                                                                    .blackColor,
                                                                fontSize: 11.0),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 2,
                                                          ),
                                                        ],
                                                      )
                                                    : Container(),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    deliverdorderDetails[index]
                                                                .colour !=
                                                            null
                                                        ? Row(
                                                            children: [
                                                              deliverdorderDetails[
                                                                              index]
                                                                          .colour !=
                                                                      null
                                                                  ? Text(
                                                                      deliverdorderDetails[
                                                                              index]
                                                                          .colour,
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .w500,
                                                                          color: Constants
                                                                              .blackColor,
                                                                          fontSize:
                                                                              11.0),
                                                                    )
                                                                  : "",
                                                              deliverdorderDetails[
                                                                              index]
                                                                          .size !=
                                                                      null
                                                                  ? Text(
                                                                      " - ",
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .w500,
                                                                          color: Constants
                                                                              .blackColor,
                                                                          fontSize:
                                                                              11.0),
                                                                    )
                                                                  : Container(),
                                                              Text(
                                                                deliverdorderDetails[index]
                                                                            .size !=
                                                                        null
                                                                    ? deliverdorderDetails[
                                                                            index]
                                                                        .size
                                                                    : "",
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color: Constants
                                                                        .blackColor,
                                                                    fontSize:
                                                                        11.0),
                                                              ),
                                                            ],
                                                          )
                                                        : Container(),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            deliverdorderDetails[index]
                                                        .quantity !=
                                                    null
                                                ? Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Row(
                                                        children: <Widget>[
                                                          Text(
                                                            "Qty: ",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                color: Constants
                                                                    .blackColor,
                                                                fontSize: 11.0),
                                                          ),
                                                          Text(
                                                            deliverdorderDetails[
                                                                    index]
                                                                .quantity
                                                                .toString(),
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: Constants
                                                                    .blackColor,
                                                                fontSize: 11.0),
                                                          ),
                                                        ],
                                                      ),
                                                      deliverdorderDetails[
                                                                          index]
                                                                      .statusTypeId ==
                                                                  11 ||
                                                              deliverdorderDetails[
                                                                          index]
                                                                      .statusTypeId ==
                                                                  12
                                                          ? Column(
                                                              children: [
                                                                Container(
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            4.0),
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: <
                                                                          Widget>[],
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: 5,
                                                                )
                                                              ],
                                                            )
                                                          : Container(),
                                                    ],
                                                  )
                                                : Container(),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        child: Text("Track shipment",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: Constants.appColor,
                                                fontSize: 13.0)),
                                        onTap: () {
                                          trackShipmetHistoryAPI(
                                              deliverdorderDetails[index].id,
                                              deliverdorderDetails[index]
                                                  .statusTypeId);
                                        },
                                      ),
                                      GestureDetector(
                                        child: Text("Shipment receipt",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: Constants.appColor,
                                                fontSize: 13.0)),
                                        onTap: () {
                                          if (deliverdorderDetails[0]
                                                  .shippingId !=
                                              null) {
                                            getShipmetReceiptAPICall(
                                                deliverdorderDetails[0]
                                                    .shippingId);
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(
                                  color: Constants.lightgreyColor,
                                  // thickness: 0.5,
                                ),
                              ],
                            ),
                          );
                        }),
                  ],
                ),
              ),
      ],
    );
  }

  void _updateOrderDetails(String itemID, int orderID, int statusID) async {
    var baseurl = ApiService.baseUrl;
    var url = baseurl + ApiService.updateOrderStatus;

    print(url);
    Map data = {
      "ItemIds": itemID,
      "OrderId": orderID,
      "StatusTypeId": statusID
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
        // Navigator.of(context, rootNavigator: true).pop();
        if (data['IsSuccess'] == true) {
          api.globalToast(data['EndUserMessage']);
          Navigator.of(context, rootNavigator: true).pop();
          Navigator.of(context).push(
              new MaterialPageRoute(builder: (context) => new MyOrderScreen()));
        } else {
          setState(() {
            // _state = 1;
          });
          api.globalToast(data['EndUserMessage']);
        }
      } else {
        setState(() {
          // _state = 1;
        });
        api.globalToast('Something went wrong ..');
      }
    });
  }

  paymentModeAPICall() {
    String paymentURL = ApiService.baseUrl + ApiService.getPaymentModeURL;

    Map<String, dynamic> parameters = {"Id": paymentID, "IsActive": true};

    api.postAPICall(paymentURL, parameters).then((response) {
      print(response);
      if (response["IsSuccess"] == true) {
        paymentModeResponse = PaymentModeResponse.fromJson(response);
        print('Payement totalPrice ' + totalPrice.toString());

        for (int i = 0; i < paymentModeResponse.listResult.length; i++) {
          discountPercentage = paymentModeResponse.listResult[i].discount;
          paymentDiscount =
              paymentModeResponse.listResult[i].discount.toDouble();
          dicountvalue = ((totalPrice / 100) * this.widget.discount);
        }
        setState(() {});
      }
    });
  }

  getOrderDetailsAPICall(int orderId) async {
    String finalUrl =
        ApiService.baseUrl + ApiService.getorderDetails + orderId.toString();
    print(" OrderDetailslUrl -- > " + finalUrl);

    await api.orderDetailsApiCall(finalUrl).then((response) {
      print(" GetOrdersByOrderID -- > " + response.toString());
      setState(() {
        firstLoading = false;
        orderDetailsResponse = OrderDetailsResponse.fromJson(response);

        print(" VenderAddressResponse -- > " +
            orderDetailsResponse.toJson().toString());

        _elements = response["ListResult"];

        if (orderDetailsResponse != null) {
          orderDetails = orderDetailsResponse.listResult;
        }

        double productCost = 0.0;
        double gstTotPrice = 0.0;
        int totalQtyIndex = 0;
        for (int i = 0; i < orderDetailsResponse.listResult.length; i++) {
          if (orderDetailsResponse.listResult[i].statusTypeId == 11) {
            confirmedorderDetails.add(orderDetailsResponse.listResult[i]);
          } else if (orderDetailsResponse.listResult[i].statusTypeId == 12) {
            shippedorderDetails.add(orderDetailsResponse.listResult[i]);
          } else if (orderDetailsResponse.listResult[i].statusTypeId == 13) {
            canceledorderDetails.add(orderDetailsResponse.listResult[i]);
          } else {
            deliverdorderDetails.add(orderDetailsResponse.listResult[i]);
          }

          var finalPrie = 0.0;
          double item = orderDetailsResponse.listResult[i].price.toDouble() *
              orderDetailsResponse.listResult[i].quantity;
          productCost += item;

          double singleItemGST =
              (((orderDetailsResponse.listResult[i].price.toDouble()) /
                      100.00) *
                  orderDetailsResponse.listResult[i].gst.toDouble());
          print('g s t  g s t' + singleItemGST.toString());
          finalPrie = orderDetailsResponse.listResult[i].price + singleItemGST;

          // double aaa = (((orderDetailsResponse.listResult[i].price.toDouble()) /
          //             100.00) *
          //         orderDetailsResponse.listResult[i].gst.toDouble()) *
          //     orderDetailsResponse.listResult[i].quantity.toDouble();
          // gstPrice += aaa;
          totalQtyIndex += orderDetailsResponse.listResult[i].quantity;

          double disc =
              (((orderDetailsResponse.listResult[i].price.toDouble()) /
                          100.00) *
                      orderDetailsResponse.listResult[i].discount.toDouble()) *
                  orderDetailsResponse.listResult[i].quantity.toDouble();

          totalItemDiscount += disc;
          totalPrice = productCost;
          dicountvalue = ((totalPrice / 100) * this.widget.discount);
          double priceWithoutGST =
              totalPrice - (totalItemDiscount + dicountvalue);
          double aaa = (((priceWithoutGST) / 100.00) *
              orderDetailsResponse.listResult[i].gst.toDouble());

          gstPrice = aaa;
          print('totalItemDiscount ' + totalItemDiscount.toString());
        }
        totalPrice = productCost;
        totalQTY = totalQtyIndex;

        double bb = discountPercentage / 100 * totalPrice;
        totaldiscountPrice = totalPrice - bb;

        if (confirmedorderDetails.length > 0) {
          sections.add(confirmedorderDetails[0]);
        } else if (shippedorderDetails.length > 0) {
          sections.add(shippedorderDetails[0]);
        } else if (canceledorderDetails.length > 0) {
          sections.add(canceledorderDetails[0]);
        } else {
          sections.add(deliverdorderDetails[0]);
        }
        print("******************************");
        print(confirmedorderDetails.length.toString());
        print(shippedorderDetails.length.toString());
        print(canceledorderDetails.length.toString());
        print(deliverdorderDetails.length.toString());
        print("******************************");
      });
    });
  }

  getTrackDetailsAPICall(int orderId) async {
    String finalUrl =
        ApiService.baseUrl + ApiService.trackOrderHistory + orderId.toString();

    await api.getAPICall(finalUrl).then((response) {
      print(" TrackHistoryByOrderID -- > " + response.toString());
      setState(() {
        firstLoading = false;
        trackOrderResponse = TrackOrderResponse.fromJson(response);
      });
    });
  }

  getShipmetReceiptAPICall(int shippingID) async {
    String finalUrl =
        ApiService.baseUrl + ApiService.shippingReceipt + shippingID.toString();

    await api.getAPICall(finalUrl).then((response) {
      print(" ShippingReceiptResponse -- > " + response.toString());
      setState(() {
        shippingReceiptResponse = ShippingReceiptResponse.fromJson(response);
        if (shippingReceiptResponse.isSuccess == true) {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return SizedBox.expand(
                    child: Container(
                        color: Colors.white,
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: GestureDetector(
                                  child: Icon(Icons.close),
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                            ),
                            ClipRRect(
                                child: shippingReceiptResponse
                                            .result.filepath !=
                                        null
                                    ? CachedNetworkImage(
                                        // fit: BoxFit.contain,
                                        imageUrl: shippingReceiptResponse
                                            .result.filepath,
                                        // placeholder: (context, url) =>
                                        //     new CircularProgressIndicator(),
                                        errorWidget: (context, url, error) =>
                                            new Image.asset(
                                                'assets/Rupdarshi.jpg'),
                                      )
                                    : Image.asset('assets/Rupdarshi.jpg')),
                          ],
                        )));
              });
        }
      });
    });
  }

  showAlertDialog(BuildContext context, String itemId, int orderID,
      int statusType, String alertName) {
    // set up the button
    Widget okButton = FlatButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
        side: BorderSide(
          width: 1,
          color: Constants.appColor,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Text(
          "Yes",
          style: TextStyle(
            color: Constants.appColor,
            fontSize: 10.0,
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.clip,
        ),
      ),
      onPressed: () {
        setState(() {
          Navigator.of(context, rootNavigator: true).pop();
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return Center(
                  child: Container(
                    // color: Colors.red,
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(),
                  ),
                );
              });

          _updateOrderDetails(itemId, orderID, statusType);
          // Navigator.of(context, rootNavigator: true).pop();
        });
      },
    );

    Widget cancelButton = FlatButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
        side: BorderSide(
          width: 1,
          color: Constants.appColor,
        ),
      ),
      child: Text(
        "No",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Constants.appColor,
          fontSize: 10.0,
        ),
        overflow: TextOverflow.clip,
      ),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
    );

    // show the dialog
    showDialog(
        context: context,
        builder: (BuildContext context) {
          var size = MediaQuery.of(context).size;
          final double itemHeight = (size.height) / 4.5;
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)), //this right here
            child: Container(
              height: itemHeight,
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        widget.statusID == 11
                            ? alertName == "cancel item"
                                ? "Cancel item"
                                : "Cancel Order"
                            : widget.statusID == 12
                                ? "Confirm Delivery"
                                : "",
                        style: TextStyle(
                            color: Constants.appColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 14),
                        overflow: TextOverflow.clip,
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        widget.statusID == 11
                            ? 'Are you sure you want to ' + alertName + "?"
                            : widget.statusID == 12
                                ? 'Did you receive your ' + alertName + "?"
                                : "",
                        overflow: TextOverflow.clip,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Divider(color: Colors.black),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            cancelButton,
                            SizedBox(
                              width: 5,
                            ),
                            okButton,
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  bottomSheet(BuildContext bc, int statusType) {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (BuildContext bc) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.transparent, spreadRadius: 10),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Shipment Tracking',
                          style: TextStyle(
                              fontSize: 13,
                              color: Constants.blackColor,
                              fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    Divider(
                      color: Constants.lightgreyColor,
                      // thickness: 0.5,
                    ),
                    Container(
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: Row(
                              children: [
                                Theme(
                                  data: Theme.of(context).copyWith(
                                      unselectedWidgetColor: Colors.grey,
                                      disabledColor: Constants.appColor),
                                  child: Radio(
                                    activeColor: Colors.red,
                                    value: 0,
                                    groupValue: 0,
                                    onChanged: null,
                                    // onChanged: null
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 3,
                                    ),
                                    Text('Confirmed',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Constants.blackColor,
                                            fontSize: 12.0)),
                                    SizedBox(
                                      height: 3,
                                    ),
                                    trackHistoryResponse.result.confirmedDate !=
                                            null
                                        ? Text(
                                            formatter.format(
                                                trackHistoryResponse
                                                    .result.confirmedDate),
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: Constants.greyColor,
                                                fontSize: 9.0))
                                        : Container(),
                                    SizedBox(
                                      height: 3,
                                    ),
                                    Text('Your order confirmed successfully',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: Constants.greyColor,
                                            fontSize: 9.0)),
                                    Divider(
                                      color: Constants.appColor,

                                      // thickness: 0.5,
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 15.0),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Container(
                                  height: 30,
                                  child: VerticalDivider(
                                    color: Colors.grey[400],
                                    thickness: 2,
                                  )),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Theme(
                                  data: Theme.of(context).copyWith(
                                      unselectedWidgetColor: Colors.grey,
                                      disabledColor: Constants.appColor),
                                  child: Radio(
                                    activeColor: Colors.blue,
                                    value: 0,
                                    groupValue: statusType == 11 ? -1 : 0,
                                    onChanged: null,
                                    // onChanged: null
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        statusType == 13
                                            ? "Cancelled"
                                            : "Shipped",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Constants.blackColor,
                                            fontSize: 12.0)),
                                    SizedBox(
                                      height: 3,
                                    ),
                                    statusType == 12 || statusType == 14
                                        ? trackHistoryResponse
                                                    .result.shippedDate !=
                                                null
                                            ? Text(
                                                formatter.format(
                                                    trackHistoryResponse
                                                        .result.shippedDate),
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    color: Constants.greyColor,
                                                    fontSize: 9.0))
                                            : Container()
                                        : statusType == 13
                                            ? trackHistoryResponse
                                                        .result.cancelledDate !=
                                                    null
                                                ? Text(
                                                    formatter.format(
                                                        trackHistoryResponse
                                                            .result
                                                            .cancelledDate),
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color:
                                                            Constants.greyColor,
                                                        fontSize: 9.0))
                                                : Container()
                                            : Container(),
                                    SizedBox(
                                      height: 3,
                                    ),
                                    Text(
                                        statusType == 12 || statusType == 14
                                            ? "Your order shipped successfully"
                                            : statusType == 13
                                                ? "As per your request your order has been cancelled"
                                                : "",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: Constants.greyColor,
                                            fontSize: 9.0)),
                                  ],
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 15.0),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Container(
                                  height: 30,
                                  child: VerticalDivider(
                                    color: Colors.grey[400],
                                    thickness: 2,
                                  )),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Theme(
                                  data: Theme.of(context).copyWith(
                                      unselectedWidgetColor: Colors.grey,
                                      disabledColor: Constants.appColor),
                                  child: Radio(
                                    activeColor: Colors.blue,
                                    value: 0,
                                    groupValue: statusType == 14 ? 0 : -1,
                                    onChanged: null,
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Delivered',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Constants.greyColor,
                                            fontSize: 12.0)),
                                    SizedBox(
                                      height: 3,
                                    ),
                                    trackHistoryResponse.result.delivedDate !=
                                            null
                                        ? Text(
                                            formatter.format(
                                                trackHistoryResponse
                                                    .result.delivedDate),
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: Constants.greyColor,
                                                fontSize: 9.0))
                                        : Container(),
                                    SizedBox(
                                      height: 3,
                                    ),
                                    statusType == 14
                                        ? Text(
                                            'Your order has been delivered successfully',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: Constants.blackColor,
                                                fontSize: 9.0))
                                        : Container()
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  trackShipmetHistoryAPI(int itemID, int statusType) {
    String finalURL =
        ApiService.baseUrl + ApiService.trackHitoryURL + itemID.toString();

    print("trackHistoryURL - > " + finalURL);

    api.getAPICall(finalURL).then((response) {
      print("trackHistoryResponse - > " + response.toString());
      setState(() {
        if (response != null) {
          trackHistoryResponse = TrackHistoryResponse.fromJson(response);

          if (trackHistoryResponse.isSuccess == true) {
            bottomSheet(context, statusType);
          }
        }
      });
    });
  }

  void backnavigation() {
    Navigator.of(context).pop(true);
    Navigator.of(context).pushReplacement(
        new MaterialPageRoute(builder: (context) => new MyOrderScreen()));
  }
}

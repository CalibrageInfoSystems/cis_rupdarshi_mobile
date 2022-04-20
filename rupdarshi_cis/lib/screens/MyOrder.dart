import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:rupdarshi_cis/Model/GetCartResponse.dart';
import 'package:rupdarshi_cis/Model/GetOrdersResponse.dart';
import 'package:rupdarshi_cis/Model/StatusTypesResponse.dart';
import 'package:rupdarshi_cis/Service/ApiService.dart';
import 'package:rupdarshi_cis/common/Constants.dart';
import 'package:rupdarshi_cis/common/LocalDb.dart';
import 'package:rupdarshi_cis/common/SessionManager.dart';
import 'package:rupdarshi_cis/screens/AccountScreen.dart';
import 'package:rupdarshi_cis/screens/CartScreen.dart';

import 'package:progress_dialog/progress_dialog.dart';
import 'package:rupdarshi_cis/screens/NewHomeScreen.dart';
import 'package:rupdarshi_cis/screens/OrderDetails.dart';
import 'package:rupdarshi_cis/screens/WishList.dart';

extension CapExtension on String {
  String get inCapss => '${this[0].toUpperCase()}${this.substring(1)}';
  String get allInCapss => this.toUpperCase();
}

RegExp reg = new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
Function mathFunc = (Match match) => '${match[1]},';

final GlobalKey<State> _keyLoader = new GlobalKey<State>();
ProgressDialog pr;

class MyOrderScreen extends StatefulWidget {
  // final String userID;

  // const CartScreen({@required this.userID});
  @override
  _MyOrderScreenState createState() => _MyOrderScreenState();
}

class _MyOrderScreenState extends State<MyOrderScreen> {
  var formatter = new DateFormat("dd-MM-yyyy");
  int cartitemcount = 0;
  int oldIndex = 0;
  int ordersCount = 0;
  bool isStatuClicked = false;
  int statusTypeID = 0;
  bool firstLoading = true;
  GetOrdersResponse getOrdersResponse;
  StatusTypesResponse statusTypesResponse;
  List<StatusTypeListResult> statusTypeListResult;
  var discountedPrice = 0.0;
  var totalPrice = 0.0;
  bool islogin = false;
  ProgressDialog progressHud;
  ScrollController controller;
  LocalData localData = new LocalData();
  var _itemCount = 0;
  int loginUserID = 0;
  String userID;
  ApiService apiConnector;
  GetCartResponse getCartResponse;
  List<String> listCategory = new List();
  createCategoryList() {
    // listCategory.add("All orders");
  }

  refresh() {
    setState(() {
      print('Refresh Wishlist');
      localData.getIntToSF(LocalData.USERID).then((userid) {
        setState(() {
          loginUserID = userid;

          getCartDetails(userid.toString());
        });
      });
    });
  }

  @override
  void initState() {
    firstLoading = true;

    super.initState();
    initializeDateFormatting();
    formatter = new DateFormat("dd-MM-yyyy");
    ordersCount = 0;
    oldIndex = 0;
    cartitemcount = 0;
    createCategoryList();
    apiConnector = new ApiService();
    getOrdersResponse = new GetOrdersResponse();
    getCartResponse = new GetCartResponse();
    statusTypesResponse = new StatusTypesResponse();
    statusTypeListResult = new List<StatusTypeListResult>();
    SessionManager().getIsLogin().then((value) {
      islogin = value;
      print('is login new splash $islogin');
    });

    localData.getIntToSF(LocalData.USERID).then((userid) {
      setState(() {
        loginUserID = userid;
        getOrdersAPICall(loginUserID, null);
        print('USERid ' + loginUserID.toString());
        getCartDetails(loginUserID.toString());
      });
    });
    getstatusTypes();
  }

  getCartDetails(String userID) async {
    print(" selected Userid -- > " + loginUserID.toString());
    String finalUrl =
        ApiService.baseUrl + ApiService.getCartURL + loginUserID.toString();
    print(" finalUrl -- > " + finalUrl);
    await apiConnector.getCartApiCall(finalUrl).then((response) {
      print(" GetCartByUserID -- > " + response.toString());

      setState(() {
        getCartResponse = GetCartResponse.fromJson(response);
        if (getCartResponse != null && getCartResponse.result != null) {
          cartitemcount = getCartResponse.result.productsList.length;
          print(" QUANTITY -- > " + cartitemcount.toString());
          print("Home itemDetailsResponse -- > " +
              getCartResponse.result.productsList.length.toString());
        }
      });
    }).catchError((onError) {});
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double itemHeight = (size.height) / 4;
    final double itemWidth = size.width / 2;

    return WillPopScope(
      onWillPop: () {
        backnavigation();
      },
      child: DefaultTabController(
        length: 5,
        child: Scaffold(
          appBar: AppBar(
            title: Text('My Order',
                style: TextStyle(
                    color: Constants.blackColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 16),
                overflow: TextOverflow.ellipsis,
                maxLines: 1),
            backgroundColor: Constants.bgColor,
            leading: GestureDetector(
              onTap: () {
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => NewHomeScreen()));
              },
              child: Icon(
                Icons.keyboard_arrow_left,
                size: 35,
                color: Constants.greyColor, // add custom icons also
              ),
            ),
            actions: <Widget>[],
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
              : ordersCount == 0
                  ? Column(
                      children: [
                        categoryList(),
                        Container(
                            child: Center(
                          child: Column(
                            children: [
                              SizedBox(
                                height: 100,
                              ),
                              Image.asset(
                                'assets/Icons/No-products-icon.png',
                                height: itemHeight,
                                color: Constants.lightgreyColor,
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Text(
                                'No Orders Found',
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Constants.lightgreyColor),
                              ),
                              SizedBox(
                                height: 50,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Container(
                                  height: 45,
                                  width: itemWidth,
                                  child: RaisedButton(
                                    color: Constants.appColor,
                                    child: Text(
                                      "Go to Home",
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).push(
                                          new MaterialPageRoute(
                                              builder: (context) =>
                                                  new NewHomeScreen()));
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                      ],
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(children: <Widget>[
                        categoryList(),
                        ordersDetails(),
                      ]),
                    ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(0.0),
            child: Container(
              height: 55,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey[300]),
              ),
              child: Column(
                children: <Widget>[
                  Container(
                    child: new TabBar(
                      tabs: [
                        Tab(
                            child: Image.asset(
                          'assets/Icons/icons8-home-page-48.png',
                          height: 20,
                        )),
                        Tab(
                            child: Image.asset(
                          'assets/Icons/user-48.png',
                          height: 20,
                        )),
                        Tab(
                            child: Badge(
                          badgeColor: Colors.red,
                          badgeContent: Text(
                            cartitemcount.toString(),
                            style: TextStyle(fontSize: 12),
                          ),
                          child: Image.asset(
                            'assets/Icons/icons8-shopping-cart-48.png',
                            height: 22,
                          ),
                        )),
                        Tab(
                            child: Image.asset(
                          'assets/Icons/heart-48.png',
                          height: 20,
                          // color: Constants.appColor,
                        )),
                        Tab(
                            child: Image.asset(
                          'assets/Icons/notification-48.png',
                          height: 20,
                        )),
                      ],
                      labelColor: Colors.indigo,
                      unselectedLabelColor: Colors.grey,
                      indicatorSize: TabBarIndicatorSize.label,
                      // indicatorPadding: EdgeInsets.all(5.0),
                      indicator: UnderlineTabIndicator(
                          borderSide:
                              BorderSide(width: 3.5, color: Colors.white),
                          insets: EdgeInsets.symmetric(horizontal: 11.0)),
                      indicatorColor: Colors.black54,
                      onTap: (tabIndex) {
                        if (tabIndex == 0) {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => NewHomeScreen()));
                        } else if (tabIndex == 1) {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => AccountScreen()));
                        } else if (tabIndex == 2) {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  CartScreen(userID: loginUserID.toString())));
                        } else if (tabIndex == 3) {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => WishListScreen(
                                  userID: loginUserID.toString())));
                        } else if (tabIndex == 4) {}
                      },
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

  categoryList() {
    return Container(
      padding: EdgeInsets.only(top: 16, bottom: 16),
      color: Colors.white,
      width: double.infinity,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 30, minWidth: double.infinity),
        child: ListView.builder(
          itemBuilder: (context, index) {
            return categoryListItem(statusTypeListResult[index].desc, index);
          },
          primary: false,
          itemCount:
              statusTypeListResult == null ? 0 : statusTypeListResult.length,
          scrollDirection: Axis.horizontal,
        ),
      ),
    );
  }

  categoryListItem(String strCategory, int index) {
    double leftMargin = 8;
    double rightMargin = 8;
    if (index == 0) {
      leftMargin = 12;
    }
    if (index == listCategory.length - 1) {
      rightMargin = 12;
    }
    return GestureDetector(
      child: Container(
        child: Text(statusTypeListResult[index].desc,
            style: TextStyle(
                color: statusTypeListResult[index].isSelected == true
                    ? Constants.bgColor
                    : Constants.lightgreyColor,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
        margin: EdgeInsets.only(left: leftMargin, right: rightMargin),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 6),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(15)),
            border: Border.all(color: Constants.appColor, width: 1.5),
            color: statusTypeListResult[index].isSelected == true
                ? Constants.appColor
                : Constants.bgColor),
      ),
      onTap: () {
        if (oldIndex != index) {
          print(oldIndex);
          statusTypeListResult[oldIndex].isSelected = false;
          getOrdersByStatusTypeID(statusTypeListResult[index].typeCdId);
        }
        oldIndex = index;

        if (statusTypeListResult[index].isSelected == true) {
          statusTypeListResult[index].isSelected = false;
        } else {
          statusTypeListResult[index].isSelected = true;
        }

        print("Status Clicked " +
            statusTypeListResult[index].desc +
            " " +
            statusTypeListResult[index].typeCdId.toString());
      },
    );
  }

  Widget ordersDetails() {
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: ListView.builder(
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          itemCount: getOrdersResponse == null
              ? 0
              : getOrdersResponse.listResult.length,
          itemBuilder: (BuildContext context, int index) {
            var size = MediaQuery.of(context).size;
            final double itemHeight = (size.height) / 6;
            final double itemWidth = size.width / 3;
            //  discountedPrice = value.wholeSalePrice * (value.discount);
            //         totalPrice = value.wholeSalePrice - discountedPrice;
            return Container(
              decoration: BoxDecoration(
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 2,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              child: GestureDetector(
                child: new Card(
                  elevation: 2,
                  color: Colors.white,
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Order ID#",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: Constants.boldTextColor,
                                                fontSize: 10.0),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            getOrdersResponse
                                                .listResult[index].code,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: Constants.appColor,
                                                fontSize: 13.0),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                      Container(
                                        color: Constants.statusBGColor,
                                        child: Padding(
                                          padding: const EdgeInsets.all(7.0),
                                          child: Text(
                                            '₹' +
                                                getOrdersResponse
                                                    .listResult[index]
                                                    .totalPrice
                                                    .toStringAsFixed(2)
                                                    .replaceAllMapped(
                                                        reg, mathFunc),
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: Constants.appColor,
                                                fontSize: 12.0),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Order Date",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Constants.boldTextColor,
                                            fontSize: 12.0),
                                      ),
                                      Text(
                                        (formatter
                                                .format(getOrdersResponse
                                                    .listResult[index]
                                                    .createdDate)
                                                .toString())
                                            .substring(0, 10),
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Constants.boldTextColor,
                                            fontSize: 12.0),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Align(
                                        alignment: Alignment.bottomLeft,
                                        child: Container(
                                            width: 100,
                                            decoration: BoxDecoration(
                                              color: getOrdersResponse
                                                          .listResult[index]
                                                          .statusTypeid ==
                                                      11
                                                  ? Constants.confirmedBGColor
                                                  : getOrdersResponse
                                                              .listResult[index]
                                                              .statusTypeid ==
                                                          12
                                                      ? Constants.shippedBGColor
                                                      : getOrdersResponse
                                                                  .listResult[
                                                                      index]
                                                                  .statusTypeid ==
                                                              13
                                                          ? Constants
                                                              .cancelBGColor
                                                          : getOrdersResponse
                                                                      .listResult[
                                                                          index]
                                                                      .statusTypeid ==
                                                                  14
                                                              ? Constants
                                                                  .deliverBGColor
                                                              : Colors.red,
                                              // border: Border.all(color: Colors.green[100]),
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              border: Border.all(
                                                  width: 1.5,
                                                  color: getOrdersResponse
                                                              .listResult[index]
                                                              .statusTypeid ==
                                                          11
                                                      ? Colors.orange[900]
                                                      : getOrdersResponse
                                                                  .listResult[
                                                                      index]
                                                                  .statusTypeid ==
                                                              12
                                                          ? Constants.appColor
                                                          : getOrdersResponse
                                                                      .listResult[
                                                                          index]
                                                                      .statusTypeid ==
                                                                  13
                                                              ? Colors.red
                                                              : getOrdersResponse
                                                                          .listResult[
                                                                              index]
                                                                          .statusTypeid ==
                                                                      14
                                                                  ? Colors.green
                                                                  : Colors.red),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(3.0),
                                              child: Center(
                                                child: Row(
                                                  // mainAxisAlignment:
                                                  //     MainAxisAlignment
                                                  //         .spaceBetween,
                                                  children: <Widget>[
                                                    Image.asset(
                                                      getOrdersResponse
                                                                  .listResult[
                                                                      index]
                                                                  .statusTypeid ==
                                                              11
                                                          ? 'assets/checked-24.png'
                                                          : getOrdersResponse
                                                                      .listResult[
                                                                          index]
                                                                      .statusTypeid ==
                                                                  12
                                                              ? 'assets/in-transit-24.png'
                                                              : getOrdersResponse
                                                                          .listResult[
                                                                              index]
                                                                          .statusTypeid ==
                                                                      13
                                                                  ? 'assets/cancel-24.png'
                                                                  : getOrdersResponse
                                                                              .listResult[index]
                                                                              .statusTypeid ==
                                                                          14
                                                                      ? 'assets/delivered-box-24.png'
                                                                      : 'assets/delivered-box-24.png',
                                                      // fit: BoxFit.fill,
                                                      height: 13,
                                                    ),
                                                    Text(
                                                      " " +
                                                          getOrdersResponse
                                                              .listResult[index]
                                                              .statusName,
                                                      style: TextStyle(
                                                          // fontSize: 10,
                                                          color: getOrdersResponse
                                                                      .listResult[
                                                                          index]
                                                                      .statusTypeid ==
                                                                  11
                                                              ? Colors
                                                                  .orange[900]
                                                              : getOrdersResponse
                                                                          .listResult[
                                                                              index]
                                                                          .statusTypeid ==
                                                                      12
                                                                  ? Constants
                                                                      .appColor
                                                                  : getOrdersResponse
                                                                              .listResult[
                                                                                  index]
                                                                              .statusTypeid ==
                                                                          13
                                                                      ? Colors
                                                                          .red
                                                                      : getOrdersResponse.listResult[index].statusTypeid ==
                                                                              14
                                                                          ? Colors
                                                                              .green
                                                                          : Colors
                                                                              .red,
                                                          fontWeight:
                                                              FontWeight.w700),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            'View Order',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Constants.greyColor,
                                                fontWeight: FontWeight.w600),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Icon(
                                            Icons.chevron_right,
                                            size: 20,
                                          )
                                        ],
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => OrderDetailsScreen(
                            orderID: getOrdersResponse.listResult[index].id,
                            status:
                                getOrdersResponse.listResult[index].statusName,
                            statusID: getOrdersResponse
                                .listResult[index].statusTypeid,
                            orderCode: getOrdersResponse.listResult[index].code,
                            fileLocation: getOrdersResponse
                                .listResult[index].fileLocation,
                            fileName:
                                getOrdersResponse.listResult[index].fileName,
                            discount:
                                getOrdersResponse.listResult[index].discount,
                            totalPrice:
                                getOrdersResponse.listResult[index].totalPrice,
                            payableAmount: getOrdersResponse
                                .listResult[index].payableAmount,
                          )));
                },
              ),
            );
          }),
    );
  }

  getOrdersAPICall(int userID, String searchInput) {
    // String getOrdersURL = ApiService.baseUrl + 'Order/GetOrders';
    String getOrdersURL = ApiService.baseUrl + ApiService.getOrdersByStatusID;
    Map<String, dynamic> parameters = {
      "VendorId": userID.toString(),
      "OrderId": null,
      "StatusTypeId": null,
      "FromDate": null,
      "ToDate": null
    };
    print('getOrdersURL : ' + getOrdersURL);

    print('Request :' + parameters.toString());

    apiConnector.postAPICall(getOrdersURL, parameters).then((response) {
      //String res = response.body;
      getOrdersResponse = GetOrdersResponse.fromJson(response);
      print('OrdersRespone' + response.toString());
      if (response["IsSuccess"] == true) {
        setState(() {
          firstLoading = false;

          ordersCount = getOrdersResponse.listResult.length;

          print('OrdersRespone' + response.toString());
        });
      }
    });
  }

  getstatusTypes() {
    String statusURL = ApiService.baseUrl + ApiService.statusTypesURL;
    print('statusURL :' + statusURL.toString());

    apiConnector.getAPICall(statusURL).then((response) {
      statusTypesResponse = StatusTypesResponse.fromJson(response);
      if (statusTypesResponse.isSuccess == true) {
        //  productsforpost.add(new ItemsList(
        //       itemId: itemDetailsResponse.result.itemDetails.id,
        //       quantity: itemCount,
        //       colourId: activeColorID == 0 ? null : activeColorID,
        //       sizeId: activeSizeID == 0 ? null : activeSizeID));
        statusTypeListResult.add(new StatusTypeListResult(
            desc: "All", typeCdId: null, isSelected: true));
        statusTypeListResult[0].isSelected = true;

        if (statusTypesResponse.listResult.length > 0) {
          for (int i = 0; i < statusTypesResponse.listResult.length; i++) {
            statusTypeListResult.add(new StatusTypeListResult(
                classTypeId: statusTypesResponse.listResult[i].classTypeId,
                columnName: statusTypesResponse.listResult[i].columnName,
                desc: statusTypesResponse.listResult[i].desc,
                isActive: statusTypesResponse.listResult[i].isActive,
                name: statusTypesResponse.listResult[i].name,
                sortOrder: statusTypesResponse.listResult[i].sortOrder,
                tableName: statusTypesResponse.listResult[i].tableName,
                typeCdId: statusTypesResponse.listResult[i].typeCdId,
                isSelected: false));
          }
        }
      } else {}
    });
  }

  getOrdersByStatusTypeID(int statusID) {
    String getOrdersByStatusTypeIDURL =
        ApiService.baseUrl + ApiService.getOrdersByStatusID;
    Map<String, dynamic> parameters = {
      "VendorId": loginUserID.toString(),
      "OrderId": null,
      "StatusTypeId": statusID,
      "FromDate": null,
      "ToDate": null
    };

    apiConnector
        .postAPICall(getOrdersByStatusTypeIDURL, parameters)
        .then((response) {
      print('OrdersRespone' + response.toString());

      getOrdersResponse = GetOrdersResponse.fromJson(response);

      if (response["IsSuccess"] == true) {
        setState(() {
          firstLoading = false;

          ordersCount = getOrdersResponse.listResult.length;
          print('OrdersRespone' + response.toString());
        });
      } else {}
    });
  }

  void backnavigation() {
    Navigator.of(context).pop(true);
  }
}

import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:rupdarshi_cis/Model/GetCartResponse.dart';
import 'package:rupdarshi_cis/Model/GetWishListResponse.dart';

import 'package:rupdarshi_cis/Service/ApiService.dart';
import 'package:rupdarshi_cis/common/Constants.dart';
import 'package:rupdarshi_cis/common/LocalDb.dart';
import 'package:rupdarshi_cis/common/SessionManager.dart';
import 'package:rupdarshi_cis/screens/AccountScreen.dart';
import 'package:rupdarshi_cis/screens/CartScreen.dart';
import 'package:rupdarshi_cis/screens/Home_screen.dart';
import 'package:rupdarshi_cis/screens/ItemDetailsScreen.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:rupdarshi_cis/screens/NewHomeScreen.dart';

RegExp reg = new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
Function mathFunc = (Match match) => '${match[1]},';
final GlobalKey<State> _keyLoader = new GlobalKey<State>();
ProgressDialog pr;

class WishListScreen extends StatefulWidget {
  final String userID;
  final bool isFromCategory;
  final Function refresh;
  final bool isFromNewHome;
  final bool isFromHome;
  final String finalItemType;

  const WishListScreen(
      {this.userID,
      this.isFromCategory,
      this.refresh,
      this.isFromNewHome,
      this.isFromHome,
      this.finalItemType});
  @override
  _WishListScreenState createState() => _WishListScreenState();
}

class _WishListScreenState extends State<WishListScreen> {
  String errorMessage = "";
  int userid;
  double itemHeight = 0.0;
  double itemWidth = 0.0;
  bool isLoading = false;
  int pageNo = 1;
  bool islogin = false;
  ProgressDialog progressHud;
  ScrollController controller;
  int loginUserID = 0;
  int cartID = 0;
  int cartitemcount = 0;
  String addedCartStr = "Item added to cart";
  int wishListCount = 0;
  LocalData localData = new LocalData();
  ApiService apiConnector;
  GetWishListResponse getWishListResponse;
  List<WishListResult> wishListResult;
  GetCartResponse getCartResponse;
  bool firstLoading = true;

  refresh() async {
    setState(() {
      print('Refresh Wishlist');
      localData.getIntToSF(LocalData.USERID).then((userid) {
        setState(() {
          loginUserID = userid;
          cartID = 0;
          Future.delayed(Duration.zero, () {
            getCartDetails(userid.toString());
            getWishListAPICall(loginUserID);
            // Navigator.pop(context);
          });
        });
      });
    });
  }

  @override
  void initState() {
    super.initState();
    firstLoading = true;
    errorMessage = "";
    apiConnector = new ApiService();
    pr = new ProgressDialog(context);
    SessionManager().getIsLogin().then((value) {
      islogin = value;
      print('is login new splash $islogin');
    });
    getWishListResponse = new GetWishListResponse();
    wishListResult = new List<WishListResult>();
    wishListCount = 0;
    localData.getIntToSF(LocalData.USERID).then((userid) {
      setState(() {
        loginUserID = userid;
        getWishListAPICall(loginUserID);
        print('USERid' + loginUserID.toString());
      });
    });

    localData.getIntToSF(LocalData.USERID).then((userid) {
      setState(() {
        loginUserID = userid;
        cartID = 0;
        Future.delayed(Duration.zero, () {
          getCartDetails(userid.toString());
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    itemHeight = (size.height) / 3;
    itemWidth = size.width / 2;

    return WillPopScope(
      onWillPop: () {
        backnavigation();
      },
      child: DefaultTabController(
        length: 5,
        child: Scaffold(
            appBar: AppBar(
              title: Text('Wishlist',
                  style: TextStyle(
                      color: Constants.greyColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1),
              backgroundColor: Constants.bgColor,
              leading: GestureDetector(
                onTap: () {
                  if (widget.isFromCategory == true) {
                    print('Refresh Category screen');
                    widget.refresh();
                    Navigator.pop(context);
                  } else if (widget.isFromNewHome == true) {
                    print('Refresh New Home screen');
                    widget.refresh();
                    Navigator.pop(context);
                  } else if (widget.isFromHome == true) {
                    print('Refresh Home screen from top back');
                    widget.refresh();
                    Navigator.pop(context);
                  } else {
                    Navigator.pop(context);
                  }
                  // Navigator.of(context).push(
                  //     MaterialPageRoute(builder: (context) => NewHomeScreen()));
                  // Navigator.of(context).push(
                  //     MaterialPageRoute(builder: (context) => HomeScreen()));
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
                : wishListResult.length == 0 || wishListResult.length == null
                    ? Column(
                        children: [
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
                                  'No Wishlist Found',
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
                                        "Go to home",
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
                    : Column(children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                wishListCount.toString() + ' Items',
                                style: TextStyle(
                                    color: Constants.blackColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700),
                              )),
                        ),
                        Divider(
                          color: Colors.grey[400],
                          thickness: 2,
                        ),
                        wishListView(),
                      ]),
            bottomNavigationBar: getWishListResponse.listResult != null
                ? Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: Container(
                      height: 55,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey[300]),
                        // borderRadius: BorderRadius.only(
                        //   bottomLeft: const Radius.circular(25.0),
                        //   bottomRight: const Radius.circular(25.0),
                        // )
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
                                  color: Constants.appColor,
                                )),
                                Tab(
                                    child: Image.asset(
                                  'assets/Icons/notification-48.png',
                                  height: 20,
                                )),
                              ],
                              indicator: UnderlineTabIndicator(
                                  borderSide: BorderSide(
                                      width: 3.5, color: Colors.white),
                                  insets:
                                      EdgeInsets.symmetric(horizontal: 11.0)),
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
                                      builder: (context) => CartScreen(
                                            userID: loginUserID.toString(),
                                            refresh: refresh,
                                            isFromWishlist: true,
                                          )));
                                } else if (tabIndex == 3) {
                                  // Navigator.of(context).push(MaterialPageRoute(
                                  //     builder: (context) => WishListScreen(
                                  //         userID: loginUserID.toString())));
                                } else if (tabIndex == 4) {}
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Text('')),
      ),
    );
  }

  wishListView() {
    ScrollController controller;
    /*24 is for notification bar on Android*/

    return getWishListResponse.listResult == null
        ? Center(
            child: Container(),
          )
        : Expanded(
            child: GridView.count(
                physics: ClampingScrollPhysics(),
                shrinkWrap: true,
                crossAxisCount: 2,
                childAspectRatio: MediaQuery.of(context).size.height / 850,
                // childAspectRatio: 1 / 1.5,
                // mainAxisSpacing: 5.0,
                // crossAxisSpacing: 5.0,
                controller: controller,
                children: wishListResult != null || wishListResult.length > 0
                    ? wishListResult.map((value) {
                        var savingPrice =
                            value.wholeSalePrice - value.discountPrince;
                        return GestureDetector(
                          onTap: () {
                            print(value.isWishlist);
                            print("****************");
                            print(this.widget.isFromHome);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ItemDetailsScreen(
                                          itemID: value.itemId.toString(),
                                          isWishList: true,
                                          isFromWishList: true,
                                          isFromHome: this.widget.isFromHome,
                                        )));
                          },
                          child: Card(
                            child: Container(
                              // color: Colors.red,
                              child: Stack(
                                children: <Widget>[
                                  Column(
                                    children: <Widget>[
                                      Expanded(
                                        child: Container(
                                          // height: itemHeight / 1.75,
                                          width: itemWidth / 1,
                                          color: Constants.imageBGColor,
                                          child: Padding(
                                            padding: const EdgeInsets.all(3.0),
                                            child: value.filePath != null
                                                ? CachedNetworkImage(
                                                    // fit: BoxFit.fill,
                                                    imageUrl: ApiService
                                                            .filerepopath +
                                                        value.filePath,
                                                    placeholder: (context,
                                                            url) =>
                                                        Center(
                                                            child: Container(
                                                      height: 20,
                                                      width: 20,
                                                      child:
                                                          CircularProgressIndicator(),
                                                    )),
                                                    errorWidget: (context, url,
                                                            error) =>
                                                        new Image.asset(
                                                            'assets/Rupdarshi.jpg'),
                                                  )
                                                : Image.asset(
                                                    'assets/Rupdarshi.jpg',
                                                    fit: BoxFit.scaleDown,
                                                  ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Container(
                                          child: Column(
                                            children: <Widget>[
                                              Align(
                                                alignment: Alignment.topLeft,
                                                child: Text(
                                                  value.categoryName.inCaps,
                                                  style: TextStyle(
                                                    color: Constants.appColor,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 10,
                                                  ),
                                                  overflow: TextOverflow.clip,
                                                ),
                                              ),
                                              Align(
                                                alignment: Alignment.topLeft,
                                                child: Text(
                                                  value.name.inCaps,
                                                  style: TextStyle(
                                                      color:
                                                          Constants.blackColor,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 12.0),
                                                  overflow: TextOverflow.clip,
                                                ),
                                              ),
                                              Row(
                                                children: <Widget>[
                                                  Expanded(
                                                    child: Column(
                                                      children: <Widget>[
                                                        Row(
                                                          children: <Widget>[
                                                            Text(
                                                              "₹ ${value.discountPrince.toStringAsFixed(0)}"
                                                                  .replaceAllMapped(
                                                                      reg,
                                                                      mathFunc),
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Constants
                                                                    .boldTextColor,
                                                              ),
                                                              overflow:
                                                                  TextOverflow
                                                                      .clip,
                                                              maxLines: 1,
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(3.0),
                                                              child: Text(
                                                                value.discount ==
                                                                            0.0 ||
                                                                        value.discount ==
                                                                            0
                                                                    ? ""
                                                                    : "₹ ${value.wholeSalePrice.toStringAsFixed(0)}"
                                                                        .replaceAllMapped(
                                                                            reg,
                                                                            mathFunc),
                                                                style:
                                                                    TextStyle(
                                                                  decoration:
                                                                      TextDecoration
                                                                          .lineThrough,
                                                                  fontSize: 9,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color: Constants
                                                                      .lightgreyColor,
                                                                ),
                                                                overflow:
                                                                    TextOverflow
                                                                        .clip,
                                                              ),
                                                            ),
                                                            Text(
                                                              value.discount ==
                                                                          0.0 ||
                                                                      value.discount ==
                                                                          0
                                                                  ? " "
                                                                  : "Save ₹${savingPrice.toStringAsFixed(0)}"
                                                                      .replaceAllMapped(
                                                                          reg,
                                                                          mathFunc),
                                                              style: TextStyle(
                                                                fontSize: 9,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: Colors
                                                                    .green,
                                                              ),
                                                              overflow:
                                                                  TextOverflow
                                                                      .clip,
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    ' Barcode  - ',
                                                    style: TextStyle(
                                                      fontSize: 9,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          Constants.greyColor,
                                                    ),
                                                    overflow: TextOverflow.clip,
                                                    maxLines: 2,
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      value.barCode,
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Constants
                                                            .boldTextColor,
                                                      ),
                                                      overflow:
                                                          TextOverflow.clip,
                                                      maxLines: 2,
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
                                  Positioned(
                                    top: 10,
                                    left: 10,
                                    child: GestureDetector(
                                      child: Container(
                                          padding: const EdgeInsets.all(2.0),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.grey.shade100,
                                          ),
                                          child: Icon(Icons.favorite,
                                              color: Colors.pink)),
                                      onTap: () {
                                        removeFromWishListAPICall(
                                            false, value.itemId);
                                      },
                                    ),
                                  ),
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: value.discount == 0 ||
                                            value.discount == 0.0
                                        ? Container()
                                        : Container(
                                            padding: const EdgeInsets.all(6.0),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Constants.appColor,
                                            ),
                                            child: Text(
                                              value.discount
                                                      .toStringAsFixed(0) +
                                                  '%\nOff',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 7),
                                              overflow: TextOverflow.clip,
                                            )),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList()
                    : Container()),
          );
  }

  getCartDetails(String userID) async {
    // progressHud.show();
    print(" selected Userid -- > " + userid.toString());
    String finalUrl = ApiService.baseUrl + ApiService.getCartURL + userID;
    print(" finalUrl -- > " + finalUrl);
    await apiConnector.getCartApiCall(finalUrl).then((response) {
      print(" GetCartByUserID -- > " + response.toString());
      // progressHud.hide();

      setState(() {
        // progressHud.hide();
        getCartResponse = GetCartResponse.fromJson(response);
        if (getCartResponse != null && getCartResponse.result != null) {
          cartitemcount = getCartResponse.result.productsList.length;
          print(" QUANTITY -- > " + cartitemcount.toString());
          print("Home itemDetailsResponse -- > " +
              getCartResponse.result.productsList.length.toString());
        } else {
          cartitemcount = 0;
        }
      });
      // progressHud.hide();
    }).catchError((onError) {
      // progressHud.hide();
    });
  }

  getWishListAPICall(int userID) async {
    // progressHud.show();
    String getWishListURL =
        ApiService.baseUrl + ApiService.getWishList + userID.toString();
    print(" ******** WishList  " + getWishListURL.toString());

    apiConnector.getAPICall(getWishListURL).then((response) {
      setState(() {
        firstLoading = false;
        // progressHud.hide();
        print(" ******** WishList  " + response.toString());
        getWishListResponse = GetWishListResponse.fromJson(response);
        if (getWishListResponse != null &&
            getWishListResponse.listResult != null) {
          setState(() {
            wishListResult = getWishListResponse.listResult;
            wishListCount = getWishListResponse.listResult.length;

            print(" ******** wishListCount  " + wishListCount.toString());
          });
        } else {
          setState(() {
            errorMessage = "No wishlist found";
          });
        }
      });
    });
  }

  removeFromWishListAPICall(bool isFaverate, int itemID) {
    String removeFromWishListURL =
        ApiService.baseUrl + ApiService.removeFromishList;

    Map<String, dynamic> parameters = {
      "VendorId": loginUserID,
      "ItemId": itemID
    };

    apiConnector
        .postAPICall(removeFromWishListURL, parameters)
        .then((response) {
      print(response);
      if (response["IsSuccess"] == true) {
        print(response["EndUserMessage"]);
        apiConnector.globalToast("Removed from wishlist");
        setState(() {
          wishListResult.removeWhere((item) => item.itemId == itemID);
          wishListCount = wishListResult.length;
        });
      }
    });
  }

  void backnavigation() {
    if (widget.isFromCategory == true) {
      print('Refresh Category screen');
      widget.refresh();
      Navigator.pop(context);
    } else if (widget.isFromNewHome == true) {
      print('Refresh New Home screen');
      widget.refresh();
      Navigator.pop(context);
    } else if (widget.isFromHome == true) {
      print('Refresh Home screen');
      print(this.widget.finalItemType);
      // widget.refresh();
      // Navigator.pop(context);

      localData.getStringValueSF("finalItemType").then((value) {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => HomeScreen(
                  itemTypeID: value,
                )));
      });
    } else {
      // widget.refresh();
      // Navigator.pop(context);
      print(widget.isFromHome);
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => NewHomeScreen()));
    }
  }
}

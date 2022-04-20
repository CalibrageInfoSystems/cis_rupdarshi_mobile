import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rupdarshi_cis/Model/CategoriesByIDResponse.dart';
import 'package:rupdarshi_cis/Model/DeleteCartResponse.dart';
import 'package:rupdarshi_cis/Model/GetCartResponse.dart';
import 'package:rupdarshi_cis/Model/Requests/PostCartRequest.dart';
import 'package:rupdarshi_cis/Service/ApiService.dart';
import 'package:rupdarshi_cis/common/Constants.dart';
import 'package:rupdarshi_cis/common/LocalDb.dart';
import 'package:rupdarshi_cis/common/SessionManager.dart';
import 'package:rupdarshi_cis/screens/Address.dart';
import 'package:rupdarshi_cis/screens/ItemDetailsScreen.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'NewHomeScreen.dart';

final GlobalKey<State> _keyLoader = new GlobalKey<State>();
ProgressDialog pr;
RegExp reg = new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
Function mathFunc = (Match match) => '${match[1]},';

RegExp regex = RegExp(r"([.]*0)(?!.*\d)");

class CartScreen extends StatefulWidget {
  final String userID;
  final String itemID;
  final Function refresh;
  final bool isFromItemDetails;
  final bool isFromHome;
  final bool isFromCategory;
  final bool isfromNewHome;
  final bool isFromWishlist;

  const CartScreen(
      {this.userID,
      this.itemID,
      this.refresh,
      this.isFromItemDetails,
      this.isFromHome,
      this.isFromCategory,
      this.isfromNewHome,
      this.isFromWishlist});
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController itemCountController = new TextEditingController();
  RegExp regex = RegExp(r"([.]*0)(?!.*\d)");

  int itemCount = 0;
  int totalQTY = 0;
  double totalGSTprice = 0.0;

  bool firstLoading = true;
  CategoriesByIDListResult categoriesByIDList;
  String errorMessage = "";
  bool isfaverate = false;
  var gstPrice = 0.0;
  var quantityPrice = 0.0;
  var discountedPrice = 0.0;
  var totalPrice = 0.0;
  var totItemsSavingPrice = 0.0;
  var totalSavingPrice = 0.0;
  var savingPrice = 0.0;
  var savingPrice2 = 0.0;
  var totalQtySavingPrice = 0.0;
  bool islogin = false;
  ProgressDialog progressHud;
  ScrollController controller;
  int loginUserID = 0;
  int cartID = 0;
  int cartitemcount = 0;
  String addedCartStr = "Item added to cart";

  LocalData localData = new LocalData();
  ApiService apiConnecter;
  GetCartResponse getCartResponse;
  PostCartRequest cartModel;
  DeleteCartResponse deleteCartResponse;
  List<ItemsList> productsforpost;
  List<ProductsList> cartProductList;
  ProductsList productsList;

  refresh() {
    setState(() {
      print('Refresh Wishlist');
      localData.getIntToSF(LocalData.USERID).then((userid) {
        setState(() {
          loginUserID = userid;
          cartID = 0;
          Future.delayed(Duration.zero, () {
            progressHud =
                new ProgressDialog(context, type: ProgressDialogType.Normal);

            getCartDetails(userid.toString());
          });
        });
      });
    });
  }

  @override
  void initState() {
    super.initState();
    itemCount = 0;
    totalQTY = 0;
    itemCountController.text = "1";
    firstLoading = true;
    errorMessage = "";
    cartitemcount = 0;
    apiConnecter = new ApiService();
    pr = new ProgressDialog(context);
    itemCountController.text = "";
    categoriesByIDList = new CategoriesByIDListResult();
    SessionManager().getIsLogin().then((value) {
      islogin = value;
      print('is login new splash $islogin');
    });
    getCartResponse = new GetCartResponse();
    deleteCartResponse = new DeleteCartResponse();
    cartProductList = new List<ProductsList>();
    productsforpost = new List<ItemsList>();

    cartModel = new PostCartRequest();

    localData.getIntToSF(LocalData.USERID).then((userid) {
      setState(() {
        loginUserID = userid;
        cartID = 0;
        Future.delayed(Duration.zero, () {
          getCartDetails(widget.userID);
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double itemHeight = (size.height) / 3.3;
    final double bottomHtemHeight = (size.height) / 6.5;

    final double itemWidth = size.width / 2;

    return WillPopScope(
      onWillPop: () {
        backnavigation();
      },
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
            appBar: AppBar(
              title: Text('My Cart',
                  style: TextStyle(
                    color: Constants.greyColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1),
              backgroundColor: Constants.bgColor,
              leading: GestureDetector(
                onTap: () {
                  if (widget.isFromItemDetails == true) {
                    setState(() {
                      print('Refresh Item');
                      widget.refresh(); // just refresh() if its statelesswidget
                      Navigator.pop(context);
                    });
                  } else if (widget.isFromHome == true) {
                    print('Refresh Home');
                    widget.refresh(); // just refresh() if its statelesswidget
                    Navigator.pop(context);
                  } else if (widget.isfromNewHome == true) {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => NewHomeScreen()));
                    // print('Refresh Home');
                    //   widget.refresh(); // just refresh() if its statelesswidget
                    //   Navigator.pop(context);
                  } else if (widget.isFromCategory == true) {
                    print('Refresh Category screen');
                    widget.refresh(); // just refresh() if its statelesswidget
                    Navigator.pop(context);
                  } else if (widget.isFromWishlist == true) {
                    print('Refresh Wishlist screen');
                    widget.refresh(); // just refresh() if its statelesswidget
                    Navigator.pop(context);
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
              actions: <Widget>[
                cartitemcount == 0
                    ? Container()
                    : Padding(
                        padding: EdgeInsets.only(
                          right: 5.0,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            deleteCartAlertDialog(context);
                          },
                          child: Row(
                            children: <Widget>[
                              Image.asset(
                                'assets/clear-cart-48.png',
                                height: 20,
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: Text(" Clear Cart",
                                    style: TextStyle(
                                      color: Constants.appColor,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1),
                              ),
                            ],
                          ),
                        )),
              ],
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
                : getCartResponse.result == null
                    ? Container(
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
                              'Your Cart is empty!',
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
                      ))
                    : SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(children: <Widget>[categories()]),
                      ),
            bottomNavigationBar: getCartResponse.result != null
                ? Stack(children: <Widget>[
                    Container(
                      height: bottomHtemHeight,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey[300]),
                      ),
                      child: Column(
                        children: [
                          priceDetails(),
                          Row(
                            // crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Container(
                                    child: Container(
                                      // height: 48,
                                      child: RaisedButton(
                                        child: Padding(
                                          padding: const EdgeInsets.all(6.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              Text(
                                                " Continue Shopping",
                                                style: TextStyle(
                                                  // fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Constants.blackColor,
                                                ),
                                                overflow: TextOverflow.clip,
                                              ),
                                            ],
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
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      NewHomeScreen()));
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: Container(
                                    //  height: 48,
                                    // width: 160,
                                    child: RaisedButton(
                                      color: Constants.appColor,
                                      child: Text(
                                        " Place Order ",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      onPressed: () {
                                        if (itemCountController.text == "0") {
                                          print('object');
                                        } else {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      AddressScreen(
                                                        isFromCart: true,
                                                        isFromItemDetails:
                                                            false,
                                                        refresh: refresh,
                                                      )));
                                        }

                                        //  showProceedDialog();
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ])
                : Text('')),
      ),
    );
  }

  Widget categories() {
    return getCartResponse.result == null
        ? Center(
            child: Container(),
          )
        : Padding(
            padding: const EdgeInsets.all(1.0),
            child: ListView.builder(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                itemCount: getCartResponse == null
                    ? 0
                    : getCartResponse.result.productsList.length,
                itemBuilder: (BuildContext context, int index) {
                  var size = MediaQuery.of(context).size;
                  final double itemHeight = (size.height) / 4.0;
                  final double itemWidth = size.width / 2.5;

                  var savingPrice = getCartResponse
                          .result.productsList[index].wholeSalePrice
                          .toDouble() -
                      getCartResponse.result.productsList[index].discountPrince
                          .toDouble();

                  quantityPrice = getCartResponse
                          .result.productsList[index].quantity
                          .toDouble() *
                      getCartResponse.result.productsList[index].discountPrince
                          .toDouble();
                  var qtySavingPrice = savingPrice.toDouble() *
                      getCartResponse.result.productsList[index].quantity
                          .toDouble();
                  var qtyWholeSalePrice = getCartResponse
                          .result.productsList[index].quantity
                          .toDouble() *
                      getCartResponse.result.productsList[index].wholeSalePrice
                          .toDouble();
                  itemCount =
                      getCartResponse.result.productsList[index].quantity;
                  // gstPrice = (quantityPrice *
                  //         getCartResponse.result.productsList[index].gst
                  //             .toDouble()) /
                  //     100;
                  print('++++++++++gstPrice' + gstPrice.toString());
                  return Container(
                    decoration: BoxDecoration(
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.white,
                          blurRadius: 2,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    height: itemHeight + 10,
                    width: double.infinity,
                    child: new Card(
                      elevation: 2,
                      color: Colors.white,
                      child: Column(
                        children: <Widget>[
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ItemDetailsScreen(
                                              itemID: getCartResponse
                                                  .result.productsList[index].id
                                                  .toString(),
                                              isWishList: getCartResponse
                                                  .result
                                                  .productsList[index]
                                                  .isWishlist,
                                              isFromCart: true,
                                              refresh: refresh,
                                            )));
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Stack(children: <Widget>[
                                    Container(
                                      // width: itemWidth,
                                      //  height: itemHeight - 50,
                                      color: Constants.imageBGColor,
                                      child: Padding(
                                        padding: const EdgeInsets.all(3.0),
                                        child: ClipRRect(
                                            child: getCartResponse
                                                        .result
                                                        .productsList[index]
                                                        .filePath !=
                                                    null
                                                ? CachedNetworkImage(
                                                    width: itemWidth,
                                                    fit: BoxFit.contain,
                                                    imageUrl: ApiService
                                                            .filerepopath +
                                                        getCartResponse
                                                            .result
                                                            .productsList[index]
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
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            new Image.asset(
                                                      'assets/Rupdarshi.jpg',
                                                      width: itemWidth,
                                                    ),
                                                  )
                                                : Image.asset(
                                                    'assets/Rupdarshi.jpg',
                                                    width: itemWidth,
                                                  )),
                                      ),
                                    ),
                                    Positioned(
                                      top: 10,
                                      right: 10,
                                      child: getCartResponse
                                                      .result
                                                      .productsList[index]
                                                      .discount ==
                                                  0 ||
                                              getCartResponse
                                                      .result
                                                      .productsList[index]
                                                      .discount ==
                                                  0.0
                                          ? Container()
                                          : Container(
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Constants.appColor,
                                              ),
                                              child: Text(
                                                getCartResponse
                                                        .result
                                                        .productsList[index]
                                                        .discount
                                                        .toString()
                                                        .replaceAll(
                                                            RegExp(
                                                                r"([.]*0)(?!.*\d)"),
                                                            "") +
                                                    '%\nOff',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 6),
                                                overflow: TextOverflow.ellipsis,
                                              )),
                                    ),
                                  ]),
                                  // SizedBox(width: 10),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          getCartResponse
                                                      .result
                                                      .productsList[index]
                                                      .itemTypename ==
                                                  null
                                              ? Container()
                                              : Text(
                                                  getCartResponse
                                                              .result
                                                              .productsList[
                                                                  index]
                                                              .itemTypename ==
                                                          null
                                                      ? ""
                                                      : getCartResponse
                                                          .result
                                                          .productsList[index]
                                                          .itemTypename
                                                          .inCaps,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: Constants.appColor,
                                                    fontSize: 11.0,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                          getCartResponse
                                                          .result
                                                          .productsList[index]
                                                          .name ==
                                                      null ||
                                                  getCartResponse
                                                          .result
                                                          .productsList[index]
                                                          .name ==
                                                      ""
                                              ? Container()
                                              : Text(
                                                  getCartResponse.result == null
                                                      ? ""
                                                      : getCartResponse
                                                          .result
                                                          .productsList[index]
                                                          .name
                                                          .inCaps,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: Constants.blackColor,
                                                    fontSize: 12.0,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          getCartResponse
                                                          .result
                                                          .productsList[index]
                                                          .colourNames ==
                                                      null ||
                                                  getCartResponse
                                                          .result
                                                          .productsList[index]
                                                          .colourNames ==
                                                      ""
                                              ? Container()
                                              : Row(
                                                  children: <Widget>[
                                                    Text(
                                                      getCartResponse
                                                          .result
                                                          .productsList[index]
                                                          .colourNames,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color:
                                                            Constants.greyColor,
                                                        fontSize: 10.0,
                                                      ),
                                                      overflow:
                                                          TextOverflow.clip,
                                                    ),
                                                    Text(getCartResponse
                                                                .result
                                                                .productsList[
                                                                    index]
                                                                .sizeNames ==
                                                            null
                                                        ? ""
                                                        : ' - '),
                                                    Text(
                                                      getCartResponse
                                                                  .result
                                                                  .productsList[
                                                                      index]
                                                                  .sizeNames ==
                                                              null
                                                          ? ""
                                                          : getCartResponse
                                                              .result
                                                              .productsList[
                                                                  index]
                                                              .sizeNames,
                                                      style: new TextStyle(
                                                          color: Constants
                                                              .greyColor,
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.w600),
                                                      overflow:
                                                          TextOverflow.clip,
                                                    ),
                                                  ],
                                                ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Row(
                                            // mainAxisAlignment:
                                            //     MainAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                getCartResponse.result == null
                                                    ? ""
                                                    : '₹ ' +
                                                        getCartResponse
                                                            .result
                                                            .productsList[index]
                                                            .discountPrince
                                                            .toString()
                                                            .replaceAll(
                                                                RegExp(
                                                                    r"([.]*0)(?!.*\d)"),
                                                                "")
                                                            .replaceAllMapped(
                                                                reg, mathFunc),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      Constants.boldTextColor,
                                                  fontSize: 15.0,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(5.0),
                                                child: Text(
                                                  getCartResponse
                                                                  .result
                                                                  .productsList[
                                                                      index]
                                                                  .discount ==
                                                              0.0 ||
                                                          getCartResponse
                                                                  .result
                                                                  .productsList[
                                                                      index]
                                                                  .discount ==
                                                              0
                                                      ? ""
                                                      : '₹ ' +
                                                          getCartResponse
                                                              .result
                                                              .productsList[
                                                                  index]
                                                              .wholeSalePrice
                                                              .toStringAsFixed(
                                                                  0)
                                                              .replaceAllMapped(
                                                                  reg,
                                                                  mathFunc),
                                                  style: TextStyle(
                                                      decoration: TextDecoration
                                                          .lineThrough,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Constants
                                                          .lightgreyColor,
                                                      fontSize: 10),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Text(
                                                getCartResponse
                                                                .result
                                                                .productsList[
                                                                    index]
                                                                .discount ==
                                                            0.0 ||
                                                        getCartResponse
                                                                .result
                                                                .productsList[
                                                                    index]
                                                                .discount ==
                                                            0
                                                    ? ""
                                                    : "Save ₹" +
                                                        savingPrice
                                                            .toStringAsFixed(0)
                                                            .replaceAllMapped(
                                                                reg, mathFunc),
                                                style: TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.green,
                                                ),
                                                overflow: TextOverflow.clip,
                                                maxLines: 2,
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                getCartResponse.result == null
                                                    ? ""
                                                    : 'GST  :',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: Constants.greyColor,
                                                  fontSize: 10.0,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                getCartResponse
                                                                .result
                                                                .productsList[
                                                                    index]
                                                                .gst ==
                                                            0.0 ||
                                                        getCartResponse
                                                                .result
                                                                .productsList[
                                                                    index]
                                                                .gst ==
                                                            0
                                                    ? ""
                                                    : getCartResponse
                                                            .result
                                                            .productsList[index]
                                                            .gst
                                                            .toStringAsFixed(0)
                                                            .replaceAllMapped(
                                                                reg, mathFunc) +
                                                        '%',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: Constants.greyColor,
                                                    fontSize: 10),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                          getCartResponse
                                                          .result
                                                          .productsList[index]
                                                          .barCode ==
                                                      null ||
                                                  getCartResponse
                                                          .result
                                                          .productsList[index]
                                                          .barCode ==
                                                      ""
                                              ? Container()
                                              : Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 5.0),
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        getCartResponse
                                                                    .result ==
                                                                null
                                                            ? ""
                                                            : 'Barcode  -',
                                                        style: TextStyle(
                                                          fontSize: 9,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Constants
                                                              .greyColor,
                                                        ),
                                                        overflow:
                                                            TextOverflow.clip,
                                                      ),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                      Text(
                                                        getCartResponse
                                                                        .result
                                                                        .productsList[
                                                                            index]
                                                                        .barCode ==
                                                                    null ||
                                                                getCartResponse
                                                                        .result
                                                                        .productsList[
                                                                            index]
                                                                        .barCode ==
                                                                    ""
                                                            ? ""
                                                            : getCartResponse
                                                                .result
                                                                .productsList[
                                                                    index]
                                                                .barCode
                                                                .toString(),
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
                          ),
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Container(
                                  width: itemWidth,
                                  // color: Colors.blue,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          print('++++itemCount ' +
                                              getCartResponse.result
                                                  .productsList[index].quantity
                                                  .toString());
                                          if (getCartResponse
                                                  .result
                                                  .productsList[index]
                                                  .quantity >
                                              1) {
                                            setState(() {
                                              getCartResponse
                                                  .result
                                                  .productsList[index]
                                                  .quantity--;
                                              removefromcart(getCartResponse
                                                  .result.productsList[index]);
                                            });
                                          }
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(),
                                          child: Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Icon(
                                              Icons.remove,
                                              color: Constants.greyColor,
                                              size: 16.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                          height: 25,
                                          width: 40,
                                          child: TextFormField(
                                            maxLength: 4,
                                            style: TextStyle(fontSize: 12),
                                            textAlign: TextAlign.center,
                                            // controller: itemCountController,
                                            controller: TextEditingController(
                                                text: getCartResponse
                                                    .result
                                                    .productsList[index]
                                                    .quantity
                                                    .toString()),
                                            keyboardType: TextInputType.text,
                                            inputFormatters: <
                                                TextInputFormatter>[
                                              WhitelistingTextInputFormatter
                                                  .digitsOnly
                                            ],
                                            decoration: InputDecoration(
                                                counterText: "",
                                                contentPadding: EdgeInsets.only(
                                                    top: 6.0,
                                                    left: 5,
                                                    right: 5,
                                                    bottom: 3.0),
                                                // hintText:"1",

                                                labelStyle: TextStyle(
                                                    color: Constants
                                                        .lightgreyColor,
                                                    fontSize: 4,
                                                    fontWeight:
                                                        FontWeight.w600),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color:
                                                          Constants.blackColor,
                                                      width: 1),
                                                ),
                                                border: new OutlineInputBorder(
                                                  borderSide: BorderSide(),
                                                )),
                                            onChanged: (value) {
                                              itemCountController.text = value;
                                              getCartResponse
                                                      .result
                                                      .productsList[index]
                                                      .quantity =
                                                  int.parse(
                                                      itemCountController.text);
                                              //  value = itemCountController.text;
                                              // itemCountController.text = value;
                                              print('ItemCount Tadded text ' +
                                                  getCartResponse
                                                      .result
                                                      .productsList[index]
                                                      .quantity
                                                      .toString());
                                              // itemCountController.text == null || itemCountController.text == "" ? itemCountController.text="1" : itemCount.toString();
                                            },
                                            onFieldSubmitted: (val) {
                                              setState(() {
                                                getCartResponse
                                                    .result
                                                    .productsList[index]
                                                    .quantity = int.parse(val);
                                                updateCart(getCartResponse
                                                    .result
                                                    .productsList[index]);

                                                print(
                                                    'ItemCount Onfield submitted text ' +
                                                        getCartResponse
                                                            .result
                                                            .productsList[index]
                                                            .quantity
                                                            .toString());
                                              });
                                            },
                                            onSaved: (newValue) {
                                              setState(() {
                                                getCartResponse
                                                        .result
                                                        .productsList[index]
                                                        .quantity =
                                                    int.parse(newValue);
                                                //  itemCountController.text = newValue;
                                                print('OnSaved text ' +
                                                    getCartResponse
                                                        .result
                                                        .productsList[index]
                                                        .quantity
                                                        .toString());
                                                //  itemCountController.clear();
                                                // itemCountController.text == null || itemCountController.text == "" ? itemCountController.text="1" : itemCount.toString();
                                              });
                                            },
                                          )),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            getCartResponse.result
                                                .productsList[index].quantity++;
                                            updateCart(getCartResponse
                                                .result.productsList[index]);
                                          });
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(),
                                          child: Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Icon(
                                              Icons.add,
                                              color: Constants.greyColor,
                                              size: 16.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: GestureDetector(
                                          onTap: () {
                                            if (cartitemcount == 1) {
                                              deleteCart(
                                                  loginUserID.toString());
                                            } else {
                                              removeItemfromcart(getCartResponse
                                                  .result.productsList[index]);
                                            }

                                            addToWishListAPICall(
                                                true,
                                                getCartResponse.result
                                                    .productsList[index].id);
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade300,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(3)),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(5.0),
                                              child: Row(
                                                children: <Widget>[
                                                  Icon(
                                                    Icons.favorite_border,
                                                    color: Constants
                                                        .lightgreyColor,
                                                    size: 15.0,
                                                  ),
                                                  Text(
                                                    '  Save for later ',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Constants.greyColor,
                                                        fontSize: 12.0),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: GestureDetector(
                                          onTap: () {
                                            showAlertDialog(context, index);

                                            // getCartResponse
                                            //     .result.productsList
                                            //     .removeAt(index);
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade300,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(3)),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(7.0),
                                              child: Row(
                                                children: <Widget>[
                                                  Icon(
                                                    Icons.delete,
                                                    color: Constants
                                                        .lightgreyColor,
                                                    size: 15.0,
                                                  ),
                                                  Text(
                                                    '  Remove ',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Constants.greyColor,
                                                        fontSize: 12.0),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
          );
  }

  Widget priceDetails() {
    return Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
          child: Column(
            children: <Widget>[
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: [
                        Text(
                          'Total Price ',
                          style: new TextStyle(
                              color: Constants.blackColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          getCartResponse.result.productsList.length > 0
                              ? '(' + totalQTY.toString()
                              : "",
                          style: TextStyle(
                              color: Constants.blackColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                          overflow: TextOverflow.clip,
                        ),
                        Text(
                          totalQTY == 1 ? ' Piece)' : ' Pieces)',
                          style: TextStyle(
                              color: Constants.blackColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                          overflow: TextOverflow.clip,
                        ),
                        // Text(
                        //   getCartResponse.result.productsList.length > 0
                        //       ? '(' +
                        //           totalQTY .toString() +
                        //           ' Items)'
                        //       : "",
                        //   style: TextStyle(
                        //       color: Constants.blackColor,
                        //       fontSize: 12,
                        //       fontWeight: FontWeight.w600),
                        //   overflow: TextOverflow.clip,
                        // ),
                      ],
                    ),
                    Text(
                      '₹' +
                          totalPrice
                              .toStringAsFixed(2)
                              .replaceAllMapped(reg, mathFunc),
                      style: TextStyle(
                          color: Constants.blackColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                      overflow: TextOverflow.clip,
                    )
                  ]),
              Divider(
                color: Colors.grey[400],
              ),
            ],
          ),
        ));
  }

  void updateCart(ProductsList categoryList) {
    setState(() {
      print('**************' + gstPrice.toString());
      print('productsforpost.length ' + productsforpost.length.toString());

      if (getCartResponse != null) {
        cartModel.cart =
            new CartPostInfo(id: cartID, userId: loginUserID, name: "cart");
      } else {
        cartModel.cart =
            new CartPostInfo(id: cartID, userId: loginUserID, name: 'cart');
      }
      if (productsforpost.length > 0) {
        var items =
            productsforpost.where((p) => p.itemId == categoryList.id).toList();
        print('items.length ' + items.length.toString());
        if (items != null && items.length > 0) {
          productsforpost.removeWhere((p) =>
              p.sizeId == categoryList.sizeIds &&
              p.colourId == categoryList.colourids);
          print('productsforpost.length ' + productsforpost.length.toString());

          productsforpost.add(new ItemsList(
              itemId: categoryList.id,
              quantity: categoryList.quantity,
              colourId: categoryList.colourids,
              sizeId: categoryList.sizeIds));
        } else {
          productsforpost.add(new ItemsList(
              itemId: categoryList.id,
              quantity: categoryList.quantity,
              colourId: categoryList.colourids,
              sizeId: categoryList.sizeIds));
        }
      } else {
        productsforpost.add(new ItemsList(
            itemId: categoryList.id,
            quantity: categoryList.quantity,
            colourId: categoryList.colourids,
            sizeId: categoryList.sizeIds));
      }
      print('----------------------' + gstPrice.toString());
      cartModel.items = productsforpost;
      apiConnecter.postCartUpdate(cartModel).then((cartResponce) {
        if (cartResponce == 200) {
          setState(() {
            print('Narmada ------- Added Cart Success');
            print('cartResponce response  -------' + cartResponce.toString());
            // totalPrice=
          });
        } else {
          print('-- -------- ' + cartResponce.toString());
        }
      });
      double productCost = 0.0;
      int totalQtyIndex = 0;
      double totgst = 0.0;

      for (int i = 0; i < getCartResponse.result.productsList.length; i++) {
        double item =
            getCartResponse.result.productsList[i].discountPrince.toDouble() *
                getCartResponse.result.productsList[i].quantity;
        productCost += item;

        getCartResponse.result.productsList[i].discountPrince.toDouble();
        totalQtyIndex += getCartResponse.result.productsList[i].quantity;

        double bbb =
            ((getCartResponse.result.productsList[i].discountPrince.toDouble() /
                    100.00) *
                categoryList.gst.toDouble());

        totgst += bbb * getCartResponse.result.productsList[i].quantity;
        print('jkdfjkfjkd ' + totgst.toString());
      }
      totalPrice = productCost;
      totalQTY = totalQtyIndex;
      totalGSTprice = totgst;
    });
  }

  void removefromcart(ProductsList categoryList) {
    setState(() {
      print('++++categoryList.itemCount ' + categoryList.quantity.toString());
      PostCartRequest cartModel = new PostCartRequest();
      cartModel.cart =
          new CartPostInfo(id: cartID, userId: loginUserID, name: 'cart');

      print('productsforpost.length ' + productsforpost.length.toString());

      if (productsforpost.length > 0) {
        var items =
            productsforpost.where((p) => p.itemId == categoryList.id).toList();
        print('items.length ' + items.length.toString());
        if (items != null && items.length > 0) {
          print("+++++++++++++++++++++++++++++");
          print(' ------ enter Items Quantity ' +
              items[0].itemId.toString() +
              " " +
              items[0].quantity.toString());

          productsforpost.removeWhere((p) =>
              p.sizeId == categoryList.sizeIds &&
              p.colourId == categoryList.colourids);
          productsforpost.add(new ItemsList(
              itemId: categoryList.id,
              quantity: categoryList.quantity,
              colourId: categoryList.colourids,
              sizeId: categoryList.sizeIds));

          print("+++++++++++++++++++++++++++++" +
              productsforpost.length.toString());
        } else {
          print("///////////////////////////////");
        }
      } else {}

      double bbb = ((categoryList.discountPrince.toDouble() / 100.00) *
          categoryList.gst.toDouble());
      print('gst 1 item-------' + bbb.toString());
      print('gst-------' + gstPrice.toString());
      gstPrice -= bbb;

      cartModel.items = productsforpost;
      apiConnecter.postCartUpdate(cartModel).then((cartResponce) {
        // getCartDetails(widget.userID);
        if (cartResponce == 200) {
          print('Narmada ------- Added Cart Success');
          print('cartResponce response  -------' + cartResponce.toString());
        } else {
          print('-- -------- No items' + cartResponce.toString());
          // Toast.show('Unable to Proceed', context,
          //     duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        }
      });
      double productCost = 0.0;
      double gst = 0.0;
      int totalQtyIndex = 0;
      double totgst = 0.0;
      for (int i = 0; i < getCartResponse.result.productsList.length; i++) {
        double item = getCartResponse.result.productsList[i].discountPrince *
            getCartResponse.result.productsList[i].quantity;
        productCost += item;
        double aaa = (((getCartResponse.result.productsList[i].discountPrince
                    .toDouble()) /
                100.00) *
            getCartResponse.result.productsList[i].gst.toDouble());
        totalQtyIndex += getCartResponse.result.productsList[i].quantity;
        totgst += aaa * getCartResponse.result.productsList[i].quantity;
        // gst += aaa;
      }

      totalPrice = productCost;
      totalQTY = totalQtyIndex;
      totalGSTprice = totgst;

      // totalSavingPrice = totItemsSavingPrice;
      print('----------------------' + totalPrice.toString());
    });
  }

  showProceedDialog() {
    // set up the button
    Widget okButton = Container(
        // width: 90,
        child: FlatButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
        side: BorderSide(
          width: 1.5,
          color: Constants.appColor,
        ),
      ),
      child: Text(
        "Continue",
        style: TextStyle(
          color: Constants.appColor,
          fontSize: 10.0,
          fontWeight: FontWeight.w600,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => AddressScreen(
                  isFromCart: true,
                )));
      },
    ));

    Widget cancelButton = FlatButton(
      child: Text(
        "Cancel",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Constants.greyColor,
          fontSize: 10.0,
        ),
        overflow: TextOverflow.clip,
      ),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
    );
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
                        'Rupdarshi',
                        style: TextStyle(
                            color: Constants.greyColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 16),
                        overflow: TextOverflow.clip,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'Do you want to proceed?',
                        overflow: TextOverflow.clip,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            cancelButton,
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

  showAlertDialog(BuildContext context, int index) {
    // set up the button
    Widget okButton = FlatButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
        side: BorderSide(
          width: 1,
          color: Constants.appColor,
        ),
      ),
      child: Text(
        "Remove",
        style: TextStyle(
          color: Constants.appColor,
          fontSize: 10.0,
          fontWeight: FontWeight.w600,
        ),
        overflow: TextOverflow.clip,
      ),
      onPressed: () {
        setState(() {
          // Navigator.of(context).push(
          //              new MaterialPageRoute(builder: (context) =>new HomeScreen()));
          if (cartitemcount == 1) {
            deleteCart(loginUserID.toString());
          } else {
            // deleteCart(loginUserID.toString());
            removeItemfromcart(getCartResponse.result.productsList[index]);
          }
          Navigator.of(context, rootNavigator: true).pop();
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
        "Cancel",
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
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'Remove Item',
                        style: TextStyle(
                            color: Constants.appColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 14),
                        overflow: TextOverflow.clip,
                      ),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'Are you sure you want to remove this item?',
                        overflow: TextOverflow.clip,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
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

  deleteCartAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = FlatButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
        side: BorderSide(
          width: 1,
          color: Constants.appColor,
        ),
      ),
      child: Text(
        "Delete",
        style: TextStyle(
          color: Constants.appColor,
          fontSize: 10.0,
          fontWeight: FontWeight.w600,
        ),
      ),
      onPressed: () {
        setState(() {
          deleteCart(loginUserID.toString());

          Navigator.of(context, rootNavigator: true).pop();
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
        "Cancel",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Constants.appColor,
          fontSize: 10.0,
        ),
      ),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
    );

    // set up the AlertDialog
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
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'Delete Cart',
                        style: TextStyle(
                            color: Constants.appColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 14),
                      ),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'Are you sure you want to delete all items from cart?',
                        overflow: TextOverflow.clip,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
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

  addToWishListAPICall(bool isFaverate, int itemID) {
    String addToWishListURL = ApiService.baseUrl + ApiService.addToWishlist;

    Map<String, dynamic> parameters = {
      "VendorId": loginUserID,
      "ItemId": itemID
    };
    apiConnecter.postAPICall(addToWishListURL, parameters).then((response) {
      if (response["IsSuccess"] == true) {
        apiConnecter.globalToast(response["EndUserMessage"]);
        print(response["EndUserMessage"]);
        setState(() {});
      }
    });
  }

  removeFromWishListAPICall(bool isFaverate, int itemID) {
    String removeFromWishListURL =
        ApiService.baseUrl + ApiService.removeFromishList;

    Map<String, dynamic> parameters = {
      "VendorId": loginUserID,
      "ItemId": itemID
    };

    apiConnecter
        .postAPICall(removeFromWishListURL, parameters)
        .then((response) {
      print(response);
      if (response["IsSuccess"] == true) {
        print(response["EndUserMessage"]);
        apiConnecter.globalToast(response["EndUserMessage"]);
        setState(() {});
      }
    });
  }

  void removeItemfromcart(ProductsList categoryList) {
    setState(() {
      print('++++categoryList.itemCount ' + categoryList.quantity.toString());
      PostCartRequest cartModel = new PostCartRequest();
      cartModel.cart =
          new CartPostInfo(id: cartID, userId: loginUserID, name: 'cart');

      print('postCartUpdate :' + cartModel.toJson().toString());
      print("productsforpost count Before remove item from cart - > " +
          productsforpost.length.toString());

      if (productsforpost.length > 0) {
        var items =
            productsforpost.where((p) => p.itemId == categoryList.id).toList();
        var itemsColor = productsforpost
            .where((p) => p.colourId == categoryList.colourids)
            .toList();
        var itemsSize = productsforpost
            .where((p) => p.sizeId == categoryList.sizeIds)
            .toList();

        print('items.length ' + items.length.toString());
        if (items != null && items.length > 0) {
          if (itemsColor != null &&
              itemsColor.length > 0 &&
              itemsSize != null &&
              itemsSize.length > 0) {
            productsforpost.removeWhere((item) =>
                item.itemId == categoryList.id &&
                item.colourId == categoryList.colourids &&
                item.sizeId == categoryList.sizeIds);
          }
        } else {
          print("///////////////////////////////");
        }
      } else {}
      cartModel.items = productsforpost;

      print("productsforpost count after remove item from cart - > " +
          productsforpost.length.toString());

      print('postCartUpdate :' + cartModel.toJson().toString());

      apiConnecter.postCartUpdate(cartModel).then((cartResponce) {
        if (cartResponce["IsSuccess"] == true) {
          print('Narmada ------- Added Cart Success');
          print('cartResponce response  -------' + cartResponce.toString());
          apiConnecter.globalToast(cartResponce["EndUserMessage"]);
          getCartDetails(widget.userID);
        } else {
          print('-- -------- No items' + cartResponce.toString());
        }
      });
    });
  }

  getCartDetails(String userID) async {
    gstPrice = 0.0;

    print(" selected Userid -- > " + this.widget.userID);
    String finalUrl = ApiService.baseUrl + ApiService.getCartURL + userID;
    print(" finalUrl -- > " + finalUrl);
    await apiConnecter.getCartApiCall(finalUrl).then((response) {
      print(" GetCartByUserID -- > " + response.toString());

      setState(() {
        firstLoading = false;
        getCartResponse = GetCartResponse.fromJson(response);
        if (getCartResponse != null && getCartResponse.result != null) {
          cartitemcount = getCartResponse.result.productsList.length;
          cartID = getCartResponse.result.cart.id;
          print(" QUANTITY -- > " + cartitemcount.toString());
          print(" itemDetailsResponse -- > " +
              getCartResponse.result.productsList.length.toString());
          double productCost = 0.0;
          int totalQtyIndex = 0;
          for (int i = 0; i < getCartResponse.result.productsList.length; i++) {
            print(getCartResponse.result.productsList[i].colourids);
            print(getCartResponse.result.productsList[i].sizeIds);
            productsforpost.add(new ItemsList(
                itemId: getCartResponse.result.productsList[i].id,
                quantity: getCartResponse.result.productsList[i].quantity,
                colourId: getCartResponse.result.productsList[i].colourids,
                sizeId: getCartResponse.result.productsList[i].sizeIds));

            double item = getCartResponse.result.productsList[i].discountPrince
                    .toDouble() *
                getCartResponse.result.productsList[i].quantity;

            double aaa = (((getCartResponse
                            .result.productsList[i].discountPrince
                            .toDouble()) /
                        100.00) *
                    getCartResponse.result.productsList[i].gst.toDouble()) *
                getCartResponse.result.productsList[i].quantity.toDouble();

            totalQtyIndex += getCartResponse.result.productsList[i].quantity;
            // print('g s t  g s t' + aaa.toString());
            gstPrice += aaa;
            productCost += item;
          }
          totalPrice = productCost;
          totalQTY = totalQtyIndex;
          totalGSTprice = gstPrice;

          print('gstPrice hen comming from cart' + totalQTY.toString());
        } else {
          errorMessage = "Cart is empty";
          cartitemcount = 0;
        }
      });
    }).catchError((onError) {});
  }

  deleteCart(String userID) async {
    print(" selected Userid -- > " + this.widget.userID);
    String finalUrl = ApiService.baseUrl + ApiService.deleteCartURL + userID;
    await apiConnecter.deleteCartApiCall(finalUrl).then((response) {
      print(" DeleteCartByUserID -- > " + response.toString());
      setState(() {
        deleteCartResponse = DeleteCartResponse.fromJson(response);
        // getCartResponse.result.productsList[0] = null;
        // cartitemcount=getCartResponse.result.productsList[0].quantity;
        print(" itemDetailsResponse -- > " + response.toString());
        getCartDetails(widget.userID);
      });
    });
  }

  showLoadingDialog(BuildContext context) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new WillPopScope(
              onWillPop: () async => false,
              child: SimpleDialog(
                  backgroundColor: Colors.black54,
                  children: <Widget>[
                    Center(
                      child: Column(children: [
                        CircularProgressIndicator(),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Please Wait....",
                          style: TextStyle(color: Colors.blueAccent),
                        )
                      ]),
                    )
                  ]));
        });
  }

  void backnavigation() {
    if (widget.isFromItemDetails == true) {
      setState(() {
        print('Refresh Item');
        widget.refresh(); // just refresh() if its statelesswidget
        Navigator.pop(context);
      });
    } else if (widget.isFromHome == true) {
      print('Refresh Home');
      widget.refresh(); // just refresh() if its statelesswidget
      Navigator.pop(context);
    } else if (widget.isfromNewHome == true) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => NewHomeScreen()));
    } else if (widget.isFromCategory == true) {
      print('Refresh Category screen');
      widget.refresh(); // just refresh() if its statelesswidget
      Navigator.pop(context);
    } else if (widget.isFromWishlist == true) {
      print('Refresh Wishlist screen');
      widget.refresh(); // just refresh() if its statelesswidget
      Navigator.pop(context);
    } else {
      Navigator.pop(context);
    }
  }
}

class Dialogs {
  static Future<void> showLoadingDialog(
      BuildContext context, GlobalKey key) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new WillPopScope(
              onWillPop: () async => false,
              child: SimpleDialog(
                  key: key,
                  backgroundColor: Colors.black54,
                  children: <Widget>[
                    Center(
                      child: Column(children: [
                        CircularProgressIndicator(),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Please Wait....",
                          style: TextStyle(color: Colors.blueAccent),
                        )
                      ]),
                    )
                  ]));
        });
  }
}

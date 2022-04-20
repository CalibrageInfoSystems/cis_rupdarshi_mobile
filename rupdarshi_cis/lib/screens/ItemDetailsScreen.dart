import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

// import 'package:pinch_zoom_image_last/pinch_zoom_image_last.dart';
// import 'package:photo_view/photo_view.dart';
// import 'package:photo_view/photo_view_gallery.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:rupdarshi_cis/Model/AddtoCartResponse.dart';
import 'package:rupdarshi_cis/Model/CategoriesByIDResponse.dart';
import 'package:rupdarshi_cis/Model/GetCartResponse.dart';
import 'package:rupdarshi_cis/Model/ItemDetailsResponse.dart';
import 'package:rupdarshi_cis/Model/Requests/PlaceOerderRequest.dart';
import 'package:rupdarshi_cis/Model/Requests/PostCartRequest.dart';
import 'package:rupdarshi_cis/Service/ApiService.dart';
import 'package:rupdarshi_cis/common/Constants.dart';
import 'package:rupdarshi_cis/common/LocalDb.dart';
import 'package:rupdarshi_cis/screens/CartScreen.dart';
import 'package:photo_view/photo_view.dart';
import 'package:rupdarshi_cis/screens/Home_screen.dart';
import 'package:transparent_image/transparent_image.dart';
import 'NewHomeScreen.dart';
import 'WishList.dart';

import 'Address.dart';

RegExp reg1 = new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
Function mathFunc1 = (Match match) => '${match[1]},';

extension CapExtension on String {
  String get inCaps => '${this[0].toUpperCase()}${this.substring(1)}';
  String get allInCaps => this.toUpperCase();
}

ItemDetailsResponse itemDetailsResponse;

class ItemDetailsScreen extends StatefulWidget {
  final String itemID;
  bool isWishList;
  bool isFromWishList;
  bool isFromCart;
  bool isFromProductList;
  final Function refresh;
  bool isFromCategory;
  bool isFromHome;
  ItemDetailsScreen(
      {this.itemID,
      this.isWishList,
      this.isFromWishList,
      this.isFromCart,
      this.isFromProductList,
      this.refresh,
      this.isFromCategory,
      this.isFromHome});
  @override
  _ItemDetailsScreenState createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  TextEditingController itemCountController = new TextEditingController();

  PlaceOerderRequestModel placeOerderRequestModel;
  List<Product> products;
  bool alradyColor = false;
  bool alreadySize = false;

  String appBarTitle = "";
  var savingPrice;
  var images = [];
  bool firstLoading = true;

  ProgressDialog progressHud;

  bool isAlreadyInCart = false;
  bool isColorVisible = false;
  bool isSizeVisible = false;
  bool isActiveColor = false;
  int oldColorIndex = -1;
  int oldSizeIndex = -2;
  int activeColorID = 0;
  bool isActiveSize = false;
  int activeSizeID = 0;
  int cartID = 0;
  int loginUserID = 0;
  int cartitemcount = 0;
  int itemCount = 1;
  int selectedcolorIndex = 0;

  String colorError = "Yes";
  String sizeError = "Yes";

  GetCartResponse cartModelfromAPI;
  // List<CategoriesByIDListResult> cartProducts = [];
  List<ItemsList> productsforpost;
  AddtoCartResponse addtoCartResponse;
  GetCartResponse getCartResponse;
  PostCartRequest postCartRequest;
  LocalData localData = new LocalData();
  List<Item> listItemSizes = new List();
  // List<Item> listItemColors= new List();
  List<String> listItemColor = new List();
  List<String> listItemSize = new List();
  List<bool> listColorID = new List();
  List<bool> listSizeID = new List();

  void addItemColor() {
    listItemColor.add("Blue");
    listItemColor.add("Yellow");
    listItemColor.add("Red");
  }

  void addItemColorID() {
    listColorID.add(false);
    listColorID.add(false);
    listColorID.add(false);
  }

  void addItemSize() {
    listItemSize.add("S");
    listItemSize.add("M");
    listItemSize.add("L");
  }

  void addItemSizeID() {
    listSizeID.add(false);
    listSizeID.add(false);
    listSizeID.add(false);
  }

  int photoIndex = 0;
  int colorImageIndex = 0;
  List<String> photos = [
    'assets/sarees2.jpg',
    'assets/sarees2.jpg',
  ];

  Widget imageCarousel = SizedBox(
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Carousel(
        dotSize: 4.0,
        dotSpacing: 15.0,
        dotColor: Constants.dotColor,
        indicatorBgPadding: 5.0,
        dotBgColor: Colors.white,
        borderRadius: false,
        moveIndicatorFromBottom: 180.0,
        noRadiusForIndicator: true,
        overlayShadow: true,
        autoplay: false,
        // overlayShadowColors: Colors.green,
        overlayShadowSize: 0.4,
        dotIncreasedColor: Constants.greyColor,
        images: [
          new Image.asset('assets/sarees2.jpg', fit: BoxFit.fill),
          new Image.asset('assets/sarees3.jpg', fit: BoxFit.fill),
        ],
        animationCurve: Curves.fastOutSlowIn,
        animationDuration: Duration(microseconds: 1500),
      ),
    ),
  );

  bool pressed = true;
  String colorName = "";
  var _currentAmount = 0;

  // Result result;
  ApiService apiConnector;

  refresh() async {
    setState(() {
      print('Refresh ItemDetails');
      localData.getIntToSF(LocalData.USERID).then((userid) {
        setState(() {
          String cartURL =
              ApiService.baseUrl + ApiService.getCartURL + userid.toString();

          apiConnector.getCartApiCall(cartURL).then((response) {
            print(" GetCartByUserID -- > " + response.toString());

            setState(() {
              // progressHud.hide();
              getCartResponse = GetCartResponse.fromJson(response);
              if (getCartResponse != null && getCartResponse.result != null) {
                cartitemcount = getCartResponse.result.productsList.length;
                cartID = getCartResponse.result.cart.id;
                print(" cartitemcount -- > " + cartitemcount.toString());
                print(" cartResponse -- > " +
                    getCartResponse.result.productsList.length.toString());
              } else {
                setState(() {
                  cartitemcount = 0;
                });
                print(" cartResponse -- > " +
                    getCartResponse.result.productsList.length.toString());
              }
            });
          }).catchError((onError) {});
        });

        Future.delayed(Duration.zero, () {});
      });
    });
  }

  @override
  void initState() {
    super.initState();
    itemCountController.text = itemCount.toString();
    addItemColor();
    addItemSize();
    addItemColorID();
    addItemSizeID();
    appBarTitle = "";
    colorError = "Yes";
    sizeError = "Yes";
    selectedcolorIndex = 0;
    firstLoading = true;
    apiConnector = new ApiService();
    cartitemcount = 0;
    itemCount = 1;
    isAlreadyInCart = false;
    itemDetailsResponse = new ItemDetailsResponse();
    addtoCartResponse = new AddtoCartResponse();
    productsforpost = new List<ItemsList>();
    getCartResponse = new GetCartResponse();
    // result = new Result();

    print(" selected no -- > " + this.widget.itemID);
    print(this.widget.isWishList);

    getLocalDB();
  }

  getLocalDB() {
    itemCount = 1;
    activeColorID = 0;
    activeSizeID = 0;
    isActiveSize = false;
    isActiveColor = false;
    alradyColor = false;
    alreadySize = false;
    localData.getIntToSF(LocalData.USERID).then((userid) {
      setState(() {
        loginUserID = userid;
        print(" ******** loginUserID  " + loginUserID.toString());
        getItemDetails(this.widget.itemID);
        cartID = 0;

        String cartURL =
            ApiService.baseUrl + ApiService.getCartURL + userid.toString();

        apiConnector.getCartApiCall(cartURL).then((response) {
          print(" GetCartByUserID -- > " + response.toString());

          setState(() {
            // progressHud.hide();
            getCartResponse = GetCartResponse.fromJson(response);
            if (getCartResponse != null && getCartResponse.result != null) {
              cartitemcount = getCartResponse.result.productsList.length;
              cartID = getCartResponse.result.cart.id;
              print(" cartitemcount -- > " + cartitemcount.toString());
              print(" cartResponse -- > " +
                  getCartResponse.result.productsList.length.toString());
            } else {
              print(" cartResponse -- > " +
                  getCartResponse.result.productsList.length.toString());
            }
          });
        }).catchError((onError) {});
      });

      Future.delayed(Duration.zero, () {});
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double itemHeight = (size.height) / 3.2;
    final double itemWidth = size.width / 2;

    return WillPopScope(
      onWillPop: () {
        backnavigation();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            appBarTitle,
            style: TextStyle(
              color: Constants.greyColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          backgroundColor: Constants.bgColor,
          leading: GestureDetector(
            onTap: () {
              if (widget.isFromCart == true) {
                print('Category screen');
                widget.refresh();
                Navigator.pop(context);
                // Navigator.of(context).pushReplacement(MaterialPageRoute(
                //     builder: (context) =>
                //         CartScreen(userID: loginUserID.toString())));
              } else if (widget.isFromWishList == true) {
                print(widget.isFromHome);
                Navigator.pop(context);
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => WishListScreen(
                        userID: loginUserID.toString(),
                        isFromHome: this.widget.isFromHome)));
              } else if (widget.isFromCategory == true) {
                print('Category screen');
                widget.refresh(); // just refresh() if its statelesswidget
                Navigator.pop(context);
                // Navigator.pop(context);
                // Navigator.of(context).push(MaterialPageRoute(
                //                     builder: (context) => CategoriesScreen(
                //                           categoryID: value.id.toString(),
                //                           categoryName: value.name,
                //                           fromHomeSearch: false,
                //                           subCategory: this.widget.subCategory,
                //                         )));
              } else {
                Navigator.pop(context);
              }
            },
            child: Icon(
              Icons.keyboard_arrow_left,
              size: 35,
              color: Constants.blackColor, // add custom icons also
            ),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: GestureDetector(
                child: Icon(
                  Icons.home,
                  size: 25,
                  color: Constants.greyColor,
                ),
                onTap: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => NewHomeScreen()));
                },
              ),
            ),
            Padding(
                padding: EdgeInsets.only(top: 10, bottom: 10, right: 20.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => CartScreen(
                            userID: loginUserID.toString(),
                            isFromItemDetails: true,
                            refresh: refresh)));
                  },
                  child: Badge(
                    // alignment: Alignment.topRight,
                    // position: BadgePosition.topRight(),
                    badgeColor: Colors.red,
                    badgeContent: Text(
                      cartitemcount.toString(),
                      style: TextStyle(fontSize: 12),
                    ),
                    child: Icon(
                      Icons.shopping_cart,
                      size: 25,
                      color: Constants.greyColor,
                    ),
                  ),
                )),
          ],
        ),
        backgroundColor: Constants.bgColor,
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
            : Container(
                child: SingleChildScrollView(
                  child: itemDetailsResponse.result == null
                      ? Container()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                                // color: Colors.grey.shade300,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(30.0),
                                      bottomRight: Radius.circular(30.0)),
                                  color: Constants.bgGreyColor,
                                ),
                                height: itemHeight,
                                child: Stack(children: <Widget>[
                                  GestureDetector(
                                    onTap: () {},
                                    child: images == null && images.length < 0
                                        ? Image.asset('assets/Rupdarshi.jpg')
                                        : Container(
                                            child: SizedBox(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Carousel(
                                                  dotSize: 6.0,
                                                  dotSpacing: 15.0,
                                                  dotColor:
                                                      Constants.lightgreyColor,
                                                  indicatorBgPadding: 5.0,
                                                  dotBgColor:
                                                      Constants.bgGreyColor,
                                                  borderRadius: false,
                                                  moveIndicatorFromBottom:
                                                      180.0,
                                                  noRadiusForIndicator: true,
                                                  overlayShadow: true,
                                                  autoplay: false,
                                                  // overlayShadowColors: Colors.green,
                                                  overlayShadowSize: 0.4,
                                                  dotIncreasedColor:
                                                      Constants.greyColor,
                                                  images: images,
                                                  animationCurve:
                                                      Curves.fastOutSlowIn,
                                                  animationDuration: Duration(
                                                    microseconds: 1500,
                                                  ),
                                                  onImageTap: (int imageIndex) {
                                                    print(
                                                        "++++++++++++++++++++++");
                                                    //  print(itemDetailsResponse);
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              MySecondScreen(
                                                            itemFileRepositories:
                                                                itemDetailsResponse
                                                                    .result
                                                                    .itemFileRepositories,
                                                            clickedimageIndex:
                                                                imageIndex,
                                                            title: appBarTitle,
                                                            itemDetailsResponse:
                                                                itemDetailsResponse,
                                                          ),
                                                        ));
                                                  },
                                                ),
                                              ),
                                            ),
                                            height: 400,
                                            // width: 300,
                                          ),
                                  ),
                                  // imageCarousel,
                                  Positioned(
                                    bottom: 0,
                                    right: 20,
                                    child: GestureDetector(
                                      child: Container(
                                          padding: const EdgeInsets.all(5.0),
                                          decoration: BoxDecoration(
                                            boxShadow: <BoxShadow>[
                                              BoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.3),
                                                blurRadius: 1,
                                                offset: Offset(2, 2),
                                              ),
                                            ],
                                            shape: BoxShape.circle,
                                            color: Constants.bgColor,
                                          ),
                                          child: this.widget.isWishList == true
                                              ? Icon(Icons.favorite,
                                                  color: Colors.pink)
                                              : Icon(Icons.favorite_border)),
                                      onTap: () {
                                        setState(() {
                                          if (this.widget.isWishList == true) {
                                            this.widget.isWishList = false;
                                            print(
                                                "***** Favarate Removed Clicked *****");
                                            removeFromWishListAPICall(
                                                false,
                                                itemDetailsResponse
                                                    .result.itemDetails.id);
                                          } else {
                                            this.widget.isWishList = true;
                                            addToWishListAPICall(
                                                false,
                                                itemDetailsResponse
                                                    .result.itemDetails.id);
                                            print(
                                                "***** Favarate Added Clicked *****");
                                          }
                                          print("***** Favarate Clicked *****");
                                        });
                                      },
                                    ),
                                  ),
                                  Positioned(
                                    top: 10,
                                    right: 20,
                                    child: itemDetailsResponse.result
                                                    .itemDetails.discount ==
                                                0 ||
                                            itemDetailsResponse.result
                                                    .itemDetails.discount ==
                                                0.0
                                        ? Container()
                                        : Container(
                                            padding: const EdgeInsets.all(7.0),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Constants.appColor,
                                            ),
                                            child: Text(
                                              itemDetailsResponse.result
                                                      .itemDetails.discount
                                                      .toStringAsFixed(0) +
                                                  '%\nOff',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 10),
                                              overflow: TextOverflow.clip,
                                            )),
                                  ),
                                ])),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 8.0, right: 8.0, top: 8.0),
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Column(
                                  children: <Widget>[
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        itemDetailsResponse.result.itemDetails
                                            .itemTypename.inCaps,
                                        style: TextStyle(
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.w600,
                                          color: Constants.appColor,
                                        ),
                                        overflow: TextOverflow.clip,
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        itemDetailsResponse
                                            .result.itemDetails.name.inCaps,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Constants.greyColor,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Column(
                                      children: <Widget>[
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Row(
                                              children: [
                                                Text(
                                                  '₹ ' +
                                                      itemDetailsResponse
                                                          .result
                                                          .itemDetails
                                                          .discountPrince
                                                          .toStringAsFixed(0)
                                                          .replaceAllMapped(
                                                              reg1, mathFunc1),
                                                  style: new TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        Constants.boldTextColor,
                                                    fontSize: 18,
                                                  ),
                                                  overflow: TextOverflow.clip,
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    itemDetailsResponse
                                                                    .result
                                                                    .itemDetails
                                                                    .discount ==
                                                                0 ||
                                                            itemDetailsResponse
                                                                    .result
                                                                    .itemDetails
                                                                    .discount ==
                                                                0.0
                                                        ? ''
                                                        : '₹' +
                                                            itemDetailsResponse
                                                                .result
                                                                .itemDetails
                                                                .wholeSalePrice
                                                                .toStringAsFixed(
                                                                    0)
                                                                .replaceAllMapped(
                                                                    reg1,
                                                                    mathFunc1),
                                                    style: TextStyle(
                                                      decoration: TextDecoration
                                                          .lineThrough,
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Constants
                                                          .lightgreyColor,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                Text(
                                                  itemDetailsResponse
                                                                  .result
                                                                  .itemDetails
                                                                  .discount ==
                                                              0.0 ||
                                                          itemDetailsResponse
                                                                  .result
                                                                  .itemDetails
                                                                  .discount ==
                                                              0
                                                      ? ""
                                                      : "Save ₹${savingPrice.toStringAsFixed(0)}"
                                                          .replaceAllMapped(
                                                              reg1, mathFunc1),
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    // fontStyle: FontStyle.italic,
                                                    fontWeight: FontWeight.w600,
                                                    color: Constants.greyColor,
                                                  ),
                                                  overflow: TextOverflow.clip,
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 0.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: <Widget>[
                                                  SizedBox(
                                                    width: 50,
                                                  ),
                                                  Align(
                                                    alignment:
                                                        Alignment.topRight,
                                                    child: Container(
                                                      child: Row(
                                                        children: <Widget>[
                                                          GestureDetector(
                                                            child: Container(
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        3.0),
                                                                child: Icon(
                                                                  Icons.remove,
                                                                  color: Constants
                                                                      .greyColor,
                                                                  size: 20.0,
                                                                ),
                                                              ),
                                                            ),
                                                            onTap: () {
                                                              if (itemCount >
                                                                  1) {
                                                                setState(() {
                                                                  itemCount--;
                                                                  itemCountController
                                                                          .text =
                                                                      itemCount
                                                                          .toString();
                                                                  // itemCountController.clear();
                                                                  // removefromcart(categoryList)
                                                                });
                                                              }
                                                            },
                                                          ),
                                                          Container(
                                                              height: 25,
                                                              width: 40,
                                                              child:
                                                                  TextFormField(
                                                                maxLength: 4,
                                                                // initialValue: "1",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        13),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                controller:
                                                                    itemCountController,
                                                                keyboardType:
                                                                    TextInputType
                                                                        .text,
                                                                inputFormatters: <
                                                                    TextInputFormatter>[
                                                                  WhitelistingTextInputFormatter
                                                                      .digitsOnly
                                                                ],
                                                                decoration:
                                                                    InputDecoration(
                                                                        counterText:
                                                                            "",
                                                                        contentPadding: EdgeInsets.only(
                                                                            top:
                                                                                6.0,
                                                                            left:
                                                                                5,
                                                                            right:
                                                                                5,
                                                                            bottom:
                                                                                3.0),
                                                                        hintText:
                                                                            "1",
                                                                        labelStyle: TextStyle(
                                                                            color: Constants
                                                                                .lightgreyColor,
                                                                            fontSize:
                                                                                4,
                                                                            fontWeight: FontWeight
                                                                                .w600),
                                                                        focusedBorder:
                                                                            OutlineInputBorder(
                                                                          borderSide: BorderSide(
                                                                              color: Constants.blackColor,
                                                                              width: 1),
                                                                        ),
                                                                        border:
                                                                            new OutlineInputBorder(
                                                                          borderSide:
                                                                              BorderSide(),
                                                                        )),
                                                                onChanged:
                                                                    (value) {
                                                                  value =
                                                                      itemCountController
                                                                          .text;
                                                                  itemCount =
                                                                      int.parse(
                                                                          value);
                                                                  // itemCountController.text == null || itemCountController.text == "" ? itemCountController.text="1" : itemCount.toString();
                                                                },
                                                                onSaved:
                                                                    (newValue) {
                                                                  setState(() {
                                                                    newValue =
                                                                        itemCountController
                                                                            .text;
                                                                    itemCount =
                                                                        int.parse(
                                                                            newValue);
                                                                    print('ItemCount Tadded text ' +
                                                                        itemCount
                                                                            .toString());
                                                                    //  itemCountController.clear();
                                                                    // itemCountController.text == null || itemCountController.text == "" ? itemCountController.text="1" : itemCount.toString();
                                                                  });
                                                                },
                                                              )

                                                              // Text(
                                                              //   itemCount
                                                              //       .toString(),
                                                              //   style: TextStyle(
                                                              //       fontWeight:
                                                              //           FontWeight
                                                              //               .w600,
                                                              //       color: Constants
                                                              //           .greyColor,
                                                              //       fontSize: 16.0),
                                                              // ),

                                                              ),
                                                          GestureDetector(
                                                            child: Container(
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        3.0),
                                                                child: Icon(
                                                                  Icons.add,
                                                                  color: Constants
                                                                      .greyColor,
                                                                  size: 20.0,
                                                                ),
                                                              ),
                                                            ),
                                                            onTap: () {
                                                              setState(() {
                                                                itemCount++;
                                                                itemCountController
                                                                        .text =
                                                                    itemCount
                                                                        .toString();
                                                                print('itemc-------------' +
                                                                    itemCount
                                                                        .toString());
                                                                //  itemCountController.clear();
                                                                // updateCart(categoryList);
                                                              });
                                                            },
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
                                      ],
                                    ),
                                    SizedBox(height: 5),
                                    Row(
                                      children: [
                                        Text(
                                          ' *This price is exclusive of GST ' +
                                              itemDetailsResponse
                                                  .result.itemDetails.gst
                                                  .toStringAsFixed(0) +
                                              " %",
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black54,
                                          ),
                                          overflow: TextOverflow.clip,
                                        ),
                                      ],
                                    ),
                                    Divider(
                                      color: Constants.lightgreyColor,
                                    ),
                                    SizedBox(height: 10.0),
                                    itemDetailsResponse
                                                .result.itemColours.length >
                                            0
                                        ? Column(
                                            children: [
                                              Align(
                                                alignment: Alignment.topLeft,
                                                child: Column(
                                                  children: <Widget>[
                                                    Text(
                                                      'Select Colour',
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Constants
                                                            .boldTextColor,
                                                      ),
                                                      overflow:
                                                          TextOverflow.clip,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              SizedBox(
                                                height: 40,
                                                child: ListView.builder(
                                                  primary: false,
                                                  itemCount: itemDetailsResponse
                                                      .result
                                                      .itemColours
                                                      .length,
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  // shrinkWrap: true,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          colorError = "Yes";
                                                          // itemDetailsResponse.result.itemColours[oldColorIndex].isSelectedColor =true;
                                                          for (int n = 0;
                                                              n <
                                                                  itemDetailsResponse
                                                                      .result
                                                                      .itemFileRepositories
                                                                      .length;
                                                              n++) {
                                                            if (itemDetailsResponse
                                                                    .result
                                                                    .itemColours[
                                                                        index]
                                                                    .id ==
                                                                itemDetailsResponse
                                                                    .result
                                                                    .itemFileRepositories[
                                                                        n]
                                                                    .colourId) {
                                                              print(itemDetailsResponse
                                                                  .result
                                                                  .itemColours[
                                                                      index]
                                                                  .id
                                                                  .toString());
                                                              print(itemDetailsResponse
                                                                  .result
                                                                  .itemFileRepositories[
                                                                      n]
                                                                  .id
                                                                  .toString());

                                                              setState(() {
                                                                images = [
                                                                  CachedNetworkImage(
                                                                      // fit: BoxFit.fill,
                                                                      imageUrl: itemDetailsResponse
                                                                          .result
                                                                          .itemFileRepositories[
                                                                              n]
                                                                          .fileLocation)
                                                                ];
                                                              });
                                                            }
                                                          }

                                                          print('narmadaa----' +
                                                              index.toString());
                                                          if (oldColorIndex !=
                                                              -1) {
                                                            print(
                                                                oldColorIndex);
                                                            itemDetailsResponse
                                                                .result
                                                                .itemColours[
                                                                    oldColorIndex]
                                                                .isSelectedColor = false;
                                                          }
                                                          oldColorIndex = index;
                                                          if (itemDetailsResponse
                                                                  .result
                                                                  .itemColours[
                                                                      index]
                                                                  .isSelectedColor ==
                                                              true) {
                                                            itemDetailsResponse
                                                                    .result
                                                                    .itemColours[
                                                                        index]
                                                                    .isSelectedColor =
                                                                false;
                                                          } else {
                                                            print(
                                                                "tttttttttttttt");
                                                            itemDetailsResponse
                                                                    .result
                                                                    .itemColours[
                                                                        index]
                                                                    .isSelectedColor =
                                                                true;
                                                          }

                                                          isActiveColor =
                                                              itemDetailsResponse
                                                                  .result
                                                                  .itemColours[
                                                                      index]
                                                                  .isSelectedColor;
                                                          activeColorID =
                                                              isActiveColor ==
                                                                      true
                                                                  ? itemDetailsResponse
                                                                      .result
                                                                      .itemColours[
                                                                          index]
                                                                      .id
                                                                  : 0;
                                                        });

                                                        print(
                                                            itemDetailsResponse
                                                                .result
                                                                .itemColours[
                                                                    index]
                                                                .id);
                                                        print(
                                                            itemDetailsResponse
                                                                .result
                                                                .itemColours[
                                                                    index]
                                                                .name);
                                                        print(itemDetailsResponse
                                                            .result
                                                            .itemColours[index]
                                                            .isSelectedColor);

                                                        print(
                                                            "--Selected color index -> " +
                                                                index
                                                                    .toString());
                                                      },
                                                      child: Container(
                                                        height: 40,
                                                        child: Align(
                                                          alignment:
                                                              Alignment.center,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(5.0),
                                                            child: Text(
                                                              itemDetailsResponse
                                                                  .result
                                                                  .itemColours[
                                                                      index]
                                                                  .name
                                                                  .toString(),
                                                              style: TextStyle(
                                                                  fontSize: 13,
                                                                  color: Constants
                                                                      .greyColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                              overflow:
                                                                  TextOverflow
                                                                      .clip,
                                                            ),
                                                          ),
                                                        ),
                                                        margin: EdgeInsets.only(
                                                            top: 4,
                                                            bottom: 4,
                                                            right: 10),
                                                        // width: 30,
                                                        // height: 30,
                                                        decoration:
                                                            BoxDecoration(
                                                          boxShadow: <
                                                              BoxShadow>[
                                                            BoxShadow(
                                                              color:
                                                                  Colors.white,
                                                              blurRadius: 3,
                                                              offset:
                                                                  Offset(2, 2),
                                                            ),
                                                          ],
                                                          border: itemDetailsResponse
                                                                      .result
                                                                      .itemColours[
                                                                          index]
                                                                      .isSelectedColor ==
                                                                  true
                                                              ? Border.all(
                                                                  color: Constants
                                                                      .appColor,
                                                                  width: 1.5)
                                                              : Border.all(
                                                                  color: Colors
                                                                      .grey,
                                                                  width: 1.5),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                          // color: listItemSizes[index].name.toString()
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          )
                                        : Container(),
                                    colorError == null
                                        ? Align(
                                            alignment: Alignment.topLeft,
                                            child: Text(
                                              "Please select colour",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.red),
                                            ),
                                          )
                                        : Container(),
                                    itemDetailsResponse
                                                .result.itemSizes.length >
                                            0
                                        ? Column(
                                            children: [
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Column(
                                                children: <Widget>[
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Align(
                                                        alignment:
                                                            Alignment.topLeft,
                                                        child: Text(
                                                          //  itemDetailsResponse.result.itemSizes.length.toString()==null?'':
                                                          'Select Size'.inCaps,
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            // fontFamily: 'RobotoMono',
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Constants
                                                                .boldTextColor,
                                                          ),
                                                          overflow:
                                                              TextOverflow.clip,
                                                        ),
                                                      ),
                                                      GestureDetector(
                                                        onTap: () {
                                                          showModalBottomSheet(
                                                              backgroundColor:
                                                                  Colors
                                                                      .transparent,
                                                              context: context,
                                                              builder:
                                                                  (BuildContext
                                                                      bc) {
                                                                return Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          2.0),
                                                                  child:
                                                                      Container(
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5),
                                                                      // borderRadius:
                                                                      //     BorderRadius.circular(
                                                                      //         10),
                                                                      color: Colors
                                                                          .white,
                                                                      boxShadow: [
                                                                        BoxShadow(
                                                                            color:
                                                                                Colors.transparent,
                                                                            spreadRadius: 10),
                                                                      ],
                                                                    ),
                                                                    //color: Colors.green,
                                                                    child:
                                                                        Padding(
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                              8.0),
                                                                      child:
                                                                          Container(
                                                                        //  color: Colors.red,
                                                                        child:
                                                                            new Wrap(
                                                                          children: <
                                                                              Widget>[
                                                                            Column(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                                              children: <Widget>[
                                                                                Align(
                                                                                    alignment: Alignment.topLeft,
                                                                                    child: Text(
                                                                                      'Size Chart',
                                                                                      style: TextStyle(
                                                                                        fontSize: 15,
                                                                                        fontWeight: FontWeight.bold,
                                                                                        color: Constants.greyColor,
                                                                                      ),
                                                                                    )),
                                                                                Padding(
                                                                                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                                                                                  child: Container(
                                                                                    height: 1.5,
                                                                                    color: Colors.grey[400],
                                                                                  ),
                                                                                ),
                                                                                SizedBox(
                                                                                  height: 10,
                                                                                ),
                                                                                Container(
                                                                                  // height: 30,
                                                                                  color: Colors.grey[300],
                                                                                  child: Padding(
                                                                                    padding: const EdgeInsets.all(8.0),
                                                                                    child: GestureDetector(
                                                                                      child: Row(
                                                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                        children: [
                                                                                          Container(
                                                                                            child: Text(
                                                                                              "Size",
                                                                                              style: TextStyle(
                                                                                                fontSize: 13,
                                                                                                fontWeight: FontWeight.bold,
                                                                                                color: Constants.blackColor,
                                                                                              ),
                                                                                              overflow: TextOverflow.ellipsis,
                                                                                            ),
                                                                                          ),
                                                                                          Text(
                                                                                            "Shoulder",
                                                                                            style: TextStyle(
                                                                                              fontSize: 13,
                                                                                              fontWeight: FontWeight.bold,
                                                                                              color: Constants.blackColor,
                                                                                            ),
                                                                                            overflow: TextOverflow.ellipsis,
                                                                                          ),
                                                                                          Text(
                                                                                            "Chest",
                                                                                            style: TextStyle(
                                                                                              fontSize: 13,
                                                                                              fontWeight: FontWeight.bold,
                                                                                              color: Constants.blackColor,
                                                                                            ),
                                                                                            overflow: TextOverflow.ellipsis,
                                                                                          ),
                                                                                          Text(
                                                                                            "Waist",
                                                                                            style: TextStyle(
                                                                                              fontSize: 13,
                                                                                              fontWeight: FontWeight.bold,
                                                                                              color: Constants.blackColor,
                                                                                            ),
                                                                                            overflow: TextOverflow.ellipsis,
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                Container(
                                                                                  height: 1,
                                                                                  color: Colors.grey[300],
                                                                                ),
                                                                                Padding(
                                                                                  padding: const EdgeInsets.all(8.0),
                                                                                  child: GestureDetector(
                                                                                    child: Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                      children: [
                                                                                        Container(
                                                                                          child: Text(
                                                                                            "S  ",
                                                                                            style: TextStyle(
                                                                                              fontSize: 13,
                                                                                              fontWeight: FontWeight.bold,
                                                                                              color: Constants.greyColor,
                                                                                            ),
                                                                                            overflow: TextOverflow.ellipsis,
                                                                                          ),
                                                                                        ),
                                                                                        Text(
                                                                                          "17.5",
                                                                                          style: TextStyle(
                                                                                            fontSize: 11,
                                                                                            fontWeight: FontWeight.w600,
                                                                                            color: Constants.lightgreyColor,
                                                                                          ),
                                                                                          overflow: TextOverflow.ellipsis,
                                                                                        ),
                                                                                        Text(
                                                                                          "40",
                                                                                          style: TextStyle(
                                                                                            fontSize: 11,
                                                                                            fontWeight: FontWeight.w600,
                                                                                            color: Constants.lightgreyColor,
                                                                                          ),
                                                                                          overflow: TextOverflow.ellipsis,
                                                                                        ),
                                                                                        Text(
                                                                                          "37",
                                                                                          style: TextStyle(
                                                                                            fontSize: 11,
                                                                                            fontWeight: FontWeight.w600,
                                                                                            color: Constants.lightgreyColor,
                                                                                          ),
                                                                                          overflow: TextOverflow.ellipsis,
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                Container(
                                                                                  height: 1,
                                                                                  color: Colors.grey[300],
                                                                                ),
                                                                                Padding(
                                                                                  padding: const EdgeInsets.all(8.0),
                                                                                  child: GestureDetector(
                                                                                    child: Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                      children: [
                                                                                        Container(
                                                                                          child: Align(
                                                                                            alignment: Alignment.topLeft,
                                                                                            child: Text(
                                                                                              "M  ",
                                                                                              style: TextStyle(
                                                                                                fontSize: 13,
                                                                                                fontWeight: FontWeight.bold,
                                                                                                color: Constants.greyColor,
                                                                                              ),
                                                                                              overflow: TextOverflow.ellipsis,
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                        Text(
                                                                                          "18",
                                                                                          style: TextStyle(
                                                                                            fontSize: 11,
                                                                                            fontWeight: FontWeight.w600,
                                                                                            color: Constants.lightgreyColor,
                                                                                          ),
                                                                                          overflow: TextOverflow.ellipsis,
                                                                                        ),
                                                                                        Text(
                                                                                          "43",
                                                                                          style: TextStyle(
                                                                                            fontSize: 11,
                                                                                            fontWeight: FontWeight.w600,
                                                                                            color: Constants.lightgreyColor,
                                                                                          ),
                                                                                          overflow: TextOverflow.ellipsis,
                                                                                        ),
                                                                                        Text(
                                                                                          "40",
                                                                                          style: TextStyle(
                                                                                            fontSize: 11,
                                                                                            fontWeight: FontWeight.w600,
                                                                                            color: Constants.lightgreyColor,
                                                                                          ),
                                                                                          overflow: TextOverflow.ellipsis,
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                Container(
                                                                                  height: 1,
                                                                                  color: Colors.grey[300],
                                                                                ),
                                                                                Padding(
                                                                                  padding: const EdgeInsets.all(8.0),
                                                                                  child: GestureDetector(
                                                                                    child: Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                      children: [
                                                                                        Container(
                                                                                          child: Align(
                                                                                            alignment: Alignment.topLeft,
                                                                                            child: Text(
                                                                                              "L  ",
                                                                                              style: TextStyle(
                                                                                                fontSize: 13,
                                                                                                fontWeight: FontWeight.bold,
                                                                                                color: Constants.greyColor,
                                                                                              ),
                                                                                              overflow: TextOverflow.ellipsis,
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                        Text(
                                                                                          "18.5",
                                                                                          style: TextStyle(
                                                                                            fontSize: 11,
                                                                                            fontWeight: FontWeight.w600,
                                                                                            color: Constants.lightgreyColor,
                                                                                          ),
                                                                                          overflow: TextOverflow.ellipsis,
                                                                                        ),
                                                                                        Text(
                                                                                          "45",
                                                                                          style: TextStyle(
                                                                                            fontSize: 11,
                                                                                            fontWeight: FontWeight.w600,
                                                                                            color: Constants.lightgreyColor,
                                                                                          ),
                                                                                          overflow: TextOverflow.ellipsis,
                                                                                        ),
                                                                                        Text(
                                                                                          "42",
                                                                                          style: TextStyle(
                                                                                            fontSize: 11,
                                                                                            fontWeight: FontWeight.w600,
                                                                                            color: Constants.lightgreyColor,
                                                                                          ),
                                                                                          overflow: TextOverflow.ellipsis,
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                Container(
                                                                                  height: 1,
                                                                                  color: Colors.grey[300],
                                                                                ),
                                                                                Padding(
                                                                                  padding: const EdgeInsets.all(8.0),
                                                                                  child: GestureDetector(
                                                                                    child: Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                      children: [
                                                                                        Container(
                                                                                          child: Align(
                                                                                            alignment: Alignment.topLeft,
                                                                                            child: Text(
                                                                                              "XL",
                                                                                              style: TextStyle(
                                                                                                fontSize: 12,
                                                                                                fontWeight: FontWeight.bold,
                                                                                                color: Constants.greyColor,
                                                                                              ),
                                                                                              overflow: TextOverflow.ellipsis,
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                        Text(
                                                                                          "19.3",
                                                                                          style: TextStyle(
                                                                                            fontSize: 11,
                                                                                            fontWeight: FontWeight.w600,
                                                                                            color: Constants.lightgreyColor,
                                                                                          ),
                                                                                          overflow: TextOverflow.ellipsis,
                                                                                        ),
                                                                                        Text(
                                                                                          "48",
                                                                                          style: TextStyle(
                                                                                            fontSize: 11,
                                                                                            fontWeight: FontWeight.w600,
                                                                                            color: Constants.lightgreyColor,
                                                                                          ),
                                                                                          overflow: TextOverflow.ellipsis,
                                                                                        ),
                                                                                        Text(
                                                                                          "46",
                                                                                          style: TextStyle(
                                                                                            fontSize: 11,
                                                                                            fontWeight: FontWeight.w600,
                                                                                            color: Constants.lightgreyColor,
                                                                                          ),
                                                                                          overflow: TextOverflow.ellipsis,
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                Container(
                                                                                  height: 1,
                                                                                  color: Colors.grey[300],
                                                                                ),
                                                                                Padding(
                                                                                  padding: const EdgeInsets.only(top: 15.0, bottom: 15, left: 5, right: 5),
                                                                                  child: Row(
                                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                                    children: [
                                                                                      Expanded(
                                                                                        child: RichText(
                                                                                          maxLines: 3,
                                                                                          overflow: TextOverflow.ellipsis,
                                                                                          text: TextSpan(
                                                                                            children: <TextSpan>[
                                                                                              // new TextSpan(text: 'Don\'t have an account? '),
                                                                                              new TextSpan(
                                                                                                  text: 'Dimensions: ',
                                                                                                  style: new TextStyle(
                                                                                                    fontWeight: FontWeight.w600,
                                                                                                    color: Constants.blackColor,
                                                                                                    fontSize: 12,
                                                                                                  )),
                                                                                              new TextSpan(
                                                                                                text: 'Saree Length: 5.5 m, Blouse Length: 0.8 m (Unstiched), Total Length: 6.3 m including blouse material.',
                                                                                                style: new TextStyle(color: Constants.lightgreyColor, fontSize: 11, fontWeight: FontWeight.w600),
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                        //  Text(
                                                                                        //      "Dimensions: Saree Length:55 Meter, Blouse Length: 0.8Meter (Blouse will be Unstiched), Total Saree Length:6.3Meter including blouse material. ",
                                                                                        //     maxLines: 4,
                                                                                        //     style:
                                                                                        //                     TextStyle(
                                                                                        //                   fontSize: 13,
                                                                                        //                   fontWeight: FontWeight.w500,
                                                                                        //                   color: Constants.lightgreyColor,
                                                                                        //                 ),
                                                                                        //                 overflow: TextOverflow.ellipsis,
                                                                                        //               ),
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
                                                                  ),
                                                                );
                                                              });
                                                        },
                                                        child: Row(
                                                          children: [
                                                            Image.asset(
                                                              'assets/Icons/ruler-64.png',
                                                              height: 20,
                                                            ),
                                                            SizedBox(
                                                              width: 5,
                                                            ),
                                                            Text(
                                                              //  itemDetailsResponse.result.itemSizes.length.toString()==null?'':
                                                              'Size Chart'
                                                                  .inCaps,
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                fontFamily:
                                                                    'Montserrat',
                                                                // fontFamily: 'RobotoMono',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: Constants
                                                                    .appColor,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  SizedBox(
                                                    height: 40,
                                                    child: ListView.builder(
                                                      primary: false,
                                                      itemCount:
                                                          itemDetailsResponse
                                                              .result
                                                              .itemSizes
                                                              .length,
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      // shrinkWrap: true,
                                                      itemBuilder:
                                                          (context, index) {
                                                        return GestureDetector(
                                                          onTap: () {
                                                            setState(() {
                                                              sizeError = "Yes";
                                                              if (oldSizeIndex !=
                                                                  -2) {
                                                                itemDetailsResponse
                                                                    .result
                                                                    .itemSizes[
                                                                        oldSizeIndex]
                                                                    .isSelectedColor = false;
                                                              }
                                                              oldSizeIndex =
                                                                  index;
                                                              itemDetailsResponse
                                                                      .result
                                                                      .itemSizes[
                                                                          index]
                                                                      .isSelectedColor =
                                                                  true;
                                                              isActiveSize =
                                                                  itemDetailsResponse
                                                                      .result
                                                                      .itemSizes[
                                                                          index]
                                                                      .isSelectedColor;

                                                              activeSizeID = isActiveSize ==
                                                                      true
                                                                  ? itemDetailsResponse
                                                                      .result
                                                                      .itemSizes[
                                                                          index]
                                                                      .id
                                                                  : 0;
                                                            });

                                                            print(
                                                                itemDetailsResponse
                                                                    .result
                                                                    .itemSizes[
                                                                        index]
                                                                    .id);
                                                            print(
                                                                itemDetailsResponse
                                                                    .result
                                                                    .itemSizes[
                                                                        index]
                                                                    .name);
                                                            print(itemDetailsResponse
                                                                .result
                                                                .itemSizes[
                                                                    index]
                                                                .isSelectedColor);
                                                          },
                                                          child: Container(
                                                            height: 40,
                                                            child: Align(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        5.0),
                                                                child: Text(
                                                                  itemDetailsResponse
                                                                      .result
                                                                      .itemSizes[
                                                                          index]
                                                                      .name
                                                                      .toString(),
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          13,
                                                                      color: Constants
                                                                          .greyColor,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .clip,
                                                                ),
                                                              ),
                                                            ),
                                                            margin:
                                                                EdgeInsets.only(
                                                                    top: 4,
                                                                    bottom: 4,
                                                                    right: 10),
                                                            // width: 30,
                                                            // height: 30,
                                                            decoration:
                                                                BoxDecoration(
                                                              boxShadow: <
                                                                  BoxShadow>[
                                                                BoxShadow(
                                                                  color: Colors
                                                                      .white,
                                                                  blurRadius: 3,
                                                                  offset:
                                                                      Offset(
                                                                          2, 2),
                                                                ),
                                                              ],
                                                              border: itemDetailsResponse
                                                                          .result
                                                                          .itemSizes[
                                                                              index]
                                                                          .isSelectedColor ==
                                                                      true
                                                                  ? Border.all(
                                                                      color: Constants
                                                                          .appColor,
                                                                      width:
                                                                          1.5)
                                                                  : Border.all(
                                                                      color: Colors
                                                                          .grey,
                                                                      width:
                                                                          1.5),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5),
                                                              // color: listItemSizes[index].name.toString()
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          )
                                        : Container(),
                                    sizeError == null
                                        ? Align(
                                            alignment: Alignment.topLeft,
                                            child: Text(
                                              "Please select size",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.red),
                                            ),
                                          )
                                        : Container(),
                                    SizedBox(height: 5),
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Column(
                                        children: <Widget>[
                                          Text(
                                            //  itemDetailsResponse.result.itemColours==null?'':
                                            'Product Details',
                                            style: TextStyle(
                                              fontSize: 13,
                                              // fontFamily: 'RobotoMono',
                                              fontWeight: FontWeight.bold,
                                              color: Constants.boldTextColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    itemDetailsResponse.result.itemDetails
                                                .itemTypename ==
                                            null
                                        ? Container()
                                        : Align(
                                            alignment: Alignment.topLeft,
                                            child: Row(
                                              children: <Widget>[
                                                itemDetailsResponse
                                                            .result
                                                            .itemDetails
                                                            .itemTypename ==
                                                        null
                                                    ? Container()
                                                    : Text(
                                                        'Type    ',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: Constants
                                                              .lightgreyColor,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                        overflow:
                                                            TextOverflow.clip,
                                                      ),
                                                SizedBox(width: 74),
                                                Text(
                                                  itemDetailsResponse
                                                              .result
                                                              .itemDetails
                                                              .itemTypename ==
                                                          null
                                                      ? ''
                                                      : itemDetailsResponse
                                                          .result
                                                          .itemDetails
                                                          .itemTypename
                                                          .inCaps,
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold
                                                      // fontFamily: 'RobotoMono',
                                                      ),
                                                  overflow: TextOverflow.clip,
                                                ),
                                              ],
                                            ),
                                          ),
                                    itemDetailsResponse.result.itemDetails
                                                    .fabricName ==
                                                null ||
                                            itemDetailsResponse.result
                                                    .itemDetails.fabricName ==
                                                ""
                                        ? Container()
                                        : Padding(
                                            padding:
                                                const EdgeInsets.only(top: 10),
                                            child: Align(
                                              alignment: Alignment.topLeft,
                                              child: Row(
                                                children: <Widget>[
                                                  Text(
                                                    itemDetailsResponse
                                                                    .result
                                                                    .itemDetails
                                                                    .fabricName ==
                                                                null ||
                                                            itemDetailsResponse
                                                                    .result
                                                                    .itemDetails
                                                                    .fabricName ==
                                                                ""
                                                        ? null
                                                        : 'Fabric   ',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Constants
                                                          .lightgreyColor,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      // fontFamily: 'RobotoMono',
                                                    ),
                                                  ),
                                                  SizedBox(width: 71),
                                                  Text(
                                                    itemDetailsResponse
                                                                .result
                                                                .itemDetails
                                                                .fabricName ==
                                                            null
                                                        ? ''
                                                        : itemDetailsResponse
                                                            .result
                                                            .itemDetails
                                                            .fabricName
                                                            .inCaps,
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold
                                                        // fontFamily: 'RobotoMono',
                                                        ),
                                                    overflow: TextOverflow.clip,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                    itemDetailsResponse.result.itemDetails
                                                .categoryName ==
                                            null
                                        ? Container()
                                        : Padding(
                                            padding:
                                                const EdgeInsets.only(top: 10),
                                            child: Align(
                                              alignment: Alignment.topLeft,
                                              child: Row(
                                                children: <Widget>[
                                                  Text(
                                                    itemDetailsResponse
                                                                .result
                                                                .itemDetails
                                                                .categoryName ==
                                                            null
                                                        ? ''
                                                        : 'Category ',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Constants
                                                          .lightgreyColor,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      // fontFamily: 'RobotoMono',
                                                    ),
                                                  ),
                                                  SizedBox(width: 57),
                                                  Text(
                                                    itemDetailsResponse
                                                                .result
                                                                .itemDetails
                                                                .categoryName ==
                                                            null
                                                        ? ''
                                                        : itemDetailsResponse
                                                            .result
                                                            .itemDetails
                                                            .categoryName
                                                            .inCaps,
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold
                                                        // fontFamily: 'RobotoMono',
                                                        ),
                                                    overflow: TextOverflow.clip,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                    itemDetailsResponse
                                                .result.itemDetails.barCode ==
                                            null
                                        ? Container()
                                        : Padding(
                                            padding:
                                                const EdgeInsets.only(top: 10),
                                            child: Align(
                                              alignment: Alignment.topLeft,
                                              child: Row(
                                                children: <Widget>[
                                                  Text(
                                                    itemDetailsResponse
                                                                .result
                                                                .itemDetails
                                                                .barCode ==
                                                            null
                                                        ? ''
                                                        : 'Barcode  ',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Constants
                                                          .lightgreyColor,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      // fontFamily: 'RobotoMono',
                                                    ),
                                                  ),
                                                  SizedBox(width: 59),
                                                  Text(
                                                    itemDetailsResponse
                                                                .result
                                                                .itemDetails
                                                                .barCode ==
                                                            null
                                                        ? ''
                                                        : itemDetailsResponse
                                                            .result
                                                            .itemDetails
                                                            .barCode
                                                            .inCaps,
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold
                                                        // fontFamily: 'RobotoMono',
                                                        ),
                                                    overflow: TextOverflow.clip,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                    SizedBox(height: 10),
                                    itemDetailsResponse.result.itemDetails
                                                .description ==
                                            null
                                        ? Container()
                                        : Align(
                                            alignment: Alignment.topLeft,
                                            child: Text(
                                              "Description ",
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: Constants.blackColor),
                                              overflow: TextOverflow.clip,
                                            ),
                                          ),
                                    SizedBox(height: 5),
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        itemDetailsResponse == null
                                            ? Container()
                                            : itemDetailsResponse.result
                                                .itemDetails.description.inCaps,
                                        style: TextStyle(
                                          fontSize: 13,
                                        ),
                                        overflow: TextOverflow.clip,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                ),
              ),
        bottomNavigationBar: itemDetailsResponse.result == null
            ? Container()
            : Padding(
                padding: const EdgeInsets.all(0.0),
                child: Container(
                  // height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey[300]),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          // height: 48,
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: RaisedButton(
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Icons.shopping_cart,
                                      color: Constants.blackColor,
                                    ),
                                    Text(
                                      " Add to cart",
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
                                // if (isAlreadyInCart == true) {
                                //   Navigator.push(
                                //       context,
                                //       MaterialPageRoute(
                                //           builder: (context) => CartScreen(
                                //               userID: loginUserID.toString())));
                                // } else {

                                if (itemCountController.text == "0") {
                                  apiConnector.globalToast(
                                      'Select Atleast one Quantity');
                                } else {
                                  if (itemCount == 0) {
                                    apiConnector
                                        .globalToast(" Select Quantity ");
                                  } else if (itemDetailsResponse
                                              .result.itemColours.length !=
                                          0 &&
                                      isActiveColor == false) {
                                    print("/////////////////");
                                    if (isActiveColor == false) {
                                      // apiConnector.globalToast(" Select Colour ");

                                      setState(() {
                                        colorError = null;
                                      });
                                    }
                                  } else if (itemDetailsResponse
                                              .result.itemSizes.length !=
                                          0 &&
                                      isActiveSize == false) {
                                    print("----------------");
                                    if (isActiveSize == false) {
                                      // apiConnector.globalToast(" Select Size ");
                                      setState(() {
                                        sizeError = null;
                                      });
                                    }
                                  } else {
                                    List<int> colorsIDArray = [];
                                    List<int> sizesIDArray = [];
                                    List<int> itemIDArray = [];
                                    List<String> combination = [];
                                    print("----------------");
                                    print(activeColorID);
                                    print(activeSizeID);
                                    print("----------------");

                                    if (productsforpost.length > 0) {
                                      for (int i = 0;
                                          i < productsforpost.length;
                                          i++) {
                                        colorsIDArray
                                            .add(productsforpost[i].colourId);

                                        sizesIDArray
                                            .add(productsforpost[i].sizeId);

                                        itemIDArray
                                            .add(productsforpost[i].itemId);

                                        combination.add(productsforpost[i]
                                                .colourId
                                                .toString() +
                                            productsforpost[i]
                                                .sizeId
                                                .toString());
                                        combination.add(productsforpost[i]
                                                .sizeId
                                                .toString() +
                                            productsforpost[i]
                                                .colourId
                                                .toString());
                                      }
                                      print("colorsIDArray");
                                      print(colorsIDArray);
                                      print("sizesIDArray");
                                      print(sizesIDArray);
                                      print("itemIDArray");
                                      print(itemIDArray);
                                      print(combination);

                                      //  int colorInt = activeColorID.toString() + activeSizeID.toString();
                                      String colorString =
                                          activeColorID.toString() +
                                              activeSizeID.toString();

                                      // int sizeInt = activeSizeID.toString() + activeColorID.toString();
                                      String sizeString =
                                          activeSizeID.toString() +
                                              activeColorID.toString();

                                      print(colorString);
                                      print(sizeString);

                                      if (itemIDArray.contains(
                                          itemDetailsResponse
                                              .result.itemDetails.id)) {
                                        alradyColor =
                                            combination.contains(colorString);
                                        alreadySize =
                                            combination.contains(sizeString);

                                        print(alradyColor);
                                        print(alreadySize);

                                        if (alradyColor == true &&
                                            alreadySize == true) {
                                          print(" -- Item  already in cart");
                                          apiConnector.globalToast(
                                              "Item already in cart");
                                          setState(() {
                                            itemCountController.text = "1";
                                          });
                                        } else {
                                          print(
                                              "-----Already in cart but---item adding to cart with  Diff color or Diff size");
                                          addToCartAPICall();
                                          setState(() {
                                            itemCountController.text = "1";
                                          });
                                        }
                                      } else {
                                        print(
                                            "-----Cart is Available So  adding to cart");
                                        addToCartAPICall();
                                        setState(() {
                                          itemCountController.text = "1";
                                        });
                                      }
                                    } else {
                                      print("-----first time adding to cart");
                                      addToCartAPICall();
                                      setState(() {
                                        itemCountController.text = "1";
                                      });
                                    }
                                  }
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Container(
                          // height: 48,
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: RaisedButton(
                              color: Constants.appColor,
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.shopping_basket,
                                      color: Colors.white,
                                    ),
                                    Text(
                                      " Buy Now",
                                      style: TextStyle(
                                        // fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              onPressed: () {
                                print('ItemCount Tadded text ' +
                                    itemCount.toString());
                                if (itemCount == 0) {
                                } else if (itemDetailsResponse
                                            .result.itemColours.length !=
                                        0 &&
                                    isActiveColor == false) {
                                  print("/////////////////");
                                  if (isActiveColor == false) {
                                    setState(() {
                                      colorError = null;
                                    });
                                  }
                                } else if (itemDetailsResponse
                                            .result.itemSizes.length !=
                                        0 &&
                                    isActiveSize == false) {
                                  print("----------------");
                                  if (isActiveSize == false) {
                                    setState(() {
                                      sizeError = null;
                                    });
                                  }
                                } else {
                                  products = new List<Product>();
                                  var finalPrie = 0.0;
                                  double aaa = (((itemDetailsResponse
                                              .result.itemDetails.discountPrince
                                              .toDouble()) /
                                          100.00) *
                                      itemDetailsResponse.result.itemDetails.gst
                                          .toDouble());

                                  print('g s t  g s t' + aaa.toString());
                                  finalPrie = itemDetailsResponse
                                          .result.itemDetails.discountPrince +
                                      aaa;

                                  print('finalPrie' + finalPrie.toString());

                                  products.add(new Product(
                                      itemId: itemDetailsResponse
                                          .result.itemDetails.id,
                                      price: itemDetailsResponse
                                          .result.itemDetails.discountPrince,
                                      finalPrice: finalPrie,
                                      gst: itemDetailsResponse
                                          .result.itemDetails.gst,
                                      discount: itemDetailsResponse
                                          .result.itemDetails.discount,
                                      quantity: itemCount,
                                      sizeId: activeSizeID == 0
                                          ? null
                                          : activeSizeID,
                                      colourId: activeColorID == 0
                                          ? null
                                          : activeColorID));

                                  setState(() {
                                    localData.addIntToSF(
                                        "itemID",
                                        itemDetailsResponse
                                            .result.itemDetails.id);
                                  });

                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => AddressScreen(
                                            isFromCart: false,
                                            products: products,
                                            itemID: itemDetailsResponse
                                                .result.itemDetails.id,
                                            isFromItemDetails: true,
                                          )));
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  addToWishListAPICall(bool isFaverate, int itemID) {
    String addToWishListURL = ApiService.baseUrl + ApiService.addToWishlist;

    Map<String, dynamic> parameters = {
      "VendorId": loginUserID,
      "ItemId": itemID
    };

    apiConnector.postAPICall(addToWishListURL, parameters).then((response) {
      if (response["IsSuccess"] == true) {
        setState(() {
          apiConnector.globalToast(response["EndUserMessage"]);
        });
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

    apiConnector
        .postAPICall(removeFromWishListURL, parameters)
        .then((response) {
      print(response);
      if (response["IsSuccess"] == true) {
        print(response["EndUserMessage"]);
        apiConnector.globalToast(response["EndUserMessage"]);
      }
    });
  }

  void removefromcart(CategoriesByIDListResult categoryList) {
    setState(() {
      print('++++categoryList.itemCount ' + categoryList.itemCount.toString());
      PostCartRequest cartModel = new PostCartRequest();
      if (cartModelfromAPI != null) {
        print('Narmada ------ enter to cart');
        cartModel.cart = new CartPostInfo(
            // id: cartModelfromAPI.result.cart.id,
            // userId: cartModelfromAPI.result.cart.userId,
            // name: cartModelfromAPI.result.cart.name
            id: cartID,
            userId: loginUserID,
            name: "cart");
      } else {
        print('Narmada ------ Cart item Null');
        cartModel.cart =
            new CartPostInfo(id: cartID, userId: loginUserID, name: 'cart');
      }

      print('productsforpost.length ' + productsforpost.length.toString());

      if (productsforpost.length > 0) {
        var items = productsforpost
            .where((p) => p.itemId == categoryList.itemId)
            .toList();
        print('items.length ' + items.length.toString());
        if (items != null && items.length > 0) {
          print("+++++++++++++++++++++++++++++");
          print(' ------ enter Items Quantity ' +
              items[0].itemId.toString() +
              " " +
              items[0].quantity.toString());
          productsforpost
              .removeWhere((item) => item.itemId == categoryList.itemId);
          if (categoryList.itemCount > 0) {
            productsforpost.add(new ItemsList(
                itemId: categoryList.itemId, quantity: categoryList.itemCount));
          } else {
            print("not more than One");
          }
        } else {
          print("///////////////////////////////");
        }
      } else {}

      cartModel.items = productsforpost;
      apiConnector.postCartUpdate(cartModel).then((cartResponce) {
        if (cartResponce == 200) {
          print('Narmada ------- Added Cart Success');
          print('cartResponce response  -------' + cartResponce.toString());
        } else {
          print('-- -------- No items' + cartResponce.toString());
        }
      });
    });
  }

  void updateCart(CategoriesByIDListResult categoryList) {
    print('++++categoryList.itemCount ' + categoryList.itemCount.toString());
    PostCartRequest cartModel = new PostCartRequest();
    if (cartModelfromAPI != null) {
      print('Narmada ------ enter to cart');
      cartModel.cart = new CartPostInfo(
          // id: cartModelfromAPI.result.cart.id,
          // userId: cartModelfromAPI.result.cart.userId,
          // name: cartModelfromAPI.result.cart.name
          id: cartID,
          userId: loginUserID,
          name: "cart");
    } else {
      print('Narmada ------ Cart item Null');
      cartModel.cart =
          new CartPostInfo(id: cartID, userId: loginUserID, name: 'cart');
    }

    productsforpost[0].itemId = categoryList.itemId;
    productsforpost[0].quantity = itemCount;

    cartModel.items = productsforpost;

    print('productsforpost.length ' + productsforpost.length.toString());

    apiConnector.postCartUpdate(cartModel).then((cartResponce) {
      if (cartResponce == 200) {
        print('Narmada ------- Added Cart Success');
        print('cartResponce response  -------' + cartResponce.toString());
      } else {
        print('-- -------- No items' + cartResponce.toString());
      }
    });
  }

  getItemDetails(String itemID) async {
    itemDetailsResponse = new ItemDetailsResponse();

    productsforpost = new List<ItemsList>();

    String finalUrl = ApiService.baseUrl + "Item/GetitemById?Id=" + itemID;

    await apiConnector.getAPICall(finalUrl).then((response) {
      // progressHud.hide();
      print(" finalUrl -- > " + finalUrl);

      setState(() {
        // progressHud.hide();
        firstLoading = false;
        itemDetailsResponse = ItemDetailsResponse.fromJson(response);

        if (itemDetailsResponse.isSuccess == true) {
          print("itemColours  - ---- " +
              itemDetailsResponse.result.itemColours.length.toString());
          print(" itemFileRepositories -- > " +
              itemDetailsResponse.result.itemSizes.length.toString());
          print(" ITEMIMAGES -- > " +
              itemDetailsResponse.result.itemFileRepositories.length
                  .toString());
          setState(() {
            appBarTitle = itemDetailsResponse.result.itemDetails.name.inCaps;

            savingPrice =
                itemDetailsResponse.result.itemDetails.wholeSalePrice -
                    itemDetailsResponse.result.itemDetails.discountPrince;
          });

          if (itemDetailsResponse.result.itemColours.length > 0) {
            for (int i = 0;
                i < itemDetailsResponse.result.itemColours.length;
                i++) {
              itemDetailsResponse.result.itemColours[i].isSelectedColor = false;

              print(itemDetailsResponse.result.itemColours[i].isSelectedColor);
              print(" ---------------------------------------- ");
              if (itemDetailsResponse.result.itemColours.length == 1) {
                itemDetailsResponse.result.itemColours[0].isSelectedColor =
                    true;
                activeColorID = itemDetailsResponse.result.itemColours[0].id;
                isActiveColor = true;
              }
            }
          } else {}
          if (itemDetailsResponse.result.itemSizes.length > 0) {
            for (int i = 0;
                i < itemDetailsResponse.result.itemSizes.length;
                i++) {
              itemDetailsResponse.result.itemSizes[i].isSelectedColor = false;

              print(itemDetailsResponse.result.itemSizes[i].isSelectedColor);
              print(" ---------------------------------------- ");

              if (itemDetailsResponse.result.itemSizes.length == 1) {
                itemDetailsResponse.result.itemSizes[i].isSelectedColor = true;
                activeSizeID = itemDetailsResponse.result.itemSizes[0].id;
                isActiveSize = true;
              }
            }
          } else {}

          if (getCartResponse != null) {
            if (getCartResponse.result != null &&
                getCartResponse.result.productsList != null) {
              for (int i = 0;
                  i < getCartResponse.result.productsList.length;
                  i++) {
                productsforpost.add(new ItemsList(
                    itemId: getCartResponse.result.productsList[i].id,
                    quantity: getCartResponse.result.productsList[i].quantity,
                    colourId:
                        getCartResponse.result.productsList[i].colourids == null
                            ? 0
                            : getCartResponse.result.productsList[i].colourids,
                    sizeId:
                        getCartResponse.result.productsList[i].sizeIds == null
                            ? 0
                            : getCartResponse.result.productsList[i].sizeIds));

                if (itemDetailsResponse.result.itemDetails.id ==
                    getCartResponse.result.productsList[i].id) {
                  print(" ---------------------------------------- ");
                  setState(() {
                    // isAlreadyInCart = true;
                  });
                }
                // else {
                //   setState(() {
                //     productsforpost.add(new ItemsList(
                //         itemId: getCartResponse.result.productsList[i].id,
                //         quantity:
                //             getCartResponse.result.productsList[i].quantity));
                //   });
                // }
              }

              print(" -------coming from cart -- " +
                  productsforpost.length.toString());
            }
          }

          images.clear();
          for (int i = 0;
              i < itemDetailsResponse.result.itemFileRepositories.length;
              i++) {
            // print('Narmada---------' +
            //     itemDetailsResponse.result.itemColours[i].isSelectedColor
            //         .toString());
            images.add(itemDetailsResponse.result.itemFileRepositories != null
                ? CachedNetworkImage(
                    // fit: BoxFit.fill,
                    imageUrl: itemDetailsResponse
                        .result.itemFileRepositories[i].fileLocation,
                    placeholder: (context, url) => Center(
                        child: Container(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(),
                    )),
                    errorWidget: (context, url, error) =>
                        Image.asset('assets/Rupdarshi.jpg'),
                  )
                : Image.asset('assets/Rupdarshi.jpg'));
          }
        }
      });
    });
  }

  addToCartAPICall() {
    print("---------  came to addToCartAPI ");

    PostCartRequest cartModel = new PostCartRequest();

    cartModel.cart =
        new CartPostInfo(id: cartID, userId: loginUserID, name: 'cart');

    print(" ********************* " + productsforpost.length.toString());
    if (productsforpost.length > 0) {
      print("---------  cart count " +
          getCartResponse.result.productsList.length.toString());

      for (int i = 0; i < productsforpost.length; i++) {
        productsforpost[i].colourId = productsforpost[i].colourId == 0
            ? null
            : productsforpost[i].colourId;
        productsforpost[i].sizeId =
            productsforpost[i].sizeId == 0 ? null : productsforpost[i].sizeId;
      }

      var item = getCartResponse.result.productsList
          .where((x) => x.id == itemDetailsResponse.result.itemDetails.id);
      if (null != item) {
        var localitem = productsforpost.where(
            (x) => x.itemId == itemDetailsResponse.result.itemDetails.id);

        if (null != localitem) {
          productsforpost.add(new ItemsList(
              itemId: itemDetailsResponse.result.itemDetails.id,
              quantity: itemCount,
              colourId: activeColorID == 0 ? null : activeColorID,
              sizeId: activeSizeID == 0 ? null : activeSizeID));
        }
      }
    } else {
      print("First time adding to cart " +
          itemDetailsResponse.result.itemDetails.id.toString() +
          " " +
          itemCount.toString());
      productsforpost.add(new ItemsList(
          itemId: itemDetailsResponse.result.itemDetails.id,
          quantity: itemCount,
          colourId: activeColorID == 0 ? null : activeColorID,
          sizeId: activeSizeID == 0 ? null : activeSizeID));
    }

    cartModel.items = productsforpost;

    print(" *************** " + productsforpost.length.toString());

    apiConnector.postCartUpdate(cartModel).then((cartResponce) {
      print('cartResponce response  -------' + cartResponce.toString());
      addtoCartResponse = AddtoCartResponse.fromJson(cartResponce);

      if (addtoCartResponse.isSuccess == true) {
        setState(() {
          setState(() {
            itemCount = 0;
            activeColorID = 0;
            activeSizeID = 0;
            isActiveSize = false;
            isActiveColor = false;
            alradyColor = false;
            alreadySize = false;
            // isAlreadyInCart = true;
            // firstLoading = true;
            // cartitemcount++;
            // getItemDetails(this.widget.itemID);
          });

          print(isAlreadyInCart);
          apiConnector.globalToast("Item Added to Cart");

          getLocalDB();
        });
      }
    });
  }

  void backnavigation() {
    if (widget.isFromCart == true) {
      print('Category screen');
      widget.refresh();
      Navigator.pop(context);
      // Navigator.of(context).pushReplacement(MaterialPageRoute(
      //     builder: (context) =>
      //         CartScreen(userID: loginUserID.toString())));
    } else if (widget.isFromWishList == true) {
      print(widget.isFromHome);
      Navigator.pop(context);
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => WishListScreen(
                userID: loginUserID.toString(),
                isFromHome: this.widget.isFromHome,
              )));
    } else if (widget.isFromCategory == true) {
      print('Category screen');
      widget.refresh(); // just refresh() if its statelesswidget
      Navigator.pop(context);
      // Navigator.pop(context);
      // Navigator.of(context).push(MaterialPageRoute(
      //                     builder: (context) => CategoriesScreen(
      //                           categoryID: value.id.toString(),
      //                           categoryName: value.name,
      //                           fromHomeSearch: false,
      //                           subCategory: this.widget.subCategory,
      //                         )));
    } else {
      Navigator.pop(context);
    }
  }
}

class MySecondScreen extends StatefulWidget {
  final List<ItemFileRepository> itemFileRepositories;
  final String title;
  final int clickedimageIndex;
  // final List<Item> itemColours;
  final ItemDetailsResponse itemDetailsResponse;

  MySecondScreen(
      {Key key,
      this.itemFileRepositories,
      this.title,
      this.clickedimageIndex,
      this.itemDetailsResponse})
      : super(key: key);

  @override
  _MySecondScreenState createState() => _MySecondScreenState();
}

class _MySecondScreenState extends State<MySecondScreen> {
  String imageTitle = "";
  int photoIndex = 0;

  bool isActiveColor = false;
  int oldColorIndex = -1;
  int activeColorID = 0;
  @override
  void initState() {
    super.initState();

    setState(() {
      imageTitle = this.widget.title;
      photoIndex = this.widget.clickedimageIndex;

      print(imageTitle);
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double itemHeight = (size.height) / 2;
    final double itemWidth = size.width / 2;
    return Scaffold(
      appBar: AppBar(
        title: Text(imageTitle,
            style: TextStyle(
              color: Constants.greyColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1),
        backgroundColor: Constants.bgColor,
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop(true);
          },
          child: Icon(
            Icons.close,
            size: 35,
            color: Constants.blackColor, // add custom icons also
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            SizedBox(
              height: 50,
            ),
            // Center(child: CircularProgressIndicator()),
            Column(
              children: [
                Center(
                  child: Container(
                    // color: Colors.red,
                    height: itemHeight,
                    child: PhotoView(
                        imageProvider: NetworkImage(
                          widget.itemFileRepositories[photoIndex].fileLocation,
                        ),
                        // Contained = the smallest possible size to fit one dimension of the screen
                        // minScale: PhotoViewComputedScale.contained * 0.8,
                        // Covered = the smallest possible size to fit the whole screen
                        maxScale: PhotoViewComputedScale.covered * 3,
                        // enableRotation: true,
                        // Set the background color to the "classic white"
                        backgroundDecoration: BoxDecoration(
                          color: Theme.of(context).canvasColor,
                        ),
                        loadingBuilder: (context, event) => Center(
                              child: Container(
                                width: 20.0,
                                height: 20.0,
                                child: CircularProgressIndicator(
                                  value: event == null
                                      ? 0
                                      : event.cumulativeBytesLoaded /
                                          event.expectedTotalBytes,
                                ),
                              ),
                            )),
                  ),
                ),
                // Padding(
                //   padding: const EdgeInsets.all(8.0),
                //   child: Row(
                //     children: [
                //       Text(
                //         'Color: ',
                //         style: TextStyle(
                //           fontSize: 14,
                //
                //           color: Constants.greyColor,
                //         ),
                //         overflow: TextOverflow.ellipsis,
                //       ),
                //       Text(
                //         this
                //             .widget
                //             .itemDetailsResponse
                //             .result
                //             .itemColours[photoIndex]
                //             .name,
                //         style: TextStyle(
                //
                //             fontSize: 15,
                //             fontWeight: FontWeight.w600,
                //             color: Constants.appColor),
                //       ),
                //     ],
                //   ),
                // ),
              ],
            ),

            Expanded(
              //  flex: 1,
              child: ListView.builder(
                primary: false,
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount:
                    itemDetailsResponse.result.itemFileRepositories.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 100.0,
                    //             child: Card(
                    //                shape: RoundedRectangleBorder(
                    //   borderRadius: BorderRadius.circular(15.0),
                    // ),
                    //               color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                          onTap: () {
                            print("Selected photo index " + index.toString());

                            setState(() {
                              photoIndex = index;
                            });
                          },
                          child: itemDetailsResponse
                                      .result
                                      .itemFileRepositories[index]
                                      .fileLocation !=
                                  null
                              ? CachedNetworkImage(
                                  fit: BoxFit.contain,
                                  imageUrl: itemDetailsResponse.result
                                      .itemFileRepositories[index].thumbName,
                                  errorWidget: (context, url, error) =>
                                      new Image.asset('assets/Rupdarshi.jpg'),
                                )
                              : Image.asset('assets/Rupdarshi.jpg')),
                    ),
                    //  ),
                  );
                },
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

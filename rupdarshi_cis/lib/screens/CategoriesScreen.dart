import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:rupdarshi_cis/Model/AddtoCartResponse.dart';
import 'package:rupdarshi_cis/Model/AllCategoriesResponse.dart';
import 'package:rupdarshi_cis/Model/CategoriesByIDResponse.dart';
import 'package:rupdarshi_cis/Model/ColorImagesResponse.dart';
import 'package:rupdarshi_cis/Model/ColorsResponse.dart';
import 'package:rupdarshi_cis/Model/GetCartResponse.dart';
import 'package:rupdarshi_cis/Model/Requests/PostCartRequest.dart';
import 'package:rupdarshi_cis/Service/ApiService.dart';
import 'package:rupdarshi_cis/common/Constants.dart';
import 'package:rupdarshi_cis/common/LocalDb.dart';
import 'package:rupdarshi_cis/screens/AccountScreen.dart';
import 'package:rupdarshi_cis/screens/Home_screen.dart';
import 'package:rupdarshi_cis/screens/ItemDetailsScreen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rupdarshi_cis/screens/NewHomeScreen.dart';
import 'package:rupdarshi_cis/screens/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rupdarshi_cis/Model/GetWishListResponse.dart';
import 'CartScreen.dart';
import 'WishList.dart';

RegExp reg = new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
Function mathFunc = (Match match) => '${match[1]},';

class CategoriesScreen extends StatefulWidget {
  final String categoryID;
  final String categoryName;
  final List<Category> subCategory;
  final String searchString;
  final bool fromHomeSearch;
  final Function refresh;
  CategoriesScreen(
      {this.categoryID,
      this.categoryName,
      this.searchString,
      this.fromHomeSearch,
      this.subCategory,
      this.refresh});
  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  String finalCategoryID = "";
  List<dynamic> redimages = [];
  List<dynamic> blueimages = [];
  List<dynamic> yellowimages = [];
  List<int> colorsAry = [];

  var sareesImages = [];
  var allColorImages = [];
  int scrollColorID = 0;

  bool isNewColorselected = false;
  bool isFilterClicked = false;

  int filterOldColorIndex = -1;
  String filterColorsStr = "";

  String itemTypeID = "";

  String filterColorIdsString = "";

  // ScrollController _scrollController = ScrollController();
  ScrollController _scrollController;
  int oldColorIndex = 0;
  int oldListIndex = 0;
  int oldColorIndex2 = 0;
  double itemHeight = 0.0;
  double itemWidth = 0.0;
  List<String> listCategory = new List();
  bool iteminCart = false;
  bool fromHomeSearch = false;
  int oldIndex = 0;
  AddtoCartResponse addtoCartResponse;
  ColorsResponse colorsResponse;
  List<ColorsListResult> colorsListResult;

  bool isNewestSort = false;
  bool isPriceLowToHighSort = false;
  bool isPriceHighToLowSort = false;
  bool isWholesaleSort = false;

  bool isrefreshes = false;

  int globalIndex = -1;

  var minvalue = 0.00;
  Icon shoppingcart = new Icon(
    Icons.add_shopping_cart,
    color: Constants.greyColor,
    size: 20,
  );
  ProgressDialog progressHud;
  SharedPreferences preferences;
  LocalData localData = new LocalData();
  ApiService apiConnector;
  GetCartResponse cartModelfromAPI;
  CategoriesByIdResponse categoriesByIdResponse;
  List<CategoriesByIDListResult> categoriesByIDListResult;

  ColorImagesResponse colorImagesResponse;

  List<CategoriesByIDListResult> cartProducts = [];
  List<ItemsList> productsforpost;

  GetCartResponse getCartResponse;
  PostCartRequest postCartRequest;

  TextEditingController searchcontroller = new TextEditingController();
  TextEditingController minPricecontroller = new TextEditingController();
  TextEditingController maxPricecontroller = new TextEditingController();
  int minimunValue = 0;
  int maximumValue = 0;
  int minPrice;
  int maxPrice;
  bool isFromSearch = false;
  String searchingStr = "";
  int loginUserID = 0;
  int cartID = 0;
  bool isLoading = false;
  bool firstLoading = true;
  int totalCount = 0;
  int cartitemcount = 0;
  String addedCartStr = "Item added to cart";
  String serviceIds = "0";
  int pageNo = 1;
  int pageSize = 10;
  String sortColumn = "Newest";
  String sortOrder = "DESC";
  var currentItemCount = 0;
  bool isnomoreproducts = false;
  var pageNumber = 1;
  String parameterASC = 'ASC';
  bool isGrid = true;
  String grid = "Grid";
  bool isfaverate = false;
  static String categoryName = "";
  String errorMessage = "";

  refresh() async {
    setState(() {
      isrefreshes = true;
      print('Refresh Category');
      pageNo = 1;

      //  Future.delayed(Duration.zero, () {
      // categoriesByIDListResult.clear();
      getPrefs();
      // });
      cartitemcount = 0;
      productsforpost.clear();
      getCartAPICAll();
    });
  }

  @override
  void initState() {
    super.initState();
    filterOldColorIndex = -1;
    filterColorsStr = "";
    oldColorIndex = 0;
    oldColorIndex2 = 0;
    scrollColorID = 0;
    oldListIndex = 0;
    isrefreshes = false;
    finalCategoryID = this.widget.categoryID;
    isNewColorselected = false;
    isFilterClicked = false;
    colorsAry = [];

    if (this.widget.subCategory != null) {
      for (int n = 0; n < this.widget.subCategory.length; n++) {
        this.widget.subCategory[n].isSelected = false;
      }
      // this
      //     .widget
      //     .subCategory
      //     .insert(0, new Category(name: "All", isSelected: true));
    }

    // sareesImages = [
    //   new Image.asset('assets/saree/red1.jpg', fit: BoxFit.fill),
    //   new Image.asset('assets/saree/red2.jpg', fit: BoxFit.fill),
    //   new Image.asset('assets/saree/red3.jpg', fit: BoxFit.fill),
    // ];

    sareesImages = [];
    allColorImages = [];

    redimages = [];
    blueimages = [];
    yellowimages = [];

    oldIndex = 0;
    iteminCart = false;
    fromHomeSearch = this.widget.fromHomeSearch;
    if (this.widget.fromHomeSearch == false) {
      categoryName = this.widget.categoryName;
      appbarTitle = Text(
        widget.categoryName,
        style: TextStyle(
            color: Constants.greyColor,
            fontSize: 13,
            fontWeight: FontWeight.w700),
      );
    } else {
      categoryName = null;
      appbarTitle = Text(
        this.widget.searchString,
        style: TextStyle(
            color: Constants.greyColor,
            fontSize: 13,
            fontWeight: FontWeight.w700),
      );
    }
    filterColorIdsString = null;
    minimunValue = 0;
    maximumValue = 0;
    firstLoading = true;
    isFromSearch = false;
    searchingStr = "";
    isGrid = true;
    grid = "Grid";
    isfaverate = false;
    serviceIds = "";
    pageNo = 1;
    pageSize = 10;
    sortColumn = "Newest";
    sortOrder = null;
    cartitemcount = 0;
    errorMessage = "";
    apiConnector = new ApiService();
    categoriesByIdResponse = new CategoriesByIdResponse();
    categoriesByIDListResult = new List<CategoriesByIDListResult>();

    colorImagesResponse = new ColorImagesResponse();
    addtoCartResponse = new AddtoCartResponse();

    getCartResponse = new GetCartResponse();
    postCartRequest = new PostCartRequest();
    productsforpost = new List<ItemsList>();
    colorsResponse = new ColorsResponse();
    colorsListResult = new List<ColorsListResult>();

    // print(" ************* " + this.widget.categoryID);
    // print('Appbar name' + categoryName);

    Future.delayed(Duration.zero, () {
      getPrefs();
    });

    getCartAPICAll();

    getcolorsAPICall();
  }

  getCartAPICAll() async {
    await localData.getIntToSF(LocalData.USERID).then((userid) {
      setState(() {
        loginUserID = userid;
        cartID = 0;

        String cartURL =
            ApiService.baseUrl + ApiService.getCartURL + userid.toString();

        // localData.getIntToSF(LocalData.USERID).then((userid) {
        //   setState(() {
        //     loginUserID = userid;
        //     print(" ******** loginUserID  " + loginUserID.toString());
        //     cartID = 0;

        // String cartURL =
        //     ApiService.baseUrl + ApiService.getCartURL + loginUserID.toString();

        apiConnector.getCartApiCall(cartURL).then((response) {
          print(" GetCartByUserID -- > " + response.toString());

          setState(() {
            // progressHud.hide();
            getCartResponse = GetCartResponse.fromJson(response);
            if (getCartResponse != null && getCartResponse.result != null) {
              setState(() {
                cartitemcount = getCartResponse.result.productsList.length;
                cartID = getCartResponse.result.cart.id;
              });

              print(" cartitemcount -- > " + cartitemcount.toString());
              print(" itemDetailsResponse -- > " +
                  getCartResponse.result.productsList.length.toString());

              if (getCartResponse != null) {
                if (getCartResponse.result != null &&
                    getCartResponse.result.productsList != null) {
                  for (int i = 0;
                      i < getCartResponse.result.productsList.length;
                      i++) {
                    productsforpost.add(new ItemsList(
                        itemId: getCartResponse.result.productsList[i].id,
                        quantity:
                            getCartResponse.result.productsList[i].quantity,
                        colourId: getCartResponse
                                    .result.productsList[i].colourids ==
                                null
                            ? 0
                            : getCartResponse.result.productsList[i].colourids,
                        sizeId: getCartResponse
                                    .result.productsList[i].sizeIds ==
                                null
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
            } else {
              print(" itemDetailsResponse -- > " +
                  getCartResponse.result.productsList.length.toString());
              cartitemcount = 0;
            }
          });
        }).catchError((onError) {});
        //   });
        // });

        //  getWishListAPICall(loginUserID);
      });
    });
  }

  Future getPrefs() async {
    print(" ********************************* ");
    preferences = await SharedPreferences.getInstance();
    serviceIds = preferences.getInt("ServiceTypeId").toString();

    localData.getStringValueSF(LocalData.ITEMTYPEID).then((value) {
      setState(() {
        itemTypeID = value;

        if (this.widget.fromHomeSearch == true) {
          categoriesByIDAPICallForSearch(
              // this.widget.categoryID,
              null,
              serviceIds,
              pageNo,
              pageSize,
              "Newest",
              null,
              this.widget.searchString,
              null,
              null);
        } else {
          categoriesByIDAPICall(finalCategoryID, serviceIds, pageNo, pageSize,
              sortColumn, sortOrder, null, null, null);
        }
      });
    });

    // print(" CatID : " + this.widget.categoryID + "  ServiceID " + serviceIds);
  }

  double _lowerValue = 0;
  double _upperValue = 10000;
  Icon searchIcon = new Icon(
    Icons.search,
    color: Constants.greyColor,
  );

  Widget appbarTitle = Text(categoryName ?? '',
      style: TextStyle(
          color: Constants.greyColor,
          fontSize: 16,
          fontWeight: FontWeight.w700),
      overflow: TextOverflow.ellipsis,
      maxLines: 1);
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    itemHeight = (size.height) / 1.4;
    itemWidth = size.width / 1;

    return WillPopScope(
      onWillPop: () {
        backNavigation();
      },
      child: DefaultTabController(
        length: 5,
        child: Scaffold(
            appBar: AppBar(
              title: appbarTitle,
              backgroundColor: Constants.bgColor,
              leading: GestureDetector(
                onTap: () {
                  print('Home screen');
                  this
                      .widget
                      .refresh(); // just refresh() if its statelesswidget
                  Navigator.pop(context);
                },
                child: Icon(
                  Icons.keyboard_arrow_left,
                  size: 50,
                  color: Constants.greyColor, // add custom icons also
                ),
              ),
              actions: <Widget>[
                firstLoading == true
                    ? Container()
                    : categoriesByIDListResult.length <= 0
                        ? Icon(
                            Icons.keyboard_arrow_left,
                            color: Constants.bgColor,
                          )
                        : new IconButton(
                            icon: this.widget.fromHomeSearch == false
                                ? searchIcon
                                : searchIcon = new Icon(
                                    Icons.close,
                                    color: Colors.black,
                                  ),
                            onPressed: () {
                              setState(() {
                                if (searchIcon.icon == Icons.search) {
                                  print("Search icon clicked");
                                  searchIcon = new Icon(
                                    Icons.close,
                                    color: Colors.black,
                                  );

                                  setState(() {
                                    appbarTitle = new TextField(
                                      keyboardType: TextInputType.text,
                                      textInputAction: TextInputAction.search,
                                      autofocus: true,
                                      onSubmitted: (String searchStr) {
                                        print("**** search submited **** " +
                                            searchStr);
                                        setState(() {
                                          searchingStr = searchStr;

                                          isFromSearch = true;
                                          firstLoading = true;
                                          categoriesByIdResponse =
                                              new CategoriesByIdResponse();
                                          categoriesByIDListResult = new List<
                                              CategoriesByIDListResult>();
                                          categoriesByIDAPICallForSearch(
                                              // this.widget.categoryID,
                                              null,
                                              serviceIds,
                                              pageNo,
                                              pageSize,
                                              "Newest",
                                              null,
                                              searchStr,
                                              null,
                                              null);
                                        });
                                      },
                                      cursorColor: Colors.grey[400],
                                      style: new TextStyle(
                                          color: Constants.greyColor,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700),
                                      decoration: new InputDecoration(
                                          border: InputBorder.none,
                                          hintText: "Search...",
                                          hintStyle: new TextStyle(
                                              color: Colors.grey[400])),
                                    );
                                  });
                                } else {
                                  print(" *** Search canceelled *** ");
                                  // isFromSearch = true;
                                  searchIcon = new Icon(Icons.search,
                                      color: Colors.black);
                                  if (this.widget.fromHomeSearch == false) {
                                    print(" *** from category *** ");
                                    categoryName = this.widget.categoryName;
                                    appbarTitle = Text(
                                      widget.categoryName,
                                      style: TextStyle(
                                          color: Constants.greyColor,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700),
                                    );
                                  } else {
                                    print(" *** from home *** ");
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                NewHomeScreen()));
                                    // categoryName = null;
                                    // appbarTitle = Text(
                                    //   this.widget.searchString,
                                    //   style: TextStyle(
                                    //       color: Constants.greyColor,
                                    //       fontSize: 13,
                                    //
                                    //       fontWeight: FontWeight.w700),
                                    // );
                                  }
                                  setState(() {
                                    isFromSearch = false;
                                    firstLoading = true;
                                    searchingStr = null;
                                    categoriesByIdResponse =
                                        new CategoriesByIdResponse();
                                    categoriesByIDListResult =
                                        new List<CategoriesByIDListResult>();
                                    categoriesByIDAPICallForSearch(
                                        this.widget.categoryID,
                                        serviceIds,
                                        pageNo,
                                        pageSize,
                                        "Newest",
                                        null,
                                        null,
                                        null,
                                        null);
                                  });
                                }
                              });
                            }),
              ],
            ),
            backgroundColor: Colors.grey.shade200,
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
                : Stack(children: <Widget>[
                    Container(
                        child: Column(children: <Widget>[
                      SizedBox(
                        height: 3,
                      ),
                      categoriesByIDListResult.length > 0 &&
                              categoriesByIDListResult != null
                          ? Column(
                              children: [
                                this.widget.fromHomeSearch == true
                                    ? Container()
                                    : this.widget.subCategory == null
                                        ? Container()
                                        : subCategoryList(),
                                Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Container(
                                    height: 60,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(15),
                                        topLeft: Radius.circular(15),
                                      ),
                                      color: Colors.white,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Container(
                                          width: itemWidth / 2,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              GestureDetector(
                                                child: Container(
                                                  child: Row(
                                                    children: <Widget>[
                                                      Text('  Sort',
                                                          style: TextStyle(
                                                              color: Constants
                                                                  .greyColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600)),
                                                      Icon(
                                                        Icons
                                                            .keyboard_arrow_down,
                                                        color: Constants
                                                            .blackColor,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                onTap: () {
                                                  firstLoading = true;
                                                  showModalBottomSheet(
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      context: context,
                                                      builder:
                                                          (BuildContext bc) {
                                                        return Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(2.0),
                                                          child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              color:
                                                                  Colors.white,
                                                              boxShadow: [
                                                                BoxShadow(
                                                                    color: Colors
                                                                        .transparent,
                                                                    spreadRadius:
                                                                        10),
                                                              ],
                                                            ),
                                                            //color: Colors.green,
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: Container(
                                                                //  color: Colors.red,
                                                                child: new Wrap(
                                                                  children: <
                                                                      Widget>[
                                                                    Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .center,
                                                                      children: <
                                                                          Widget>[
                                                                        GestureDetector(
                                                                          onTap:
                                                                              () {
                                                                            isPriceHighToLowSort =
                                                                                false;
                                                                            isPriceLowToHighSort =
                                                                                true;
                                                                            isNewestSort =
                                                                                false;
                                                                            isWholesaleSort =
                                                                                false;
                                                                            Navigator.pop(context);

                                                                            resetCount();
                                                                            setState(() {
                                                                              sortColumn = "Price";
                                                                              sortOrder = "ASC";
                                                                            });
                                                                            categoriesByIDAPICall(
                                                                                this.widget.categoryID,
                                                                                serviceIds,
                                                                                pageNo,
                                                                                pageSize,
                                                                                sortColumn,
                                                                                sortOrder,
                                                                                searchingStr,
                                                                                null,
                                                                                null);
                                                                          },
                                                                          child:
                                                                              Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceBetween,
                                                                            children: [
                                                                              Container(
                                                                                child: Padding(
                                                                                  padding: const EdgeInsets.all(10.0),
                                                                                  child: Align(
                                                                                    alignment: Alignment.topLeft,
                                                                                    child: Text(
                                                                                      "Price Low to High",
                                                                                      style: TextStyle(
                                                                                        fontSize: 13,
                                                                                        fontWeight: FontWeight.w500,
                                                                                        color: Constants.lightgreyColor,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              Visibility(
                                                                                  visible: isPriceLowToHighSort,
                                                                                  child: Icon(
                                                                                    Icons.check,
                                                                                    size: 20,
                                                                                  ))
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        Container(
                                                                          height:
                                                                              1,
                                                                          color:
                                                                              Colors.grey[300],
                                                                        ),
                                                                        GestureDetector(
                                                                          onTap:
                                                                              () {
                                                                            isPriceHighToLowSort =
                                                                                true;
                                                                            isPriceLowToHighSort =
                                                                                false;
                                                                            isNewestSort =
                                                                                false;
                                                                            isWholesaleSort =
                                                                                false;
                                                                            Navigator.pop(context);

                                                                            resetCount();

                                                                            setState(() {
                                                                              sortColumn = "Price";
                                                                              sortOrder = "DESC";
                                                                            });

                                                                            categoriesByIDAPICall(
                                                                                this.widget.categoryID,
                                                                                serviceIds,
                                                                                pageNo,
                                                                                pageSize,
                                                                                sortColumn,
                                                                                sortOrder,
                                                                                searchingStr,
                                                                                null,
                                                                                null);
                                                                          },
                                                                          child:
                                                                              Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceBetween,
                                                                            children: [
                                                                              Container(
                                                                                child: Padding(
                                                                                  padding: const EdgeInsets.all(10.0),
                                                                                  child: Align(
                                                                                    alignment: Alignment.topLeft,
                                                                                    child: Text(
                                                                                      "Price High to Low",
                                                                                      style: TextStyle(
                                                                                        fontSize: 13,
                                                                                        fontWeight: FontWeight.w500,
                                                                                        color: Constants.lightgreyColor,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              Visibility(
                                                                                  visible: isPriceHighToLowSort,
                                                                                  child: Icon(
                                                                                    Icons.check,
                                                                                    size: 20,
                                                                                  ))
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        Container(
                                                                          height:
                                                                              1,
                                                                          color:
                                                                              Colors.grey[300],
                                                                        ),
                                                                        GestureDetector(
                                                                          onTap:
                                                                              () {
                                                                            isPriceHighToLowSort =
                                                                                false;
                                                                            isPriceLowToHighSort =
                                                                                false;
                                                                            isNewestSort =
                                                                                true;
                                                                            isWholesaleSort =
                                                                                false;
                                                                            Navigator.pop(context);

                                                                            resetCount();
                                                                            categoriesByIDAPICall(
                                                                                this.widget.categoryID,
                                                                                serviceIds,
                                                                                pageNo,
                                                                                pageSize,
                                                                                "Newest",
                                                                                null,
                                                                                null,
                                                                                null,
                                                                                null);
                                                                          },
                                                                          child:
                                                                              Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceBetween,
                                                                            children: [
                                                                              Container(
                                                                                child: Padding(
                                                                                  padding: const EdgeInsets.all(10.0),
                                                                                  child: Align(
                                                                                    alignment: Alignment.topLeft,
                                                                                    child: Text(
                                                                                      "Newest",
                                                                                      style: TextStyle(
                                                                                        fontSize: 13,
                                                                                        fontWeight: FontWeight.w500,
                                                                                        color: Constants.lightgreyColor,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              Visibility(
                                                                                  visible: isNewestSort,
                                                                                  child: Icon(
                                                                                    Icons.check,
                                                                                    size: 20,
                                                                                  ))
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
                                              ),
                                              GestureDetector(
                                                child: Container(
                                                  child: Row(
                                                    children: <Widget>[
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(2.0),
                                                        child: Text('Filter',
                                                            style: TextStyle(
                                                                color: Constants
                                                                    .greyColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600)),
                                                      ),
                                                      Image.asset(
                                                        'assets/Icons/filter-32.png',
                                                        height: 14,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                onTap: () {
                                                  //  firstLoading = true;
                                                  filterColorsStr = "";
                                                  filterColorIdsString = null;

                                                  colorsAry = [];
                                                  for (int i = 0;
                                                      i <
                                                          colorsListResult
                                                              .length;
                                                      i++) {
                                                    setState(() {
                                                      colorsListResult[i]
                                                              .isSelectedColor =
                                                          false;
                                                    });
                                                  }
                                                  _lowerValue = 0;
                                                  _upperValue = 0;
                                                  minPricecontroller.clear();
                                                  maxPricecontroller.clear();
                                                  // getcolorsAPICall();

                                                  isFilterClicked = true;
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            // color: Colors.red,
                                            // width: 50.0,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: <Widget>[
                                                GestureDetector(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            5.0),
                                                    child: Text(
                                                      isGrid == true
                                                          ? "Grid"
                                                          : "List",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600),
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    setState(() {
                                                      firstLoading = true;
                                                      pageNo = 1;
                                                      isGrid = !isGrid;
                                                      print(
                                                          " *********** Grid Clicked ***********");
                                                      print(isGrid);
                                                      print(
                                                          " *********** Grid Clicked ***********");
                                                      categoriesByIDListResult
                                                          .clear();
                                                      // pageNo = 1;

                                                      getPrefs();
                                                    });
                                                  },
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 5),
                                                  child: Icon(
                                                    isGrid == true
                                                        ? Icons.grid_on
                                                        : Icons.sort,
                                                    color: Constants.blackColor,
                                                    size: 20,
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
                              ],
                            )
                          : Container(
                              child: Center(
                              child: Column(
                                children: [
                                  Container(
                                    height: 100,
                                  ),
                                  Image.asset(
                                    'assets/Icons/No-products-icon.png',
                                    // height: itemHeight,
                                    color: Constants.lightgreyColor,
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Text(
                                    'No Products Found',
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Constants.lightgreyColor),
                                  ),
                                  SizedBox(
                                    height: 50,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(),
                                      Container(
                                        // height: 45,
                                        width: 200,
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
                                    ],
                                  ),
                                ],
                              ),
                            )),
                      isFromSearch == true || fromHomeSearch == true
                          ? Container(
                              height: 35,
                              width: double.infinity,
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: RichText(
                                  overflow: TextOverflow.clip,
                                  text: new TextSpan(
                                    style: new TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.black,
                                    ),
                                    children: <TextSpan>[
                                      new TextSpan(
                                          text: 'Search Results for  ',
                                          style: new TextStyle(
                                              color: Constants.greyColor,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600)),
                                      new TextSpan(
                                          text: fromHomeSearch == true
                                              ? this.widget.searchString
                                              : searchingStr,
                                          style: new TextStyle(
                                              color: Constants.appColor,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : Container(),
                      Expanded(
                        child: Container(
                            child: Column(
                          children: [
                            isGrid == true ? listViewItems() : gridViewItems(),
                            // Container(
                            //   height: isLoading ? 50.0 : 0,
                            //   color: Colors.transparent,
                            //   child: Center(
                            //     child: new CircularProgressIndicator(),
                            //   ),
                            // ),
                          ],
                        )),
                      ),
                    ])),
                    Visibility(
                      visible: isFilterClicked == true ? true : false,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            // isFilterClicked = false;
                            print("touched on screen");
                          });
                        },
                        child: Container(
                          color: Colors.black54,

                          height: double.infinity,
                          // width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 50, left: 5, right: 5),
                            child: Container(
                                height: 250,
                                color: Colors.transparent,
                                child:
                                    Stack(children: <Widget>[priceDetails()])),
                          ),
                        ),
                      ),
                    ),
                  ]),
            // ),
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.all(0.0),
              child:
                  //  isFilterClicked == true
                  //     ? priceDetails()
                  //     :
                  Container(
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
                          )),
                          Tab(
                              child: Image.asset(
                            'assets/Icons/notification-48.png',
                            height: 20,
                          )),
                        ],
                        // labelColor: Colors.red,
                        // unselectedLabelColor: Colors.grey,
                        // indicatorSize: TabBarIndicatorSize.label,
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
                                builder: (context) => CartScreen(
                                      userID: loginUserID.toString(),
                                      isFromCategory: true,
                                      refresh: refresh,
                                    )));
                          } else if (tabIndex == 3) {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => WishListScreen(
                                      userID: loginUserID.toString(),
                                      isFromCategory: true,
                                      refresh: refresh,
                                    )));
                          } else if (tabIndex == 4) {}
                        },
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ),
    );
  }

  void resetCount() {
    setState(() {
      isnomoreproducts = false;
      isLoading = false;
      pageNo = 1;
      pageSize = 10;
      minimunValue = 0;
      maximumValue = 0;
      categoriesByIDListResult = [];
    });
  }

  Widget listViewItems() {
    return
        //  Padding(
        //   padding: const EdgeInsets.all(1.0),
        //   child: categoriesByIDListResult == null ||
        //           categoriesByIDListResult.length == 0
        //       ? Center(
        //           child: Text(errorMessage, textAlign: TextAlign.center),
        //         )
        //       :
        Expanded(
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          print("List scolling statred");

          if (!isLoading &&
              scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            pageNo = pageNo + 1;
            //  if (categoriesByIDListResult.length < 10) {

            categoriesByIDAPICall(
                this.widget.categoryID,
                serviceIds,
                pageNo,
                pageSize,
                sortColumn,
                sortOrder,
                null,
                minimunValue,
                maximumValue);
            // }
            // start loading data
            // print('--->>> listResultResponse.length' +
            //     categoriesByIDListResult.length.toString());
            // print('--->>> total count' + totalCount.toString());
            // print('--->>> called Notiification listener');
            setState(() {
              isLoading = true;
            });
          }
        },
        child: ListView.builder(
            shrinkWrap: true,
            controller: _scrollController,
            physics: ScrollPhysics(),
            itemCount: categoriesByIDListResult == null
                ? 0
                : categoriesByIDListResult.length,
            itemBuilder: (BuildContext context, int index) {
              var size = MediaQuery.of(context).size;
              final double itemHeight = (size.height) / 4;
              final double itemWidth = size.width / 2.5;
              var savingPrice = categoriesByIDListResult[index].wholeSalePrice -
                  categoriesByIDListResult[index].discountPrince;
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
                height: itemHeight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ItemDetailsScreen(
                                  itemID: categoriesByIDListResult[index]
                                      .itemId
                                      .toString(),
                                  isWishList: categoriesByIDListResult[index]
                                      .isWishlist,
                                  refresh: refresh,
                                  isFromCategory: true,
                                )));
                  },
                  child: Card(
                    elevation: 2,
                    color: Colors.white,
                    child: Stack(children: <Widget>[
                      Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Align(
                            alignment: Alignment.topLeft,
                            child: Container(
                              height: itemHeight,
                              width: itemWidth,
                              color: Constants.imageBGColor,
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: categoriesByIDListResult[index]
                                            .colorSelected ==
                                        false
                                    ? ClipRRect(
                                        child: categoriesByIDListResult[index]
                                                    .filePath !=
                                                null
                                            ? CachedNetworkImage(
                                                fit: BoxFit.cover,
                                                imageUrl: ApiService
                                                        .filerepopath +
                                                    categoriesByIDListResult[
                                                            index]
                                                        .filePath,
                                                // placeholder: (context, url) =>
                                                //     new CircularProgressIndicator(),
                                                errorWidget: (context, url,
                                                        error) =>
                                                    new Image.asset(
                                                        'assets/Rupdarshi.jpg'),
                                              )
                                            : Image.asset(
                                                'assets/Rupdarshi.jpg'))
                                    : sareesImages == null ||
                                            sareesImages.length < 1
                                        ? Container()
                                        : Carousel(
                                            dotSize: 2.0,
                                            dotSpacing: 10.0,
                                            dotColor: Constants.lightgreyColor,
                                            indicatorBgPadding: 5.0,
                                            dotBgColor: Constants.bgGreyColor,
                                            borderRadius: false,
                                            moveIndicatorFromBottom: 180.0,
                                            noRadiusForIndicator: true,
                                            overlayShadow: true,
                                            autoplay: false,
                                            // overlayShadowColors: Colors.green,
                                            overlayShadowSize: 0.4,
                                            dotIncreasedColor:
                                                Constants.greyColor,
                                            images: sareesImages,

                                            animationCurve:
                                                Curves.fastOutSlowIn,
                                            animationDuration: Duration(
                                              microseconds: 1500,
                                            ),
                                            onImageTap: (int imageIndex) {
                                              print("++++++++++++++++++++++");
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ItemDetailsScreen(
                                                            itemID:
                                                                categoriesByIDListResult[
                                                                        index]
                                                                    .itemId
                                                                    .toString(),
                                                            isWishList:
                                                                categoriesByIDListResult[
                                                                        index]
                                                                    .isWishlist,
                                                            refresh: refresh,
                                                            isFromCategory:
                                                                true,
                                                          )));
                                            },
                                          ),
                              ),
                            ),
                          ),
                          // SizedBox(width: 10),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    categoriesByIDListResult == null
                                        ? ""
                                        : categoriesByIDListResult[index]
                                            .itemTypename
                                            .inCaps,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Constants.appColor,
                                      fontSize: 11.0,
                                    ),
                                    overflow: TextOverflow.clip,
                                    maxLines: 1,
                                  ),
                                  Text(
                                    categoriesByIDListResult == null
                                        ? ""
                                        : categoriesByIDListResult[index]
                                            .name
                                            .inCaps,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Constants.blackColor,
                                      fontSize: 12.0,
                                    ),
                                    overflow: TextOverflow.clip,
                                    maxLines: 1,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Row(
                                      // mainAxisAlignment:
                                      //     MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          categoriesByIDListResult[index]
                                                          .discountPrince ==
                                                      0.0 ||
                                                  categoriesByIDListResult[
                                                              index]
                                                          .discountPrince ==
                                                      0
                                              ? ''
                                              : "₹ ${categoriesByIDListResult[index].discountPrince.toStringAsFixed(0)}"
                                                  .replaceAllMapped(
                                                      reg, mathFunc),
                                          style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w600,
                                            color: Constants.boldTextColor,
                                          ),
                                          overflow: TextOverflow.clip,
                                          maxLines: 1,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          categoriesByIDListResult[index]
                                                          .discount ==
                                                      0.0 ||
                                                  categoriesByIDListResult[
                                                              index]
                                                          .discount ==
                                                      0
                                              ? ''
                                              : "₹ ${categoriesByIDListResult[index].wholeSalePrice.toStringAsFixed(0)}"
                                                  .replaceAllMapped(
                                                      reg, mathFunc),
                                          style: TextStyle(
                                            decoration:
                                                TextDecoration.lineThrough,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w600,
                                            color: Constants.lightgreyColor,
                                          ),
                                          overflow: TextOverflow.clip,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          categoriesByIDListResult[index]
                                                          .discount ==
                                                      0.0 ||
                                                  categoriesByIDListResult[
                                                              index]
                                                          .discount ==
                                                      0
                                              ? ""
                                              : "Save ₹${savingPrice.toStringAsFixed(0)}"
                                                  .replaceAllMapped(
                                                      reg, mathFunc),
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                          overflow: TextOverflow.clip,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        ' Barcode  - ',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: Constants.greyColor,
                                        ),
                                        overflow: TextOverflow.clip,
                                        maxLines: 2,
                                      ),
                                      Expanded(
                                        child: Text(
                                          categoriesByIDListResult[index]
                                              .barCode,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Constants.boldTextColor,
                                          ),
                                          overflow: TextOverflow.clip,
                                          maxLines: 2,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                      height: 30,
                                      child: ListView.builder(
                                          primary: false,
                                          itemCount: categoriesByIDListResult[
                                                          index]
                                                      .colorNamesAry !=
                                                  null
                                              ? categoriesByIDListResult[index]
                                                  .colorNamesAry
                                                  .length
                                              : 0,
                                          scrollDirection: Axis.horizontal,
                                          shrinkWrap: true,
                                          itemBuilder: (context, colorindex) {
                                            return GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  categoriesByIDListResult[
                                                              index]
                                                          .selectedColorname =
                                                      categoriesByIDListResult[
                                                                  index]
                                                              .colorNamesAry[
                                                          colorindex];
                                                  categoriesByIDListResult[
                                                              index]
                                                          .selectedColor =
                                                      colorindex;

                                                  sareesImages = [];

                                                  if (oldColorIndex != index) {
                                                    print("00000000000000000");
                                                    print(oldColorIndex);
                                                    categoriesByIDListResult[
                                                            oldColorIndex]
                                                        .colorSelected = false;
                                                  }
                                                  setState(() {
                                                    oldColorIndex = index;
                                                  });

                                                  if (categoriesByIDListResult[
                                                              index]
                                                          .colorSelected ==
                                                      true) {
                                                    print("1111111111111111");
                                                    categoriesByIDListResult[
                                                            index]
                                                        .colorSelected = true;
                                                  } else {
                                                    print("22222222222222222");
                                                    categoriesByIDListResult[
                                                            index]
                                                        .colorSelected = true;
                                                  }

                                                  print(oldColorIndex);
                                                  print(
                                                      categoriesByIDListResult[
                                                              index]
                                                          .colorSelected);
                                                  print(
                                                      categoriesByIDListResult[
                                                              oldColorIndex]
                                                          .colorSelected);
                                                });
                                                print(categoriesByIDListResult[
                                                        index]
                                                    .itemId);

                                                setState(() {
                                                  scrollColorID = colorindex;
                                                  oldListIndex = colorindex;
                                                });
                                                print("scrollColorID -> " +
                                                    scrollColorID.toString());

                                                getColorImages(
                                                    index,
                                                    categoriesByIDListResult[
                                                            index]
                                                        .itemId
                                                        .toString(),
                                                    int.parse(
                                                        categoriesByIDListResult[
                                                                    index]
                                                                .colorIDSAry[
                                                            scrollColorID]),
                                                    categoriesByIDListResult[
                                                                index]
                                                            .colorNamesAry[
                                                        colorindex],
                                                    colorindex);
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(2.0),
                                                child: Container(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            3.0),
                                                    child: Text(
                                                      categoriesByIDListResult[
                                                                      index]
                                                                  .colorNamesAry
                                                                  .length <
                                                              0
                                                          ? ""
                                                          : categoriesByIDListResult[
                                                                      index]
                                                                  .colorNamesAry[
                                                              colorindex],
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w600),
                                                    ),
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade300,
                                                    border: Border.all(
                                                        color: categoriesByIDListResult[
                                                                        index]
                                                                    .selectedColor ==
                                                                colorindex
                                                            ? Constants.appColor
                                                            : Constants
                                                                .bgGreyColor,
                                                        width: 1),

                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                    // color: listItemSizes[index].name.toString()
                                                  ),
                                                ),
                                              ),
                                            );
                                          })),
                                  Spacer(),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        child: Container(
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(2)),
                                                color: Colors.white,
                                                border: Border.all(
                                                    color: Constants
                                                        .lightgreyColor)),
                                            child:
                                                categoriesByIDListResult[index]
                                                            .isWishlist ==
                                                        true
                                                    ? Icon(
                                                        Icons.favorite,
                                                        color: Colors.pink,
                                                        size: 24,
                                                      )
                                                    : Icon(
                                                        Icons.favorite_border,
                                                        size: 24)),
                                        onTap: () {
                                          setState(() {
                                            if (categoriesByIDListResult[index]
                                                    .isWishlist ==
                                                true) {
                                              categoriesByIDListResult[index]
                                                  .isWishlist = false;
                                              isfaverate =
                                                  categoriesByIDListResult[
                                                          index]
                                                      .isWishlist;
                                              removeFromWishListAPICall(
                                                  isfaverate,
                                                  categoriesByIDListResult[
                                                          index]
                                                      .itemId);
                                              print(
                                                  "***** Favarate Added Clicked *****");
                                            } else {
                                              // showAddToast();
                                              categoriesByIDListResult[index]
                                                  .isWishlist = true;
                                              isfaverate =
                                                  categoriesByIDListResult[
                                                          index]
                                                      .isWishlist;
                                              addToWishListAPICall(
                                                  isfaverate,
                                                  categoriesByIDListResult[
                                                          index]
                                                      .itemId);
                                              print(
                                                  "***** Favarate Added Clicked *****");
                                            }
                                            print(
                                                "***** Favarate Clicked *****");
                                            print(isfaverate);
                                            print(
                                                "***** Favarate Clicked *****");
                                          });
                                        },
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(5)),
                                            color: Constants.appColor,
                                          ),
                                          height: 28,
                                          // width: 130,
                                          child: RaisedButton(
                                              color: Constants.appColor,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.shopping_cart,
                                                    color: Colors.white,
                                                    size: 15,
                                                  ),
                                                  Text(
                                                    " Add to Cart",
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              onPressed: () {
                                                print("selectedColor - > " +
                                                    categoriesByIDListResult[
                                                            index]
                                                        .selectedColor
                                                        .toString());
                                                print(
                                                    "categoriesByIDListResult - > " +
                                                        categoriesByIDListResult[
                                                                index]
                                                            .toString());

                                                if (categoriesByIDListResult[
                                                            index] ==
                                                        null ||
                                                    categoriesByIDListResult[
                                                                index]
                                                            .sizeIds ==
                                                        null) {
                                                  if (getCartResponse != null &&
                                                      getCartResponse.result !=
                                                          null) {
                                                    if (getCartResponse !=
                                                            null &&
                                                        getCartResponse
                                                                .result !=
                                                            null) {
                                                      for (int i = 0;
                                                          i <
                                                              getCartResponse
                                                                  .result
                                                                  .productsList
                                                                  .length;
                                                          i++) {
                                                        if (categoriesByIDListResult[
                                                                        index]
                                                                    .colorIds ==
                                                                null &&
                                                            categoriesByIDListResult[
                                                                        index]
                                                                    .sizeIds ==
                                                                null) {
                                                          if (categoriesByIDListResult[
                                                                      index]
                                                                  .itemId ==
                                                              getCartResponse
                                                                  .result
                                                                  .productsList[
                                                                      i]
                                                                  .id) {
                                                            print(
                                                                "Item already in cart");
                                                            apiConnector
                                                                .globalToast(
                                                                    "Item already in cart");
                                                            return;
                                                          } else {
                                                            print(
                                                                "Not in cart");
                                                            addToCartAPICall(
                                                                categoriesByIDListResult[
                                                                        index]
                                                                    .itemId,
                                                                0,
                                                                0);
                                                          }
                                                        }

                                                        if (categoriesByIDListResult[
                                                                        index]
                                                                    .itemId ==
                                                                getCartResponse
                                                                    .result
                                                                    .productsList[
                                                                        i]
                                                                    .id &&
                                                            int.parse(categoriesByIDListResult[
                                                                            index]
                                                                        .colorIDSAry[
                                                                    scrollColorID]) ==
                                                                getCartResponse
                                                                    .result
                                                                    .productsList[
                                                                        i]
                                                                    .colourids) {
                                                          print("*********** " +
                                                              categoriesByIDListResult[
                                                                      index]
                                                                  .itemId
                                                                  .toString() +
                                                              " " +
                                                              getCartResponse
                                                                  .result
                                                                  .productsList[
                                                                      i]
                                                                  .id
                                                                  .toString());
                                                          iteminCart = true;
                                                        }
                                                      }
                                                    }
                                                  }

                                                  if (iteminCart == true) {
                                                    setState(() {
                                                      iteminCart = false;
                                                    });
                                                    apiConnector.globalToast(
                                                        "Item already in cart");
                                                    return;
                                                  }

                                                  if (categoriesByIDListResult[
                                                              index]
                                                          .colorIDSAry !=
                                                      null) {
                                                    if (int.parse(categoriesByIDListResult[
                                                                        index]
                                                                    .colorIDSAry[
                                                                scrollColorID]) ==
                                                            0 ||
                                                        categoriesByIDListResult[
                                                                    index]
                                                                .selectedColor ==
                                                            null) {
                                                      apiConnector.globalToast(
                                                          "Please select colour");
                                                    } else {
                                                      print(
                                                          "calling addto cart api ");
                                                      addToCartAPICall(
                                                          categoriesByIDListResult[
                                                                  index]
                                                              .itemId,
                                                          int.parse(
                                                              categoriesByIDListResult[
                                                                          index]
                                                                      .colorIDSAry[
                                                                  scrollColorID]),
                                                          0);
                                                    }
                                                  }

                                                  if (categoriesByIDListResult[
                                                                  index]
                                                              .colorIds ==
                                                          null &&
                                                      categoriesByIDListResult[
                                                                  index]
                                                              .sizeIds ==
                                                          null) {
                                                    if (getCartResponse ==
                                                            null &&
                                                        getCartResponse
                                                                .result ==
                                                            null) {
                                                      apiConnector.globalToast(
                                                          "Item already in cart");
                                                      return;
                                                    } else {
                                                      print("Not in cart");
                                                      addToCartAPICall(
                                                          categoriesByIDListResult[
                                                                  index]
                                                              .itemId,
                                                          0,
                                                          0);
                                                    }
                                                  }
                                                } else {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              ItemDetailsScreen(
                                                                itemID: categoriesByIDListResult[
                                                                        index]
                                                                    .itemId
                                                                    .toString(),
                                                                isWishList:
                                                                    categoriesByIDListResult[
                                                                            index]
                                                                        .isWishlist,
                                                                isFromCategory:
                                                                    true,
                                                                refresh:
                                                                    refresh,
                                                              )));
                                                }
                                              }),
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
                        child: categoriesByIDListResult[index].discount == 0 ||
                                categoriesByIDListResult[index].discount == 0.0
                            ? Container()
                            : Container(
                                padding: const EdgeInsets.all(5.0),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Constants.appColor,
                                ),
                                child: Text(
                                  categoriesByIDListResult[index]
                                          .discount
                                          .toStringAsFixed(0) +
                                      '%\nOff',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 7),
                                  overflow: TextOverflow.clip,
                                )),
                      ),
                    ]),
                  ),
                ),
              );
            }),
      ),
    );
  }

  Widget noItemFound() {
    return Center(
        child: Column(
      children: [
        Image.asset(
          'assets/Icons/No-products-icon.png',
          height: 90,
          color: Constants.lightgreyColor,
        ),
        Text(
          'No Products  Found',
          style: TextStyle(fontSize: 20, color: Constants.lightgreyColor),
        ),
        Padding(
          padding: const EdgeInsets.all(70.0),
          child: Container(
            height: 45,
            width: 80,
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
                Navigator.of(context).push(new MaterialPageRoute(
                    builder: (context) => new NewHomeScreen()));
              },
            ),
          ),
        ),
      ],
    ));
  }

  Widget gridViewItems() {
    ScrollController controller;

    var size = MediaQuery.of(context).size;
    /*24 is for notification bar on Android*/
    itemHeight = (size.height) / 2.8;
    itemWidth = size.width / 2;
    return categoriesByIDListResult == null ||
            categoriesByIDListResult.length == 0
        ? Center(
            child: Text(errorMessage, textAlign: TextAlign.center),
          )
        : Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                print("List scolling statred");

                if (!isLoading &&
                    scrollInfo.metrics.pixels ==
                        scrollInfo.metrics.maxScrollExtent) {
                  pageNo = pageNo + 1;
                  //  if (categoriesByIDListResult.length < 5) {
                  categoriesByIDAPICall(
                      this.widget.categoryID,
                      serviceIds,
                      pageNo,
                      pageSize,
                      sortColumn,
                      sortOrder,
                      null,
                      minimunValue,
                      maximumValue);

                  setState(() {
                    isLoading = true;
                  });
                }
              },
              child: GridView.count(
                  physics: ClampingScrollPhysics(),
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  childAspectRatio: MediaQuery.of(context).size.height / 1000,
                  controller: controller,
                  children: List.generate(
                      categoriesByIDListResult == null
                          ? 0
                          : categoriesByIDListResult.length, (index2) {
                    var savingPrice = categoriesByIDListResult[index2]
                            .wholeSalePrice
                            .toDouble() -
                        categoriesByIDListResult[index2]
                            .discountPrince
                            .toDouble();
                    return Card(
                      child: Container(
                        child: Stack(
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ItemDetailsScreen(
                                              itemID: categoriesByIDListResult[
                                                      index2]
                                                  .itemId
                                                  .toString(),
                                              isWishList:
                                                  categoriesByIDListResult[
                                                          index2]
                                                      .isWishlist,
                                              isFromProductList: true,
                                              isFromCategory: true,
                                              refresh: refresh,
                                            )));
                              },
                              child: Column(
                                children: <Widget>[
                                  Expanded(
                                    child: Container(
                                      // height:
                                      //     MediaQuery.of(context).size.height / 5,
                                      color: Constants.imageBGColor,
                                      width: itemWidth / 1,
                                      child: Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: categoriesByIDListResult[index2]
                                                    .colorSelected ==
                                                false
                                            ? ClipRRect(
                                                child: categoriesByIDListResult[
                                                                index2]
                                                            .filePath !=
                                                        null
                                                    ? CachedNetworkImage(
                                                        fit: BoxFit.cover,
                                                        imageUrl: ApiService
                                                                .filerepopath +
                                                            categoriesByIDListResult[
                                                                    index2]
                                                                .filePath,
                                                        // placeholder: (context, url) =>
                                                        //     new CircularProgressIndicator(),
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            new Image.asset(
                                                                'assets/Rupdarshi.jpg'),
                                                      )
                                                    : Image.asset(
                                                        'assets/Rupdarshi.jpg'))
                                            : sareesImages == null ||
                                                    sareesImages.length < 1
                                                ? Container()
                                                : Carousel(
                                                    dotSize: 2.0,
                                                    dotSpacing: 10.0,
                                                    dotColor: Constants
                                                        .lightgreyColor,
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
                                                    images: sareesImages,

                                                    animationCurve:
                                                        Curves.fastOutSlowIn,
                                                    animationDuration: Duration(
                                                      microseconds: 1500,
                                                    ),
                                                    onImageTap:
                                                        (int imageIndex) {
                                                      print(
                                                          "++++++++++++++++++++++");
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  ItemDetailsScreen(
                                                                    itemID: categoriesByIDListResult[
                                                                            index2]
                                                                        .itemId
                                                                        .toString(),
                                                                    isWishList:
                                                                        categoriesByIDListResult[index2]
                                                                            .isWishlist,
                                                                    refresh:
                                                                        refresh,
                                                                    isFromCategory:
                                                                        true,
                                                                  )));
                                                    },
                                                  ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    // color: Colors.green[500],
                                    child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Column(
                                        children: <Widget>[
                                          Align(
                                            alignment: Alignment.topLeft,
                                            child: Text(
                                                categoriesByIDListResult[index2]
                                                    .itemTypename
                                                    .inCaps,
                                                style: TextStyle(
                                                  color: Constants.appColor,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 10,
                                                ),
                                                overflow: TextOverflow.clip,
                                                maxLines: 1),
                                          ),
                                          Align(
                                            alignment: Alignment.topLeft,
                                            child: Text(
                                                categoriesByIDListResult[index2]
                                                    .name
                                                    .inCaps,
                                                style: TextStyle(
                                                    color: Constants.greyColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12),
                                                overflow: TextOverflow.clip,
                                                maxLines: 2),
                                          ),
                                          Column(
                                            children: <Widget>[
                                              Row(
                                                // mainAxisAlignment:
                                                //     MainAxisAlignment
                                                //         .spaceBetween,
                                                children: <Widget>[
                                                  Align(
                                                    alignment:
                                                        Alignment.topLeft,
                                                    child: Text(
                                                      "₹ " +
                                                          categoriesByIDListResult[
                                                                  index2]
                                                              .discountPrince
                                                              .toStringAsFixed(
                                                                  0)
                                                              .replaceAllMapped(
                                                                  reg,
                                                                  mathFunc),
                                                      style: TextStyle(
                                                        fontSize: 16.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Constants
                                                            .boldTextColor,
                                                      ),
                                                      overflow:
                                                          TextOverflow.clip,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 4,
                                                  ),
                                                  Text(
                                                    categoriesByIDListResult[
                                                                        index2]
                                                                    .discount ==
                                                                0.0 ||
                                                            categoriesByIDListResult[
                                                                        index2]
                                                                    .discount ==
                                                                0
                                                        ? ""
                                                        : "₹ " +
                                                            categoriesByIDListResult[
                                                                    index2]
                                                                .wholeSalePrice
                                                                .toStringAsFixed(
                                                                    0)
                                                                .replaceAllMapped(
                                                                    reg,
                                                                    mathFunc),
                                                    style: TextStyle(
                                                      decoration: TextDecoration
                                                          .lineThrough,
                                                      fontSize: 9,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Constants
                                                          .lightgreyColor,
                                                    ),
                                                    overflow: TextOverflow.clip,
                                                  ),
                                                  SizedBox(
                                                    width: 4,
                                                  ),
                                                  Text(
                                                    categoriesByIDListResult[
                                                                        index2]
                                                                    .discount ==
                                                                0.0 ||
                                                            categoriesByIDListResult[
                                                                        index2]
                                                                    .discount ==
                                                                0
                                                        ? ""
                                                        : 'Save ₹' +
                                                            savingPrice
                                                                .toStringAsFixed(
                                                                    0)
                                                                .replaceAllMapped(
                                                                    reg,
                                                                    mathFunc),
                                                    style: TextStyle(
                                                      fontSize: 9,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.green,
                                                    ),
                                                    overflow: TextOverflow.clip,
                                                  ),
                                                  // SizedBox(
                                                  //   width: 5,
                                                  // ),
                                                  // Text(
                                                  //   categoriesByIDListResult[index].discount == 0.0 ||
                                                  //           categoriesByIDListResult[index].discount == 0
                                                  //       ? ""
                                                  //       : "(${categoriesByIDListResult[index].discount.toStringAsFixed(0)}%)",
                                                  //   style: TextStyle(
                                                  //       fontSize: 8,
                                                  //       fontWeight:
                                                  //           FontWeight.w600,
                                                  //       color: Constants.appColor,
                                                  //      ),
                                                  //        overflow: TextOverflow.clip,
                                                  // ),
                                                ],
                                              ),
                                            ],
                                          ),

                                          //  Icon(Icons.local_shipping, color: Constants.lightgreyColor,),
                                          Row(
                                            children: [
                                              Text(
                                                ' Barcode  - ',
                                                style: TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      Constants.boldTextColor,
                                                ),
                                                overflow: TextOverflow.clip,
                                                maxLines: 2,
                                              ),
                                              Expanded(
                                                child: Text(
                                                  categoriesByIDListResult[
                                                          index2]
                                                      .barCode,
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        Constants.boldTextColor,
                                                  ),
                                                  overflow: TextOverflow.clip,
                                                  maxLines: 2,
                                                ),
                                              ),
                                            ],
                                          ),
                                          // Padding(
                                          //   padding:
                                          //       const EdgeInsets.only(top: 5.0),
                                          //   child: Align(
                                          //     alignment: Alignment.topLeft,
                                          //     child: Row(
                                          //       children: [
                                          //         Icon(
                                          //           Icons.local_shipping,
                                          //           color:
                                          //               Constants.boldTextColor,
                                          //           size: 12,
                                          //         ),
                                          //         Text(
                                          //           ' Free Delivery',
                                          //           style: TextStyle(
                                          //             fontSize: 9,
                                          //             fontWeight:
                                          //                 FontWeight.bold,
                                          //             color: Constants
                                          //                 .boldTextColor,
                                          //           ),
                                          //           overflow: TextOverflow.clip,
                                          //         ),
                                          //       ],
                                          //     ),
                                          //   ),
                                          // ),

                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Container(
                                                height: 30,
                                                child: ListView.builder(
                                                    primary: false,
                                                    itemCount: categoriesByIDListResult[
                                                                    index2]
                                                                .colorNamesAry !=
                                                            null
                                                        ? categoriesByIDListResult[
                                                                index2]
                                                            .colorNamesAry
                                                            .length
                                                        : 0,
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    shrinkWrap: true,
                                                    itemBuilder:
                                                        (context, colorindex) {
                                                      return GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            scrollColorID = 0;
                                                            categoriesByIDListResult[
                                                                        index2]
                                                                    .selectedColorname =
                                                                categoriesByIDListResult[
                                                                            index2]
                                                                        .colorNamesAry[
                                                                    colorindex];
                                                            categoriesByIDListResult[
                                                                        index2]
                                                                    .selectedColor =
                                                                colorindex;
                                                            sareesImages = [];
                                                            // categoriesByIDListResult[
                                                            //             index2]
                                                            //         .colorSelected =
                                                            //     false;

                                                            if (allColorImages !=
                                                                null) {
                                                              for (int n = 0;
                                                                  n <
                                                                      allColorImages
                                                                          .length;
                                                                  n++) {
                                                                setState(() {
                                                                  if (int.parse(
                                                                          categoriesByIDListResult[index2].colorIDSAry[
                                                                              colorindex]) ==
                                                                      allColorImages[
                                                                              n]
                                                                          .colourId) {}
                                                                });
                                                              }
                                                            }
                                                            if (oldColorIndex2 !=
                                                                categoriesByIDListResult[
                                                                        index2]
                                                                    .itemId) {
                                                              print(
                                                                  "ggggggggggggggg");
                                                              print(
                                                                  oldColorIndex2);
                                                              categoriesByIDListResult[
                                                                      oldColorIndex2]
                                                                  .colorSelected = false;
                                                            }

                                                            setState(() {
                                                              oldColorIndex2 =
                                                                  index2;
                                                            });

                                                            if (categoriesByIDListResult[
                                                                        index2]
                                                                    .colorSelected ==
                                                                true) {
                                                              print(
                                                                  "rrrrrrrrrrrrrrrrr");
                                                              categoriesByIDListResult[
                                                                          index2]
                                                                      .colorSelected =
                                                                  true;
                                                            } else {
                                                              print(
                                                                  "ddddddddddddddddd");
                                                              categoriesByIDListResult[
                                                                          index2]
                                                                      .colorSelected =
                                                                  true;
                                                            }

                                                            print(
                                                                oldColorIndex2);
                                                            print(categoriesByIDListResult[
                                                                    index2]
                                                                .colorSelected);
                                                            print(categoriesByIDListResult[
                                                                    oldColorIndex]
                                                                .colorSelected);
                                                          });
                                                          print(
                                                              categoriesByIDListResult[
                                                                      index2]
                                                                  .itemId);
                                                          print(categoriesByIDListResult[
                                                                      index2]
                                                                  .colorIDSAry[
                                                              colorindex]);
                                                          setState(() {
                                                            scrollColorID =
                                                                colorindex;
                                                          });

                                                          getColorImages(
                                                              index2,
                                                              categoriesByIDListResult[
                                                                      index2]
                                                                  .itemId
                                                                  .toString(),
                                                              int.parse(categoriesByIDListResult[
                                                                          index2]
                                                                      .colorIDSAry[
                                                                  scrollColorID]),
                                                              categoriesByIDListResult[
                                                                          index2]
                                                                      .colorNamesAry[
                                                                  colorindex],
                                                              colorindex);
                                                        },
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(2.0),
                                                          child: Container(
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(3.0),
                                                              child: Text(
                                                                categoriesByIDListResult[index2]
                                                                            .colorNamesAry
                                                                            .length <
                                                                        0
                                                                    ? ""
                                                                    : categoriesByIDListResult[index2]
                                                                            .colorNamesAry[
                                                                        colorindex],
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600),
                                                              ),
                                                            ),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors.grey
                                                                  .shade200,
                                                              border: Border.all(
                                                                  color: categoriesByIDListResult[index2]
                                                                              .selectedColor ==
                                                                          colorindex
                                                                      ? Constants
                                                                          .appColor
                                                                      : Constants
                                                                          .bgGreyColor,
                                                                  width: 1),

                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          4),
                                                              // color: listItemSizes[index].name.toString()
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    })),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          GestureDetector(
                                            child: Container(
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(2)),
                                                    color: Colors.white,
                                                    border: Border.all(
                                                        color: Constants
                                                            .lightgreyColor)),
                                                child: categoriesByIDListResult[
                                                                index2]
                                                            .isWishlist ==
                                                        true
                                                    ? Icon(
                                                        Icons.favorite,
                                                        color: Colors.pink,
                                                        size: 24,
                                                      )
                                                    : Icon(
                                                        Icons.favorite_border,
                                                        size: 24)),
                                            onTap: () {
                                              setState(() {
                                                if (categoriesByIDListResult[
                                                            index2]
                                                        .isWishlist ==
                                                    true) {
                                                  categoriesByIDListResult[
                                                          index2]
                                                      .isWishlist = false;
                                                  isfaverate =
                                                      categoriesByIDListResult[
                                                              index2]
                                                          .isWishlist;
                                                  removeFromWishListAPICall(
                                                      isfaverate,
                                                      categoriesByIDListResult[
                                                              index2]
                                                          .itemId);
                                                  print(
                                                      "***** Favarate Added Clicked *****");
                                                } else {
                                                  categoriesByIDListResult[
                                                          index2]
                                                      .isWishlist = true;
                                                  isfaverate =
                                                      categoriesByIDListResult[
                                                              index2]
                                                          .isWishlist;
                                                  addToWishListAPICall(
                                                      isfaverate,
                                                      categoriesByIDListResult[
                                                              index2]
                                                          .itemId);
                                                  print(
                                                      "***** Favarate Added Clicked *****");
                                                }
                                                print(
                                                    "***** Favarate Clicked *****");
                                                print(isfaverate);
                                                print(
                                                    "***** Favarate Clicked *****");
                                              });
                                            },
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(5)),
                                                color: Constants.appColor,
                                              ),
                                              // color: Constants.appColor,
                                              height: 28,
                                              // width: 130,
                                              child: RaisedButton(
                                                  color: Constants.appColor,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons.shopping_cart,
                                                        color: Colors.white,
                                                        size: 15,
                                                      ),
                                                      Text(
                                                        " Add to Cart",
                                                        // softWrap: true,
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Colors.white,
                                                        ),
                                                        overflow:
                                                            TextOverflow.clip,
                                                      ),
                                                    ],
                                                  ),
                                                  onPressed: () {
                                                    if (categoriesByIDListResult[
                                                                index2]
                                                            .sizeIds ==
                                                        null) {
                                                      if (getCartResponse !=
                                                              null &&
                                                          getCartResponse
                                                                  .result !=
                                                              null) {
                                                        if (getCartResponse !=
                                                                null &&
                                                            getCartResponse
                                                                    .result !=
                                                                null) {
                                                          for (int i = 0;
                                                              i <
                                                                  getCartResponse
                                                                      .result
                                                                      .productsList
                                                                      .length;
                                                              i++) {
                                                            if (categoriesByIDListResult[
                                                                            index2]
                                                                        .colorIds ==
                                                                    null &&
                                                                categoriesByIDListResult[
                                                                            index2]
                                                                        .sizeIds ==
                                                                    null) {
                                                              if (categoriesByIDListResult[
                                                                          index2]
                                                                      .itemId ==
                                                                  getCartResponse
                                                                      .result
                                                                      .productsList[
                                                                          i]
                                                                      .id) {
                                                                print(
                                                                    "Item already in cart");
                                                                apiConnector
                                                                    .globalToast(
                                                                        "Item already in cart");
                                                                return;
                                                              } else {
                                                                print(
                                                                    "Not in cart");
                                                                addToCartAPICall(
                                                                    categoriesByIDListResult[
                                                                            index2]
                                                                        .itemId,
                                                                    0,
                                                                    0);
                                                              }
                                                            }
                                                            if (categoriesByIDListResult[
                                                                            index2]
                                                                        .itemId ==
                                                                    getCartResponse
                                                                        .result
                                                                        .productsList[
                                                                            i]
                                                                        .id &&
                                                                int.parse(categoriesByIDListResult[
                                                                                index2]
                                                                            .colorIDSAry[
                                                                        scrollColorID]) ==
                                                                    getCartResponse
                                                                        .result
                                                                        .productsList[
                                                                            i]
                                                                        .colourids) {
                                                              print("*********** " +
                                                                  categoriesByIDListResult[
                                                                          index2]
                                                                      .itemId
                                                                      .toString() +
                                                                  " " +
                                                                  getCartResponse
                                                                      .result
                                                                      .productsList[
                                                                          i]
                                                                      .id
                                                                      .toString());
                                                              iteminCart = true;
                                                            }
                                                          }
                                                        }
                                                      }

                                                      if (iteminCart == true) {
                                                        setState(() {
                                                          iteminCart = false;
                                                        });
                                                        apiConnector.globalToast(
                                                            "Item already in cart");
                                                        return;
                                                      }

                                                      if (categoriesByIDListResult[
                                                                  index2]
                                                              .colorIDSAry !=
                                                          null) {
                                                        if (int.parse(categoriesByIDListResult[
                                                                            index2]
                                                                        .colorIDSAry[
                                                                    scrollColorID]) ==
                                                                0 ||
                                                            categoriesByIDListResult[
                                                                        index2]
                                                                    .selectedColor ==
                                                                null) {
                                                          apiConnector.globalToast(
                                                              "Please select colour");
                                                        } else {
                                                          addToCartAPICall(
                                                              categoriesByIDListResult[
                                                                      index2]
                                                                  .itemId,
                                                              int.parse(categoriesByIDListResult[
                                                                          index2]
                                                                      .colorIDSAry[
                                                                  scrollColorID]),
                                                              0);
                                                        }
                                                      }

                                                      if (categoriesByIDListResult[
                                                                      index2]
                                                                  .colorIds ==
                                                              null &&
                                                          categoriesByIDListResult[
                                                                      index2]
                                                                  .sizeIds ==
                                                              null) {
                                                        if (getCartResponse ==
                                                                null &&
                                                            getCartResponse
                                                                    .result ==
                                                                null) {
                                                          apiConnector.globalToast(
                                                              "Item already in cart");
                                                          return;
                                                        } else {
                                                          print("Not in cart");
                                                          addToCartAPICall(
                                                              categoriesByIDListResult[
                                                                      index2]
                                                                  .itemId,
                                                              0,
                                                              0);
                                                        }
                                                      }
                                                    } else {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  ItemDetailsScreen(
                                                                    itemID: categoriesByIDListResult[
                                                                            index2]
                                                                        .itemId
                                                                        .toString(),
                                                                    isWishList:
                                                                        categoriesByIDListResult[index2]
                                                                            .isWishlist,
                                                                    isFromCategory:
                                                                        true,
                                                                    refresh:
                                                                        refresh,
                                                                  )));
                                                    }
                                                  }),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Positioned(
                              top: 10,
                              left: 10,
                              child:
                                  categoriesByIDListResult[index2].discount ==
                                              0 ||
                                          categoriesByIDListResult[index2]
                                                  .discount ==
                                              0.0
                                      ? Container()
                                      : Container(
                                          padding: const EdgeInsets.all(5.0),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Constants.appColor,
                                          ),
                                          child: Text(
                                            categoriesByIDListResult[index2]
                                                    .discount
                                                    .toStringAsFixed(0) +
                                                '%\nOff',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 8),
                                            overflow: TextOverflow.clip,
                                          )),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList()),
            ),
          );
  }

  subCategoryList() {
    return Container(
      padding: EdgeInsets.only(top: 8, bottom: 8),
      color: Colors.white,
      width: double.infinity,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 30, minWidth: double.infinity),
        child: ListView.builder(
          itemBuilder: (context, index) {
            return subCategoryListItem(
                this.widget.subCategory[index].name, index);
          },
          primary: false,
          itemCount: this.widget.subCategory == null
              ? 0
              : this.widget.subCategory.length,
          scrollDirection: Axis.horizontal,
        ),
      ),
    );
  }

  subCategoryListItem(String strCategory, int index) {
    double leftMargin = 8;
    double rightMargin = 8;
    if (index == 0) {
      leftMargin = 12;
    }
    if (index == listCategory.length - 1) {
      rightMargin = 12;
    }
    if (isrefreshes == true) {
      // setState(() {
      pageNo = 1;

      // });
    }
    return GestureDetector(
      child: Container(
        child: Text(this.widget.subCategory[index].name,
            style: TextStyle(
                color: this.widget.subCategory[index].isSelected == true
                    ? Constants.bgColor
                    : Constants.lightgreyColor,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
        margin: EdgeInsets.only(left: leftMargin, right: rightMargin),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 6),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(15)),
            border: Border.all(color: Constants.appColor, width: 1.5),
            color: this.widget.subCategory[index].isSelected == true
                ? Constants.appColor
                : Constants.bgColor),
      ),
      onTap: () {
        setState(() {
          searchingStr = null;
          if (oldIndex != index) {
            print(oldIndex);
            this.widget.subCategory[oldIndex].isSelected = false;
          }
          oldIndex = index;
          finalCategoryID = this.widget.subCategory[index].id.toString();
          if (this.widget.subCategory[index].isSelected == true) {
            this.widget.subCategory[index].isSelected = true;
            print('ffffffffffffffffffffffff');
          } else {
            print("tttttttttttttt");
            isFromSearch = false;
            firstLoading = true;
            categoriesByIdResponse = new CategoriesByIdResponse();
            categoriesByIDListResult = new List<CategoriesByIDListResult>();
            this.widget.subCategory[index].isSelected = true;
            resetCount();
            print("selected Sub cat ID  " +
                this.widget.subCategory[index].id.toString());
            categoriesByIDAPICall(finalCategoryID, serviceIds, pageNo, pageSize,
                "Newest", null, null, null, null);
          }

          if (this.widget.subCategory[index].name == "All") {
            resetCount();
            print("All Sub cat IDs  " + this.widget.categoryID);
            categoriesByIDAPICall(this.widget.categoryID, serviceIds, pageNo,
                pageSize, "Newest", null, null, null, null);
          } else {
            print(
                "Sub cat ID  " + this.widget.subCategory[index].id.toString());
          }

          print("Sub cat ID  " + finalCategoryID.toString());
        });
      },
    );
  }

  categoriesByIDAPICall(
      String categoryIDs,
      String serviceIds,
      int pageNo,
      int pageSize,
      String sortColumn,
      String sortOrder,
      String searchStr,
      int minPrice,
      int maxPrice) async {
    // progressHud.show();
    print("searchStr  " + searchingStr.toString());
    print("minPrice  " + minPrice.toString());
    print("maxPrice  " + maxPrice.toString());
    String categoriesByIDsURL =
        ApiService.baseUrl + ApiService.getCategoriesByIDs;
    Map<String, dynamic> parameters = {
      "VendorId": loginUserID,
      "CategoryIds":
          searchingStr == null || searchingStr == "" ? finalCategoryID : null,
      "ServiceIds": serviceIds,
      "ColourIds": filterColorIdsString,
      "PageNo": pageNo,
      "TypeId": itemTypeID,
      "PageSize": 10,
      "SortColumn": sortColumn,
      "SortOrder": sortOrder,
      "SearchName": searchingStr,
      "MinPrice": minPrice == 0 ? null : minPrice,
      "MaxPrice": maxPrice == 0 ? null : maxPrice
    };

    await apiConnector
        .postAPICall(categoriesByIDsURL, parameters)
        .then((response) {
      // progressHud.hide();
      setState(() {
        // progressHud.hide();
        categoriesByIdResponse = CategoriesByIdResponse.fromJson(response);
        // print(' categoriesByID response -----  ' + response.toString());
        firstLoading = false;

        if (categoriesByIDListResult.length < 10) {
          print(' ---------- pagination completed');
        } else {
          print(' ---------- pagination not completed');
        }

        if (isrefreshes == true) {
          categoriesByIDListResult.clear();
        }

        isrefreshes = false;

        categoriesByIDListResult.addAll(categoriesByIdResponse.listResult);
        totalCount = categoriesByIdResponse.affectedRecords;
        if (categoriesByIDListResult.length > 0) {
          for (int n = 0; n < categoriesByIDListResult.length; n++) {
            categoriesByIDListResult[n].colorSelected = false;

            if (categoriesByIDListResult[n].colorNames != null) {
              // print(categoriesByIDListResult[n].colorNames);

              // print(categoriesByIDListResult[n].colorNames.split(","));
              categoriesByIDListResult[n].colorNames.split(",");
              setState(() {
                categoriesByIDListResult[n].colorNamesAry =
                    categoriesByIDListResult[n].colorNames.split(",");
                categoriesByIDListResult[n].colorIDSAry =
                    categoriesByIDListResult[n].colorIds.split(",");
                categoriesByIDListResult[n].colorselection = [false];
              });
            }

            // for (int k = 0;
            //     k < categoriesByIDListResult[n].colorNamesAry.length;
            //     k++) {
            //   setState(() {
            //     colorsArray[k].iscolorSelected = false;
            //   });
            // }
          }
        }

        print('--->>> total count ' + totalCount.toString());
        isLoading = false;
        if (categoriesByIDListResult == null ||
            categoriesByIDListResult == null ||
            categoriesByIDListResult.length == 0) {
          //_datamsg = 'No Data Available';
        }
      });
      // progressHud.hide();
    });
  }

  categoriesByIDAPICallForSearch(
      String categoryIDs,
      String serviceIds,
      int pageNo,
      int pageSize,
      String sortColumn,
      String sortOrder,
      String searchStr,
      int minPrice,
      int maxPrice) async {
    String categoriesByIDsURL =
        ApiService.baseUrl + ApiService.getCategoriesByIDs;
    Map<String, dynamic> parameters = {
      "VendorId": loginUserID,
      "CategoryIds": null,
      "ServiceIds": serviceIds,
      "ColourIds": filterColorIdsString,
      "PageNo": pageNo,
      "TypeId": itemTypeID,
      "PageSize": 10,
      "SortColumn": sortColumn,
      "SortOrder": sortOrder,
      "SearchName": searchStr,
      "MinPrice": minPrice == 0 ? null : minPrice,
      "MaxPrice": maxPrice == 0 ? null : maxPrice
    };

    await apiConnector
        .postAPICall(categoriesByIDsURL, parameters)
        .then((response) {
      print(' categoriesByID response -----  ' + response.toString());
      setState(() {
        _lowerValue = 0;
        _upperValue = 10000;

        categoriesByIdResponse = CategoriesByIdResponse.fromJson(response);
        firstLoading = false;
        if (categoriesByIdResponse.isSuccess == true) {
          categoriesByIDListResult.addAll(categoriesByIdResponse.listResult);
          totalCount = categoriesByIdResponse.affectedRecords;
          if (categoriesByIDListResult.length > 0) {
            for (int n = 0; n < categoriesByIDListResult.length; n++) {
              if (categoriesByIDListResult[n].colorNames != null) {
                categoriesByIDListResult[n].colorNames.split(",");
                setState(() {
                  categoriesByIDListResult[n].colorNamesAry =
                      categoriesByIDListResult[n].colorNames.split(",");
                  categoriesByIDListResult[n].colorIDSAry =
                      categoriesByIDListResult[n].colorIds.split(",");
                });
              }
            }
          }

          if (isFromSearch == true &&
              categoriesByIdResponse.affectedRecords == 0) {
            setState(() {
              isFromSearch = false;
            });
          }

          if (categoriesByIDListResult.length < 10) {
            print(' ---------- pagination completed');
          }
          print('--->>> total count ' + totalCount.toString());
          isLoading = false;
          if (categoriesByIDListResult == null ||
              categoriesByIDListResult == null ||
              categoriesByIDListResult.length == 0) {
            //_datamsg = 'No Data Available';
          }
        }
      });
    });
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
        setState(() {
          apiConnector.globalToast(response["EndUserMessage"]);
        });
      }
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

    print('productsforpost.length ' + productsforpost.length.toString());

    if (productsforpost.length > 0) {
      var items = productsforpost
          .where((p) => p.itemId == categoryList.itemId)
          .toList();
      print('items.length ' + items.length.toString());
      if (items != null && items.length > 0) {
        print(' ------ enter Items Quantity ' +
            items[0].itemId.toString() +
            " " +
            items[0].quantity.toString());

        productsforpost
            .removeWhere((item) => item.itemId == categoryList.itemId);

        productsforpost.add(new ItemsList(
            itemId: categoryList.itemId, quantity: categoryList.itemCount));
      } else {
        productsforpost.add(new ItemsList(
            itemId: categoryList.itemId, quantity: categoryList.itemCount));
      }
    } else {
      productsforpost.add(new ItemsList(
          itemId: categoryList.itemId, quantity: categoryList.itemCount));
    }

    cartModel.items = productsforpost;
    apiConnector.postCartUpdate(cartModel).then((cartResponce) {
      if (cartResponce == 200) {
        print('Narmada ------- Added Cart Success');
        print('cartResponce response  -------' + cartResponce.toString());
      } else {
        print('-- -------- No items' + cartResponce.toString());
        // Toast.show('Unable to Proceed', context,
        //     duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
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
          // Toast.show('Unable to Proceed', context,
          //     duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        }
      });
    });
  }

  addToCartAPICall(int itemID, int colorID, int rowIndex) {
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

      var item =
          getCartResponse.result.productsList.where((x) => x.id == itemID);
      if (null != item) {
        var localitem = productsforpost.where((x) => x.itemId == itemID);

        if (null != localitem) {
          productsforpost.add(new ItemsList(
              itemId: itemID,
              quantity: 1,
              colourId: colorID == 0 ? null : colorID,
              sizeId: null));
        }
      }
    } else {
      productsforpost.add(new ItemsList(
          itemId: itemID,
          quantity: 1,
          colourId: colorID == 0 ? null : colorID,
          sizeId: null));
    }

    cartModel.items = productsforpost;

    print(" *************** " + productsforpost.length.toString());

    apiConnector.postCartUpdate(cartModel).then((cartResponce) {
      print('cartResponce response  -------' + cartResponce.toString());
      addtoCartResponse = AddtoCartResponse.fromJson(cartResponce);

      if (addtoCartResponse.isSuccess == true) {
        setState(() {
          getCartAPICAll();
          // cartitemcount++;
          setState(() {
            // isAlreadyInCart = true;
            // firstLoading = true;
            // cartitemcount++;
            // getItemDetails(this.widget.itemID);
            iteminCart = false;
            scrollColorID = 0;
          });
          apiConnector.globalToast("Item Added to Cart");
        });
      }
    });
  }

  getColorImages(int itemIndex, String colorID, int colorIDs, String colorName,
      int colorIndex) async {
    String colorimagesAPI =
        ApiService.baseUrl + ApiService.colorImagesURL + colorID.toString();
    print(" color images API  -- > " + colorimagesAPI.toString());

    apiConnector.getAPICall(colorimagesAPI).then((response) {
      print(" color images -- > " + response.toString());
      print(" colorIDs -- > " + colorIDs.toString());

      setState(() {
        colorImagesResponse = new ColorImagesResponse();
        colorImagesResponse = ColorImagesResponse.fromJson(response);
        if (colorImagesResponse.isSuccess == true) {
          setState(() {
            allColorImages = [];
            sareesImages = [];

            if (colorImagesResponse.listResult.length > 0) {
              setState(() {
                allColorImages = colorImagesResponse.listResult;
              });
              for (int n = 0; n < colorImagesResponse.listResult.length; n++) {
                setState(() {
                  if (colorName ==
                      colorImagesResponse.listResult[n].colourName) {
                    setState(() {
                      categoriesByIDListResult[itemIndex]
                              .colorIDSAry[colorIndex] =
                          colorImagesResponse.listResult[n].colourId.toString();
                      print(" both are equal -- > " +
                          colorName.toString() +
                          " " +
                          colorImagesResponse.listResult[n].colourName
                              .toString());
                      print(colorImagesResponse.listResult[n].colourName
                          .toString());
                      if (colorImagesResponse.listResult[n].fileLocation !=
                          null) {
                        sareesImages.add(colorImagesResponse.listResult != null
                            ? CachedNetworkImage(
                                fit: BoxFit.fill,
                                imageUrl: colorImagesResponse
                                    .listResult[n].fileLocation,
                                placeholder: (context, url) => Center(
                                    child: Container(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(),
                                )),
                                errorWidget: (context, url, error) =>
                                    Image.asset('assets/Rupdarshi.jpg'),
                              )
                            : CachedNetworkImage(
                                imageUrl: colorImagesResponse
                                    .listResult[n].fileLocation,
                                placeholder: (context, url) => Center(
                                    child: Container(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(),
                                )),
                                errorWidget: (context, url, error) =>
                                    Image.asset('assets/Rupdarshi.jpg'),
                              ));
                      }
                    });
                  }
                });
              }

              print(allColorImages.length);
            }
          });
        }
      });
    });
  }

  getWishListAPICall(int userID) async {
    // progressHud.show();
    String getWishListURL =
        ApiService.baseUrl + ApiService.getWishList + userID.toString();
    GetWishListResponse getWishListResponse;
    getWishListResponse = new GetWishListResponse();
    print(" ******** WishList  " + getWishListURL.toString());

    apiConnector.getAPICall(getWishListURL).then((response) {
      setState(() {
        // firstLoading = false;
        // progressHud.hide();
        print(" ******** WishList  " + response.toString());

        getWishListResponse = GetWishListResponse.fromJson(response);
        if (getWishListResponse != null &&
            getWishListResponse.listResult.length > 0) {
          setState(() {
            List<WishListResult> wishlist;

            wishlist = new List<WishListResult>();

            List<int> catAry;
            catAry = [];

            for (int k = 0; k < getWishListResponse.listResult.length; k++) {
              wishlist.add(getWishListResponse.listResult[k]);
            }

            for (int n = 0; n < categoriesByIDListResult.length; n++) {
              catAry.add(categoriesByIDListResult[n].itemId);

              for (int z = 0; z < wishlist.length; z++) {
                print(categoriesByIDListResult[n].itemId.toString() +
                    "  " +
                    wishlist[z].itemId.toString());

                if (catAry.contains(wishlist[z].itemId)) {
                  print("ssssssssssss");
                  setState(() {
                    if (categoriesByIDListResult[z].itemId ==
                        wishlist[z].itemId) {
                      setState(() {
                        categoriesByIDListResult[n].isWishlist = true;
                      });
                    }
                  });

                  // if (wishlist[z].isWishlist == true) {

                  // }
                  // else{
                  //   setState(() {
                  //     categoriesByIDListResult[n].isWishlist = false;

                  //   });

                  // }

                } else {
                  print("888888888888888");

                  setState(() {
                    categoriesByIDListResult[n].isWishlist = false;
                  });
                }
              }
            }
          });
        } else {
          setState(() {
            errorMessage = "No wishlist found";
            for (int n = 0; n < categoriesByIDListResult.length; n++) {
              categoriesByIDListResult[n].isWishlist = false;
            }
          });
        }
      });
    });
  }

  getcolorsAPICall() {
    String getColorsURL = ApiService.baseUrl + ApiService.getColorsURL;
    print("getColorsURL -> " + getColorsURL);

    apiConnector.getAPICall(getColorsURL).then((response) {
      colorsResponse = ColorsResponse.fromJson(response);
      print("colorsResponse -> " + colorsResponse.toString());

      if (colorsResponse.isSuccess == true) {
        if (colorsResponse.listResult.length > 0) {
          setState(() {
            colorsListResult = colorsResponse.listResult;

            print("colorsListResult -> " + colorsListResult.length.toString());

            for (int i = 0; i < colorsListResult.length; i++) {
              setState(() {
                colorsListResult[i].isSelectedColor = false;
              });
            }
          });
        } else {
          apiConnector.globalToast(colorsResponse.endUserMessage);
        }
      } else {
        apiConnector.globalToast(colorsResponse.endUserMessage);
      }
    });
  }

  void backNavigation() {
    this.widget.refresh(); // just refresh() if its statelesswidget
    Navigator.pop(context);
  }

  Widget priceDetails() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.white,
              blurRadius: 1,
              //  offset: Offset(2, 2),
            ),
          ],
          border: Border.all(color: Colors.grey, width: 1.5),
          borderRadius: BorderRadius.circular(3),
          // color: listItemSizes[index].name.toString()
        ),
        child: Padding(
            padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
            child: Column(children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                    child: Wrap(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 0, bottom: 8.0),
                      child: Text(
                        ' Price Range',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Container(
                            height: 40,
                            //  width: 100,
                            child: TextFormField(
                              controller: minPricecontroller,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                WhitelistingTextInputFormatter.digitsOnly
                              ],
                              //                   onSaved: (val) {
                              //   print('min value' + minimunValue);
                              //     print('min controller' + minPricecontroller.text);
                              //   setState(() {
                              //     minimunValue = val;
                              //   });
                              // },
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(8.0),
                                  hintText: 'Min *',
                                  labelStyle: TextStyle(
                                      color: Constants.lightgreyColor,
                                      fontSize: 8,
                                      fontWeight: FontWeight.w600),
                                  border: new OutlineInputBorder(
                                    borderSide: new BorderSide(),
                                  )),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            ' - ',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            height: 40,
                            //   width: 100,
                            child: TextFormField(
                              controller: maxPricecontroller,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                WhitelistingTextInputFormatter.digitsOnly
                              ],
                              onSaved: (val) {
                                setState(() {
                                  maximumValue = int.parse(val);
                                  print('Max' + maximumValue.toString());
                                });
                              },
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(8.0),
                                  hintText: 'Max *',
                                  labelStyle: TextStyle(
                                      color: Constants.lightgreyColor,
                                      fontSize: 8,
                                      fontWeight: FontWeight.w600),
                                  border: new OutlineInputBorder(
                                    borderSide: new BorderSide(),
                                  )),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 5, left: 0, bottom: 8.0),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              ' Colors',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 40,
                            child: ListView.builder(
                                primary: false,
                                itemCount: colorsListResult.length,
                                scrollDirection: Axis.horizontal,
                                // shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        // if (filterOldColorIndex != -1) {
                                        //   print(filterOldColorIndex);
                                        //   colorsListResult[index]
                                        //       .isSelectedColor = false;
                                        //   print("============ " +
                                        //       index.toString());
                                        // }

                                        //  filterOldColorIndex = index;

                                        if (colorsListResult[index]
                                                .isSelectedColor ==
                                            true) {
                                          colorsListResult[index]
                                              .isSelectedColor = false;
                                          print("*********** " +
                                              colorsListResult[index]
                                                  .id
                                                  .toString());

                                          if (colorsAry.contains(
                                              colorsListResult[index].id)) {
                                            colorsAry.remove(
                                                colorsListResult[index].id);
                                          }
                                        } else {
                                          print("filtor color");
                                          print("%%%%%%%%%%%% " +
                                              index.toString());

                                          colorsListResult[index]
                                              .isSelectedColor = true;

                                          colorsAry
                                              .add(colorsListResult[index].id);
                                        }

                                        print(colorsAry);

                                        filterColorIdsString = colorsAry
                                            .map((i) => i.toString())
                                            .join(",");
                                        print(filterColorIdsString);
                                      });
                                    },
                                    child: Container(
                                      height: 40,
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Text(
                                            colorsListResult[index].name,
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: Constants.greyColor,
                                                fontWeight: FontWeight.w600),
                                            overflow: TextOverflow.clip,
                                          ),
                                        ),
                                      ),
                                      margin: EdgeInsets.only(
                                          top: 4, bottom: 4, right: 10),
                                      // width: 30,
                                      // height: 30,
                                      decoration: BoxDecoration(
                                        boxShadow: <BoxShadow>[
                                          BoxShadow(
                                            color: Colors.white,
                                            blurRadius: 3,
                                            offset: Offset(2, 2),
                                          ),
                                        ],
                                        border: colorsListResult[index]
                                                    .isSelectedColor ==
                                                true
                                            ? Border.all(
                                                color: Constants.appColor,
                                                width: 1.5)
                                            : Border.all(
                                                color: Colors.grey, width: 1.5),
                                        borderRadius: BorderRadius.circular(5),
                                        // color: listItemSizes[index].name.toString()
                                      ),
                                    ),
                                  );
                                }),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Container(
                              child: RaisedButton(
                                child: Text(
                                  " Clear ",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Constants.blackColor,
                                  ), // overflow: TextOverflow.clip,
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
                                  isFromSearch = false;
                                  firstLoading = true;
                                  isFilterClicked = false;
                                  // Navigator.pop(
                                  //     context);
                                  setState(() {
                                    // Navigator.pop(context);
                                    setState(() {
                                      isnomoreproducts = false;
                                      isLoading = false;
                                      pageNo = 1;
                                      pageSize = 10;
                                      minimunValue = 0;
                                      maximumValue = 0;
                                    });
                                    filterColorIdsString = null;

                                    colorsAry = [];

                                    categoriesByIdResponse =
                                        new CategoriesByIdResponse();
                                    categoriesByIDListResult =
                                        new List<CategoriesByIDListResult>();
                                    categoriesByIDAPICall(
                                        this.widget.categoryID,
                                        serviceIds,
                                        pageNo,
                                        pageSize,
                                        "Newest",
                                        null,
                                        null,
                                        null,
                                        null);
                                  });
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '   ',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: RaisedButton(
                                color: Constants.appColor,
                                child: Text(
                                  " Apply ",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    isnomoreproducts = false;
                                    isLoading = false;
                                    pageNo = 1;
                                    pageSize = 10;
                                    minimunValue = 0;
                                    maximumValue = 0;
                                  });
                                  minimunValue = minPricecontroller.text != ""
                                      ? int.parse(minPricecontroller.text)
                                      : minimunValue;
                                  maximumValue = maxPricecontroller.text != ""
                                      ? int.parse(maxPricecontroller.text)
                                      : maximumValue;

                                  print('minimunValue value ++++++++' +
                                      minimunValue.toString());

                                  print('max value ++++++++' +
                                      maximumValue.toString());

                                  if (minimunValue == 0 &&
                                      maximumValue == 0 &&
                                      filterColorIdsString == null) {
                                    print('Return ++++++++');
                                    apiConnector.globalToast(
                                        'Please select Price or Color');
                                    setState(() {
                                      isFilterClicked = false;
                                    });
                                    return;
                                  }

                                  // if (maximumValue < minimunValue) {
                                  //   apiConnector.globalToast(
                                  //       'Min price cannot be greater than max price');
                                  // }
                                  //  else if (maximumValue == 0 &&
                                  //     filterColorIdsString != null &&
                                  //     filterColorIdsString != "") {
                                  //   apiConnector
                                  //       .globalToast('Select price');
                                  // }

                                  else {
                                    if (maximumValue < minimunValue) {
                                      apiConnector.globalToast(
                                          'Min price cannot be greater than max price');
                                      setState(() {
                                        isFilterClicked = false;
                                        minimunValue = 0;
                                        maximumValue = 0;
                                      });

                                      return;
                                    } else {
                                      isFromSearch = false;
                                      firstLoading = true;
                                      isFilterClicked = false;
                                      sortColumn = "Newest";
                                      sortOrder = "ASC";
                                      print('minimum Value---- ' +
                                          minPricecontroller.text);
                                      print('maximum Value---- ' +
                                          maxPricecontroller.text);
                                      print("**** Apply Clicked **** ");
                                      setState(() {
                                        //  Navigator.pop(context);

                                        categoriesByIdResponse =
                                            new CategoriesByIdResponse();
                                        categoriesByIDListResult = new List<
                                            CategoriesByIDListResult>();

                                        categoriesByIDAPICall(
                                            this.widget.categoryID,
                                            serviceIds,
                                            pageNo,
                                            pageSize,
                                            sortColumn,
                                            sortOrder,
                                            null,
                                            minimunValue,
                                            maximumValue);
                                      });
                                    }
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                )),
              )
            ])),
      ),
    );
  }
}

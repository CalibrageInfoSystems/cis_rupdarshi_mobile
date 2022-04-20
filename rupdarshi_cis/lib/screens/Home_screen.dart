import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rupdarshi_cis/Model/AllItemsResponse.dart';
import 'package:rupdarshi_cis/Model/GetCartResponse.dart';
import 'package:rupdarshi_cis/Model/ItemTypeResponse.dart';
import 'package:rupdarshi_cis/Service/ApiService.dart';
import 'package:rupdarshi_cis/common/Constants.dart';
import 'package:rupdarshi_cis/common/LocalDb.dart';
import 'package:rupdarshi_cis/common/SessionManager.dart';
import 'package:rupdarshi_cis/screens/CartScreen.dart';
import 'package:rupdarshi_cis/screens/CategoriesScreen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:rupdarshi_cis/screens/ItemDetailsScreen.dart';
import 'package:rupdarshi_cis/screens/MyOrder.dart';
import 'package:rupdarshi_cis/screens/AccountScreen.dart';
import 'package:rupdarshi_cis/screens/NewHomeScreen.dart';
import 'package:rupdarshi_cis/Model/AllCategoriesResponse.dart';
import 'WishList.dart';
import 'login_screen.dart';
import 'package:progress_dialog/progress_dialog.dart';

final GlobalKey<State> _keyLoader = new GlobalKey<State>();
ProgressDialog pr;

class HomeScreen extends StatefulWidget {
  final String itemTypeID;
  final List<CategoryListResult> categoryTypes;
  final int itemTypeIndex;
  final finalItemType;
  HomeScreen(
      {this.itemTypeID,
      this.categoryTypes,
      this.itemTypeIndex,
      this.finalItemType});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController searchcontroller = new TextEditingController();
  List<String> listCategory = new List();
  String finalItemType = "";
  bool _visible = false;
  int oldMoreIndex = -1;
  int oldItemType = 0;
  bool isExpandable = false;
  int userid;
  int loginUserID = 0;
  int cartID = 0;
  bool firstLoading = true;
  int _cIndex = 0;
  bool islogin = false;
  ProgressDialog progressHud;
  void _incrementTab(index) {
    setState(() {
      _cIndex = index;
    });
  }

  ScrollController controller;
  ItemTypeResponse itemTypeResponse;
  int cartitemcount = 0;
  ApiService apiConnector;
  GetCartResponse getCartResponse;
  AllItemsResponse allItemsResponse;
  AllCategoriesResponse allCategoriesResponse;
  List<Category> categoryListResult;
  List<Category> subCategoryListResult;
  List<List<Category>> subCategires;
  LocalData localData = new LocalData();

  Icon searchIcon = new Icon(
    Icons.search,
    color: Constants.greyColor,
  );
  Widget appbarTitle = Image.asset(
    'assets/logo-o.png',
    fit: BoxFit.fitHeight,
  );

  refresh() {
    setState(() {
      print('Refresh Wishlist');
      localData.getIntToSF(LocalData.USERID).then((userid) {
        setState(() {
          loginUserID = userid;
          cartID = 0;
          // Future.delayed(Duration.zero, () {
          // progressHud =
          //     new ProgressDialog(context, type: ProgressDialogType.Normal);

          getCartDetails(userid.toString());
          // });
        });
      });
    });
  }

  @override
  void initState() {
    super.initState();
    isExpandable = false;
    oldMoreIndex = -1;
    oldItemType = 0;
    cartitemcount = 0;
    firstLoading = true;
    pr = new ProgressDialog(context);
    SessionManager().getIsLogin().then((value) {
      islogin = value;
      print('is login new splash $islogin');
    });
    SessionManager().getUserId().then((value) {
      userid = value;
      print('User ID :' + userid.toString());
    });
    apiConnector = new ApiService();
    allItemsResponse = new AllItemsResponse();
    allCategoriesResponse = new AllCategoriesResponse();
    categoryListResult = new List<Category>();
    subCategoryListResult = new List<Category>();
    subCategires = new List<List<Category>>();
    //  allItemlistResult = new List<AllItem>();

    print("*********************");
    finalItemType = this.widget.itemTypeID;
    print(this.widget.itemTypeID);

    getCategoriesAPICall(finalItemType);
    getCategoryTypeAPICall();
    localData.addStringToSF(LocalData.ITEMTYPEID, finalItemType);

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
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double itemHeight = (size.height) / 4;
    final double itemWidth = size.width / 2;

    return WillPopScope(
        onWillPop: () async {
          Navigator.pop(context);
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => NewHomeScreen()));
          return true;
        },
        child: DefaultTabController(
          length: 5,
          child: Scaffold(
              appBar: AppBar(
                leading: Builder(builder: (BuildContext context) {
                  return IconButton(
                    icon: new Icon(
                      Icons.sort,
                      color: Constants.greyColor,
                      size: 35,
                    ),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  );
                }),
                backgroundColor: Constants.bgColor,
                centerTitle: true,
                title: appbarTitle,
                actions: <Widget>[
                  new IconButton(
                      icon: searchIcon,
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
                                  print(
                                      "**** search submited **** " + searchStr);
                                  setState(() {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                CategoriesScreen(
                                                  searchString: searchStr,
                                                  fromHomeSearch: true,
                                                  refresh: refresh,
                                                )));
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
                                    hintStyle:
                                        new TextStyle(color: Colors.grey[400])),
                              );
                            });
                          } else {
                            print(" *** Search canceelled *** ");
                            // isFromSearch = true;
                            searchIcon =
                                new Icon(Icons.search, color: Colors.black);
                            appbarTitle = Image.asset(
                              'assets/logo-o.png',
                              fit: BoxFit.fitHeight,
                            );
                          }
                        });
                      }),
                ],
              ),
              drawer: Drawer(
                // Add a ListView to the drawer. This ensures the user can scroll
                // through the options in the drawer if there isn't enough vertical
                // space to fit everything.
                child: ListView(
                  // Important: Remove any padding from the ListView.
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    DrawerHeader(
                      child: Center(
                          child: Image.asset(
                        'assets/logo-o.png',
                        fit: BoxFit.fill,
                      )),
                      decoration: BoxDecoration(
                        color: Colors.white,
                      ),
                    ),
                    ListTile(
                      leading: Image.asset(
                        'assets/Icons/icons8-home-page-48.png',
                        height: 20,
                      ),
                      title: Text('Home'),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => NewHomeScreen()));
                      },
                    ),
                    Divider(),
                    ListTile(
                      leading: Image.asset(
                        'assets/Icons/user-48.png',
                        height: 20,
                      ),
                      title: Text('Account'),
                      onTap: () {
                        // Navigator.pop(context);
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => AccountScreen()));
                      },
                    ),
                    Divider(),
                    ListTile(
                      leading: Image.asset(
                        'assets/Icons/icons8-shopping-cart-48.png',
                        height: 20,
                      ),
                      title: Text('Cart'),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => CartScreen(
                                  userID: userid.toString(),
                                  isfromNewHome: true,
                                  refresh: refresh,
                                )));
                      },
                    ),
                    Divider(),
                    ListTile(
                      leading: Image.asset(
                        'assets/Icons/heart-48.png',
                        height: 20,
                      ),
                      title: Text('Wish list'),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => WishListScreen(
                                  userID: userid.toString(),
                                  refresh: refresh,
                                  isFromHome: true,
                                )));
                      },
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(
                        Icons.local_shipping,
                        color: Colors.black,
                        size: 20,
                      ),
                      title: Text('My Orders'),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => MyOrderScreen()));
                      },
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(
                        Icons.exit_to_app,
                        color: Colors.black,
                        size: 20,
                      ),
                      title: Text('LogOut'),
                      onTap: () {
                        SessionManager().setIsLogin(false);

                        setState(() {
                          localData.clearLocalDta();
                          sharedPreferencesClear();
                        });

                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (BuildContext context) => LoginPage()));
                      },
                    ),
                    Divider(),
                  ],
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
                  : Container(
                      child: Column(
                        children: <Widget>[
                          categoryTypeList(),
                          categoryListResult.length > 0
                              ? Expanded(
                                  child: Container(
                                    child: ListView(
                                      children: <Widget>[categories()],
                                    ),
                                  ),
                                )
                              : Container(
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
                                        'No Products  Found',
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
                      ),
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
                              // color: Constants.appColor,
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
                                        isFromHome: true,
                                        refresh: refresh,
                                      )));
                            } else if (tabIndex == 3) {
                              print(finalItemType);
                              localData.addStringToSF(
                                  "finalItemType", finalItemType);
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => WishListScreen(
                                        userID: loginUserID.toString(),
                                        refresh: refresh,
                                        isFromHome: true,
                                        finalItemType: finalItemType,
                                      )));
                            } else if (tabIndex == 4) {
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) => NewProfileScreen()));
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              )),
        ));
  }

  Widget categories() {
    return categoryListResult == null
        ? Center(
            child: Text('No Data ..'),
          )
        : Container(
            color: Constants.homeBGColor,
            // decoration: BoxDecoration(
            //     borderRadius: BorderRadius.circular(100),
            //     shape: BoxShape.rectangle),
            child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount:
                    categoryListResult == null ? 0 : categoryListResult.length,
                itemBuilder: (BuildContext context, int index) {
                  final _screenSize = MediaQuery.of(context).size;
                  var size = MediaQuery.of(context).size;
                  final double itemHeight = (size.height) / 3.5;
                  final double itemWidth = size.width / 2.2;
                  return Card(
                      color: Colors.white,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              List<int> idsArry = [];
                              String idsString = "";
                              if (allCategoriesResponse
                                      .listResult[index].subCategory.length >
                                  0) {
                                for (int i = 0;
                                    i <
                                        allCategoriesResponse.listResult[index]
                                            .subCategory.length;
                                    i++) {
                                  idsArry.add(allCategoriesResponse
                                      .listResult[index].subCategory[i].id);
                                }

                                idsString =
                                    idsArry.map((i) => i.toString()).join(",");
                                print(idsString);
                              }

                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => CategoriesScreen(
                                        categoryID:
                                            idsString == "" ? "0" : idsString,
                                        categoryName:
                                            categoryListResult[index].name,
                                        fromHomeSearch: false,
                                        subCategory: allCategoriesResponse
                                            .listResult[index].subCategory,
                                        refresh: refresh,
                                      )));
                            },
                            child: Container(
                              width: itemWidth,
                              height: 200,
                              color: Constants.imageBGColor,
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(0.0),
                                    child: categoryListResult[index].filepath !=
                                            null
                                        ? CachedNetworkImage(
                                            fit: BoxFit.fill,
                                            imageUrl: ApiService.filerepopath +
                                                categoryListResult[index]
                                                    .filepath,
                                            // placeholder: (context, url) =>
                                            //     new CircularProgressIndicator(),
                                            errorWidget: (context, url,
                                                    error) =>
                                                new Image.asset(
                                                    'assets/Rupdarshi.jpg'), //// YOU CAN CREATE YOUR OWN ERROR WIDGET HERE
                                          )
                                        : Image.asset('assets/Rupdarshi.jpg')),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                GestureDetector(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: Container(
                                      child: Text(
                                        categoryListResult[index].name.inCaps,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Constants.greyColor,
                                          fontSize: 15.0,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    List<int> idsArry = [];
                                    String idsString = "";
                                    if (allCategoriesResponse.listResult[index]
                                            .subCategory.length >
                                        0) {
                                      for (int i = 0;
                                          i <
                                              allCategoriesResponse
                                                  .listResult[index]
                                                  .subCategory
                                                  .length;
                                          i++) {
                                        idsArry.add(allCategoriesResponse
                                            .listResult[index]
                                            .subCategory[i]
                                            .id);
                                      }

                                      idsString = idsArry
                                          .map((i) => i.toString())
                                          .join(",");
                                      print(idsString);
                                    }

                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                CategoriesScreen(
                                                  categoryID: idsString == ""
                                                      ? "0"
                                                      : idsString,
                                                  categoryName:
                                                      categoryListResult[index]
                                                          .name,
                                                  fromHomeSearch: false,
                                                  subCategory:
                                                      allCategoriesResponse
                                                          .listResult[index]
                                                          .subCategory,
                                                  refresh: refresh,
                                                )));
                                  },
                                ),
                                SizedBox(height: 5),
                                Container(
                                  height: 2,
                                  width: 50,
                                  color: Constants.appColor,
                                ),
                                SizedBox(height: 10),
                                allCategoriesResponse
                                            .listResult[index].subCategory ==
                                        null
                                    ? Center(
                                        child: Text(''),
                                      )
                                    : Column(children: [
                                        ListView.builder(
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount: allCategoriesResponse
                                                        .listResult[index]
                                                        .subCategory ==
                                                    null
                                                ? 0
                                                : allCategoriesResponse
                                                            .listResult[index]
                                                            .category
                                                            .isSelected ==
                                                        false
                                                    ? allCategoriesResponse
                                                                .listResult[
                                                                    index]
                                                                .subCategory
                                                                .length >
                                                            4
                                                        ? 4
                                                        : allCategoriesResponse
                                                            .listResult[index]
                                                            .subCategory
                                                            .length
                                                    : allCategoriesResponse
                                                        .listResult[index]
                                                        .subCategory
                                                        .length,
                                            // ? allCategoriesResponse
                                            //     .listResult[index]
                                            //     .subCategory
                                            //     .length
                                            // : allCategoriesResponse
                                            //     .listResult[index]
                                            //     .subCategory
                                            //     .length,
                                            itemBuilder: (BuildContext context,
                                                int index2) {
                                              return GestureDetector(
                                                child: Container(
                                                  height: itemHeight / 6.5,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 5),
                                                    child: Column(
                                                      children: <Widget>[
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: <Widget>[
                                                            Flexible(
                                                              child: Text(
                                                                  allCategoriesResponse
                                                                      .listResult[
                                                                          index]
                                                                      .subCategory[
                                                                          index2]
                                                                      .name
                                                                      .inCaps,
                                                                  style:
                                                                      TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    color: Constants
                                                                        .blackColor,
                                                                    fontSize:
                                                                        12.0,
                                                                  ),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  maxLines: 1),
                                                            ),
                                                            Icon(
                                                              Icons
                                                                  .keyboard_arrow_right,
                                                              size: 20,
                                                              color:
                                                                  Colors.grey,
                                                            )
                                                          ],
                                                        ),
                                                        // SizedBox(
                                                        //   height: 4,
                                                        // ),
                                                        Container(
                                                          height: 1,
                                                          color:
                                                              Colors.grey[400],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                onTap: () {
                                                  // print(allCategoriesResponse.listResult[index].subCategory[index2].name);
                                                  // allCategoriesResponse.listResult[index].subCategory.insert(0, new Category(name: "All", id: null, isSelected: true));
                                                  Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              CategoriesScreen(
                                                                categoryID: allCategoriesResponse
                                                                    .listResult[
                                                                        index]
                                                                    .subCategory[
                                                                        index2]
                                                                    .id
                                                                    .toString(),
                                                                categoryName: allCategoriesResponse
                                                                    .listResult[
                                                                        index]
                                                                    .subCategory[
                                                                        index2]
                                                                    .name,
                                                                fromHomeSearch:
                                                                    false,
                                                                refresh:
                                                                    refresh,
                                                              )));
                                                },
                                              );
                                            }),
                                        Visibility(
                                          visible: allCategoriesResponse
                                                      .listResult[index]
                                                      .subCategory
                                                      .length >
                                                  4
                                              ? true
                                              : false,
                                          // _visible,
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                if (allCategoriesResponse
                                                        .listResult[index]
                                                        .category
                                                        .isSelected ==
                                                    true) {
                                                  setState(() {
                                                    allCategoriesResponse
                                                        .listResult[index]
                                                        .category
                                                        .isSelected = false;
                                                    print(allCategoriesResponse
                                                        .listResult[index]
                                                        .category
                                                        .isSelected);
                                                  });
                                                } else {
                                                  setState(() {
                                                    allCategoriesResponse
                                                        .listResult[index]
                                                        .category
                                                        .isSelected = true;
                                                    print(allCategoriesResponse
                                                        .listResult[index]
                                                        .category
                                                        .isSelected);
                                                  });
                                                }
                                              });
                                            },
                                            child: Container(
                                              height: itemHeight / 6.5,
                                              color: Colors.white,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: <Widget>[
                                                  Text(
                                                    allCategoriesResponse
                                                                .listResult[
                                                                    index]
                                                                .category
                                                                .isSelected ==
                                                            false
                                                        ? 'More'
                                                        : "Less",
                                                    // allCategoriesResponse.listResult[index].subCategory[index2].name.inCaps,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Constants.appColor,
                                                      fontSize: 12.0,
                                                    ),
                                                    // overflow: TextOverflow.fade,
                                                  ),
                                                  Icon(
                                                    Icons.keyboard_arrow_right,
                                                    size: 20,
                                                    color: Colors.grey,
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ]),
                              ],
                            ),
                          ),
                        ],
                      ));
                }),
          );
  }

  Widget expandedCategories() {
    return categoryListResult == null
        ? Center(
            child: Text('No Data ..'),
          )
        : Container(
            color: Constants.homeBGColor,
            // decoration: BoxDecoration(
            //     borderRadius: BorderRadius.circular(100),
            //     shape: BoxShape.rectangle),
            child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount:
                    categoryListResult == null ? 0 : categoryListResult.length,
                itemBuilder: (BuildContext context, int index) {
                  final _screenSize = MediaQuery.of(context).size;
                  var size = MediaQuery.of(context).size;
                  final double itemHeight = (size.height) / 3.5;
                  final double itemWidth = size.width / 2.2;
                  return Card(
                      color: Colors.white,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            width: itemWidth,
                            height: 200,
                            color: Constants.imageBGColor,
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(0.0),
                                  child: categoryListResult[index].filepath !=
                                          null
                                      ? CachedNetworkImage(
                                          fit: BoxFit.fill,
                                          imageUrl: categoryListResult[index]
                                              .filepath,
                                          // placeholder: (context, url) =>
                                          //     new CircularProgressIndicator(),
                                          errorWidget: (context, url, error) =>
                                              new Image.asset(
                                                  'assets/Rupdarshi.jpg'), //// YOU CAN CREATE YOUR OWN ERROR WIDGET HERE
                                        )
                                      : Image.asset('assets/Rupdarshi.jpg')),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                GestureDetector(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: Container(
                                      child: Text(
                                        categoryListResult[index].name.inCaps,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Constants.greyColor,
                                          fontSize: 15.0,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    List<int> idsArry = [];
                                    String idsString = "";
                                    if (allCategoriesResponse.listResult[index]
                                            .subCategory.length >
                                        0) {
                                      for (int i = 0;
                                          i <
                                              allCategoriesResponse
                                                  .listResult[index]
                                                  .subCategory
                                                  .length;
                                          i++) {
                                        idsArry.add(allCategoriesResponse
                                            .listResult[index]
                                            .subCategory[i]
                                            .id);
                                      }

                                      idsString = idsArry
                                          .map((i) => i.toString())
                                          .join(",");
                                      print(idsString);
                                    }

                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                CategoriesScreen(
                                                  categoryID: idsString == ""
                                                      ? "0"
                                                      : idsString,
                                                  categoryName:
                                                      categoryListResult[index]
                                                          .name,
                                                  fromHomeSearch: false,
                                                  subCategory:
                                                      allCategoriesResponse
                                                          .listResult[index]
                                                          .subCategory,
                                                  refresh: refresh,
                                                )));
                                  },
                                ),
                                SizedBox(height: 5),
                                Container(
                                  height: 2,
                                  width: 50,
                                  color: Colors.black12,
                                ),
                                SizedBox(height: 10),
                                allCategoriesResponse
                                            .listResult[index].subCategory ==
                                        null
                                    ? Center(
                                        child: Text(''),
                                      )
                                    : Column(children: [
                                        ListView.builder(
                                            shrinkWrap: true,
                                            itemCount: allCategoriesResponse
                                                .listResult[index]
                                                .subCategory
                                                .length,
                                            //  itemCount: allCategoriesResponse.listResult[index].subCategory == null ? 0 : allCategoriesResponse.listResult[index].subCategory.length > 4 ? 4 : allCategoriesResponse.listResult[index].subCategory.length,
                                            itemBuilder: (BuildContext context,
                                                int index2) {
                                              return GestureDetector(
                                                child: Container(
                                                  height: itemHeight / 6.5,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 5),
                                                    child: Column(
                                                      children: <Widget>[
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: <Widget>[
                                                            Flexible(
                                                              child: Text(
                                                                  allCategoriesResponse
                                                                      .listResult[
                                                                          index]
                                                                      .subCategory[
                                                                          index2]
                                                                      .name
                                                                      .inCaps,
                                                                  style:
                                                                      TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    color: Constants
                                                                        .blackColor,
                                                                    fontSize:
                                                                        12.0,
                                                                  ),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  maxLines: 1),
                                                            ),
                                                            Icon(
                                                              Icons
                                                                  .keyboard_arrow_right,
                                                              size: 20,
                                                              color:
                                                                  Colors.grey,
                                                            )
                                                          ],
                                                        ),
                                                        // SizedBox(
                                                        //   height: 4,
                                                        // ),
                                                        Container(
                                                          height: 1,
                                                          color:
                                                              Colors.grey[400],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                onTap: () {
                                                  // print(allCategoriesResponse.listResult[index].subCategory[index2].name);
                                                  // allCategoriesResponse.listResult[index].subCategory.insert(0, new Category(name: "All", id: null, isSelected: true));
                                                  Navigator.of(context).push(MaterialPageRoute(
                                                      builder: (context) => CategoriesScreen(
                                                          categoryID:
                                                              allCategoriesResponse
                                                                  .listResult[
                                                                      index]
                                                                  .subCategory[
                                                                      index2]
                                                                  .id
                                                                  .toString(),
                                                          categoryName:
                                                              allCategoriesResponse
                                                                  .listResult[
                                                                      index]
                                                                  .subCategory[
                                                                      index2]
                                                                  .name,
                                                          fromHomeSearch: false,
                                                          subCategory:
                                                              allCategoriesResponse
                                                                  .listResult[
                                                                      index]
                                                                  .subCategory,
                                                          refresh: refresh)));
                                                },
                                              );
                                            }),
                                        Visibility(
                                          visible: allCategoriesResponse
                                                      .listResult[index]
                                                      .subCategory
                                                      .length >
                                                  4
                                              ? true
                                              : false,
                                          // _visible,
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                allCategoriesResponse
                                                    .listResult[index]
                                                    .subCategory[0]
                                                    .isSelected = false;
                                                allCategoriesResponse
                                                    .listResult[index]
                                                    .subCategory[0]
                                                    .isSelected = isExpandable;
                                                print('less' +
                                                    isExpandable.toString());

                                                isExpandable = false;
                                              });
                                            },
                                            child: Container(
                                              height: itemHeight / 6.5,
                                              color: Colors.white,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: <Widget>[
                                                  Text(
                                                    'Less',
                                                    // allCategoriesResponse.listResult[index].subCategory[index2].name.inCaps,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color:
                                                          Constants.blackColor,
                                                      fontSize: 12.0,
                                                    ),
                                                    // overflow: TextOverflow.fade,
                                                  ),
                                                  Icon(
                                                    Icons.keyboard_arrow_right,
                                                    size: 20,
                                                    color: Colors.grey,
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ]),
                              ],
                            ),
                          ),
                        ],
                      ));
                }),
          );
  }

  categoryTypeList() {
    return Container(
      padding: EdgeInsets.only(top: 8, bottom: 8),
      color: Colors.white,
      width: double.infinity,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 30, minWidth: double.infinity),
        child: ListView.builder(
          itemBuilder: (context, index) {
            return subCategoryListItem(this.widget.itemTypeID, index);
          },
          primary: false,
          itemCount:
              itemTypeResponse == null ? 0 : itemTypeResponse.listResult.length,
          scrollDirection: Axis.horizontal,
        ),
      ),
    );
  }

  subCategoryListItem(String strCategory, int index) {
    double leftMargin = 8;
    double rightMargin = 8;
    // if (index == 0) {
    //   leftMargin = 12;
    // }
    // if (index == listCategory.length - 1) {
    //   rightMargin = 12;
    // }
    return GestureDetector(
      child: Container(
        child: Text(
            itemTypeResponse.listResult[index].name == null
                ? ""
                : itemTypeResponse.listResult[index].name.inCaps,
            style: TextStyle(
                color: itemTypeResponse.listResult[index].isSeleted == true
                    ? Constants.bgColor
                    : Constants.lightgreyColor,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
        margin: EdgeInsets.only(left: leftMargin, right: rightMargin),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 6),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(15)),
            border: Border.all(color: Constants.appColor, width: 1.5),
            color: itemTypeResponse.listResult[index].isSeleted == true
                ? Constants.appColor
                : Constants.bgColor),
      ),
      onTap: () {
        setState(() {
          finalItemType = itemTypeResponse.listResult[index].id.toString();
          for (int k = 0; k < itemTypeResponse.listResult.length; k++) {
            itemTypeResponse.listResult[k].isSeleted = false;
          }

          if (oldItemType != index) {
            print(oldItemType);
            itemTypeResponse.listResult[oldItemType].isSeleted = false;
          }
          oldItemType = index;
          if (itemTypeResponse.listResult[index].isSeleted == true) {
            itemTypeResponse.listResult[index].isSeleted = false;
          } else {
            print("tttttttttttttt");
            itemTypeResponse.listResult[index].isSeleted = true;
          }

          firstLoading = true;
          localData.addStringToSF(LocalData.ITEMTYPEID, finalItemType);

          print("Sub cat ID  " +
              itemTypeResponse.listResult[index].id.toString());

          getCategoriesAPICall(finalItemType.toString());
        });
      },
    );
  }

  getAllItemsList() async {
    await apiConnector.getAllItems().then((response) {
      setState(() {
        if (response.listResult != null && response.listResult.length > 0) {
          allItemsResponse = response;
        }
      });
    });
  }

  getCategoriesAPICall(String itemTypeID) async {
    String categoryURL = ApiService.baseUrl +
        ApiService.getAllCategoriesURL +
        itemTypeID.toString();
    await apiConnector.getAPICall(categoryURL).then((response) {
      setState(() {
        allCategoriesResponse = new AllCategoriesResponse();
        print(categoryURL);
        allCategoriesResponse = AllCategoriesResponse.fromJson(response);
        firstLoading = false;
        categoryListResult.clear();

        if (allCategoriesResponse.isSuccess == true) {
          for (int i = 0; i < allCategoriesResponse.listResult.length; i++) {
            categoryListResult
                .add(allCategoriesResponse.listResult[i].category);
            print('object newww ++++++++++++++++++++++++++++++++  ' +
                allCategoriesResponse.listResult[i].subCategory.length
                    .toString());

            setState(() {
              allCategoriesResponse.listResult[i].category.isSelected = false;
            });

            for (int j = 0;
                j < allCategoriesResponse.listResult[i].subCategory.length;
                j++) {
              if (allCategoriesResponse.listResult[i].subCategory.length > 4) {
                setState(() {
                  print(' sub act count  ' + j.toString());
                  // allCategoriesResponse.listResult[i].subCategory[j].isSelected =
                  //     isExpandable;

                  _visible = true;
                });
              } else {}
            }
          }
        }
      });
    });
  }

  getCartDetails(String userID) async {
    print(" selected Userid -- > " + userid.toString());
    String finalUrl = ApiService.baseUrl + ApiService.getCartURL + userID;
    print(" finalUrl -- > " + finalUrl);
    await apiConnector.getCartApiCall(finalUrl).then((response) {
      print(" GetCartByUserID -- > " + response.toString());

      setState(() {
        progressHud.hide();
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
    }).catchError((onError) {});
  }

  getCategoryTypeAPICall() async {
    String itemTypeURL = ApiService.baseUrl + ApiService.getItemTypeURL;
    print('itemTypeURL ' + itemTypeURL);
    await apiConnector.getAPICall(itemTypeURL).then((response) {
      setState(() {
        itemTypeResponse = ItemTypeResponse.fromJson(response);
        if (itemTypeResponse.isSuccess == true) {
          // itemTypeResponse.listResult[oldItemType].isSeleted = true;
          // itemTypeResponse.listResult[widget].isSeleted = true;

          for (int i = 0; i < itemTypeResponse.listResult.length; i++) {
            if (this.widget.itemTypeID ==
                itemTypeResponse.listResult[i].id.toString()) {
              itemTypeResponse.listResult[i].isSeleted = true;
            }
          }
        }
        // firstLoading = false;

        print('-----  ' + itemTypeResponse.listResult.length.toString());
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

  Future<void> sharedPreferencesClear() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
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

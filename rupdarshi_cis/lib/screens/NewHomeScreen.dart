import 'package:badges/badges.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rupdarshi_cis/Model/AllItemsResponse.dart';
import 'package:rupdarshi_cis/Model/BannerImagesResponse.dart';
import 'package:rupdarshi_cis/Model/GetCartResponse.dart';
import 'package:rupdarshi_cis/Model/ItemTypeResponse.dart';
import 'package:rupdarshi_cis/Service/ApiService.dart';
import 'package:rupdarshi_cis/common/Constants.dart';
import 'package:rupdarshi_cis/common/LocalDb.dart';
import 'package:rupdarshi_cis/common/SessionManager.dart';
import 'package:rupdarshi_cis/screens/CartScreen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:rupdarshi_cis/screens/Home_screen.dart';
import 'package:rupdarshi_cis/screens/MyOrder.dart';
import 'package:rupdarshi_cis/screens/AccountScreen.dart';
import 'package:rupdarshi_cis/Model/AllCategoriesResponse.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'WishList.dart';
import 'login_screen.dart';
import 'package:progress_dialog/progress_dialog.dart';

extension CapExtension1 on String {
  String get inCapsH => '${this[0].toUpperCase()}${this.substring(1)}';
  String get allInCapsH => this.toUpperCase();
}

final GlobalKey<State> _keyLoader = new GlobalKey<State>();
ProgressDialog pr;

class NewHomeScreen extends StatefulWidget {
  @override
  _NewHomeScreenState createState() => _NewHomeScreenState();
}

class _NewHomeScreenState extends State<NewHomeScreen> {
  TextEditingController searchcontroller = new TextEditingController();
  bool _visible = false;
  var images = [];
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

  String errorMessage = "";
  ScrollController controller;
  int cartitemcount = 0;
  ApiService apiConnector;
  GetCartResponse getCartResponse;
  AllItemsResponse allItemsResponse;
  AllCategoriesResponse allCategoriesResponse;
  ItemTypeResponse itemTypeResponse;
  BannerImagesResponse bannerImagesResponse;
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
      print('Refresh New Home');
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
    cartitemcount = 0;
    errorMessage = "";
    firstLoading = true;
    images = [];
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
    itemTypeResponse = new ItemTypeResponse();
    bannerImagesResponse = new BannerImagesResponse();
    categoryListResult = new List<Category>();
    subCategoryListResult = new List<Category>();
    subCategires = new List<List<Category>>();
    //  allItemlistResult = new List<AllItem>();

    print("*********************");

    // getCategoriesAPICall();
    getCategoryTypeAPICall();
    getBannerList();
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

  Widget imageCarousel = Container(
    padding: EdgeInsets.only(top: 1),
    child: Carousel(
      overlayShadow: false,
      dotBgColor: Colors.transparent,
      borderRadius: true,
      dotColor: Colors.grey,
      boxFit: BoxFit.cover,
      autoplay: true,
      dotSize: 3.0,

      // dotHorizontalPadding: 2.0,
      // dotVerticalPadding: 2.0,
      dotPosition: DotPosition.bottomLeft,
      // indicatorBgPadding: 20.0,
      images: [
        ClipRRect(
          child: new Image.asset('assets/banner1.jpg', fit: BoxFit.fill),
          // borderRadius: BorderRadius.circular(8.0)
        ),
        ClipRRect(
          child: new Image.asset('assets/banner2.jpg', fit: BoxFit.fill),
          // borderRadius: BorderRadius.circular(8.0)
        ),
      ],
      animationCurve: Curves.fastOutSlowIn,
      animationDuration: Duration(microseconds: 1500),
    ),
  );

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double itemHeight = (size.height) / 4;
    final double itemWidth = size.width / 2;

    return WillPopScope(
      onWillPop: () {
        SystemNavigator.pop();
      },
      child: DefaultTabController(
        length: 5,
        child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
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
              actions: <Widget>[],
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
                                isFromNewHome: true,
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
                : bannerImagesResponse.listResult != null ||
                        itemTypeResponse.listResult != null ||
                        itemTypeResponse.listResult.length > 0
                    ? Container(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Container(
                                width: double.maxFinite,
                                height: itemHeight,
                                color: Constants.imageBGColor,
                                child: bannerImagesResponse.listResult != null
                                    ? Container(
                                        width: double.infinity,
                                        child: Carousel(
                                          overlayShadow: false,
                                          dotBgColor: Colors.transparent,
                                          borderRadius: true,
                                          dotColor: Constants.greyColor,
                                          dotIncreasedColor: Constants.appColor,

                                          boxFit: BoxFit.cover,
                                          autoplay: true,
                                          dotSize: 4.0,
                                          dotHorizontalPadding: -10.0,
                                          dotVerticalPadding: -7.0,
                                          dotPosition: DotPosition.bottomLeft,
                                          // indicatorBgPadding: 20.0,

                                          images: images,
                                          animationCurve: Curves.fastOutSlowIn,
                                          animationDuration:
                                              Duration(microseconds: 1500),
                                        ),
                                      )
                                    : Container(),
                              ),
                            ),
                            Expanded(
                              child: ListView(
                                children: <Widget>[itemTypesView()],
                              ),
                            ),
                          ],
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
                            color: Constants.appColor,
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
                            // Navigator.of(context).pushReplacement(MaterialPageRoute(
                            //     builder: (context) => NewHomeScreen()));
                          } else if (tabIndex == 1) {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => AccountScreen()));
                          } else if (tabIndex == 2) {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => CartScreen(
                                      userID: userid.toString(),
                                      isfromNewHome: true,
                                      refresh: refresh,
                                    )));
                          } else if (tabIndex == 3) {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => WishListScreen(
                                      userID: loginUserID.toString(),
                                      refresh: refresh,
                                      isFromNewHome: true,
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
      ),
    );
  }

  itemTypesView() {
    ScrollController controller;
    /*24 is for notification bar on Android*/

    return itemTypeResponse == null || itemTypeResponse.listResult == null
        ? Center(
            child: Text(errorMessage, textAlign: TextAlign.center),
          )
        : GridView.count(
            physics: ClampingScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: 2,
            childAspectRatio: MediaQuery.of(context).size.height / 750,
            mainAxisSpacing: 10.0,
            crossAxisSpacing: 10.0,
            controller: controller,
            padding: const EdgeInsets.all(5.0),
            children: itemTypeResponse.listResult.map((
              value,
            ) {
              return Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black45,
                        offset: Offset(2, 2),
                        blurRadius: 4,
                      ),
                    ]),
                child: Column(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          print(value.id.toString());
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => HomeScreen(
                                    itemTypeID: value.id.toString(),
                                  )));
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10)),
                          child: value.filepath != null
                              ? CachedNetworkImage(
                                  width: double.infinity,
                                  fit: BoxFit.fill,
                                  imageUrl: value.filepath,
                                  placeholder: (context, url) => Center(

                                      //  child: new CircularProgressIndicator()
                                      child: Container(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(),
                                  )),
                                  errorWidget: (context, url, error) =>
                                      new Image.asset('assets/Rupdarshi.jpg'),
                                )
                              : Image.asset('assets/Rupdarshi.jpg'),

                          // image: AssetImage('assets/saree.jpg')
                          // decoration: BoxDecoration(
                          //     color: Constants.imageBGColor,
                          //     borderRadius: BorderRadius.only(
                          //         topLeft: Radius.circular(8),
                          //         topRight: Radius.circular(8))),
                        ),
                      ),
                    ),
                    value.name == null || value.name == ""
                        ? Container()
                        : Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              value.name == null || value.name == ""
                                  ? ""
                                  : value.name.inCapsH,
                              style: TextStyle(
                                  color: Constants.boldTextColor,
                                  fontWeight: FontWeight.bold),
                            ),
                          )
                  ],
                ),
              );
            }).toList());
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

  getBannerList() async {
    String bannerListURL = ApiService.baseUrl + ApiService.bannerImagesURL;
    print('bannerListURL ' + bannerListURL);
    await apiConnector.getAPICall(bannerListURL).then((response) {
      setState(() {
        bannerImagesResponse = BannerImagesResponse.fromJson(response);
        firstLoading = false;

        print('-----  ' + bannerImagesResponse.listResult.length.toString());
        for (int i = 0; i < bannerImagesResponse.listResult.length; i++) {
          // images.clear();
          images.add(bannerImagesResponse.listResult[i].filePath != null
              ? CachedNetworkImage(
                  imageUrl: bannerImagesResponse.listResult[i].filePath,
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
      });
    });
  }

  getCategoryTypeAPICall() async {
    String itemTypeURL = ApiService.baseUrl + ApiService.getItemTypeURL;
    print('itemTypeURL ' + itemTypeURL);
    await apiConnector.getAPICall(itemTypeURL).then((response) {
      setState(() {
        itemTypeResponse = ItemTypeResponse.fromJson(response);
        firstLoading = false;
        print('-----  ' + itemTypeResponse.listResult.length.toString());
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

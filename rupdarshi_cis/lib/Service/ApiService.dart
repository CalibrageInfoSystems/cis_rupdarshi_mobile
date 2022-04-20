import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:rupdarshi_cis/Model/AllItemsResponse.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rupdarshi_cis/Model/Requests/PlaceOerderRequest.dart';
import 'package:rupdarshi_cis/Model/Requests/PostCartRequest.dart';
import 'package:rupdarshi_cis/common/Constants.dart';

// const baseUrl = "http://183.82.111.111/Rupdarshi/API/api";
// http://183.82.111.111/Rupdarshi/API/api/Cart/GetCartByUserId/3

class ApiService {
  ProgressDialog progressHud;

  // static var filerepopath =
  //     'http://45.114.143.245/RupdarshiRepo/FileRepository/'; // CTlss

  // static var baseUrl = "http://45.114.143.245:9091/api/"; // CTlss

  static var filerepopath =
      'http://183.82.111.111/RupdarshiFileRepository/FileRepository/'; // Local

  static var baseUrl = "http://183.82.111.111/Rupdarshi/API/api/"; // Local

  // static var baseUrl = "http://183.82.111.111/RupdarshiUAT/API/api/"; // Client

  static var getAllCategoriesURL = "Category/GetParentCategoryAndSubCategory/";

  static var getCategoriesByIDs = "Item/GetItemsByCategoryIds"; // post
  static var getItemTypeURL = "ItemType/GetAllItemTypes/true";

  static var getCartURL = "Cart/GetCartByUserId/";
  static var postCartURL = "Cart/AddUpdateCart";
  static var addToWishlist = "WishList/AddToWishList"; // Post
  static var removeFromishList =
      "WishList/RemoveFromWishList"; // itemID, loginUserID  post
  static var getWishList = "WishList/GetAllWishListItemsByVendorId/";
  static var addToCartURL = "Cart/AddUpdateCart"; // post
  static var getPaymentTypeURL = "TypeCdDmt/GetTypeCdDmt?Id=4"; // get
  static var deleteCartURL = "Cart/DeleteCartByUserId/";
  static var statusTypesURL = "TypeCdDmt/GetTypeCdDmt?Id=5";
  static var getOrdersByStatusID = "Order/SearchOrders"; // post
  static var addUpdateAddress = "Order/AddUpdateVendorAddress";
  static var getorderDetails = "Order/GetItemsByOrderid/";
  static var updateOrderStatus = "Order/UpdateOrderItemStatus";
  static var trackOrderHistory = "Order/GetOrderHistory/";
  static var deleteAddress = 'Order/ActiveorInActiveAddress';

  static var logisticOperatorURL =
      "Lookup/GetAllLookUp?Id=null&typeid=19&IsActive=true";
  static var bannerImagesURL = "Banner/GetBannersByTypeId/23";
  static var shippingReceipt = "Order/GetShippingDetailsById/"; // get

  static var colorImagesURL = "Item/GetImageByItemId/";
  static var forgotPasswordURL = "User/ForgotVendorPassword/";
  static var changePasswordURL = "User/ChangeVendorPassword/";
  static var trackHitoryURL = "Order/GetOrderItemHistoryById/"; // itemID
  static var getPaymentModeURL = "PaymentMode/GetpaymentModes/";

  static var getColorsURL =
      "/Lookup/GetAllLookUp?Id=null&typeid=8&IsActive=true";

  void globalToast(String toastMessage) {
    Fluttertoast.showToast(
        msg: toastMessage,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Constants.toastBGColor,
        textColor: Colors.white);
  }

  Future<bool> isNetAvailable() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }
    return false;
  }

  // Service calls -------
  static Future getStates() {
    var url = baseUrl + "/State/GetAllStates";
    return http.get(url);
  }

  Future getProfile() async {
    bool isNetworkavailable = await isNetAvailable();
    if (isNetworkavailable) {
      var url = "http://183.82.111.111/Rupdarshi/API/api/User/GetVendorInfo";
      Map data = {
        "VendorId": 18,
        "ServiceTypeId": null,
        "StatusTypeId": null,
        "FromDate": null,
        "ToDate": null
      };
      return http.post(
        url,
        headers: null,
        body: data,
      );
    } else {
      Fluttertoast.showToast(
          msg: "Please check internet connection",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  Future<AllItemsResponse> getAllItems() async {
    AllItemsResponse items = new AllItemsResponse();
    Response res =
        await get("http://183.82.111.111/Rupdarshi/API/api/Item/GetAllItems");

    int statusCode = res.statusCode;
    String responseBody = res.body;

    if (statusCode == 200) {
      var itemsrespone = json.decode(responseBody);
      items = AllItemsResponse.fromJson(itemsrespone);
      print('------getAllItems----- Success : 200');
      print('------ getAllItems -------' + itemsrespone.toString());

      return items;
    } else {
      print('::: getAllItems :::: error : ');

      return null;
    }
  }

// Added by Naveen for Global api usage ::::::::::::

  Future<dynamic> getAPICall(String url) async {
    bool isNetworkavailable = await isNetAvailable();
    if (isNetworkavailable) {
      Response res = await get(url);

      int statusCode = res.statusCode;
      String responseBody = res.body;

      if (statusCode == 200) {
        var respone = json.decode(responseBody);

        print('----- Success : 200');
        print('----- respone  - > ' + respone.toString());

        return respone;
      } else {
        print(':::  :::: error : ');

        return null;
      }
    } else {
      Fluttertoast.showToast(
          msg: "Please check internet connection",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  Future<dynamic> postAPICall(
      String url, Map<String, dynamic> parameters) async {
    bool isNetworkavailable = await isNetAvailable();
    if (isNetworkavailable) {
      print("request URL - > " + url);
      print("request parameters - > " + parameters.toString());
      String body = json.encode(parameters);
      Response res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );
      int statusCode = res.statusCode;
      String responseBody = res.body;

      if (statusCode == 200) {
        var respone = json.decode(responseBody);

        print('----- Success : 200');
        print('------  ------- ' + respone.toString());

        return respone;
      } else {
        print(':::  :::: error : ');

        return null;
      }
    } else {
      Fluttertoast.showToast(
          msg: "Please check internet connection",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

// Added by Naveen for Global api usage ::::::::::::

  Future<dynamic> getCartApiCall(String url) async {
    bool isNetworkavailable = await isNetAvailable();
    if (isNetworkavailable) {
      Response res = await get(url);

      int statusCode = res.statusCode;
      String responseBody = res.body;

      if (statusCode == 200) {
        var respone = json.decode(responseBody);

        print('----- Success : 200');
        print('------  -------' + respone.toString());

        return respone;
      } else {
        print(':::  :::: error : ');

        return null;
      }
    } else {
      Fluttertoast.showToast(
          msg: "Please check internet connection",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  Future<dynamic> getAddressApiCall(String url) async {
    bool isNetworkavailable = await isNetAvailable();
    if (isNetworkavailable) {
      Response res = await get(url);

      int statusCode = res.statusCode;
      String responseBody = res.body;

      if (statusCode == 200) {
        var respone = json.decode(responseBody);

        print('----- Success : 200');
        print('------  -------' + respone.toString());

        return respone;
      } else {
        print(':::  :::: error : ');

        return null;
      }
    } else {
      Fluttertoast.showToast(
          msg: "Please check internet connection",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  Future<dynamic> orderDetailsApiCall(String url) async {
    bool isNetworkavailable = await isNetAvailable();
    if (isNetworkavailable) {
      Response res = await get(url);

      int statusCode = res.statusCode;
      String responseBody = res.body;

      if (statusCode == 200) {
        var respone = json.decode(responseBody);

        print('----- Success : 200');
        print('------  -------' + respone.toString());

        return respone;
      } else {
        print(':::  :::: error : ');

        return null;
      }
    } else {
      Fluttertoast.showToast(
          msg: "Please check internet connection",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  Future<dynamic> deleteCartApiCall(String url) async {
    bool isNetworkavailable = await isNetAvailable();

    if (isNetworkavailable) {
      Response res = await get(url);

      int statusCode = res.statusCode;
      String responseBody = res.body;

      if (statusCode == 200) {
        var respone = json.decode(responseBody);

        print('----- Success : 200');
        print('------  -------' + respone.toString());

        return respone;
      } else {
        print(':::  :::: error : ');

        return null;
      }
    } else {
      Fluttertoast.showToast(
          msg: "Please check internet connection",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  Future<dynamic> postCartUpdate(PostCartRequest cartinfo) async {
    bool isNetworkavailable = await isNetAvailable();
    if (isNetworkavailable) {
      final url = baseUrl + "Cart/AddUpdateCart";
      print(url);
      final headers = {'Content-Type': 'application/json'};

      String jsonBody = json.encode(cartinfo.toJson());
      final encoding = Encoding.getByName('utf-8');

      print('postCartUpdate :' + cartinfo.toJson().toString());
      Response response = await post(
        url,
        headers: headers,
        body: jsonBody,
        encoding: encoding,
      );

      int statusCode = response.statusCode;
      String responseBody = response.body;
      if (statusCode == 200) {
        var userresponce = json.decode(responseBody);

        print('::: postCartUpdate Response :::: ' + userresponce.toString());
        bool issucess = userresponce['IsSuccess'];
        print('::: postCartUpdate :::: Success : ' + issucess.toString());
        if (issucess) {
        } else {}
        return userresponce;
      } else {
        print('::: postCartUpdate Response :::: error : ');

        return null;
      }
    } else {
      Fluttertoast.showToast(
          msg: "Please check internet connection",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  Future<dynamic> placeOrder(PlaceOerderRequestModel placeOerderRequest) async {
    bool isNetworkavailable = await isNetAvailable();
    if (isNetworkavailable) {
      final uri = baseUrl + "Order/PlaceOrder";
      int _successcode = 200;
      final headers = {'Content-Type': 'application/json'};

      String jsonBody = json.encode(placeOerderRequest.toJson());
      final encoding = Encoding.getByName('utf-8');

      print(
          'PlaceOerderRequestModel :' + placeOerderRequest.toJson().toString());
      Response response = await post(
        uri,
        headers: headers,
        body: jsonBody,
        encoding: encoding,
      );

      int statusCode = response.statusCode;
      String responseBody = response.body;
      _successcode = statusCode;
      if (statusCode == 200) {
        var userresponce = json.decode(responseBody);

        print(':::  Response :::: ' + userresponce.toString());
        bool issucess = userresponce['IsSuccess'];
        print(':::  :::: Success : ' + issucess.toString());
        if (issucess) {
          _successcode = 200;
        } else {
          _successcode = 400;
        }
        return userresponce;
      } else {
        print(':::  Response :::: error : ');

        return null;
      }
    } else {
      Fluttertoast.showToast(
          msg: "Please check internet connection",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }
}

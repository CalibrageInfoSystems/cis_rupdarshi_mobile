// To parse this JSON data, do
//
//     final getCartResponse = getCartResponseFromJson(jsonString);

import 'dart:convert';

GetCartResponse getCartResponseFromJson(String str) =>
    GetCartResponse.fromJson(json.decode(str));

String getCartResponseToJson(GetCartResponse data) =>
    json.encode(data.toJson());

class GetCartResponse {
  GetCartResponse({
    this.result,
    this.isSuccess,
    this.affectedRecords,
    this.endUserMessage,
    this.validationErrors,
    this.exception,
  });

  Result result;
  bool isSuccess;
  int affectedRecords;
  String endUserMessage;
  List<dynamic> validationErrors;
  dynamic exception;

  factory GetCartResponse.fromJson(Map<String, dynamic> json) =>
      GetCartResponse(
        result: json["Result"] == null ? null : Result.fromJson(json["Result"]),
        isSuccess: json["IsSuccess"] == null ? null : json["IsSuccess"],
        affectedRecords:
            json["AffectedRecords"] == null ? null : json["AffectedRecords"],
        endUserMessage:
            json["EndUserMessage"] == null ? null : json["EndUserMessage"],
        validationErrors: json["ValidationErrors"] == null
            ? null
            : List<dynamic>.from(json["ValidationErrors"].map((x) => x)),
        exception: json["Exception"],
      );

  Map<String, dynamic> toJson() => {
        "Result": result == null ? null : result.toJson(),
        "IsSuccess": isSuccess == null ? null : isSuccess,
        "AffectedRecords": affectedRecords == null ? null : affectedRecords,
        "EndUserMessage": endUserMessage == null ? null : endUserMessage,
        "ValidationErrors": validationErrors == null
            ? null
            : List<dynamic>.from(validationErrors.map((x) => x)),
        "Exception": exception,
      };
}

class Result {
  Result({
    this.cart,
    this.productsList,
  });

  Cart cart;
  List<ProductsList> productsList;

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        cart: json["cart"] == null ? null : Cart.fromJson(json["cart"]),
        productsList: json["productsList"] == null
            ? null
            : List<ProductsList>.from(
                json["productsList"].map((x) => ProductsList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "cart": cart == null ? null : cart.toJson(),
        "productsList": productsList == null
            ? null
            : List<dynamic>.from(productsList.map((x) => x.toJson())),
      };
}

class Cart {
  Cart({
    this.id,
    this.userId,
    this.name,
    this.createdDate,
    this.updatedDate,
  });

  int id;
  int userId;
  String name;
  DateTime createdDate;
  DateTime updatedDate;

  factory Cart.fromJson(Map<String, dynamic> json) => Cart(
        id: json["Id"] == null ? null : json["Id"],
        userId: json["UserId"] == null ? null : json["UserId"],
        name: json["Name"] == null ? null : json["Name"],
        createdDate: json["CreatedDate"] == null
            ? null
            : DateTime.parse(json["CreatedDate"]),
        updatedDate: json["UpdatedDate"] == null
            ? null
            : DateTime.parse(json["UpdatedDate"]),
      );

  Map<String, dynamic> toJson() => {
        "Id": id == null ? null : id,
        "UserId": userId == null ? null : userId,
        "Name": name == null ? null : name,
        "CreatedDate":
            createdDate == null ? null : createdDate.toIso8601String(),
        "UpdatedDate":
            updatedDate == null ? null : updatedDate.toIso8601String(),
      };
}

class ProductsList {
  ProductsList({
    this.id,
    this.barCode,
    this.name,
    this.description,
    this.categoryId,
    this.fabricName,
    this.wholeSalePrice,
    this.retailPrice,
    this.discount,
    this.gst,
    this.remarks,
    this.isActive,
    this.createdByUserId,
    this.createdDate,
    this.updatedByUserId,
    this.updatedDate,
    this.itemType,
    this.categoryName,
    this.categorPrintName,
    this.itemTypename,
    this.discountPrince,
    this.isWishlist,
    this.quantity,
    this.colourids,
    this.colourNames,
    this.colourRemarks,
    this.sizeIds,
    this.sizeNames,
    this.sizeRemarks,
    this.serviceIds,
    this.serviceNames,
    this.filePath,
  });

  int id;
  String barCode;
  String name;
  String description;
  int categoryId;
  String fabricName;
  double wholeSalePrice;
  double retailPrice;
  double discount;
  double gst;
  String remarks;
  bool isActive;
  int createdByUserId;
  DateTime createdDate;
  int updatedByUserId;
  DateTime updatedDate;
  int itemType;
  String categoryName;
  String categorPrintName;
  String itemTypename;
  double discountPrince;
  bool isWishlist;
  int quantity;
  int colourids = 0;
  dynamic colourNames;
  dynamic colourRemarks;
  int sizeIds = 0;
  dynamic sizeNames;
  dynamic sizeRemarks;
  dynamic serviceIds;
  dynamic serviceNames;
  String filePath;

  factory ProductsList.fromJson(Map<String, dynamic> json) => ProductsList(
        id: json["Id"] == null ? null : json["Id"],
        barCode: json["BarCode"] == null ? null : json["BarCode"],
        name: json["Name"] == null ? null : json["Name"],
        description: json["Description"] == null ? null : json["Description"],
        categoryId: json["CategoryId"] == null ? null : json["CategoryId"],
        fabricName: json["FabricName"] == null ? null : json["FabricName"],
        wholeSalePrice:
            json["WholeSalePrice"] == null ? null : json["WholeSalePrice"],
        retailPrice: json["RetailPrice"] == null ? null : json["RetailPrice"],
        discount: json["Discount"] == null ? null : json["Discount"],
        gst: json["GST"] == null ? null : json["GST"],
        remarks: json["Remarks"] == null ? null : json["Remarks"],
        isActive: json["IsActive"] == null ? null : json["IsActive"],
        createdByUserId:
            json["CreatedByUserId"] == null ? null : json["CreatedByUserId"],
        createdDate: json["CreatedDate"] == null
            ? null
            : DateTime.parse(json["CreatedDate"]),
        updatedByUserId:
            json["UpdatedByUserId"] == null ? null : json["UpdatedByUserId"],
        updatedDate: json["UpdatedDate"] == null
            ? null
            : DateTime.parse(json["UpdatedDate"]),
        itemType: json["ItemType"] == null ? null : json["ItemType"],
        categoryName:
            json["CategoryName"] == null ? null : json["CategoryName"],
        categorPrintName:
            json["CategorPrintName"] == null ? null : json["CategorPrintName"],
        itemTypename:
            json["ItemTypename"] == null ? null : json["ItemTypename"],
        discountPrince:
            json["DiscountPrince"] == null ? null : json["DiscountPrince"],
        isWishlist: json["IsWishlist"] == null ? null : json["IsWishlist"],
        quantity: json["Quantity"] == null ? null : json["Quantity"],
        colourids: json["Colourids"],
        colourNames: json["colourNames"],
        colourRemarks: json["ColourRemarks"],
        sizeIds: json["SizeIds"],
        sizeNames: json["SizeNames"],
        sizeRemarks: json["SizeRemarks"],
        serviceIds: json["ServiceIds"],
        serviceNames: json["ServiceNames"],
        filePath: json["FilePath"] == null ? null : json["FilePath"],
      );

  Map<String, dynamic> toJson() => {
        "Id": id == null ? null : id,
        "BarCode": barCode == null ? null : barCode,
        "Name": name == null ? null : name,
        "Description": description == null ? null : description,
        "CategoryId": categoryId == null ? null : categoryId,
        "FabricName": fabricName == null ? null : fabricName,
        "WholeSalePrice": wholeSalePrice == null ? null : wholeSalePrice,
        "RetailPrice": retailPrice == null ? null : retailPrice,
        "Discount": discount == null ? null : discount,
        "GST": gst == null ? null : gst,
        "Remarks": remarks == null ? null : remarks,
        "IsActive": isActive == null ? null : isActive,
        "CreatedByUserId": createdByUserId == null ? null : createdByUserId,
        "CreatedDate":
            createdDate == null ? null : createdDate.toIso8601String(),
        "UpdatedByUserId": updatedByUserId == null ? null : updatedByUserId,
        "UpdatedDate":
            updatedDate == null ? null : updatedDate.toIso8601String(),
        "ItemType": itemType == null ? null : itemType,
        "CategoryName": categoryName == null ? null : categoryName,
        "CategorPrintName": categorPrintName == null ? null : categorPrintName,
        "ItemTypename": itemTypename == null ? null : itemTypename,
        "DiscountPrince": discountPrince == null ? null : discountPrince,
        "IsWishlist": isWishlist == null ? null : isWishlist,
        "Quantity": quantity == null ? null : quantity,
        "Colourids": colourids,
        "colourNames": colourNames,
        "ColourRemarks": colourRemarks,
        "SizeIds": sizeIds,
        "SizeNames": sizeNames,
        "SizeRemarks": sizeRemarks,
        "ServiceIds": serviceIds,
        "ServiceNames": serviceNames,
        "FilePath": filePath == null ? null : filePath,
      };
}

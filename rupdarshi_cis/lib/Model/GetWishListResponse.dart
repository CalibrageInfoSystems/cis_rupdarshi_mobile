// To parse this JSON data, do
//
//     final getWishListResponse = getWishListResponseFromJson(jsonString);

import 'dart:convert';

GetWishListResponse getWishListResponseFromJson(String str) =>
    GetWishListResponse.fromJson(json.decode(str));

String getWishListResponseToJson(GetWishListResponse data) =>
    json.encode(data.toJson());

class GetWishListResponse {
  GetWishListResponse({
    this.listResult,
    this.isSuccess,
    this.affectedRecords,
    this.endUserMessage,
    this.validationErrors,
    this.exception,
  });

  List<WishListResult> listResult;
  bool isSuccess;
  int affectedRecords;
  String endUserMessage;
  List<dynamic> validationErrors;
  dynamic exception;

  factory GetWishListResponse.fromJson(Map<String, dynamic> json) =>
      GetWishListResponse(
        listResult: json["ListResult"] == null
            ? null
            : List<WishListResult>.from(
                json["ListResult"].map((x) => WishListResult.fromJson(x))),
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
        "ListResult": listResult == null
            ? null
            : List<dynamic>.from(listResult.map((x) => x.toJson())),
        "IsSuccess": isSuccess == null ? null : isSuccess,
        "AffectedRecords": affectedRecords == null ? null : affectedRecords,
        "EndUserMessage": endUserMessage == null ? null : endUserMessage,
        "ValidationErrors": validationErrors == null
            ? null
            : List<dynamic>.from(validationErrors.map((x) => x)),
        "Exception": exception,
      };
}

class WishListResult {
  WishListResult({
    this.itemId,
    this.barCode,
    this.name,
    this.description,
    this.categoryId,
    this.categoryName,
    this.fabricName,
    this.wholeSalePrice,
    this.discountPrince,
    this.retailPrice,
    this.discount,
    this.gst,
    this.remarks,
    this.itemType,
    this.createdByUserId,
    this.createdDate,
    this.updatedByUserId,
    this.updatedDate,
    this.isWishlist,
    this.colorIds,
    this.colorNames,
    this.sizeIds,
    this.sizeNames,
    this.serviceIds,
    this.serviceNames,
    this.filePath,
  });

  int itemId;
  String barCode;
  String name;
  String description;
  int categoryId;
  String categoryName;
  String fabricName;
  double wholeSalePrice;
  double discountPrince;
  double retailPrice;
  double discount;
  double gst;
  String remarks;
  int itemType;
  int createdByUserId;
  DateTime createdDate;
  int updatedByUserId;
  DateTime updatedDate;
  bool isWishlist;
  dynamic colorIds;
  dynamic colorNames;
  dynamic sizeIds;
  dynamic sizeNames;
  String serviceIds;
  dynamic serviceNames;
  dynamic filePath;

  factory WishListResult.fromJson(Map<String, dynamic> json) => WishListResult(
        itemId: json["ItemId"] == null ? null : json["ItemId"],
        barCode: json["BarCode"] == null ? null : json["BarCode"],
        name: json["Name"] == null ? null : json["Name"],
        description: json["Description"] == null ? null : json["Description"],
        categoryId: json["CategoryId"] == null ? null : json["CategoryId"],
        categoryName:
            json["CategoryName"] == null ? null : json["CategoryName"],
        fabricName: json["FabricName"] == null ? null : json["FabricName"],
        wholeSalePrice:
            json["WholeSalePrice"] == null ? null : json["WholeSalePrice"],
        discountPrince:
            json["DiscountPrince"] == null ? null : json["DiscountPrince"],
        retailPrice: json["RetailPrice"] == null ? null : json["RetailPrice"],
        discount: json["Discount"] == null ? null : json["Discount"],
        gst: json["GST"] == null ? null : json["GST"],
        remarks: json["Remarks"] == null ? null : json["Remarks"],
        itemType: json["ItemType"] == null ? null : json["ItemType"],
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
        isWishlist: json["IsWishlist"] == null ? null : json["IsWishlist"],
        colorIds: json["ColorIds"],
        colorNames: json["ColorNames"],
        sizeIds: json["SizeIds"],
        sizeNames: json["SizeNames"],
        serviceIds: json["ServiceIds"] == null ? null : json["ServiceIds"],
        serviceNames: json["ServiceNames"],
        filePath: json["FilePath"],
      );

  Map<String, dynamic> toJson() => {
        "ItemId": itemId == null ? null : itemId,
        "BarCode": barCode == null ? null : barCode,
        "Name": name == null ? null : name,
        "Description": description == null ? null : description,
        "CategoryId": categoryId == null ? null : categoryId,
        "CategoryName": categoryName == null ? null : categoryName,
        "FabricName": fabricName == null ? null : fabricName,
        "WholeSalePrice": wholeSalePrice == null ? null : wholeSalePrice,
        "DiscountPrince": discountPrince == null ? null : discountPrince,
        "RetailPrice": retailPrice == null ? null : retailPrice,
        "Discount": discount == null ? null : discount,
        "GST": gst == null ? null : gst,
        "Remarks": remarks == null ? null : remarks,
        "ItemType": itemType == null ? null : itemType,
        "CreatedByUserId": createdByUserId == null ? null : createdByUserId,
        "CreatedDate":
            createdDate == null ? null : createdDate.toIso8601String(),
        "UpdatedByUserId": updatedByUserId == null ? null : updatedByUserId,
        "UpdatedDate":
            updatedDate == null ? null : updatedDate.toIso8601String(),
        "IsWishlist": isWishlist == null ? null : isWishlist,
        "ColorIds": colorIds,
        "ColorNames": colorNames,
        "SizeIds": sizeIds,
        "SizeNames": sizeNames,
        "ServiceIds": serviceIds == null ? null : serviceIds,
        "ServiceNames": serviceNames,
        "FilePath": filePath,
      };
}

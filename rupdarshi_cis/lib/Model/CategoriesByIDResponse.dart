// To parse this JSON data, do
//
//     final categoriesByIdResponse = categoriesByIdResponseFromJson(jsonString);

import 'dart:convert';

import 'package:flutter/cupertino.dart';

CategoriesByIdResponse categoriesByIdResponseFromJson(String str) =>
    CategoriesByIdResponse.fromJson(json.decode(str));

String categoriesByIdResponseToJson(CategoriesByIdResponse data) =>
    json.encode(data.toJson());

class CategoriesByIdResponse {
  CategoriesByIdResponse({
    this.listResult,
    this.isSuccess,
    this.affectedRecords,
    this.endUserMessage,
    this.validationErrors,
    this.exception,
  });

  List<CategoriesByIDListResult> listResult;
  bool isSuccess;
  int affectedRecords;
  String endUserMessage;
  List<dynamic> validationErrors;
  dynamic exception;

  factory CategoriesByIdResponse.fromJson(Map<String, dynamic> json) =>
      CategoriesByIdResponse(
        listResult: json["ListResult"] == null
            ? null
            : List<CategoriesByIDListResult>.from(json["ListResult"]
                .map((x) => CategoriesByIDListResult.fromJson(x))),
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

class CategoriesByIDListResult {
  CategoriesByIDListResult({
    this.maxRows,
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
    this.itemCount,
    this.itemTypename,
    this.sareesImages,
    this.colorNamesAry,
    this.colorIDSAry,
    this.sizeNamesAry,
    this.colorImagesURLAry,
    this.colorSelected,
    this.colorselection,
    this.selectedColor,
  });

  int maxRows;
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
  String colorIds;
  String colorNames;
  String sizeIds;
  String sizeNames;
  String serviceIds;
  dynamic serviceNames;
  String filePath;
  int itemCount = 0;
  String itemTypename;
  dynamic sareesImages = [];
  List<String> colorNamesAry = [];
  List<String> colorIDSAry = [];
  List<String> sizeNamesAry = [];
  int selectedColor = -1;
  String selectedColorname;
  List<List<ColorImagesURLAry>> colorImagesURLAry;
  bool colorSelected = false;
  List<bool> colorselection = [];

  factory CategoriesByIDListResult.fromJson(Map<String, dynamic> json) =>
      CategoriesByIDListResult(
        maxRows: json["MaxRows"] == null ? null : json["MaxRows"],
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
        discountPrince: json["DiscountPrince"] == null
            ? null
            : json["DiscountPrince"].toDouble(),
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
        colorIds: json["ColorIds"] == null ? null : json["ColorIds"],
        colorNames: json["ColorNames"] == null ? null : json["ColorNames"],
        sizeIds: json["SizeIds"] == null ? null : json["SizeIds"],
        sizeNames: json["SizeNames"] == null ? null : json["SizeNames"],
        serviceIds: json["ServiceIds"] == null ? null : json["ServiceIds"],
        serviceNames: json["ServiceNames"],
        filePath: json["FilePath"] == null ? null : json["FilePath"],
        itemCount: json["ItemCount"] == null ? 0 : json["ItemCount"],
        itemTypename:
            json["ItemTypename"] == null ? null : json["ItemTypename"],
      );

  Map<String, dynamic> toJson() => {
        "MaxRows": maxRows == null ? null : maxRows,
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
        "ColorIds": colorIds == null ? null : colorIds,
        "ColorNames": colorNames == null ? null : colorNames,
        "SizeIds": sizeIds == null ? null : sizeIds,
        "SizeNames": sizeNames == null ? null : sizeNames,
        "ServiceIds": serviceIds == null ? null : serviceIds,
        "ServiceNames": serviceNames,
        "FilePath": filePath == null ? null : filePath,
        "ItemCount": itemCount == null ? 0 : itemCount,
        "ItemTypename": itemTypename == null ? null : itemTypename,
      };
}

class ColorImagesURLAry {
  ColorImagesURLAry({
    this.id,
    this.colourId,
    this.colourName,
    this.fileName,
    this.fileLocation,
    this.fileExtension,
    this.createdByUserId,
    this.createdByUserName,
    this.createdDate,
    this.isDefault,
    this.thumbName,
  });

  int id;
  int colourId;
  String colourName;
  String fileName;
  String fileLocation = "";
  String fileExtension;
  int createdByUserId;
  String createdByUserName;
  DateTime createdDate;
  bool isDefault;
  String thumbName;

  factory ColorImagesURLAry.fromJson(Map<String, dynamic> json) =>
      ColorImagesURLAry(
        id: json["Id"] == null ? null : json["Id"],
        colourId: json["ColourId"] == null ? null : json["ColourId"],
        colourName: json["ColourName"] == null ? null : json["ColourName"],
        fileName: json["FileName"] == null ? null : json["FileName"],
        fileLocation:
            json["FileLocation"] == null ? null : json["FileLocation"],
        fileExtension:
            json["FileExtension"] == null ? null : json["FileExtension"],
        createdByUserId:
            json["CreatedByUserId"] == null ? null : json["CreatedByUserId"],
        createdByUserName: json["CreatedByUserName"] == null
            ? null
            : json["CreatedByUserName"],
        createdDate: json["createdDate"] == null
            ? null
            : DateTime.parse(json["createdDate"]),
        isDefault: json["isDefault"] == null ? null : json["isDefault"],
        thumbName: json["ThumbName"] == null ? null : json["ThumbName"],
      );

  Map<String, dynamic> toJson() => {
        "Id": id == null ? null : id,
        "ColourId": colourId == null ? null : colourId,
        "ColourName": colourName == null ? null : colourName,
        "FileName": fileName == null ? null : fileName,
        "FileLocation": fileLocation == null ? null : fileLocation,
        "FileExtension": fileExtension == null ? null : fileExtension,
        "CreatedByUserId": createdByUserId == null ? null : createdByUserId,
        "CreatedByUserName":
            createdByUserName == null ? null : createdByUserName,
        "createdDate":
            createdDate == null ? null : createdDate.toIso8601String(),
        "isDefault": isDefault == null ? null : isDefault,
        "ThumbName": thumbName == null ? null : thumbName,
      };
}

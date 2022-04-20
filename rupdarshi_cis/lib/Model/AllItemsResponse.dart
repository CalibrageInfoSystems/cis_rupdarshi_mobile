// To parse this JSON data, do
//
//     final allItemsResponse = allItemsResponseFromJson(jsonString);

import 'dart:convert';

AllItemsResponse allItemsResponseFromJson(String str) =>
    AllItemsResponse.fromJson(json.decode(str));

String allItemsResponseToJson(AllItemsResponse data) =>
    json.encode(data.toJson());

class AllItemsResponse {
  AllItemsResponse({
    this.listResult,
    this.isSuccess,
    this.affectedRecords,
    this.endUserMessage,
    this.validationErrors,
    this.exception,
  });

  List<ListResult> listResult;
  bool isSuccess;
  int affectedRecords;
  String endUserMessage;
  List<dynamic> validationErrors;
  dynamic exception;

  factory AllItemsResponse.fromJson(Map<String, dynamic> json) =>
      AllItemsResponse(
        listResult: json["ListResult"] == null
            ? null
            : List<ListResult>.from(
                json["ListResult"].map((x) => ListResult.fromJson(x))),
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

class ListResult {
  ListResult({
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
    this.itemTypename,
    this.categoryName,
    this.categorPrintName,
    this.fileName,
    this.fileExtension,
    this.fileLocation,
    this.filepath,
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
  String itemTypename;
  String categoryName;
  String categorPrintName;
  String fileName;
  String fileExtension;
  String fileLocation;
  String filepath;

  factory ListResult.fromJson(Map<String, dynamic> json) => ListResult(
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
        itemTypename:
            json["ItemTypename"] == null ? null : json["ItemTypename"],
        categoryName:
            json["CategoryName"] == null ? null : json["CategoryName"],
        categorPrintName:
            json["CategorPrintName"] == null ? null : json["CategorPrintName"],
        fileName: json["FileName"] == null ? null : json["FileName"],
        fileExtension:
            json["FileExtension"] == null ? null : json["FileExtension"],
        fileLocation:
            json["FileLocation"] == null ? null : json["FileLocation"],
        filepath: json["Filepath"] == null ? null : json["Filepath"],
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
        "ItemTypename": itemTypename == null ? null : itemTypename,
        "CategoryName": categoryName == null ? null : categoryName,
        "CategorPrintName": categorPrintName == null ? null : categorPrintName,
        "FileName": fileName == null ? null : fileName,
        "FileExtension": fileExtension == null ? null : fileExtension,
        "FileLocation": fileLocation == null ? null : fileLocation,
        "Filepath": filepath == null ? null : filepath,
      };
}

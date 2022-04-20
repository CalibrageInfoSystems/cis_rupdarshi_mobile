// To parse this JSON data, do
//
//     final itemDetailsResponse = itemDetailsResponseFromJson(jsonString);

import 'dart:convert';

ItemDetailsResponse itemDetailsResponseFromJson(String str) =>
    ItemDetailsResponse.fromJson(json.decode(str));

String itemDetailsResponseToJson(ItemDetailsResponse data) =>
    json.encode(data.toJson());

class ItemDetailsResponse {
  ItemDetailsResponse({
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
  dynamic validationErrors;
  Exception exception;

  factory ItemDetailsResponse.fromJson(Map<String, dynamic> json) =>
      ItemDetailsResponse(
        result: json["Result"] == null ? null : Result.fromJson(json["Result"]),
        isSuccess: json["IsSuccess"] == null ? null : json["IsSuccess"],
        affectedRecords:
            json["AffectedRecords"] == null ? null : json["AffectedRecords"],
        endUserMessage:
            json["EndUserMessage"] == null ? null : json["EndUserMessage"],
        validationErrors: json["ValidationErrors"],
        exception: json["Exception"] == null
            ? null
            : Exception.fromJson(json["Exception"]),
      );

  Map<String, dynamic> toJson() => {
        "Result": result == null ? null : result.toJson(),
        "IsSuccess": isSuccess == null ? null : isSuccess,
        "AffectedRecords": affectedRecords == null ? null : affectedRecords,
        "EndUserMessage": endUserMessage == null ? null : endUserMessage,
        "ValidationErrors": validationErrors,
        "Exception": exception == null ? null : exception.toJson(),
      };
}

class Exception {
  Exception({
    this.className,
    this.message,
    this.data,
    this.innerException,
    this.helpUrl,
    this.stackTraceString,
    this.remoteStackTraceString,
    this.remoteStackIndex,
    this.exceptionMethod,
    this.hResult,
    this.source,
    this.watsonBuckets,
  });

  String className;
  dynamic message;
  dynamic data;
  dynamic innerException;
  String helpUrl;
  dynamic stackTraceString;
  dynamic remoteStackTraceString;
  int remoteStackIndex;
  dynamic exceptionMethod;
  int hResult;
  String source;
  dynamic watsonBuckets;

  factory Exception.fromJson(Map<String, dynamic> json) => Exception(
        className: json["ClassName"] == null ? null : json["ClassName"],
        message: json["Message"],
        data: json["Data"],
        innerException: json["InnerException"],
        helpUrl: json["HelpURL"] == null ? null : json["HelpURL"],
        stackTraceString: json["StackTraceString"],
        remoteStackTraceString: json["RemoteStackTraceString"],
        remoteStackIndex:
            json["RemoteStackIndex"] == null ? null : json["RemoteStackIndex"],
        exceptionMethod: json["ExceptionMethod"],
        hResult: json["HResult"] == null ? null : json["HResult"],
        source: json["Source"] == null ? null : json["Source"],
        watsonBuckets: json["WatsonBuckets"],
      );

  Map<String, dynamic> toJson() => {
        "ClassName": className == null ? null : className,
        "Message": message,
        "Data": data,
        "InnerException": innerException,
        "HelpURL": helpUrl == null ? null : helpUrl,
        "StackTraceString": stackTraceString,
        "RemoteStackTraceString": remoteStackTraceString,
        "RemoteStackIndex": remoteStackIndex == null ? null : remoteStackIndex,
        "ExceptionMethod": exceptionMethod,
        "HResult": hResult == null ? null : hResult,
        "Source": source == null ? null : source,
        "WatsonBuckets": watsonBuckets,
      };
}

class Result {
  Result({
    this.itemDetails,
    this.itemColours,
    this.itemServices,
    this.itemSizes,
    this.itemFileRepositories,
  });

  ItemDetails itemDetails;
  List<Item> itemColours;
  List<ItemService> itemServices;
  List<Item> itemSizes;
  List<ItemFileRepository> itemFileRepositories;

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        itemDetails: json["ItemDetails"] == null
            ? null
            : ItemDetails.fromJson(json["ItemDetails"]),
        itemColours: json["ItemColours"] == null
            ? null
            : List<Item>.from(json["ItemColours"].map((x) => Item.fromJson(x))),
        itemServices: json["ItemServices"] == null
            ? null
            : List<ItemService>.from(
                json["ItemServices"].map((x) => ItemService.fromJson(x))),
        itemSizes: json["ItemSizes"] == null
            ? null
            : List<Item>.from(json["ItemSizes"].map((x) => Item.fromJson(x))),
        itemFileRepositories: json["ItemFileRepositories"] == null
            ? null
            : List<ItemFileRepository>.from(json["ItemFileRepositories"]
                .map((x) => ItemFileRepository.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "ItemDetails": itemDetails == null ? null : itemDetails.toJson(),
        "ItemColours": itemColours == null
            ? null
            : List<dynamic>.from(itemColours.map((x) => x.toJson())),
        "ItemServices": itemServices == null
            ? null
            : List<dynamic>.from(itemServices.map((x) => x.toJson())),
        "ItemSizes": itemSizes == null
            ? null
            : List<dynamic>.from(itemSizes.map((x) => x.toJson())),
        "ItemFileRepositories": itemFileRepositories == null
            ? null
            : List<dynamic>.from(itemFileRepositories.map((x) => x.toJson())),
      };
}

class Item {
  Item({this.id, this.name, this.remarks, this.isSelectedColor});

  int id;
  String name;
  String remarks;
  bool isSelectedColor = false;

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        id: json["Id"] == null ? null : json["Id"],
        name: json["Name"] == null ? null : json["Name"],
        remarks: json["Remarks"] == null ? null : json["Remarks"],
        isSelectedColor:
            json["IsSelectedColor"] == null ? null : json["IsSelectedColor"],
      );

  Map<String, dynamic> toJson() => {
        "Id": id == null ? null : id,
        "Name": name == null ? null : name,
        "Remarks": remarks == null ? null : remarks,
        "IsSelectedColor": isSelectedColor == null ? null : isSelectedColor,
      };
}

class ItemDetails {
  ItemDetails({
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
    this.active,
    this.parentcategoryId,
    this.parentcategoryName,
    this.parentcategoryPrintName,    
    this.discountPrince,
    this.colourids,
    this.colourNames,
    this.colourRemarks,
    this.sizeIds,
    this.sizeNames,
    this.sizeRemarks,
    this.serviceIds,
    this.serviceNames,
    this.filePath,
    this.thumbpath,
    this.isWishlist,
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
  String active;
  int parentcategoryId;
  String parentcategoryName;
  String parentcategoryPrintName;
  double discountPrince;
  String colourids;
  String colourNames;
  String colourRemarks;
  String sizeIds;
  String sizeNames;
  String sizeRemarks;
  String serviceIds;
  String serviceNames;
  String filePath;
  String thumbpath;
  bool isWishlist;

  factory ItemDetails.fromJson(Map<String, dynamic> json) => ItemDetails(
        id: json["Id"] == null ? null : json["Id"],
        barCode: json["BarCode"] == null ? null : json["BarCode"],
        name: json["Name"] == null ? null : json["Name"],
        description: json["Description"] == null ? null : json["Description"],
        categoryId: json["CategoryId"] == null ? null : json["CategoryId"],
        fabricName: json["FabricName"] == null ? null : json["FabricName"],
        wholeSalePrice: json["WholeSalePrice"] == null
            ? null
            : json["WholeSalePrice"].toDouble(),
        retailPrice:
            json["RetailPrice"] == null ? null : json["RetailPrice"].toDouble(),
        discount: json["Discount"] == null ? null : json["Discount"].toDouble(),
        gst: json["GST"] == null ? null : json["GST"].toDouble(),
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
         active:
            json["Active"] == null ? null : json["Active"],
         parentcategoryId:
            json["ParentcategoryId"] == null ? null : json["ParentcategoryId"],
         parentcategoryName:
            json["ParentcategoryName"] == null ? null : json["ParentcategoryName"],
         parentcategoryPrintName:
            json["ParentcategoryPrintName"] == null ? null : json["ParentcategoryPrintName"],
        discountPrince: json["DiscountPrince"] == null
            ? null
            : json["DiscountPrince"].toDouble(),
        colourids: json["Colourids"] == null ? null : json["Colourids"],
        colourNames: json["colourNames"] == null ? null : json["colourNames"],
        colourRemarks:
            json["ColourRemarks"] == null ? null : json["ColourRemarks"],
        sizeIds: json["SizeIds"] == null ? null : json["SizeIds"],
        sizeNames: json["SizeNames"] == null ? null : json["SizeNames"],
        sizeRemarks: json["SizeRemarks"] == null ? null : json["SizeRemarks"],
        serviceIds: json["ServiceIds"] == null ? null : json["ServiceIds"],
        serviceNames:
            json["ServiceNames"] == null ? null : json["ServiceNames"],
        filePath: json["FilePath"] == null ? null : json["FilePath"],
        thumbpath: json["Thumbpath"] == null ? null : json["Thumbpath"],
        isWishlist: json["IsWishlist"] == null ? null : json["IsWishlist"],
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
        "Active": active == null ? null : active,
        "ParentcategoryId": parentcategoryId == null ? null : parentcategoryId,
        "ParentcategoryName": parentcategoryName == null ? null : parentcategoryName,
        "ParentcategoryPrintName": parentcategoryPrintName == null ? null : parentcategoryPrintName,
        "DiscountPrince": discountPrince == null ? null : discountPrince,
        "Colourids": colourids == null ? null : colourids,
        "colourNames": colourNames == null ? null : colourNames,
        "ColourRemarks": colourRemarks == null ? null : colourRemarks,
        "SizeIds": sizeIds == null ? null : sizeIds,
        "SizeNames": sizeNames == null ? null : sizeNames,
        "SizeRemarks": sizeRemarks == null ? null : sizeRemarks,
        "ServiceIds": serviceIds == null ? null : serviceIds,
        "ServiceNames": serviceNames == null ? null : serviceNames,
        "FilePath": filePath == null ? null : filePath,
        "Thumbpath": thumbpath == null ? null : thumbpath,
        "IsWishlist": isWishlist == null ? null : isWishlist,
      };
}

class ItemFileRepository {
  ItemFileRepository({
    this.id,
    this.itemId,
    this.colourId,
    this.fileName,
    this.fileLocation,
    this.fileExtension,
    this.createdByUserId,
    this.createdDate,
    this.isDefault,
    this.thumbName,
  });

  int id;
  int itemId;
  int colourId;
  String fileName;
  String fileLocation;
  String fileExtension;
  int createdByUserId;
  DateTime createdDate;
  bool isDefault;
  String thumbName;

  factory ItemFileRepository.fromJson(Map<String, dynamic> json) =>
      ItemFileRepository(
        id: json["Id"] == null ? null : json["Id"],
        itemId: json["ItemId"] == null ? null : json["ItemId"],
        colourId: json["ColourId"] == null ? null : json["ColourId"],
        fileName: json["FileName"] == null ? null : json["FileName"],
        fileLocation:
            json["FileLocation"] == null ? null : json["FileLocation"],
        fileExtension:
            json["FileExtension"] == null ? null : json["FileExtension"],
        createdByUserId:
            json["CreatedByUserId"] == null ? null : json["CreatedByUserId"],
        createdDate: json["CreatedDate"] == null
            ? null
            : DateTime.parse(json["CreatedDate"]),
        isDefault: json["IsDefault"] == null ? null : json["IsDefault"],
        thumbName: json["ThumbName"] == null ? null : json["ThumbName"],
      );

  Map<String, dynamic> toJson() => {
        "Id": id == null ? null : id,
        "ItemId": itemId == null ? null : itemId,
        "ColourId": colourId == null ? null : colourId,
        "FileName": fileName == null ? null : fileName,
        "FileLocation": fileLocation == null ? null : fileLocation,
        "FileExtension": fileExtension == null ? null : fileExtension,
        "CreatedByUserId": createdByUserId == null ? null : createdByUserId,
        "CreatedDate":
            createdDate == null ? null : createdDate.toIso8601String(),
        "IsDefault": isDefault == null ? null : isDefault,
        "ThumbName": thumbName == null ? null : thumbName,
      };
}

class ItemService {
  ItemService({
    this.typeCdId,
    this.desc,
  });

  int typeCdId;
  String desc;

  factory ItemService.fromJson(Map<String, dynamic> json) => ItemService(
        typeCdId: json["TypeCdId"] == null ? null : json["TypeCdId"],
        desc: json["Desc"] == null ? null : json["Desc"],
      );

  Map<String, dynamic> toJson() => {
        "TypeCdId": typeCdId == null ? null : typeCdId,
        "Desc": desc == null ? null : desc,
      };
}

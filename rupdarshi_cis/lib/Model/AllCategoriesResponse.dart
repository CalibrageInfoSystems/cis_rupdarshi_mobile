// To parse this JSON data, do
//
//     final allCategoriesResponse = allCategoriesResponseFromJson(jsonString);

import 'dart:convert';

AllCategoriesResponse allCategoriesResponseFromJson(String str) =>
    AllCategoriesResponse.fromJson(json.decode(str));

String allCategoriesResponseToJson(AllCategoriesResponse data) =>
    json.encode(data.toJson());

class AllCategoriesResponse {
  AllCategoriesResponse({
    this.listResult,
    this.isSuccess,
    this.affectedRecords,
    this.endUserMessage,
    this.validationErrors,
    this.exception,
  });

  List<CategoryListResult> listResult;
  bool isSuccess;
  int affectedRecords;
  String endUserMessage;
  List<dynamic> validationErrors;
  dynamic exception;

  factory AllCategoriesResponse.fromJson(Map<String, dynamic> json) =>
      AllCategoriesResponse(
        listResult: json["ListResult"] == null
            ? null
            : List<CategoryListResult>.from(
                json["ListResult"].map((x) => CategoryListResult.fromJson(x))),
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

class CategoryListResult {
  CategoryListResult({
    this.category,
    this.subCategory,
  });

  Category category;
  List<Category> subCategory;

  factory CategoryListResult.fromJson(Map<String, dynamic> json) =>
      CategoryListResult(
        category: json["Category"] == null
            ? null
            : Category.fromJson(json["Category"]),
        subCategory: json["SubCategory"] == null
            ? null
            : List<Category>.from(
                json["SubCategory"].map((x) => Category.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "Category": category == null ? null : category.toJson(),
        "SubCategory": subCategory == null
            ? null
            : List<dynamic>.from(subCategory.map((x) => x.toJson())),
      };
}

class Category {
  Category({
    this.id,
    this.name,
    this.printName,
    this.description,
    this.parentCategoryId,
    this.parentCategoryName,
    this.parentCategoryPrintName,
    this.fileName,
    this.fileExtention,
    this.fileLocation,
    this.filepath,
    this.isActive,
    this.active,
    this.createdByUserId,
    this.createdDate,
    this.updatedByUserId,
    this.updatedDate,
    this.subCatCount,
    this.isSelected,
  });

  int id;
  String name;
  String printName;
  String description;
  int parentCategoryId;
  String parentCategoryName;
  String parentCategoryPrintName;
  String fileName;
  FileExtention fileExtention;
  String fileLocation;
  String filepath;
  bool isActive;
  String active;
  int createdByUserId;
  DateTime createdDate;
  int updatedByUserId;
  DateTime updatedDate;
  int subCatCount = 4;
  bool isSelected = false;

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json["Id"] == null ? null : json["Id"],
        name: json["Name"] == null ? null : json["Name"],
        printName: json["PrintName"] == null ? null : json["PrintName"],
        description: json["Description"] == null ? null : json["Description"],
        parentCategoryId:
            json["ParentCategoryId"] == null ? null : json["ParentCategoryId"],
        parentCategoryName: json["ParentCategoryName"] == null
            ? null
            : json["ParentCategoryName"],
        parentCategoryPrintName: json["ParentCategoryPrintName"] == null
            ? null
            : json["ParentCategoryPrintName"],
        fileName: json["FileName"] == null ? null : json["FileName"],
        fileExtention: json["FileExtention"] == null
            ? null
            : fileExtentionValues.map[json["FileExtention"]],
        fileLocation:
            json["FileLocation"] == null ? null : json["FileLocation"],
        filepath: json["Filepath"] == null ? null : json["Filepath"],
        isActive: json["IsActive"] == null ? null : json["IsActive"],
        active: json["Active"] == null ? null : json["Active"],
        createdByUserId:
            json["CreatedByUserId"] == null ? null : json["CreatedByUserId"],
        createdDate: json["CreatedDate"] == null
            ? null
            : DateTime.parse(json["CreatedDate"]),
        updatedByUserId:
            json["UpdatedByUserId"] == null ? null : json["UpdatedByUserId"],
        updatedDate: json["UpdatedDate"] == null
            ? null
            : DateTime.parse(
                json["UpdatedDate"],
              ),
        subCatCount: json["SubCatCount"] == null ? null : json["SubCatCount"],
        isSelected: json["isSelected"] == null ? null : json["isSelected"],
      );

  Map<String, dynamic> toJson() => {
        "Id": id == null ? null : id,
        "Name": name == null ? null : name,
        "PrintName": printName == null ? null : printName,
        "Description": description == null ? null : description,
        "ParentCategoryId": parentCategoryId == null ? null : parentCategoryId,
        "ParentCategoryName":
            parentCategoryName == null ? null : parentCategoryName,
        "ParentCategoryPrintName":
            parentCategoryPrintName == null ? null : parentCategoryPrintName,
        "FileName": fileName == null ? null : fileName,
        "FileExtention": fileExtention == null
            ? null
            : fileExtentionValues.reverse[fileExtention],
        "FileLocation": fileLocation == null ? null : fileLocation,
        "Filepath": filepath == null ? null : filepath,
        "IsActive": isActive == null ? null : isActive,
        "Active": active == null ? null : active,
        "CreatedByUserId": createdByUserId == null ? null : createdByUserId,
        "CreatedDate":
            createdDate == null ? null : createdDate.toIso8601String(),
        "UpdatedByUserId": updatedByUserId == null ? null : updatedByUserId,
        "UpdatedDate":
            updatedDate == null ? null : updatedDate.toIso8601String(),
        "SubCatCount": subCatCount == null ? null : subCatCount,
        "isSelected": isSelected == null ? null : isSelected,
      };
}

enum FileExtention { JPG }

final fileExtentionValues = EnumValues({".jpg": FileExtention.JPG});

class EnumValues<T> {
  Map<String, T> map;
  Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    if (reverseMap == null) {
      reverseMap = map.map((k, v) => new MapEntry(v, k));
    }
    return reverseMap;
  }
}

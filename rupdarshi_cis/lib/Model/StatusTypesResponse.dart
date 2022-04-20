// To parse this JSON data, do
//
//     final statusTypesResponse = statusTypesResponseFromJson(jsonString);

import 'dart:convert';

StatusTypesResponse statusTypesResponseFromJson(String str) =>
    StatusTypesResponse.fromJson(json.decode(str));

String statusTypesResponseToJson(StatusTypesResponse data) =>
    json.encode(data.toJson());

class StatusTypesResponse {
  StatusTypesResponse({
    this.listResult,
    this.isSuccess,
    this.affectedRecords,
    this.endUserMessage,
    this.validationErrors,
    this.exception,
  });

  List<StatusTypeListResult> listResult;
  bool isSuccess;
  int affectedRecords;
  String endUserMessage;
  List<dynamic> validationErrors;
  dynamic exception;

  factory StatusTypesResponse.fromJson(Map<String, dynamic> json) =>
      StatusTypesResponse(
        listResult: json["ListResult"] == null
            ? null
            : List<StatusTypeListResult>.from(json["ListResult"]
                .map((x) => StatusTypeListResult.fromJson(x))),
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

class StatusTypeListResult {
  StatusTypeListResult({
    this.typeCdId,
    this.classTypeId,
    this.name,
    this.desc,
    this.tableName,
    this.columnName,
    this.sortOrder,
    this.isActive,
    this.isSelected

  });

  int typeCdId;
  int classTypeId;
  String name;
  String desc;
  String tableName;
  String columnName;
  int sortOrder;
  bool isActive;
  bool isSelected = true;

  factory StatusTypeListResult.fromJson(Map<String, dynamic> json) =>
      StatusTypeListResult(
        typeCdId: json["TypeCdId"] == null ? null : json["TypeCdId"],
        classTypeId: json["ClassTypeId"] == null ? null : json["ClassTypeId"],
        name: json["NAME"] == null ? null : json["NAME"],
        desc: json["Desc"] == null ? null : json["Desc"],
        tableName: json["TableName"] == null ? null : json["TableName"],
        columnName: json["ColumnName"] == null ? null : json["ColumnName"],
        sortOrder: json["SortOrder"] == null ? null : json["SortOrder"],
        isActive: json["IsActive"] == null ? null : json["IsActive"],
        isSelected: json["IsSelected"] == null ? null : json["IsSelected"],
      );

  Map<String, dynamic> toJson() => {
        "TypeCdId": typeCdId == null ? null : typeCdId,
        "ClassTypeId": classTypeId == null ? null : classTypeId,
        "NAME": name == null ? null : name,
        "Desc": desc == null ? null : desc,
        "TableName": tableName == null ? null : tableName,
        "ColumnName": columnName == null ? null : columnName,
        "SortOrder": sortOrder == null ? null : sortOrder,
        "IsActive": isActive == null ? null : isActive,
        "IsSelected": isSelected == null ? null : isSelected,
      };
}

// To parse this JSON data, do
//
//     final logisticResponse = logisticResponseFromJson(jsonString);

import 'dart:convert';

LogisticResponse logisticResponseFromJson(String str) =>
    LogisticResponse.fromJson(json.decode(str));

String logisticResponseToJson(LogisticResponse data) =>
    json.encode(data.toJson());

class LogisticResponse {
  LogisticResponse({
    this.listResult,
    this.isSuccess,
    this.affectedRecords,
    this.endUserMessage,
    this.validationErrors,
    this.exception,
  });

  List<LogisticListResult> listResult;
  bool isSuccess;
  int affectedRecords;
  String endUserMessage;
  List<dynamic> validationErrors;
  dynamic exception;

  factory LogisticResponse.fromJson(Map<String, dynamic> json) =>
      LogisticResponse(
        listResult: json["ListResult"] == null
            ? null
            : List<LogisticListResult>.from(
                json["ListResult"].map((x) => LogisticListResult.fromJson(x))),
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

class LogisticListResult {
  LogisticListResult({
    this.id,
    this.lookUpTypeId,
    this.name,
    this.desc,
    this.remarks,
    this.isActive,
    this.createdByUserId,
    this.createdDate,
    this.updatedByUserId,
    this.updatedDate,
  });

  int id;
  int lookUpTypeId;
  String name;
  String desc;
  String remarks;
  bool isActive;
  int createdByUserId;
  DateTime createdDate;
  int updatedByUserId;
  DateTime updatedDate;

  factory LogisticListResult.fromJson(Map<String, dynamic> json) =>
      LogisticListResult(
        id: json["Id"] == null ? null : json["Id"],
        lookUpTypeId:
            json["LookUpTypeId"] == null ? null : json["LookUpTypeId"],
        name: json["NAME"] == null ? null : json["NAME"],
        desc: json["Desc"] == null ? null : json["Desc"],
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
      );

  Map<String, dynamic> toJson() => {
        "Id": id == null ? null : id,
        "LookUpTypeId": lookUpTypeId == null ? null : lookUpTypeId,
        "NAME": name == null ? null : name,
        "Desc": desc == null ? null : desc,
        "Remarks": remarks == null ? null : remarks,
        "IsActive": isActive == null ? null : isActive,
        "CreatedByUserId": createdByUserId == null ? null : createdByUserId,
        "CreatedDate":
            createdDate == null ? null : createdDate.toIso8601String(),
        "UpdatedByUserId": updatedByUserId == null ? null : updatedByUserId,
        "UpdatedDate":
            updatedDate == null ? null : updatedDate.toIso8601String(),
      };
}

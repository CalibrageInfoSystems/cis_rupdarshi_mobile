// To parse this JSON data, do
//
//     final colorsResponse = colorsResponseFromJson(jsonString);

import 'dart:convert';

ColorsResponse colorsResponseFromJson(String str) =>
    ColorsResponse.fromJson(json.decode(str));

String colorsResponseToJson(ColorsResponse data) => json.encode(data.toJson());

class ColorsResponse {
  ColorsResponse({
    this.listResult,
    this.isSuccess,
    this.affectedRecords,
    this.endUserMessage,
    this.validationErrors,
    this.exception,
  });

  List<ColorsListResult> listResult;
  bool isSuccess;
  int affectedRecords;
  String endUserMessage;
  List<dynamic> validationErrors;
  dynamic exception;

  factory ColorsResponse.fromJson(Map<String, dynamic> json) => ColorsResponse(
        listResult: json["ListResult"] == null
            ? null
            : List<ColorsListResult>.from(
                json["ListResult"].map((x) => ColorsListResult.fromJson(x))),
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

class ColorsListResult {
  ColorsListResult(
      {this.id,
      this.lookUpTypeId,
      this.name,
      this.desc,
      this.remarks,
      this.isActive,
      this.createdByUserId,
      this.createdDate,
      this.updatedByUserId,
      this.updatedDate,
      this.active,
      this.isSelectedColor});

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
  String active;
  bool isSelectedColor = false;

  factory ColorsListResult.fromJson(Map<String, dynamic> json) =>
      ColorsListResult(
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
        active: json["Active"] == null ? null : json["Active"],
        isSelectedColor:
            json["isSelectedColor"] == null ? null : json["isSelectedColor"],
      );

  Map<String, dynamic> toJson() => {
        "Id": id == null ? null : id,
        "LookUpTypeId": lookUpTypeId == null ? null : lookUpTypeId,
        "NAME": name == null ? null : name,
        "Desc": desc == null ? null : descValues.reverse[desc],
        "Remarks": remarks == null ? null : remarks,
        "IsActive": isActive == null ? null : isActive,
        "CreatedByUserId": createdByUserId == null ? null : createdByUserId,
        "CreatedDate":
            createdDate == null ? null : createdDate.toIso8601String(),
        "UpdatedByUserId": updatedByUserId == null ? null : updatedByUserId,
        "UpdatedDate":
            updatedDate == null ? null : updatedDate.toIso8601String(),
        "Active": active == null ? null : active,
        "isSelectedColor": isSelectedColor == null ? null : isSelectedColor,
      };
}

enum Active { YES }

final activeValues = EnumValues({"YES": Active.YES});

enum Desc { COLOUR }

final descValues = EnumValues({"Colour": Desc.COLOUR});

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

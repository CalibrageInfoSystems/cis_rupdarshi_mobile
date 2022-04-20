// To parse this JSON data, do
//
//     final itemTypeResponse = itemTypeResponseFromJson(jsonString);

import 'dart:convert';

ItemTypeResponse itemTypeResponseFromJson(String str) => ItemTypeResponse.fromJson(json.decode(str));

String itemTypeResponseToJson(ItemTypeResponse data) => json.encode(data.toJson());

class ItemTypeResponse {
    ItemTypeResponse({
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

    factory ItemTypeResponse.fromJson(Map<String, dynamic> json) => ItemTypeResponse(
        listResult: json["ListResult"] == null ? null : List<ListResult>.from(json["ListResult"].map((x) => ListResult.fromJson(x))),
        isSuccess: json["IsSuccess"] == null ? null : json["IsSuccess"],
        affectedRecords: json["AffectedRecords"] == null ? null : json["AffectedRecords"],
        endUserMessage: json["EndUserMessage"] == null ? null : json["EndUserMessage"],
        validationErrors: json["ValidationErrors"] == null ? null : List<dynamic>.from(json["ValidationErrors"].map((x) => x)),
        exception: json["Exception"],
    );

    Map<String, dynamic> toJson() => {
        "ListResult": listResult == null ? null : List<dynamic>.from(listResult.map((x) => x.toJson())),
        "IsSuccess": isSuccess == null ? null : isSuccess,
        "AffectedRecords": affectedRecords == null ? null : affectedRecords,
        "EndUserMessage": endUserMessage == null ? null : endUserMessage,
        "ValidationErrors": validationErrors == null ? null : List<dynamic>.from(validationErrors.map((x) => x)),
        "Exception": exception,
    };
}

class ListResult {
    ListResult({
        this.id,
        this.name,
        this.isActive,
        this.filepath,
        this.createdDate,
        this.updatedDate,
        this.createdByUsername,
        this.updateByUsername,
        this.isSeleted
    });

    int id;
    String name;
    bool isActive;
    String filepath;
    DateTime createdDate;
    DateTime updatedDate;
    String createdByUsername;
    String updateByUsername;
    bool isSeleted = false;

    factory ListResult.fromJson(Map<String, dynamic> json) => ListResult(
        id: json["Id"] == null ? null : json["Id"],
        name: json["Name"] == null ? null : json["Name"],
        isActive: json["isActive"] == null ? null : json["isActive"],
        filepath: json["Filepath"] == null ? null : json["Filepath"],
        createdDate: json["CreatedDate"] == null ? null : DateTime.parse(json["CreatedDate"]),
        updatedDate: json["UpdatedDate"] == null ? null : DateTime.parse(json["UpdatedDate"]),
        createdByUsername: json["CreatedByUsername"] == null ? null : json["CreatedByUsername"],
        updateByUsername: json["UpdateByUsername"] == null ? null : json["UpdateByUsername"],
         isSeleted: json["isSeleted"] == null ? null : json["isSeleted"],
    );

    Map<String, dynamic> toJson() => {
        "Id": id == null ? null : id,
        "Name": name == null ? null : name,
        "isActive": isActive == null ? null : isActive,
        "Filepath": filepath == null ? null : filepath,
        "CreatedDate": createdDate == null ? null : createdDate.toIso8601String(),
        "UpdatedDate": updatedDate == null ? null : updatedDate.toIso8601String(),
        "CreatedByUsername": createdByUsername == null ? null : createdByUsername,
        "UpdateByUsername": updateByUsername == null ? null : updateByUsername,
         "isSeleted": isSeleted == null ? null : isSeleted,
    };
}

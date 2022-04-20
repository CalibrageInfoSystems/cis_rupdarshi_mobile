// To parse this JSON data, do
//
//     final statesResModel = statesResModelFromJson(jsonString);

import 'dart:convert';

StatesResModel statesResModelFromJson(String str) => StatesResModel.fromJson(json.decode(str));

String statesResModelToJson(StatesResModel data) => json.encode(data.toJson());

class StatesResModel {
    StatesResModel({
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

    factory StatesResModel.fromJson(Map<String, dynamic> json) => StatesResModel(
        listResult: List<ListResult>.from(json["ListResult"].map((x) => ListResult.fromJson(x))),
        isSuccess: json["IsSuccess"],
        affectedRecords: json["AffectedRecords"],
        endUserMessage: json["EndUserMessage"],
        validationErrors: List<dynamic>.from(json["ValidationErrors"].map((x) => x)),
        exception: json["Exception"],
    );

    Map<String, dynamic> toJson() => {
        "ListResult": List<dynamic>.from(listResult.map((x) => x.toJson())),
        "IsSuccess": isSuccess,
        "AffectedRecords": affectedRecords,
        "EndUserMessage": endUserMessage,
        "ValidationErrors": List<dynamic>.from(validationErrors.map((x) => x)),
        "Exception": exception,
    };
}

class ListResult {
    ListResult({
        this.id,
        this.name,
    });

    int id;
    String name;

    factory ListResult.fromJson(Map<String, dynamic> json) => ListResult(
        id: json["Id"],
        name: json["Name"],
    );

    Map<String, dynamic> toJson() => {
        "Id": id,
        "Name": name,
    };
}

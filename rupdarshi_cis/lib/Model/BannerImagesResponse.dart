// To parse this JSON data, do
//
//     final bannerImagesResponse = bannerImagesResponseFromJson(jsonString);

import 'dart:convert';

BannerImagesResponse bannerImagesResponseFromJson(String str) => BannerImagesResponse.fromJson(json.decode(str));

String bannerImagesResponseToJson(BannerImagesResponse data) => json.encode(data.toJson());

class BannerImagesResponse {
    BannerImagesResponse({
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

    factory BannerImagesResponse.fromJson(Map<String, dynamic> json) => BannerImagesResponse(
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
        this.typeId,
        this.typeName,
        this.filePath,
    });

    int id;
    int typeId;
    String typeName;
    String filePath;

    factory ListResult.fromJson(Map<String, dynamic> json) => ListResult(
        id: json["Id"] == null ? null : json["Id"],
        typeId: json["TypeId"] == null ? null : json["TypeId"],
        typeName: json["TypeName"] == null ? null : json["TypeName"],
        filePath: json["FilePath"] == null ? null : json["FilePath"],
    );

    Map<String, dynamic> toJson() => {
        "Id": id == null ? null : id,
        "TypeId": typeId == null ? null : typeId,
        "TypeName": typeName == null ? null : typeName,
        "FilePath": filePath == null ? null : filePath,
    };
}

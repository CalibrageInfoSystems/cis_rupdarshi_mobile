// To parse this JSON data, do
//
//     final colorImagesResponse = colorImagesResponseFromJson(jsonString);

import 'dart:convert';

ColorImagesResponse colorImagesResponseFromJson(String str) =>
    ColorImagesResponse.fromJson(json.decode(str));

String colorImagesResponseToJson(ColorImagesResponse data) =>
    json.encode(data.toJson());

class ColorImagesResponse {
  ColorImagesResponse({
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

  factory ColorImagesResponse.fromJson(Map<String, dynamic> json) =>
      ColorImagesResponse(
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
  String fileLocation;
  String fileExtension;
  int createdByUserId;
  String createdByUserName;
  DateTime createdDate;
  bool isDefault;
  String thumbName;

  factory ListResult.fromJson(Map<String, dynamic> json) => ListResult(
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

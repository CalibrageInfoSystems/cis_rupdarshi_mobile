// To parse this JSON data, do
//
//     final trackHistoryResponse = trackHistoryResponseFromJson(jsonString);

import 'dart:convert';

TrackHistoryResponse trackHistoryResponseFromJson(String str) =>
    TrackHistoryResponse.fromJson(json.decode(str));

String trackHistoryResponseToJson(TrackHistoryResponse data) =>
    json.encode(data.toJson());

class TrackHistoryResponse {
  TrackHistoryResponse({
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
  List<dynamic> validationErrors;
  dynamic exception;

  factory TrackHistoryResponse.fromJson(Map<String, dynamic> json) =>
      TrackHistoryResponse(
        result: json["Result"] == null ? null : Result.fromJson(json["Result"]),
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
        "Result": result == null ? null : result.toJson(),
        "IsSuccess": isSuccess == null ? null : isSuccess,
        "AffectedRecords": affectedRecords == null ? null : affectedRecords,
        "EndUserMessage": endUserMessage == null ? null : endUserMessage,
        "ValidationErrors": validationErrors == null
            ? null
            : List<dynamic>.from(validationErrors.map((x) => x)),
        "Exception": exception,
      };
}

class Result {
  Result({
    this.confirmedDate,
    this.shippedDate,
    this.cancelledDate,
    this.delivedDate,
    this.statusTypeid,
  });

  DateTime confirmedDate;
  DateTime shippedDate;
  DateTime cancelledDate;
  DateTime delivedDate;
  int statusTypeid;

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        confirmedDate: json["ConfirmedDate"] == null
            ? null
            : DateTime.parse(json["ConfirmedDate"]),
        shippedDate: json["ShippedDate"] == null
            ? null
            : DateTime.parse(json["ShippedDate"]),
        cancelledDate: json["CancelledDate"] == null
            ? null
            : DateTime.parse(json["CancelledDate"]),
        delivedDate: json["DelivedDate"] == null
            ? null
            : DateTime.parse(json["DelivedDate"]),
        statusTypeid:
            json["StatusTypeid"] == null ? null : json["StatusTypeid"],
      );

  Map<String, dynamic> toJson() => {
        "ConfirmedDate":
            confirmedDate == null ? null : confirmedDate.toIso8601String(),
        "ShippedDate":
            shippedDate == null ? null : shippedDate.toIso8601String(),
        "CancelledDate":
            cancelledDate == null ? null : cancelledDate.toIso8601String(),
        "DelivedDate":
            delivedDate == null ? null : delivedDate.toIso8601String(),
        "StatusTypeid": statusTypeid == null ? null : statusTypeid,
      };
}

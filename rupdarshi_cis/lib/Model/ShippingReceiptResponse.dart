// To parse this JSON data, do
//
//     final shippingReceiptResponse = shippingReceiptResponseFromJson(jsonString);

import 'dart:convert';

ShippingReceiptResponse shippingReceiptResponseFromJson(String str) =>
    ShippingReceiptResponse.fromJson(json.decode(str));

String shippingReceiptResponseToJson(ShippingReceiptResponse data) =>
    json.encode(data.toJson());

class ShippingReceiptResponse {
  ShippingReceiptResponse({
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

  factory ShippingReceiptResponse.fromJson(Map<String, dynamic> json) =>
      ShippingReceiptResponse(
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
    this.id,
    this.orderId,
    this.referenceId,
    this.shippingDate,
    this.deliveryDate,
    this.logisticOparatorId,
    this.logisticOparatorName,
    this.filepath,
  });

  int id;
  int orderId;
  String referenceId;
  DateTime shippingDate;
  DateTime deliveryDate;
  int logisticOparatorId;
  String logisticOparatorName;
  String filepath;

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["Id"] == null ? null : json["Id"],
        orderId: json["OrderId"] == null ? null : json["OrderId"],
        referenceId: json["ReferenceId"] == null ? null : json["ReferenceId"],
        shippingDate: json["ShippingDate"] == null
            ? null
            : DateTime.parse(json["ShippingDate"]),
        deliveryDate: json["DeliveryDate"] == null
            ? null
            : DateTime.parse(json["DeliveryDate"]),
        logisticOparatorId: json["LogisticOparatorId"] == null
            ? null
            : json["LogisticOparatorId"],
        logisticOparatorName: json["LogisticOparatorName"] == null
            ? null
            : json["LogisticOparatorName"],
        filepath: json["Filepath"] == null ? null : json["Filepath"],
      );

  Map<String, dynamic> toJson() => {
        "Id": id == null ? null : id,
        "OrderId": orderId == null ? null : orderId,
        "ReferenceId": referenceId == null ? null : referenceId,
        "ShippingDate":
            shippingDate == null ? null : shippingDate.toIso8601String(),
        "DeliveryDate":
            deliveryDate == null ? null : deliveryDate.toIso8601String(),
        "LogisticOparatorId":
            logisticOparatorId == null ? null : logisticOparatorId,
        "LogisticOparatorName":
            logisticOparatorName == null ? null : logisticOparatorName,
        "Filepath": filepath == null ? null : filepath,
      };
}

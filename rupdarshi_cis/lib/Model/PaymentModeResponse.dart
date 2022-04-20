// To parse this JSON data, do
//
//     final paymentModeResponse = paymentModeResponseFromJson(jsonString);

import 'dart:convert';

PaymentModeResponse paymentModeResponseFromJson(String str) => PaymentModeResponse.fromJson(json.decode(str));

String paymentModeResponseToJson(PaymentModeResponse data) => json.encode(data.toJson());

class PaymentModeResponse {
    PaymentModeResponse({
        this.listResult,
        this.isSuccess,
        this.affectedRecords,
        this.endUserMessage,
        this.validationErrors,
        this.exception,
    });

    List<PaymentListResult> listResult;
    bool isSuccess;
    int affectedRecords;
    String endUserMessage;
    List<dynamic> validationErrors;
    dynamic exception;

    factory PaymentModeResponse.fromJson(Map<String, dynamic> json) => PaymentModeResponse(
        listResult: json["ListResult"] == null ? null : List<PaymentListResult>.from(json["ListResult"].map((x) => PaymentListResult.fromJson(x))),
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

class PaymentListResult {
    PaymentListResult({
        this.id,
        this.discount,
        this.name,
        this.isActive,
        this.createdByUserId,
        this.createdDate,
        this.createdUsername,
        this.updatedByUserId,
        this.updatedDate,
        this.updatedUsername,
    });

    int id;
    int discount;
    String name;
    bool isActive;
    int createdByUserId;
    DateTime createdDate;
    String createdUsername;
    int updatedByUserId;
    DateTime updatedDate;
    String updatedUsername;

    factory PaymentListResult.fromJson(Map<String, dynamic> json) => PaymentListResult(
        id: json["Id"] == null ? null : json["Id"],
        discount: json["Discount"] == null ? null : json["Discount"],
        name: json["Name"] == null ? null : json["Name"],
        isActive: json["IsActive"] == null ? null : json["IsActive"],
        createdByUserId: json["CreatedByUserId"] == null ? null : json["CreatedByUserId"],
        createdDate: json["CreatedDate"] == null ? null : DateTime.parse(json["CreatedDate"]),
        createdUsername: json["CreatedUsername"] == null ? null : json["CreatedUsername"],
        updatedByUserId: json["UpdatedByUserId"] == null ? null : json["UpdatedByUserId"],
        updatedDate: json["UpdatedDate"] == null ? null : DateTime.parse(json["UpdatedDate"]),
        updatedUsername: json["UpdatedUsername"] == null ? null : json["UpdatedUsername"],
    );

    Map<String, dynamic> toJson() => {
        "Id": id == null ? null : id,
        "Discount": discount == null ? null : discount,
        "Name": name == null ? null : name,
        "IsActive": isActive == null ? null : isActive,
        "CreatedByUserId": createdByUserId == null ? null : createdByUserId,
        "CreatedDate": createdDate == null ? null : createdDate.toIso8601String(),
        "CreatedUsername": createdUsername == null ? null : createdUsername,
        "UpdatedByUserId": updatedByUserId == null ? null : updatedByUserId,
        "UpdatedDate": updatedDate == null ? null : updatedDate.toIso8601String(),
        "UpdatedUsername": updatedUsername == null ? null : updatedUsername,
    };
}

// To parse this JSON data, do
//
//     final trackOrderResponse = trackOrderResponseFromJson(jsonString);

import 'dart:convert';

TrackOrderResponse trackOrderResponseFromJson(String str) => TrackOrderResponse.fromJson(json.decode(str));

String trackOrderResponseToJson(TrackOrderResponse data) => json.encode(data.toJson());

class TrackOrderResponse {
    TrackOrderResponse({
        this.listResult,
        this.isSuccess,
        this.affectedRecords,
        this.endUserMessage,
        this.validationErrors,
        this.exception,
    });

    List<TrackListResult> listResult;
    bool isSuccess;
    int affectedRecords;
    String endUserMessage;
    dynamic validationErrors;
    Exception exception;

    factory TrackOrderResponse.fromJson(Map<String, dynamic> json) => TrackOrderResponse(
        listResult: json["ListResult"] == null ? null : List<TrackListResult>.from(json["ListResult"].map((x) => TrackListResult.fromJson(x))),
        isSuccess: json["IsSuccess"] == null ? null : json["IsSuccess"],
        affectedRecords: json["AffectedRecords"] == null ? null : json["AffectedRecords"],
        endUserMessage: json["EndUserMessage"] == null ? null : json["EndUserMessage"],
        validationErrors: json["ValidationErrors"],
        exception: json["Exception"] == null ? null : Exception.fromJson(json["Exception"]),
    );

    Map<String, dynamic> toJson() => {
        "ListResult": listResult == null ? null : List<dynamic>.from(listResult.map((x) => x.toJson())),
        "IsSuccess": isSuccess == null ? null : isSuccess,
        "AffectedRecords": affectedRecords == null ? null : affectedRecords,
        "EndUserMessage": endUserMessage == null ? null : endUserMessage,
        "ValidationErrors": validationErrors,
        "Exception": exception == null ? null : exception.toJson(),
    };
}

class Exception {
    Exception({
        this.className,
        this.message,
        this.data,
        this.innerException,
        this.helpUrl,
        this.stackTraceString,
        this.remoteStackTraceString,
        this.remoteStackIndex,
        this.exceptionMethod,
        this.hResult,
        this.source,
        this.watsonBuckets,
    });

    String className;
    dynamic message;
    dynamic data;
    dynamic innerException;
    String helpUrl;
    dynamic stackTraceString;
    dynamic remoteStackTraceString;
    int remoteStackIndex;
    dynamic exceptionMethod;
    int hResult;
    String source;
    dynamic watsonBuckets;

    factory Exception.fromJson(Map<String, dynamic> json) => Exception(
        className: json["ClassName"] == null ? null : json["ClassName"],
        message: json["Message"],
        data: json["Data"],
        innerException: json["InnerException"],
        helpUrl: json["HelpURL"] == null ? null : json["HelpURL"],
        stackTraceString: json["StackTraceString"],
        remoteStackTraceString: json["RemoteStackTraceString"],
        remoteStackIndex: json["RemoteStackIndex"] == null ? null : json["RemoteStackIndex"],
        exceptionMethod: json["ExceptionMethod"],
        hResult: json["HResult"] == null ? null : json["HResult"],
        source: json["Source"] == null ? null : json["Source"],
        watsonBuckets: json["WatsonBuckets"],
    );

    Map<String, dynamic> toJson() => {
        "ClassName": className == null ? null : className,
        "Message": message,
        "Data": data,
        "InnerException": innerException,
        "HelpURL": helpUrl == null ? null : helpUrl,
        "StackTraceString": stackTraceString,
        "RemoteStackTraceString": remoteStackTraceString,
        "RemoteStackIndex": remoteStackIndex == null ? null : remoteStackIndex,
        "ExceptionMethod": exceptionMethod,
        "HResult": hResult == null ? null : hResult,
        "Source": source == null ? null : source,
        "WatsonBuckets": watsonBuckets,
    };
}

class TrackListResult {
    TrackListResult({
        this.id,
        this.orderId,
        this.statusTypeId,
        this.statusType,
        this.updatedDate,
        this.updatedUserName,
    });

    int id;
    int orderId;
    int statusTypeId;
    String statusType;
    DateTime updatedDate;
    String updatedUserName;

    factory TrackListResult.fromJson(Map<String, dynamic> json) => TrackListResult(
        id: json["Id"] == null ? null : json["Id"],
        orderId: json["OrderId"] == null ? null : json["OrderId"],
        statusTypeId: json["StatusTypeId"] == null ? null : json["StatusTypeId"],
        statusType: json["StatusType"] == null ? null : json["StatusType"],
        updatedDate: json["UpdatedDate"] == null ? null : DateTime.parse(json["UpdatedDate"]),
        updatedUserName: json["UpdatedUserName"] == null ? null : json["UpdatedUserName"],
    );

    Map<String, dynamic> toJson() => {
        "Id": id == null ? null : id,
        "OrderId": orderId == null ? null : orderId,
        "StatusTypeId": statusTypeId == null ? null : statusTypeId,
        "StatusType": statusType == null ? null : statusType,
        "UpdatedDate": updatedDate == null ? null : updatedDate.toIso8601String(),
        "UpdatedUserName": updatedUserName == null ? null : updatedUserName,
    };
}

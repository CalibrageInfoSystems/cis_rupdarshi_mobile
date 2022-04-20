// To parse this JSON data, do
//
//     final deleteCartResponse = deleteCartResponseFromJson(jsonString);

import 'dart:convert';

DeleteCartResponse deleteCartResponseFromJson(String str) => DeleteCartResponse.fromJson(json.decode(str));

String deleteCartResponseToJson(DeleteCartResponse data) => json.encode(data.toJson());

class DeleteCartResponse {
    DeleteCartResponse({
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
    dynamic validationErrors;
    Exception exception;

    factory DeleteCartResponse.fromJson(Map<String, dynamic> json) => DeleteCartResponse(
        result: json["Result"] == null ? null : Result.fromJson(json["Result"]),
        isSuccess: json["IsSuccess"] == null ? null : json["IsSuccess"],
        affectedRecords: json["AffectedRecords"] == null ? null : json["AffectedRecords"],
        endUserMessage: json["EndUserMessage"] == null ? null : json["EndUserMessage"],
        validationErrors: json["ValidationErrors"],
        exception: json["Exception"] == null ? null : Exception.fromJson(json["Exception"]),
    );

    Map<String, dynamic> toJson() => {
        "Result": result == null ? null : result.toJson(),
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

class Result {
    Result({
        this.id,
        this.userId,
        this.name,
        this.createdDate,
        this.updatedDate,
    });

    int id;
    int userId;
    String name;
    DateTime createdDate;
    DateTime updatedDate;

    factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["Id"] == null ? null : json["Id"],
        userId: json["UserId"] == null ? null : json["UserId"],
        name: json["Name"] == null ? null : json["Name"],
        createdDate: json["CreatedDate"] == null ? null : DateTime.parse(json["CreatedDate"]),
        updatedDate: json["UpdatedDate"] == null ? null : DateTime.parse(json["UpdatedDate"]),
    );

    Map<String, dynamic> toJson() => {
        "Id": id == null ? null : id,
        "UserId": userId == null ? null : userId,
        "Name": name == null ? null : name,
        "CreatedDate": createdDate == null ? null : createdDate.toIso8601String(),
        "UpdatedDate": updatedDate == null ? null : updatedDate.toIso8601String(),
    };
}

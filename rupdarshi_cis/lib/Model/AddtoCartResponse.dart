// To parse this JSON data, do
//
//     final addtoCartResponse = addtoCartResponseFromJson(jsonString);

import 'dart:convert';

AddtoCartResponse addtoCartResponseFromJson(String str) =>
    AddtoCartResponse.fromJson(json.decode(str));

String addtoCartResponseToJson(AddtoCartResponse data) =>
    json.encode(data.toJson());

class AddtoCartResponse {
  AddtoCartResponse({
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

  factory AddtoCartResponse.fromJson(Map<String, dynamic> json) =>
      AddtoCartResponse(
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
    this.userCartProductXrefs,
    this.id,
    this.userId,
    this.name,
    this.createdDate,
    this.updatedDate,
  });

  List<UserCartProductXref> userCartProductXrefs;
  int id;
  int userId;
  String name;
  DateTime createdDate;
  DateTime updatedDate;

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        userCartProductXrefs: json["UserCartProductXrefs"] == null
            ? null
            : List<UserCartProductXref>.from(json["UserCartProductXrefs"]
                .map((x) => UserCartProductXref.fromJson(x))),
        id: json["Id"] == null ? null : json["Id"],
        userId: json["UserId"] == null ? null : json["UserId"],
        name: json["Name"] == null ? null : json["Name"],
        createdDate: json["CreatedDate"] == null
            ? null
            : DateTime.parse(json["CreatedDate"]),
        updatedDate: json["UpdatedDate"] == null
            ? null
            : DateTime.parse(json["UpdatedDate"]),
      );

  Map<String, dynamic> toJson() => {
        "UserCartProductXrefs": userCartProductXrefs == null
            ? null
            : List<dynamic>.from(userCartProductXrefs.map((x) => x.toJson())),
        "Id": id == null ? null : id,
        "UserId": userId == null ? null : userId,
        "Name": name == null ? null : name,
        "CreatedDate":
            createdDate == null ? null : createdDate.toIso8601String(),
        "UpdatedDate":
            updatedDate == null ? null : updatedDate.toIso8601String(),
      };
}

class UserCartProductXref {
  UserCartProductXref({
    this.id,
    this.userCartId,
    this.productId,
    this.quantity,
    this.sizeId,
    this.colourId,
  });

  int id;
  int userCartId;
  int productId;
  int quantity;
  dynamic sizeId;
  dynamic colourId;

  factory UserCartProductXref.fromJson(Map<String, dynamic> json) =>
      UserCartProductXref(
        id: json["Id"] == null ? null : json["Id"],
        userCartId: json["UserCartId"] == null ? null : json["UserCartId"],
        productId: json["ProductId"] == null ? null : json["ProductId"],
        quantity: json["Quantity"] == null ? null : json["Quantity"],
        sizeId: json["SizeId"],
        colourId: json["ColourId"],
      );

  Map<String, dynamic> toJson() => {
        "Id": id == null ? null : id,
        "UserCartId": userCartId == null ? null : userCartId,
        "ProductId": productId == null ? null : productId,
        "Quantity": quantity == null ? null : quantity,
        "SizeId": sizeId,
        "ColourId": colourId,
      };
}

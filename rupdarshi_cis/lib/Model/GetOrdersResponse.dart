// To parse this JSON data, do
//
//     final getOrdersResponse = getOrdersResponseFromJson(jsonString);

import 'dart:convert';

import 'dart:ffi';

GetOrdersResponse getOrdersResponseFromJson(String str) =>
    GetOrdersResponse.fromJson(json.decode(str));

String getOrdersResponseToJson(GetOrdersResponse data) =>
    json.encode(data.toJson());

class GetOrdersResponse {
  GetOrdersResponse({
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

  factory GetOrdersResponse.fromJson(Map<String, dynamic> json) =>
      GetOrdersResponse(
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
    this.code,
    this.vendorid,
    this.vendorname,
    this.vendorType,
    this.vendorTypeId,
    this.email,
    this.totalPrice,
    this.createdByUserId,
    this.stateid,
    this.stateName,
    this.district,
    this.city,
    this.landmark,
    this.address1,
    this.address2,
    this.pincode,
    this.mobileNumber,
    this.statusName,
    this.statusTypeid,
    this.paymentTypeId,
    this.discount,
    this.paymentType,
    this.createdDate,
    this.updatedDate,
    this.fileName,
    this.fileLocation,
    this.fileExtension,
    this.payableAmount

  });

  int id;
  String code;
  int vendorid;
  String vendorname;
  String vendorType;
  int vendorTypeId;
  String email;
  double totalPrice;
  String createdByUserId;
  int stateid;
  String stateName;
  String district;
  String city;
  String landmark;
  String address1;
  String address2;
  String pincode;
  String mobileNumber;
  String statusName;
  int statusTypeid;
  int paymentTypeId;
  int discount;
  String paymentType;
  DateTime createdDate;
  DateTime updatedDate;
  String fileName;
  String fileLocation;
  String fileExtension;
  double payableAmount;

  factory ListResult.fromJson(Map<String, dynamic> json) => ListResult(
        id: json["Id"] == null ? null : json["Id"],
        code: json["Code"] == null ? null : json["Code"],
        vendorid: json["Vendorid"] == null ? null : json["Vendorid"],
        vendorname: json["Vendorname"] == null ? null : json["Vendorname"],
        vendorType: json["VendorType"] == null ? null : json["VendorType"],
        vendorTypeId: json["VendorTypeId"] == null ? null : json["VendorTypeId"],
        email: json["Email"] == null ? null : json["Email"],
        totalPrice:
            json["TotalPrice"] == null ? null : json["TotalPrice"].toDouble(),
        createdByUserId:
            json["CreatedByUserId"] == null ? null : json["CreatedByUserId"],
        stateid: json["Stateid"] == null ? null : json["Stateid"],
        stateName: json["StateName"] == null ? null : json["StateName"],
        district: json["District"] == null ? null : json["District"],
        city: json["City"] == null ? null : json["City"],
        landmark: json["Landmark"] == null ? null : json["Landmark"],
        address1: json["Address1"] == null ? null : json["Address1"],
        address2: json["Address2"] == null ? null : json["Address2"],
        pincode: json["Pincode"] == null ? null : json["Pincode"],
        mobileNumber:
            json["MobileNumber"] == null ? null : json["MobileNumber"],
        statusName: json["StatusName"] == null ? null : json["StatusName"],
        statusTypeid:
            json["StatusTypeid"] == null ? null : json["StatusTypeid"],
        paymentTypeId:
            json["PaymentTypeId"] == null ? null : json["PaymentTypeId"],
        discount:
            json["Discount"] == null ? null : json["Discount"],
        paymentType: json["PaymentType"] == null ? null : json["PaymentType"],
        createdDate: json["CreatedDate"] == null
            ? null
            : DateTime.parse(json["CreatedDate"]),
        updatedDate: json["UpdatedDate"] == null
            ? null
            : DateTime.parse(json["UpdatedDate"]),
        fileName: json["FileName"] == null ? null : json["FileName"],
        fileLocation: json["FileLocation"] == null ? null : json["FileLocation"],
        fileExtension: json["FileExtension"] == null ? null : json["FileExtension"],
        payableAmount: json["PayableAmount"] == null ? null : json["PayableAmount"],

      );

  Map<String, dynamic> toJson() => {
        "Id": id == null ? null : id,
        "Code": code == null ? null : code,
        "Vendorid": vendorid == null ? null : vendorid,
        "Vendorname": vendorname == null ? null : vendorname,
        "VendorType": vendorType == null ? null : vendorType,
        "VendorTypeId": vendorTypeId == null ? null : vendorTypeId,
        "Email": email == null ? null : email,
        "TotalPrice": totalPrice == null ? null : totalPrice,
        "CreatedByUserId": createdByUserId == null ? null : createdByUserId,
        "Stateid": stateid == null ? null : stateid,
        "StateName": stateName == null ? null : stateName,
        "District": district == null ? null : district,
        "City": city == null ? null : city,
        "Landmark": landmark == null ? null : landmark,
        "Address1": address1 == null ? null : address1,
        "Address2": address2 == null ? null : address2,
        "Pincode": pincode == null ? null : pincode,
        "MobileNumber": mobileNumber == null ? null : mobileNumber,
        "StatusName": statusName == null ? null : statusName,
        "StatusTypeid": statusTypeid == null ? null : statusTypeid,
        "PaymentTypeId": paymentTypeId == null ? null : paymentTypeId,
        "Discount": discount == null ? null : discount,
        "PaymentType": paymentType == null ? null : paymentType,
        "CreatedDate": createdDate == null ? null : createdDate,
        "UpdatedDate": updatedDate == null ? null : updatedDate,
        "FileName": fileName == null ? null : fileName,
        "FileLocation": fileLocation == null ? null : fileLocation,
        "FileExtension": fileExtension == null ? null : fileExtension,
        "PayableAmount": payableAmount == null ? null : payableAmount,
      };
}

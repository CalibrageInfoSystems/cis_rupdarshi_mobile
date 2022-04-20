// To parse this JSON data, do
//
//     final vendorAddressReponse = vendorAddressReponseFromJson(jsonString);

import 'dart:convert';

VendorAddressReponse vendorAddressReponseFromJson(String str) =>
    VendorAddressReponse.fromJson(json.decode(str));

String vendorAddressReponseToJson(VendorAddressReponse data) =>
    json.encode(data.toJson());

class VendorAddressReponse {
  VendorAddressReponse({
    this.listResult,
    this.isSuccess,
    this.affectedRecords,
    this.endUserMessage,
    this.validationErrors,
    this.exception,
  });

  List<ListResultAddress> listResult;
  bool isSuccess;
  int affectedRecords;
  String endUserMessage;
  dynamic validationErrors;
  Exception exception;

  factory VendorAddressReponse.fromJson(Map<String, dynamic> json) =>
      VendorAddressReponse(
        listResult: json["ListResult"] == null
            ? null
            : List<ListResultAddress>.from(
                json["ListResult"].map((x) => ListResultAddress.fromJson(x))),
        isSuccess: json["IsSuccess"] == null ? null : json["IsSuccess"],
        affectedRecords:
            json["AffectedRecords"] == null ? null : json["AffectedRecords"],
        endUserMessage:
            json["EndUserMessage"] == null ? null : json["EndUserMessage"],
        validationErrors: json["ValidationErrors"],
        exception: json["Exception"] == null
            ? null
            : Exception.fromJson(json["Exception"]),
      );

  Map<String, dynamic> toJson() => {
        "ListResult": listResult == null
            ? null
            : List<dynamic>.from(listResult.map((x) => x.toJson())),
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
        remoteStackIndex:
            json["RemoteStackIndex"] == null ? null : json["RemoteStackIndex"],
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

class ListResultAddress {
  ListResultAddress({
    this.id,
    this.addressName,
    this.vendorid,
    this.username,
    this.stateid,
    this.name,
    this.district,
    this.city,
    this.landmark,
    this.address1,
    this.address2,
    this.pincode,
    this.mobilenumber,
    this.isactive,
    this.addressTypeId,
    this.addressTypeName,
    this.aproved,
    this.isAddressSelected,
  });

  int id;
  String addressName;
  int vendorid;
  String username;
  int stateid;
  String name;
  String district;
  String city;
  String landmark;
  String address1;
  String address2;
  String pincode;
  String mobilenumber;
  bool isactive;
  int addressTypeId;
  String addressTypeName;
  bool aproved;
  bool isAddressSelected;

  factory ListResultAddress.fromJson(Map<String, dynamic> json) =>
      ListResultAddress(
        id: json["id"] == null ? null : json["id"],
        addressName: json["AddressName"] == null ? null : json["AddressName"],
        vendorid: json["vendorid"] == null ? null : json["vendorid"],
        username: json["Username"] == null ? null : json["Username"],
        stateid: json["Stateid"] == null ? null : json["Stateid"],
        name: json["Name"] == null ? null : json["Name"],
        district: json["District"] == null ? null : json["District"],
        city: json["City"] == null ? null : json["City"],
        landmark: json["Landmark"] == null ? null : json["Landmark"],
        address1: json["address1"] == null ? null : json["address1"],
        address2: json["address2"] == null ? null : json["address2"],
        pincode: json["pincode"] == null ? null : json["pincode"],
        mobilenumber:
            json["mobilenumber"] == null ? null : json["mobilenumber"],
        isactive: json["isactive"] == null ? null : json["isactive"],
        addressTypeId:
            json["AddressTypeId"] == null ? null : json["AddressTypeId"],
        addressTypeName:
            json["AddressTypeName"] == null ? null : json["AddressTypeName"],
        aproved: json["Aproved"] == null ? null : json["Aproved"],
        isAddressSelected: json["isAddressSelected"] == null
            ? null
            : json["isAddressSelected"],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "AddressName": addressName == null ? null : addressName,
        "vendorid": vendorid == null ? null : vendorid,
        "Username": username == null ? null : username,
        "Stateid": stateid == null ? null : stateid,
        "Name": name == null ? null : name,
        "District": district == null ? null : district,
        "City": city == null ? null : city,
        "Landmark": landmark == null ? null : landmark,
        "address1": address1 == null ? null : address1,
        "address2": address2 == null ? null : address2,
        "pincode": pincode == null ? null : pincode,
        "mobilenumber": mobilenumber == null ? null : mobilenumber,
        "isactive": isactive == null ? null : isactive,
        "AddressTypeId": addressTypeId == null ? null : addressTypeId,
        "AddressTypeName": addressTypeName == null ? null : addressTypeName,
        "Aproved": aproved == null ? null : aproved,
        "isAddressSelected":
            isAddressSelected == null ? null : isAddressSelected,
      };
}

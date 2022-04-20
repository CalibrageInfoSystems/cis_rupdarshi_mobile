// To parse this JSON data, do
//
//     final vendorProfile = vendorProfileFromJson(jsonString);

import 'dart:convert';

VendorProfile vendorProfileFromJson(String str) =>
    VendorProfile.fromJson(json.decode(str));

String vendorProfileToJson(VendorProfile data) => json.encode(data.toJson());

class VendorProfile {
  VendorProfile({
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

  factory VendorProfile.fromJson(Map<String, dynamic> json) => VendorProfile(
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
  ListResult(
      {this.id,
      this.userId,
      this.vendorName,
      this.firstName,
      this.middleName,
      this.lastName,
      this.userName,
      this.password,
      this.mobileNumber,
      this.email,
      this.businessName,
      this.gstin,
      this.stateId,
      this.stateName,
      this.district,
      this.city,
      this.address,
      this.address1,
      this.address2,
      this.landmark,
      this.pincode,
      this.roleId,
      this.roleName,
      this.serviceTypeId,
      this.serviceType,
      this.statusTypeId,
      this.statusType,
      this.comments,
      this.createdDate,
      this.updatedDate,
      this.createdbyUserId,
      this.logisticOparatorId,
      this.logisticOparatorName,
      this.createdby,
      this.updatedByUserId,
      this.updatedby,
      this.paymentTypeid,
      this.paymentType});

  int id;
  String userId;
  String vendorName;
  String firstName;
  String middleName;
  String lastName;
  String userName;
  String password;
  String mobileNumber;
  String email;
  String businessName;
  String gstin;
  int stateId;
  String stateName;
  String district;
  String city;
  String address;
  String address1;
  String address2;
  String landmark;
  String pincode;
  int roleId;
  String roleName;
  int serviceTypeId;
  String serviceType;
  int statusTypeId;
  String statusType;
  String comments;
  DateTime createdDate;
  DateTime updatedDate;
  int createdbyUserId;
  int logisticOparatorId;
  String logisticOparatorName;
  String createdby;
  int updatedByUserId;
  String updatedby;
  int paymentTypeid;
  String paymentType;

  factory ListResult.fromJson(Map<String, dynamic> json) => ListResult(
        id: json["Id"] == null ? null : json["Id"],
        userId: json["UserId"] == null ? null : json["UserId"],
        vendorName: json["VendorName"] == null ? null : json["VendorName"],
        firstName: json["FirstName"] == null ? null : json["FirstName"],
        middleName: json["MiddleName"] == null ? null : json["MiddleName"],
        lastName: json["LastName"] == null ? null : json["LastName"],
        userName: json["UserName"] == null ? null : json["UserName"],
        password: json["Password"] == null ? null : json["Password"],
        mobileNumber:
            json["MobileNumber"] == null ? null : json["MobileNumber"],
        email: json["Email"] == null ? null : json["Email"],
        businessName:
            json["BusinessName"] == null ? null : json["BusinessName"],
        gstin: json["GSTIN"] == null ? null : json["GSTIN"],
        stateId: json["StateId"] == null ? null : json["StateId"],
        stateName: json["StateName"] == null ? null : json["StateName"],
        district: json["District"] == null ? null : json["District"],
        city: json["City"] == null ? null : json["City"],
        address: json["Address"] == null ? null : json["Address"],
        address1: json["Address1"] == null ? null : json["Address1"],
        address2: json["Address2"] == null ? null : json["Address2"],
        landmark: json["Landmark"] == null ? null : json["Landmark"],
        pincode: json["Pincode"] == null ? null : json["Pincode"],
        roleId: json["RoleId"] == null ? null : json["RoleId"],
        roleName: json["RoleName"] == null ? null : json["RoleName"],
        serviceTypeId:
            json["ServiceTypeId"] == null ? null : json["ServiceTypeId"],
        serviceType: json["ServiceType"] == null ? null : json["ServiceType"],
        statusTypeId:
            json["StatusTypeId"] == null ? null : json["StatusTypeId"],
        statusType: json["StatusType"] == null ? null : json["StatusType"],
        comments: json["Comments"],
        createdDate: json["CreatedDate"] == null
            ? null
            : DateTime.parse(json["CreatedDate"]),
        updatedDate: json["UpdatedDate"] == null
            ? null
            : DateTime.parse(json["UpdatedDate"]),
        createdbyUserId:
            json["CreatedbyUserId"] == null ? null : json["CreatedbyUserId"],
        logisticOparatorId: json["LogisticOparatorId"],
        logisticOparatorName: json["LogisticOparatorName"],
        createdby: json["Createdby"] == null ? null : json["Createdby"],
        updatedByUserId:
            json["UpdatedByUserId"] == null ? null : json["UpdatedByUserId"],
        updatedby: json["Updatedby"] == null ? null : json["Updatedby"],
        paymentTypeid:
            json["PaymentTypeid"] == null ? null : json["PaymentTypeid"],
        paymentType: json["PaymentType"] == null ? null : json["PaymentType"],
      );

  Map<String, dynamic> toJson() => {
        "Id": id == null ? null : id,
        "UserId": userId == null ? null : userId,
        "VendorName": vendorName == null ? null : vendorName,
        "FirstName": firstName == null ? null : firstName,
        "MiddleName": middleName == null ? null : middleName,
        "LastName": lastName == null ? null : lastName,
        "UserName": userName == null ? null : userName,
        "Password": password == null ? null : password,
        "MobileNumber": mobileNumber == null ? null : mobileNumber,
        "Email": email == null ? null : email,
        "BusinessName": businessName == null ? null : businessName,
        "GSTIN": gstin == null ? null : gstin,
        "StateId": stateId == null ? null : stateId,
        "StateName": stateName == null ? null : stateName,
        "District": district == null ? null : district,
        "City": city == null ? null : city,
        "Address": address == null ? null : address,
        "Address1": address1 == null ? null : address1,
        "Address2": address2 == null ? null : address2,
        "Landmark": landmark == null ? null : landmark,
        "Pincode": pincode == null ? null : pincode,
        "RoleId": roleId == null ? null : roleId,
        "RoleName": roleName == null ? null : roleName,
        "ServiceTypeId": serviceTypeId == null ? null : serviceTypeId,
        "ServiceType": serviceType == null ? null : serviceType,
        "StatusTypeId": statusTypeId == null ? null : statusTypeId,
        "StatusType": statusType == null ? null : statusType,
        "Comments": comments,
        "CreatedDate":
            createdDate == null ? null : createdDate.toIso8601String(),
        "UpdatedDate":
            updatedDate == null ? null : updatedDate.toIso8601String(),
        "CreatedbyUserId": createdbyUserId == null ? null : createdbyUserId,
        "LogisticOparatorId": logisticOparatorId,
        "LogisticOparatorName": logisticOparatorName,
        "Createdby": createdby == null ? null : createdby,
        "UpdatedByUserId": updatedByUserId == null ? null : updatedByUserId,
        "Updatedby": updatedby == null ? null : updatedby,
        "PaymentTypeid": paymentTypeid == null ? null : paymentTypeid,
        "PaymentType": paymentType == null ? null : paymentType,
      };
}

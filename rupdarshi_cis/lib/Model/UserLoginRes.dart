// To parse this JSON data, do
//
//     final userloginRes = userloginResFromJson(jsonString);

import 'dart:convert';

UserloginRes userloginResFromJson(String str) => UserloginRes.fromJson(json.decode(str));

String userloginResToJson(UserloginRes data) => json.encode(data.toJson());

class UserloginRes {
    UserloginRes({
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

    factory UserloginRes.fromJson(Map<String, dynamic> json) => UserloginRes(
        result: Result.fromJson(json["Result"]),
        isSuccess: json["IsSuccess"],
        affectedRecords: json["AffectedRecords"],
        endUserMessage: json["EndUserMessage"],
        validationErrors: List<dynamic>.from(json["ValidationErrors"].map((x) => x)),
        exception: json["Exception"],
    );

    Map<String, dynamic> toJson() => {
        "Result": result.toJson(),
        "IsSuccess": isSuccess,
        "AffectedRecords": affectedRecords,
        "EndUserMessage": endUserMessage,
        "ValidationErrors": List<dynamic>.from(validationErrors.map((x) => x)),
        "Exception": exception,
    };
}

class Result {
    Result({
        this.accessToken,
        this.tokenType,
        this.expiresIn,
        this.userInfos,
    });

    dynamic accessToken;
    dynamic tokenType;
    int expiresIn;
    UserInfos userInfos;

    factory Result.fromJson(Map<String, dynamic> json) => Result(
        accessToken: json["access_token"],
        tokenType: json["token_type"],
        expiresIn: json["expires_in"],
        userInfos: UserInfos.fromJson(json["UserInfos"]),
    );

    Map<String, dynamic> toJson() => {
        "access_token": accessToken,
        "token_type": tokenType,
        "expires_in": expiresIn,
        "UserInfos": userInfos.toJson(),
    };
}

class UserInfos {
    UserInfos({
        this.id,
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
        this.createdby,
        this.updatedByUserId,
        this.updatedby,
    });

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
    String createdby;
    int updatedByUserId;
    String updatedby;

    factory UserInfos.fromJson(Map<String, dynamic> json) => UserInfos(
        id: json["Id"],
        userId: json["UserId"],
        vendorName: json["VendorName"],
        firstName: json["FirstName"],
        middleName: json["MiddleName"],
        lastName: json["LastName"],
        userName: json["UserName"],
        password: json["Password"],
        mobileNumber: json["MobileNumber"],
        email: json["Email"],
        businessName: json["BusinessName"],
        gstin: json["GSTIN"],
        stateId: json["StateId"],
        stateName: json["StateName"],
        district: json["District"],
        city: json["City"],
        address: json["Address"],
        address1: json["Address1"],
        address2: json["Address2"],
        landmark: json["Landmark"],
        pincode: json["Pincode"],
        roleId: json["RoleId"],
        roleName: json["RoleName"],
        serviceTypeId: json["ServiceTypeId"],
        serviceType: json["ServiceType"],
        statusTypeId: json["StatusTypeId"],
        statusType: json["StatusType"],
        comments: json["Comments"],
        createdDate: DateTime.parse(json["CreatedDate"]),
        updatedDate: DateTime.parse(json["UpdatedDate"]),
        createdbyUserId: json["CreatedbyUserId"],
        createdby: json["Createdby"],
        updatedByUserId: json["UpdatedByUserId"],
        updatedby: json["Updatedby"],
    );

    Map<String, dynamic> toJson() => {
        "Id": id,
        "UserId": userId,
        "VendorName": vendorName,
        "FirstName": firstName,
        "MiddleName": middleName,
        "LastName": lastName,
        "UserName": userName,
        "Password": password,
        "MobileNumber": mobileNumber,
        "Email": email,
        "BusinessName": businessName,
        "GSTIN": gstin,
        "StateId": stateId,
        "StateName": stateName,
        "District": district,
        "City": city,
        "Address": address,
        "Address1": address1,
        "Address2": address2,
        "Landmark": landmark,
        "Pincode": pincode,
        "RoleId": roleId,
        "RoleName": roleName,
        "ServiceTypeId": serviceTypeId,
        "ServiceType": serviceType,
        "StatusTypeId": statusTypeId,
        "StatusType": statusType,
        "Comments": comments,
        "CreatedDate": createdDate.toIso8601String(),
        "UpdatedDate": updatedDate.toIso8601String(),
        "CreatedbyUserId": createdbyUserId,
        "Createdby": createdby,
        "UpdatedByUserId": updatedByUserId,
        "Updatedby": updatedby,
    };
}

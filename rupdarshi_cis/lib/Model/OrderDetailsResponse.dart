// To parse this JSON data, do
//
//     final orderDetailsResponse = orderDetailsResponseFromJson(jsonString);

import 'dart:convert';

OrderDetailsResponse orderDetailsResponseFromJson(String str) => OrderDetailsResponse.fromJson(json.decode(str));

String orderDetailsResponseToJson(OrderDetailsResponse data) => json.encode(data.toJson());

class OrderDetailsResponse {
    OrderDetailsResponse({
        this.listResult,
        this.isSuccess,
        this.affectedRecords,
        this.endUserMessage,
        this.validationErrors,
        this.exception,
    });

    List<OrderDetails> listResult;
    bool isSuccess;
    int affectedRecords;
    String endUserMessage;
    List<dynamic> validationErrors;
    dynamic exception;

    factory OrderDetailsResponse.fromJson(Map<String, dynamic> json) => OrderDetailsResponse(
        listResult: json["ListResult"] == null ? null : List<OrderDetails>.from(json["ListResult"].map((x) => OrderDetails.fromJson(x))),
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

class OrderDetails {
    OrderDetails({
        this.id,
        this.orderId,
        this.itemId,
        this.name,
        this.quantity,
        this.discount,
        this.gst,
        this.sizeid,
        this.price,
        this.finalPrice,
        this.barcode,
        this.paymentTypeId,
        this.paymentType,
        this.size,
        this.statusTypeId,
        this.statusName,
        this.colourId,
        this.colour,
        this.itemFinalPrice,
        this.overallPrice,
        this.filePath,
        this.customerNumber,
        this.shippingId,
        this.deliveryDate,
        this.preferLogisticId,
        this.preferLogisticName,
        this.shippingAddress,
        this.billingAddress,
    });

    int id;
    int orderId;
    int itemId;
    String name;
    int quantity;
    double discount;
    double gst;
    int sizeid;
    double price;
    double finalPrice;
    String barcode;
    int paymentTypeId;
    String paymentType;
    String size;
    int statusTypeId;
    String statusName;
    int colourId;
    String colour;
    double itemFinalPrice;
    double overallPrice;
    String filePath;
    String customerNumber;
    dynamic shippingId;
    dynamic deliveryDate;
    int preferLogisticId;
    String preferLogisticName;
    String shippingAddress;
    String billingAddress;

    factory OrderDetails.fromJson(Map<String, dynamic> json) => OrderDetails(
        id: json["Id"] == null ? null : json["Id"],
        orderId: json["OrderId"] == null ? null : json["OrderId"],
        itemId: json["ItemId"] == null ? null : json["ItemId"],
        name: json["Name"] == null ? null : json["Name"],
        quantity: json["Quantity"] == null ? null : json["Quantity"],
        discount: json["Discount"] == null ? null : json["Discount"],
        gst: json["GST"] == null ? null : json["GST"],
        sizeid: json["Sizeid"] == null ? null : json["Sizeid"],
        price: json["Price"] == null ? null : json["Price"].toDouble(),
        finalPrice: json["FinalPrice"] == null ? null : json["FinalPrice"].toDouble(),
        barcode: json["Barcode"] == null ? null : json["Barcode"],
        paymentTypeId: json["PaymentTypeId"] == null ? null : json["PaymentTypeId"],
        paymentType: json["PaymentType"] == null ? null : json["PaymentType"],
        size: json["Size"] == null ? null : json["Size"],
        statusTypeId: json["StatusTypeId"] == null ? null : json["StatusTypeId"],
        statusName: json["StatusName"] == null ? null : json["StatusName"],
        colourId: json["ColourId"] == null ? null : json["ColourId"],
        colour: json["Colour"] == null ? null : json["Colour"],
        itemFinalPrice: json["ItemFinalPrice"] == null ? null : json["ItemFinalPrice"].toDouble(),
        overallPrice: json["OverallPrice"] == null ? null : json["OverallPrice"].toDouble(),
        filePath: json["FilePath"] == null ? null : json["FilePath"],
        customerNumber: json["CustomerNumber"] == null ? null : json["CustomerNumber"],
        shippingId: json["ShippingId"],
        deliveryDate: json["DeliveryDate"],
        preferLogisticId: json["PreferLogisticId"] == null ? null : json["PreferLogisticId"],
        preferLogisticName: json["PreferLogisticName"] == null ? null : json["PreferLogisticName"],
        shippingAddress: json["ShippingAddress"],
        billingAddress: json["BillingAddress"] == null ? null : json["BillingAddress"],
    );

    Map<String, dynamic> toJson() => {
        "Id": id == null ? null : id,
        "OrderId": orderId == null ? null : orderId,
        "ItemId": itemId == null ? null : itemId,
        "Name": name == null ? null : name,
        "Quantity": quantity == null ? null : quantity,
        "Discount": discount == null ? null : discount,
        "GST": gst == null ? null : gst,
        "Sizeid": sizeid == null ? null : sizeid,
        "Price": price == null ? null : price,
        "FinalPrice": finalPrice == null ? null : finalPrice,
        "Barcode": barcode == null ? null : barcode,
        "PaymentTypeId": paymentTypeId == null ? null : paymentTypeId,
        "PaymentType": paymentType == null ? null : paymentType,
        "Size": size == null ? null : size,
        "StatusTypeId": statusTypeId == null ? null : statusTypeId,
        "StatusName": statusName == null ? null : statusName,
        "ColourId": colourId == null ? null : colourId,
        "Colour": colour == null ? null : colour,
        "ItemFinalPrice": itemFinalPrice == null ? null : itemFinalPrice,
        "OverallPrice": overallPrice == null ? null : overallPrice,
        "FilePath": filePath == null ? null : filePath,
        "CustomerNumber": customerNumber == null ? null : customerNumber,
        "ShippingId": shippingId,
        "DeliveryDate": deliveryDate,
        "PreferLogisticId": preferLogisticId == null ? null : preferLogisticId,
        "PreferLogisticName": preferLogisticName == null ? null : preferLogisticName,
        "ShippingAddress": shippingAddress,
        "BillingAddress": billingAddress == null ? null : billingAddress,
    };
}

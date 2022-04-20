// To parse this JSON data, do
//
//     final placeOerderRequestModel = placeOerderRequestModelFromJson(jsonString);

import 'dart:convert';

PlaceOerderRequestModel placeOerderRequestModelFromJson(String str) =>
    PlaceOerderRequestModel.fromJson(json.decode(str));

String placeOerderRequestModelToJson(PlaceOerderRequestModel data) =>
    json.encode(data.toJson());

class PlaceOerderRequestModel {
  PlaceOerderRequestModel({
    this.order,
    this.products,
  });

  Order order;
  List<Product> products;

  factory PlaceOerderRequestModel.fromJson(Map<String, dynamic> json) =>
      PlaceOerderRequestModel(
        order: json["Order"] == null ? null : Order.fromJson(json["Order"]),
        products: json["Products"] == null
            ? null
            : List<Product>.from(
                json["Products"].map((x) => Product.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "Order": order == null ? null : order.toJson(),
        "Products": products == null
            ? null
            : List<dynamic>.from(products.map((x) => x.toJson())),
      };
}

class Order {
  Order({
    this.vendorId,
    this.totalPrice,
    this.statusTypeid,
    this.createdbyUserId,
    this.updatedbyUserId,
    this.billingAddressId,
    this.shippingAddressId,
    this.preferLogisticOparatorId,
    this.paymentType,
    this.discount
  });

  int vendorId;
  double totalPrice;
  int statusTypeid;
  String createdbyUserId;
  String updatedbyUserId;
  int billingAddressId;
  int shippingAddressId;
  int preferLogisticOparatorId;
  int paymentType;
  int discount;

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        vendorId: json["VendorId"] == null ? null : json["VendorId"],
        totalPrice:
            json["TotalPrice"] == null ? null : json["TotalPrice"].toDouble(),
        statusTypeid:
            json["StatusTypeid"] == null ? null : json["StatusTypeid"],
        createdbyUserId:
            json["CreatedbyUserId"] == null ? null : json["CreatedbyUserId"],
        updatedbyUserId:
            json["UpdatedbyUserId"] == null ? null : json["UpdatedbyUserId"],
        billingAddressId:
            json["BillingAddressId"] == null ? null : json["BillingAddressId"],
        shippingAddressId: json["ShippingAddressId"] == null
            ? null
            : json["ShippingAddressId"],
        preferLogisticOparatorId: json["PreferLogisticOparatorId"] == null
            ? null
            : json["PreferLogisticOparatorId"],
        paymentType: json["PaymentType"] == null ? null : json["PaymentType"],
        discount: json["Discount"] == null ? null : json["Discount"]
      );

  Map<String, dynamic> toJson() => {
        "VendorId": vendorId == null ? null : vendorId,
        "TotalPrice": totalPrice == null ? null : totalPrice,
        "StatusTypeid": statusTypeid == null ? null : statusTypeid,
        "CreatedbyUserId": createdbyUserId == null ? null : createdbyUserId,
        "UpdatedbyUserId": updatedbyUserId == null ? null : updatedbyUserId,
        "BillingAddressId": billingAddressId == null ? null : billingAddressId,
        "ShippingAddressId":
            shippingAddressId == null ? null : shippingAddressId,
        "PreferLogisticOparatorId":
            preferLogisticOparatorId == null ? null : preferLogisticOparatorId,
        "PaymentType": paymentType == null ? null : paymentType,
        "Discount": discount == null ? null : discount,

      };
}

class Product {
  Product({
    this.itemId,
    this.price,
    this.finalPrice,
    this.gst,
    this.discount,
    this.quantity,
    this.sizeId,
    this.colourId,
  });

  int itemId;
  double price;
  double finalPrice;
  double gst;
  double discount;
  int quantity;
  int sizeId;
  int colourId;

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        itemId: json["ItemId"] == null ? null : json["ItemId"],
        price: json["Price"] == null ? null : json["Price"].toDouble(),
        finalPrice:
            json["FinalPrice"] == null ? null : json["FinalPrice"].toDouble(),
        gst: json["GST"] == null ? null : json["GST"].toDouble(),
        discount: json["Discount"] == null ? null : json["Discount"].toDouble(),
        quantity: json["Quantity"] == null ? null : json["Quantity"],
        sizeId: json["SizeId"] == null ? null : json["SizeId"],
        colourId: json["ColourId"] == null ? null : json["ColourId"],
      );

  Map<String, dynamic> toJson() => {
        "ItemId": itemId == null ? null : itemId,
        "Price": price == null ? null : price,
        "FinalPrice": finalPrice == null ? null : finalPrice,
        "GST": gst == null ? null : gst,
        "Discount": discount == null ? null : discount,
        "Quantity": quantity == null ? null : quantity,
        "SizeId": sizeId == null ? null : sizeId,
        "ColourId": colourId == null ? null : colourId,
      };
}

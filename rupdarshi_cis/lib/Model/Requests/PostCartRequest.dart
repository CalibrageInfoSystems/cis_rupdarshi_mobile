// To parse this JSON data, do
//
//     final postCartRequest = postCartRequestFromJson(jsonString);

import 'dart:convert';

PostCartRequest postCartRequestFromJson(String str) =>
    PostCartRequest.fromJson(json.decode(str));

String postCartRequestToJson(PostCartRequest data) =>
    json.encode(data.toJson());

class PostCartRequest {
  PostCartRequest({
    this.cart,
    this.items,
  });

  CartPostInfo cart;
  List<ItemsList> items;

  factory PostCartRequest.fromJson(Map<String, dynamic> json) =>
      PostCartRequest(
        cart: json["cart"] == null ? null : CartPostInfo.fromJson(json["cart"]),
        items: json["Items"] == null
            ? null
            : List<ItemsList>.from(
                json["Items"].map((x) => ItemsList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "cart": cart == null ? null : cart.toJson(),
        "Items": items == null
            ? null
            : List<dynamic>.from(items.map((x) => x.toJson())),
      };
}

class CartPostInfo {
  CartPostInfo({
    this.id,
    this.userId,
    this.name,
  });

  int id;
  int userId;
  String name;

  factory CartPostInfo.fromJson(Map<String, dynamic> json) => CartPostInfo(
        id: json["Id"] == null ? null : json["Id"],
        userId: json["UserId"] == null ? null : json["UserId"],
        name: json["Name"] == null ? null : json["Name"],
      );

  Map<String, dynamic> toJson() => {
        "Id": id == null ? null : id,
        "UserId": userId == null ? null : userId,
        "Name": name == null ? null : name,
      };
}

class ItemsList {
  ItemsList({
    this.itemId,
    this.colourId,
    this.sizeId,
    this.quantity,
  });

  int itemId;
  int colourId;
  int sizeId;
  int quantity;

  factory ItemsList.fromJson(Map<String, dynamic> json) => ItemsList(
        itemId: json["ItemId"] == null ? null : json["ItemId"],
        colourId: json["ColourId"] == null ? null : json["ColourId"],
        sizeId: json["SizeId"] == null ? null : json["SizeId"],
        quantity: json["Quantity"] == null ? null : json["Quantity"],
      );

  Map<String, dynamic> toJson() => {
        "ItemId": itemId == null ? null : itemId,
        "ColourId": colourId == null ? null : colourId,
        "SizeId": sizeId == null ? null : sizeId,
        "Quantity": quantity == null ? null : quantity,
      };
}

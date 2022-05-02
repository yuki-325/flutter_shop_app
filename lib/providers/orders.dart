import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';
import 'cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    required this.id,
    required this.amount,
    required this.products,
    required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final _url = Uri.parse(
      "https://flutter-shop-app-22af1-default-rtdb.asia-southeast1.firebasedatabase.app/orders.json");

  List<OrderItem> get orders {
    return _orders;
  }

  Future<void> fetchAndSetOrder() async {
    final response = await http.get(_url);
    final List<OrderItem> loadOrders = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>?;

    if (extractedData == null) {
      return;
    }
    extractedData.forEach(
      (orderId, orderData) {
        loadOrders.add(
          OrderItem(
            id: orderId,
            amount: orderData["amount"],
            dateTime: DateTime.parse(orderData["dateTime"]),
            products: (orderData["products"] as List<dynamic>)
                .map(
                  (cartItem) => CartItem(
                    id: cartItem["id"],
                    title: cartItem["title"],
                    quantity: cartItem["quantity"],
                    price: cartItem["price"],
                  ),
                )
                .toList(),
          ),
        );
      },
    );
    _orders = loadOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final timeStamp = DateTime.now();
    try {
      final response = await http.post(_url,
          body: json.encode({
            "amount": total,
            "products": cartProducts
                .map((product) => {
                      "id": product.id,
                      "title": product.title,
                      "quantity": product.quantity,
                      "price": product.price,
                    })
                .toList(),
            "dateTime": timeStamp.toIso8601String(),
          }));

      _orders.insert(
        0,
        OrderItem(
          id: json.decode(response.body)["name"],
          amount: total,
          products: cartProducts,
          dateTime: timeStamp,
        ),
      );
      if (response.statusCode >= 400) {
        throw HttpException(
            message: "error: " + response.statusCode.toString());
      }
    } catch (error) {
      _orders.removeAt(0);
      rethrow;
    } finally {
      notifyListeners();
    }
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/http_exception.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool? isFavorite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavorite,
  }) {
    // defauleはfalse
    isFavorite ??= false;
  }

  void _setFavorite({required newValue}) {
    isFavorite = newValue;
  }

  Future<void> togglefavoriteStatus(String token) async {
    final oldStatus = isFavorite;
    final url = Uri.parse(
        "https://flutter-shop-app-22af1-default-rtdb.asia-southeast1.firebasedatabase.app/products/$id.json?auth=$token");
    // メモリ上の商品のお気に入りを変更
    isFavorite = !(isFavorite ?? false);
    try {
      final response = await http.patch(
        url,
        body: json.encode({"isFavorite": isFavorite}),
      );

      if (response.statusCode >= 400) {
        throw HttpException(
            message: "Status:" + response.statusCode.toString());
      }
    } catch (error) {
      // // サーバ上で正常に更新できなかったら元に戻す
      // isFavorite = !(isFavorite ?? false);
      _setFavorite(newValue: oldStatus);
      rethrow;
    } finally {
      notifyListeners();
    }
  }
}

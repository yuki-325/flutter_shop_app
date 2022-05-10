import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/http_exception.dart';
import 'package:shop_app/providers/product.dart';

// NOTE Providerで状態管理するオブジェクトとして設定する "with ChangeNotifier"
class Products with ChangeNotifier {
  List<Product> _items = [];
  Uri? _url;
  String? _authToken;
  String? _userId;

  set userId(String? value) {
    _userId = value;
  }

  set authToken(String? value) {
    _authToken = value;
    _url = Uri.parse(
        "https://flutter-shop-app-22af1-default-rtdb.asia-southeast1.firebasedatabase.app/products.json?auth=$_authToken");
  }

  set items(List<Product> items) {
    _items = items;
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite == true).toList();
  }

  List<Product> get items {
    return _items;
  }

  Product findById({required String id}) {
    return _items.firstWhere((product) => product.id == id);
  }

  Future<void> fetchAndSetProducts() async {
    try {
      final response = await http.get(_url!);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<Product> loadProducts = [];

      final getFavUrl = Uri.parse(
          "https://flutter-shop-app-22af1-default-rtdb.asia-southeast1.firebasedatabase.app/userFavorites/$_userId.json?auth=$_authToken");

      final favoriteResponse = await http.get(getFavUrl);
      final favoriteData = json.decode(favoriteResponse.body);

      extractedData.forEach((productId, productData) {
        loadProducts.add(Product(
          id: productId,
          title: productData["title"],
          description: productData["description"],
          price: productData["price"],
          imageUrl: productData["imageUrl"],
          isFavorite:
              favoriteData == null ? false : favoriteData[productId] ?? false,
        ));
      });
      _items = loadProducts;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      final response = await http.post(
        _url!,
        body: json.encode({
          "title": product.title,
          "description": product.description,
          "price": product.price,
          "imageUrl": product.imageUrl,
        }),
      );
      final newProduct = Product(
        id: json.decode(response.body)["name"],
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      );

      _items.add(newProduct);

      // NOTE 値(_items)の変更を通知する
      notifyListeners();
    } catch (error) {
      print(error);
      rethrow;
    }
  }

  Future<void> updateProduct(String productId, Product newProduct) async {
    final prodIndex = _items.indexWhere((product) => product.id == productId);
    if (prodIndex != -1) {
      final url = Uri.parse(
          "https://flutter-shop-app-22af1-default-rtdb.asia-southeast1.firebasedatabase.app/products/$productId.json?auth=$_authToken");
      try {
        await http.patch(url,
            body: json.encode({
              "title": newProduct.title,
              "price": newProduct.price,
              "description": newProduct.description,
              "imageUrl": newProduct.imageUrl,
              "isFavorite": newProduct.isFavorite,
            }));
        _items[prodIndex] = newProduct;
        notifyListeners();
      } catch (error) {
        print(error);
        rethrow;
      }
    }
  }

  Future<void> removeProduct(String productId) async {
    final url = Uri.parse(
        "https://flutter-shop-app-22af1-default-rtdb.asia-southeast1.firebasedatabase.app/products/$productId.json?auth=$_authToken");
    final existingProductIndex =
        _items.indexWhere((product) => product.id == productId);
    Product? existingProduct = _items[existingProductIndex];

    // メモリ上のデータを削除
    _items.removeWhere((product) => product.id == productId);

    try {
      // サーバー上のデータを削除
      final response = await http.delete(url);
      if (response.statusCode >= 400) {
        throw HttpException(message: "Could not delete product.");
      }
      existingProduct = null;
    } catch (e) {
      // サーバ上で削除できなければ(エラーが出たら)もう一度追加しておく
      _items.insert(existingProductIndex, existingProduct!);
      rethrow;
    } finally {
      notifyListeners();
    }
  }
}

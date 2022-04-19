import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/product.dart';
import 'package:shop_app/providers/products.dart';

import 'product_item.dart';

class ProductsGrid extends StatelessWidget {
  final bool showFavs;
  const ProductsGrid({
    Key? key,
    required this.showFavs,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // NOTE Productsオブジェクトを取得
    final productsData = Provider.of<Products>(context);

    // ProductsオブジェクトからProductsを取得
    final products = showFavs ? productsData.favoriteItems : productsData.items;

    return GridView.builder(
      padding: const EdgeInsets.all(10.0),
      itemCount: products.length,
      itemBuilder: (context, index) => ChangeNotifierProvider<Product>.value(
        // NOTE 新しいインスタンスを使用しないならvalueの方が効率がいいらしい
        value: products[index],
        child: const ProductItem(
            // id: products[index].id,
            // title: products[index].title,
            // imageUrl: products[index].imageUrl,
            ),
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
    );
  }
}

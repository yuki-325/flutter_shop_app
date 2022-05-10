import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/providers/product.dart';
import 'package:shop_app/screen/product_detail_screen.dart';

import '../providers/auth.dart';

class ProductItem extends StatelessWidget {
  // final String id;
  // final String title;
  // final String imageUrl;

  const ProductItem({
    Key? key,
    // required this.id,
    // required this.title,
    // required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    final authData = Provider.of<Auth>(context, listen: false);

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(
              ProductDetailScreen.routeName,
              arguments: product.id,
            );
          },
          child: Image.network(
            product.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          leading: Consumer<Product>(
            builder: (context, product, child) => IconButton(
              onPressed: () async {
                await product.togglefavoriteStatus(
                  authData.token,
                  authData.userId,
                );
              },
              icon: Icon(
                (product.isFavorite ?? false)
                    ? Icons.favorite
                    : Icons.favorite_border,
              ),
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          title: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              product.title,
              textAlign: TextAlign.center,
            ),
          ),
          trailing: IconButton(
            onPressed: () {
              cart.addItem(product.id, product.price, product.title);

              // スナックバーが表示されていれば閉じる(連続表示対策)
              ScaffoldMessenger.of(context).hideCurrentSnackBar();

              // スナックバー
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text(
                  "Added item to cart!",
                ),
                duration: const Duration(seconds: 2),
                action: SnackBarAction(
                    label: "UNDO",
                    onPressed: () {
                      cart.removeItem(product.id);
                    }),
              ));
            },
            icon: const Icon(Icons.shopping_cart),
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ),
    );
  }
}

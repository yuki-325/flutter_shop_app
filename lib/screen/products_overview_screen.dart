import 'package:flutter/material.dart';

import '../widgets/products_grid.dart';

enum FilterOption {
  Favorite,
  All,
}

class ProductsOverViewScreen extends StatefulWidget {
  const ProductsOverViewScreen({Key? key}) : super(key: key);

  @override
  State<ProductsOverViewScreen> createState() => _ProductsOverViewScreenState();
}

class _ProductsOverViewScreenState extends State<ProductsOverViewScreen> {
  var _showOnlyFavorites = false;

  @override
  Widget build(BuildContext context) {
    // final productsContainer = Provider.of<Products>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text("MyShop"),
        actions: [
          PopupMenuButton(
            onSelected: (FilterOption selectValue) {
              setState(() {
                switch (selectValue) {
                  case FilterOption.Favorite:
                    // productsContainer.showFavoriteOnly();
                    _showOnlyFavorites = true;
                    break;
                  case FilterOption.All:
                    _showOnlyFavorites = false;
                    // productsContainer.showAll();
                    break;
                  default:
                }
              });
            },
            icon: const Icon(Icons.more_vert),
            itemBuilder: (_) => [
              const PopupMenuItem(
                child: Text("Only Favorites"),
                value: FilterOption.Favorite,
              ),
              const PopupMenuItem(
                child: Text("Show All"),
                value: FilterOption.All,
              ),
            ],
          )
        ],
      ),
      body: ProductsGrid(
        showFavs: _showOnlyFavorites,
      ),
    );
  }
}

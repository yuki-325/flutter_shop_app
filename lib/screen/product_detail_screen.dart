import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products.dart';

class ProductDetailScreen extends StatelessWidget {
  static const routeName = "/product-detail";

  const ProductDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context)!.settings.arguments as String;

    /**
     * NOTE 引数listenの説明
     * true : 変更が notify されるとリビルドが起こる
     * false: 値の変更に応じた処理（表示更新など）が起こらなくなる
     */
    final loadProducts = Provider.of<Products>(
      context,
      listen: false,
    );
    final loadProduct = loadProducts.findById(id: productId);

    return Scaffold(
      // appBar: AppBar(
      //   title: Text(loadProduct.title),
      // ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(loadProduct.title),
              background: Hero(
                // NOTE ここは呼び出し元と同じじゃないとだめ
                tag: loadProduct.id,
                child: Image.network(
                  loadProduct.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(
                height: 10,
              ),
              Text(
                "\$${loadProduct.price}",
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                width: double.infinity,
                child: Text(
                  loadProduct.description,
                  textAlign: TextAlign.center,
                  softWrap: true,
                ),
              ),
              const SizedBox(
                height: 800,
              )
            ]),
          )
        ],
      ),
    );
  }
}

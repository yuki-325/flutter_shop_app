import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/product.dart';
import 'package:shop_app/providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = "/edit-product";

  const EditProductScreen({Key? key}) : super(key: key);

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _form = GlobalKey<FormState>();
  var _isInit = true;
  var _isLoading = false;
  var _editedProduct = Product(
    id: "",
    title: "",
    description: "",
    price: 0,
    imageUrl: "",
  );
  var _formInitalData = {
    "title": "",
    "description": "",
    "price": "",
    "imageUrl": "",
  };
  var _saveProductData = {
    "id": "",
    "title": "",
    "description": "",
    "price": "",
    "imageUrl": "",
  };

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context)!.settings.arguments as String;
      if (productId.isNotEmpty) {
        // 更新の場合
        _editedProduct = Provider.of<Products>(context).findById(id: productId);
        _formInitalData = {
          "title": _editedProduct.title,
          "description": _editedProduct.description,
          "price": _editedProduct.price.toString(),
          // "imageUrl": _editedProduct.imageUrl,
          "imageUrl": "",
        };
        _saveProductData = {
          "id": _editedProduct.id,
          "title": _editedProduct.title,
          "description": _editedProduct.description,
          "price": _editedProduct.price.toString(),
          // "imageUrl": _editedProduct.imageUrl,
          "imageUrl": "",
        };
        _imageUrlController.text = _editedProduct.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlFocusNode.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    final imageUrl = _imageUrlController.text;
    if (!_imageUrlFocusNode.hasFocus) {
      if ((!imageUrl.startsWith("http") && imageUrl.startsWith("https")) ||
          (!imageUrl.endsWith(".png") &&
              !imageUrl.endsWith(".jpg") &&
              !imageUrl.endsWith(".jpeg"))) {
        return;
      }
      setState(() {});
    }
  }

  void _saveForm() {
    final productsData = Provider.of<Products>(context, listen: false);
    final isValid = _form.currentState?.validate();
    if (!(isValid!)) {
      return;
    }
    _form.currentState?.save();
    setState(() => _isLoading = true);

    _editedProduct = Product(
      id: _saveProductData["id"]!,
      title: _saveProductData["title"] ?? "",
      description: _saveProductData["description"]!,
      price: double.parse(_saveProductData["price"]!),
      imageUrl: _saveProductData["imageUrl"]!,
      isFavorite: _editedProduct.isFavorite,
    );

    if (_editedProduct.id.isEmpty) {
      // 新規追加
      productsData.addProduct(_editedProduct).catchError((error) {
        // CHECK showDialog<void>だとだめだった
        // ignore: prefer_void_to_null
        return showDialog<Null>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("An error occurred!"),
            content: const Text("Something went wrong."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Okay"),
              )
            ],
          ),
        );
      }).then((_) {
        setState(() => _isLoading = false);
        Navigator.of(context).pop();
      });
    } else {
      // 更新
      productsData.updateProduct(_editedProduct.id, _editedProduct);
      setState(() => _isLoading = false);
      Navigator.of(context).pop();
    }
    // Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Product"),
        actions: [
          IconButton(
            onPressed: _saveForm,
            icon: const Icon(Icons.save),
          )
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _form,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _formInitalData["title"],
                      decoration: const InputDecoration(labelText: "Title"),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                      validator: (titleValue) {
                        if (titleValue!.isEmpty) {
                          return "Please provide a title value";
                        }
                        return null;
                      },
                      onSaved: (titleValue) {
                        _saveProductData["title"] = titleValue!;
                      },
                    ),
                    TextFormField(
                      initialValue: _formInitalData["price"],
                      decoration: const InputDecoration(labelText: "Price"),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      focusNode: _priceFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_descriptionFocusNode);
                      },
                      validator: (priceValue) {
                        if (priceValue!.isEmpty) {
                          return "Please enter a price.";
                        }
                        if (double.tryParse(priceValue) == null) {
                          return "Please enter a valid number.";
                        }
                        if (double.parse(priceValue) <= 0) {
                          return "Please enter a number greater than zero.";
                        }
                        return null;
                      },
                      onSaved: (priceValue) {
                        _saveProductData["price"] = priceValue!;
                      },
                    ),
                    TextFormField(
                      initialValue: _formInitalData["description"],
                      decoration:
                          const InputDecoration(labelText: "Description"),
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      focusNode: _descriptionFocusNode,
                      validator: (descriptionValue) {
                        if (descriptionValue!.isEmpty) {
                          return "Please enter a description.";
                        }
                        if (descriptionValue.length < 10) {
                          return "Should be at least 10 characters long.";
                        }
                        return null;
                      },
                      onSaved: (descriptionValue) {
                        _saveProductData["description"] = descriptionValue!;
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                            width: 100,
                            height: 100,
                            margin: const EdgeInsets.only(top: 8, right: 10),
                            decoration: BoxDecoration(
                              border: Border.all(width: 1, color: Colors.grey),
                            ),
                            child: _imageUrlController.text.isEmpty
                                ? const Text("Enter a URL")
                                : FittedBox(
                                    child:
                                        Image.network(_imageUrlController.text),
                                    fit: BoxFit.cover,
                                  )),
                        Expanded(
                          child: TextFormField(
                            // NOTE controllerがる場合はinitialValueは設定できないらしい
                            // controllerのtextに直接値を設定する必要がある
                            // initialValue: _initValues["imageUrl"],
                            decoration:
                                const InputDecoration(labelText: "Image URL"),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            controller: _imageUrlController,
                            focusNode: _imageUrlFocusNode,
                            onFieldSubmitted: (_) {
                              _saveForm();
                            },
                            validator: (imageUrlValue) {
                              if (imageUrlValue!.isEmpty) {
                                return "Please enter an image URL.";
                              }
                              return null;
                            },
                            onSaved: (imageUrlValue) {
                              _saveProductData["imageUrl"] = imageUrlValue!;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

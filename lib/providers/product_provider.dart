import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

class ProductProvider with ChangeNotifier {
  String? selectedCategory;
  String? selectedSubCategory;
  String? categoryImage;
  File? image;
  String? pickerError;
  String? shopName;
  String? productUrl;

  selectCategory(mainCategory, categoryImage) {
    selectedCategory = mainCategory;
    this.categoryImage = categoryImage;
    notifyListeners();
  }

  selectSubCategory(selected) {
    selectedSubCategory = selected;
    notifyListeners();
  }

  getShopName(shopName) {
    this.shopName = shopName;
  }

  resetProvider() {
    //remove all the existing data before update next product
    selectedCategory = null;
    selectedSubCategory = null;
    categoryImage = null;
    image = null;
    productUrl = null;
  }

  //upload product image
  Future uploadProductImage(filePath, productName) async {
    File file = File(filePath);
    var timeStamp = Timestamp.now().millisecondsSinceEpoch;
    FirebaseStorage _storage = FirebaseStorage.instance;
    try {
      await _storage
          .ref('productImage/$shopName/$productName$timeStamp')
          .putFile(file);
    } on FirebaseException catch (e) {
      // e.g, e.code == 'canceled'
      print(e.code);
    }
    String downloadURL = await _storage
        .ref('productImage/$shopName/$productName$timeStamp')
        .getDownloadURL();
    productUrl = downloadURL;
    notifyListeners();
    return downloadURL;
  }

  Future<File?> getProductImage() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 20);
    if (pickedFile != null) {
      image = File(pickedFile.path);
      notifyListeners();
    } else {
      pickerError = 'No image selected.';
      print('No image selected.');
      notifyListeners();
    }
    return image;
  }

  alertDialog({context, title, content}) {
    showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              CupertinoDialogAction(
                child: const Text(
                  'OK',
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  //save product data to firestore
  Future<void> saveProductDataToDb({
    seller,
    productName,
    description,
    price,
    comparedPrice,
    collection,
    brand,
    sku,
    category,
    categoryImage,
    weight,
    tax,
    stockQty,
    lowStockQty,
    context,
  }) async {
    var timeStamp =
        DateTime.now().microsecondsSinceEpoch; //this will use as product id
    User? user = FirebaseAuth.instance.currentUser;
    CollectionReference _products =
        FirebaseFirestore.instance.collection('products');
    try {
      _products.doc(timeStamp.toString()).set({
        'seller': {'shopName': shopName, 'sellerUid': user!.uid},
        'productName': productName,
        'description': description,
        'price': price,
        'comparedPrice': comparedPrice,
        'collection': collection,
        'brand': brand,
        'sku': sku,
        'category': {
          'mainCategory': selectedCategory,
          'subCategory': selectedSubCategory,
          'categoryImage': categoryImage
        },
        'weight': weight,
        'tax': tax,
        'stockQty': stockQty,
        'lowStockQty': lowStockQty,
        'published': false,
        'productId': timeStamp.toString(),
        'productImage': productUrl,
      });
      alertDialog(
        context: context,
        title: 'SAVE DATA',
        content: 'Product Details saved successfully',
      );
    } catch (e) {
      alertDialog(
        context: context,
        title: 'SAVE DATA',
        content: '${e.toString()}',
      );
    }
  }

  Future<void> updateProduct({
    productName,
    description,
    price,
    comparedPrice,
    collection,
    brand,
    sku,
    weight,
    tax,
    stockQty,
    lowStockQty,
    context,
    productId,
    image,
    category,
    subCategory,
    categoryImage,
  }) async {
    //this will use as product id
    CollectionReference _products =
        FirebaseFirestore.instance.collection('products');
    try {
      _products.doc(productId).update({
        'productName': productName,
        'description': description,
        'price': price,
        'comparedPrice': comparedPrice,
        'collection': collection,
        'brand': brand,
        'sku': sku,
        'category': {
          'mainCategory': category,
          'subCategory': subCategory,
          'categoryImage':
              categoryImage == null ? this.categoryImage : this.categoryImage
        },
        'weight': weight,
        'tax': tax,
        'stockQty': stockQty,
        'lowStockQty': lowStockQty,
        'productImage': productUrl ?? image
      });
      alertDialog(
        context: context,
        title: 'SAVE DATA',
        content: 'Product Details saved successfully',
      );
    } catch (e) {
      alertDialog(
        context: context,
        title: 'SAVE DATA',
        content: '${e.toString()}',
      );
    }
  }
}

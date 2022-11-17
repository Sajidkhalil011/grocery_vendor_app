import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:grocery_vendor_app/providers/product_provider.dart';
import 'package:grocery_vendor_app/services/firebase_services.dart';
import 'package:grocery_vendor_app/widgets/category_list.dart';
import 'package:provider/provider.dart';

class EditViewProduct extends StatefulWidget {
  final String productId;

  const EditViewProduct({Key? key, required this.productId}) : super(key: key);

  @override
  State<EditViewProduct> createState() => _EditViewProductState();
}

class _EditViewProductState extends State<EditViewProduct> {
  final FirebaseServices _services = FirebaseServices();
  final _formKey = GlobalKey<FormState>();
  List<String> _collections = [
    'Featured Products',
    'Best Selling',
    'Recently Added',
  ];
  String? dropdownValue;
  var _brandText = TextEditingController();
  var _skuText = TextEditingController();
  var _productNameText = TextEditingController();
  var _weightText = TextEditingController();
  var _priceText = TextEditingController();
  var _comparedPriceText = TextEditingController();
  var _descriptionText = TextEditingController();
  var _categoryTextController = TextEditingController();
  var _subCategoryTextController = TextEditingController();
  var _stockTextController = TextEditingController();
  var _lowStockTextController = TextEditingController();
  var _taxTextController = TextEditingController();

  DocumentSnapshot? doc;
  double? discount;
  String? image;
  String? categoryImage;
  File? _image;
  bool _visible = false;
  bool _editing=true;

  @override
  void initState() {
    getProductDetails();
    super.initState();
  }

  Future<void>getProductDetails() async {
    _services.products
        .doc(widget.productId)
        .get()
        .then((DocumentSnapshot document) {
      if (document.exists) {
        setState(() {
          doc = document;
          _brandText.text = document['brand'];
          _skuText.text = document['sku'];
          _productNameText.text = document['productName'];
          _weightText.text = document['weight'];
          _priceText.text = document['price'].toString();
          _comparedPriceText.text = document['comparedPrice'].toString();
          var difference= int.parse(_comparedPriceText.text)-double.parse(_priceText.text);
          discount = (difference/ int.parse(_comparedPriceText.text) * 100);
          image = document['productImage'];
          _descriptionText.text = document['description'];
          _categoryTextController.text = document['category']['mainCategory'];
          _subCategoryTextController.text = document['category']['subCategory'];
          dropdownValue = document['collection'];
          _stockTextController.text = document['stockQty'].toString();
          _lowStockTextController.text = document['lowStockQty'].toString();
          _taxTextController.text = document['tax'].toString();
        //  categoryImage=document['categoryImage'];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var _provider = Provider.of<ProductProvider>(context);

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          // make the button white
          color: Colors.white
        ),
        actions: [
          TextButton(
            child: Text('Edit',style: TextStyle(color: Colors.white),),
            onPressed: (){
              setState(() {
                _editing=false;
              });
            },
          ),
        ],
        backgroundColor: const Color(0xff84c225),
      ),
      bottomSheet: Container(
        height: 60,
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: (){
                  Navigator.pop(context);
                },
                child: Container(
                  color: Colors.black87,
                  child: Center(
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: AbsorbPointer(
                absorbing: _editing,
                child: InkWell(
                  onTap: (){
                    if(_formKey.currentState!.validate()){
                      EasyLoading.show(status: 'Saving...');
                      if(_image!=null){
                        //first upload new image and save data
                        _provider.uploadProductImage(_image!.path, _productNameText.text)
                            .then((url){
                           if(url!=null){
                             EasyLoading.dismiss();
                             _provider.updateProduct(
                               context: context,
                               productName: _productNameText.text,
                                 weight:_weightText.text,
                               tax: double.parse(_taxTextController.text),
                               stockQty: int.parse(_stockTextController.text),
                               sku: _skuText.text,
                               price: double.parse(_priceText.text),
                               lowStockQty: int.parse(_lowStockTextController.text),
                               description: _descriptionText.text,
                               collection: dropdownValue,
                               brand: _brandText.text,
                               comparedPrice: int.parse(_comparedPriceText.text),
                               productId: widget.productId,
                               image: image,
                               category: _categoryTextController.text,
                               subCategory: _subCategoryTextController.text,
                               categoryImage: categoryImage,
                             );
                           }
                        });
                      }else{
                        //no need to change image, so just save new data. no need to upload data
                        _provider.updateProduct(
                        context: context,
                    productName: _productNameText.text,
                    weight:_weightText.text,
                    tax: double.parse(_taxTextController.text),
                    stockQty: int.parse(_stockTextController.text),
                    sku: _skuText.text,
                    price: double.parse(_priceText.text),
                    lowStockQty: int.parse(_lowStockTextController.text),
                    description: _descriptionText.text,
                    collection: dropdownValue,
                    brand: _brandText.text,
                    comparedPrice: int.parse(_comparedPriceText.text),
                    productId: widget.productId,
                    image: image,
                    category: _categoryTextController.text,
                    subCategory: _subCategoryTextController.text,
                    categoryImage: categoryImage,);
                        EasyLoading.dismiss();
                      }
                      _provider.resetProvider();
                      //reset only after saving completed
                    }
                  },
                  child: Container(
                    color: Colors.pinkAccent,
                    child: Center(
                      child: Text(
                        'Save',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: doc == null
          ? Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: ListView(
                  children: [
                    AbsorbPointer(
                      absorbing: _editing,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 80,
                                height: 30,
                                child: TextFormField(
                                  controller: _brandText,
                                  decoration: InputDecoration(
                                    contentPadding:
                                        EdgeInsets.only(left: 10, right: 10),
                                    hintText: 'Brands',
                                    hintStyle: TextStyle(color: Colors.grey),
                                    border: OutlineInputBorder(),
                                    filled: true,
                                    fillColor: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(.1),
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('SKU : '),
                                  Container(
                                    width: 50,
                                    child: TextFormField(
                                      controller: _skuText,
                                      style: TextStyle(fontSize: 12),
                                      decoration: InputDecoration(
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.zero),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                            child: TextFormField(
                              controller: _productNameText,
                              style: TextStyle(fontSize: 30),
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.zero,
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 30,
                            child: TextFormField(
                              controller: _weightText,
                              style: TextStyle(fontSize: 20),
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.zero,
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 80,
                                child: TextFormField(
                                  controller: _priceText,
                                  style: TextStyle(fontSize: 18),
                                  decoration: InputDecoration(
                                      contentPadding: EdgeInsets.zero,
                                      border: InputBorder.none,
                                      prefixText: '\$'),
                                ),
                              ),
                              Container(
                                width: 80,
                                child: TextFormField(
                                    decoration: InputDecoration(
                                        contentPadding: EdgeInsets.zero,
                                        border: InputBorder.none,
                                        prefixText: '\$'),
                                    controller: _comparedPriceText,
                                    style: TextStyle(
                                        fontSize: 15,
                                        decoration: TextDecoration.lineThrough)),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3),
                                  color: Colors.red,
                                ),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 8, right: 8),
                                  child: Text(
                                    '${discount!.toStringAsFixed(0)}% Off',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Inclusive of all Taxes',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          InkWell(
                            onTap: (){
                              _provider.getProductImage().then((image){
                                setState(() {
                                  _image=image;
                                });
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: _image != null
                                  ? Image.file(_image!, height: 300,)
                                  : Image.network(image!, height: 300,),
                            ),
                          ),
                          Text(
                            'About this Product',
                            style: TextStyle(fontSize: 20),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: TextFormField(
                              maxLines: null,
                              controller: _descriptionText,
                              keyboardType: TextInputType.multiline,
                              style: TextStyle(color: Colors.grey),
                              decoration:
                                  InputDecoration(border: InputBorder.none),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20, bottom: 10),
                            child: Row(
                              children: [
                                const Text(
                                  'Category',
                                  style:
                                      TextStyle(color: Colors.grey, fontSize: 16),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: AbsorbPointer(
                                    absorbing: true,
                                    child: TextFormField(
                                      controller: _categoryTextController,
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'Select Category name';
                                        }
                                        return null;
                                      },
                                      decoration: const InputDecoration(
                                          hintText: 'not selected',
                                          labelStyle:
                                              TextStyle(color: Colors.grey),
                                          enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                            color: Colors.grey,
                                          ))),
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: _editing?false:true,
                                  child: IconButton(
                                    icon: const Icon(Icons.edit_outlined),
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return const CategoryList();
                                          }).whenComplete(() {
                                        setState(() {
                                          _categoryTextController.text =
                                              _provider.selectedCategory!;
                                          _visible = true;
                                        });
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Visibility(
                            visible: _visible,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 10, bottom: 20),
                              child: Row(
                                children: [
                                  const Text(
                                    'Sub-Category',
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 16),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: AbsorbPointer(
                                      absorbing: true,
                                      child: TextFormField(
                                        controller: _subCategoryTextController,
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return 'Select Sub-Category name';
                                          }
                                          return null;
                                        },
                                        decoration: const InputDecoration(
                                            hintText: 'not selected',
                                            labelStyle:
                                                TextStyle(color: Colors.grey),
                                            enabledBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(
                                              color: Colors.grey,
                                            ))),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined),
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return const SubCategoryList();
                                          }).whenComplete(() {
                                        setState(() {
                                          _subCategoryTextController.text =
                                              _provider.selectedSubCategory!;
                                        });
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            child: Row(
                              children: [
                                const Text(
                                  'Collection',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                DropdownButton<String>(
                                  hint: const Text('Select Collection'),
                                  value: dropdownValue,
                                  icon: const Icon(Icons.arrow_drop_down),
                                  onChanged: (String? value) {
                                    setState(() {
                                      dropdownValue = value;
                                    });
                                  },
                                  items: _collections
                                      .map<DropdownMenuItem<String>>(
                                          (String? value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value!),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Text('Stock :'),
                              Expanded(
                                child: TextFormField(
                                  controller: _stockTextController,
                                  style: TextStyle(color: Colors.grey),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.zero,
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text('Low Stock :'),
                              Expanded(
                                child: TextFormField(
                                  controller: _lowStockTextController,
                                  style: TextStyle(color: Colors.grey),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.zero,
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text('Tax %:'),
                              Expanded(
                                child: TextFormField(
                                  controller: _taxTextController,
                                  style: TextStyle(color: Colors.grey),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.zero,
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 60,),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

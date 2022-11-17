import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:grocery_vendor_app/providers/product_provider.dart';
import 'package:grocery_vendor_app/widgets/category_list.dart';
import 'package:provider/provider.dart';

class AddNewProduct extends StatefulWidget {
  static const String id = 'addnewproduct-screen';

  const AddNewProduct({Key? key}) : super(key: key);

  @override
  State<AddNewProduct> createState() => _AddNewProductState();
}

class _AddNewProductState extends State<AddNewProduct> {
  final _formKey = GlobalKey<FormState>();
  final List<String> _collections = [
    'Featured Products',
    'Best Selling',
    'Recently Added',
  ];
  String? dropdownValue;
  final _categoryTextController=TextEditingController();
  final _subCategoryTextController=TextEditingController();
  final _comparedPriceTextController=TextEditingController();
  final _brandTextController=TextEditingController();
  final _lowStockTextController=TextEditingController();
  final _stockTextController=TextEditingController();
  File? _image;
  bool _visible=false;
  bool _track=false;
  String? productName;
  String? description;
  double? price;
  double? comparedPrice;
  String? sku;
  String? weight;
  double? tax;
  @override
  Widget build(BuildContext context) {
    var _provider=Provider.of<ProductProvider>(context);
    return DefaultTabController(
      length: 2,
      initialIndex: 1,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xff84c225),
        ),
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              Material(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Container(
                          child: const Text('Products/Add'),
                        ),
                      ),
                      TextButton.icon(
                        icon: const Icon(
                          Icons.save,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Save',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          if(_formKey.currentState!.validate()){
                            if(_categoryTextController.text.isNotEmpty){
                              if(_subCategoryTextController.text.isNotEmpty){
                                if(_image!=null){
                                  //image should be selected
                                  //upload image to storage
                                  EasyLoading.show(status: 'Saving...');
                                  _provider.uploadProductImage(_image!.path, productName).then((url){
                                    if(url!=null){
                                      //upload product data to firestore
                                      EasyLoading.dismiss();
                                      _provider.saveProductDataToDb(
                                        context: context,
                                        comparedPrice: int.parse(_comparedPriceTextController.text),
                                        brand:_brandTextController.text,
                                        collection: dropdownValue,
                                        description: description,
                                        lowStockQty: int.parse(_lowStockTextController.text),
                                        price: price,
                                        sku: sku,
                                        stockQty: int.parse(_stockTextController.text),
                                        tax: tax,
                                        weight: weight,
                                        productName: productName,
                                      );
                                      setState(() {
                                        //clear all the existing value after saved product
                                        _formKey.currentState!.reset();
                                        _comparedPriceTextController.clear();
                                        dropdownValue=null;
                                        _subCategoryTextController.clear();
                                        _categoryTextController.clear();
                                        _brandTextController.clear();
                                        _track=false;
                                        _image=null;
                                        _visible=false;
                                      });
                                    }else{
                                      //upload failed
                                      _provider.alertDialog(
                                        context: context,
                                        title: 'IMAGE UPLOAD',
                                        content: 'Failed to upload product image',
                                      );
                                    }
                                  });
                                }else{
                                  //image not selected
                                  _provider.alertDialog(
                                    context: context,
                                    title: 'PRODUCT IMAGE',
                                    content: 'Product Image not selected',
                                  );
                                }
                              }else{
                                _provider.alertDialog(
                                  context: context,
                                  title: 'Sub-Category',
                                  content: 'Sub-Category not selected',
                                );
                              }
                            }else{
                              _provider.alertDialog(
                                context: context,
                                title: 'Main-Category',
                                content: 'Main-Category not selected',
                              );
                            }
                          }
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xff84c225),
                        ), // Background Color
                      ),
                    ],
                  ),
                ),
              ),
              TabBar(
                indicatorColor: Theme.of(context).primaryColor,
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Colors.black54,
                tabs: const [
                  Tab(
                    text: 'General',
                  ),
                  Tab(
                    text: 'Inventory',
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: TabBarView(
                        children: [
                      ListView(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                TextFormField(
                                  validator: (value){
                                    if(value!.isEmpty){
                                      return 'Enter Product Name';
                                    }
                                    setState(() {
                                      productName=value;
                                    });
                                    return null;
                                  },
                                  decoration: const InputDecoration(
                                      labelText: 'Product Name*',
                                      labelStyle: TextStyle(color: Colors.grey),
                                      enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                        color: Colors.grey,
                                      ))),
                                ),
                                TextFormField(
                                  keyboardType: TextInputType.multiline,
                                  maxLines: 5,
                                  maxLength: 500,
                                  validator: (value){
                                    if(value!.isEmpty){
                                      return 'Enter Description';
                                    }
                                    setState(() {
                                      description=value;
                                    });
                                    return null;
                                  },
                                  decoration: const InputDecoration(
                                      labelText: 'About Product*',
                                      labelStyle: TextStyle(color: Colors.grey),
                                      enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                        color: Colors.grey,
                                      ))),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child:InkWell(
                                    onTap: (){
                                      _provider.getProductImage().then((image){
                                        setState(() {
                                          _image=image;
                                        });
                                      });
                                    },
                                  child: SizedBox(
                                    width: 150,
                                    height: 150,
                                    child: Card(
                                      child: Center(
                                        child: _image==null?const Text('Select Image'):Image.file(_image!),
                                      ),
                                    ),
                                  ),
                                  ),
                                ),
                                TextFormField(
                                  validator: (value){
                                    if(value!.isEmpty){
                                      return 'Enter Selling-Price';
                                    }
                                    setState(() {
                                      price=double.parse(value);
                                    });
                                    return null;
                                  },
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                      labelText: 'Price*',
                                      //final selling price
                                      labelStyle: TextStyle(color: Colors.grey),
                                      enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                        color: Colors.grey,
                                      ))),
                                ),
                                TextFormField(
                                  controller: _comparedPriceTextController,
                                  validator: (value){
                                    if(price!>double.parse(value!)){
                                      return 'Compared price should be higher than price';
                                    }
                                    return null;
                                  },
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                      labelText: 'Compared Price',
                                      //price before discount
                                      labelStyle: TextStyle(color: Colors.grey),
                                      enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                        color: Colors.grey,
                                      ),
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
                                TextFormField(
                                  controller: _brandTextController,
                                  decoration: const InputDecoration(
                                      labelText: 'Brand',
                                      labelStyle: TextStyle(color: Colors.grey),
                                      enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                        color: Colors.grey,
                                      ))),
                                ),
                                TextFormField(
                                  validator: (value){
                                    if(value!.isEmpty){
                                      return 'Enter SKU';
                                    }
                                    setState(() {
                                      sku=value;
                                    });
                                    return null;
                                  },
                                  decoration: const InputDecoration(
                                      labelText: 'SKU*', //item unique code
                                      labelStyle:  TextStyle(color: Colors.grey),
                                      enabledBorder: UnderlineInputBorder(
                                          borderSide:  BorderSide(
                                        color: Colors.grey,
                                      ))),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 20, bottom: 10),
                                  child: Row(
                                    children: [
                                      const Text(
                                        'Category',
                                        style: TextStyle(color: Colors.grey,fontSize: 16),
                                      ),
                                      const SizedBox(width: 10,),
                                      Expanded(
                                        child: AbsorbPointer(
                                          absorbing: true,
                                          child: TextFormField(
                                            controller: _categoryTextController,
                                            validator: (value){
                                              if(value!.isEmpty){
                                                return 'Select Category name';
                                              }
                                              return null;
                                            },
                                            decoration: const InputDecoration(
                                                hintText: 'not selected',
                                                labelStyle:  TextStyle(color: Colors.grey),
                                                enabledBorder: UnderlineInputBorder(
                                                    borderSide:  BorderSide(
                                                      color: Colors.grey,
                                                    )
                                                )
                                            ),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined),
                                        onPressed: (){
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context){
                                              return const CategoryList();
                                            }
                                          ).whenComplete((){
                                            setState(() {
                                              _categoryTextController.text=_provider.selectedCategory!;
                                              _visible=true;
                                            });
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible: _visible,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 10,bottom: 20),
                                    child: Row(
                                      children: [
                                        const Text('Sub-Category',style:  TextStyle(color: Colors.grey,fontSize: 16),),
                                        const SizedBox(width: 10,),
                                        Expanded(
                                          child: AbsorbPointer(
                                            absorbing: true,
                                            child: TextFormField(
                                              controller: _subCategoryTextController,
                                              validator: (value){
                                                if(value!.isEmpty){
                                                  return 'Select Sub-Category name';
                                                }
                                                return null;
                                              },
                                              decoration: const InputDecoration(
                                                  hintText: 'not selected',
                                                  labelStyle:  TextStyle(color: Colors.grey),
                                                  enabledBorder: UnderlineInputBorder(
                                                      borderSide:  BorderSide(
                                                        color: Colors.grey,
                                                      )
                                                  )
                                              ),
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.edit_outlined),
                                          onPressed: (){
                                            showDialog(
                                                context: context,
                                                builder: (BuildContext context){
                                                  return const SubCategoryList();
                                                }
                                            ).whenComplete((){
                                              setState(() {
                                                _subCategoryTextController.text=_provider.selectedSubCategory!;
                                              });
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                TextFormField(
                                  validator: (value){
                                    if(value!.isEmpty){
                                      return 'Enter Weight';
                                    }
                                    setState(() {
                                      weight=value;
                                    });
                                    return null;
                                  },
                                  decoration: const InputDecoration(
                                      labelText: 'Weight. eg:- Kg,gm,etc', //item unique code
                                      labelStyle:  TextStyle(color: Colors.grey),
                                      enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.grey,
                                          ))),
                                ),
                                TextFormField(
                                  validator: (value){
                                    if(value!.isEmpty){
                                      return 'Enter Tax %';
                                    }
                                    setState(() {
                                      tax=double.parse(value);
                                    });
                                    return null;
                                  },
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                      labelText: 'Tax %', //item unique code
                                      labelStyle:  TextStyle(color: Colors.grey),
                                      enabledBorder: UnderlineInputBorder(
                                          borderSide:  BorderSide(
                                            color: Colors.grey,
                                          ))),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            SwitchListTile(
                              title: const Text('Track Inventory'),
                              activeColor: Theme.of(context).primaryColor,
                              subtitle: const Text('Switch ON to track Inventory',style: TextStyle(color: Colors.grey,fontSize: 12),),
                              value: _track,
                              onChanged: (selected){
                                setState(() {
                                  _track=!_track;
                                });
                              },
                            ),
                            Visibility(
                              visible: _track,
                              child: SizedBox(
                                height: 300,
                                width: double.infinity,
                              child: Card(
                                elevation: 3,
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    children: [
                                      TextFormField(
                                        controller: _stockTextController,
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                            labelText: 'Inventory Quantity*', //item unique code
                                            labelStyle:  TextStyle(color: Colors.grey),
                                            enabledBorder:  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Colors.grey,
                                                ))),
                                      ),
                                      TextFormField(
                                        controller: _lowStockTextController,
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                            labelText: 'Inventory low stock quantity*', //item unique code
                                            labelStyle:  TextStyle(color: Colors.grey),
                                            enabledBorder:  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Colors.grey,
                                                ))),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

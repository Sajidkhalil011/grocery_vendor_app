import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:grocery_vendor_app/providers/product_provider.dart';
import 'package:grocery_vendor_app/widgets/banner_card.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../services/firebase_services.dart';
class BannerScreen extends StatefulWidget {
  const BannerScreen({Key? key}) : super(key: key);
  @override
  State<BannerScreen> createState() => _BannerScreenState();
}
class _BannerScreenState extends State<BannerScreen> {
  FirebaseServices _services=FirebaseServices();
  bool _visible=false;
  File? _image;
  var _imagePathText=TextEditingController();

  @override
  Widget build(BuildContext context) {
    var _provider=Provider.of<ProductProvider>(context);
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          BannerCard(),
          Divider(thickness: 3,),
          SizedBox(height: 20,),
          Container(child: Center(child: Text('ADD NEW BANNER',style: TextStyle(fontWeight: FontWeight.bold),),
          ),
          ),
          Container(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 150,
                    width: MediaQuery.of(context).size.width,
                    child: Card(
                      color: Colors.grey[200],
                      child: _image!=null?Image.file(_image!,fit: BoxFit.fill,):Center(child: Text('No Image Selected'),),
                    ),
                  ),
                  TextFormField(
                    controller: _imagePathText,
                    enabled: false,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20,),
                  Visibility(
                    visible: _visible?false:true,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            child: Text('Add New Banner',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                            onPressed: (){
                              setState(() {
                                _visible=true;
                              });
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: const Color(0xff84c225),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: _visible,
                    child: Container(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  child: Text('Upload Image',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                                  onPressed: (){
                                    setState(() {
                                      getBannerImage().then((value){
                                        if(_image!=null){
                                          setState(() {
                                            _imagePathText.text=_image!.path;
                                          });
                                        }
                                      });
                                    });
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor: const Color(0xff84c225),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: AbsorbPointer(
                                  absorbing: _image!=null?false:true,
                                  child: TextButton(
                                    child: Text('Save',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                                    onPressed: (){
                                      EasyLoading.show(status: 'Saving...');
                                      uploadBannerImage(_image!.path,_provider.shopName).then((url){
                                        if(url!=null){
                                          //save banner url to firestore
                                          _services.saveBanner(url);
                                          setState(() {
                                            _imagePathText.clear();
                                            _image=null;
                                          });
                                          EasyLoading.dismiss();
                                          _provider.alertDialog(
                                            context: context,
                                            title: 'Banner Upload',
                                            content: 'Banner Image Uploaded Successfully..',
                                          );
                                        }else{
                                          EasyLoading.dismiss();
                                          _provider.alertDialog(
                                            context: context,
                                            title: 'Banner Upload',
                                            content: 'Banner Upload Failed',
                                          );
                                        }
                                      });
                                    },
                                    style: TextButton.styleFrom(
                                      backgroundColor:_image!=null?Color(0xff84c225):Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  child: Text('Cancel',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                                  onPressed: (){
                                    setState(() {
                                      _visible=false;
                                      _imagePathText.clear();
                                      _image=null;
                                    });
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor:  Colors.black54,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      )
    );
  }
  Future<File?> getBannerImage()async{
    final picker=ImagePicker();
    final pickedFile=await picker.pickImage(source: ImageSource.gallery,imageQuality: 20);
    if(pickedFile!=null){
      setState(() {
        _image=File(pickedFile.path);
      });
    }else{
      print('No image selected.');
    }
    return _image;
  }
  Future uploadBannerImage(filePath,shopName)async {
    File file = File(filePath);//need file path to upload, we already have inside provider
    var timeStamp=Timestamp.now().millisecondsSinceEpoch;
    FirebaseStorage _storage=FirebaseStorage.instance;
    try {
      await _storage.ref('vendorbanner/$shopName/$timeStamp').putFile(file);
    } on FirebaseException catch (e) {
      // e.g, e.code == 'canceled'
      print(e.code);
    }
    String downloadURL= await _storage
        .ref('vendorbanner/$shopName/$timeStamp').getDownloadURL();
    return downloadURL;
  }
}

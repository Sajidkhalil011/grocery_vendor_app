import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:grocery_vendor_app/providers/auth_provider.dart';
import 'package:grocery_vendor_app/screens/home_screen.dart';
import 'package:provider/provider.dart';

import '../screens/login_screen.dart';


class RegisterForm extends StatefulWidget {
  const RegisterForm({Key? key}) : super(key: key);

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailTextController=TextEditingController();
  final _passwordTextController=TextEditingController();
  final _cPasswordTextController=TextEditingController();
  final _addressTextController=TextEditingController();
  final _nameTextController=TextEditingController();
  final _dialogTextController=TextEditingController();

   String? email;
  late String password;
  late String shopName;
  late String mobile;
  bool _isLoading=false;

  Future uploadFile(filePath)async {
    File file = File(filePath);
   FirebaseStorage _storage=FirebaseStorage.instance;
    try {
      await _storage.ref('uploads/shopProfilePic/${_nameTextController.text}').putFile(file);
    } on FirebaseException catch (e) {
      // e.g, e.code == 'canceled'
      print(e.code);
    }
    String downloadURL= await _storage
    .ref('uploads/shopProfilePic/${_nameTextController.text}')
    .getDownloadURL();
    return downloadURL;
  }

  @override
  Widget build(BuildContext context) {
    final _authData=Provider.of<AuthProvider>(context);
    scaffoldMessage(message){
      return ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text(message)));
    }
    return _isLoading ? CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
    ): Form(
      key: _formKey,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: TextFormField(
              validator: (value){
                if(value!.isEmpty){
                  return 'Enter Shop Name';
                }
                setState(() {
                  _nameTextController.text=value;
                });
                setState(() {
                  shopName=value;
                });
                return null;
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.add_business),
                labelText: 'Business Name',
                contentPadding: EdgeInsets.zero,
                enabledBorder: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 2,color: Theme.of(context).primaryColor
                  )
                ),
                focusColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: TextFormField(
              keyboardType: TextInputType.phone,
              maxLength: 10,
              validator: (value){
                if(value!.isEmpty){
                  return 'Enter Phone Number';
                }
                setState(() {
                  mobile=value;
                });
                return null;
              },
              decoration: InputDecoration(
                prefixText: '+92',
                prefixIcon: Icon(Icons.phone_android),
                labelText: 'Phone Number',
                contentPadding: EdgeInsets.zero,
                enabledBorder: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        width: 2,color: Theme.of(context).primaryColor
                    )
                ),
                focusColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: TextFormField(
              controller: _emailTextController,
              keyboardType: TextInputType.emailAddress,
              validator: (value){
                if(value!.isEmpty){
                  return 'Enter Email';
                }
                final bool _isvalid=EmailValidator.validate(_emailTextController.text);
                if(!_isvalid){
                  return 'Invalid Email Format';
                }
                setState(() {
                  email=value;
                });
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.email_outlined),
                labelText: 'Email',
                contentPadding: EdgeInsets.zero,
                enabledBorder: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        width: 2,color: Theme.of(context).primaryColor
                    )
                ),
                focusColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: TextFormField(
              obscureText: true,
              validator: (value){
                if(value!.isEmpty){
                  return 'Enter Password';
                }
                if(value.length<6){
                  return 'Minimum 6 Characters';
                }
                setState(() {
                  password=value;
                });
                return null;
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.vpn_key_outlined),
                labelText: 'Password',
                contentPadding: EdgeInsets.zero,
                enabledBorder: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        width: 2,color: Theme.of(context).primaryColor
                    )
                ),
                focusColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: TextFormField(
              obscureText: true,
              validator: (value){
                if(value!.isEmpty){
                  return 'Enter Confirm Password';
                }
                if(value.length<6){
                  return 'Minimum 6 Characters';
                }
                if(_passwordTextController.text != _cPasswordTextController.text){
                  return 'Password doesn\'t match';
                }
                return null;
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.vpn_key_outlined),
                labelText: 'Confirm Password',
                contentPadding: EdgeInsets.zero,
                enabledBorder: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        width: 2,color: Theme.of(context).primaryColor
                    )
                ),
                focusColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: TextFormField(
              maxLines: 6,
              controller: _addressTextController,
              validator: (value){
                if(value!.isEmpty){
                  return 'Please press Navigation Button';
                }
                if(_authData.shopLatitude==null){
                return 'Please press Navigation Button';
                }
                return null;
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.contact_mail_outlined),
                labelText: 'Business Location',
                suffixIcon: IconButton(
                  icon: Icon(Icons.location_searching),
                  onPressed: (){
                    _addressTextController.text='Locating...\n Please wait...';
                    _authData.getCurrentAddress().then((address){
                      if(address!=null){
                        setState(() {
                          _addressTextController.text='${_authData.placeName}\n${_authData.stAddress}';
                        });
                      }else{
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Could not find location.. Try again')),
                        );
                      }
                    });
                  },),
                enabledBorder: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        width: 2,color: Theme.of(context).primaryColor
                    )
                ),
                focusColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: TextFormField(
              onChanged: (value){
                _dialogTextController.text=value;
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.comment),
                labelText: 'Shop Dialog',
                contentPadding: EdgeInsets.zero,
                enabledBorder: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        width: 2,color: Theme.of(context).primaryColor
                    )
                ),
                focusColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
          const SizedBox(
            height: 20,),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: (){
                    if(_authData.isPicAvail==true){ //first will validate profile pic
                      if (_formKey.currentState!.validate()) {//then will validate form
                        setState(() {
                          _isLoading=true;
                        });
                        _authData.registerVendor(email, password).then((credential){
                          if(credential?.user?.uid!=null){
                            //user registered
                            //now will upload profile pic to firestorage
                            uploadFile(_authData.image!.path).then((url)  {
                              if(url!=null){
                                //save vendor details to Db
                                _authData.saveVendorDataToDb(
                                  url: url,
                                  mobile: mobile,
                                  shopName: shopName,
                                  dialog: _dialogTextController.text,
                                  email: _emailTextController.text
                                );
                                  setState(() {
                                    _isLoading=false;
                                  });
                                  Navigator.pushReplacementNamed(context, HomeScreen.id);
                                //after finish all the process will navigate to homescreen
                              }else{
                                scaffoldMessage('Failed to upload Shop Profile Pic');
                              }
                            });
                          }else{
                            scaffoldMessage(_authData.error);
                          }
                        });

                      }
                    }else{
                      scaffoldMessage('Shop profile need to be added');
                    }
                    },
                  style: TextButton.styleFrom(
                      backgroundColor: Color(0xff84c225) // Text Color
                  ),
                  child: Text('Register',style: TextStyle(color: Colors.white,),),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextButton(
                child:RichText(
                  text: TextSpan(
                      text: '',
                      children: [
                        TextSpan(text: 'Already have an account ? ',style: TextStyle(color: Colors.black)),
                        TextSpan(text: 'Login',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.red)),
                      ]
                  ),
                ),
                onPressed: (){
                  Navigator.pushNamed(context, LoginScreen.id);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

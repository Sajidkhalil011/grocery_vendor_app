import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';

class AuthProvider extends ChangeNotifier{
    File? image;
   bool isPicAvail=false;
   String pickerError='';
   String error='';
    double? shopLatitude;
    double? shopLongitude;
    String? stAddress;
    String? placeName;
    String? email;
    String? password;


      Future<File?> getImage()async{
    final picker=ImagePicker();
    final pickedFile=await picker.pickImage(source: ImageSource.gallery,imageQuality: 20);
    if(pickedFile!=null){
      image=File(pickedFile.path);
      notifyListeners();
    }else{
      pickerError='No image selected.';
      print('No image selected.');
      notifyListeners();
    }
    return image;
  }

  Future getCurrentAddress()async{

    Location location =  Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    _locationData = await location.getLocation();
    shopLatitude=_locationData.latitude!;
    shopLongitude=_locationData.longitude!;
    notifyListeners();

    final coordinates =  Coordinates(_locationData.latitude, _locationData.longitude);
    var addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
      var shopAddress = addresses.first;
   stAddress=shopAddress.addressLine;
    placeName=shopAddress.featureName;
    notifyListeners();
    return shopAddress;
  }

//register vendor using email
  Future<UserCredential?>registerVendor(email,password)async {
        email=email;
        notifyListeners();
         UserCredential? userCredential;
    try {
      userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        error='The password provided is too weak.';
        notifyListeners();
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        error='The account already exists for that email.';
        notifyListeners();
        print('The account already exists for that email.');
      }
    } catch (e) {
      error=e.toString();
      notifyListeners();
      print(e);
    }
    return userCredential;
  }


  //login
  Future<UserCredential?>loginVendor(email,password)async{
        email = email;
    notifyListeners();
    UserCredential? userCredential;
    try {
      userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      error=e.code;
      notifyListeners();
    } catch (e) {
      notifyListeners();
      print(e);
    }
    return userCredential;
  }


  //reset password
  Future<UserCredential?>resetPassword(email)async{
    email = email;
    notifyListeners();
    UserCredential? userCredential;
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      error=e.code;
      notifyListeners();
    } catch (e) {
      error='Wrong-Password';
      notifyListeners();
      print(e);
    }
    return userCredential;
  }



  // vendor data to firestore
Future<void>saveVendorDataToDb({url, shopName, mobile, dialog,email})async {
        User? user=FirebaseAuth.instance.currentUser;
        DocumentReference _vendors=FirebaseFirestore.instance.collection('vendors').doc(user!.uid);
        _vendors.set({
          'uid':user.uid,
          'shopName':shopName,
          'mobile':mobile,
          'email':this.email,
          'dialog':dialog,
          'address':'${placeName}: ${stAddress}',
          'location':GeoPoint(shopLatitude!, shopLongitude!),
          'shopOpen':true,
          'rating': 0.00,
          'totalRating':0,
          'isTopPicked':false,
          'imageUrl':url,
          'accVerified':false, //only verified vendor can send their product
        });
        return;
}

}
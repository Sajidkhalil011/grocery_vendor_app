import 'package:flutter/material.dart';
import 'package:grocery_vendor_app/screens/login_screen.dart';
import 'package:grocery_vendor_app/widgets/image_picker.dart';
import 'package:grocery_vendor_app/widgets/register_form.dart';

class RegisterScreen extends StatelessWidget {
  static const String id= 'register-screen';
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                ShopPicCard(),
                RegisterForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

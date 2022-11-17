import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:grocery_vendor_app/providers/auth_provider.dart';
import 'package:grocery_vendor_app/providers/order_provider.dart';
import 'package:grocery_vendor_app/providers/product_provider.dart';
import 'package:grocery_vendor_app/screens/add_edit_coupon_screen.dart';
import 'package:grocery_vendor_app/screens/add_newproduct_screen.dart';
import 'package:grocery_vendor_app/screens/home_screen.dart';
import 'package:grocery_vendor_app/screens/login_screen.dart';
import 'package:grocery_vendor_app/screens/order_screen.dart';
import 'package:grocery_vendor_app/screens/splash_screen.dart';
import 'package:grocery_vendor_app/widgets/reset_password_screen.dart';
import 'package:provider/provider.dart';
import 'screens/register_screen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MultiProvider(
      providers: [
       ListenableProvider (create: (_)=>AuthProvider()),
        ListenableProvider (create: (_)=>ProductProvider()),
        ListenableProvider (create: (_)=>OrderProvider()),
      ],
    child: const MyApp(),
  ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: const Color(0xff84c225),
          fontFamily: 'Lato'
      ),
      builder: EasyLoading.init(),
      initialRoute: SplashScreen.id,routes: {
        SplashScreen.id:(context)=> const SplashScreen(),
        RegisterScreen.id:(context)=> const RegisterScreen(),
        HomeScreen.id:(context)=> const HomeScreen(),
        LoginScreen.id:(context)=> const LoginScreen(),
        ResetPassword.id:(context)=> const ResetPassword(),
        AddNewProduct.id:(context)=> const AddNewProduct(),
        OrderScreen.id:(context)=> const OrderScreen(),

    },
    );
  }
}



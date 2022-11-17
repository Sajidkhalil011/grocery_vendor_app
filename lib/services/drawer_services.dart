import 'package:grocery_vendor_app/screens/add_edit_coupon_screen.dart';
import 'package:grocery_vendor_app/screens/banner_screen.dart';
import 'package:grocery_vendor_app/screens/coupon_screen.dart';
import 'package:grocery_vendor_app/screens/dashboard_screen.dart';
import 'package:grocery_vendor_app/screens/order_screen.dart';
import 'package:grocery_vendor_app/screens/product_screen.dart';

class DrawerServices{
   drawerScreen(title){
    if(title=='Dashboard'){
      return const MainScreen();
    }
    if(title=='Product'){
      return const ProductScreen();
    }
    if(title=='Banner'){
      return const BannerScreen();
    }
    if(title=='Coupons'){
      return  const CouponScreen();
    }
    if(title=='Orders'){
      return  const OrderScreen();
    }
    return const MainScreen();
  }
}
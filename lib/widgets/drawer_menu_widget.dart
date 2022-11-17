import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grocery_vendor_app/providers/product_provider.dart';
import 'package:provider/provider.dart';
class MenuWidget extends StatefulWidget {
  final Function(String)? onItemClick;
  const MenuWidget({Key? key, this.onItemClick}) : super(key: key);
  @override
  State<MenuWidget> createState() => _MenuWidgetState();
}
class _MenuWidgetState extends State<MenuWidget> {
  User? user = FirebaseAuth.instance.currentUser;
  var vendorData;

  @override
  void initState() {
    getVendorData();
    super.initState();
  }
  Future<DocumentSnapshot<Map<String, dynamic>>>getVendorData()async{
    var result=await FirebaseFirestore.instance.collection('vendors').doc(user!.uid).get();
    setState(() {
      vendorData=result;
    });
    return result;
  }
  @override
  Widget build(BuildContext context) {
    var _provider=Provider.of<ProductProvider>(context);
    _provider.getShopName(vendorData!=null?vendorData.data()['shopName']:'');
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
           const SizedBox(
            height: 4,
          ),
           Padding(
             padding: const EdgeInsets.all(10.0),
             child: FittedBox(
               child: Row(
                 children:  [
                   CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.grey,
                    child: CircleAvatar(
                      radius: 30,
                      backgroundImage:vendorData!=null?NetworkImage(vendorData.data()['imageUrl']):null
                    ),
          ),
                   const SizedBox(width: 10,),
                  Text(
                     vendorData!=null?vendorData.data()['shopName']:'ShopName',
                     style: const TextStyle(
                         color: Colors.black,
                         fontWeight: FontWeight.bold,
                         fontSize: 25,
                   ),
                   ),
                 ],
               ),
             ),
           ),
           const SizedBox(
            height: 10,
          ),
          sliderMenuItem(
              title: 'Dashboard', iconData: Icons.dashboard_outlined, onTap: widget.onItemClick),
          sliderMenuItem(
              title: 'Product', iconData: Icons.shopping_bag_outlined, onTap: widget.onItemClick),
          sliderMenuItem(
              title: 'Banner', iconData: CupertinoIcons.photo, onTap: widget.onItemClick),
          sliderMenuItem(
              title: 'Coupons', iconData: CupertinoIcons.gift, onTap: widget.onItemClick),
          sliderMenuItem(
              title: 'Orders', iconData: CupertinoIcons.cart, onTap: widget.onItemClick),
          sliderMenuItem(
              title: 'Reports', iconData: Icons.stacked_bar_chart, onTap: widget.onItemClick),
          sliderMenuItem(
              title: 'Setting', iconData: Icons.settings_outlined, onTap: widget.onItemClick),
          sliderMenuItem(
              title: 'LogOut',
              iconData: Icons.arrow_back_ios,
              onTap: widget.onItemClick),
        ],
      ),
    );
  }

    sliderMenuItem({ String? title, IconData? iconData, Function? onTap}){
    return InkWell(
      child: Container(
         decoration: const BoxDecoration(
             border:  Border(
               bottom:  BorderSide(
                 color: Colors.grey,
               ),
             ),
         ),
        child: SizedBox(
          height: 40,
          child: Padding(
            padding: const EdgeInsets.only(left:20),
            child: Row(
              children: [
                Icon(iconData,color:Colors.black54,size: 18,),
                const SizedBox(width: 10,),
                Text(title!,style: const TextStyle(color: Colors.black54,fontSize: 12),)
              ],
            ),
          ),
        ),
    ),
        onTap: (){
        widget.onItemClick!(title);
      });
     }
}




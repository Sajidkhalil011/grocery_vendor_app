import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'package:grocery_vendor_app/services/drawer_services.dart';
import 'package:grocery_vendor_app/widgets/drawer_menu_widget.dart';

class HomeScreen extends StatefulWidget {
  static const String id = 'home_screen';
   const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final DrawerServices _services=DrawerServices();
  final GlobalKey<SliderDrawerState> _key =  GlobalKey<SliderDrawerState>();
   String? title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SliderDrawer(
          appBar: SliderAppBar(
            trailing: Row(
              children: [
                IconButton(
                  onPressed: (){},
                  icon: Icon(CupertinoIcons.search),

                ),
                IconButton(
                  onPressed: (){},
                  icon: Icon(CupertinoIcons.bell),

                ),
              ],
            ),
            appBarHeight: 80,
              appBarColor: Colors.white,
              title: Text('',
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w700))),
          key: _key,
          sliderOpenSize: 250,
          slider:  MenuWidget(
            onItemClick: (title) {
              _key.currentState!.closeSlider();
              setState(() {
                this.title = title;
              });
            },
          ),
          child: _services.drawerScreen(title),
      ),
    );
  }
}

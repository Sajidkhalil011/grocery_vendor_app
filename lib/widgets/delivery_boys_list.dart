import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geolocator/geolocator.dart';
import 'package:grocery_vendor_app/services/firebase_services.dart';
import 'package:grocery_vendor_app/services/order_services.dart';
import 'package:map_launcher/map_launcher.dart';

class DeliveryBoyList extends StatefulWidget {
 final  DocumentSnapshot document;
  const DeliveryBoyList(this.document, {Key? key}) : super(key: key);

  @override
  State<DeliveryBoyList> createState() => _DeliveryBoyListState();
}
class _DeliveryBoyListState extends State<DeliveryBoyList> {
  final FirebaseServices _services = FirebaseServices();
  final OrderServices _orderServices=OrderServices();
  GeoPoint? _shopLocation;

  @override
  void initState() {
    _services.getShopDetails().then((value) {
      if (value != null) {
        if (mounted) {
          setState(() {
            _shopLocation = value['location'];
          });
        }
      } else {
        print('no data');
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: Text(
                'Select Delivery Boy',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Color(0xff84c225),
              iconTheme: IconThemeData(color: Colors.white),
            ),
            Container(
              child: StreamBuilder(
                stream: _services.boys
                    .where('accVerified', isEqualTo: true)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Something went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return ListView(
                    shrinkWrap: true,
                    children:
                        snapshot.data!.docs.map((DocumentSnapshot document) {
                      GeoPoint location = document['location'];
                      double distanceInMeters = _shopLocation == null
                          ? 0.0
                          : Geolocator.distanceBetween(
                                  _shopLocation!.latitude,
                                  _shopLocation!.longitude,
                                  location.latitude,
                                  location.longitude) /
                              1000;
                      Map<String, dynamic> data =
                          document.data()! as Map<String, dynamic>;
                      if (distanceInMeters > 10) {
                        return Container();
                        //it will only show nearest delivery boys that's within 10 km radius
                      }
                      return Column(
                        children: [
                          ListTile(
                            onTap: (){
                              EasyLoading.show(status: 'Assigning Delivery Boys');
                              _services.selectBoys(
                                orderId: widget.document.id,
                                email: document['email'],
                                phone: document['mobile'],
                                name: document['name'],
                                location: document['location'],
                                image: document['imageUrl']
                              ).then((value){
                                EasyLoading.showSuccess('Assigned Delivery Boys');
                                Navigator.pop(context);
                              });
                            },
                            leading: CircleAvatar(
                              backgroundColor: Colors.white,
                              child: Image.network(document['imageUrl']),
                            ),
                            title: Text(document['name']),
                            subtitle:
                                Text('${distanceInMeters.toStringAsFixed(0)} Km'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.map,color: Theme.of(context).primaryColor,),
                                  onPressed: (){
                                    GeoPoint location = document['location'];
                                    _orderServices.launchMap(location,document['name']);
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.phone,color: Theme.of(context).primaryColor,),
                                  onPressed: () {
                                    _orderServices.launchUrl(
                                        'tel:${document['mobile']}');
                                  }
                                ),
                              ],
                            ),
                          ),
                          Divider(height: 2,color: Colors.grey,)
                        ],
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

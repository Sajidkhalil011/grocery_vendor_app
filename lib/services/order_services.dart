import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:map_launcher/map_launcher.dart';
import '../widgets/delivery_boys_list.dart';

class OrderServices{
  CollectionReference orders=FirebaseFirestore.instance.collection('orders');

  Future<void>updateOrderStatus(documentId,status){
    var result=orders.doc(documentId).update({
      'orderStatus':status,
    });
    return result;
  }
  Color statusColor(DocumentSnapshot document){
    if(document['orderStatus']=='Accepted'){
      return Colors.blueGrey.shade400;
    }
    if(document['orderStatus']=='Rejected'){
      return Colors.red;
    }
    if(document['orderStatus']=='Picked Up'){
      return Colors.pink.shade900;
    }
    if(document['orderStatus']=='On the way'){
      return Colors.purple.shade900;
    }
    if(document['orderStatus']=='Delivered'){
      return Colors.green;
    }
    return Colors.orange;
  }

  Widget statusContainer(DocumentSnapshot document,context){
    if(document['deliveryBoy']['name'].length>1){
      return document['deliveryBoy']['image']==null ? Container() : ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.white,
          child: Image.network(document['deliveryBoy']['image']),
        ),
        title: Text(document['deliveryBoy']['name']),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: (){
                GeoPoint location = document['deliveryBoy']['location'];
                launchMap(location,document['deliveryBoy']['name']);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 8, right: 8, top: 2, bottom: 2),
                  child: Icon(
                    Icons.map,color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            InkWell(
              onTap: () => launchUrl('tel:${document['deliveryBoy']['phone']}'),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 8, right: 8, top: 2, bottom: 2),
                  child: Icon(
                    Icons.phone_in_talk,color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    if(document['orderStatus']=='Accepted'){
      return Container(
        color: Colors.grey.shade300,
        height: 50,
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              40.0, 8, 40, 8),
          child: TextButton(
            child: Text(
              'Select Delivery Boy',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              print('Assign delivery boy');
              //Delivery boys list
              showDialog(context: context, builder: (BuildContext context){
                return DeliveryBoyList(document);
              });
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors
                  .orangeAccent, // Background Color
            ),
          ),
        ),
      );
    }
    return Container(
      color: Colors.grey.shade300,
      height: 50,
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton(
                child: Text(
                  'Accept',
                  style: TextStyle(
                      color: Colors.white),
                ),
                onPressed: () {
                  showMyDialog('Accept Order',
                      'Accepted', document.id,context);
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors
                      .blueGrey, // Background Color
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: AbsorbPointer(
                absorbing:
                document['orderStatus'] ==
                    'Rejected'
                    ? true
                    : false,
                child: TextButton(
                  child: Text(
                    'Reject',
                    style: TextStyle(
                        color: Colors.white),
                  ),
                  onPressed: () {
                    showMyDialog('Reject Order',
                        'Rejected', document.id,context);
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: document['orderStatus'] ==
                        'Rejected'
                        ? Colors.grey : Colors.red,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Icon statusIcon(DocumentSnapshot document){
    if(document['orderStatus']=='Accepted'){
      return Icon(Icons.assignment_turned_in_outlined,color: statusColor(document),);
    }
    if(document['orderStatus']=='Picked Up'){
      return Icon(Icons.cases_outlined,color: statusColor(document),);
    }
    if(document['orderStatus']=='On the way'){
      return Icon(Icons.delivery_dining,color: statusColor(document),);
    }
    if(document['orderStatus']=='Delivered'){
      return Icon(Icons.shopping_bag_outlined,color: statusColor(document),);
    }
    return Icon(Icons.assignment_turned_in_outlined,color: statusColor(document),);
  }

  showMyDialog(title, status, documentId,context) {
    OrderServices _orderServices = OrderServices();
    showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(title),
            content: Text('Are you sure ? '),
            actions: [
              TextButton(
                child: Text(
                  'OK',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  EasyLoading.show(status: 'Updating Status...');
                  status == 'Accepted'
                      ? _orderServices
                      .updateOrderStatus(documentId, status)
                      .then((value) {
                    EasyLoading.showSuccess('Updated successfully');
                  })
                      : _orderServices
                      .updateOrderStatus(documentId, status)
                      .then((value) {
                    EasyLoading.showSuccess('Updated successfully');
                  });
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(
                  primary: Color(0xff84c225), // Background color
                ),
              ),
              TextButton(
                child: Text(
                  'Cancel',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(
                  primary: Color(0xff84c225), // Background color
                ),
              ),
            ],
          );
        });
  }

   launchUrl(number) async {
    if (!await launchUrl(number)) {
      throw 'Could not launch $number';
    }
  }

  launchMap(GeoPoint location,name)async{
    final availableMaps = await MapLauncher.installedMaps;
    await availableMaps.first.showMarker(
      coords: Coords(location.latitude, location.longitude),
      title: name,
    );
  }
}
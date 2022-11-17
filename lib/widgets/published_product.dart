import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grocery_vendor_app/screens/edit_view_product.dart';
import 'package:grocery_vendor_app/services/firebase_services.dart';

class PublishedProducts extends StatefulWidget {
  const PublishedProducts({Key? key}) : super(key: key);
  @override
  State<PublishedProducts> createState() => _PublishedProductsState();
}
class _PublishedProductsState extends State<PublishedProducts> {
  final FirebaseServices _services=FirebaseServices();
  @override
  Widget build(BuildContext context) {
    User? user;
    return Container(
      child: StreamBuilder(
        stream: _services.products.where('published',isEqualTo: true,).where('seller.sellerUid',isEqualTo: user?.uid).snapshots(),
        builder: (context,snapshot){
          if(snapshot.hasError){
            return const Text('Something went wrong..');
          }
          if(snapshot.connectionState==ConnectionState.waiting){
            return const Center(child: CircularProgressIndicator(),);
          }
          return SingleChildScrollView(
            child: FittedBox(
              child: DataTable(
                showBottomBorder: true,
                dataRowHeight: 60,
                headingRowColor: MaterialStateProperty.all(Colors.grey[200]),
                columns: const <DataColumn>[
                  DataColumn(label: Expanded(child: Text('Product')),),
                  DataColumn(label: Text('Image'),),
                  DataColumn(label: Text('Info'),),
                  DataColumn(label: Text('Actions'),),
                ],
                rows: _productDetails(snapshot.data,context),
              ),
            ),
          );
        },
      ),
    );
  }

  List<DataRow> _productDetails(snapshot,context){
    List<DataRow> newList=snapshot.docs.map<DataRow>((document){
      if(document!=null){
        return DataRow(
            cells: [
              DataCell(
                  Container(child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Row(
                      children: [
                        const Text('Name:',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),
                        Expanded(child: Text(document['productName'],style: const TextStyle(fontSize: 15))),
                      ],
                    ),
                    subtitle: Row(
                      children: [
                        const Text('SKU:',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12),),
                        Text(document['sku'],style: const TextStyle(fontSize: 12),),
                      ],
                    ),
                  ),)
              ),
              DataCell(
                  Container(child: Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: Row(
                      children: [
                        Image.network(document.data()['productImage'],width: 50,),
                      ],
                    ),
                  ),)
              ),
              DataCell(
                IconButton(onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>EditViewProduct(
                    productId:document.data()['productId'] ,
                  ),),);
                },icon: const Icon(Icons.info_outline),),
              ),
              DataCell(
                  popUpButton(document.data())
              ),
            ]
        );
      }
    }).toList();
    return newList;
  }

  Widget popUpButton(data,{BuildContext? context}){
    FirebaseServices _services=FirebaseServices();
    return PopupMenuButton<String>(
        onSelected: (String value){
          if(value=='unpublish'){
            _services.unPublishProduct(id:data['productId'],);
          }
        },
        itemBuilder: (BuildContext context)=><PopupMenuEntry<String>>[
          const PopupMenuItem<String>(
            value: 'unpublish',
            child: ListTile(
              leading: Icon(Icons.check),
              title: Text('Un-Publish'),
            ),),
        ]);
  }
}

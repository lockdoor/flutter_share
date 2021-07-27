import 'package:flutter/material.dart';
//import 'package:flutter_share/models/api.dart';
import 'package:flutter_share/models/share/share.dart';
//import 'package:flutter_share/providers/api.dart';
import 'package:flutter_share/providers/customers.dart';
import 'package:flutter_share/providers/share.dart';
import 'package:flutter_share/screen/share/shareAdd.dart';
import 'package:flutter_share/screen/share/shareBid/shareShowBidHome.dart';
//import 'package:flutter_share/screen/share/shareBid/shareShowBidInterrest.dart';
import 'package:provider/provider.dart';

class ShareList extends StatefulWidget {
  const ShareList({Key? key}) : super(key: key);

  @override
  _ShareListState createState() => _ShareListState();
}

class _ShareListState extends State<ShareList> {
  //late ApiModel apiModel;
  @override
  void initState() {
    super.initState();
    //apiModel = context.read<ApiProvider>().api;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer(
        builder: (context, ShareProvider provider, child) {
          final List<ShareModel> shares = context.watch<ShareProvider>().shares;
          return GridView.builder(
            itemCount: shares.length,
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
            itemBuilder: (context, index) {
              return myCard(index, provider.shares[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          if (context.read<CustomerProvider>().admin != null) {
            Route route = MaterialPageRoute(builder: (context) => ShareAdd());
            Navigator.push(context, route);
          } else {
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    scrollable: true,
                    content: Text('กรุณาตั้งค่าท้าวแชร์ก่อนสร้างแชร์'),
                  );
                });
          }
        },
      ),
    );
  }

  MaterialColor color(index) {
    List<MaterialColor> colors = <MaterialColor>[
      Colors.red,
      Colors.green,
      Colors.purple,
      Colors.yellow,
      Colors.pink
    ];
    if (index + 1 < colors.length) {
      return colors.elementAt(index);
    } else
      return colors.elementAt(index % colors.length);
  }

  Widget myCard(int index, ShareModel share) {
    return Card(
        color: color(index),
        child: Center(
          child: InkWell(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'ชื่อวง : ${share.name}',
                  style: TextStyle(fontSize: 18),
                ),
                Text(
                  'เลขที่ : ${share.shareID}',
                  style: TextStyle(fontSize: 18),
                ),
                Text(
                  'ประเภท : ${share.shareType}',
                  style: TextStyle(fontSize: 18),
                ),
                Text(
                  'เงินต้น : ${share.principle}',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            onTap: () {
              Navigator.push(context, shareSelectRoute(share));
              print('from share list share id is ' + share.shareID.toString());
            },
          ),
        ));
  }

  Route shareSelectRoute(ShareModel share) {
    if (share.shareType == 'บิด') {
      return MaterialPageRoute(
          builder: (context) => ShareShowBidHome(tab: 2, share: share));
    }
    return throw Error();
  }
}

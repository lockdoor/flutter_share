//import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_share/models/api.dart';
import 'package:flutter_share/providers/api.dart';
import 'package:flutter_share/screen/share/shareBid/shareAddBid.dart';
import 'package:flutter_share/screen/share/shareAddInteresAfterReceive.dart';
import 'package:provider/provider.dart';

class ShareAdd extends StatefulWidget {
  const ShareAdd({Key? key}) : super(key: key);

  @override
  _ShareAddState createState() => _ShareAddState();
}

class _ShareAddState extends State<ShareAdd> {
  late ApiModel apiModel;
  @override
  void initState() {
    super.initState();
    apiModel = context.read<ApiProvider>().api;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('เพิ่มแชร์')),
      body: Center(
        child: Container(
          width: 800,
          child: GridView.count(
            padding: EdgeInsets.all(10),
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
            crossAxisCount: 2,
            children: [
              myCard('แชร์แบบบิด', routeShareAddBit(), 1),
              myCard('ดอกตาม', routeShareInterestAfterRecrive(), 2),
            ],
          ),
        ),
      ),
    );
  }

  Route routeShareInterestAfterRecrive() =>
      MaterialPageRoute(builder: (context) => ShareAddInterestAfterReceive());

  Route routeShareAddBit() =>
      MaterialPageRoute(builder: (context) => ShareAddBid());

  Widget myCard(text, Route route, index) {
    return Card(
        color: color(index),
        child: Center(
          child: InkWell(
            child: Text(
              text,
              style: TextStyle(fontSize: 20),
            ),
            onTap: () {
              Navigator.push(context, route);
            },
          ),
        ));
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
}

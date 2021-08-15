//import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_share/models/api.dart';
import 'package:flutter_share/models/customer/customer.dart';
import 'package:flutter_share/providers/api.dart';
import 'package:flutter_share/providers/bank.dart';
import 'package:flutter_share/providers/customers.dart';
import 'package:flutter_share/providers/share.dart';
import 'package:flutter_share/screen/home/homeNotify.dart';
import 'package:flutter_share/screen/setting/checkCustomerPay.dart';
import 'package:flutter_share/screen/setting/setting.dart';
import 'package:flutter_share/screen/share/shareList.dart';
import 'package:flutter_share/screen/share/shareListNoOpen.dart';
import 'customer/customerList.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  final tab;

  const Home({Key? key, required this.tab}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String title = 'หน้าหลัก';
  Widget myBody = Scaffold();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  late ApiModel apiModel;

  String adminName = 'กรุณาตั้งค่าท้าวแชร์';
  CustomerModel? admin;

  @override
  void initState() {
    super.initState();
    apiModel = context.read<ApiProvider>().api;
    tabMyBody(widget.tab);
    Provider.of<CustomerProvider>(context, listen: false).initData(apiModel);
    Provider.of<ShareProvider>(context, listen: false).initData(apiModel);
    Provider.of<BankProvider>(context, listen: false).initData(apiModel);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, CustomerProvider provider, child) {
      this.admin = context.watch<CustomerProvider>().admin;
      //print('admin is ${admin?.nickName}');
      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leading: IconButton(
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              icon: Icon(Icons.menu)),
          title: Text(title),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.account_circle,
                    color: Colors.white,
                    size: 36,
                  ),
                  title: this.admin == null
                      ? Text(
                          'กรุณาตั้งค่าท้าวแชร์',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold),
                        )
                      : Text('ท้าวแชร์ : ' + this.admin!.nickName,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold)),
                ),
              ),
              ListTile(
                leading: Icon(Icons.message),
                title: Text('Messages'),
              ),
              ListTile(
                leading: Icon(Icons.money_rounded),
                title: Text(
                  'เช็คลูกค้าส่งแชร์',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CheckCustomerPay())),
              ),
              ListTile(
                leading: Icon(Icons.update_disabled),
                title: Text(
                  'วงแชร์ที่ปิดไปแล้ว',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ShareListNoOpen())),
              ),
              ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Settings'),
                  onTap: () {
                    navigateToSetting(
                        apiModel.getApiUri(), apiModel.getToken(), this.admin);
                  }),
            ],
          ),
        ),
        body: myBody,
        bottomNavigationBar: Container(
          width: 500,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                  onPressed: () {
                    setState(() {
                      homeBody();
                    });
                  },
                  icon: Icon(Icons.home)),
              IconButton(
                  onPressed: () {
                    setState(() {
                      shareBody();
                    });
                  },
                  icon: Icon(Icons.article)),
              IconButton(
                  onPressed: () {
                    setState(() {
                      customerBody();
                    });
                  },
                  icon: Icon(Icons.person)),
            ],
          ),
        ),
      );
    });
  }

  void homeBody() {
    title = 'หน้าหลัก';
    myBody = HomeNotify();
  }

  void shareBody() {
    title = 'แชร์';
    myBody = ShareList();
  }

  void customerBody() {
    title = 'ลูกค้า';
    myBody = CustomerList();
  }

  void tabMyBody(tab) {
    if (tab == 1)
      homeBody();
    else if (tab == 2)
      shareBody();
    else if (tab == 3) customerBody();
  }

  void navigateToSetting(apiUri, token, admin) {
    Route route = MaterialPageRoute(builder: (context) => Setting());
    Navigator.push(context, route);
  }
}

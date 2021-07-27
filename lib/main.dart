import 'package:flutter/material.dart';
import 'package:flutter_share/providers/api.dart';
import 'package:flutter_share/providers/bank.dart';
import 'package:flutter_share/providers/customers.dart';
import 'package:flutter_share/providers/share.dart';
import 'package:flutter_share/providers/shareCustomer.dart';
import 'package:flutter_share/screen/home.dart';
//import 'package:flutter_share/screen/customer/customerAdd.dart';
//import 'package:flutter_share/screen/home.dart';
import 'package:provider/provider.dart';
//import 'package:flutter_share/screen/share/shareAddBid.dart';
//import 'package:flutter_share/screen/share/shareAdd.dart';
//import 'package:flutter_share/screen/login.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (BuildContext context) => ApiProvider()),
        ChangeNotifierProvider(
            create: (BuildContext context) => ShareCustomerProvider()),
        ChangeNotifierProvider(
            create: (BuildContext context) => BankProvider()),
        ChangeNotifierProvider(
            create: (BuildContext context) => ShareProvider()),
        ChangeNotifierProvider(
            create: (BuildContext context) => CustomerProvider()),
      ],
      child: MaterialApp(
          title: 'Share',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          //home: Login(),
          home: Home(tab: 2)),
    );
  }
}

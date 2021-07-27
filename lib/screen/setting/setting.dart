//import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_share/models/api.dart';
import 'package:flutter_share/models/customer/customer.dart';
import 'package:flutter_share/providers/api.dart';
import 'package:flutter_share/providers/customers.dart';
import 'package:flutter_share/screen/setting/editAdmin.dart';
//import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class Setting extends StatefulWidget {
  const Setting({
    Key? key,
  }) : super(key: key);

  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  late Text adminName;
  CustomerModel? admin;
  late ApiModel apiModel;
  @override
  void initState() {
    super.initState();
    apiModel = context.read<ApiProvider>().api;
  }

  @override
  Widget build(BuildContext context) {
    admin = context.watch<CustomerProvider>().admin;
    //admin = widget.admin == null ? null : widget.admin;
    if (admin != null) {
      adminName = Text('ท้าวแชร์: ' + admin!.nickName);
    } else {
      adminName = Text(
        'กรุณาตั้งค่าท้าวแชร์ เพื่อใช้งานระบบ',
        style: TextStyle(color: Colors.red),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Setting'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.account_circle),
            title: adminName,
            trailing: IconButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => EditAdmin()));
                },
                icon: Icon(Icons.edit)),
          )
        ],
      ),
    );
  }
}

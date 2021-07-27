//https://www.youtube.com/watch?v=ybV1aIyKFE0

//import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_share/models/api.dart';
import 'package:flutter_share/models/customer/customer.dart';
import 'package:flutter_share/providers/api.dart';
import 'package:flutter_share/providers/customers.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';

class EditAdmin extends StatefulWidget {
  const EditAdmin({Key? key}) : super(key: key);

  @override
  _EditAdminState createState() => _EditAdminState();
}

class _EditAdminState extends State<EditAdmin> {
  late ApiModel apiModel;
  CustomerModel? adminOld;
  CustomerModel? adminNew;
  late String adminNickname;
  late List<CustomerModel> customers;
  CustomerProvider customerProvider = new CustomerProvider();
  String hintText = 'ค้นหารายชื่อลูกค้า';
  TextEditingController submit = TextEditingController();
  @override
  void initState() {
    super.initState();
    apiModel = context.read<ApiProvider>().api;
    customers = context.read<CustomerProvider>().customers;
    adminOld = context.read<CustomerProvider>().admin;
    adminNickname = adminOld == null ? '' : adminOld!.nickName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ตั้งค่าท้าวแชร์ : ' + adminNickname),
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(8.0),
          child: TypeAheadField<CustomerModel?>(
              hideSuggestionsOnKeyboardHide: false,
              textFieldConfiguration: TextFieldConfiguration(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  hintText: this.hintText,
                ),
              ),
              suggestionsCallback:
                  Provider.of<CustomerProvider>(context, listen: false)
                      .getSuggestions,
              itemBuilder: (context, CustomerModel? suggestion) {
                final customer = suggestion!;

                return ListTile(
                  title: Text(customer.nickName),
                );
              },
              noItemsFoundBuilder: (context) => Container(
                    height: 100,
                    child: Center(
                      child: Text(
                        'No Users Found.',
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
              onSuggestionSelected: (CustomerModel? customerModel) {
                setState(() {
                  this.hintText = customerModel!.nickName;
                });
                adminNew = customerModel!;
              }),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.edit),
        onPressed: () => showDialog<String>(
            context: context,
            builder: (context) => Container(
                    child: AlertDialog(
                  scrollable: true,
                  title: Text('ยืนยันตั้งค่าท้าวแชร์'),
                  content: Form(
                      child: Column(
                    children: [
                      Text(
                          'เพื่อเป็นการยืนยันให้ ${adminNew!.nickName} เป็นท้าวแชร์'),
                      Text('กรุณาพิมพ์ ${apiModel.inputSubmit} ในกล่องข้อความ'),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: TextFormField(
                          controller: submit,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText:
                                  'พิมพ์ข้อความ ${apiModel.inputSubmit} ที่นี่'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: SizedBox(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              SizedBox(
                                  width: 100,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      editAdmin(this.adminNew);
                                    },
                                    child: Text('ตกลง'),
                                    style: ElevatedButton.styleFrom(
                                        primary: Colors.green),
                                  )),
                              SizedBox(
                                  width: 100,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text('ยกเลิก'),
                                    style: ElevatedButton.styleFrom(
                                        primary: Colors.red),
                                  )),
                            ],
                          ),
                        ),
                      )
                    ],
                  )),
                ))),
      ),
    );
  }

  void editAdmin(CustomerModel? adminNew) async {
    if (submit.text == apiModel.inputSubmit) {
      //print(submit.text);
      final Response response =
          await Provider.of<CustomerProvider>(context, listen: false)
              .setAdmin(apiModel, adminNew);
      if (response.statusCode == 201) {
        Navigator.pop(context);
        Navigator.pop(context);
      }
    }
  }
}

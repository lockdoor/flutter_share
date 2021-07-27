import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_share/models/api.dart';
import 'package:flutter_share/models/customer/customer.dart';
import 'package:flutter_share/providers/api.dart';
import 'package:flutter_share/providers/bank.dart';
import 'package:flutter_share/providers/customers.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:provider/provider.dart';

class CustomerAdd extends StatefulWidget {
  const CustomerAdd({Key? key}) : super(key: key);

  @override
  _CustomerAddState createState() => _CustomerAddState();
}

class _CustomerAddState extends State<CustomerAdd> {
  late ApiModel apiModel;
  GlobalKey<FormState> customerCreateFormKey = GlobalKey<FormState>();
  CustomerModel customerModel = new CustomerModel();
  late List<String> listBankName;
  int bankForms = 1;
  int phoneForms = 1;
  List<String> dropDownValue = [];
  @override
  void initState() {
    apiModel = context.read<ApiProvider>().api;
    super.initState();
    listBankName = context.read<BankProvider>().bankName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('เพิ่มลูกค้า')),
      body: //SingleChildScrollView(        child:
          Center(
        child: Container(
          color: Colors.grey.shade100,
          width: 800,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: customerCreateFormKey,
              child: Column(
                children: [
                  //nickname Form
                  Flexible(
                    child: ListTile(
                      leading: Icon(Icons.person),
                      title: TextFormField(
                        validator:
                            RequiredValidator(errorText: 'ต้องใส่ชื่อเล่น'),
                        decoration: InputDecoration(
                            labelText: 'ชื่อเล่น***',
                            labelStyle: TextStyle(color: Colors.red)),
                        onSaved: (val) =>
                            customerModel.nickName = val.toString(),
                      ),
                    ),
                  ),
                  //fname Form
                  Flexible(
                    child: ListTile(
                      leading: Icon(Icons.person),
                      title: TextFormField(
                        decoration: InputDecoration(labelText: 'ชื่อจริง'),
                        onSaved: (String? val) => customerModel.fname =
                            val == "" ? null : val.toString(),
                      ),
                    ),
                  ),
                  //lname Form
                  Flexible(
                    child: ListTile(
                      leading: Icon(Icons.person),
                      title: TextFormField(
                        decoration: InputDecoration(labelText: 'นามสกุล'),
                        onSaved: (String? val) => customerModel.lname =
                            val == "" ? null : val.toString(),
                      ),
                    ),
                  ),
                  //citizenID Form
                  Flexible(
                    child: ListTile(
                      leading: Icon(Icons.person),
                      title: TextFormField(
                        keyboardType: TextInputType.number,
                        decoration:
                            InputDecoration(labelText: 'เลขบัตรประชาชน'),
                        onSaved: (String? val) => customerModel.citizenID =
                            val == "" ? null : val.toString(),
                      ),
                    ),
                  ),
                  ////Phone Form
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: 200, minHeight: 56),
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: phoneForms,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: Icon(Icons.phone_android_outlined),
                            title: TextFormField(
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'หมายเลขโทรศัพท์ ${index + 1}',
                              ),
                              onSaved: (val) => {
                                customerModel.phoneNumber
                                    .add({'number': val.toString()})
                              },
                            ),
                            trailing: trailingPhoneForm(),
                          );
                        }),
                  ),
                  //bankFrom
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: 200, minHeight: 56),
                    child: Consumer(
                        builder: (context, BankProvider provider, child) {
                      List<String> bankName = provider.bankName;
                      dropDownValue.add(bankName.elementAt(0));
                      return ListView.builder(
                          shrinkWrap: true,
                          itemCount: bankForms,
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: DropdownButton(
                                items: bankName.map<DropdownMenuItem<String>>(
                                    (String value) {
                                  return DropdownMenuItem<String>(
                                      child: Text(value), value: value);
                                }).toList(),
                                value: dropDownValue.elementAt(index),
                                onChanged: (value) {
                                  setState(() {
                                    dropDownValue[index] = value.toString();
                                  });
                                },
                              ),
                              title: TextFormField(
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                    labelText: 'เลขบัญชี ${index + 1}'),
                                onSaved: (value) {
                                  var bankObject = {
                                    'bank': dropDownValue.elementAt(index),
                                    'account': value
                                  };
                                  customerModel.bankAccount.add(bankObject);
                                },
                              ),
                              trailing: trailingBankForm(bankName[0], index),
                            );
                          });
                    }),
                  ),

                  //submit button
                  Expanded(
                      child: Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                          onPressed: () async {
                            if (customerCreateFormKey.currentState!
                                .validate()) {
                              customerModel = new CustomerModel();
                              customerCreateFormKey.currentState!.save();
                              print(jsonEncode(customerModel.toJson()));

                              final response =
                                  await Provider.of<CustomerProvider>(context,
                                          listen: false)
                                      .addData(apiModel, customerModel);
                              print(response.body);
                              print(response.statusCode);
                              if (response.statusCode == 201) {
                                Navigator.pop(context);
                              }
                              final json = jsonDecode(response.body);
                              final snackBar = SnackBar(
                                content: Text(json['message']),
                              );
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                            }
                            //print(jsonEncode(customer.toJson()));
                          },
                          child: Text(
                            'เพิ่มลูกค้า',
                            style: TextStyle(fontSize: 20),
                          )),
                    ),
                  )),
                ],
              ),
            ),
          ),
        ),
      ),
      //),
    );
  }

  Row trailingPhoneForm() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
            onPressed: () {
              if (phoneForms < 3) {
                setState(() {
                  phoneForms++;
                });
              }
            },
            icon: Icon(Icons.add_box_outlined)),
        IconButton(
            onPressed: () {
              if (phoneForms <= 3 && phoneForms > 1) {
                setState(() {
                  phoneForms--;
                });
              }
            },
            icon: Icon(Icons.remove_circle_outline_outlined)),
      ],
    );
  }

  Row trailingBankForm(data, index) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
            onPressed: () {
              if (bankForms < 3) {
                dropDownValue.add(data);
                setState(() {
                  bankForms++;
                });
              }
            },
            icon: Icon(Icons.add_box_outlined)),
        IconButton(
            onPressed: () {
              if (bankForms <= 3 && bankForms > 1) {
                dropDownValue.removeAt(index);
                setState(() {
                  bankForms--;
                });
              }
            },
            icon: Icon(Icons.remove_circle_outline_outlined)),
      ],
    );
  }
}

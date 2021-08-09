import 'package:flutter/material.dart';
import 'package:flutter_share/models/api.dart';
import 'package:flutter_share/models/customer/customer.dart';
import 'package:flutter_share/models/share/shareCustomer.dart';
import 'package:flutter_share/providers/api.dart';
import 'package:flutter_share/providers/customers.dart';
import 'package:flutter_share/providers/shareCustomer.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';

class EditShareCustomerCustomer extends StatefulWidget {
  final sharecustomer;
  const EditShareCustomerCustomer({Key? key, required this.sharecustomer})
      : super(key: key);

  @override
  _EditShareCustomerCustomerState createState() =>
      _EditShareCustomerCustomerState();
}

class _EditShareCustomerCustomerState extends State<EditShareCustomerCustomer> {
  late List<ShareCustomerModel> shareCustomers;
  late ShareCustomerModel shareCustomer;
  String hintText = 'เพิ่มหรือเปลี่ยนรายชื่อลูกค้า';
  TextEditingController submit = new TextEditingController();
  TextEditingController nickName = new TextEditingController();
  late List<CustomerModel> customers;
  CustomerModel? newCustomer;
  late ApiModel apiModel;

  @override
  void initState() {
    super.initState();
    shareCustomer = widget.sharecustomer;
    apiModel = context.read<ApiProvider>().api;
  }

  @override
  void dispose() {
    super.dispose();
    submit.dispose();
    nickName.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, ShareCustomerProvider provider,
          Widget? child) {
        this.shareCustomers = provider.shareCustomers;
        this.customers = context.watch<CustomerProvider>().customers;
        return Scaffold(
          appBar: AppBar(
            title: Text('เพิ่มหรือเปลี่ยนรายชื่อลูกค้า : '),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                      'มือที่: ${shareCustomer.sequence} , ชื่อลูกค้า: ${shareCustomer.personName == null ? '' : shareCustomer.personName}',
                      style: TextStyle(fontSize: 20)),
                ),
                Container(
                  padding: EdgeInsets.all(8.0),
                  child: TypeAheadField<CustomerModel?>(
                      hideSuggestionsOnKeyboardHide: false,
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: nickName,
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
                          this.nickName.text = customerModel.nickName;
                        });
                        newCustomer = customerModel!;
                      }),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
              child: Icon(Icons.edit),
              onPressed: () => {
                    if (newCustomer?.nickName != null)
                      {
                        showDialog<String>(
                            context: context,
                            builder: (context) => Container(
                                    child: AlertDialog(
                                  scrollable: true,
                                  title: Text('ยืนยันตั้งค่า'),
                                  content: Form(
                                      child: Column(
                                    children: [
                                      Text(
                                          'เพื่อเป็นการยืนยันให้แชร์ลำดับที่ ${shareCustomer.sequence} มีลูกค้าเป็น ${newCustomer!.nickName} '),
                                      Text(
                                          'กรุณาพิมพ์ ${apiModel.inputSubmit} ในกล่องข้อความ'),
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
                                        padding:
                                            const EdgeInsets.only(top: 10.0),
                                        child: SizedBox(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              SizedBox(
                                                  width: 100,
                                                  child: ElevatedButton(
                                                    onPressed: () async {
                                                      if (submit.text ==
                                                          apiModel
                                                              .inputSubmit) {
                                                        final Response
                                                            response =
                                                            await Provider.of<
                                                                        ShareCustomerProvider>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                                .addCustomerToShareCustomer(
                                                                    apiModel,
                                                                    newCustomer,
                                                                    shareCustomer
                                                                        .sequence);
                                                        if (response
                                                                .statusCode ==
                                                            201) {
                                                          Navigator.pop(
                                                              context);
                                                          Navigator.pop(
                                                              context);
                                                        }
                                                      }
                                                      //editAdmin(this.adminNew);
                                                    },
                                                    child: Text('ตกลง'),
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                            primary:
                                                                Colors.green),
                                                  )),
                                              SizedBox(
                                                  width: 100,
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text('ยกเลิก'),
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                            primary:
                                                                Colors.red),
                                                  )),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  )),
                                ))),
                      }
                    else
                      {
                        showDialog<String>(
                            context: context,
                            builder: (context) => Container(
                                  child: AlertDialog(
                                    content:
                                        Text('กรุณาเลือกลูกค้าก่อนกดแก้ไข'),
                                  ),
                                )),
                      }
                  }),
        );
      },
    );
  }
}
// onPressed: () => showDialog<String>(
            //     context: context,
            //     builder: (context) => Container(
            //             child: AlertDialog(
            //           scrollable: true,
            //           title: Text('ยืนยันตั้งค่า'),
            //           content: Form(
            //               child: Column(
            //             children: [
            //               Text(
            //                   'เพื่อเป็นการยืนยันให้แชร์ลำดับที่ ${shareCustomer.sequence} มีลูกค้าเป็น ${newCustomer!.nickName} '),
            //               Text('กรุณาพิมพ์ 1 ในกล่องข้อความ'),
            //               Padding(
            //                 padding: const EdgeInsets.only(top: 10),
            //                 child: TextFormField(
            //                   controller: submit,
            //                   decoration: InputDecoration(
            //                       border: OutlineInputBorder(),
            //                       hintText: 'พิมพ์ข้อความ 1 ที่นี่'),
            //                 ),
            //               ),
            //               Padding(
            //                 padding: const EdgeInsets.only(top: 10.0),
            //                 child: SizedBox(
            //                   child: Row(
            //                     mainAxisAlignment:
            //                         MainAxisAlignment.spaceAround,
            //                     children: [
            //                       SizedBox(
            //                           width: 100,
            //                           child: ElevatedButton(
            //                             onPressed: () async {
            //                               final Response response =
            //                                   await Provider.of<
            //                                               ShareCustomerProvider>(
            //                                           context,
            //                                           listen: false)
            //                                       .addCustomerToShareCustomer(
            //                                           apiModel,
            //                                           newCustomer,
            //                                           shareCustomer.sequence);
            //                               if (response.statusCode == 201) {
            //                                 Navigator.pop(context);
            //                                 Navigator.pop(context);
            //                               }
            //                               //editAdmin(this.adminNew);
            //                             },
            //                             child: Text('ตกลง'),
            //                             style: ElevatedButton.styleFrom(
            //                                 primary: Colors.green),
            //                           )),
            //                       SizedBox(
            //                           width: 100,
            //                           child: ElevatedButton(
            //                             onPressed: () {
            //                               Navigator.pop(context);
            //                             },
            //                             child: Text('ยกเลิก'),
            //                             style: ElevatedButton.styleFrom(
            //                                 primary: Colors.red),
            //                           )),
            //                     ],
            //                   ),
            //                 ),
            //               )
            //             ],
            //           )),
            //         ))),
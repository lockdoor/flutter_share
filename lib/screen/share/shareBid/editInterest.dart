import 'package:flutter/material.dart';
import 'package:flutter_share/models/api.dart';
//import 'package:flutter_share/models/share/share.dart';
import 'package:flutter_share/models/share/shareCustomer.dart';
import 'package:flutter_share/providers/api.dart';
import 'package:flutter_share/providers/shareCustomer.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class EditInterest extends StatefulWidget {
  final shareCustomer;
  final adminFirstSequence;
  final adminLastSequence;
  final shareModel;
  const EditInterest(
      {Key? key,
      required this.shareCustomer,
      required this.adminFirstSequence,
      required this.adminLastSequence,
      required this.shareModel})
      : super(key: key);

  @override
  _EditInterestState createState() => _EditInterestState();
}

class _EditInterestState extends State<EditInterest> {
  late ShareCustomerModel shareCustomerOld;
  ShareCustomerModel? shareCustomerNew;
  late ApiModel apiModel;
  TextStyle bigFont = TextStyle(fontSize: 20);
  String hintText = 'ใส่ลำดับมือที่เปีย';
  int? shareSequence;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  //TextEditingController sequence = TextEditingController();
  TextEditingController interest = TextEditingController();

  @override
  void initState() {
    super.initState();
    shareCustomerOld = widget.shareCustomer;
    apiModel = context.read<ApiProvider>().api;
    //สร้าง list shareCustomer no admin
    Provider.of<ShareCustomerProvider>(context, listen: false)
        .noLocker(widget.adminFirstSequence, widget.adminLastSequence);
  }

  @override
  void dispose() {
    super.dispose();
    //formKey.dispose();
    //sequence.dispose();
    interest.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('แก้ไขดอกเบี้ยรายการที่ : ${shareCustomerOld.sequence}'),
      ),
      body: Center(
        child: Container(
          width: 800,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('ลูกค้า: ${shareCustomerOld.personName}',
                        style: bigFont),
                  ),
                  Text(
                    'เปียมือที่:',
                    style: bigFont,
                  ),
                  //ตรงนี้จะใช้ auto complete โดยมีลำดับมือและวันที่มาแสดงในกล่องข้อความ
                  TypeAheadField<ShareCustomerModel?>(
                      hideSuggestionsOnKeyboardHide: false,
                      textFieldConfiguration: TextFieldConfiguration(
                        //controller: sequence,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                          hintText: this.hintText,
                        ),
                      ),
                      suggestionsCallback: Provider.of<ShareCustomerProvider>(
                              context,
                              listen: false)
                          .getSuggestions,
                      itemBuilder: (context, ShareCustomerModel? suggestion) {
                        final shareCustomer = suggestion!;
                        return ListTile(
                          leading: Text(shareCustomer.sequence.toString()),
                          title: Text(DateFormat('EEEE dd-MM-yyyy')
                              .format(shareCustomer.shareDate)),
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
                      onSuggestionSelected:
                          (ShareCustomerModel? shareCustomerModel) {
                        setState(() {
                          this.hintText =
                              'ลำดับที่: ${shareCustomerModel!.sequence} , วันที่: ${DateFormat('EEEE dd-MM-yyyy').format(shareCustomerModel.shareDate)}';
                        });
                        shareCustomerNew = shareCustomerModel!;
                      }),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    'ดอกเบี้ย:',
                    style: bigFont,
                  ),
                  TextFormField(
                    controller: interest,
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        checkNum(value, 'จำเป็นต้องใส่ดอกเบี้ย'),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.filter_vintage_sharp),
                      border: OutlineInputBorder(),
                      hintText: 'ใส่จำนวนดอกเบี้ย',
                    ),
                  ),
                  SizedBox(
                    height: 20,
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
                                onPressed: () async {
                                  if (formKey.currentState!.validate() &&
                                      shareCustomerNew != null) {
                                    print('พร้อมที่จะทำการบันทึกแล้วครับ');
                                    final Response response = await Provider.of<
                                                ShareCustomerProvider>(context,
                                            listen: false)
                                        .editInterest(
                                            apiModel,
                                            widget.shareModel,
                                            shareCustomerOld,
                                            shareCustomerNew,
                                            int.parse(interest.text));
                                    if (response.statusCode == 201) {
                                      Navigator.pop(context);
                                    }
                                  }
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
              ),
            ),
          ),
        ),
      ),
    );
  }

  checkNum(String? value, String errorMessage) {
    if (value!.isEmpty) {
      return errorMessage;
    } else {
      final String num = '0123456789';
      for (int i = 0; i < value.length; i++) {
        if (!num.contains(value[i])) {
          //print('false at ' + value[i]);
          return 'กรุณากรอกตัวเลขเท่านั้น';
        }
      }
      return null;
    }
  }
}

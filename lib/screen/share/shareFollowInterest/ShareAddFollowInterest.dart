//แชร์แบบดอกตาม
import 'package:flutter/material.dart';
import 'package:flutter_share/models/api.dart';
import 'package:flutter_share/models/share/share.dart';
import 'package:flutter_share/providers/api.dart';
import 'package:flutter_share/providers/share.dart';
import 'package:flutter_share/screen/home.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ShareAddFollowInterest extends StatefulWidget {
  const ShareAddFollowInterest({Key? key}) : super(key: key);
  @override
  _ShareAddFollowInterestState createState() => _ShareAddFollowInterestState();
}

class _ShareAddFollowInterestState extends State<ShareAddFollowInterest> {
  late ApiModel apiModel;
  final ShareModel shareModel = ShareModel();
  GlobalKey<FormState> shareAddBitForm = GlobalKey<FormState>();
  final TextEditingController principleController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController payController = TextEditingController();
  final TextEditingController dateRunController = TextEditingController();
  Map<String, bool> formCollect = {'principle': false, 'amount': false};
  late DateTime toDay;
  @override
  void initState() {
    super.initState();
    apiModel = context.read<ApiProvider>().api;
    toDay = DateTime.now();
    dateRunController.text = DateFormat('dd-MM-yyyy').format(toDay).toString();
    shareModel.dateRun = toDay;
    shareModel.shareType = 'ดอกตาม';
  }

  @override
  void dispose() {
    super.dispose();
    principleController.dispose();
    amountController.dispose();
    payController.dispose();
    dateRunController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('สร้างแชร์แบบดอกตาม')),
      body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: SingleChildScrollView(
            //child: ConstrainedBox(
            //constraints: BoxConstraints(
            //minHeight: viewportConstraints.maxHeight,
            //),
            //child: IntrinsicHeight(
            child: Center(
              child: Container(
                //height: 940,
                width: 800,
                child: Form(
                  key: shareAddBitForm,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        //ชื่อวง
                        ListTile(
                          leading: Icon(Icons.ac_unit),
                          title: TextFormField(
                            validator: RequiredValidator(
                                errorText: 'จำเป็นต้องใส่ชื่อวงแชร์'),
                            onSaved: (value) {
                              shareModel.name = value.toString();
                            },
                            decoration: InputDecoration(
                              labelText: 'ชื่อวงแชร์***',
                              //labelStyle: TextStyle(color: Colors.red)
                            ),
                          ),
                        ),
                        //ค่าดูแล
                        ListTile(
                            leading: Icon(Icons.filter_vintage_sharp),
                            title: TextFormField(
                              initialValue: '0',
                              onSaved: (value) =>
                                  shareModel.fee = int.parse(value.toString()),
                              validator: (value) => checkNum(
                                  value, 'จำเป็นต้องใส่ค่าดูแลเริ่มต้น'),
                              decoration: InputDecoration(labelText: 'ค่าดูแล'),
                              keyboardType: TextInputType.number,
                            )),
                        //เริ่มวันที่
                        ListTile(
                          onTap: () {
                            pickDate();
                          },
                          leading: Icon(Icons.date_range),
                          title: TextFormField(
                            //keyboardType: TextInputType.datetime,

                            enabled: false,
                            controller: dateRunController,
                            validator: RequiredValidator(
                                errorText: 'จำเป็นต้องใส่วันที่'),
                            // onSaved: (value) {
                            //   share.dateRun = DateTime.parse(value.toString());
                            // },
                            decoration: InputDecoration(
                              labelText: 'เริ่มวันที่',
                              //labelStyle: TextStyle(color: Colors.red)
                            ),
                          ),
                        ),
                        //เงินต้น
                        ListTile(
                            leading: Icon(Icons.money),
                            title: TextFormField(
                              controller: principleController,
                              onChanged: (value) => payByPrincipleDivideAmount(
                                  value, 'เงินต้นไม่ถูกต้อง', 'principle'),
                              onSaved: (value) => shareModel.principle =
                                  int.parse(value.toString()),
                              validator: (value) =>
                                  checkNum(value, 'จำเป็นต้องใส่เงินต้น'),
                              decoration: InputDecoration(labelText: 'เงินต้น'),
                              keyboardType: TextInputType.number,
                            )),
                        //จำนวนมือ
                        ListTile(
                            leading: Icon(Icons.face),
                            title: TextFormField(
                              onChanged: (value) => payByPrincipleDivideAmount(
                                  value, 'จำนวนมือไม่ถูกต้อง', 'amount'),
                              controller: amountController,
                              onSaved: (value) => shareModel.amount =
                                  int.parse(value.toString()),
                              validator: (value) =>
                                  checkNum(value, 'จำเป็นต้องใส่จำนวนมือ'),
                              decoration:
                                  InputDecoration(labelText: 'จำนวนมือ'),
                              keyboardType: TextInputType.number,
                            )),
                        //ส่งมือละ
                        ListTile(
                            leading: Icon(Icons.attach_money),
                            title: TextFormField(
                              //enabled: false,
                              controller: payController,
                              onSaved: (value) =>
                                  shareModel.pay = int.parse(value.toString()),
                              validator: (value) =>
                                  checkNum(value, 'จำเป็นต้องใส่ส่งมือละ'),
                              decoration:
                                  InputDecoration(labelText: 'ส่งมือละ'),
                              keyboardType: TextInputType.number,
                            )),
                        //ดอกเบี้ย
                        ListTile(
                            leading: Icon(Icons.filter_vintage_sharp),
                            title: TextFormField(
                              //initialValue: '0',
                              onSaved: (value) => shareModel.interestFix =
                                  int.parse(value.toString()),
                              validator: (value) =>
                                  checkNum(value, 'จำเป็นต้องใส่ดอกเบี้ย'),
                              decoration:
                                  InputDecoration(labelText: 'ดอกเบี้ย'),
                              keyboardType: TextInputType.number,
                            )),
                        //ระยะส่ง
                        ListTile(
                            leading: Icon(Icons.date_range),
                            title: TextFormField(
                              onSaved: (value) =>
                                  shareModel.days = int.parse(value.toString()),
                              validator: (String? value) {
                                String? result;
                                if (value!.isNotEmpty) {
                                  result =
                                      checkNum(value, 'จำเป็นต้องใส่ระยะส่ง');
                                  if (int.parse(value.toString()) > 30 ||
                                      int.parse(value.toString()) < 1) {
                                    result = 'กรุณาใส่ตัวเลข 1-30';
                                  }
                                } else {
                                  result = 'จำเป็นต้องใส่ระยะส่ง';
                                }
                                return result;
                              },
                              decoration: InputDecoration(
                                  labelText: 'ระยะส่ง ( 1- 30 วัน)'),
                              keyboardType: TextInputType.number,
                            )),

                        //เช็คบ๊อก
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: SizedBox(
                              child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              SizedBox(
                                //width: 150,
                                child: Row(
                                  children: [
                                    Checkbox(
                                      checkColor: Colors.white,
                                      //fillColor: MaterialStateProperty.resolveWith(getColor),
                                      value: shareModel.firstReceive,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          shareModel.firstReceive = value!;
                                        });
                                      },
                                    ),
                                    Text('ท้าวยกมือแรก',
                                        style: TextStyle(fontSize: 16))
                                  ],
                                ),
                              ),
                              SizedBox(
                                //width: 150,
                                child: Row(
                                  children: [
                                    Checkbox(
                                      checkColor: Colors.white,
                                      //fillColor: MaterialStateProperty.resolveWith(getColor),
                                      value: shareModel.lastReceive,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          shareModel.lastReceive = value!;
                                        });
                                      },
                                    ),
                                    Text('ท้าวหักค้ำท้าย',
                                        style: TextStyle(fontSize: 16))
                                  ],
                                ),
                              ),
                            ],
                          )),
                        ),
                        //submit
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: SizedBox(
                            width: double.infinity,
                            height: 40,
                            child: ElevatedButton(
                                onPressed: () async {
                                  if (shareAddBitForm.currentState!
                                      .validate()) {
                                    shareAddBitForm.currentState!.save();
                                    print('เริ่มทำการบันทึก');
                                    //print(jsonEncode(share.toJson()));

                                    final response =
                                        await Provider.of<ShareProvider>(
                                                context,
                                                listen: false)
                                            .addData(apiModel, shareModel);
                                    print(response.statusCode);
                                    print(response.body);
                                    if (response.statusCode == 201) {
                                      Route route = MaterialPageRoute(
                                          builder: (context) => Home(
                                                tab: 2,
                                              ));
                                      Navigator.pushReplacement(context, route);
                                    }
                                  }
                                },
                                child: Text(
                                  'เพิ่มวงแชร์',
                                  style: TextStyle(fontSize: 16),
                                )),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          //))
        );
      }),
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

  void payByPrincipleDivideAmount(val, String showError, flag) {
    final String num = '0123456789';
    String value = val.trim();
    if (value.length > 0) {
      for (int i = 0; i < value.length; i++) {
        if (!num.contains(value[i])) {
          formCollect[flag] = false;
          payController.text = showError;
          break;
        } else {
          formCollect[flag] = true;
        }
      }
    } else {
      formCollect[flag] = false;
      payController.text = '';
    }
    if (formCollect['principle']! && formCollect['amount']!) {
      int principleInt = int.parse(principleController.text.toString());
      int amountInt = int.parse(amountController.text.toString());
      if (shareModel.firstReceive) {
        amountInt -= 1;
      }
      if (amountInt != 0) {
        double payDouble = principleInt / amountInt;
        int payInt = payDouble.round();
        payController.text = payInt.toString();
      }
    }
  }

  pickDate() async {
    await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(DateTime.now().year - 1),
            lastDate: DateTime(DateTime.now().year + 1))
        .then((DateTime? value) => {
              if (value != null)
                {
                  setState(() {
                    dateRunController.text =
                        DateFormat('dd-MM-yyyy').format(value).toString();
                    shareModel.dateRun = value;
                  })
                }
            });
  }
}

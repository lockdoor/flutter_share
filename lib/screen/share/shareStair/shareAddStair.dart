import 'package:flutter/material.dart';
import 'package:flutter_share/models/api.dart';
import 'package:flutter_share/models/share/share.dart';
import 'package:flutter_share/providers/api.dart';
import 'package:flutter_share/providers/share.dart';
import 'package:flutter_share/screen/home.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ShareAddStair extends StatefulWidget {
  const ShareAddStair({Key? key}) : super(key: key);

  @override
  _ShareAddStairState createState() => _ShareAddStairState();
}

class _ShareAddStairState extends State<ShareAddStair> {
  late ApiModel apiModel;
  ShareModel shareModel = ShareModel();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController dateRunController = TextEditingController();

  @override
  void initState() {
    super.initState();
    apiModel = context.read<ApiProvider>().api;
    dateRunController.text =
        DateFormat('dd-MM-yyyy').format(DateTime.now()).toString();
    shareModel.shareType = 'ขั้นบันได';
    shareModel.dateRun = new DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('สร้างแชร์แบบขั้นบันได'),
      ),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              child: Form(
                  key: formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        //ชื่อวงแชร์
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
                              //controller: principleController,
                              //onChanged: (value) => payByPrincipleDivideAmount(
                              //value, 'เงินต้นไม่ถูกต้อง', 'principle'),
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
                              //onChanged: (value) => payByPrincipleDivideAmount(
                              //value, 'จำนวนมือไม่ถูกต้อง', 'amount'),
                              //controller: amountController,
                              onSaved: (value) => shareModel.amount =
                                  int.parse(value.toString()),
                              validator: (value) =>
                                  checkNum(value, 'จำเป็นต้องใส่จำนวนมือ'),
                              decoration:
                                  InputDecoration(labelText: 'จำนวนมือ'),
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
                                  if (formKey.currentState!.validate()) {
                                    formKey.currentState!.save();
                                    print('เริ่มทำการบันทึก');
                                    print(shareModel.toJson());

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
                  )),
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

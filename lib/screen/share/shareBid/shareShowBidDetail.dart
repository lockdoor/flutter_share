import 'package:flutter/material.dart';
import 'package:flutter_share/models/api.dart';
import 'package:flutter_share/models/share/share.dart';
import 'package:flutter_share/providers/api.dart';
import 'package:flutter_share/providers/share.dart';
import 'package:flutter_share/screen/home.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';

import '../../capture.dart';

class ShareShowBidDetail extends StatefulWidget {
  final shareModel;
  final title;
  const ShareShowBidDetail(
      {Key? key, required this.shareModel, required this.title})
      : super(key: key);

  @override
  _ShareShowBidDetailState createState() => _ShareShowBidDetailState();
}

class _ShareShowBidDetailState extends State<ShareShowBidDetail> {
  late ShareModel shareModel;
  late ShareModel shareModelOld;
  late ApiModel apiModel;
  GlobalKey<FormState> shareUpdateBitForm = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController feeController = TextEditingController();
  final TextEditingController dateRunController = TextEditingController();
  final TextEditingController principleController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController payController = TextEditingController();
  final TextEditingController daysController = TextEditingController();
  final TextEditingController firstBidController = TextEditingController();
  final TextEditingController bidController = TextEditingController();
  final TextEditingController lastBidController = TextEditingController();
  final ScreenshotController screenshotController = ScreenshotController();
  final TextEditingController alertTextFrom = TextEditingController();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool canEdit = false;
  Map<String, bool> formCollect = {'principle': true, 'amount': true};
  @override
  void initState() {
    super.initState();
    shareModel = widget.shareModel;
    shareModelOld = new ShareModel.fromJson(shareModel.toJson());
    apiModel = context.read<ApiProvider>().api;
    nameController.text = shareModel.name;
    dateRunController.text =
        DateFormat('dd-MM-yyyy').format(shareModel.dateRun).toString();
    principleController.text = shareModel.principle.toString();
    amountController.text = shareModel.amount.toString();
    payController.text = shareModel.pay.toString();
    daysController.text = shareModel.days.toString();
    firstBidController.text = shareModel.firstBid.toString();
    bidController.text = shareModel.bid.toString();
    lastBidController.text = shareModel.bid.toString();
    feeController.text = shareModel.fee.toString();
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    feeController.dispose();
    dateRunController.dispose();
    principleController.dispose();
    amountController.dispose();
    payController.dispose();
    daysController.dispose();
    firstBidController.dispose();
    bidController.dispose();
    lastBidController.dispose();
    alertTextFrom.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
        builder: (BuildContext context, ShareProvider provider, Widget? child) {
      int index = provider.shares
          .indexWhere((share) => share.shareID == widget.shareModel.shareID);
      shareModel = provider.shares[index];
      shareModelOld = new ShareModel.fromJson(shareModel.toJson());
      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: Row(
            children: [Icon(Icons.article), Text(' : ' + shareModel.name)],
          ),
          actions: [
            IconButton(
                onPressed: () {
                  _scaffoldKey.currentState!.openDrawer();
                },
                icon: Icon(Icons.menu)),
            IconButton(
                onPressed: () {
                  screenshotController
                      .capture(delay: Duration(milliseconds: 10))
                      .then((capturedImage) async {
                    await Capture.shareCaptureWidget(
                        capturedImage!, shareModel);
                  }).catchError((onError) {
                    print(onError);
                  });
                },
                icon: Icon(Icons.share)),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Text(
                  'ตั้งค่าแชร์\n${shareModel.name}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              //เปิด - ปิด วงแชร์
              ListTile(
                leading: shareModel.isOpen == true
                    ? Icon(Icons.check_circle_outline)
                    : Icon(Icons.block_outlined),
                title: shareModel.isOpen == true
                    ? Text('แชร์วงนี้เปิดอยู่')
                    : Text('แชร์วงนี้ปิดวงแล้ว'),
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            scrollable: true,
                            title: shareModel.isOpen == false
                                ? Text('ยืนยันจะเปิดแชร์วงนี้')
                                : Text('ยืนยันจะปิดแชร์วงนี้'),
                            content: Container(
                              child: Column(
                                children: [
                                  shareModel.isOpen == false
                                      ? Text('เพื่อเป็นการยืนยันเปิดแชร์วงนี้')
                                      : Text(
                                          'เพื่อเป็นการยืนยันจะปิดแชร์วงนี้'),
                                  Text(
                                      'กรุณาพิมพ์ ${apiModel.inputSubmit} ในกล่องข้อความ'),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: TextFormField(
                                      controller: alertTextFrom,
                                      decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          hintText:
                                              'พิมพ์ข้อความ ${apiModel.inputSubmit} ที่นี่'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, 'Cancel'),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  if (alertTextFrom.text ==
                                      apiModel.inputSubmit) {
                                    setState(() {
                                      canEdit = !canEdit;
                                    });
                                    alertTextFrom.clear();
                                    Response response =
                                        await Provider.of<ShareProvider>(
                                                context,
                                                listen: false)
                                            .onOffShare(apiModel, shareModel);
                                    if (response.statusCode == 201) {
                                      _scaffoldKey.currentState!
                                          .openEndDrawer();

                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  Home(tab: 2)));
                                    }
                                  }
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          ));
                },
              ),
              //แก้ไขแชร์
              ListTile(
                leading: canEdit == false
                    ? Icon(Icons.block_outlined)
                    : Icon(Icons.edit_outlined),
                title: canEdit == false
                    ? Text('แชร์วงนี้ห้ามแก้ไข')
                    : Text('แชร์วงนี้สามารถแก้ไข'),
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            scrollable: true,
                            title: canEdit == false
                                ? Text('ยืนยันจะแก้ไขแชร์วงนี้')
                                : Text('ยืนยันจะห้ามแก้ไขแชร์วงนี้'),
                            content: Container(
                              child: Column(
                                children: [
                                  canEdit == false
                                      ? Text(
                                          'เพื่อเป็นการยืนยันจะแก้ไขแชร์วงนี้')
                                      : Text(
                                          'เพื่อเป็นการยืนยันจะห้ามแก้ไขแชร์วงนี้'),
                                  Text(
                                      'กรุณาพิมพ์ ${apiModel.inputSubmit} ในกล่องข้อความ'),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: TextFormField(
                                      controller: alertTextFrom,
                                      decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          hintText:
                                              'พิมพ์ข้อความ ${apiModel.inputSubmit} ที่นี่'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, 'Cancel'),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  if (alertTextFrom.text ==
                                      apiModel.inputSubmit) {
                                    setState(() {
                                      canEdit = !canEdit;
                                    });
                                    alertTextFrom.clear();
                                    Navigator.pop(context, 'OK');
                                    _scaffoldKey.currentState!.openEndDrawer();
                                  }
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          ));
                },
              ),
              //บันทึกแชร์
              ListTile(
                leading: Icon(Icons.save_outlined),
                title: Text('บันทึกการแก้ไข'),
                onTap: () {
                  if (canEdit == true) {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              scrollable: true,
                              title: Text('ยืนยันการบันทึก'),
                              content: Container(
                                child: Column(
                                  children: [
                                    Text('เพื่อเป็นการยืนยันจะบันทึกแชร์วงนี้'),
                                    Text(
                                        'กรุณาพิมพ์ ${apiModel.inputSubmit} ในกล่องข้อความ'),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: TextFormField(
                                        controller: alertTextFrom,
                                        decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            hintText:
                                                'พิมพ์ข้อความ ${apiModel.inputSubmit} ที่นี่'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, 'Cancel'),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => updateShare(),
                                  child: const Text('OK'),
                                ),
                              ],
                            ));
                  }
                },
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Screenshot(
            controller: screenshotController,
            child: Center(
              child: Container(
                color: Colors.white,
                child: Form(
                  key: shareUpdateBitForm,
                  child: Column(
                    children: [
                      //ชื่อวง
                      ListTile(
                        leading: Icon(Icons.ac_unit),
                        title: TextFormField(
                          enabled: canEdit,
                          controller: nameController,
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
                            enabled: canEdit,
                            controller: feeController,
                            onSaved: (value) =>
                                shareModel.fee = int.parse(value.toString()),
                            validator: (value) =>
                                checkNum(value, 'จำเป็นต้องใส่ค่าดูแลเริ่มต้น'),
                            decoration: InputDecoration(labelText: 'ค่าดูแล'),
                            keyboardType: TextInputType.number,
                          )),
                      //เริ่มวันที่
                      ListTile(
                        onTap: () {
                          if (canEdit == true) {
                            pickDate();
                          }
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
                            enabled: canEdit,
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
                            enabled: canEdit,
                            onChanged: (value) => payByPrincipleDivideAmount(
                                value, 'จำนวนมือไม่ถูกต้อง', 'amount'),
                            controller: amountController,
                            onSaved: (value) =>
                                shareModel.amount = int.parse(value.toString()),
                            validator: (value) =>
                                checkNum(value, 'จำเป็นต้องใส่จำนวนมือ'),
                            decoration: InputDecoration(labelText: 'จำนวนมือ'),
                            keyboardType: TextInputType.number,
                          )),
                      //ส่งมือละ
                      ListTile(
                          leading: Icon(Icons.attach_money),
                          title: TextFormField(
                            enabled: canEdit,
                            controller: payController,
                            onSaved: (value) =>
                                shareModel.pay = int.parse(value.toString()),
                            validator: (value) =>
                                checkNum(value, 'จำเป็นต้องใส่ส่งมือละ'),
                            decoration: InputDecoration(labelText: 'ส่งมือละ'),
                            keyboardType: TextInputType.number,
                          )),
                      //ระยะส่ง
                      ListTile(
                          leading: Icon(Icons.date_range),
                          title: TextFormField(
                            enabled: canEdit,
                            controller: daysController,
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
                      //บิดเริ่มต้น
                      ListTile(
                          leading: Icon(Icons.filter_vintage_sharp),
                          title: TextFormField(
                            enabled: canEdit,
                            controller: firstBidController,
                            onSaved: (value) => shareModel.firstBid =
                                int.parse(value.toString()),
                            validator: (value) =>
                                checkNum(value, 'จำเป็นต้องใส่บิดเริ่มต้น'),
                            decoration:
                                InputDecoration(labelText: 'บิดเริ่มต้น'),
                            keyboardType: TextInputType.number,
                          )),
                      //บิดครั้้งละ
                      ListTile(
                          leading: Icon(Icons.filter_vintage_sharp),
                          title: TextFormField(
                            enabled: canEdit,
                            controller: bidController,
                            onSaved: (value) =>
                                shareModel.bid = int.parse(value.toString()),
                            validator: (value) =>
                                checkNum(value, 'จำเป็นต้องบิดครั้งละ'),
                            decoration:
                                InputDecoration(labelText: 'บิดครั้งละ'),
                            keyboardType: TextInputType.number,
                          )),
                      //ไม่มีคนบิดสุ่มดอก
                      ListTile(
                          leading: Icon(Icons.filter_vintage_sharp),
                          title: TextFormField(
                            enabled: canEdit,
                            controller: lastBidController,
                            onSaved: (value) =>
                                shareModel.noBid = int.parse(value.toString()),
                            validator: (value) =>
                                checkNum(value, 'จำเป็นต้องใส่สุ่มดอก'),
                            decoration: InputDecoration(
                                labelText: 'ไม่มีคนบิด สุ่มดอก'),
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
                                      if (canEdit == true) {
                                        setState(() {
                                          shareModel.firstReceive = value!;
                                        });
                                      }
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
                                      if (canEdit == true) {
                                        setState(() {
                                          shareModel.lastReceive = value!;
                                        });
                                      }
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
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(vertical: 8),
                      //   child: SizedBox(
                      //     width: double.infinity,
                      //     height: 40,
                      //     child: ElevatedButton(
                      //         onPressed: () async {
                      //           if (shareAddBitForm.currentState!.validate()) {
                      //             shareAddBitForm.currentState!.save();
                      //             print('เริ่มทำการบันทึก');
                      //             //print(jsonEncode(share.toJson()));

                      //             final response = await Provider.of<ShareProvider>(
                      //                     context,
                      //                     listen: false)
                      //                 .addData(apiModel, shareModel);
                      //             print(response.statusCode);
                      //             print(response.body);
                      //             if (response.statusCode == 201) {
                      //               // Route route = MaterialPageRoute(
                      //               //     builder: (context) => Home(
                      //               //           tab: 2,
                      //               //         ));
                      //               // Navigator.pushReplacement(
                      //               //     context, route);
                      //             }
                      //           }
                      //         },
                      //         child: Text(
                      //           'เพิ่มวงแชร์',
                      //           style: TextStyle(fontSize: 16),
                      //         )),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  updateShare() async {
    if (shareUpdateBitForm.currentState!.validate()) {
      shareUpdateBitForm.currentState!.save();
      final shareModelNew = shareModel;
      //final json = shareModel.toJson();
      //final jsonOld = shareModelOld.toJson();
      // print('json  is ' + json.toString());
      // print('json old is ' + jsonOld.toString());
      final Response response =
          await Provider.of<ShareProvider>(context, listen: false)
              .updateShare(apiModel, shareModelNew, shareModelOld);
      if (response.statusCode == 201) {
        Navigator.pop(context);
        print(response.body);
        alertTextFrom.clear();
        canEdit = false;
        _scaffoldKey.currentState!.openEndDrawer();
      }
    }
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
    if (formCollect['principle'] == true && formCollect['amount'] == true) {
      int principleInt = int.parse(principleController.text.toString());
      int amountInt = int.parse(amountController.text.toString());
      if (shareModel.firstReceive) {
        amountInt -= 1;
      }
      if (amountInt != 0) {
        double payDouble = principleInt / amountInt;
        int payInt = payDouble.round();
        setState(() {
          payController.text = payInt.toString();
        });
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

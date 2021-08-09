import 'package:flutter/material.dart';
import 'package:flutter_share/models/api.dart';
import 'package:flutter_share/models/share/share.dart';
import 'package:flutter_share/models/share/shareCustomer.dart';
import 'package:flutter_share/providers/api.dart';
import 'package:flutter_share/providers/shareCustomer.dart';
import 'package:flutter_share/screen/capture.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:http/http.dart';
import 'package:screenshot/screenshot.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ShareShowBidCustomerReceive extends StatefulWidget {
  final ShareCustomerModel shareCustomerModel;
  final ShareModel shareModel;
  const ShareShowBidCustomerReceive(
      {Key? key, required this.shareCustomerModel, required this.shareModel})
      : super(key: key);

  @override
  _ShareShowBidCustomerReceiveState createState() =>
      _ShareShowBidCustomerReceiveState();
}

class _ShareShowBidCustomerReceiveState
    extends State<ShareShowBidCustomerReceive> {
  late ShareCustomerModel shareCustomerModel;
  late ShareModel shareModel;
  late List<ShareCustomerModel> shareCustomerModels;
  late ApiModel apiModel;
  ScreenshotController screenshotController = ScreenshotController();
  TextStyle bigFont = TextStyle(fontSize: 20);
  late int totalInterest;
  late int last;
  late int totalReceive;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController commentController = TextEditingController();
  TextEditingController submitController = TextEditingController();
  @override
  void initState() {
    super.initState();
    shareCustomerModel = widget.shareCustomerModel;
    shareModel = widget.shareModel;
    shareCustomerModels = context.read<ShareCustomerProvider>().shareCustomers;
    apiModel = context.read<ApiProvider>().api;
    totalInterest = totalInterestReceive(
        shareModel, shareCustomerModel, shareCustomerModels);
    last = lastReceive(shareModel, shareCustomerModel);
    totalReceive = shareModel.principle + totalInterest - last;
    if (shareCustomerModel.comment != null)
      commentController.text = shareCustomerModel.comment!;
  }

  @override
  void dispose() {
    super.dispose();
    commentController.dispose();
    submitController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [Icon(Icons.money), Text(' : ${shareModel.name}')],
        ),
        actions: [
          IconButton(
              onPressed: () {
                screenshotController
                    .capture(delay: Duration(milliseconds: 10))
                    .then((capturedImage) async {
                  await Capture.shareCaptureWidget(capturedImage!, shareModel);
                }).catchError((onError) {
                  print(onError);
                });
              },
              icon: Icon(Icons.share))
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Screenshot(
                controller: screenshotController,
                //child: Padding(
                //padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        Text(
                          'ชื่อวงแชร์ : ${shareModel.name}',
                          style: bigFont,
                        ),
                        Text(
                          'ชื่อลูกค้า : ${shareCustomerModel.personName}',
                          style: bigFont,
                        ),
                        Text(
                          'งวดที่ : ${shareCustomerModel.sequence}',
                          style: bigFont,
                        ),
                        Text(
                            'วันที่ : ${DateFormat('dd/MM/yyyy').format(shareCustomerModel.shareDate)}',
                            style: bigFont),
                        Text(
                          'ดอกเบี้ย : ${shareCustomerModel.interest}',
                          style: bigFont,
                        ),
                        Text(
                          'เงินต้น : ${shareModel.principle}',
                          style: bigFont,
                        ),
                        Text(
                          'รับดอกเบี้ยรวม : $totalInterest',
                          style: bigFont,
                        ),
                        if (shareModel.lastReceive == true)
                          Text(
                            'หักค้ำท้าย : $last',
                            style: bigFont,
                          ),
                        Text(
                          'รวมรับ : $totalReceive',
                          style: bigFont,
                        )
                      ],
                    ),
                  ),
                ),
              ),
              //),
              //เพิ่ม comment
              Divider(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      Text(
                        'หมายเหตุ',
                        style: bigFont,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          controller: commentController,
                          validator: RequiredValidator(
                              errorText: "กรุณาระบุข้อความหมายเหตุ"),
                          onSaved: (value) =>
                              shareCustomerModel.comment = value,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'ระบุหมายเหตุ')),
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        height: 50,
                        width: 150,
                        child: ElevatedButton(
                            onPressed: () => submitComment(),
                            child: Text('บันทึก')),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  int totalInterestReceive(
      ShareModel shareModel,
      ShareCustomerModel shareCustomerModel,
      List<ShareCustomerModel> shareCustomerModels) {
    int interestTotal = 0;
    for (int i = 0; i < shareCustomerModel.sequence - 1; i++) {
      int interest = shareCustomerModels[i].interest == null
          ? 0
          : shareCustomerModels[i].interest!;
      interestTotal += interest;
    }
    return interestTotal;
  }

  int lastReceive(
      ShareModel shareModel, ShareCustomerModel shareCustomerModel) {
    return shareModel.pay! + shareCustomerModel.interest!;
  }

  submitComment() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      showDialog(
        context: context,
        builder: (context) => Container(
            child: AlertDialog(
          scrollable: true,
          title: Text('ยืนยันตั้งค่า'),
          content: Form(
              child: Column(
            children: [
              Text('เพื่อเป็นการยืนยันให้บันทึกหมายเหตุ'),
              Text('กรุณาพิมพ์ ${apiModel.inputSubmit} ในกล่องข้อความ'),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: TextFormField(
                  controller: submitController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'พิมพ์ข้อความ ${apiModel.inputSubmit} ที่นี่'),
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
                            onPressed: () async {
                              if (submitController.text ==
                                  apiModel.inputSubmit) {
                                final Response response =
                                    await Provider.of<ShareCustomerProvider>(
                                            context,
                                            listen: false)
                                        .updateComment(apiModel, shareModel,
                                            shareCustomerModel);
                                if (response.statusCode == 201) {
                                  Navigator.pop(context);
                                  submitController.clear();

                                  FocusScope.of(context).unfocus();
                                  //call snackbar tell user
                                  final snackBar = SnackBar(
                                      content:
                                          Text('บันทึกหมายเหตุเรียบร้อยแล้ว'));

                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
                                }
                              }
                            },
                            child: Text('ตกลง'),
                            style:
                                ElevatedButton.styleFrom(primary: Colors.green),
                          )),
                      SizedBox(
                          width: 100,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('ยกเลิก'),
                            style:
                                ElevatedButton.styleFrom(primary: Colors.red),
                          )),
                    ],
                  ),
                ),
              )
            ],
          )),
        )),
      );
      // final Response response =
      //     Provider.of<ShareCustomerProvider>(context, listen: false)
      //         .updateComment(apiModel, shareModel, shareCustomerModel);
      // if (response.statusCode == 201) {
      //   //do some thing
      // }
    }
  }
}

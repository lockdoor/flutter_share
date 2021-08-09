import 'package:flutter/material.dart';
import 'package:flutter_share/models/api.dart';
import 'package:flutter_share/models/share/share.dart';
import 'package:flutter_share/providers/api.dart';
import 'package:flutter_share/providers/shareCustomer.dart';
import 'package:provider/provider.dart';

class ShareShowStairHome extends StatefulWidget {
  final int tab;
  final ShareModel shareModel;

  const ShareShowStairHome(
      {Key? key, required this.tab, required this.shareModel})
      : super(key: key);

  @override
  _ShareShowStairHomeState createState() => _ShareShowStairHomeState();
}

class _ShareShowStairHomeState extends State<ShareShowStairHome> {
  int tab = 1;
  Widget myBody = Scaffold();
  late ShareModel shareModel;
  late ApiModel apiModel;
  String title = "รายละเอียด";
  //เพิ่มการจับภาพหน้าจอ
  //ScreenshotController screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    apiModel = context.read<ApiProvider>().api;
    shareModel = widget.shareModel;
    Provider.of<ShareCustomerProvider>(context, listen: false)
        .initData(apiModel, shareModel);
    tabMyBody(widget.tab);
    print('from share home shareId is ' + shareModel.shareID.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('ชื่อวงแชร์: ${shareModel.name} - $title'),
      // ),
      body: myBody,
      bottomNavigationBar: Container(
        color: Colors.blue.shade300,
        width: 500,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
                onPressed: () {
                  setState(() {
                    shareShowBidDetail();
                  });
                },
                icon: Icon(Icons.article)),
            IconButton(
                onPressed: () {
                  setState(() {
                    shareShowBidInterest();
                  });
                },
                icon: Icon(Icons.filter_vintage_sharp)),
            IconButton(
                onPressed: () {
                  setState(() {
                    shareShowBidPay();
                  });
                },
                icon: Icon(Icons.person)),
          ],
        ),
      ),
    );
  }

  void shareShowBidDetail() {
    title = 'รายละเอียด';
    //myBody = ShareShowBidDetail(shareModel: shareModel, title: title);
  }

  void shareShowBidInterest() {
    title = 'ดอกเบี้ย';
    // myBody = ShareShowBidInterest(
    //   shareModel: this.shareModel,
    //   title: this.title,
    // );
  }

  void shareShowBidPay() {
    title = 'เรตส่ง';
    //myBody = ShareShowBidPay(shareModel: shareModel, title: title);
  }

  void tabMyBody(tab) {
    if (tab == 1)
      shareShowBidDetail();
    else if (tab == 2)
      shareShowBidInterest();
    else if (tab == 3) shareShowBidPay();
  }
}

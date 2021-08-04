import 'package:flutter/material.dart';
import 'package:flutter_share/models/api.dart';
import 'package:flutter_share/models/share/share.dart';
import 'package:flutter_share/providers/api.dart';
import 'package:flutter_share/providers/shareCustomer.dart';
import 'package:flutter_share/screen/share/shareFollowInterest/shareShowFollowInterestDetail.dart';
import 'package:flutter_share/screen/share/shareFollowInterest/shareShowFollowInterestInterest.dart';
import 'package:provider/provider.dart';

class ShareShowFollowInterestHome extends StatefulWidget {
  final tab;
  final share;
  const ShareShowFollowInterestHome(
      {Key? key, required this.tab, required this.share})
      : super(key: key);

  @override
  _ShareShowFollowInterestHomeState createState() =>
      _ShareShowFollowInterestHomeState();
}

class _ShareShowFollowInterestHomeState
    extends State<ShareShowFollowInterestHome> {
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
    shareModel = widget.share;
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
                    shareShowFollowInterestDetail();
                  });
                },
                icon: Icon(Icons.article)),
            IconButton(
                onPressed: () {
                  setState(() {
                    shareShowFollowInterestInterest();
                  });
                },
                icon: Icon(Icons.filter_vintage_sharp)),
            IconButton(
                onPressed: () {
                  setState(() {
                    shareShowFollowInterestPay();
                  });
                },
                icon: Icon(Icons.person)),
          ],
        ),
      ),
    );
  }

  void shareShowFollowInterestDetail() {
    title = 'รายละเอียด';
    myBody =
        ShareShowFollowInterestDetail(shareModel: shareModel, title: title);
  }

  void shareShowFollowInterestInterest() {
    title = 'ดอกเบี้ย';
    myBody = ShareShowFollowInterestInterest(
      shareModel: this.shareModel,
      title: this.title,
    );
  }

  void shareShowFollowInterestPay() {
    title = 'เรตส่ง';
    // myBody = ShareShowFollowInterestPay(shareModel: shareModel, title: title);
  }

  void tabMyBody(tab) {
    if (tab == 1)
      shareShowFollowInterestDetail();
    else if (tab == 2)
      shareShowFollowInterestInterest();
    else if (tab == 3) shareShowFollowInterestPay();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_share/models/share/share.dart';
import 'package:flutter_share/models/share/shareCustomer.dart';
import 'package:flutter_share/providers/shareCustomer.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:intl/intl.dart';

import '../../capture.dart';

class ShareShowBidPay extends StatefulWidget {
  final shareModel;
  final title;
  const ShareShowBidPay(
      {Key? key, required this.shareModel, required this.title})
      : super(key: key);

  @override
  _ShareShowBidPayState createState() => _ShareShowBidPayState();
}

class _ShareShowBidPayState extends State<ShareShowBidPay> {
  late ShareModel shareModel;
  late List<ShareCustomerModel> shareCustomers;
  ScreenshotController screenshotController = ScreenshotController();
  int? adminFirstSequence;
  int? adminLastSequence;

  @override
  void initState() {
    super.initState();
    shareModel = widget.shareModel;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, ShareCustomerProvider provider,
          Widget? child) {
        shareCustomers = provider.shareCustomers;
        if (shareCustomers.length != 0) {
          adminFirstSequence = shareModel.firstReceive == true
              ? shareCustomers[0].sequence
              : null;
          adminLastSequence = shareModel.lastReceive == true
              ? shareCustomers[shareCustomers.length - 1].sequence
              : null;
        }
        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [Icon(Icons.person), Text(' : ' + shareModel.name)],
            ),
            actions: [
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
                  icon: Icon(Icons.share))
            ],
          ),
          body: SingleChildScrollView(
            child: Screenshot(
              controller: screenshotController,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        Container(
                          child: Text(
                            'ชื่อวงแชร์: ${shareModel.name} - ${widget.title}',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        Container(
                          child: ListView.separated(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                return myList(this.shareCustomers, index);
                              },
                              separatorBuilder: (context, index) {
                                return Divider();
                              },
                              itemCount: shareCustomers.length),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget showDate(ShareCustomerModel shareCustomerModel) {
    if ((shareCustomerModel.sequence == adminFirstSequence ||
            shareCustomerModel.sequence == adminLastSequence) ||
        (shareCustomerModel.interest != null &&
            shareCustomerModel.interest != 0)) {
      return Text(DateFormat('dd/MM').format(shareCustomerModel.shareDate));
    } else {
      return Text('');
    }
  }

  Widget showPay(ShareCustomerModel shareCustomerModel) {
    int interest =
        shareCustomerModel.interest == null ? 0 : shareCustomerModel.interest!;
    int pay = this.shareModel.pay + interest;
    if ((shareCustomerModel.sequence == adminFirstSequence ||
        shareCustomerModel.sequence == adminLastSequence)) {
      return Text('ท้าว');
    } else {
      return Text(pay.toString());
    }
  }

  Widget myList(List<ShareCustomerModel> shareCustomers, index) {
    ShareCustomerModel shareCustomer = shareCustomers[index];
    return ListTile(
      leading: CircleAvatar(child: Text(shareCustomer.sequence.toString())),
      title: Row(
        children: [
          Expanded(flex: 1, child: showDate(shareCustomer)),
          Expanded(
            flex: 3,
            child: Text(shareCustomer.personName.toString()),
          ),
          Expanded(flex: 1, child: showPay(shareCustomer)),
        ],
      ),
    );
  }
}

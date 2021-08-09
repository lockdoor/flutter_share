import 'package:flutter/material.dart';
import 'package:flutter_share/models/share/share.dart';
import 'package:flutter_share/models/share/shareCustomer.dart';
import 'package:flutter_share/providers/shareCustomer.dart';
import 'package:flutter_share/screen/capture.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:intl/intl.dart';

class ShareShowFollowInterestPay extends StatefulWidget {
  final ShareModel shareModel;
  final String title;
  const ShareShowFollowInterestPay(
      {Key? key, required this.shareModel, required this.title})
      : super(key: key);

  @override
  _ShareShowFollowInterestPayState createState() =>
      _ShareShowFollowInterestPayState();
}

class _ShareShowFollowInterestPayState
    extends State<ShareShowFollowInterestPay> {
  late ShareModel shareModel;
  late List<ShareCustomerModel> shareCustomers;
  ScreenshotController screenshotController = ScreenshotController();
  int? adminFirstSequence;
  int? adminLastSequence;
  final DateTime yesterday = new DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day - 1);
  TextStyle shareDeath = TextStyle(color: Colors.red);

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
    if (shareCustomerModel.shareDate.isBefore(yesterday)) {
      return Text(
        DateFormat('dd/MM').format(shareCustomerModel.shareDate),
        style: shareDeath,
      );
    } else {
      return Text(DateFormat('dd/MM').format(shareCustomerModel.shareDate));
    }
  }

  Widget showPay(ShareCustomerModel shareCustomerModel) {
    if ((shareCustomerModel.sequence == adminFirstSequence ||
        shareCustomerModel.sequence == adminLastSequence)) {
      return Text('ท้าว');
    } else {
      if (shareCustomerModel.shareDate.isBefore(yesterday)) {
        return Text('${shareModel.pay! + shareModel.interestFix!}',
            style: shareDeath);
      } else {
        return Text('${shareModel.pay}');
      }
    }
  }

  Widget showName(ShareCustomerModel shareCustomerModel) {
    if (shareCustomerModel.personName == null) {
      return Text('');
    } else if (shareCustomerModel.shareDate.isBefore(yesterday)) {
      return Text(
        shareCustomerModel.personName.toString(),
        style: shareDeath,
      );
    } else {
      return Text(
        shareCustomerModel.personName.toString(),
      );
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
            child: showName(shareCustomer),
            // Text(shareCustomer.personName == null
            //     ? ''
            //     : shareCustomer.personName!),
          ),
          Expanded(flex: 1, child: showPay(shareCustomer)),
        ],
      ),
      onTap: () {
        // if (shareCustomer.interest != 0 && shareCustomer.interest != null) {
        //   Navigator.push(context, MaterialPageRoute(builder: (context) {
        //     return ShareShowBidCustomerReceive(
        //         shareCustomerModel: shareCustomer, shareModel: shareModel);
        //   }));
        // }
      },
    );
  }
}

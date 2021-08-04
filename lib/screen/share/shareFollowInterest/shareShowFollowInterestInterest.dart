import 'package:flutter/material.dart';
import 'package:flutter_share/models/api.dart';
import 'package:flutter_share/models/share/share.dart';
import 'package:flutter_share/models/share/shareCustomer.dart';
import 'package:flutter_share/providers/api.dart';
import 'package:flutter_share/providers/shareCustomer.dart';
import 'package:flutter_share/screen/share/shareBid/editCustomer.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:intl/intl.dart';

import '../../capture.dart';

class ShareShowFollowInterestInterest extends StatefulWidget {
  final shareModel;
  final title;
  const ShareShowFollowInterestInterest(
      {Key? key, required this.shareModel, required this.title})
      : super(key: key);

  @override
  _ShareShowFollowInterestInterestState createState() =>
      _ShareShowFollowInterestInterestState();
}

class _ShareShowFollowInterestInterestState
    extends State<ShareShowFollowInterestInterest> {
  late ShareModel shareModel;
  late ApiModel apiModel;
  int? adminFirstSequence;
  int? adminLastSequence;
  ScreenshotController screenshotController = ScreenshotController();
  bool canEdit = false;

  @override
  void initState() {
    super.initState();
    shareModel = widget.shareModel;
    apiModel = context.read<ApiProvider>().api;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, ShareCustomerProvider provider,
          Widget? child) {
        List<ShareCustomerModel> shareCustomers = provider.shareCustomers;
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
              children: [
                Icon(Icons.filter_vintage_sharp),
                Text(' : ' + shareModel.name)
              ],
            ),
            actions: [
              IconButton(
                  onPressed: () {
                    setState(() {
                      canEdit = !canEdit;
                    });
                  },
                  icon: Icon(canEdit == true
                      ? Icons.lock_open_outlined
                      : Icons.lock_outline)),
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
          body: content(shareCustomers),
        );
      },
    );
  }

  Widget content(List<ShareCustomerModel> shareCustomers) {
    return SingleChildScrollView(
      child: Screenshot(
        controller: screenshotController,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Container(
            color: Colors.white,
            child: Column(
              children: [
                Container(
                  child: Center(
                    child: Text(
                      'ชื่อวงแชร์: ${shareModel.name} - ${widget.title}',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                Container(
                  child: ListView.separated(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        ShareCustomerModel shareCustomer =
                            shareCustomers[index];
                        return myList(shareCustomer);
                      },
                      separatorBuilder: (context, index) {
                        return Divider();
                      },
                      itemCount: shareCustomers.length),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String showInterest(ShareCustomerModel shareCustomerModel) {
    if (shareCustomerModel.sequence == adminFirstSequence ||
        shareCustomerModel.sequence == adminLastSequence) {
      return 'ท้าว';
    } else {
      return shareModel.interestFix.toString();
    }
  }

  Widget showName(ShareCustomerModel shareCustomerModel) {
    Widget name = shareCustomerModel.personName == null
        ? Align(
            alignment: Alignment.centerLeft,
            child: Icon(
              Icons.person_add,
            ))
        : Text(shareCustomerModel.personName!);

    if (shareCustomerModel.sequence == adminFirstSequence ||
        shareCustomerModel.sequence == adminLastSequence ||
        shareCustomerModel.locker == true) {
      return name;
    } else {
      if (canEdit == true) {
        return InkWell(
          child: name,
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EditShareCustomerCustomer(
                          sharecustomer: shareCustomerModel,
                        )));
          },
        );
      } else {
        return name;
      }
    }
  }

  Widget myList(ShareCustomerModel shareCustomer) {
    return ListTile(
        leading: CircleAvatar(
          child: Text(shareCustomer.sequence.toString()),
        ),
        title: Row(
          children: [
            Expanded(
                flex: 1,
                child:
                    Text(DateFormat('dd/MM').format(shareCustomer.shareDate))),
            Expanded(flex: 3, child: showName(shareCustomer)),
            Expanded(flex: 1, child: Text(showInterest(shareCustomer)))
          ],
        ));
  }
}

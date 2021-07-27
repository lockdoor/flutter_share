//import 'dart:convert';
//capture screenshot
//https://www.youtube.com/watch?v=rABnaF-Xk3E

import 'package:flutter/material.dart';
import 'package:flutter_share/models/api.dart';
import 'package:flutter_share/models/customer/customer.dart';
import 'package:flutter_share/models/share/share.dart';
import 'package:flutter_share/models/share/shareCustomer.dart';
import 'package:flutter_share/providers/api.dart';
import 'package:flutter_share/providers/customers.dart';
import 'package:flutter_share/providers/shareCustomer.dart';
import 'package:flutter_share/screen/share/shareBid/editCustomer.dart';
import 'package:flutter_share/screen/share/shareBid/editInterest.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ShareShowBidInterest extends StatefulWidget {
  final shareModel;
  const ShareShowBidInterest({Key? key, required this.shareModel})
      : super(key: key);

  @override
  _ShareShowBidInterestState createState() => _ShareShowBidInterestState();
}

class _ShareShowBidInterestState extends State<ShareShowBidInterest> {
  late ShareModel shareModel;
  late List<ShareCustomerModel> shareCustomerModelList;
  late List<CustomerModel> customers;
  CustomerModel? customer;
  late ApiModel apiModel;
  int? adminFirstSequence;
  int? adminLastSequence;
  @override
  void initState() {
    super.initState();
    apiModel = context.read<ApiProvider>().api;
    shareModel = widget.shareModel;
    // Provider.of<ShareCustomerProvider>(context, listen: false)
    //     .initData(apiModel, shareModel);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder:
        (BuildContext context, ShareCustomerProvider provider, Widget? child) {
      //this.shareCustomerModelList = provider.shareCustomers;
      this.shareCustomerModelList =
          context.watch<ShareCustomerProvider>().shareCustomers;
      this.customers = context.watch<CustomerProvider>().customers;
      if (shareCustomerModelList.length != 0) {
        adminFirstSequence = shareModel.firstReceive == true
            ? shareCustomerModelList[0].sequence
            : null;
        adminLastSequence = shareModel.lastReceive == true
            ? shareCustomerModelList[shareCustomerModelList.length - 1].sequence
            : null;
      }
      return Scaffold(
          body: Center(
        child: Container(
          width: 800,
          child: Column(
            children: [
              Flexible(
                child: ListView.builder(
                    itemCount: shareCustomerModelList.length,
                    itemBuilder: (context, index) {
                      return myList(shareCustomerModelList, index);
                    }),
              ),
            ],
          ),
        ),
      ));
    });
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
    }
  }

  Widget showSequence(ShareCustomerModel shareCustomerModel) {
    if (shareCustomerModel.sequence == adminFirstSequence ||
        shareCustomerModel.sequence == adminLastSequence) {
      return Icon(Icons.lock_rounded);
    } else if (shareCustomerModel.locker == true) {
      return InkWell(
        child: Icon(Icons.lock_rounded),
        onTap: () {
          Provider.of<ShareCustomerProvider>(context, listen: false)
              .setLocker(apiModel, shareModel, shareCustomerModel);
        },
      );
    } else {
      return TextButton(
        child: Text(
          shareCustomerModel.sequence.toString(),
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () {
          Provider.of<ShareCustomerProvider>(context, listen: false)
              .setLocker(apiModel, shareModel, shareCustomerModel);
        },
      );
    }
  }

  Widget showInterest(ShareCustomerModel shareCustomerModel) {
    Widget interest;
    if (shareCustomerModel.interest == null ||
        shareCustomerModel.interest == 0) {
      interest = Align(
          alignment: Alignment.centerRight,
          child: Icon(Icons.filter_vintage_sharp));
    } else {
      interest = Align(
          alignment: Alignment.centerRight,
          child: Text(shareCustomerModel.interest.toString()));
    }
    // Widget interest = shareCustomerModel.interest == null
    //     ? Align(
    //         alignment: Alignment.centerRight,
    //         child: Icon(Icons.filter_vintage_sharp))
    //     : Align(
    //         alignment: Alignment.centerRight,
    //         child: Text(shareCustomerModel.interest.toString()));
    if (shareCustomerModel.sequence == adminFirstSequence ||
        shareCustomerModel.sequence == adminLastSequence) {
      return Align(alignment: Alignment.centerRight, child: Text('ท้าว'));
    } else if (shareCustomerModel.locker == true ||
        shareCustomerModel.personName == null) {
      return interest;
    } else {
      return InkWell(
        child: interest,
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => EditInterest(
                        shareModel: shareModel,
                        shareCustomer: shareCustomerModel,
                        adminFirstSequence: adminFirstSequence,
                        adminLastSequence: adminLastSequence,
                      )));
        },
      );
    }
  }

  ListTile myList(List<ShareCustomerModel> items, int index) {
    ShareCustomerModel shareCustomerModel = items[index];
    return ListTile(
      leading: CircleAvatar(
          child: showSequence(
              shareCustomerModel) //Text(items[index].sequence.toString()),
          ),
      //ให้มีการเข้าไปเช็คว่ามีการเปียแชร์ไปหรือยังโดยมีการเช็คดอกเบี้ย และวันที่รับแชร์
      title: Row(
        //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(flex: 1, child: showDate(shareCustomerModel)),
          Expanded(
            flex: 3,
            child: showName(shareCustomerModel),
          ),
          Expanded(flex: 1, child: showInterest(shareCustomerModel)),
        ],
      ),
    );
  }
}

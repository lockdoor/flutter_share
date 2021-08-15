import 'package:flutter/material.dart';
import 'package:flutter_share/models/api.dart';
import 'package:flutter_share/models/customer/customer.dart';
import 'package:flutter_share/models/share/share.dart';
import 'package:flutter_share/models/share/shareCustomer.dart';
import 'package:flutter_share/models/share/transaction.dart';
import 'package:flutter_share/providers/api.dart';
import 'package:flutter_share/providers/share.dart';
import 'package:flutter_share/providers/shareCustomer.dart';
import 'package:provider/provider.dart';

class CustomerDetail extends StatefulWidget {
  final CustomerModel customerModel;
  const CustomerDetail({Key? key, required this.customerModel})
      : super(key: key);

  @override
  _CustomerDetailState createState() => _CustomerDetailState();
}

class _CustomerDetailState extends State<CustomerDetail> {
  late ApiModel apiModel;
  late CustomerModel customerModel;
  late List<ShareModel> shareModels;
  //late List<CustomerModel> customerModels;
  late List<ShareCustomerModel> shareCustomerModels;
  late List<TransactionModel> transactionModels;
  @override
  void initState() {
    super.initState();
    apiModel = context.read<ApiProvider>().api;
    customerModel = widget.customerModel;
    shareModels = context.read<ShareProvider>().shares;
    //customerModels = context.read<>()
    Provider.of<ShareCustomerProvider>(context, listen: false)
        .getShareOpenByCustomer(apiModel, customerModel);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, ShareCustomerProvider provider,
          Widget? child) {
        List<ShareCustomerModel> shareCustomerModels =
            provider.sharesByCustomer;
        return Scaffold(
            appBar: AppBar(
              title: Text('ลูกค้า ${customerModel.nickName}'),
            ),
            body: SingleChildScrollView(
              child: ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: shareCustomerModels.length,
                  itemBuilder: (context, index) {
                    return myCard(shareCustomerModels, index);
                  }),
            ));
      },
    );
  }

  Widget myCard(List<ShareCustomerModel> shareCustomerModels, int index) {
    ShareCustomerModel shareCustomerModel =
        shareCustomerModels.elementAt(index);
    if (checkAdmin(shareModels, shareCustomerModel))
      return SizedBox.shrink();
    else
      return Card(
        child: Column(
          children: [
            Text("วงแชร์: ${shareCustomerModel.shareName}"),
            Text(shareCustomerModel.sequence.toString())
          ],
        ),
      );
  }

  bool checkAdmin(
      List<ShareModel> shareModels, ShareCustomerModel shareCustomerModel) {
    int index = shareModels.indexWhere((ShareModel shareModel) =>
        shareModel.shareID == shareCustomerModel.shareID);
    ShareModel shareModel = shareModels.elementAt(index);
    int? firstReceive;
    int? lastReCeive;
    if (shareModel.firstReceive == true) firstReceive = 1;
    if (shareModel.lastReceive == true) lastReCeive = shareModel.amount;
    if (this.customerModel.admin == true &&
        (shareCustomerModel.sequence == firstReceive ||
            shareCustomerModel.sequence == lastReCeive)) {
      return true;
    } else {
      return false;
    }
  }
}

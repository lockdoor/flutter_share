import 'package:flutter/material.dart';
import 'package:flutter_share/models/api.dart';
import 'package:flutter_share/models/share/share.dart';
import 'package:flutter_share/models/share/shareCustomer.dart';
import 'package:flutter_share/models/share/transaction.dart';
import 'package:flutter_share/providers/api.dart';
//import 'package:flutter_share/providers/customers.dart';
import 'package:flutter_share/providers/share.dart';
import 'package:flutter_share/providers/shareCustomer.dart';
import 'package:flutter_share/providers/transaction.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

//หน้ารวมวงแชร์
class CheckCustomerPay extends StatefulWidget {
  const CheckCustomerPay({Key? key}) : super(key: key);

  @override
  _CheckCustomerPayState createState() => _CheckCustomerPayState();
}

class _CheckCustomerPayState extends State<CheckCustomerPay> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('เช็คลูกค้าส่งแชร์'),
      ),
      body: Consumer(
        builder: (context, ShareProvider provider, child) {
          final List<ShareModel> shares = context.watch<ShareProvider>().shares;
          return GridView.builder(
            itemCount: shares.length,
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
            itemBuilder: (context, index) {
              return myCard(index, provider.shares[index]);
            },
          );
        },
      ),
    );
  }

  MaterialColor color(index) {
    List<MaterialColor> colors = <MaterialColor>[
      Colors.red,
      Colors.green,
      Colors.purple,
      Colors.yellow,
      Colors.pink
    ];
    if (index + 1 < colors.length) {
      return colors.elementAt(index);
    } else
      return colors.elementAt(index % colors.length);
  }

  Widget myCard(int index, ShareModel share) {
    return Card(
        color: color(index),
        child: Center(
          child: InkWell(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'ชื่อวง : ${share.name}',
                  style: TextStyle(fontSize: 18),
                ),
                Text(
                  'เลขที่ : ${share.shareID}',
                  style: TextStyle(fontSize: 18),
                ),
                Text(
                  'ประเภท : ${share.shareType}',
                  style: TextStyle(fontSize: 18),
                ),
                Text(
                  'เงินต้น : ${share.principle}',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ListDateSharePay(shareModel: share)));
              //print('from share list share id is ' + share.shareID.toString());
            },
          ),
        ));
  }
}

//หน้าแชร์แต่ละวงแต่ละวัน
class ListDateSharePay extends StatefulWidget {
  final ShareModel shareModel;
  const ListDateSharePay({Key? key, required this.shareModel})
      : super(key: key);

  @override
  _ListDateSharePayState createState() => _ListDateSharePayState();
}

class _ListDateSharePayState extends State<ListDateSharePay> {
  late ShareModel shareModel;
  late ApiModel apiModel;
  late List<ShareCustomerModel> shareCustomerModels;
  int amountAdmin = 0;
  @override
  void initState() {
    super.initState();
    shareModel = widget.shareModel;
    apiModel = context.read<ApiProvider>().api;
    Provider.of<ShareCustomerProvider>(context, listen: false)
        .getSharePersonByDateWithNotPaid(apiModel, shareModel);
    if (shareModel.firstReceive == true) amountAdmin++;
    if (shareModel.lastReceive == true) amountAdmin++;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, ShareCustomerProvider provider,
          Widget? child) {
        List<ShareCustomerModel> shareCustomerModels = provider.sharesNoPaid;
        return Scaffold(
            appBar: AppBar(
              title: Row(
                children: [Icon(Icons.details), Text(" : ${shareModel.name}")],
              ),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.separated(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: shareCustomerModels.length,
                  separatorBuilder: (context, index) {
                    return Divider();
                  },
                  itemBuilder: (context, index) {
                    ShareCustomerModel shareCustomer =
                        shareCustomerModels[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(shareCustomer.sequence.toString()),
                      ),
                      title: Text(DateFormat('E dd/MM/yyyy')
                          .format(shareCustomer.shareDate)),
                      trailing: Text(shareCustomer.notPaid! - amountAdmin == 0
                          ? ""
                          : "ขาดส่ง ${shareCustomer.notPaid! - amountAdmin}"),
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CustomerPayDate(
                                  shareModel: shareModel,
                                  shareCustomerModel: shareCustomer))),
                    );
                  },
                ),
              ),
            ));
      },
    );
  }
}

//หน้าแสดงแชร์แต่ละวงส่งแต่ละวันแต่ละคน
class CustomerPayDate extends StatefulWidget {
  final ShareModel shareModel;
  final ShareCustomerModel shareCustomerModel;
  const CustomerPayDate(
      {Key? key, required this.shareModel, required this.shareCustomerModel})
      : super(key: key);

  @override
  _CustomerPayDateState createState() => _CustomerPayDateState();
}

class _CustomerPayDateState extends State<CustomerPayDate> {
  late ShareModel shareModel;
  late ShareCustomerModel shareCustomerModel;
  late List<ShareCustomerModel> shareCustomerModels;
  late ApiModel apiModel;
  int? adminFirst;
  int? adminLast;
  final DateTime yesterday = new DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day - 1);
  final DateTime today = new DateTime.now();

  @override
  void initState() {
    super.initState();
    shareModel = widget.shareModel;
    shareCustomerModel = widget.shareCustomerModel;
    apiModel = context.read<ApiProvider>().api;
    Provider.of<TransactionProvider>(context, listen: false)
        .initData(apiModel, shareCustomerModel);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder:
          (BuildContext context, TransactionProvider provider, Widget? child) {
        List<TransactionModel> transactions = provider.transactions;
        if (shareModel.firstReceive == true) {
          adminFirst = 0;
        }
        if (shareModel.lastReceive == true) {
          adminLast = transactions.length - 1;
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(
                '${shareModel.name} : มือที่ ${shareCustomerModel.sequence}(${DateFormat('dd/MM').format(shareCustomerModel.shareDate)})'),
          ),
          body: SingleChildScrollView(
            // child: Text('555'),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: transactions.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2),
                  itemBuilder: (context, index) {
                    TransactionModel transactionModel = transactions[index];
                    return myCard(index, transactionModel);
                  }),
            ),
          ),
        );
      },
    );
  }

  MaterialColor color(int index, TransactionModel transactionModel) {
    if (this.adminFirst == index || this.adminLast == index)
      return Colors.blue;
    else if (transactionModel.paid == true)
      return Colors.green;
    else if (shareCustomerModel.shareDate.isBefore(today))
      return Colors.red;
    else
      return Colors.yellow;
  }

  Widget myCard(int index, TransactionModel transactionModel) {
    return Card(
      color: color(index, transactionModel),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'ลำดับที่ : ${transactionModel.sequence}',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'ชื่อ : ${transactionModel.nickName}',
              style: TextStyle(fontSize: 18),
            ),
            if (this.adminFirst != index && this.adminLast != index)
              Text(
                'วันที่ส่ง : ${transactionModel.paidDate == null ? "" : DateFormat('dd/MM/yy').format(transactionModel.paidDate!)}',
                style: TextStyle(fontSize: 18),
              ),
            if (this.adminFirst == index || this.adminLast == index)
              Text('ท้าว', style: TextStyle(fontSize: 18))
            else
              SizedBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox(
                      checkColor: Colors.white,
                      //fillColor: MaterialStateProperty.resolveWith(getColor),
                      value: transactionModel.paid,
                      onChanged: (bool? value) async {
                        setState(() {
                          transactionModel.paid = value!;
                        });
                        if (transactionModel.paid == true)
                          transactionModel.paidDate = today;
                        else
                          transactionModel.paidDate = null;
                        await Provider.of<TransactionProvider>(context,
                                listen: false)
                            .setPaidDate(
                                apiModel, transactionModel, shareCustomerModel);
                      },
                    ),
                    Text('ส่งแชร์', style: TextStyle(fontSize: 18))
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

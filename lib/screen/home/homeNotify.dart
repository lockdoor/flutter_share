import 'package:flutter/material.dart';
import 'package:flutter_share/models/api.dart';
import 'package:flutter_share/models/share/shareCustomer.dart';
import 'package:flutter_share/providers/api.dart';
import 'package:flutter_share/providers/shareCustomer.dart';
import 'package:provider/provider.dart';

class HomeNotify extends StatefulWidget {
  const HomeNotify({Key? key}) : super(key: key);

  @override
  _HomeNotifyState createState() => _HomeNotifyState();
}

class _HomeNotifyState extends State<HomeNotify> {
  late ApiModel apiModel;
  final DateTime today =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  final DateTime tomorrow = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day + 1);

  @override
  void initState() {
    super.initState();
    apiModel = context.read<ApiProvider>().api;
    Provider.of<ShareCustomerProvider>(context, listen: false)
        .getSharebyWeek(apiModel);
    print(today.toIso8601String());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, ShareCustomerProvider provider,
          Widget? child) {
        List<ShareCustomerModel> shareCustomerModelToday =
            List.of(provider.shareCustomers)
                .where((ShareCustomerModel shareCustomerModel) =>
                    shareCustomerModel.shareDate.year == today.year &&
                    shareCustomerModel.shareDate.month == today.month &&
                    shareCustomerModel.shareDate.day == today.day)
                .toList();
        List<ShareCustomerModel> shareCustomerModelToMorrow =
            List.of(provider.shareCustomers)
                .where((ShareCustomerModel shareCustomerModel) =>
                    shareCustomerModel.shareDate.year == tomorrow.year &&
                    shareCustomerModel.shareDate.month == tomorrow.month &&
                    shareCustomerModel.shareDate.day == tomorrow.day)
                .toList();
        List<ShareCustomerModel> shareCustomerModelWeek =
            List.of(provider.shareCustomers)
                .where((ShareCustomerModel shareCustomerModel) =>
                    !(shareCustomerModel.shareDate.year == today.year &&
                        shareCustomerModel.shareDate.month == today.month &&
                        shareCustomerModel.shareDate.day == today.day) &&
                    !(shareCustomerModel.shareDate.year == tomorrow.year &&
                        shareCustomerModel.shareDate.month == tomorrow.month &&
                        shareCustomerModel.shareDate.day == tomorrow.day))
                .toList();
        return Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      'แชร์วันนี้ ${today.toIso8601String()}',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                  if (shareCustomerModelToday.length != 0)
                    ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: shareCustomerModelToday.length,
                        itemBuilder: (context, index) {
                          return Text(shareCustomerModelToday[index]
                              .shareDate
                              .toIso8601String());
                        })
                  else
                    Text('ไม่มีแชร์วันนี้'),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      'แชร์วันพรุ่งนี้ ${tomorrow.toIso8601String()}',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                  if (shareCustomerModelToMorrow.length != 0)
                    ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: shareCustomerModelToMorrow.length,
                        itemBuilder: (context, index) {
                          return Text(shareCustomerModelToMorrow[index]
                              .shareDate
                              .toIso8601String());
                        })
                  else
                    Text('ไม่มีแชร์วันพรุ่งนี้'),
                  ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: shareCustomerModelWeek.length,
                      itemBuilder: (context, index) {
                        return Text(shareCustomerModelWeek[index]
                            .shareDate
                            .toIso8601String());
                      })
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_share/models/api.dart';
import 'package:flutter_share/models/share/share.dart';
import 'package:flutter_share/providers/api.dart';
import 'package:flutter_share/providers/share.dart';
import 'package:flutter_share/screen/home.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';

class ShareListNoOpen extends StatefulWidget {
  const ShareListNoOpen({Key? key}) : super(key: key);

  @override
  _ShareListNoOpenState createState() => _ShareListNoOpenState();
}

class _ShareListNoOpenState extends State<ShareListNoOpen> {
  late ApiModel apiModel;
  final TextEditingController alertTextFrom = TextEditingController();

  @override
  void initState() {
    super.initState();
    apiModel = context.read<ApiProvider>().api;
    Provider.of<ShareProvider>(context, listen: false).getShareNoOpen(apiModel);
  }

  @override
  void dispose() {
    super.dispose();
    alertTextFrom.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, ShareProvider provider, Widget? child) {
        final List<ShareModel> shares = provider.sharesNoOpen;
        return Scaffold(
          appBar: AppBar(
              title: Text(
            'วงแชร์ที่ปิดไปแล้ว',
          )),
          body: GridView.builder(
            itemCount: shares.length,
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
            itemBuilder: (context, index) {
              return myCard(index, shares[index]);
            },
          ),
        );
      },
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
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        scrollable: true,
                        title: share.isOpen == false
                            ? Text('ยืนยันจะเปิดแชร์วงนี้')
                            : Text('ยืนยันจะปิดแชร์วงนี้'),
                        content: Container(
                          child: Column(
                            children: [
                              share.isOpen == false
                                  ? Text('เพื่อเป็นการยืนยันเปิดแชร์วงนี้')
                                  : Text('เพื่อเป็นการยืนยันจะปิดแชร์วงนี้'),
                              Text(
                                  'กรุณาพิมพ์ ${apiModel.inputSubmit} ในกล่องข้อความ'),
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: TextFormField(
                                  controller: alertTextFrom,
                                  decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      hintText:
                                          'พิมพ์ข้อความ ${apiModel.inputSubmit} ที่นี่'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, 'Cancel'),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              if (alertTextFrom.text == apiModel.inputSubmit) {
                                alertTextFrom.clear();
                                Response response =
                                    await Provider.of<ShareProvider>(context,
                                            listen: false)
                                        .onOffShare(apiModel, share);
                                if (response.statusCode == 201) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Home(tab: 2)));
                                }
                              }
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      ));

              // Navigator.push(context, shareSelectRoute(share));
              // print('from share list share id is ' + share.shareID.toString());
            },
          ),
        ));
  }
}

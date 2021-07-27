//แชร์แบบดอกตาม
import 'package:flutter/material.dart';
import 'package:flutter_share/models/api.dart';
import 'package:flutter_share/providers/api.dart';
import 'package:provider/provider.dart';

class ShareAddInterestAfterReceive extends StatefulWidget {
  const ShareAddInterestAfterReceive({Key? key}) : super(key: key);
  @override
  _ShareAddInterestAfterReceiveState createState() =>
      _ShareAddInterestAfterReceiveState();
}

class _ShareAddInterestAfterReceiveState
    extends State<ShareAddInterestAfterReceive> {
  late ApiModel apiModel;
  @override
  void initState() {
    super.initState();
    apiModel = context.read<ApiProvider>().api;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('สร้างแชร์แบบดอกตาม')),
    );
  }
}

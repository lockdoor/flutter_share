import 'package:flutter/foundation.dart';
import 'package:flutter_share/models/api.dart';
//import 'package:flutter_share/models/customer/customer.dart';
import 'package:flutter_share/models/share/share.dart';

class ShareProvider with ChangeNotifier {
  List<ShareModel> shares = [];
  void initData(ApiModel apiModel) async {
    shares = await ShareModel.getAllShares(apiModel);
    notifyListeners();
  }

  addData(ApiModel apiModel, ShareModel shareModel) async {
    this.shares.add(shareModel);
    final response = await ShareModel.addShare(apiModel, shareModel);
    initData(apiModel);
    notifyListeners();
    return response;
  }
}

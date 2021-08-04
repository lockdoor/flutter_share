import 'package:flutter/foundation.dart';
import 'package:flutter_share/models/api.dart';
//import 'package:flutter_share/models/customer/customer.dart';
import 'package:flutter_share/models/share/share.dart';
import 'package:http/http.dart';

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
    //notifyListeners();
    return response;
  }

  updateShare(ApiModel apiModel, ShareModel shareModelNew,
      ShareModel shareModelOld) async {
    final Response response =
        await ShareModel.updateShare(apiModel, shareModelNew, shareModelOld);
    initData(apiModel);
    return response;
  }
}

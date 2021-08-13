import 'package:flutter/cupertino.dart';
import 'package:flutter_share/models/api.dart';
import 'package:flutter_share/models/customer/customer.dart';
import 'package:flutter_share/models/share/share.dart';
import 'package:flutter_share/models/share/shareCustomer.dart';
//import 'package:flutter_share/screen/share/shareBid/editInterest.dart';
import 'package:http/http.dart';

class ShareCustomerProvider with ChangeNotifier {
  List<ShareCustomerModel> shareCustomers = [];

  List<ShareCustomerModel> shareCusconersNoLocker = [];
  List<ShareCustomerModel> getSuggestions(String query) =>
      List.of(this.shareCusconersNoLocker).where((shareCustomer) {
        final userLower = shareCustomer.sequence.toString().toLowerCase();
        final queryLower = query.toLowerCase();
        return userLower.contains(queryLower);
      }).toList();
  void noLocker(int? adminFirstSequence, int? adminLastSequence) {
    List<ShareCustomerModel> noLocker = List.of(this.shareCustomers)
        .where((sharecustomer) => sharecustomer.locker == false)
        .toList();
    shareCusconersNoLocker = noLocker;
  }

  void initData(ApiModel apiModel, ShareModel shareModel) async {
    shareCustomers =
        await ShareCustomerModel.getAllShareCustomer(apiModel, shareModel);
    notifyListeners();
  }

  void getSharebyWeek(ApiModel apiModel) async {
    shareCustomers = await ShareCustomerModel.getSharebyWeek(apiModel);
    notifyListeners();
  }

  addCustomerToShareCustomer(
      ApiModel apiModel, CustomerModel? customerModel, sequence) async {
    //print('sequence is ' + sequence.toString());
    int index = shareCustomers
        .indexWhere((shareCustomer) => shareCustomer.sequence == sequence);
    //print('ชื่อใหม่ ' + customerModel!.nickName);
    shareCustomers[index].personID = customerModel!.personID;
    shareCustomers[index].personName = customerModel.nickName;
    //print('index is ' + index.toString());
    //print(shareCustomers[index].personName);
    final Response response =
        await ShareCustomerModel.addCustomerToShareCustomer(
            apiModel, shareCustomers[index]);
    print(response.statusCode);
    notifyListeners();
    return response;
  }

  editInterest(
      ApiModel apiModel,
      ShareModel shareModel,
      ShareCustomerModel shareCustomerOld,
      ShareCustomerModel? shareCustomerNew,
      int interest) {
    final response = ShareCustomerModel.editInterest(
            apiModel, shareCustomerOld, shareCustomerNew, interest)
        .then((response) {
      initData(apiModel, shareModel);
      setLocker(apiModel, shareModel, shareCustomerNew!);
      return response;
    });

    //initData(apiModel, shareModel);
    notifyListeners();

    return response;
  }

  setLocker(ApiModel apiModel, ShareModel shareModel,
      ShareCustomerModel shareCustomerModel) async {
    Response response =
        await ShareCustomerModel.setLocker(apiModel, shareCustomerModel)
            .then((response) {
      initData(apiModel, shareModel);
      return response;
    });
    return response;
  }

  updateComment(ApiModel apiModel, ShareModel shareModel,
      ShareCustomerModel shareCustomerModel) async {
    Response response =
        await ShareCustomerModel.updateComment(apiModel, shareCustomerModel)
            .then((response) {
      initData(apiModel, shareModel);
      return response;
    });
    return response;
  }

  void getSharePersonByDateWithNotPaid(
      ApiModel apiModel, ShareModel shareModel) async {
    shareCustomers = await ShareCustomerModel.getSharePersonByDateWithNotPaid(
        apiModel, shareModel);
    notifyListeners();
  }
}

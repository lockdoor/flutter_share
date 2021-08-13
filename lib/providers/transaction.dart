import 'package:flutter/foundation.dart';
import 'package:flutter_share/models/api.dart';
import 'package:flutter_share/models/share/shareCustomer.dart';
import 'package:flutter_share/models/share/transaction.dart';
import 'package:http/http.dart';

class TransactionProvider with ChangeNotifier {
  List<TransactionModel> transactions = [];
  void initData(
      ApiModel apiModel, ShareCustomerModel shareCustomerModel) async {
    transactions = await TransactionModel.getTransactionByShareDate(
        apiModel, shareCustomerModel);
    notifyListeners();
  }

  setPaidDate(ApiModel apiModel, TransactionModel transactionModel,
      ShareCustomerModel shareCustomerModel) async {
    Response response =
        await TransactionModel.setPaidDate(apiModel, transactionModel);
    if (response.statusCode == 201) {
      initData(apiModel, shareCustomerModel);
    }
  }
}

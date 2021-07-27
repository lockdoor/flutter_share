import 'package:flutter/foundation.dart';
import 'package:flutter_share/models/api.dart';
import 'package:flutter_share/models/bank.dart';

class BankProvider with ChangeNotifier {
  List<String> bankName = [];
  //List<Bank> banks = [];
  void initData(ApiModel apiModel) async {
    bankName = await BankModel.findBankName(apiModel);
    notifyListeners();
  }
}

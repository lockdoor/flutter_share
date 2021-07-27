import 'dart:convert';

import 'package:flutter_share/models/api.dart';
import 'package:http/http.dart' as http;

class BankModel {
  int? personID;
  late String account;
  int? id;
  late String bank;

  BankModel();

  BankModel.fromJson(Map<String, dynamic> json)
      : personID = json['person_id'],
        account = json['account'],
        id = json['id'],
        bank = json['bank'];

  static findBankName(ApiModel apiModel) async {
    final response = await http
        .get(
          Uri.parse(apiModel.getApiUri() + 'api/bank_name'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer ' + apiModel.getToken()
          },
        )
        .then((response) => response.body)
        .catchError((error) {
          throw Exception('failed to connect database');
        });
    Iterable l = await json.decode(response);
    List<String> list = List<String>.from(l.map((model) => model['bankName']));

    //dropDownValue.add(list.elementAt(0));
    return list;
  }
}

import 'dart:convert';

import 'package:flutter_share/models/api.dart';
import 'package:flutter_share/models/share/shareCustomer.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class TransactionModel {
  int transactionsId;
  int sharePersonId;
  int date;
  bool paid;
  DateTime? paidDate;
  String? comment;
  int? pay;
  String? nickName;
  DateTime shareDate;
  int sequence;

  TransactionModel.fromJson(Map<String, dynamic> json)
      : transactionsId = json['transactions_id'],
        sharePersonId = json['share_person_id'],
        date = json['date'],
        paid = json['paid'] == 0 ? false : true,
        paidDate = json['paid_date'] == null
            ? null
            : DateTime.parse(json['paid_date']),
        comment = json['comment'] == null ? null : json['comment'],
        pay = json['pay'] == null ? null : json['pay'],
        nickName = json['nickname'] == null ? null : json['nickname'],
        shareDate = DateTime.parse(json['share_date']),
        sequence = json['sequence'];

  Map<String, dynamic> toJson() => {
        'transactions_id': transactionsId,
        'share_person_id': sharePersonId,
        'date': date,
        'paid': paid,
        'paid_date': paidDate == null
            ? null
            : DateFormat('yyyy-MM-dd').format(paidDate!).toString(),
        'comment': comment == null ? null : comment,
        'pay': pay == null ? null : pay,
        'nickname': nickName == null ? null : nickName,
        'share_date': DateFormat('yyyy-MM-dd').format(shareDate).toString(),
        'sequence': sequence
      };

  static getTransactionByShareDate(
      ApiModel apiModel, ShareCustomerModel shareCustomerModel) async {
    final http.Response response = await http
        .post(Uri.parse(apiModel.getApiUri() + 'api/get_transctions_by_date'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer ' + apiModel.getToken()
            },
            body: jsonEncode(shareCustomerModel.toJson()))
        .then((response) => response)
        .catchError((onError) {
      throw Exception('failed to connect database');
    });
    //print(response.body);
    Iterable l = json.decode(response.body);
    List<TransactionModel> transaction = List<TransactionModel>.from(
        l.map((model) => TransactionModel.fromJson(model)));
    return transaction;
  }

  static setPaidDate(
      ApiModel apiModel, TransactionModel transactionModel) async {
    final http.Response response = await http
        .post(Uri.parse(apiModel.getApiUri() + 'api/set_paid_date'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer ' + apiModel.getToken()
            },
            body: jsonEncode(transactionModel.toJson()))
        .then((http.Response response) => response)
        .catchError((onError) {
      throw Exception('failed to connect database');
    });
    return response;
  }
}

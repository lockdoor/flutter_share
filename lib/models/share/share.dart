import 'dart:convert';

import 'package:flutter_share/models/api.dart';
//import 'package:flutter_share/models/customer/customer.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ShareModel {
  int? shareID;
  String shareType = 'บิด'; //ประเภทของแชร์
  late String name; //ชื่อวง
  late DateTime dateRun; //วันเริ่ม
  late int principle; //เงินต้น
  int? interestFix; //ดอกตายตัว
  late int amount; // จำนวนมือ
  late int pay; //ส่งมือละ
  late int days; //ระยะส่ง
  int? firstBid; //บิดเริ่มต้น
  int? bid; //บิดครั้งละ
  int? noBid; //ไม่มีคนบิด สุ่มดอก
  bool firstReceive = true; //ท้าวยกหัว
  bool lastReceive = false; //ท้าวหักค้ำท้าย

  ShareModel();

  Map<dynamic, dynamic> toJson() => {
        'share_id': shareID == null ? null : shareID,
        'share_type': shareType,
        'name': name,
        'date_run': DateFormat('yyyy-MM-dd').format(dateRun).toString(),
        'principle': principle,
        'interest_fix': interestFix == null ? null : interestFix,
        'amount': amount,
        'pay': pay,
        'days': days,
        'first_bid': firstBid == null ? null : firstBid,
        'bid': bid == null ? null : bid,
        'no_bid': noBid == null ? null : noBid,
        'first_receive': firstReceive,
        'last_receive': lastReceive
      };

  ShareModel.fromJson(Map<String, dynamic> json)
      : shareID = json['share_id'] == null ? null : json['share_id'],
        shareType = json['share_type'],
        name = json['name'],
        dateRun = DateTime.parse(json['date_run']),
        principle = json['principle'],
        interestFix =
            json['interest_fix'] == null ? null : json['interest_fix'],
        amount = json['amount'],
        pay = json['pay'],
        days = json['days'],
        firstBid = json['first_bid'] == null ? null : json['first_bid'],
        bid = json['bid'] == null ? null : json['bid'],
        noBid = json['no_bid'] == null ? null : json['no_bid'],
        firstReceive = json['first_receive'] == 1 ? true : false,
        lastReceive = json['last_receive'] == 1 ? true : false;

  static getAllShares(ApiModel apiModel) async {
    final response = await http
        .get(
          Uri.parse(apiModel.getApiUri() + 'api/shares'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer ' + apiModel.getToken()
          },
        )
        .then((response) => response.body)
        .catchError((error) {
          throw Exception('failed to connect database');
        });
    //print(response);
    Iterable l = json.decode(response);
    List<ShareModel> shares =
        List<ShareModel>.from(l.map((model) => ShareModel.fromJson(model)));
    return shares;
  }

  static addShare(ApiModel apiModel, ShareModel shareModel) async {
    final response =
        http.post(Uri.parse(apiModel.getApiUri() + 'api/share_create'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer ' + apiModel.getToken()
            },
            body: jsonEncode(shareModel));
    return response;
  }
}

main(List<String> args) async {
  ApiModel apiModel = new ApiModel();
  //var list = ShareModel.getAllShares(apiModel);
  Map<String, dynamic> json = {
    "share_id": null,
    "name": "ข้าวหอม",
    "amount": 11,
    "date_run": "2021-07-15T00:00:00.000Z",
    "principle": 10000,
    "interest_fix": null,
    "days": 10,
    "first_receive": 1,
    "last_receive": 1,
    "pay": 1000,
    "share_type": "บิด",
    "first_bid": 10,
    "bid": 1,
    "no_bid": 1
  };
  ShareModel shareModel = new ShareModel.fromJson(json);
  final http.Response response =
      await ShareModel.addShare(apiModel, shareModel);
  print(response.statusCode);
  print(response.body);
}

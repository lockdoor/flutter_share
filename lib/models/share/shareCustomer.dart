// To parse this JSON data, do
//
//     final sharesCustomers = sharesCustomersFromJson(jsonString);

import 'dart:convert';

import 'package:flutter_share/models/api.dart';
//import 'package:flutter_share/models/customer/customer.dart';
import 'package:flutter_share/models/share/share.dart';
import 'package:http/http.dart' as http;

ShareCustomerModel sharesCustomersFromJson(String str) =>
    ShareCustomerModel.fromJson(json.decode(str));

//String sharesCustomersToJson(SharesCustomers data) => json.encode(data.toJson());

class ShareCustomerModel {
  late int sharesPersonsID;
  late int shareID;
  int? personID;
  String? personName;
  bool admin;
  late DateTime shareDate;
  int sequence;
  int? interest;
  bool locker;

  ShareCustomerModel.fromJson(Map<String, dynamic> json)
      : sharesPersonsID = json["shares_persons_id"],
        shareID = json["share_id"],
        personID = json["person_id"] == null ? null : json["person_id"],
        personName = json["nickname"] == null ? null : json["nickname"],
        admin = json["admin"] == 1 ? true : false,
        shareDate = DateTime.parse(json["share_date"]),
        sequence = json["sequence"],
        interest = json["interest"] == null ? null : json["interest"],
        locker = json["locker"] == 1 ? true : false;

  Map<String, dynamic> toJson() => {
        "shares_persons_id": sharesPersonsID,
        "share_id": shareID,
        "person_id": personID,
        "share_date": shareDate.toIso8601String(),
        "sequence": sequence,
        "interest": interest == null ? null : interest,
        "locker": locker
      };
  static getAllShareCustomer(ApiModel apiModel, ShareModel shareModel) async {
    final response = await http
        .post(Uri.parse(apiModel.getApiUri() + 'api/share_person'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer ' + apiModel.getToken()
            },
            body: jsonEncode({"share_id": shareModel.shareID.toString()}))
        .then((response) => response.body)
        .catchError((error) {
      print(error);
    });
    //รอ  response
    //print(response);
    Iterable l = jsonDecode(response);
    //print(l);

    List<ShareCustomerModel> shareCustomer = List<ShareCustomerModel>.from(
        l.map((model) => ShareCustomerModel.fromJson(model)));
    return shareCustomer;
  }

  static addCustomerToShareCustomer(
      ApiModel apiModel, ShareCustomerModel shareCustomerModel) async {
    final http.Response response = await http.post(
        Uri.parse(apiModel.getApiUri() + 'api/share_person_edit_person'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ' + apiModel.getToken()
        },
        body: jsonEncode(shareCustomerModel.toJson()));
    return response;
  }

  static editInterest(ApiModel apiModel, ShareCustomerModel shareCustomerOld,
      ShareCustomerModel? shareCustomerNew, int interest) async {
    var myBody = jsonEncode({
      "interest": interest,
      "shareCustomerOld": shareCustomerOld.toJson(),
      "shareCustomerNew": shareCustomerNew!.toJson(),
    });
    final http.Response response = await http.post(
      Uri.parse(apiModel.getApiUri() + 'api/share_person_edit_interest'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + apiModel.getToken()
      },
      body: myBody,
    );

    return response;
  }

  static setLocker(
      ApiModel apiModel, ShareCustomerModel shareCustomerModel) async {
    final http.Response response = await http.post(
        Uri.parse(apiModel.getApiUri() + 'api/share_person_set_locker'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ' + apiModel.getToken()
        },
        body: jsonEncode(shareCustomerModel.toJson()));
    return response;
  }
}

// void main() async {
//   ApiModel apiModel = new ApiModel();
//   Map<String, dynamic> json = {
//     "share_id": 94,
//     "name": "ข้าวหอม",
//     "amount": 11,
//     "date_run": "2021-07-15T00:00:00.000Z",
//     "principle": 10000,
//     "interest_fix": null,
//     "days": 10,
//     "first_receive": 1,
//     "last_receive": 1,
//     "pay": 1000,
//     "share_type": "บิด",
//     "first_bid": 10,
//     "bid": 1,
//     "no_bid": 1
//   };
//   ShareModel shareModel = new ShareModel.fromJson(json);
//   final response =
//       await ShareCustomerModel.getAllShareCustomer(apiModel, shareModel);
//   print(response);
//}
// {"shares_persons_id":882,
// "share_id":93,"person_id":202,
// "share_date":"2021-07-15T00:00:00.000Z",
// "sequence":1,
// "nickname":"แมวเซา"}
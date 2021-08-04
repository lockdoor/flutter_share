import 'dart:convert';

import 'package:flutter_share/models/api.dart';
import 'package:http/http.dart' as http;

class CustomerModel {
  int? personID;
  bool admin = false;
  late String nickName;
  String? fname;
  String? lname;
  String? citizenID;
  List bankAccount = [];
  List phoneNumber = [];
  CustomerModel();

  Map<String, dynamic> toJson() => {
        'person_id': personID,
        'admin': admin,
        'nickname': nickName,
        'fname': fname,
        'lname': lname,
        'citizenID': citizenID,
        'bankAccount': bankAccount,
        'phoneNumber': phoneNumber
      };

  CustomerModel.fromJson(json) {
    personID = json['person_id'];
    admin = json['admin'] == 0 ? false : true;
    nickName = json['nickname'];
    fname = json['fname'];
    lname = json['lname'];
    citizenID = json['citizen_id'];
    //bankAccount =
    //phoneNumber =
  }

  static getAllCustomers(ApiModel apiModel) async {
    print('เรียกฐานข้อมูลลูกค้าจาก model');
    final response = await http
        .get(
          Uri.parse(apiModel.getApiUri() + 'api/persons'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer ' + apiModel.getToken()
          },
        )
        .then((response) => response.body)
        .catchError((error) {
          throw Exception('failed to connect database');
        });
    //print(apiuri);
    //print(response);
    Iterable l = json.decode(response);
    List<CustomerModel> customers = List<CustomerModel>.from(
        l.map((model) => CustomerModel.fromJson(model)));
    //print(customers[0].nickName);
    return customers;
  }

  static addCustomer(ApiModel apiModel, CustomerModel customerModel) async {
    final response = await http
        .post(
          Uri.parse(apiModel.getApiUri() + 'api/person_create'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer ' + apiModel.getToken()
          },
          body: jsonEncode(customerModel.toJson()),
        )
        .then((response) => response)
        .catchError((error) {
      throw Exception('failed to connect database');
    });
    return response;
  }

  static setAdmin(ApiModel apiModel, CustomerModel? adminNew) async {
    print(adminNew!.nickName);
    final response = await http
        .post(
          Uri.parse(apiModel.getApiUri() + 'api/set_admin'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer ' + apiModel.getToken()
          },
          body: jsonEncode(adminNew.toJson()),
          // body: jsonEncode({
          //   "adminOld": jsonEncode(adminOld),
          //   "adminNew": jsonEncode(adminNew)
        )
        .then((response) => response)
        .catchError((error) {
      throw Exception('failed to connect database');
    });
    return response;
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter_share/models/api.dart';
import 'package:flutter_share/models/customer/customer.dart';
import 'package:http/http.dart';

class CustomerProvider with ChangeNotifier {
  List<CustomerModel> customers = <CustomerModel>[];
  CustomerModel? admin;

  List<CustomerModel> getSuggestions(String query) =>
      List.of(this.customers).where((customer) {
        final userLower = customer.nickName.toLowerCase();
        final queryLower = query.toLowerCase();
        return userLower.contains(queryLower);
      }).toList();

  void initData(ApiModel apiModel) async {
    this.customers = await CustomerModel.getAllCustomers(apiModel);
    this.admin = findAdmin(this.customers);
    notifyListeners();
  }

  CustomerModel? findAdmin(List<CustomerModel> customers) {
    int index = customers.indexWhere((customer) => customer.admin == true);
    if (index == -1) {
      return null;
    } else {
      return customers[index];
    }
  }

  setAdmin(ApiModel apiModel, CustomerModel? adminNew) async {
    //หาข้อมูล admin เก่า
    int indexOld = customers.indexWhere((customer) => customer.admin == true);
    //หาข้อมูล admin ใหม่
    int indexNew = customers
        .indexWhere((customer) => customer.personID == adminNew!.personID);
    //ถ้ายังไม่เคยสร้าง admin ให้ admin ใหม่เป็น admin
    if (indexOld == -1) {
      customers[indexNew].admin = true;
      //ถ้าเคยสร้าง admin แล้ว
    } else {
      //ยกเลิก admin เก่า
      customers[indexOld].admin = false;
      //ตั้งค่า admin ใหม่
      customers[indexNew].admin = true;
      //เปลื่ยน admin ใน db
    }
    this.admin = customers[indexNew];
    //ทำการส่งข้อมูลไปที่ db
    final Response response = await CustomerModel.setAdmin(apiModel, adminNew);
    notifyListeners();
    return response;
  }

  addData(ApiModel apiModel, CustomerModel customerModel) async {
    //customers.add(customerModel);
    final Response response =
        await CustomerModel.addCustomer(apiModel, customerModel);
    initData(apiModel);
    notifyListeners();
    return response;
  }
}

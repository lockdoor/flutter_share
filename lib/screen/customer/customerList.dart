import 'package:flutter/material.dart';
import 'package:flutter_share/models/api.dart';
import 'package:flutter_share/models/customer/customer.dart';
import 'package:flutter_share/providers/api.dart';
import 'package:flutter_share/providers/customers.dart';
import 'package:flutter_share/screen/customer/customerAdd.dart';
import 'package:provider/provider.dart';

/* วิดเจด รายชื่อลูกค้า */
class CustomerList extends StatefulWidget {
  const CustomerList({Key? key}) : super(key: key);

  @override
  _CustomerListState createState() => _CustomerListState();
}

class _CustomerListState extends State<CustomerList> {
  late ApiModel apiModel;

  @override
  void initState() {
    super.initState();
    apiModel = context.read<ApiProvider>().api;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer(
        builder: (context, CustomerProvider provider, child) {
          List<CustomerModel> customers = provider.customers;
          return ListView.builder(
              itemCount: customers.length,
              itemBuilder: (BuildContext context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(customers[index].personID.toString()),
                  ),
                  title: Text(customers[index].nickName),
                );
              });
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Route route = MaterialPageRoute(builder: (context) => CustomerAdd());
          Navigator.push(context, route);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

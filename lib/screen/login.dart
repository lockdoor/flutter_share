import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_share/providers/api.dart';
import 'package:flutter_share/screen/home.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  const Login({
    Key? key,
  }) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  late String apiUri;

  @override
  void initState() {
    super.initState();
    apiUri = context.read<ApiProvider>().api.getApiUri();
    email.text = 'lockdoor@gmail.com';
    password.text = '77776666';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child: Container(
          width: 500,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                //mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Email'),
                  TextFormField(
                    controller: email,
                    keyboardType: TextInputType.emailAddress,
                    validator: MultiValidator([
                      RequiredValidator(errorText: 'กรุณาป้อน อีเมล์'),
                      EmailValidator(errorText: "อีเมล์ รูปแบบไม่ถูกต้อง")
                    ]),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text('Password'),
                  TextFormField(
                    controller: password,
                    validator:
                        RequiredValidator(errorText: 'กรุณาป้อนรหัสผ่าน'),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          final result = await login(email.text, password.text);
                          //print(token ?? "ไม่ได้รับค่า");
                          if (result['token'] != null) {
                            //print(result['token']);
                            Provider.of<ApiProvider>(context, listen: false)
                                .api
                                .setToken(result['token']);
                            Navigator.pushReplacement(context,
                                MaterialPageRoute(builder: (contex) {
                              return Home(
                                tab: 1,
                              );
                            }));
                            formKey.currentState!.reset();
                          } else {
                            showDialog<String>(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                      title: Text('ERROR!!'),
                                      content: Text(result['message']),
                                    ));
                          }
                        }
                      },
                      child: Text('Login'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<Map> login(email, password) async {
    final response = await http
        .post(Uri.parse(apiUri + 'login'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(
                <String, String>{'email': email, 'password': password}))
        .then((response) => response.body)
        .catchError((error) {
      throw Exception('failed to connect database');
    });
    return jsonDecode(response);
  }
}

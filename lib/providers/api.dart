import 'package:flutter/foundation.dart';
import 'package:flutter_share/models/api.dart';

class ApiProvider with ChangeNotifier {
  ApiModel api = new ApiModel();
  ApiProvider();

  // String _apiuri = 'http://localhost:3000/';
  // String? _token;
  // ApiProvider();
  // void setToken(token) => this._token = token;
  // getApiUri() => this._apiuri;
  // getToken() => this._token;
}

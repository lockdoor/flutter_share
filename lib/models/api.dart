class ApiModel {
  //String _apiuri = 'http://localhost:3000/';
  String _apiuri = 'http://lockdoor.local:3000/';
  //String _apiuri = 'http://192.168.12.56:3000/';
  //String _apiuri = 'https://share-api.namning.xyz/';
  String _token = 'token';
  String inputSubmit = '1';
  ApiModel();
  void setToken(token) => this._token = token;
  getApiUri() => this._apiuri;
  getToken() => this._token;
}

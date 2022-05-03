import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Auth with ChangeNotifier {
  String? _tokenk;
  String? _expiryDate;
  String? _userId;

  // Auth({
  //   required this._tokenk,
  //   required this._expiryDate,
  //   required this._userId,
  // });

  Future<void> signup(String email, String password) async {
    final url = Uri.parse(
        "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyDHfpB16cTz7yhaU-MtKDdEItFQvt2usaA");

    final response = await http.post(url,
        body: json.encode({
          "email": email,
          "password": password,
          "returnSecureToken": true,
        }));
    print(json.decode(response.body));
  }
}

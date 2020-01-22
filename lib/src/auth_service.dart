import 'dart:async';
import 'dart:html';
import 'dart:js';
import 'dart:convert';

import 'package:HolySheetWeb/src/request_objects.dart';
import 'package:HolySheetWeb/src/request_utils.dart';
import 'package:HolySheetWeb/src/utility.dart';
import 'package:angular/angular.dart';
import 'package:HolySheetWeb/src/js.dart';

@Injectable()
class AuthService {
  bool get signedIn => 'auth2.isSignedIn.get'();

  String get accessToken =>
      'auth2.currentUser.get'<JsObject>()('getAuthResponse')['access_token'];

  int get userId =>
      toInt('auth2.currentUser.get'<JsObject>()('getBasicProfile')['Eea']);

  BasicProfile _basicProfile;

  BasicProfile get basicProfile {
    if (!(_basicProfile?.id == userId ?? false)) {
      _basicProfile = BasicProfile.fromJS(
          'auth2.currentUser.get'<JsObject>()('getBasicProfile'));
    }
    return _basicProfile;
  }

  /// Logs in a user
  void loginUser() => 'auth2.grantOfflineAccess'<JsObject>()(
      'then',
      (authResult) => HttpRequest.getString(
          'http://localhost:8090/callback?code=${authResult['code']}'));

  Future<RequestResponse> makeAuthedRequest(String url,
          {String baseUrl = BASE_URL,
          Map<String, String> query,
          Map<String, String> requestHeaders}) async =>
      makeRequest(url,
          baseUrl: baseUrl,
          query: query..addAll({'Authorization': accessToken}),
          requestHeaders: requestHeaders);
}

class BasicProfile {
  int id;
  String fullName;
  String firstName;
  String lastName;
  String imageUrl;
  String email;

  BasicProfile(this.id, this.fullName, this.firstName, this.lastName,
      this.imageUrl, this.email);

  BasicProfile.fromJS(JsObject json)
      : id = toInt(json['Eea']),
        fullName = json['ig'],
        firstName = json['ofa'],
        lastName = json['wea'],
        imageUrl = json['Paa'],
        email = json['U3'];
}

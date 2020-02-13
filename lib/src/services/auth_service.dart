import 'dart:async';
import 'dart:html';
import 'dart:js';

import 'package:HolySheetWeb/src/js.dart';
import 'package:HolySheetWeb/src/utility.dart';
import 'package:angular/angular.dart';

@Injectable()
class AuthService {
  static final emptyJS = JsObject.jsify({});

  @Input()
  bool get signedIn => context['auth2'] != null && 'auth2.isSignedIn.get'();

  String get accessToken =>
      'auth2.currentUser.get'<JsObject>()('getAuthResponse')['access_token'];

  int get userId =>
      toInt(('auth2.currentUser.get'<JsObject>()('getBasicProfile') ?? {'Eea': '-1'}) ['Eea']);

  BasicProfile _basicProfile;

  BasicProfile get basicProfile {
    if (!signedIn) {
      return null;
    }

    if (!(_basicProfile?.id == userId ?? false)) {
      _basicProfile = BasicProfile.fromJS(
          'auth2.currentUser.get'<JsObject>()('getBasicProfile') ?? emptyJS);
    }
    return _basicProfile;
  }

  void loginUser() => 'auth2.grantOfflineAccess'();

  void logoutUser() => 'auth2.signOut'();
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
      : id = toInt(json['Eea'] ?? '0'),
        fullName = json['ig'],
        firstName = json['ofa'],
        lastName = json['wea'],
        imageUrl = json['Paa'],
        email = json['U3'];
}

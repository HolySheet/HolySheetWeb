import 'dart:async';
import 'dart:html';
import 'dart:js';

import 'package:HolySheetWeb/src/js.dart';
import 'package:HolySheetWeb/src/utility.dart';
import 'package:angular/angular.dart';

@Injectable()
class AuthService {
  static final emptyJS = JsObject.jsify({});

  final signInCallbacks = <Function>[];

  @Input()
  bool signedIn = false;

  @Input()
  bool get checkSignedIn {
    var signedIn = context['auth2'] != null && 'auth2.isSignedIn.get'();
    if (!this.signedIn && signedIn) {
      this.signedIn = true;
      updateCallbacks();
    }

    return signedIn;
  }

  void updateCallbacks() {
    for (var callback in signInCallbacks) {
      callback();
    }

    signInCallbacks.clear();
  }

  String get accessToken =>
      'auth2.currentUser.get'<JsObject>()('getAuthResponse')['access_token'];

  int get userId =>
      toInt((('auth2.currentUser.get'() as JsObject)('getBasicProfile')
          as JsObject)('getId'));

  BasicProfile _basicProfile;

  BasicProfile get basicProfile {
    if (!checkSignedIn) {
      return null;
    }

    if (!(_basicProfile?.id == userId ?? false)) {
      _basicProfile = BasicProfile.fromJS(
          'auth2.currentUser.get'<JsObject>()('getBasicProfile') ?? emptyJS);
    }

    return _basicProfile;
  }

  void onSignedIn(void Function() callback) {
    if (checkSignedIn) {
      callback();
    } else {
      signInCallbacks.add(callback);
    }
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
      : id = toInt(json('getId') ?? '0'),
        fullName = json('getName'),
        firstName = json('getGivenName'),
        lastName = json('getFamilyName'),
        imageUrl = json('getImageUrl'),
        email = json('getEmail');
}

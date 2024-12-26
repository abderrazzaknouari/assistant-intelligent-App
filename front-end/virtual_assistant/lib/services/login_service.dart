import 'package:google_sign_in/google_sign_in.dart';
import 'package:virtual_assistant/exceptions/authentication_exception.dart';
import 'package:virtual_assistant/models/user.dart';

class LoginService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email',"https://www.googleapis.com/auth/gmail.modify","https://www.googleapis.com/auth/calendar","https://www.googleapis.com/auth/calendar.events"],clientId: "426322832792-i9frut2ssb3uu29vilivn0t148h09rdu.apps.googleusercontent.com");

  GoogleSignInAccount? _user;

  GoogleSignInAccount? get user => _user;

  LoginService();

  Future<GoogleSignInAccount> signInWithGoogle () async {
    try {
      _user = await _googleSignIn.signIn();
      return _user!;
    } catch (error) {
        throw new AuthenticationException(error.toString());

    }
  }


  Future googleLogout() async {
    try {
      await _googleSignIn.disconnect();
    } catch (error) {
      print(error);
    }
  }
Future<GoogleSignInAccount?> getGoogleSignInAccountSilenlty() async {
    try {
      _user = await _googleSignIn.signInSilently();

      return _user!;
    } catch (error) {
      return null;
    }
  }
  GoogleSignInAccount? getCurrentUser() {
    return _googleSignIn.currentUser;
  }
}
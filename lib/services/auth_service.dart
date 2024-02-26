import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService();
  final googleSignIn = GoogleSignIn();

  GoogleSignInAccount? get currentUser => googleSignIn.currentUser;
  bool get isLoggedIn => currentUser != null;
  late final loggedInStateChanges = googleSignIn.onCurrentUserChanged
      .map((user) => user != null)
      .asBroadcastStream();

  Future<void> initialize() async {
    await googleSignIn.signInSilently();
  }

  Future<void> signIn() async {
    await googleSignIn.signIn();
  }

  Future<void> signOut() async {
    await googleSignIn.signOut();
  }
}

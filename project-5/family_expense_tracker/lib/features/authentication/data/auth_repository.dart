import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Represents an authenticated user.
class User {
  final String id;
  final String? displayName;
  final String? email;
  final String? photoUrl;

  User({
    required this.id,
    this.displayName,
    this.email,
    this.photoUrl,
  });
}

/// Repository for handling Google OAuth authentication.
class AuthRepository {
  final GoogleSignIn _googleSignIn;
  final FlutterSecureStorage _secureStorage;

  AuthRepository({GoogleSignIn? googleSignIn, FlutterSecureStorage? secureStorage})
      : _googleSignIn = googleSignIn ?? GoogleSignIn(
          scopes: [
            'email',
            'https://www.googleapis.com/auth/spreadsheets', // Required for Google Sheets access
          ],
        ),
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Signs in the user with Google.
  /// Returns a [User] object if successful, otherwise null.
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled the sign-in
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      await _saveTokens(googleAuth.accessToken, googleAuth.idToken);

      return User(
        id: googleUser.id,
        displayName: googleUser.displayName,
        email: googleUser.email,
        photoUrl: googleUser.photoUrl,
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> _saveTokens(String? accessToken, String? idToken) async {
    if (accessToken != null) {
      await _secureStorage.write(key: 'access_token', value: accessToken);
    }
    if (idToken != null) {
      await _secureStorage.write(key: 'id_token', value: idToken);
    }
  }

  Future<Map<String, String?>> _readTokens() async {
    final String? accessToken = await _secureStorage.read(key: 'access_token');
    final String? idToken = await _secureStorage.read(key: 'id_token');
    return {'access_token': accessToken, 'id_token': idToken};
  }

  /// Returns a valid access token, refreshing it if necessary.
  Future<String?> getAccessToken() async {
    final GoogleSignInAccount? googleUser = _googleSignIn.currentUser;
    if (googleUser == null) {
      final Map<String, String?> storedTokens = await _readTokens();
      return storedTokens['access_token'];
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    if (googleAuth.accessToken != null) {
      await _saveTokens(googleAuth.accessToken, googleAuth.idToken);
      return googleAuth.accessToken;
    }

    // If access token is null, try silent sign-in to refresh
    final GoogleSignInAccount? refreshedUser = await _googleSignIn.signInSilently();
    if (refreshedUser != null) {
      final GoogleSignInAuthentication refreshedAuth = await refreshedUser.authentication;
      await _saveTokens(refreshedAuth.accessToken, refreshedAuth.idToken);
      return refreshedAuth.accessToken;
    }

    return null;
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _secureStorage.delete(key: 'access_token');
    await _secureStorage.delete(key: 'id_token');
  }

  /// Checks if a user is currently signed in.
  Future<bool> isSignedIn() async {
    final bool signedIn = await _googleSignIn.isSignedIn();
    return signedIn;
  }

  /// Returns the currently signed-in user, if any.
  Future<User?> getCurrentUser() async {
    GoogleSignInAccount? googleUser = _googleSignIn.currentUser;
    if (googleUser == null) {
      final Map<String, String?> storedTokens = await _readTokens();
      if (storedTokens['access_token'] != null) {
        googleUser = await _googleSignIn.signInSilently();
        if (googleUser != null) {
          // Ensure tokens are up-to-date after silent sign-in
          final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
          await _saveTokens(googleAuth.accessToken, googleAuth.idToken);
        }
      }
    }

    if (googleUser == null) {
      return null;
    }
    return User(
      id: googleUser.id,
      displayName: googleUser.displayName,
      email: googleUser.email,
      photoUrl: googleUser.photoUrl,
    );
  }
}

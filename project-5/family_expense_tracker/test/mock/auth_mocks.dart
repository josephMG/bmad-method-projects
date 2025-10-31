import 'package:mockito/annotations.dart';
import 'package:family_expense_tracker/features/authentication/data/auth_repository.dart';
import 'package:google_sign_in/google_sign_in.dart';

@GenerateMocks([
  AuthRepository,
  GoogleSignIn,
  GoogleSignInAccount,
  GoogleSignInAuthentication,
])
void main() {}
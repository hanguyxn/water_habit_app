import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:water_habit_app/features/auth/domain/user_model.dart';

class AuthRepository {
  AuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  /// Stream of auth state changes
  Stream<User?> getCurrentUser() => _firebaseAuth.authStateChanges();

  /// Stream of UserModel from Firestore
  Stream<UserModel?> getUserStream(String uid) {
    return _usersCollection.doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return null;
      return UserModel.fromJson({...snapshot.data()!, 'id': snapshot.id});
    });
  }

  /// Sign in with email and password
  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Sign up with email, password and username
  Future<UserCredential> signUpWithEmail(
    String email,
    String password,
    String username,
  ) async {
    try {
      final isAvailable = await checkUsernameAvailable(username);
      if (!isAvailable) {
        throw AuthException('Tên người dùng đã được sử dụng');
      }

      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user != null) {
        await createUserDocument(credential.user!, username);
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Sign in with Google
  Future<UserCredential> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw AuthException('Đăng nhập Google bị hủy');
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      if (userCredential.additionalUserInfo?.isNewUser == true &&
          userCredential.user != null) {
        final username = _generateUsername(
          userCredential.user!.displayName ?? 'user',
        );
        await createUserDocument(userCredential.user!, username);
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Sign in with Apple
  Future<UserCredential> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(oauthCredential);

      if (userCredential.additionalUserInfo?.isNewUser == true &&
          userCredential.user != null) {
        final displayName = [
          appleCredential.givenName,
          appleCredential.familyName,
        ].where((n) => n != null).join(' ');

        final username = _generateUsername(
          displayName.isNotEmpty ? displayName : 'user',
        );
        await createUserDocument(userCredential.user!, username);

        if (displayName.isNotEmpty) {
          await userCredential.user!.updateDisplayName(displayName);
        }
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Update profile
  Future<void> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw AuthException('Chưa đăng nhập');

    final updates = <String, dynamic>{};

    if (displayName != null) {
      await user.updateDisplayName(displayName);
      updates['displayName'] = displayName;
    }
    if (photoUrl != null) {
      await user.updatePhotoURL(photoUrl);
      updates['avatarUrl'] = photoUrl;
    }

    if (updates.isNotEmpty) {
      updates['lastActiveAt'] = FieldValue.serverTimestamp();
      await _usersCollection.doc(user.uid).update(updates);
    }
  }

  /// Delete account
  Future<void> deleteAccount() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw AuthException('Chưa đăng nhập');

    await _usersCollection.doc(user.uid).delete();
    await user.delete();
  }

  /// Check if username is available
  Future<bool> checkUsernameAvailable(String username) async {
    final normalizedUsername = username.toLowerCase().trim();
    if (normalizedUsername.length < 3) return false;

    final query = await _usersCollection
        .where('username', isEqualTo: normalizedUsername)
        .limit(1)
        .get();

    return query.docs.isEmpty;
  }

  /// Create user document in Firestore
  Future<void> createUserDocument(User user, String username) async {
    final now = DateTime.now();
    final userModel = UserModel(
      id: user.uid,
      username: username.toLowerCase().trim(),
      email: user.email ?? '',
      displayName: user.displayName,
      avatarUrl: user.photoURL,
      createdAt: now,
      lastActiveAt: now,
    );

    await _usersCollection.doc(user.uid).set(userModel.toJson());
  }

  /// Update FCM token
  Future<void> updateFcmToken(String token) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;

    await _usersCollection.doc(user.uid).update({
      'fcmToken': token,
      'lastActiveAt': FieldValue.serverTimestamp(),
    });
  }

  String _generateUsername(String name) {
    final base = name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]'), '')
        .substring(0, name.length.clamp(0, 12));
    final suffix = DateTime.now().millisecondsSinceEpoch % 10000;
    return '${base}_$suffix';
  }

  AuthException _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return AuthException('Không tìm thấy tài khoản với email này');
      case 'wrong-password':
        return AuthException('Mật khẩu không đúng');
      case 'email-already-in-use':
        return AuthException('Email đã được sử dụng');
      case 'weak-password':
        return AuthException('Mật khẩu quá yếu');
      case 'invalid-email':
        return AuthException('Email không hợp lệ');
      case 'user-disabled':
        return AuthException('Tài khoản đã bị vô hiệu hóa');
      case 'too-many-requests':
        return AuthException('Quá nhiều yêu cầu. Vui lòng thử lại sau');
      case 'operation-not-allowed':
        return AuthException('Phương thức đăng nhập chưa được kích hoạt');
      default:
        return AuthException(e.message ?? 'Đã xảy ra lỗi xác thực');
    }
  }
}

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}

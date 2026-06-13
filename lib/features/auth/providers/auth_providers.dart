import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:water_habit_app/features/auth/data/auth_repository.dart';
import 'package:water_habit_app/features/auth/domain/user_model.dart';

part 'auth_providers.g.dart';

@Riverpod(keepAlive: true)
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepository();
}

@Riverpod(keepAlive: true)
Stream<User?> authState(AuthStateRef ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.getCurrentUser();
}

@Riverpod(keepAlive: true)
Stream<UserModel?> currentUser(CurrentUserRef ref) {
  final authStateAsync = ref.watch(authStateProvider);
  final repo = ref.watch(authRepositoryProvider);

  return authStateAsync.when(
    data: (user) {
      if (user == null) return Stream.value(null);
      return repo.getUserStream(user.uid);
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
}

@riverpod
class UsernameAvailability extends _$UsernameAvailability {
  @override
  FutureOr<bool?> build() => null;

  Future<void> check(String username) async {
    if (username.length < 3) {
      state = const AsyncData(false);
      return;
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      return repo.checkUsernameAvailable(username);
    });
  }
}

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  FutureOr<void> build() {}

  Future<void> signInWithEmail(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      await repo.signInWithEmail(email, password);
    });
  }

  Future<void> signUpWithEmail(
    String email,
    String password,
    String username,
  ) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      await repo.signUpWithEmail(email, password, username);
    });
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      await repo.signInWithGoogle();
    });
  }

  Future<void> signInWithApple() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      await repo.signInWithApple();
    });
  }

  Future<void> resetPassword(String email) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      await repo.resetPassword(email);
    });
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      await repo.signOut();
    });
  }
}

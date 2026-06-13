class RouteNames {
  RouteNames._();

  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/';
  static const String friends = '/friends';
  static const String friendSearch = '/friends/search';
  static const String qrScanner = '/friends/qr-scanner';
  static const String feed = '/feed';
  static const String leaderboard = '/leaderboard';
  static const String profile = '/profile';
  static const String profileEdit = '/profile/edit';
  static const String userProfile = '/user/:userId';
  static const String settings = '/settings';

  static String userProfilePath(String userId) => '/user/$userId';
}

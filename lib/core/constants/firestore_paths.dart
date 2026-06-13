class FirestorePaths {
  FirestorePaths._();

  // Root collections
  static const String users = 'users';
  static const String friendRequests = 'friend_requests';
  static const String feed = 'feed';
  static const String leaderboards = 'leaderboards';
  static const String seasons = 'seasons';
  static const String forests = 'forests';
  static const String guilds = 'guilds';
  static const String worldTree = 'world_tree';
  static const String waterSupports = 'water_supports';

  // User sub-collections
  static String userDoc(String userId) => '$users/$userId';
  static String waterLogs(String userId) => '$users/$userId/water_logs';
  static String waterLogDoc(String userId, String date) =>
      '$users/$userId/water_logs/$date';
  static String userFriends(String userId) => '$users/$userId/friends';
  static String userFriendDoc(String userId, String friendId) =>
      '$users/$userId/friends/$friendId';
  static String userAchievements(String userId) =>
      '$users/$userId/achievements';
  static String userAchievementDoc(String userId, String achievementId) =>
      '$users/$userId/achievements/$achievementId';

  // Friend requests
  static String friendRequestDoc(String requestId) =>
      '$friendRequests/$requestId';

  // Feed
  static String feedDoc(String feedItemId) => '$feed/$feedItemId';

  // Leaderboards
  static String leaderboardDoc(String type, String period) =>
      '$leaderboards/${type}_$period';

  // Seasons
  static String seasonDoc(String seasonId) => '$seasons/$seasonId';

  // Forests
  static String forestDoc(String forestId) => '$forests/$forestId';
  static String forestMembers(String forestId) =>
      '$forests/$forestId/members';

  // Guilds
  static String guildDoc(String guildId) => '$guilds/$guildId';
  static String guildMissions(String guildId) =>
      '$guilds/$guildId/missions';

  // World Tree
  static String worldTreeDoc(String eventId) => '$worldTree/$eventId';

  // Water Supports
  static String waterSupportDoc(String supportId) =>
      '$waterSupports/$supportId';
}

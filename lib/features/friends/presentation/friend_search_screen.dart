import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:water_habit_app/core/theme/app_colors.dart';
import 'package:water_habit_app/core/widgets/app_avatar.dart';
import 'package:water_habit_app/core/widgets/app_button.dart';
import 'package:water_habit_app/core/widgets/app_text_field.dart';
import 'package:water_habit_app/core/localization/app_localizations.dart';

class FriendSearchScreen extends StatefulWidget {
  const FriendSearchScreen({super.key});

  @override
  State<FriendSearchScreen> createState() => _FriendSearchScreenState();
}

class _FriendSearchScreenState extends State<FriendSearchScreen> {
  final _searchController = TextEditingController();
  final List<Map<String, dynamic>> _results = [];
  final Set<String> _sentRequests = {};
  bool _isSearching = false;

  final List<Map<String, dynamic>> _mockUsers = [
    {'id': '1', 'name': 'Hương Giang', 'username': '@huonggiang', 'level': 12},
    {'id': '2', 'name': 'Thanh Mai', 'username': '@thanhmai', 'level': 6},
    {'id': '3', 'name': 'Quốc Bảo', 'username': '@quocbao', 'level': 3},
    {'id': '4', 'name': 'Minh Anh', 'username': '@minhanh', 'level': 9},
    {'id': '5', 'name': 'Đức Huy', 'username': '@duchuy', 'level': 20},
  ];

  void _search(String query) {
    if (query.isEmpty) {
      setState(() => _results.clear());
      return;
    }
    setState(() => _isSearching = true);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() {
        _results.clear();
        _results.addAll(_mockUsers.where(
          (u) => u['username'].toString().toLowerCase().contains(query.toLowerCase()) ||
              u['name'].toString().toLowerCase().contains(query.toLowerCase()),
        ));
        _isSearching = false;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(title: Text(context.tr('friends.searchTitle'))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: AppTextField(
              controller: _searchController,
              hint: context.tr('friends.searchPlaceholder'),
              prefixIcon: Icons.search,
              onChanged: _search,
            ),
          ),
          // QR Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _QuickAction(
                    icon: Icons.qr_code_rounded,
                    label: context.tr('friends.qrShow'),
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickAction(
                    icon: Icons.qr_code_scanner_rounded,
                    label: context.tr('friends.qrScan'),
                    onTap: () {},
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 200.ms),
          ),
          const SizedBox(height: 16),
          // Results
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary500))
                : _results.isEmpty && _searchController.text.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.person_search, size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text(context.tr('friends.notFound'), style: TextStyle(color: Colors.grey.shade500)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _results.length,
                        itemBuilder: (context, index) {
                          final user = _results[index];
                          final isSent = _sentRequests.contains(user['id']);
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
                              ],
                            ),
                            child: Row(
                              children: [
                                AppAvatar(name: user['name'], size: 48),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(user['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
                                      Text(user['username'], style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text('Lv.${user['level']}',
                                      style: const TextStyle(fontSize: 12, color: AppColors.primary700, fontWeight: FontWeight.w600)),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 90,
                                  height: 36,
                                  child: ElevatedButton(
                                    onPressed: isSent
                                        ? null
                                        : () => setState(() => _sentRequests.add(user['id'])),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isSent ? Colors.grey.shade200 : AppColors.primary500,
                                      foregroundColor: isSent ? Colors.grey.shade500 : Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      padding: EdgeInsets.zero,
                                      textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                    ),
                                    child: Text(isSent ? context.tr('friends.sent') : context.tr('friends.addFriend')),
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fadeIn(delay: (index * 80).ms).slideX(begin: 0.05, end: 0);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary100),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary500, size: 28),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.primary700)),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../services/app_store.dart';

class NotificationCenter extends StatelessWidget {
  const NotificationCenter({super.key, required this.store});

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: store.notifications.isEmpty
            ? const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.notifications_none_rounded, size: 52),
                    SizedBox(height: 12),
                    Text('No notifications yet'),
                    SizedBox(height: 6),
                    Text('Your GPA updates will appear here.'),
                  ],
                ),
              )
            : ListView.separated(
                itemCount: store.notifications.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = store.notifications[index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFFEEF2FF),
                        child: const Icon(
                          Icons.notifications_active_rounded,
                          color: Color(0xFF4F46E5),
                        ),
                      ),
                      title: Text(item.title),
                      subtitle: Text(item.message),
                      trailing: Text(
                        '${item.createdAt.day}/${item.createdAt.month}/${item.createdAt.year}',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

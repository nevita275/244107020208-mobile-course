import 'package:flutter/material.dart';

import '../messaging/push_service.dart';

class DebugFcmPage extends StatelessWidget {
  const DebugFcmPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Debug FCM')),
      body: ValueListenableBuilder<PushDebugState>(
        valueListenable: pushDebugState,
        builder: (context, state, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _DebugItem(
                title: 'Izin notifikasi',
                value: state.permissionStatus,
              ),
              _DebugItem(
                title: 'Token FCM (terpotong)',
                value: state.currentTokenPreview ?? 'Belum tersedia',
              ),
              _DebugItem(
                title: 'Kejadian onTokenRefresh',
                value: '${state.refreshCount}',
              ),
              _DebugItem(
                title: 'Token terakhir dikirim (simulasi)',
                value: state.lastSentTokenPreview ?? 'Belum dikirim',
              ),
              _DebugItem(
                title: 'Waktu terakhir dikirim',
                value: state.lastSentAt?.toLocal().toString() ?? 'Belum ada',
              ),
              SwitchListTile(
                title: const Text('Langganan topik pengumuman-kampus'),
                subtitle: Text(
                  state.topicOperationInProgress
                      ? 'Memperbarui status...'
                      : state.topicSubscribed
                      ? 'Aktif'
                      : 'Nonaktif',
                ),
                value: state.topicSubscribed,
                onChanged: state.topicOperationInProgress
                    ? null
                    : (subscribed) async {
                        await setAnnouncementTopicSubscription(subscribed);
                      },
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Text(
                  'Kejadian notifikasi terakhir',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              ValueListenableBuilder<List<NotificationEvent>>(
                valueListenable: notificationEvents,
                builder: (context, events, child) {
                  if (events.isEmpty) {
                    return const ListTile(
                      title: Text('Belum ada kejadian notifikasi'),
                    );
                  }
                  return Column(
                    children: events
                        .map(
                          (event) => ListTile(
                            title: Text('${event.state} · ${event.route}'),
                            subtitle: Text(
                              event.occurredAt.toLocal().toString(),
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
              if (state.errorMessage != null)
                _DebugItem(title: 'Status', value: state.errorMessage!),
            ],
          );
        },
      ),
    );
  }
}

class _DebugItem extends StatelessWidget {
  const _DebugItem({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(title: Text(title), subtitle: Text(value));
  }
}

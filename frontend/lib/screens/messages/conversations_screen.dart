import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/message_provider.dart';
// models/message.dart is used indirectly via MessageProvider

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({Key? key}) : super(key: key);

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      // Fetch conversations once when the widget is inserted in the tree
      final provider = Provider.of<MessageProvider>(context, listen: false);
      provider.fetchConversations();
      _initialized = true;
    }
  }

  String _formatRelative(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversations'),
      ),
      body: Consumer<MessageProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: Text('Error: ${provider.error}'));
          }

          final conversations = provider.conversations;
          if (conversations.isEmpty) {
            return const Center(child: Text('Aucune conversation'));
          }

          return RefreshIndicator(
            onRefresh: provider.fetchConversations,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: conversations.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (ctx, i) {
                final conv = conversations[i];
                final last = conv.lastMessage;
                final subtitle = last != null ? last.content : '—';
                final time =
                    last != null ? _formatRelative(last.createdAt) : '';

                return ListTile(
                  leading: conv.otherUserAvatar != null
                      ? CircleAvatar(
                          backgroundImage: NetworkImage(conv.otherUserAvatar!),
                        )
                      : CircleAvatar(child: Text(conv.otherUserName[0])),
                  title: Text(conv.otherUserName),
                  subtitle: Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (time.isNotEmpty)
                        Text(time, style: const TextStyle(fontSize: 12)),
                      if (conv.unreadCount > 0)
                        Container(
                          margin: const EdgeInsets.only(top: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            conv.unreadCount.toString(),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      '/chat',
                      arguments: {
                        'userId': conv.otherUserId,
                        'userName': conv.otherUserName,
                        'userAvatar': conv.otherUserAvatar,
                      },
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

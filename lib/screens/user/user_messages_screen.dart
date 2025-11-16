import 'package:flutter/material.dart';
import 'package:focusflow/models/models.dart';
import 'package:focusflow/providers/providers.dart';
import 'package:focusflow/widgets/widgets.dart';
import 'package:pixelarticons/pixelarticons.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class UserMessagesScreen extends StatefulWidget {
  final String coachId;
  final String coachName;

  const UserMessagesScreen({
    Key? key,
    required this.coachId,
    required this.coachName,
  }) : super(key: key);

  @override
  State<UserMessagesScreen> createState() => _UserMessagesScreenState();
}

class _UserMessagesScreenState extends State<UserMessagesScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final currentUserId = userProvider.user?.uid;

    if (currentUserId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.coachName),
        leading: IconButton(
          icon: const Icon(Pixel.chevronleft),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: StreamBuilder<List<MessageModel>>(
        stream: MessageProvider().messagesStream(currentUserId, widget.coachId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final messages = snapshot.data ?? [];
          if (messages.isEmpty) {
            return const Center(child: Text('No messages yet.'));
          }

          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              final isFromCoach = message.coachId == widget.coachId;
              final bubbleColor = isFromCoach
                  ? Colors.grey.shade200
                  : Theme.of(context).colorScheme.primary;
              final textColor = isFromCoach
                  ? Colors.black87
                  : Theme.of(context).colorScheme.onPrimary;

              final timeString =
                  DateFormat('hh:mm a').format(message.createdAt.toDate());

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Align(
                  alignment:
                      isFromCoach ? Alignment.centerLeft : Alignment.centerRight,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75),
                    child: Column(
                      crossAxisAlignment: isFromCoach
                          ? CrossAxisAlignment.start
                          : CrossAxisAlignment.end,
                      children: [
                        Text(
                          timeString,
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 2),
                        ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: isFromCoach
                                ? const Radius.circular(0)
                                : const Radius.circular(16),
                            bottomRight: isFromCoach
                                ? const Radius.circular(16)
                                : const Radius.circular(0),
                          ),
                          child: StyledCard(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            color: bubbleColor,
                            child: Text(
                              message.text,
                              style: TextStyle(color: textColor, fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

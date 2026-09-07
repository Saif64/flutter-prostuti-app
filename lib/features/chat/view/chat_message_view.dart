import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prostuti/common/widgets/common_widgets/common_widgets.dart';
import 'package:prostuti/core/services/localization_service.dart';
import 'package:prostuti/core/services/socket_service.dart';
import 'package:prostuti/features/chat/viewmodel/chat_viewmodel.dart';
import 'package:prostuti/features/chat/widgets/chat_input_field.dart';
import 'package:prostuti/features/chat/widgets/chat_message_item.dart';

import '../widgets/chat_skeleton.dart';

const String RESOLVED_MESSAGE = "Your doubt is solved. Thank you";

class ChatMessageView extends ConsumerStatefulWidget {
  final String conversationId;
  final String recipientId;
  final String recipientName;
  final String message;

  const ChatMessageView({
    super.key,
    required this.conversationId,
    required this.recipientId,
    required this.recipientName,
    required this.message,
  });

  @override
  ConsumerState<ChatMessageView> createState() =>
      _StreamBasedChatMessageViewState();
}

class _StreamBasedChatMessageViewState extends ConsumerState<ChatMessageView>
    with CommonWidgets {
  final ScrollController _scrollController = ScrollController();
  late String userId;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    userId = 'current_user_id'; // This would be fetched from an auth service
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      ref
          .read(
            chatMessagesNotifierProvider(widget.conversationId).notifier,
          )
          .loadMoreMessages(widget.conversationId);
    }
  }

  void _sendMessage(String message) {
    ref
        .read(
          chatMessagesNotifierProvider(widget.conversationId).notifier,
        )
        .sendMessage(
          conversationId: widget.conversationId,
          recipientId: widget.recipientId,
          message: message,
        );

    // Scroll to the bottom to see the new message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch providers for state
    final messagesAsync = ref.watch(
      chatMessagesNotifierProvider(widget.conversationId),
    );
    final isTyping = ref
        .watch(typingIndicatorNotifierProvider)
        .containsKey(widget.conversationId);

    // ✨ **KEY CHANGE**: Determine the resolved state directly from the provider's data
    // This makes the UI a pure function of the state.
    final isConversationResolved = messagesAsync.when(
      data: (messages) {
        if (messages.isEmpty) return false;

        // Create a sorted copy to find the newest message
        final sortedMessages = List.of(messages);
        sortedMessages.sort((a, b) {
          final timeA = DateTime.tryParse(a.createdAt ?? '');
          final timeB = DateTime.tryParse(b.createdAt ?? '');
          if (timeA == null || timeB == null) return 0;
          return timeB.compareTo(timeA); // Newest messages first
        });

        // Check the newest message for the resolved text
        return sortedMessages.first.message == RESOLVED_MESSAGE;
      },
      loading: () => false, // Default to not resolved while loading
      error: (_, __) => false, // Default to not resolved on error
    );

    return Scaffold(
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  // Back button
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 12),
                  const CircleAvatar(
                    radius: 20,
                    backgroundImage: AssetImage('assets/images/test_dp.jpg'),
                  ),
                  const SizedBox(width: 12),
                  // ✨ **KEY CHANGE**: Expanded allows the column to take available
                  // space and lets the text wrap without causing a layout overflow.
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.recipientName,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.message,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 2, // Optional: limit the number of lines
                          overflow: TextOverflow
                              .ellipsis, // Optional: handle overflow
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Connection status indicator
          Consumer(
            builder: (context, ref, child) {
              final connectionStatus =
                  ref.watch(socketConnectionStatusProvider);

              return connectionStatus.when(
                data: (status) {
                  if (status != ConnectionStatus.connected) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 16),
                      color: status == ConnectionStatus.connecting
                          ? Colors.orange.withOpacity(0.8)
                          : Colors.red.withOpacity(0.8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (status == ConnectionStatus.connecting)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          else
                            const Icon(Icons.error_outline,
                                size: 16, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            status == ConnectionStatus.connecting
                                ? context.l10n?.connecting ?? 'Connecting...'
                                : context.l10n?.connectionError ??
                                    'Connection error',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              );
            },
          ),

          // Messages list
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                messages.sort((a, b) {
                  final timeA = DateTime.tryParse(a.createdAt ?? '');
                  final timeB = DateTime.tryParse(b.createdAt ?? '');
                  if (timeA == null || timeB == null) return 0;
                  return timeB.compareTo(timeA);
                });

                if (messages.isEmpty) {
                  return Center(
                    child: Text(
                      context.l10n?.noMessagesYet ?? 'No messages yet',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  );
                }

                // StreamBuilder for real-time typing indicator
                return Stack(
                  children: [
                    ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isMe = message.senderId == userId ||
                            message.senderRole == 'student';
                        final isLastMessage = index == 0;

                        return ChatMessageItem(
                          message: message,
                          isMe: isMe,
                          isLastMessage: isLastMessage,
                        );
                      },
                    ),

                    // Typing indicator overlay at the bottom
                    if (isTyping)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            bottom: 8,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const CircleAvatar(
                                radius: 16,
                                backgroundImage:
                                    AssetImage('assets/images/test_dp.jpg'),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey[800]
                                      : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    Container(/* ...typing dots... */),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
              loading: () => const SkeletonizedChatScreen(),
              error: (error, stack) => Center(
                child: Text('${context.l10n?.error ?? 'Error'}: $error'),
              ),
            ),
          ),

          // ✨ **KEY CHANGE**: Conditionally show the input field or the resolved text
          if (isConversationResolved)
            Container(
              key: const ValueKey('resolved'),
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(
                vertical: 24,
                horizontal: 20,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF34C759).withOpacity(0.1),
                    const Color(0xFF34C759).withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF34C759).withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFF34C759),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "This conversation has been resolved",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: const Color(0xFF34C759),
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            )
          else
            ChatInputField(
              conversationId: widget.conversationId,
              recipientId: widget.recipientId,
              onSendMessage: _sendMessage,
            ),
        ],
      ),
    );
  }
}

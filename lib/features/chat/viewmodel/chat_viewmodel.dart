import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:prostuti/features/chat/model/conversation_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/services/socket_service.dart';
import '../model/chat_model.dart';
import '../repository/chat_repo.dart';

part 'chat_viewmodel.g.dart';

// Provider to initialize the socket once at app startup
@riverpod
Future<bool> socketInitializer(SocketInitializerRef ref) async {
  final socketService = SocketService();
  return await socketService.initSocket();
}

// Provider for active conversations
@riverpod
class ConversationsNotifier extends _$ConversationsNotifier {
  @override
  Future<List<Conversation>> build() async {
    // Initialize socket through the shared initializer
    try {
      await ref
          .watch(socketInitializerProvider.future)
          .timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint('Socket initialization timeout: $e');
    }

    // Listen to broadcast events to refresh conversations when needed
    ref.listen(broadcastsStreamProvider, (_, __) {
      refreshConversations();
    });

    return _fetchConversations();
  }

  Future<List<Conversation>> _fetchConversations() async {
    final result =
        await ref.read(chatRepositoryProvider).getActiveConversations();

    return result.fold(
      (error) {
        debugPrint('Error fetching conversations: ${error.message}');
        return [];
      },
      (conversations) {
        return conversations.data ?? [];
      },
    );
  }

  Future<void> refreshConversations() async {
    state = const AsyncValue.loading();
    state = AsyncValue.data(await _fetchConversations());
  }
}

// Provider for unread message count
@riverpod
class UnreadMessagesNotifier extends _$UnreadMessagesNotifier {
  @override
  Future<UnreadCountData?> build() {
    // Listen to new messages to refresh unread count automatically
    ref.listen(socketConnectionStatusProvider, (previous, next) {
      next.whenData((status) {
        if (status == ConnectionStatus.connected) {
          refreshUnreadCount();
        }
      });
    });

    // Also listen to chat message streams to refresh
    ref.listen(chatMessagesStreamProvider('all'), (previous, next) {
      refreshUnreadCount();
    });

    return _fetchUnreadCount();
  }

  Future<UnreadCountData?> _fetchUnreadCount() async {
    final result =
        await ref.read(chatRepositoryProvider).getUnreadMessageCount();

    return result.fold(
      (error) {
        debugPrint('Error fetching unread count: ${error.message}');
        return null;
      },
      (response) {
        return response.data;
      },
    );
  }

  Future<void> refreshUnreadCount() async {
    state = const AsyncValue.loading();
    state = AsyncValue.data(await _fetchUnreadCount());
  }
}

// Improved chat messages provider that leverages streams
@riverpod
class ChatMessagesNotifier extends _$ChatMessagesNotifier {
  late final SocketService _socketService;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  bool _hasMoreMessages = true;
  static const int _messagesPerPage = 20;

  // Subscription cancellation
  StreamSubscription? _messageSubscription;

  @override
  Future<List<ChatMessage>> build(String conversationId) async {
    _socketService = SocketService();

    // Wait for socket initialization
    try {
      await ref
          .watch(socketInitializerProvider.future)
          .timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint('Socket initialization timeout in chat messages: $e');
    }

    // Join the conversation room
    if (_socketService.isConnected) {
      _socketService.joinConversation(conversationId);
    }

    // Mark conversation as read
    _markConversationAsRead(conversationId);

    // Listen to new messages through the stream
    _messageSubscription = _socketService.messageStream
        .where((message) => message.conversationId == conversationId)
        .listen((newMessage) {
      // Add new message to state
      state = AsyncValue.data([
        newMessage,
        ...state.value ?? [],
      ]);

      // Mark as read since we're in this conversation
      _markConversationAsRead(conversationId);

      // Refresh unread count
      ref.read(unreadMessagesNotifierProvider.notifier).refreshUnreadCount();
    });

    // Clean up when provider is disposed
    ref.onDispose(() {
      _messageSubscription?.cancel();
      _socketService.leaveConversation(conversationId);
    });

    return _fetchMessages(conversationId);
  }

  Future<List<ChatMessage>> _fetchMessages(
    String conversationId, {
    int page = 1,
    bool append = false,
  }) async {
    final result = await ref.read(chatRepositoryProvider).getChatHistory(
          conversationId: conversationId,
          page: page,
          limit: _messagesPerPage,
        );

    return result.fold(
      (error) {
        debugPrint('Error fetching messages: ${error.message}');
        return append ? state.value ?? [] : [];
      },
      (response) {
        final messages = response.data?.messages ?? [];
        final total = response.data?.total ?? 0;

        // Check if we have more messages to load
        _hasMoreMessages = (page * _messagesPerPage) < total;

        if (append && state.value != null) {
          // Append new messages to existing list
          return [...state.value!, ...messages];
        } else {
          return messages;
        }
      },
    );
  }

  Future<void> loadMoreMessages(String conversationId) async {
    if (_isLoadingMore || !_hasMoreMessages) return;

    _isLoadingMore = true;
    _currentPage++;

    final messages = await _fetchMessages(
      conversationId,
      page: _currentPage,
      append: true,
    );

    state = AsyncValue.data(messages);
    _isLoadingMore = false;
  }

  Future<void> sendMessage({
    required String conversationId,
    required String recipientId,
    required String message,
  }) async {
    if (message.trim().isEmpty) return;

    final messageData = {
      'conversation_id': conversationId,
      'message': message.trim(),
      'recipient_id': recipientId,
    };

    _socketService.sendMessage(messageData);
  }

  void sendTypingIndicator(String conversationId) {
    _socketService.sendTypingIndicator(conversationId);
  }

  void sendStopTypingIndicator(String conversationId) {
    _socketService.sendStopTypingIndicator(conversationId);
  }

  Future<void> _markConversationAsRead(String conversationId) async {
    await ref.read(chatRepositoryProvider).markMessagesAsRead(conversationId);
    ref.read(unreadMessagesNotifierProvider.notifier).refreshUnreadCount();
  }
}

// Simplified typing indicator provider using streams
@riverpod
class TypingIndicatorNotifier extends _$TypingIndicatorNotifier {
  StreamSubscription? _typingSubscription;
  StreamSubscription? _stopTypingSubscription;

  @override
  Map<String, String> build() {
    final socketService = SocketService();

    // Listen to typing events
    _typingSubscription = socketService.typingStream.listen((event) {
      state = {...state, event.conversationId: event.userId};
    });

    // Listen to stop typing events
    _stopTypingSubscription = socketService.stopTypingStream.listen((event) {
      final newState = Map<String, String>.from(state);
      newState.remove(event.conversationId);
      state = newState;
    });

    // Clean up
    ref.onDispose(() {
      _typingSubscription?.cancel();
      _stopTypingSubscription?.cancel();
    });

    return {};
  }

  bool isUserTyping(String conversationId) {
    return state.containsKey(conversationId);
  }
}

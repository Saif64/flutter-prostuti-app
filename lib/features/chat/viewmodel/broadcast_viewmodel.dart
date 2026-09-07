import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:prostuti/features/chat/model/broadcast_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/services/socket_service.dart';
import '../repository/chat_repo.dart';

part 'broadcast_viewmodel.g.dart';

@riverpod
class BroadcastNotifier extends _$BroadcastNotifier {
  late final SocketService _socketService;
  StreamSubscription? _broadcastSubscription;

  @override
  Future<List<BroadcastRequest>> build() async {
    _socketService = SocketService();
    await _socketService.initSocket();
    _setupStreamListeners();

    // Cleanup when this provider is disposed
    ref.onDispose(() {
      _broadcastSubscription?.cancel();
    });

    return _fetchActiveBroadcasts();
  }

  Future<List<BroadcastRequest>> _fetchActiveBroadcasts() async {
    final result = await ref.read(chatRepositoryProvider).getActiveBroadcasts();

    return result.fold(
      (error) {
        debugPrint('Error fetching broadcasts: ${error.message}');
        return [];
      },
      (broadcasts) {
        return broadcasts.data ?? [];
      },
    );
  }

  void _setupStreamListeners() {
    // Listen to the broadcast stream for any broadcast-related events
    _broadcastSubscription = _socketService.broadcastStream.listen((broadcast) {
      debugPrint('Broadcast event received: ${broadcast.status}');
      refreshBroadcasts();
    });
  }

  Future<void> refreshBroadcasts() async {
    state = const AsyncValue.loading();
    state = AsyncValue.data(await _fetchActiveBroadcasts());
  }

  Future<bool> createBroadcastRequest({
    required String message,
    required String subject,
  }) async {
    try {
      final result =
          await ref.read(chatRepositoryProvider).createBroadcastRequest(
                message: message,
                subject: subject,
              );

      return result.fold(
        (error) {
          debugPrint('Error creating broadcast: ${error.message}');
          if (error.message.contains("created successfully")) {
            refreshBroadcasts();
            return true;
          }
          return false;
        },
        (response) {
          refreshBroadcasts();
          return response.success ?? false;
        },
      );
    } catch (e) {
      debugPrint('Exception creating broadcast: $e');
      return false;
    }
  }

  // Method to send a broadcast request via socket
  // Method to send a broadcast request via socket
  Future<bool> sendBroadcastViaSocket({
    required String message,
    required String subject,
  }) async {
    try {
      final requestData = {
        'message': message,
        'subject': subject,
      };

      // We can create a Completer to handle the async response
      final completer = Completer<bool>();

      // Create the subscription before referencing it
      late StreamSubscription subscription;
      subscription = _socketService.broadcastStream.listen((broadcast) {
        // This is a simple check - you might need more sophisticated logic
        // to match the response to the request
        if (!completer.isCompleted) {
          completer.complete(true);
          subscription.cancel();
        }
      });

      // Send the broadcast request
      _socketService.sendBroadcastRequest(requestData);

      // Set a timeout
      Future.delayed(const Duration(seconds: 5), () {
        if (!completer.isCompleted) {
          completer.complete(false);
          subscription.cancel();
        }
      });

      return completer.future;
    } catch (e) {
      debugPrint('Exception sending broadcast via socket: $e');
      return false;
    }
  }
}

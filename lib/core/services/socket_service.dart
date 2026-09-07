import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prostuti/common/helpers/persist_util.dart';
import 'package:prostuti/features/chat/model/broadcast_model.dart';
import 'package:prostuti/features/chat/model/chat_model.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../flutter_config.dart';

final SOCKET_URL = FlavorConfig.instance.socketBaseUrl;

// Event classes for better type safety
class TypingEvent {
  final String conversationId;
  final String userId;

  TypingEvent({required this.conversationId, required this.userId});

  factory TypingEvent.fromJson(Map<String, dynamic> json) {
    return TypingEvent(
      conversationId: json['conversation_id'] ?? '',
      userId: json['user_id'] ?? '',
    );
  }
}

// Course notice/enrollment events. Backend payload shape is not documented,
// so every field is optional and parsing never throws - a malformed payload
// still produces an event (with null fields) rather than being dropped.
class CourseNoticeEvent {
  final String? courseName;
  final String? noticeText;
  final dynamic raw;

  CourseNoticeEvent({this.courseName, this.noticeText, this.raw});

  factory CourseNoticeEvent.fromJson(dynamic json) {
    String? courseName;
    String? noticeText;
    try {
      if (json is Map) {
        final course = json['course'] ?? json['courseId'] ?? json['course_id'];
        courseName = (json['courseName'] ??
                json['course_name'] ??
                (course is Map ? course['name'] : null))
            ?.toString();
        noticeText =
            (json['notice'] ?? json['message'] ?? json['title'])?.toString();
      }
    } catch (e) {
      debugPrint('Error parsing CourseNoticeEvent: $e');
    }
    return CourseNoticeEvent(
        courseName: courseName, noticeText: noticeText, raw: json);
  }
}

class CourseEnrolledEvent {
  final String? courseName;
  final dynamic raw;

  CourseEnrolledEvent({this.courseName, this.raw});

  factory CourseEnrolledEvent.fromJson(dynamic json) {
    String? courseName;
    try {
      if (json is Map) {
        final course = json['course'] ?? json['courseId'] ?? json['course_id'];
        courseName = (json['courseName'] ??
                json['course_name'] ??
                (course is Map ? course['name'] : null))
            ?.toString();
      }
    } catch (e) {
      debugPrint('Error parsing CourseEnrolledEvent: $e');
    }
    return CourseEnrolledEvent(courseName: courseName, raw: json);
  }
}

// Connection status enum
enum ConnectionStatus {
  disconnected,
  connecting,
  connected,
  connectionError,
  authError
}

// Providers
final socketConnectionStatusProvider = StreamProvider<ConnectionStatus>((ref) {
  return SocketService().connectionStatus;
});

final chatMessagesStreamProvider =
    StreamProvider.family<ChatMessage, String>((ref, conversationId) {
  return SocketService()
      .messageStream
      .where((message) => message.conversationId == conversationId);
});

final typingEventsStreamProvider =
    StreamProvider.family<TypingEvent, String>((ref, conversationId) {
  return SocketService()
      .typingStream
      .where((event) => event.conversationId == conversationId);
});

final broadcastsStreamProvider = StreamProvider<BroadcastRequest>((ref) {
  return SocketService().broadcastStream;
});

final courseNoticeStreamProvider = StreamProvider<CourseNoticeEvent>((ref) {
  return SocketService().courseNoticeStream;
});

final courseEnrolledStreamProvider = StreamProvider<CourseEnrolledEvent>((ref) {
  return SocketService().courseEnrolledStream;
});

class SocketService {
  static final SocketService _instance = SocketService._internal();

  factory SocketService() => _instance;

  // Stream controllers for different event types
  final StreamController<ConnectionStatus> _connectionStatusController =
      StreamController<ConnectionStatus>.broadcast();
  final StreamController<ChatMessage> _messageController =
      StreamController<ChatMessage>.broadcast();
  final StreamController<TypingEvent> _typingController =
      StreamController<TypingEvent>.broadcast();
  final StreamController<TypingEvent> _stopTypingController =
      StreamController<TypingEvent>.broadcast();
  final StreamController<BroadcastRequest> _broadcastController =
      StreamController<BroadcastRequest>.broadcast();
  final StreamController<CourseNoticeEvent> _courseNoticeController =
      StreamController<CourseNoticeEvent>.broadcast();
  final StreamController<CourseEnrolledEvent> _courseEnrolledController =
      StreamController<CourseEnrolledEvent>.broadcast();

  // Expose streams
  Stream<ConnectionStatus> get connectionStatus =>
      _connectionStatusController.stream;

  Stream<ChatMessage> get messageStream => _messageController.stream;

  Stream<TypingEvent> get typingStream => _typingController.stream;

  Stream<TypingEvent> get stopTypingStream => _stopTypingController.stream;

  Stream<BroadcastRequest> get broadcastStream => _broadcastController.stream;

  Stream<CourseNoticeEvent> get courseNoticeStream =>
      _courseNoticeController.stream;

  Stream<CourseEnrolledEvent> get courseEnrolledStream =>
      _courseEnrolledController.stream;

  IO.Socket? _socket;
  bool _isConnected = false;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _initialReconnectDelay = Duration(seconds: 2);

  bool _isInitializing = false;
  Completer<bool>? _initCompleter;

  SocketService._internal();

  bool get isConnected => _isConnected;

  // Initialize the socket connection
  Future<bool> initSocket() async {
    // If already connected, return success immediately
    if (_isConnected && _socket != null) {
      debugPrint('Socket already connected');
      return true;
    }

    // If initialization is in progress, wait for it to complete
    if (_isInitializing && _initCompleter != null) {
      debugPrint('Socket initialization already in progress, waiting...');
      return _initCompleter!.future;
    }

    // Set initialization flag and create completion completer
    _isInitializing = true;
    _initCompleter = Completer<bool>();

    _connectionStatusController.add(ConnectionStatus.connecting);

    try {
      // If socket exists, disconnect and dispose before recreating
      if (_socket != null) {
        debugPrint('Cleaning up existing socket');
        _socket!.disconnect();
        _socket!.dispose();
        _socket = null;
      }

      final token = await PersistUtil.getAccessToken();

      if (token == null) {
        debugPrint('Cannot initialize socket: No access token');
        _connectionStatusController.add(ConnectionStatus.authError);
        _isInitializing = false;
        _initCompleter!.complete(false);
        return false;
      }

      debugPrint('Creating socket with URL: $SOCKET_URL');

      // Create socket with the corrected configuration
      _socket = IO.io(
        SOCKET_URL,
        IO.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .disableAutoConnect()
            .setAuth({'token': token})
            .setExtraHeaders({'Authorization': 'Bearer $token'})
            .setTimeout(10000) // 10 seconds connection timeout
            .setReconnectionAttempts(0) // Custom reconnection logic
            .enableForceNew()
            .enableReconnection()
            .build(),
      );

      _setupSocketListeners();

      debugPrint('Socket object created, attempting to connect...');
      _socket!.connect();

      // Add a timeout for the initial connection attempt
      Timer(const Duration(seconds: 15), () {
        if (!_isConnected && _isInitializing) {
          debugPrint('Socket connection timeout after 15 seconds');
          _connectionStatusController.add(ConnectionStatus.connectionError);
          _isInitializing = false;
          _initCompleter!.complete(false);
          _attemptReconnect();
        }
      });

      return _initCompleter!.future;
    } catch (e) {
      debugPrint('Error initializing socket: $e');
      _connectionStatusController.add(ConnectionStatus.connectionError);
      _isInitializing = false;
      _initCompleter!.complete(false);
      return false;
    }
  }

  void _setupSocketListeners() {
    _socket?.onConnect((_) {
      debugPrint('Socket connected successfully');
      _isConnected = true;
      _reconnectAttempts = 0;
      _connectionStatusController.add(ConnectionStatus.connected);

      if (_isInitializing &&
          _initCompleter != null &&
          !_initCompleter!.isCompleted) {
        _isInitializing = false;
        _initCompleter!.complete(true);
      }
    });

    _socket?.onDisconnect((_) {
      debugPrint('Socket disconnected');
      _isConnected = false;
      _connectionStatusController.add(ConnectionStatus.disconnected);

      if (_isInitializing &&
          _initCompleter != null &&
          !_initCompleter!.isCompleted) {
        _isInitializing = false;
        _initCompleter!.complete(false);
      }

      _attemptReconnect();
    });

    _socket?.onConnectError((data) {
      debugPrint('Socket connection error: $data');
      _isConnected = false;
      _connectionStatusController.add(ConnectionStatus.connectionError);

      if (_isInitializing &&
          _initCompleter != null &&
          !_initCompleter!.isCompleted) {
        _isInitializing = false;
        _initCompleter!.complete(false);
      }

      _attemptReconnect();
    });

    _socket?.onError((_) {
      debugPrint('Socket error');
      _isConnected = false;
      _connectionStatusController.add(ConnectionStatus.connectionError);

      if (_isInitializing &&
          _initCompleter != null &&
          !_initCompleter!.isCompleted) {
        _isInitializing = false;
        _initCompleter!.complete(false);
      }

      _attemptReconnect();
    });

    _socket?.on('authenticated', (data) {
      debugPrint('Socket authenticated: $data');
      _connectionStatusController.add(ConnectionStatus.connected);
    });

    _socket?.on('authentication_error', (data) {
      debugPrint('Socket authentication error: $data');
      _isConnected = false;
      _connectionStatusController.add(ConnectionStatus.authError);

      if (_isInitializing &&
          _initCompleter != null &&
          !_initCompleter!.isCompleted) {
        _isInitializing = false;
        _initCompleter!.complete(false);
      }
    });

    // Message events
    _socket?.on('receive_message', (data) {
      debugPrint('Received message: $data');
      final message = ChatMessage.fromJson(data);
      _messageController.add(message);
    });

    // Typing events
    _socket?.on('typing', (data) {
      debugPrint('Typing event: $data');
      if (data['conversation_id'] != null && data['user_id'] != null) {
        final typingEvent = TypingEvent.fromJson(data);
        _typingController.add(typingEvent);
      }
    });

    _socket?.on('stop_typing', (data) {
      debugPrint('Stop typing event: $data');
      if (data['conversation_id'] != null && data['user_id'] != null) {
        final typingEvent = TypingEvent.fromJson(data);
        _stopTypingController.add(typingEvent);
      }
    });

    // Broadcast events
    _socket?.on('broadcast_accepted', (data) {
      debugPrint('Broadcast accepted: $data');
      if (data is Map<String, dynamic>) {
        try {
          final broadcast = BroadcastRequest.fromJson(data);
          _broadcastController.add(broadcast);
        } catch (e) {
          debugPrint('Error parsing broadcast data: $e');
        }
      }
    });

    _socket?.on('broadcast_expired', (data) {
      debugPrint('Broadcast expired: $data');
      if (data is Map<String, dynamic>) {
        try {
          final broadcast = BroadcastRequest.fromJson(data);
          _broadcastController.add(broadcast);
        } catch (e) {
          debugPrint('Error parsing broadcast data: $e');
        }
      }
    });

    _socket?.on('broadcast_request', (data) {
      debugPrint('Broadcast request confirmation: $data');
      if (data is Map<String, dynamic> &&
          data['success'] == true &&
          data['data'] is Map<String, dynamic>) {
        try {
          final broadcast = BroadcastRequest.fromJson(data['data']);
          _broadcastController.add(broadcast);
        } catch (e) {
          debugPrint('Error parsing broadcast data: $e');
        }
      }
    });

    // Course notice events - a student's enrolled course has a new notice
    _socket?.on('COURSE_NOTICE_NOTIFICATION', (data) {
      debugPrint('COURSE_NOTICE_NOTIFICATION: $data');
      try {
        _courseNoticeController.add(CourseNoticeEvent.fromJson(data));
      } catch (e) {
        debugPrint('Error handling COURSE_NOTICE_NOTIFICATION: $e');
        _courseNoticeController.add(CourseNoticeEvent(raw: data));
      }
    });

    // Course enrollment events - a student's enrollment was confirmed
    _socket?.on('COURSE_ENROLLED', (data) {
      debugPrint('COURSE_ENROLLED: $data');
      try {
        _courseEnrolledController.add(CourseEnrolledEvent.fromJson(data));
      } catch (e) {
        debugPrint('Error handling COURSE_ENROLLED: $e');
        _courseEnrolledController.add(CourseEnrolledEvent(raw: data));
      }
    });
  }

  void _attemptReconnect() {
    _reconnectTimer?.cancel();

    if (_reconnectAttempts >= _maxReconnectAttempts) {
      debugPrint('Max reconnect attempts reached');
      return;
    }

    final backoffFactor = _reconnectAttempts + 1;
    final jitter = (backoffFactor / 2) *
        (DateTime.now().millisecondsSinceEpoch % 1000) /
        1000;
    final delaySeconds =
        _initialReconnectDelay.inSeconds * backoffFactor + jitter;

    debugPrint(
        'Attempting reconnect in $delaySeconds seconds (attempt ${_reconnectAttempts + 1})');

    _reconnectTimer = Timer(Duration(seconds: delaySeconds.round()), () {
      if (!_isConnected && _socket != null) {
        _reconnectAttempts++;
        _socket!.connect();
        debugPrint('Reconnect attempt ${_reconnectAttempts}');
      }
    });
  }

  // Disconnect the socket
  void disconnect() {
    _reconnectTimer?.cancel();
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
    }
    _isConnected = false;
    _connectionStatusController.add(ConnectionStatus.disconnected);
    debugPrint('Socket disconnected');

    _isInitializing = false;
    if (_initCompleter != null && !_initCompleter!.isCompleted) {
      _initCompleter!.complete(false);
    }
  }

  // Emit an event
  void emit(String event, dynamic data) {
    if (_isConnected) {
      _socket?.emit(event, data);
    } else {
      debugPrint('Cannot emit $event: Socket not connected');
    }
  }

  // Emit an event and receive a callback
  void emitWithAck(String event, dynamic data, Function(dynamic) callback) {
    if (_isConnected) {
      _socket?.emitWithAck(event, data, ack: callback);
    } else {
      debugPrint('Cannot emit $event with ACK: Socket not connected');
    }
  }

  // Join a conversation room
  void joinConversation(String conversationId) {
    emit('join_conversation', conversationId);
  }

  // Leave a conversation room
  void leaveConversation(String conversationId) {
    emit('leave_conversation', conversationId);
  }

  // Send a typing indicator
  void sendTypingIndicator(String conversationId) {
    emit('typing', conversationId);
  }

  // Send a stop typing indicator
  void sendStopTypingIndicator(String conversationId) {
    emit('stop_typing', conversationId);
  }

  // Send a message
  void sendMessage(Map<String, dynamic> messageData) {
    emit('send_message', messageData);
  }

  // Send a broadcast request
  void sendBroadcastRequest(Map<String, dynamic> broadcastData) {
    emit('broadcast_request', broadcastData);
  }

  // Clean up resources
  void dispose() {
    _reconnectTimer?.cancel();
    disconnect();
    _connectionStatusController.close();
    _messageController.close();
    _typingController.close();
    _stopTypingController.close();
    _broadcastController.close();
    _courseNoticeController.close();
    _courseEnrolledController.close();
  }
}

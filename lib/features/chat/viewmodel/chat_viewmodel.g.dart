// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$socketInitializerHash() => r'3464fcf4db03f77285d30bd78c5b78aeb7a06474';

/// See also [socketInitializer].
@ProviderFor(socketInitializer)
final socketInitializerProvider = AutoDisposeFutureProvider<bool>.internal(
  socketInitializer,
  name: r'socketInitializerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$socketInitializerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SocketInitializerRef = AutoDisposeFutureProviderRef<bool>;
String _$conversationsNotifierHash() =>
    r'7191df4a7d81ca944141495010f4889f0541a222';

/// See also [ConversationsNotifier].
@ProviderFor(ConversationsNotifier)
final conversationsNotifierProvider = AutoDisposeAsyncNotifierProvider<
    ConversationsNotifier, List<Conversation>>.internal(
  ConversationsNotifier.new,
  name: r'conversationsNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$conversationsNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ConversationsNotifier = AutoDisposeAsyncNotifier<List<Conversation>>;
String _$unreadMessagesNotifierHash() =>
    r'6a979835e280a31c3aac12fe9e8b7b610b56052b';

/// See also [UnreadMessagesNotifier].
@ProviderFor(UnreadMessagesNotifier)
final unreadMessagesNotifierProvider = AutoDisposeAsyncNotifierProvider<
    UnreadMessagesNotifier, UnreadCountData?>.internal(
  UnreadMessagesNotifier.new,
  name: r'unreadMessagesNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$unreadMessagesNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$UnreadMessagesNotifier = AutoDisposeAsyncNotifier<UnreadCountData?>;
String _$chatMessagesNotifierHash() =>
    r'1f7a43f56494c486c4070941a13f6dc4334a0c6b';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$ChatMessagesNotifier
    extends BuildlessAutoDisposeAsyncNotifier<List<ChatMessage>> {
  late final String conversationId;

  FutureOr<List<ChatMessage>> build(
    String conversationId,
  );
}

/// See also [ChatMessagesNotifier].
@ProviderFor(ChatMessagesNotifier)
const chatMessagesNotifierProvider = ChatMessagesNotifierFamily();

/// See also [ChatMessagesNotifier].
class ChatMessagesNotifierFamily extends Family<AsyncValue<List<ChatMessage>>> {
  /// See also [ChatMessagesNotifier].
  const ChatMessagesNotifierFamily();

  /// See also [ChatMessagesNotifier].
  ChatMessagesNotifierProvider call(
    String conversationId,
  ) {
    return ChatMessagesNotifierProvider(
      conversationId,
    );
  }

  @override
  ChatMessagesNotifierProvider getProviderOverride(
    covariant ChatMessagesNotifierProvider provider,
  ) {
    return call(
      provider.conversationId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'chatMessagesNotifierProvider';
}

/// See also [ChatMessagesNotifier].
class ChatMessagesNotifierProvider extends AutoDisposeAsyncNotifierProviderImpl<
    ChatMessagesNotifier, List<ChatMessage>> {
  /// See also [ChatMessagesNotifier].
  ChatMessagesNotifierProvider(
    String conversationId,
  ) : this._internal(
          () => ChatMessagesNotifier()..conversationId = conversationId,
          from: chatMessagesNotifierProvider,
          name: r'chatMessagesNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$chatMessagesNotifierHash,
          dependencies: ChatMessagesNotifierFamily._dependencies,
          allTransitiveDependencies:
              ChatMessagesNotifierFamily._allTransitiveDependencies,
          conversationId: conversationId,
        );

  ChatMessagesNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.conversationId,
  }) : super.internal();

  final String conversationId;

  @override
  FutureOr<List<ChatMessage>> runNotifierBuild(
    covariant ChatMessagesNotifier notifier,
  ) {
    return notifier.build(
      conversationId,
    );
  }

  @override
  Override overrideWith(ChatMessagesNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: ChatMessagesNotifierProvider._internal(
        () => create()..conversationId = conversationId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        conversationId: conversationId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<ChatMessagesNotifier,
      List<ChatMessage>> createElement() {
    return _ChatMessagesNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChatMessagesNotifierProvider &&
        other.conversationId == conversationId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, conversationId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ChatMessagesNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<List<ChatMessage>> {
  /// The parameter `conversationId` of this provider.
  String get conversationId;
}

class _ChatMessagesNotifierProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<ChatMessagesNotifier,
        List<ChatMessage>> with ChatMessagesNotifierRef {
  _ChatMessagesNotifierProviderElement(super.provider);

  @override
  String get conversationId =>
      (origin as ChatMessagesNotifierProvider).conversationId;
}

String _$typingIndicatorNotifierHash() =>
    r'9cb951f0359835a200faf4ce1f3141f8dbeb8e42';

/// See also [TypingIndicatorNotifier].
@ProviderFor(TypingIndicatorNotifier)
final typingIndicatorNotifierProvider = AutoDisposeNotifierProvider<
    TypingIndicatorNotifier, Map<String, String>>.internal(
  TypingIndicatorNotifier.new,
  name: r'typingIndicatorNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$typingIndicatorNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TypingIndicatorNotifier = AutoDisposeNotifier<Map<String, String>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

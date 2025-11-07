// models/message.dart
class Message {
  final String id;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final String receiverId;
  final String receiverName;
  final String? receiverAvatar;
  final String content;
  final String? propertyId; // Si le message concerne une propriété
  final bool isRead;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.receiverId,
    required this.receiverName,
    this.receiverAvatar,
    required this.content,
    this.propertyId,
    this.isRead = false,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'].toString(),
      senderId: json['sender_id'].toString(),
      senderName: json['sender_name'],
      senderAvatar: json['sender_avatar'],
      receiverId: json['receiver_id'].toString(),
      receiverName: json['receiver_name'],
      receiverAvatar: json['receiver_avatar'],
      content: json['content'],
      propertyId: json['property_id']?.toString(),
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'sender_name': senderName,
      'sender_avatar': senderAvatar,
      'receiver_id': receiverId,
      'receiver_name': receiverName,
      'receiver_avatar': receiverAvatar,
      'content': content,
      'property_id': propertyId,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Message copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? senderAvatar,
    String? receiverId,
    String? receiverName,
    String? receiverAvatar,
    String? content,
    String? propertyId,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      receiverId: receiverId ?? this.receiverId,
      receiverName: receiverName ?? this.receiverName,
      receiverAvatar: receiverAvatar ?? this.receiverAvatar,
      content: content ?? this.content,
      propertyId: propertyId ?? this.propertyId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// Model for conversation (liste des conversations)
class Conversation {
  final String id;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserAvatar;
  final Message? lastMessage;
  final int unreadCount;
  final DateTime updatedAt;

  Conversation({
    required this.id,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserAvatar,
    this.lastMessage,
    this.unreadCount = 0,
    required this.updatedAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'].toString(),
      otherUserId: json['other_user_id'].toString(),
      otherUserName: json['other_user_name'],
      otherUserAvatar: json['other_user_avatar'],
      lastMessage: json['last_message'] != null
          ? Message.fromJson(json['last_message'])
          : null,
      unreadCount: json['unread_count'] ?? 0,
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'other_user_id': otherUserId,
      'other_user_name': otherUserName,
      'other_user_avatar': otherUserAvatar,
      'last_message': lastMessage?.toJson(),
      'unread_count': unreadCount,
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
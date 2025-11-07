// providers/message_provider.dart
import 'package:flutter/material.dart';
import '../models/message.dart';

class MessageProvider with ChangeNotifier {
  List<Message> _messages = [];
  List<Conversation> _conversations = [];
  bool _isLoading = false;
  String? _error;

  List<Message> get messages => _messages;
  List<Conversation> get conversations => _conversations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get messages with a specific user
  List<Message> getMessagesWithUser(String userId) {
    return _messages
        .where((msg) =>
            msg.senderId == userId || msg.receiverId == userId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Fetch all conversations
  Future<void> fetchConversations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: Call API
      await Future.delayed(const Duration(seconds: 1));

      _conversations = _getMockConversations();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch messages with a specific user
  Future<void> fetchMessages(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: Call API
      await Future.delayed(const Duration(seconds: 1));

      // Filter messages for this user
      _messages = _getMockMessages()
          .where((msg) =>
              msg.senderId == userId || msg.receiverId == userId)
          .toList();

      // Mark messages as read
      await markMessagesAsRead(userId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Send a message
  Future<void> sendMessage(Message message) async {
    try {
      // Optimistically add message to UI
      _messages.insert(0, message);
      notifyListeners();

      // TODO: Call API to send message
      await Future.delayed(const Duration(milliseconds: 500));

      // Update conversation list
      _updateConversationList(message);

    } catch (e) {
      _error = e.toString();
      // Remove message if failed
      _messages.removeWhere((m) => m.id == message.id);
      notifyListeners();
    }
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String userId) async {
    try {
      // TODO: Call API
      
      // Update local state
      for (var i = 0; i < _messages.length; i++) {
        if (_messages[i].senderId == userId && !_messages[i].isRead) {
          _messages[i] = _messages[i].copyWith(isRead: true);
        }
      }

      // Update conversation unread count
      final convIndex = _conversations.indexWhere(
        (conv) => conv.otherUserId == userId,
      );
      if (convIndex != -1) {
        _conversations[convIndex] = Conversation(
          id: _conversations[convIndex].id,
          otherUserId: _conversations[convIndex].otherUserId,
          otherUserName: _conversations[convIndex].otherUserName,
          otherUserAvatar: _conversations[convIndex].otherUserAvatar,
          lastMessage: _conversations[convIndex].lastMessage,
          unreadCount: 0,
          updatedAt: _conversations[convIndex].updatedAt,
        );
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  // Update conversation list after sending message
  void _updateConversationList(Message message) {
    final existingIndex = _conversations.indexWhere(
      (conv) => conv.otherUserId == message.receiverId,
    );

    final updatedConversation = Conversation(
      id: existingIndex != -1 ? _conversations[existingIndex].id : message.id,
      otherUserId: message.receiverId,
      otherUserName: message.receiverName,
      otherUserAvatar: message.receiverAvatar,
      lastMessage: message,
      unreadCount: 0,
      updatedAt: DateTime.now(),
    );

    if (existingIndex != -1) {
      _conversations[existingIndex] = updatedConversation;
    } else {
      _conversations.insert(0, updatedConversation);
    }

    // Sort by updated time
    _conversations.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    notifyListeners();
  }

  // Get unread message count
  int getUnreadCount() {
    return _conversations.fold(
      0,
      (sum, conv) => sum + conv.unreadCount,
    );
  }

  // Mock data generators
  List<Conversation> _getMockConversations() {
    return [
      Conversation(
        id: '1',
        otherUserId: '2',
        otherUserName: 'Ahmed Ben Ali',
        otherUserAvatar: null,
        lastMessage: Message(
          id: '1',
          senderId: '2',
          senderName: 'Ahmed Ben Ali',
          receiverId: '1',
          receiverName: 'John Doe',
          content: 'Bonjour, est-ce que l\'appartement est toujours disponible ?',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        unreadCount: 2,
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Conversation(
        id: '2',
        otherUserId: '3',
        otherUserName: 'Fatma Trabelsi',
        otherUserAvatar: null,
        lastMessage: Message(
          id: '2',
          senderId: '1',
          senderName: 'John Doe',
          receiverId: '3',
          receiverName: 'Fatma Trabelsi',
          content: 'Merci pour votre réponse',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          isRead: true,
        ),
        unreadCount: 0,
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Conversation(
        id: '3',
        otherUserId: '4',
        otherUserName: 'Mohamed Saidi',
        otherUserAvatar: null,
        lastMessage: Message(
          id: '3',
          senderId: '4',
          senderName: 'Mohamed Saidi',
          receiverId: '1',
          receiverName: 'John Doe',
          content: 'Je suis intéressé par votre villa',
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          isRead: true,
        ),
        unreadCount: 0,
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
  }

  List<Message> _getMockMessages() {
    return [
      Message(
        id: '1',
        senderId: '2',
        senderName: 'Ahmed Ben Ali',
        receiverId: '1',
        receiverName: 'John Doe',
        content: 'Bonjour',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        isRead: true,
      ),
      Message(
        id: '2',
        senderId: '1',
        senderName: 'John Doe',
        receiverId: '2',
        receiverName: 'Ahmed Ben Ali',
        content: 'Bonjour ! Comment puis-je vous aider ?',
        createdAt: DateTime.now().subtract(const Duration(hours: 3, minutes: 5)),
        isRead: true,
      ),
      Message(
        id: '3',
        senderId: '2',
        senderName: 'Ahmed Ben Ali',
        receiverId: '1',
        receiverName: 'John Doe',
        content: 'Est-ce que l\'appartement est toujours disponible ?',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false,
      ),
      Message(
        id: '4',
        senderId: '2',
        senderName: 'Ahmed Ben Ali',
        receiverId: '1',
        receiverName: 'John Doe',
        content: 'Je souhaiterais organiser une visite',
        createdAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 2)),
        isRead: false,
      ),
    ];
  }
}
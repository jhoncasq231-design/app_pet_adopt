// lib/data/models/message.dart
import 'package:equatable/equatable.dart';

class ChatMessage extends Equatable {
  final String text;
  final bool isUser;

  const ChatMessage({required this.text, required this.isUser});

  @override
  List<Object?> get props => [text, isUser];
}

import 'package:equatable/equatable.dart';

class ChatMessage extends Equatable {
  final String text;
  final bool isUser;

  const ChatMessage({required this.text, required this.isUser});

  @override
  List<Object?> get props => [text, isUser];
}

abstract class ChatState extends Equatable {
  final List<ChatMessage> messages;
  const ChatState({this.messages = const []});

  @override
  List<Object?> get props => [messages];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {
  const ChatLoading({required List<ChatMessage> messages})
    : super(messages: messages);
}

class ChatLoaded extends ChatState {
  const ChatLoaded({required List<ChatMessage> messages})
    : super(messages: messages);
}

class ChatError extends ChatState {
  final String errorMessage;
  const ChatError({
    required this.errorMessage,
    required List<ChatMessage> messages,
  }) : super(messages: messages);
}

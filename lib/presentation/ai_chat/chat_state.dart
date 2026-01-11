import 'package:equatable/equatable.dart';
import '../../data/models/message.dart';

abstract class ChatState extends Equatable {
  final List<ChatMessage> messages;
  const ChatState({this.messages = const []});

  @override
  List<Object?> get props => [messages];
}

class ChatInitial extends ChatState {
  const ChatInitial() : super(messages: const []);
}

class ChatLoading extends ChatState {
  const ChatLoading({required List<ChatMessage> messages}) : super(messages: messages);
}

class ChatLoaded extends ChatState {
  const ChatLoaded({required List<ChatMessage> messages}) : super(messages: messages);
}

class ChatError extends ChatState {
  final String errorMessage;
  const ChatError({required this.errorMessage, required List<ChatMessage> messages})
      : super(messages: messages);

  @override
  List<Object?> get props => [errorMessage, messages];
}

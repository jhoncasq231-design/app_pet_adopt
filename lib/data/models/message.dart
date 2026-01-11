enum MessageType { user, ai }

class Message {
  final String text;
  final MessageType type;

  Message({required this.text, required this.type});
}

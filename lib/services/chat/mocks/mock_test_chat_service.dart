import '../../../models/message/message_model.dart';
import '../../../models/message/role.dart';
import '../chat_service_interface.dart';

class TestChatService implements AbstractChatService {
  final chatHistories = <Message>[...sampleMessageList];

  @override
  Future<List<Message>> getMessages() async {
    return chatHistories;
  }

  @override
  Future<void> initialize() async {}

  @override
  Future<void> sendMessage(String content) async {
    chatHistories.add(
      (
        content: content,
        role: Role.user,
        timestamp: DateTime.now(),
      ),
    );
  }
}

final sampleBaseDateTime = DateTime(
  2021,
  10,
  10,
  10,
  10,
);

final sampleMessageList = [
  (
    content: 'Hello, world!',
    role: Role.user,
    timestamp: sampleBaseDateTime,
  ),
  (
    content: 'Hi, there!',
    role: Role.ai,
    timestamp: sampleBaseDateTime.add(const Duration(seconds: 1)),
  ),
  (
    content: 'How are you?',
    role: Role.user,
    timestamp: sampleBaseDateTime.add(const Duration(seconds: 2)),
  ),
  (
    content: 'I am fine, thank you!',
    role: Role.ai,
    timestamp: sampleBaseDateTime.add(const Duration(seconds: 3)),
  ),
  (
    content: 'Hello, world!',
    role: Role.user,
    timestamp: sampleBaseDateTime,
  ),
  (
    content: 'Hi, there!',
    role: Role.ai,
    timestamp: sampleBaseDateTime.add(const Duration(seconds: 1)),
  ),
  (
    content: 'How are you?',
    role: Role.user,
    timestamp: sampleBaseDateTime.add(const Duration(seconds: 2)),
  ),
  (
    content: 'I am fine, thank you!',
    role: Role.ai,
    timestamp: sampleBaseDateTime.add(const Duration(seconds: 3)),
  ),
  (
    content: 'Hello, world!',
    role: Role.user,
    timestamp: sampleBaseDateTime,
  ),
  (
    content: 'Hi, there!',
    role: Role.ai,
    timestamp: sampleBaseDateTime.add(const Duration(seconds: 1)),
  ),
  (
    content: 'How are you?',
    role: Role.user,
    timestamp: sampleBaseDateTime.add(const Duration(seconds: 2)),
  ),
  (
    content: 'I am fine, thank you!',
    role: Role.ai,
    timestamp: sampleBaseDateTime.add(const Duration(seconds: 3)),
  ),
  (
    content: 'Hello, world!',
    role: Role.user,
    timestamp: sampleBaseDateTime,
  ),
  (
    content: 'Hi, there!',
    role: Role.ai,
    timestamp: sampleBaseDateTime.add(const Duration(seconds: 1)),
  ),
  (
    content: 'How are you?',
    role: Role.user,
    timestamp: sampleBaseDateTime.add(const Duration(seconds: 2)),
  ),
  (
    content: 'I am fine, thank you!',
    role: Role.ai,
    timestamp: sampleBaseDateTime.add(const Duration(seconds: 3)),
  ),
];

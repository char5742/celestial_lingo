import '../../models/message/message_model.dart';

abstract interface class AbstractChatService {
  Future<void> initialize();
  Future<List<Message>> getMessages();
  Future<void> sendMessage(String content);
}

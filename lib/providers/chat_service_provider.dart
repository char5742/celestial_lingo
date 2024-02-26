import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/chat/chat_service_interface.dart';
import '../services/chat/openai_chat_service.dart';

part 'chat_service_provider.g.dart';

@Riverpod(keepAlive: true)
AbstractChatService chatService(ChatServiceRef ref) {
  return OpenAIChatService(ref);
}

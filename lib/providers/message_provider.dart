import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/message/message_model.dart';
import 'chat_service_provider.dart';

part 'message_provider.g.dart';

@Riverpod()
Future<List<Message>> messageList(MessageListRef ref) async {
  return ref.watch(chatServiceProvider).getMessages();
}

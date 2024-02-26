import 'message_model.dart';
import 'role.dart';

extension OpenAIMessage on Message {
  static Message fromOepnAIJson(Map<String, dynamic> json) {
    final content = json['content'] as List<dynamic>;
    final text =
        (content.first as Map<String, dynamic>)['text'] as Map<String, dynamic>;
    final value = text['value'] as String;
    return (
      content: value,
      role: json['role'] == 'user' ? Role.user : Role.ai,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
          int.parse(json['created_at'].toString()) * 1000),
    );
  }
}

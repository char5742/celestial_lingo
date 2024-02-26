import 'dart:convert';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../models/message/message_model.dart';
import '../../models/message/openai_message.dart';
import '../../models/message/role.dart';
import '../../providers/message_provider.dart';
import 'chat_service_interface.dart';

class OpenAIChatService implements AbstractChatService {
  OpenAIChatService(this.ref);
  final Ref ref;

  final _apiKey = const String.fromEnvironment('apiKey');
  final _apiBase = 'https://api.openai.com/v1/';
  Map<String, String> get _headersBase => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
        'OpenAI-Beta': 'assistants=v1',
      };

  late String _threadId;
  late String _assistantId;

  @override
  Future<void> initialize() async {
    // スレッドIDとアシスタントIDを作成する場合
    // _threadId = await _createThread();
    // _assistantId = await _createAssistant(
    //   instructions: const String.fromEnvironment('instructions'),
    //   name: 'celestial_lingo_bot',
    //   tools: [
    //     {'type': 'retrieval'},
    //   ],
    // );

    _threadId = const String.fromEnvironment('threadId');
    _assistantId = const String.fromEnvironment('assistantId');
  }

  @override
  Future<List<Message>> getMessages() async {
    final response = await http.get(
      Uri.parse('$_apiBase/threads/$_threadId/messages'),
      headers: _headersBase,
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      final messages = responseData['data'] as List;
      return messages
          .map(
            (message) =>
                OpenAIMessage.fromOepnAIJson(message as Map<String, dynamic>),
          )
          .expand(_splitMessage)
          .toList()
          .reversed
          .toList();
    }
    // エラー処理
    throw Exception('Failed to get messages: ${response.statusCode}');
  }

  @override
  Future<void> sendMessage(String content) async {
    await _addMessage(content);
    ref.invalidate(messageListProvider);
    final runId = await _runAssistant(_assistantId);
    while (!await _isCompleted(runId)) {
      await Future<void>.delayed(const Duration(seconds: 1));
    }
    ref.invalidate(messageListProvider);
  }

  /// 新しいアシスタントを作成し、そのIDを返す
  ///
  /// [instructions] はアシスタントに与える指示
  /// [name] はアシスタントの名前
  /// [model] は使用するモデル
  /// [tools] は使用するツール。`code_interpreter`, `retrieval`, or `function`.
  Future<String> _createAssistant({
    required String instructions,
    required String name,
    String model = 'gpt-4-turbo-preview',
    List<Map<String, String>> tools = const [],
  }) async {
    final response = await http.post(
      Uri.parse('$_apiBase/assistants'),
      headers: _headersBase,
      body: jsonEncode({
        'instructions': instructions,
        'name': name,
        'tools': tools,
        'model': model,
      }),
    );

    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as Map<String, dynamic>)['id']
          as String;
    }
    // TODO(char574): エラー処理
    throw Exception('Failed to create a assistant: ${response.body}');
  }

  /// 新しいスレッドを作成し、そのIDを返す
  Future<String> _createThread() async {
    final response = await http.post(
      Uri.parse('$_apiBase/threads'),
      headers: _headersBase,
    );

    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as Map<String, dynamic>)['id']
          as String;
    }
    // TODO(char574): エラー処理
    throw Exception('Failed to create a thread: ${response.statusCode}');
  }

  Future<void> _addMessage(String content) async {
    final response = await http.post(
      Uri.parse('$_apiBase/threads/$_threadId/messages'),
      headers: _headersBase,
      body: jsonEncode({
        'role': 'user',
        'content': content,
      }),
    );

    if (response.statusCode != 200) {
      // TODO(char574): エラー処理
      throw Exception('Failed to add a message: ${response.statusCode}');
    }
  }

  /// アシスタントを実行し、実行IDを返す
  Future<String> _runAssistant(String assistantId) async {
    final response = await http.post(
      Uri.parse('$_apiBase/threads/$_threadId/runs'),
      headers: _headersBase,
      body: jsonEncode({
        'assistant_id': assistantId,
        // 新しい指示を与えることができるが、既存の指示をオーバーライドする
        // 'instructions': '',
      }),
    );

    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as Map<String, dynamic>)['id']
          as String;
    }
    // TODO(char574): エラー処理
    throw Exception('Failed to run the assistant: ${response.body}');
  }

  /// アシスタントが完了したかどうかを返す
  Future<bool> _isCompleted(String runId) async {
    final response = await http.get(
      Uri.parse('$_apiBase/threads/$_threadId/runs/$runId'),
      headers: _headersBase,
    );

    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as Map<String, dynamic>)['status'] ==
          'completed';
    }
    // TODO(char574): エラー処理
    throw Exception(
      'Failed to check the assistant`s status: ${response.body}',
    );
  }

  /// メッセージを分割する
  ///
  /// AIのメッセージを2つの改行ごとに分割する
  List<Message> _splitMessage(Message message) {
    if (message.role == Role.ai) {
      final spilited = message.content.split('\n\n');
      return spilited
          .map(
            (c) => (
              content: c,
              role: Role.ai,
              timestamp: message.timestamp,
            ),
          )
          .toList();
    }
    return [message];
  }
}

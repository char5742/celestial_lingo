import 'dart:convert';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;

import 'talk_surpport_service.dart';

class OpenAITalkSupportService implements AbstractTalkSupportService {
  OpenAITalkSupportService(this.ref);
  final Ref ref;

  final _apiKey = const String.fromEnvironment('apiKey');
  final _apiBase = 'https://api.openai.com/v1/';
  Map<String, String> get _headersBase => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      };

  /// OpenAIのChat Completion APIを使用して、指定されたテキストを翻訳する
  /// 日本であれば英語に、英語であれば日本語に翻訳する
  /// [content] 翻訳するテキスト
  /// return 翻訳結果
  /// throws Exception 翻訳に失敗した場合
  @override
  Future<String> translate(String content) {
    final messages = [
      {
        'role': 'system',
        'content': '''
Translate the following text into the other language.
If the input is in Japanese, translate it into English.
If the input is in English, translate it into Japanese.
return the translated text.
''',
      },
      {
        'role': 'user',
        'content': content,
      },
    ];
    final body = jsonEncode({
      'model': 'gpt-3.5-turbo',
      'messages': messages,
    });

    return http
        .post(
      Uri.parse('$_apiBase/chat/completions'),
      headers: _headersBase,
      body: body,
    )
        .then((response) {
      if (response.statusCode == 200) {
        final responseData =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        return (((responseData['choices'] as List<dynamic>)[0]
                as Map<String, dynamic>)['message']
            as Map<String, dynamic>)['content'] as String;
      } else {
        throw Exception('Failed to load translation');
      }
    });
  }
}

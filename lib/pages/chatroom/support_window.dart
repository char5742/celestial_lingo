import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../providers/talk_support_service_provider.dart';

/// 翻訳を行うウィンドウ
class TranslateWindow extends HookConsumerWidget {
  const TranslateWindow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final translateResult = useState('');

    Future<void> onSubmitted(String value) async {
      final result =
          await ref.read(talkSupportServiceProvider).translate(value);
      print(result);
      translateResult.value = result;
    }

    return Container(
      width: 300,
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              labelText: '翻訳する文章を入力してください',
              border: OutlineInputBorder(),
            ),
            onSubmitted: onSubmitted,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              child: SelectableText(
                translateResult.value,
                style: theme.textTheme.bodyLarge,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

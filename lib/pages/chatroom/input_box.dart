import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../providers/chat_service_provider.dart';
import 'components.dart';

class InputBox extends HookConsumerWidget {
  const InputBox({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatController = useTextEditingController();
    final focusNode = useFocusNode();
    final theme = Theme.of(context);

    Future<void> submit() async {
      final text = chatController.text;
      if (text.isEmpty) {
        return;
      }
      chatController.clear();

      await ref.read(chatServiceProvider).sendMessage(text);
    }

    const shortcutMap = <ShortcutActivator, Intent>{
      SingleActivator(LogicalKeyboardKey.enter, alt: true): ActivateIntent(),
    };

    final actionMap = <Type, Action<Intent>>{
      ActivateIntent: CallbackAction<ActivateIntent>(
        onInvoke: (intent) {
          submit();
          return null;
        },
      ),
    };

    return ColoredBox(
      color: theme.colorScheme.primaryContainer,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(
                left: 50,
                top: 10,
                bottom: 10,
              ),
              child: FocusableActionDetector(
                focusNode: focusNode,
                actions: actionMap,
                shortcuts: shortcutMap,
                child: TextField(
                  maxLines: 4,
                  minLines: 1,
                  decoration: InputDecoration(
                    isDense: true,
                    isCollapsed: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10,
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.background,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        width: 0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        width: 0,
                      ),
                    ),
                  ),
                  controller: chatController,
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8, left: 8, bottom: 3),
            child: OutlinedIconButton(
              icon: Icons.send_outlined,
              onPressed: submit,
            ),
          ),
        ],
      ),
    );
  }
}

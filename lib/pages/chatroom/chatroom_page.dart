import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../providers/message_provider.dart';
import 'input_box.dart';
import 'message_box.dart';

class ChatRoomPage extends HookConsumerWidget {
  const ChatRoomPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messageListAsync = ref.watch(messageListProvider);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: () {
                context.go('/settings');
              },
              icon: const Icon(Icons.settings),
            ),
          ],
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: switch (messageListAsync) {
                AsyncError(:final error) => Text(error.toString()),
                AsyncData(:final value) => ListView.builder(
                    physics: const ClampingScrollPhysics(),
                    reverse: true,
                    itemBuilder: (context, index) =>
                        value.reversed.map(MessageBox.new).toList()[index],
                    itemCount: value.length,
                  ),
                _ => const SizedBox(),
              },
            ),
            const InputBox(),
          ],
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../models/message/message_model.dart';
import '../../models/message/role.dart';

class MessageBox extends HookConsumerWidget {
  const MessageBox(
    this.message, {
    super.key,
  });
  final Message message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final content = message.content;
    final isAi = message.role == Role.ai;
    void handleContextMenuAction(String value) {
      switch (value) {
        case 'copy':
          Clipboard.setData(ClipboardData(text: message.content));
      }
    }

    final rows = [
      Flexible(
        flex: 2,
        child: MessageContent(
          content: content,
          isAi: isAi,
          onContextMenuSelected: handleContextMenuAction,
        ),
      ),
      //投稿時間
      const SizedBox(width: 8),
      Flexible(
        child: Text(
          '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}',
          style: theme.textTheme.labelSmall,
        ),
      ),
    ];
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment:
            isAi ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: isAi ? rows : rows.reversed.toList(),
      ),
    );
  }
}

class MessageContent extends StatelessWidget {
  const MessageContent({
    super.key,
    required this.content,
    required this.isAi,
    this.onContextMenuSelected,
  });

  final String content;
  final bool isAi;
  final void Function(String)? onContextMenuSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Ink(
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.onSecondaryContainer),
      ),
      child: TextFieldTapRegion(
        child: InkWell(
          onLongPress: () async {
            final selectedValue = await _showContextMenu(
              context,
              left: isAi,
              items: const [
                _ContextMenuItem(
                  icon: Icon(Icons.copy),
                  value: 'copy',
                  text: 'コピー',
                ),
              ],
            );
            if (selectedValue != null) {
              onContextMenuSelected?.call(selectedValue);
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Text(
              content,
              style: theme.textTheme.bodyLarge?.copyWith(letterSpacing: 0),
            ),
          ),
        ),
      ),
    );
  }
}

class _ContextMenuItem {
  const _ContextMenuItem({
    required this.icon,
    required this.text,
    this.value,
    this.onTap,
  });

  final Icon icon;
  final String text;
  final String? value;
  final void Function()? onTap;
}

class _ContextMenuItemWidget extends StatelessWidget {
  const _ContextMenuItemWidget({
    super.key,
    required this.icon,
    required this.text,
    this.onTap,
  });

  final Icon icon;
  final String text;
  final void Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onTapDown: (_) {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          children: [
            icon,
            const SizedBox(height: 4),
            Opacity(
              opacity: 0.7,
              child: Text(text, style: Theme.of(context).textTheme.labelSmall),
            ),
          ],
        ),
      ),
    );
  }
}

Future<String?> _showContextMenu(
  BuildContext context, {
  bool left = true,
  required List<_ContextMenuItem> items,
}) async {
  final overlayState = Overlay.of(context);
  final renderBox = context.findRenderObject()! as RenderBox;
  final size = renderBox.size;
  final position = renderBox.localToGlobal(Offset.zero);
  final isTopHalf = position.dy < (MediaQuery.of(context).size.height) / 3;
  final completer = Completer<String?>();
  late OverlayEntry overlayEntry;
  void closeMenu() {
    overlayEntry.remove();
  }

  overlayEntry = OverlayEntry(
    builder: (context) => TapRegion(
      onTapOutside: (_) =>
          closeMenu(), // Closes the menu when user taps outside
      child: Stack(
        children: [
          _buildMenuPositioned(
            context,
            position: position,
            size: size,
            isTopHalf: isTopHalf,
            left: left,
            items: items,
            completer: completer,
            closeMenu: closeMenu,
          ),
        ],
      ),
    ),
  );

  overlayState.insert(overlayEntry);
  return completer.future;
}

Positioned _buildMenuPositioned(
  BuildContext context, {
  required Offset position,
  required Size size,
  required bool isTopHalf,
  required bool left,
  required List<_ContextMenuItem> items,
  required Completer<String?> completer,
  required VoidCallback closeMenu,
}) {
  return Positioned(
    bottom: isTopHalf ? null : MediaQuery.of(context).size.height - position.dy,
    top: isTopHalf ? position.dy + size.height : null,
    left: left ? position.dx : null,
    right: !left
        ? MediaQuery.of(context).size.width - position.dx - size.width
        : null,
    child: Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(16),
      color: Theme.of(context).colorScheme.tertiaryContainer,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: items
            .map((item) => _buildMenuItem(item, completer, closeMenu))
            .toList(),
      ),
    ),
  );
}

_ContextMenuItemWidget _buildMenuItem(
  _ContextMenuItem item,
  Completer<String?> completer,
  VoidCallback closeMenu,
) {
  return _ContextMenuItemWidget(
    icon: item.icon,
    text: item.text,
    onTap: () {
      item.onTap?.call();
      closeMenu();
      completer.complete(item.value);
    },
  );
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// An icon button with a circular outline that becomes solid when hovered over.
class OutlinedIconButton extends HookConsumerWidget {
  const OutlinedIconButton({
    super.key,
    required this.icon,
    this.color,
    required this.onPressed,
  });
  final IconData icon;
  final void Function() onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hover = useState(false);
    return Padding(
      padding: const EdgeInsets.all(8),
      child: GestureDetector(
        onTap: onPressed,
        child: MouseRegion(
          onEnter: (_) => hover.value = true,
          onExit: (_) => hover.value = false,
          child: Icon(
            icon,
            // color: (color ?? Theme.of(context).iconTheme.color)
            //     ?.withAlpha(hover.value ? 160 : 255),
          ),
        ),
      ),
    );
  }
}

class ContextMenuItem {
  const ContextMenuItem({
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

class ContextMenuItemWidget extends StatelessWidget {
  const ContextMenuItemWidget({
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

Future<String?> showContextMenu(
  BuildContext context, {
  bool left = true,
  required List<ContextMenuItem> items,
}) async {
  final overlayState = Overlay.of(context);
  late OverlayEntry? overlayEntry;
  final responseStream = StreamController<String?>();

  final globalKey = GlobalKey();
  final renderBox = context.findRenderObject()! as RenderBox;
  final size = renderBox.size;
  final position = renderBox.localToGlobal(Offset.zero);

  final isTopHalf = position.dy < (MediaQuery.of(context).size.height) / 3;
  overlayEntry = OverlayEntry(
    builder: (context) => Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (event) {
        // メニューの外側を触ったらメニューを閉じる
        final menuBox =
            globalKey.currentContext!.findRenderObject()! as RenderBox;
        final isPositionInsideRenderBox = menuBox.hitTest(
          BoxHitTestResult(),
          position: menuBox.globalToLocal(event.position),
        );
        if (!isPositionInsideRenderBox) {
          overlayEntry?.remove();
          overlayEntry = null;
          responseStream.add('hello');
        }
      },
      child: Stack(
        children: [
          Positioned(
            bottom: isTopHalf
                ? null
                : MediaQuery.of(context).size.height - position.dy,
            top: isTopHalf ? position.dy + size.height : null,
            left: left ? position.dx : null,
            right: left
                ? null
                : MediaQuery.of(context).size.width - position.dx - size.width,
            child: Material(
              elevation: 5,
              borderRadius: BorderRadius.circular(16),
              color: Theme.of(context).colorScheme.tertiaryContainer,
              child: Row(
                key: globalKey,
                mainAxisSize: MainAxisSize.min,
                children: items
                    .map(
                      (item) => ContextMenuItemWidget(
                        icon: item.icon,
                        text: item.text,
                        onTap: () {
                          item.onTap?.call();
                          overlayEntry?.remove();
                          overlayEntry = null;
                          responseStream.add(item.value);
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  overlayState.insert(overlayEntry!);
  return responseStream.stream.first;
}

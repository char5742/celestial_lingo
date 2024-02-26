import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'app.dart';
import 'providers/chat_service_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer();
  await container.read(chatServiceProvider).initialize();
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const App(),
    ),
  );
}

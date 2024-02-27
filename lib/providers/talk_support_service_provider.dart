import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/talk_support/openai_talk_support_service.dart';
import '../services/talk_support/talk_surpport_service.dart';

part 'talk_support_service_provider.g.dart';

@Riverpod(keepAlive: true)
AbstractTalkSupportService talkSupportService(TalkSupportServiceRef ref) {
  return OpenAITalkSupportService(ref);
}

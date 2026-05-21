import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/ai_repository.dart';
import 'app_providers.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;

  ChatState({required this.messages, this.isLoading = false, this.error});

  ChatState copyWith({List<ChatMessage>? messages, bool? isLoading, String? error}) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class ChatNotifier extends Notifier<ChatState> {
  @override
  ChatState build() {
    return ChatState(messages: []);
  }

  Future<void> sendMessage(String text) async {
    final aiRepository = ref.read(aiRepositoryProvider);
    
    // Add user message
    final newMessages = [...state.messages, ChatMessage(text: text, isUser: true)];
    state = state.copyWith(messages: newMessages, isLoading: true, error: null);

    try {
      // Assuming a generic explainShloka usage for chat, or extending AiRepository.
      // We will use explainShloka with default parameters for now as placeholders.
      final response = await aiRepository.explainShloka(
        chapter: 1,
        verse: 1,
        question: text,
        history: state.messages.map((m) => {'role': m.isUser ? 'user' : 'assistant', 'content': m.text}).toList(),
      );
      
      final answer = response.data['explanation'] ?? response.data.toString();
      state = state.copyWith(
        messages: [...state.messages, ChatMessage(text: answer, isUser: false)],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

final chatProvider = NotifierProvider<ChatNotifier, ChatState>(() {
  return ChatNotifier();
});

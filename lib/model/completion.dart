import 'package:equatable/equatable.dart';

class ChatCompletionResponse extends Equatable {
  const ChatCompletionResponse({
    required this.id,
    required this.object,
    required this.created,
    required this.model,
    required this.systemFingerprint,
    required this.choices,
    required this.usage,
  });

  factory ChatCompletionResponse.fromJson(Map<String, dynamic> json) {
    return ChatCompletionResponse(
      id: json['id'] as String? ?? '',
      object: json['object'] as String? ?? 'chat.completion',
      created: json['created'] as int? ?? 0,
      model: json['model'] as String? ?? '',
      systemFingerprint: json['system_fingerprint'] as String? ?? '',
      choices: (json['choices'] as List<dynamic>?)
              ?.map((choice) => Choice.fromJson(choice as Map<String, dynamic>))
              .toList() ??
          [],
      usage: Usage.fromJson(json['usage'] as Map<String, dynamic>? ?? {}),
    );
  }

  final String id;
  final String object;
  final int created;
  final String model;
  final String systemFingerprint;
  final List<Choice> choices;
  final Usage usage;

  Map<String, dynamic> toJson() => {
        'id': id,
        'object': object,
        'created': created,
        'model': model,
        'system_fingerprint': systemFingerprint,
        'choices': choices.map((choice) => choice.toJson()).toList(),
        'usage': usage.toJson(),
      };

  @override
  String toString() {
    return '''ChatCompletionResponse(
      id: $id,
      object: $object,
      created: $created,
      model: $model,
      systemFingerprint: $systemFingerprint,
      choices: ${choices.map((c) => '\n        ${c.toString().replaceAll('\n', '\n        ')}')}
      usage: \n        ${usage.toString().replaceAll('\n', '\n        ')}
    )''';
  }

  @override
  List<Object?> get props => [
        id,
        object,
        created,
        model,
        systemFingerprint,
        choices,
        usage,
      ];
}

class Choice {
  Choice({
    required this.index,
    required this.message,
    required this.finishReason,
    this.logprobs,
  });

  factory Choice.fromJson(Map<String, dynamic> json) {
    return Choice(
      index: json['index'] as int? ?? 0,
      message: Message.fromJson(json['message'] as Map<String, dynamic>? ?? {}),
      logprobs: json['logprobs'], // Keep as dynamic since it can be null
      finishReason: json['finish_reason'] as String? ?? 'stop',
    );
  }
  final int index;
  final Message message;
  final dynamic logprobs;
  final String finishReason;

  Map<String, dynamic> toJson() => {
        'index': index,
        'message': message.toJson(),
        'logprobs': logprobs,
        'finish_reason': finishReason,
      };

  @override
  String toString() {
    return '''Choice(
      index: $index,
      message: ${message.toString().replaceAll('\n', '\n      ')},
      logprobs: $logprobs,
      finishReason: $finishReason
    )''';
  }
}

class Message {
  Message({
    required this.role,
    required this.content,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      role: json['role'] as String? ?? 'assistant',
      content: json['content'] as String? ?? '',
    );
  }
  final String role;
  final String content;

  Map<String, dynamic> toJson() => {
        'role': role,
        'content': content,
      };

  @override
  String toString() {
    return '''Message(
      role: $role,
      content: $content
    )''';
  }
}

class Usage {
  Usage({
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
    required this.completionTokensDetails,
  });

  factory Usage.fromJson(Map<String, dynamic> json) {
    return Usage(
      promptTokens: json['prompt_tokens'] as int? ?? 0,
      completionTokens: json['completion_tokens'] as int? ?? 0,
      totalTokens: json['total_tokens'] as int? ?? 0,
      completionTokensDetails: CompletionTokensDetails.fromJson(
        json['completion_tokens_details'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
  final int promptTokens;
  final int completionTokens;
  final int totalTokens;
  final CompletionTokensDetails completionTokensDetails;

  Map<String, dynamic> toJson() => {
        'prompt_tokens': promptTokens,
        'completion_tokens': completionTokens,
        'total_tokens': totalTokens,
        'completion_tokens_details': completionTokensDetails.toJson(),
      };
}

class CompletionTokensDetails {
  CompletionTokensDetails({
    required this.reasoningTokens,
    required this.acceptedPredictionTokens,
    required this.rejectedPredictionTokens,
  });

  factory CompletionTokensDetails.fromJson(Map<String, dynamic> json) {
    return CompletionTokensDetails(
      reasoningTokens: json['reasoning_tokens'] as int? ?? 0,
      acceptedPredictionTokens: json['accepted_prediction_tokens'] as int? ?? 0,
      rejectedPredictionTokens: json['rejected_prediction_tokens'] as int? ?? 0,
    );
  }
  final int reasoningTokens;
  final int acceptedPredictionTokens;
  final int rejectedPredictionTokens;

  Map<String, dynamic> toJson() => {
        'reasoning_tokens': reasoningTokens,
        'accepted_prediction_tokens': acceptedPredictionTokens,
        'rejected_prediction_tokens': rejectedPredictionTokens,
      };
}

final class Translation {
  const Translation({required this.text});

  factory Translation.fromJson(Map<String, dynamic> json) =>
      Translation(text: json['text'] as String? ?? '');

  final String text;
}

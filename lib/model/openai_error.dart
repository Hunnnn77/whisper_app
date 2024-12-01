import 'package:equatable/equatable.dart';

class OpenAIErrorResponse extends Equatable {
  const OpenAIErrorResponse({required this.error});

  factory OpenAIErrorResponse.fromJson(Map<String, dynamic> json) {
    // Type assertion for the entire error object
    if (json['error'] is! Map<String, dynamic>) {
      throw const FormatException('Invalid error object type');
    }

    return OpenAIErrorResponse(
      error: OpenAIError.fromJson(json['error'] as Map<String, dynamic>),
    );
  }
  final OpenAIError error;

  Map<String, dynamic> toJson() {
    return {
      'error': error.toJson(),
    };
  }

  @override
  List<Object?> get props => [error];
}

class OpenAIError {
  OpenAIError({
    required this.message,
    required this.type,
    required this.code,
    this.param,
  });

  factory OpenAIError.fromJson(Map<String, dynamic> json) {
    // Type assertions for each field
    if (json['message'] is! String) {
      throw FormatException('Invalid message type: ${json['message']}');
    }

    if (json['type'] is! String) {
      throw FormatException('Invalid type: ${json['type']}');
    }

    if (json['code'] is! String) {
      throw FormatException('Invalid code type: ${json['code']}');
    }

    return OpenAIError(
      message: json['message'] as String,
      type: json['type'] as String,
      param: json['param'], // Allow dynamic type for param
      code: json['code'] as String,
    );
  }
  final String message;
  final String type;
  final dynamic param;
  final String code;

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'type': type,
      'param': param,
      'code': code,
    };
  }
}

import 'dart:convert';
import 'package:listener_demo/inh/state.dart';
import 'package:listener_demo/model/completion.dart';
import 'package:typed_monad/typed_monad.dart';

final class Screen extends ViewModel<ScreenState, ScreenEvent> {
  Screen._() : super(Ok(ScreenInitalState())) {
    event.listen(
      (e) => switch (e) {
        ScreenLoadingEvent() => _loading(),
        ScreenSuccessEvent(:final chat) => _success(chat),
        ScreenFailureEvent(:final e) => _fail(e),
        ScreenInitialEvent() => _init(),
      },
    );
  }
  static Screen? _instance;
  static Screen instance() {
    _instance ??= Screen._();
    return _instance!;
  }

  final List<(Side, String)> messages = [];
  void _init() {
    emit(Ok(ScreenInitalState()));
  }

  void _success((Side, ChatCompletionResponse) chat) {
    try {
      final msg = utf8.decode(chat.$2.choices[0].message.content.codeUnits);
      messages.add((chat.$1, msg));
      emit(Ok(ScreenSuccessState(messages)));
    } on Exception catch (e) {
      emit(Err(e));
    } catch (e) {
      emit(Err(Exception(e.toString())));
    }
  }

  void _fail(String e) => emit(Err(Exception(e)));

  void _loading() => emit(Ok(ScreenLoadingState()));
}

sealed class ScreenState {}

final class ScreenInitalState extends ScreenState {}

final class ScreenLoadingState extends ScreenState {
  ScreenLoadingState();
}

final class ScreenSuccessState extends ScreenState {
  ScreenSuccessState(this.ok);
  final List<(Side, String)> ok;
}

sealed class ScreenEvent {}

final class ScreenInitialEvent extends ScreenEvent {
  ScreenInitialEvent();
}

final class ScreenLoadingEvent extends ScreenEvent {
  ScreenLoadingEvent();
}

final class ScreenSuccessEvent extends ScreenEvent {
  ScreenSuccessEvent(this.chat);
  final (Side, ChatCompletionResponse) chat;
}

final class ScreenFailureEvent extends ScreenEvent {
  ScreenFailureEvent(this.e);
  final String e;
}

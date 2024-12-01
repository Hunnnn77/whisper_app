import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:country_flags/country_flags.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:listener_demo/bloc/screen.dart';
import 'package:listener_demo/inh/inh.dart';
import 'package:listener_demo/inh/log.dart';
import 'package:listener_demo/inh/state.dart';
import 'package:listener_demo/model/completion.dart';
import 'package:listener_demo/model/openai_error.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:typed_monad/typed_monad.dart';

class RecorderButton extends StatefulWidget {
  const RecorderButton(
    this.provider, {
    required this.side,
    required this.code,
    this.textStyle,
    super.key,
  });

  final StateProvider provider;
  final Side side;
  final String code;
  final TextStyle? textStyle;

  @override
  State<RecorderButton> createState() => _RecorderButtonState();
}

class _RecorderButtonState extends State<RecorderButton> {
  late AudioRecorder audioRecorder;

  @override
  void initState() {
    super.initState();
    audioRecorder = AudioRecorder();
  }

  @override
  void dispose() {
    audioRecorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StateProvider>(context);
    final screen = Provider.of<Screen>(context);
    final log = Provider.of<Log>(context);

    return ListenableBuilder(
      listenable: provider,
      builder: (context, child) => FloatingActionButton(
        foregroundColor: Colors.black,
        mini: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(40)),
        ),
        backgroundColor:
            provider.isRecoding ? Colors.yellow[400] : Colors.grey[400],
        onPressed: provider.invalidKey
            ? null
            : () async {
                switch (widget.side) {
                  case Side.from:
                    provider.changeButtonState(ButtonPressd.left);
                  case Side.to:
                    provider.changeButtonState(ButtonPressd.right);
                }
                await _onpressed(
                  log,
                  screen: screen,
                  side: widget.side,
                  provider: provider,
                );
              },
        child: provider.isRecoding
            ? const Icon(Icons.stop)
            : CountryFlag.fromCountryCode(
                widget.code,
                shape: const Circle(),
              ),
      ),
    );
  }

  Future<void> _onpressed(
    Log log, {
    required Screen screen,
    required Side side,
    required StateProvider provider,
  }) async {
    if (!provider.isRecoding) {
      //recording
      await _record(
        log,
        audioRecorder: audioRecorder,
        stateProvider: provider,
        screen: screen,
      ).then(provider.setPath).whenComplete(provider.toggleRecoding);
    } else {
      //stop recording
      await audioRecorder.stop().whenComplete(() {
        provider
          ..toggleHideFloatingButton()
          ..toggleRecoding();
      });

      //make request
      await _sendAudio(
        provider,
        log,
        path: provider.path ?? '',
        screen: screen,
      ).then((data) {
        _translateAudio(
          screen,
          provider,
          log,
          text: data ?? '',
          side: side,
          code: switch (side) {
            Side.to => provider.to!.code,
            Side.from => provider.from!.code,
          },
          country: switch (side) {
            Side.to => provider.to!.country,
            Side.from => provider.from!.country,
          },
        ).whenComplete(() {
          provider
            ..toggleHideFloatingButton()
            ..toggleTranslating()
            ..changeButtonState(ButtonPressd.nothing);
        });
      });

      await File(provider.path ?? '').delete();
      await audioRecorder.cancel();
    }
  }

  Future<String?> _record(
    Log log, {
    required AudioRecorder audioRecorder,
    required StateProvider stateProvider,
    required Screen screen,
  }) async {
    try {
      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

      if (kDebugMode) {
        log.logger.i(path);
      }

      if (await audioRecorder.hasPermission()) {
        await audioRecorder.start(
          const RecordConfig(noiseSuppress: true, echoCancel: true),
          path: path,
        );
      }

      return path;
    } on Exception catch (e) {
      screen.add(ScreenFailureEvent(FromException(e).message));
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> _sendAudio(
    StateProvider provider,
    Log log, {
    required String path,
    required Screen screen,
  }) async {
    screen.add(ScreenLoadingEvent());
    provider.toggleTranslating();

    if (!File(path).existsSync()) {
      screen.add(ScreenFailureEvent('not found file'));
      return null;
    }

    if (kDebugMode) {
      log.logger.i(
        'full: ${widget.provider.path}, file: ${widget.provider.path?.split('/').last}',
      );
    }

    try {
      final req = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.openai.com/v1/audio/translations'),
      )
        ..headers.addAll({
          'Authorization': 'Bearer ${provider.key}',
        })
        ..files.add(
          await http.MultipartFile.fromPath(
            'file',
            path,
            filename: path.split('/').last,
          ),
        )
        ..fields['model'] = 'whisper-1';

      final response = await req.send().then(http.Response.fromStream);

      if (response.statusCode != 200) {
        if (kDebugMode) {
          log.logger.e('${response.statusCode}/${response.body}');
        }
        return null;
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final translation = Translation.fromJson(json);

      if (kDebugMode) {
        log.logger.i('translation: $translation');
      }

      return translation.text;
    } on Exception catch (e) {
      screen.add(ScreenFailureEvent(FromException(e).message));
    } catch (e) {
      screen.add(ScreenFailureEvent(e.toString()));
    }
    return null;
  }

  Future<void> _translateAudio(
    Screen screen,
    StateProvider provider,
    Log log, {
    required String text,
    required Side side,
    required String code,
    required String country,
  }) async {
    final body = <String, dynamic>{
      'model': 'gpt-4o-mini',
      'messages': [
        {'role': 'system', 'content': 'You are a multi-language translator.'},
        {
          'role': 'user',
          'content':
              'tranlsate below sentenses to $country($code) and returns raw output only:\n$text',
        },
      ],
    };

    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${provider.key}',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        screen.add(
          ScreenFailureEvent(
            OpenAIErrorResponse.fromJson(
              jsonDecode(response.body) as Map<String, dynamic>,
            ).error.message,
          ),
        );
        return;
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final fromJson = ChatCompletionResponse.fromJson(json);

      if (kDebugMode) {
        log.logger.i(fromJson);
      }

      screen.add(ScreenSuccessEvent((side, fromJson)));
    } on Exception catch (e) {
      screen.add(ScreenFailureEvent(FromException(e).message));
    } catch (e) {
      screen.add(ScreenFailureEvent(e.toString()));
    }
  }
}

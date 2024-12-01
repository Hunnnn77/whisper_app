import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:listener_demo/bloc/screen.dart';
import 'package:listener_demo/components/recorder_appbar.dart';
import 'package:listener_demo/components/recorder_button.dart';
import 'package:listener_demo/components/snapshot.dart';
import 'package:listener_demo/inh/inh.dart';
import 'package:listener_demo/inh/log.dart';
import 'package:listener_demo/inh/state.dart';
import 'package:listener_demo/styles.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:typed_monad/typed_monad.dart';

part './main_part.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  final localStorage = SharedPreferencesAsync();
  final provider = await StateProvider(localStorage).init();

  runApp(
    Provider(
      children: [
        Log(),
        Screen.instance(),
        provider,
      ],
      child: const _App(),
    ),
  );
}

class _App extends StatelessWidget with DefaultTheme {
  const _App();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StateProvider>(context);

    return MaterialApp(
      theme: light,
      darkTheme: dark,
      home: Scaffold(
        appBar: RecorderAppBar(
          provider: provider,
        ),
        floatingActionButtonLocation:
            FloatingActionButtonLocation.miniCenterDocked,
        floatingActionButton: _Fab(provider: provider),
        body: const _Body(),
      ),
    );
  }
}

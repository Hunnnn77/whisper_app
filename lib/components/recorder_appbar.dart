import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:listener_demo/bloc/screen.dart';
import 'package:listener_demo/inh/inh.dart';
import 'package:listener_demo/inh/state.dart';
import 'package:listener_demo/util/string.dart';

part 'recorder_appbar_part.dart';

class RecorderAppBar extends StatefulWidget implements PreferredSizeWidget {
  const RecorderAppBar({
    required this.provider,
    super.key,
  });
  final StateProvider provider;

  @override
  State<RecorderAppBar> createState() => _RecorderAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(45);
}

class _RecorderAppBarState extends State<RecorderAppBar> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final header = Theme.of(context).textTheme.titleLarge;

    return ListenableBuilder(
      listenable: widget.provider,
      builder: (context, child) => AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _showDialog(
              context,
              provider: widget.provider,
              controller: _controller,
            ),
            icon: const Icon(
              Icons.language,
              color: Colors.white,
            ),
          ),
        ],
        title: widget.provider.isRecoding
            ? _BlinkingText(
                text: 'recording'.toUpperCase(),
                style: header?.copyWith(color: Colors.white),
              )
            : widget.provider.isTranslating
                ? _BlinkingText(
                    text: 'translating'.toUpperCase(),
                    style: header?.copyWith(color: Colors.white),
                  )
                : Text(
                    'paused'.toUpperCase(),
                    style: header?.copyWith(color: Colors.white),
                  ),
      ),
    );
  }

  void _showDialog(
    BuildContext context, {
    required StateProvider provider,
    required TextEditingController controller,
  }) {
    final height = MediaQuery.of(context).size.height;
    final text =
        Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black);
    final themeData = CountryListThemeData(bottomSheetHeight: height / 1.5);
    final screen = Provider.of<Screen>(context);

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('settings'.cap),
            IconButton(
              onPressed: () async {
                await widget.provider
                    .deleteAll()
                    .whenComplete(() => screen.add(ScreenInitialEvent()));
              },
              icon: const Icon(Icons.delete),
            ),
          ],
        ),
        titleTextStyle:
            Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
        titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        backgroundColor: Colors.white,
        content: SingleChildScrollView(
          child: ListenableBuilder(
            listenable: provider,
            builder: (context, child) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SetLangButton(
                      provider,
                      lang: Side.from,
                      themeData: themeData,
                      text: text,
                    ),
                    _SetLangButton(
                      provider,
                      lang: Side.to,
                      themeData: themeData,
                      text: text,
                    ),
                    if (provider.invalidKey)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: TextField(
                          obscureText: true,
                          showCursor: true,
                          decoration: InputDecoration(
                            helper: Center(
                              child: Text(
                                'please keep your api key'.cap,
                                style: text?.copyWith(
                                  decoration: TextDecoration.underline,
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            label: Center(
                              child: Text(
                                'openAI api key'.cap,
                                style: text?.copyWith(fontSize: 13),
                              ),
                            ),
                          ),
                          controller: controller,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'cancel'.toUpperCase(),
                        style: text?.copyWith(fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 16),
                    if (provider.invalidKey)
                      OutlinedButton(
                        onPressed: () {
                          provider.setKey(controller.text.trim());
                          controller.clear();
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'set'.toUpperCase(),
                          style: text?.copyWith(fontSize: 14),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

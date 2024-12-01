part of './main.dart';

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final screen = Provider.of<Screen>(context);
    final provider = Provider.of<StateProvider>(context);
    final log = Provider.of<Log>(context);
    final body = Theme.of(context).textTheme.bodySmall;

    return SafeArea(
      child: Center(
        child: StreamBuilder(
          stream: screen.stream,
          builder: (context, snapshot) {
            return snapshot.on(
              pending: CircularProgressIndicator.new,
              fail: (e) {
                final from = FromException(e);
                if (kDebugMode) {
                  log.logger.e(from.message, error: '${from.type}');
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      '$e',
                      style: body?.copyWith(fontSize: 14),
                    ),
                  ),
                );
              },
              success: (data) => switch (data) {
                ScreenInitalState() => ListenableBuilder(
                    listenable: provider,
                    builder: (context, child) => _Initial(provider: provider),
                  ),
                ScreenSuccessState(:final ok) => _Success(ok: ok, body: body),
                ScreenLoadingState() => const CircularProgressIndicator(),
              },
            );
          },
        ),
      ),
    );
  }
}

class _Fab extends StatelessWidget {
  const _Fab({
    required this.provider,
  });

  final StateProvider provider;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context)
        .textTheme
        .titleLarge
        ?.copyWith(fontSize: 14, color: Colors.white);

    return ListenableBuilder(
      listenable: provider,
      builder: (context, child) => provider.isHideButton
          ? const SizedBox.expand()
          : provider.from == null || provider.to == null || provider.invalidKey
              ? const SizedBox.expand()
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Opacity(
                    opacity: 0.5,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!(provider.buttonPressed == ButtonPressd.right))
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              RecorderButton(
                                provider,
                                side: Side.from,
                                //to
                                code: provider.from!.code,
                              ),
                              if (!provider.isRecoding)
                                Text(
                                  provider.from!.code,
                                  style: text,
                                ),
                            ],
                          ),
                        if (!provider.isRecoding) const Spacer(),
                        if (!(provider.buttonPressed == ButtonPressd.left))
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              RecorderButton(
                                provider,
                                side: Side.to,
                                //from
                                code: provider.to!.code,
                              ),
                              if (!provider.isRecoding)
                                Text(
                                  provider.to!.code,
                                  style: text,
                                ),
                            ],
                          ),
                        // const Spacer(),
                      ],
                    ),
                  ),
                ),
    );
  }
}

class _Success extends StatefulWidget {
  const _Success({
    required this.ok,
    required this.body,
  });

  final List<(Side, String)> ok;
  final TextStyle? body;

  @override
  State<_Success> createState() => _SuccessState();
}

class _SuccessState extends State<_Success> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrolldown();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrolldown() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        children: [
          for (final o in widget.ok)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Column(
                children: [
                  if (o.$1 == Side.from)
                    Row(
                      children: [
                        BubbleSpecialThree(
                          text: o.$2,
                          tail: false,
                          color: const Color(0xFFE8E8EE),
                        ),
                        // Spacer(),
                      ],
                    ),
                  if (o.$1 == Side.to)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Spacer(),
                        BubbleSpecialThree(
                          text: o.$2,
                          tail: false,
                          color: const Color(0xFF1B97F3),
                        ),
                      ],
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Initial extends StatelessWidget {
  const _Initial({
    required this.provider,
    super.key,
  });

  final StateProvider provider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context)
        .textTheme
        .titleLarge
        ?.copyWith(fontSize: 16, color: Colors.white);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (provider.from == null || provider.to == null)
          _ErrorRow(
            theme: theme,
            text: 'missing language',
          ),
        const SizedBox(height: 8),
        if (provider.invalidKey)
          _ErrorRow(
            theme: theme,
            text: 'missing or invalid key',
          ),
        const SizedBox(height: 8),
        if (provider.from != null &&
            provider.to != null &&
            !provider.invalidKey)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.verified,
                color: Colors.green[300],
              ),
              const SizedBox(width: 8),
              Text.rich(
                style: theme?.copyWith(color: Colors.white),
                TextSpan(
                  text: 'a'.toUpperCase(),
                  children: const [
                    TextSpan(text: 'll settings have been completed'),
                  ],
                ),
              )
            ],
          )
      ],
    );
  }
}

class _ErrorRow extends StatelessWidget {
  const _ErrorRow({
    required this.theme,
    required this.text,
  });

  final String text;
  final TextStyle? theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error, color: Colors.red[200], size: 32),
        const SizedBox(width: 8),
        Text(
          text.toUpperCase(),
          style: theme,
        ),
      ],
    );
  }
}

part of './recorder_appbar.dart';

class _SetLangButton extends StatelessWidget {
  const _SetLangButton(
    this.provider, {
    required this.lang,
    required this.themeData,
    required this.text,
  });

  final StateProvider provider;
  final CountryListThemeData themeData;
  final TextStyle? text;
  final Side lang;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: const ButtonStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
      ),
      onPressed: () => showCountryPicker(
        context: context,
        countryListTheme: themeData,
        onSelect: (Country country) => provider.setLang(
          lang,
          (
            code: country.countryCode,
            country: country.displayName.split(' ').first
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            (lang == Side.from ? 'left'.cap : 'right'.cap),
            style: text?.copyWith(fontSize: 14),
          ),
          const SizedBox(width: 8),
          if (provider.from != null || provider.to != null)
            Text(
              lang == Side.from
                  ? provider.from == null
                      ? ''
                      : provider.from!.country
                  : provider.to == null
                      ? ''
                      : provider.to!.country,
              style: text?.copyWith(fontSize: 14),
            ),
        ],
      ),
    );
  }
}

class _BlinkingText extends StatefulWidget {
  const _BlinkingText({
    required this.text,
    required this.style,
  });
  static const Duration duration = Duration(seconds: 1);
  final TextStyle? style;
  final String text;

  @override
  State<_BlinkingText> createState() => _BlinkingTextState();
}

class _BlinkingTextState extends State<_BlinkingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: _BlinkingText.duration,
    );

    _opacityAnimation = Tween<double>(
      begin: 1,
      end: 0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: Text(
        widget.text,
        style: widget.style,
      ),
    );
  }
}

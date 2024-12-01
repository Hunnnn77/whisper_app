import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Side { from, to }

enum ButtonPressd { left, right, nothing }

enum LocalStorageKey { fromCode, fromCountry, toCode, toCountry, api }

final class StateProvider extends ChangeNotifier {
  StateProvider(this.localStorage);

  final SharedPreferencesAsync localStorage;

  late String? path;
  String? key;
  bool getValidKey = true;
  ({String code, String country})? from;
  ({String code, String country})? to;

  bool isRecoding = false;
  bool isTranslating = false;
  bool isHideButton = false;
  ButtonPressd buttonPressed = ButtonPressd.nothing;

  void toggleRecoding() {
    isRecoding = !isRecoding;
    notifyListeners();
  }

  void toggleTranslating() {
    isTranslating = !isTranslating;
    notifyListeners();
  }

  void toggleHideFloatingButton() {
    isHideButton = !isHideButton;
    notifyListeners();
  }

  void setPath(String? path) {
    if (path == null) {
      return;
    }
    this.path = path;
  }

  Future<StateProvider> init() async {
    final key = dotenv.maybeGet('KEY');
    await _initKey(key);

    final [fromCode, fromCountry, toCode, toCountry] = await Future.wait([
      localStorage.getString(LocalStorageKey.fromCode.name),
      localStorage.getString(LocalStorageKey.fromCountry.name),
      localStorage.getString(LocalStorageKey.toCode.name),
      localStorage.getString(LocalStorageKey.toCountry.name),
    ]);
    from = (fromCode == null || fromCountry == null)
        ? null
        : (
            code: fromCode,
            country: fromCountry,
          );
    to = (toCode == null || toCountry == null)
        ? null
        : (
            code: toCode,
            country: toCountry,
          );
    return this;
  }

  Future<void> setLang(
    Side side,
    ({String code, String country}) newValue,
  ) async {
    switch (side) {
      case Side.from:
        from = newValue;
        await Future.wait([
          localStorage.setString(LocalStorageKey.fromCode.name, newValue.code),
          localStorage.setString(
            LocalStorageKey.fromCountry.name,
            newValue.country,
          ),
        ]);
      case Side.to:
        to = newValue;
        await Future.wait([
          localStorage.setString(LocalStorageKey.toCode.name, newValue.code),
          localStorage.setString(
            LocalStorageKey.toCountry.name,
            newValue.country,
          ),
        ]);
    }
    notifyListeners();
  }

  void setNull() => path = null;

  void changeButtonState(ButtonPressd buttonPressed) {
    this.buttonPressed = buttonPressed;
    notifyListeners();
  }

  Future<void> _initKey(String? key) async {
    if (key == null) {
      throw Exception('NOT FOUND KEY');
    }

    if (kDebugMode) {
      this.key = key;
    } else {
      this.key = await localStorage.getString(LocalStorageKey.api.name);
    }
  }

  bool get invalidKey => key == null || !_validationKey(key ?? '');

  bool _validationKey(String key) {
    if (key.trim().isEmpty || key.length < 4) return false;
    return key.startsWith('sk-');
  }

  Future<void> setKey(String key) async {
    this.key = key.trim();
    await localStorage.setString(LocalStorageKey.api.name, key);
    notifyListeners();
  }

  Future<void> deleteAll() async {
    key = null;
    from = null;
    to = null;

    await Future.wait([
      localStorage.remove(LocalStorageKey.fromCode.name),
      localStorage.remove(LocalStorageKey.fromCountry.name),
      localStorage.remove(LocalStorageKey.toCode.name),
      localStorage.remove(LocalStorageKey.toCountry.name),
      localStorage.remove(LocalStorageKey.api.name),
    ]);

    notifyListeners();
  }
}

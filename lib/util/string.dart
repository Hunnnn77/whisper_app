extension TransformString on String {
  String get cap {
    if (split(' ').length > 1) {
      final texts = split(' ').map((t) => t[0].toUpperCase() + t.substring(1));
      return texts.join(' ');
    }
    return this[0].toUpperCase() + substring(1);
  }
}

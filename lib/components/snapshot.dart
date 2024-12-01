import 'package:flutter/material.dart';
import 'package:typed_monad/typed_monad.dart';

extension FromResult<T, E extends Exception> on AsyncSnapshot<Result<T, E>> {
  Widget on({
    required Widget Function() pending,
    required Widget Function(E e) fail,
    required Widget Function(T ok) success,
  }) {
    if (connectionState == ConnectionState.waiting) {
      return pending();
    }
    if (hasError) {
      return fail((error! as Err<E>).bind());
    }
    return success((data! as Ok<T>).bind());
  }
}

extension FromPrimitive<T, E extends Exception> on AsyncSnapshot<T> {
  Widget on({
    required Widget Function() pending,
    required Widget Function(E e) fail,
    required Widget Function(T ok) success,
  }) {
    if (connectionState == ConnectionState.waiting) {
      return pending();
    }
    if (hasError) {
      return fail(error! as E);
    }
    return success(data as T);
  }
}

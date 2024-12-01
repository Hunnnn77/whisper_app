import 'package:logger/logger.dart';

final class Log {
  Log();
  final Logger logger = Logger(printer: PrettyPrinter());
}

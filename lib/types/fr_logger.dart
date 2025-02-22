import 'package:app_rhyme/src/rust/api/log.dart' as rust_logger;
import 'package:app_rhyme/src/rust/api/utils/path_util.dart';
import 'package:app_rhyme/utils/global_vars.dart';
import 'package:logger/logger.dart' as flutter_logger;

enum LogLevel {
  debug,
  info,
  warn,
  error,
  ;
}

rust_logger.LogLevel toRustLogLevel(LogLevel level) {
  switch (level) {
    case LogLevel.debug:
      return rust_logger.LogLevel.debug;
    case LogLevel.info:
      return rust_logger.LogLevel.info;
    case LogLevel.warn:
      return rust_logger.LogLevel.warn;
    case LogLevel.error:
      return rust_logger.LogLevel.error;
  }
}

rust_logger.Logger? globalRustLogger;
final globalFlutterLogger = FRLogger._();

Future<void> initGlobalRustLogger() async {
  globalRustLogger = await rust_logger.Logger.newInstance(
      logDir: await getLogDir(documentDir: globalDocumentPath),
      maxLevel: rust_logger.LogLevel.info,
      maxLogFiles: BigInt.from(5),
      maxLogSize: BigInt.from(1024 * 1024 * 10));
}

Future<FRLogger> createFRLogger() async {
  await initGlobalRustLogger();
  return FRLogger._();
}

class FRLogger {
  flutter_logger.Logger flutterLogger = flutter_logger.Logger();

  FRLogger._();

  Future<void> debug(String message) async {
    // 使用flutter的log打印彩色日志到控制台
    flutterLogger.d(message);
    // 使用 rustLogger 调用 debug 方法保存日志到文件
    await globalRustLogger!.debug(
      message: message,
    );
  }

  Future<void> error(String message) async {
    flutterLogger.e(message);
    await globalRustLogger!.error(
      message: message,
    );
  }

  Future<void> info(String message) async {
    flutterLogger.i(message);
    await globalRustLogger!.info(
      message: message,
    );
  }

  Future<void> warn(String message) async {
    flutterLogger.w(message);
    await globalRustLogger!.warn(
      message: message,
    );
  }
}

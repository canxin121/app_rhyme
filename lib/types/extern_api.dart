import 'dart:io';

import 'package:app_rhyme/types/http_wrap.dart';
import 'package:app_rhyme/types/music.dart';
import 'package:dart_eval/dart_eval.dart';
import 'package:dart_eval/stdlib/core.dart';

class ExternApi {
  late Runtime runTime;
  ExternApi(String path) {
    final compile = Compiler();
    compile.defineBridgeClasses([$HttpHelper.$declaration]);
    var file = File(path);
    final bytecode = file.readAsBytesSync().buffer.asByteData();
    runTime = Runtime(bytecode);

    runTime.registerBridgeFunc('package:http_helper/helper.dart', "HttpHelper.",
        $HttpHelper.$construct,
        isBridge: true);
  }

  Future<PlayInfo?> getMusicPlayInfo(
    String source,
    String extra,
  ) async {
    var resultFuture = runTime.executeLib(
        "package:api/main.dart",
        "getMusicPlayInfo",
        [$String("kuwo".toString()), $String(extra)]) as Future;

    dynamic result = await resultFuture;
    if (result.runtimeType != $null) {
      return PlayInfo.fromObject(result.$reified);
    } else {
      return null;
    }
  }
}

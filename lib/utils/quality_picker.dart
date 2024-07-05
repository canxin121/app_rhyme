import 'dart:io';

import 'package:app_rhyme/src/rust/api/mirrors.dart';
import 'package:app_rhyme/types/chore.dart';
import 'package:app_rhyme/utils/global_vars.dart';

enum QualityOption { low, medium, high, highest }

String qualityOptionToString(QualityOption qualityOption) {
  switch (qualityOption) {
    case QualityOption.low:
      return "最低";
    case QualityOption.medium:
      return "中等";
    case QualityOption.high:
      return "较高";
    case QualityOption.highest:
      return "最高";
  }
}

QualityOption stringToQualityOption(String qualityOptionString) {
  switch (qualityOptionString) {
    case "最低":
      return QualityOption.low;
    case "中等":
      return QualityOption.medium;
    case "较高":
      return QualityOption.high;
    case "最高":
      return QualityOption.highest;
    default:
      return QualityOption.medium;
  }
}

Quality autoPickQualityByOption(List<Quality> qualities, QualityOption option) {
  if (qualities.length == 1) {
    return qualities.first;
  } else if (qualities.length == 2) {
    switch (option) {
      case QualityOption.low:
        return qualities.last;
      case QualityOption.medium:
        return qualities.last;
      case QualityOption.high:
        return qualities.first;
      case QualityOption.highest:
        return qualities.first;
    }
  } else if (qualities.length == 3) {
    switch (option) {
      case QualityOption.low:
        return qualities.last;
      case QualityOption.medium:
        return qualities[1];
      case QualityOption.high:
        return qualities[1];
      case QualityOption.highest:
        return qualities.first;
    }
  } else if (qualities.length == 4) {
    switch (option) {
      case QualityOption.low:
        return qualities[3];
      case QualityOption.medium:
        return qualities[2];
      case QualityOption.high:
        return qualities[1];
      case QualityOption.highest:
        return qualities[0];
    }
  } else {
    switch (option) {
      case QualityOption.low:
        return qualities.last;
      case QualityOption.medium:
        return qualities[(qualities.length / 2).ceil()];
      case QualityOption.high:
        return qualities[(qualities.length * 3 / 4).ceil()];
      case QualityOption.highest:
        return qualities.first;
    }
  }
}

Quality autoPickQuality(List<Quality> qualities) {
  if (Platform.isIOS || Platform.isAndroid) {
    switch (globalConnectivityStateSimple) {
      case ConnectivityStateSimple.wifi:
        return autoPickQualityByOption(
            qualities, stringToQualityOption(globalConfig.wifiAutoQuality));
      case ConnectivityStateSimple.mobile:
        return autoPickQualityByOption(
            qualities, stringToQualityOption(globalConfig.mobileAutoQuality));
      case ConnectivityStateSimple.none:
        return qualities.last;
    }
  } else {
    return autoPickQualityByOption(
        qualities, stringToQualityOption(globalConfig.wifiAutoQuality));
  }
}

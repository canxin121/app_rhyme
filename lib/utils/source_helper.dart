import 'package:app_rhyme/utils/const_vars.dart';

String? nextSource(List<String> availableSources) {
  // 传入已经使用过的源，返回下一个可用的源，如果没有下一个源了，返回 null
  // 顺序：酷我 => 网易

  if (availableSources.length >= 2) {
    return null;
  }

  if (availableSources.contains(sourceKuWo)) {
    return sourceWangYi;
  } else {
    return sourceKuWo;
  }
}

String sourceToShort(String source) {
  switch (source) {
    case sourceKuWo:
      return 'kw';
    case sourceWangYi:
      return 'wy';
    default:
      return source;
  }
}

import 'dart:math';

List<T> shuffleList<T>(List<T> items) {
  var random = Random();
  // 创建列表的副本以避免修改原始列表
  List<T> shuffledItems = List<T>.from(items);

  for (int i = shuffledItems.length - 1; i > 0; i--) {
    int n = random.nextInt(i + 1);
    T temp = shuffledItems[i];
    shuffledItems[i] = shuffledItems[n];
    shuffledItems[n] = temp;
  }

  return shuffledItems;
}

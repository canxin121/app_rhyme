import 'package:drag_select_grid_view/drag_select_grid_view.dart';

void selectAll(DragSelectGridViewController controller, int itemLength) {
  Set<int> selectAllSet = Set.from(List.generate(itemLength, (i) => i));
  controller.value = Selection(selectAllSet);
}

void reverseSelect(DragSelectGridViewController controller, int itemLength) {
  Set<int> selectAllSet =
      Set.from(List.generate(itemLength, (i) => i, growable: false));
  selectAllSet.removeAll(controller.value.selectedIndexes);
  controller.value = Selection(Set.from(selectAllSet));
}

void rebuildDragged(
  DragSelectGridViewController controller,
  int itemLength,
) {
  controller.value = Selection(const {});
}

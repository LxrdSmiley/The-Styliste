import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/design_blueprint.dart';

/// Local, recoverable Atelier intent. Durable saves/releases stay behind the
/// validated Edge Function; undo/redo never mutates authoritative game state.
class DesignBlueprintEditor extends StateNotifier<DesignBlueprint> {
  DesignBlueprintEditor()
      : super(DesignBlueprint.starter(
            materials: const <String>[], palette: const <String>[]));

  final List<DesignBlueprint> _undo = <DesignBlueprint>[];
  final List<DesignBlueprint> _redo = <DesignBlueprint>[];

  bool get canUndo => _undo.isNotEmpty;
  bool get canRedo => _redo.isNotEmpty;

  void replace(DesignBlueprint next) {
    if (!next.isReleaseValid) return;
    _undo.add(state);
    _redo.clear();
    state = next;
  }

  void undo() {
    if (_undo.isEmpty) return;
    _redo.add(state);
    state = _undo.removeLast();
  }

  void redo() {
    if (_redo.isEmpty) return;
    _undo.add(state);
    state = _redo.removeLast();
  }
}

final StateNotifierProvider<DesignBlueprintEditor, DesignBlueprint>
    designBlueprintProvider =
    StateNotifierProvider<DesignBlueprintEditor, DesignBlueprint>(
  (Ref<DesignBlueprint> ref) => DesignBlueprintEditor(),
);

import 'package:flutter_bloc/flutter_bloc.dart';

extension EmitIfOpen<S> on BlocBase<S> {
  /// Emits [state] unless the cubit was closed in the meantime. Use it for every
  /// emit that happens after an await.
  void emitIfOpen(S state) {
    if (!isClosed) {
      // ignore: invalid_use_of_protected_member
      emit(state);
    }
  }
}

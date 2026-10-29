/// The value and validation error of one form field, kept in a cubit state.
class FormInput<T> {
  const FormInput({required this.value, this.error});

  final T value;
  final String? error;

  bool get isValid => error == null;

  FormInput<T> update(T value, {String? error}) =>
      FormInput<T>(value: value, error: error);

  @override
  bool operator ==(Object other) =>
      other is FormInput<T> && other.value == value && other.error == error;

  @override
  int get hashCode => Object.hash(value, error);
}

// Tests for the shared core files in skills/flutter-new-project/assets/core.
// CI copies those files into a scratch package named core_check and runs this.
import 'package:bloc/bloc.dart';
import 'package:core_check/cubit_ext.dart';
import 'package:core_check/form_input.dart';
import 'package:core_check/paging.dart';
import 'package:core_check/request_status.dart';
import 'package:core_check/result.dart';
import 'package:core_check/validators.dart';
import 'package:test/test.dart';

class _Counter extends Cubit<int> {
  _Counter() : super(0);
  void set(int value) => emitIfOpen(value);
}

void main() {
  group('slicePage', () {
    final all = [1, 2, 3, 4, 5];

    test('first page has more', () {
      final page = slicePage(all, offset: 0, limit: 2);
      expect(page.items, [1, 2]);
      expect(page.hasMore, isTrue);
    });

    test('negative limit returns an empty page instead of throwing', () {
      final page = slicePage(all, offset: 3, limit: -5);
      expect(page.items, isEmpty);
      expect(page.hasMore, isTrue);
    });

    test('last page has no more', () {
      final page = slicePage(all, offset: 4, limit: 2);
      expect(page.items, [5]);
      expect(page.hasMore, isFalse);
    });

    test('offset past the end gives an empty page', () {
      final page = slicePage(all, offset: 9, limit: 2);
      expect(page.items, isEmpty);
      expect(page.hasMore, isFalse);
    });

    test('exact end has no more', () {
      expect(slicePage(all, offset: 3, limit: 2).hasMore, isFalse);
    });
  });

  group('validators', () {
    test('email', () {
      expect(validateEmail('a@b.co'), isNull);
      expect(validateEmail('  a@b.co '), isNull);
      expect(validateEmail('a@b'), isNotNull);
      expect(validateEmail(''), isNotNull);
    });

    test('password', () {
      expect(validatePassword('1234567'), isNotNull);
      expect(validatePassword('12345678'), isNull);
    });

    test('required', () {
      expect(validateRequired('  ', 'needed'), 'needed');
      expect(validateRequired('x', 'needed'), isNull);
    });
  });

  group('FormInput', () {
    test('validity and equality', () {
      const ok = FormInput<String>(value: 'a');
      expect(ok.isValid, isTrue);
      expect(ok.update('b', error: 'bad').isValid, isFalse);
      expect(ok, const FormInput<String>(value: 'a'));
      expect(ok == ok.update('b'), isFalse);
    });
  });

  group('RequestStatus', () {
    test('flags and message', () {
      expect(const Loading().isLoading, isTrue);
      expect(const Succeeded().isSuccess, isTrue);
      expect(const Failed('x').isFailure, isTrue);
      expect(const Failed('x').errorMessage, 'x');
      expect(const Idle().errorMessage, isNull);
    });

    test('equality compares type and message', () {
      expect(const Failed('x'), const Failed('x'));
      expect(const Failed('x') == const Failed('y'), isFalse);
      expect(const Idle() == const Loading(), isFalse);
    });
  });

  group('Result', () {
    test('switch is exhaustive', () {
      String describe(Result<int> r) => switch (r) {
            Ok(:final value) => 'ok $value',
            Err(:final failure) => 'err ${failure.message}',
          };
      expect(describe(const Ok(1)), 'ok 1');
      expect(describe(const Err(AppFailure('no'))), 'err no');
    });
  });

  group('emitIfOpen', () {
    test('emits while open and ignores emits after close', () async {
      final cubit = _Counter();
      cubit.set(1);
      expect(cubit.state, 1);
      await cubit.close();
      cubit.set(2);
      expect(cubit.state, 1);
    });
  });
}

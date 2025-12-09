import 'package:flutter_test/flutter_test.dart';
import 'package:pipe_x/pipe_x.dart';

void main() {
  group('AsyncValue', () {
    group('AsyncLoading', () {
      test('should have correct state flags', () {
        const loading = AsyncLoading<int>();

        expect(loading.isLoading, true);
        expect(loading.hasData, false);
        expect(loading.hasError, false);
      });

      test('valueOrNull should return null', () {
        const loading = AsyncLoading<int>();
        expect(loading.valueOrNull, null);
      });

      test('errorOrNull should return null', () {
        const loading = AsyncLoading<int>();
        expect(loading.errorOrNull, null);
      });

      test('stackTraceOrNull should return null', () {
        const loading = AsyncLoading<int>();
        expect(loading.stackTraceOrNull, null);
      });

      test('requireValue should throw StateError', () {
        const loading = AsyncLoading<int>();
        expect(() => loading.requireValue, throwsStateError);
      });

      test('equality should work correctly', () {
        const loading1 = AsyncLoading<int>();
        const loading2 = AsyncLoading<int>();

        expect(loading1, equals(loading2));
        expect(loading1.hashCode, equals(loading2.hashCode));
      });

      test('toString should return correct format', () {
        const loading = AsyncLoading<int>();
        expect(loading.toString(), 'AsyncLoading()');
      });
    });

    group('AsyncData', () {
      test('should have correct state flags', () {
        const data = AsyncData(42);

        expect(data.isLoading, false);
        expect(data.hasData, true);
        expect(data.hasError, false);
      });

      test('should hold the correct value', () {
        const data = AsyncData(42);
        expect(data.value, 42);
      });

      test('valueOrNull should return the value', () {
        const data = AsyncData(42);
        expect(data.valueOrNull, 42);
      });

      test('errorOrNull should return null', () {
        const data = AsyncData(42);
        expect(data.errorOrNull, null);
      });

      test('requireValue should return the value', () {
        const data = AsyncData(42);
        expect(data.requireValue, 42);
      });

      test('equality should work correctly', () {
        const data1 = AsyncData(42);
        const data2 = AsyncData(42);
        const data3 = AsyncData(99);

        expect(data1, equals(data2));
        expect(data1, isNot(equals(data3)));
        expect(data1.hashCode, equals(data2.hashCode));
      });

      test('toString should return correct format', () {
        const data = AsyncData(42);
        expect(data.toString(), 'AsyncData(42)');
      });
    });

    group('AsyncError', () {
      test('should have correct state flags', () {
        final error = AsyncError<int>(Exception('test'));

        expect(error.isLoading, false);
        expect(error.hasData, false);
        expect(error.hasError, true);
      });

      test('should hold the error', () {
        final exception = Exception('test');
        final error = AsyncError<int>(exception);
        expect(error.error, exception);
      });

      test('should hold the stack trace', () {
        final stackTrace = StackTrace.current;
        final error = AsyncError<int>(Exception('test'), stackTrace);
        expect(error.stackTrace, stackTrace);
      });

      test('valueOrNull should return null', () {
        final error = AsyncError<int>(Exception('test'));
        expect(error.valueOrNull, null);
      });

      test('errorOrNull should return the error', () {
        final exception = Exception('test');
        final error = AsyncError<int>(exception);
        expect(error.errorOrNull, exception);
      });

      test('stackTraceOrNull should return stack trace', () {
        final stackTrace = StackTrace.current;
        final error = AsyncError<int>(Exception('test'), stackTrace);
        expect(error.stackTraceOrNull, stackTrace);
      });

      test('requireValue should throw the error', () {
        final exception = Exception('test');
        final error = AsyncError<int>(exception);
        expect(() => error.requireValue, throwsA(exception));
      });

      test('equality should work correctly', () {
        final exception = Exception('test');
        final error1 = AsyncError<int>(exception);
        final error2 = AsyncError<int>(exception);
        final error3 = AsyncError<int>(Exception('other'));

        expect(error1, equals(error2));
        expect(error1, isNot(equals(error3)));
      });

      test('toString should return correct format', () {
        final error = AsyncError<int>(Exception('test'));
        expect(error.toString(), contains('AsyncError'));
      });
    });

    group('AsyncRefreshing', () {
      test('should have correct state flags', () {
        const refreshing = AsyncRefreshing(42);

        expect(refreshing.isLoading, true);
        expect(refreshing.hasData, true);
        expect(refreshing.hasError, false);
      });

      test('should hold the previous value', () {
        const refreshing = AsyncRefreshing(42);
        expect(refreshing.previousValue, 42);
      });

      test('valueOrNull should return previous value', () {
        const refreshing = AsyncRefreshing(42);
        expect(refreshing.valueOrNull, 42);
      });

      test('requireValue should return previous value', () {
        const refreshing = AsyncRefreshing(42);
        expect(refreshing.requireValue, 42);
      });

      test('equality should work correctly', () {
        const refreshing1 = AsyncRefreshing(42);
        const refreshing2 = AsyncRefreshing(42);
        const refreshing3 = AsyncRefreshing(99);

        expect(refreshing1, equals(refreshing2));
        expect(refreshing1, isNot(equals(refreshing3)));
      });

      test('toString should return correct format', () {
        const refreshing = AsyncRefreshing(42);
        expect(refreshing.toString(), 'AsyncRefreshing(42)');
      });
    });

    group('when', () {
      test('should call loading callback for AsyncLoading', () {
        const loading = AsyncLoading<int>();

        final result = loading.when(
          loading: () => 'loading',
          data: (value) => 'data: $value',
          onError: (e, s) => 'error: $e',
        );

        expect(result, 'loading');
      });

      test('should call loading callback for AsyncRefreshing', () {
        const refreshing = AsyncRefreshing(42);

        final result = refreshing.when(
          loading: () => 'loading',
          data: (value) => 'data: $value',
          onError: (e, s) => 'error: $e',
        );

        expect(result, 'loading');
      });

      test('should call data callback for AsyncData', () {
        const data = AsyncData(42);

        final result = data.when(
          loading: () => 'loading',
          data: (value) => 'data: $value',
          onError: (e, s) => 'error: $e',
        );

        expect(result, 'data: 42');
      });

      test('should call error callback for AsyncError', () {
        final error = AsyncError<int>(Exception('test'));

        final result = error.when(
          loading: () => 'loading',
          data: (value) => 'data: $value',
          onError: (e, s) => 'error: $e',
        );

        expect(result, contains('error:'));
      });
    });

    group('maybeWhen', () {
      test('should call orElse when callback is null', () {
        const loading = AsyncLoading<int>();

        final result = loading.maybeWhen(
          data: (value) => 'data: $value',
          orElse: () => 'fallback',
        );

        expect(result, 'fallback');
      });

      test('should call specific callback when provided', () {
        const data = AsyncData(42);

        final result = data.maybeWhen(
          data: (value) => 'data: $value',
          orElse: () => 'fallback',
        );

        expect(result, 'data: 42');
      });
    });

    group('map', () {
      test('should map AsyncData value', () {
        const data = AsyncData(42);
        final mapped = data.map((value) => value.toString());

        expect(mapped, isA<AsyncData<String>>());
        expect((mapped as AsyncData<String>).value, '42');
      });

      test('should preserve AsyncLoading', () {
        const loading = AsyncLoading<int>();
        final mapped = loading.map((value) => value.toString());

        expect(mapped, isA<AsyncLoading<String>>());
      });

      test('should preserve AsyncError', () {
        final error = AsyncError<int>(Exception('test'));
        final mapped = error.map((value) => value.toString());

        expect(mapped, isA<AsyncError<String>>());
      });

      test('should map AsyncRefreshing previous value', () {
        const refreshing = AsyncRefreshing(42);
        final mapped = refreshing.map((value) => value.toString());

        expect(mapped, isA<AsyncRefreshing<String>>());
        expect((mapped as AsyncRefreshing<String>).previousValue, '42');
      });
    });
  });
}

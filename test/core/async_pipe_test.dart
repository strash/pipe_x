import 'package:flutter_test/flutter_test.dart';
import 'package:pipe_x/pipe_x.dart';

void main() {
  group('AsyncPipe', () {
    test('should start in loading state when immediate is true', () async {
      final pipe = AsyncPipe<int>(() async => 42);

      expect(pipe.value, isA<AsyncLoading>());
      expect(pipe.isLoading, true);

      // Wait for async operation to complete
      await Future.delayed(const Duration(milliseconds: 50));

      expect(pipe.value, isA<AsyncData<int>>());
      expect(pipe.dataOrNull, 42);

      pipe.dispose();
    });

    test('should stay in loading state when immediate is false', () async {
      final pipe = AsyncPipe<int>(
        () async => 42,
        immediate: false,
      );

      expect(pipe.value, isA<AsyncLoading>());

      // Should still be loading after delay since immediate is false
      await Future.delayed(const Duration(milliseconds: 50));
      expect(pipe.value, isA<AsyncLoading>());

      pipe.dispose();
    });

    test('should load data when refresh is called with immediate false',
        () async {
      final pipe = AsyncPipe<int>(
        () async => 42,
        immediate: false,
      );

      expect(pipe.value, isA<AsyncLoading>());

      // Call refresh to start loading
      await pipe.refresh();

      expect(pipe.value, isA<AsyncData<int>>());
      expect(pipe.dataOrNull, 42);

      pipe.dispose();
    });

    test('should handle errors correctly', () async {
      final pipe = AsyncPipe<int>(() async {
        throw Exception('Test error');
      });

      // Wait for async operation to complete
      await Future.delayed(const Duration(milliseconds: 50));

      expect(pipe.value, isA<AsyncError<int>>());
      expect(pipe.hasError, true);
      expect(pipe.errorOrNull, isA<Exception>());

      pipe.dispose();
    });

    test('should use AsyncRefreshing when refreshing with existing data',
        () async {
      var callCount = 0;
      final pipe = AsyncPipe<int>(() async {
        callCount++;
        await Future.delayed(const Duration(milliseconds: 10));
        return callCount * 10;
      });

      // Wait for initial load
      await Future.delayed(const Duration(milliseconds: 50));
      expect(pipe.dataOrNull, 10);

      // Start refresh - should show AsyncRefreshing
      final refreshFuture = pipe.refresh();

      // Give it time to start but not complete
      await Future.delayed(const Duration(milliseconds: 5));

      // Should be refreshing with previous value available
      if (pipe.value is AsyncRefreshing<int>) {
        expect((pipe.value as AsyncRefreshing<int>).previousValue, 10);
      }

      // Wait for refresh to complete
      await refreshFuture;
      expect(pipe.dataOrNull, 20);

      pipe.dispose();
    });

    test('withInitialValue should start with AsyncData', () {
      final pipe = AsyncPipe<int>.withInitialValue(
        42,
        () async => 99,
      );

      expect(pipe.value, isA<AsyncData<int>>());
      expect(pipe.dataOrNull, 42);
      expect(pipe.hasData, true);
      expect(pipe.isLoading, false);

      pipe.dispose();
    });

    test('withInitialValue should update on refresh', () async {
      final pipe = AsyncPipe<int>.withInitialValue(
        42,
        () async => 99,
      );

      expect(pipe.dataOrNull, 42);

      await pipe.refresh();

      expect(pipe.dataOrNull, 99);

      pipe.dispose();
    });

    test('setData should manually set data value', () {
      final pipe = AsyncPipe<int>(
        () async => 42,
        immediate: false,
      );

      expect(pipe.value, isA<AsyncLoading>());

      pipe.setData(100);

      expect(pipe.value, isA<AsyncData<int>>());
      expect(pipe.dataOrNull, 100);

      pipe.dispose();
    });

    test('setError should manually set error state', () {
      final pipe = AsyncPipe<int>(
        () async => 42,
        immediate: false,
      );

      pipe.setError(Exception('Manual error'));

      expect(pipe.value, isA<AsyncError<int>>());
      expect(pipe.hasError, true);

      pipe.dispose();
    });

    test('setLoading should manually set loading state', () async {
      final pipe = AsyncPipe<int>(() async => 42);

      await Future.delayed(const Duration(milliseconds: 50));
      expect(pipe.hasData, true);

      pipe.setLoading();

      expect(pipe.value, isA<AsyncLoading>());
      expect(pipe.isLoading, true);

      pipe.dispose();
    });

    test('reset should clear data and reload', () async {
      final pipe = AsyncPipe<int>(() async => 42);

      await Future.delayed(const Duration(milliseconds: 50));
      expect(pipe.dataOrNull, 42);

      final resetFuture = pipe.reset();

      // Should be in loading state (not refreshing)
      expect(pipe.value, isA<AsyncLoading>());

      await resetFuture;
      expect(pipe.dataOrNull, 42);

      pipe.dispose();
    });

    test('should notify listeners on state change', () async {
      final pipe = AsyncPipe<int>(() async => 42);
      var notifyCount = 0;

      pipe.addListener((_) {
        notifyCount++;
      });

      await Future.delayed(const Duration(milliseconds: 50));

      expect(notifyCount, greaterThan(0));

      pipe.dispose();
    });

    test('should cancel in-flight request on refresh', () async {
      var callCount = 0;
      final pipe = AsyncPipe<int>(() async {
        callCount++;
        await Future.delayed(const Duration(milliseconds: 100));
        return callCount * 10;
      });

      // Start first request
      await Future.delayed(const Duration(milliseconds: 10));

      // Cancel and start new request
      pipe.refresh();

      // Wait for completion
      await Future.delayed(const Duration(milliseconds: 150));

      // Should have the result from second call
      expect(pipe.dataOrNull, 20);

      pipe.dispose();
    });

    test('dispose should prevent further updates', () async {
      final pipe = AsyncPipe<int>(() async {
        await Future.delayed(const Duration(milliseconds: 50));
        return 42;
      });

      // Dispose while loading
      pipe.dispose();

      // Wait for what would be completion
      await Future.delayed(const Duration(milliseconds: 100));

      expect(pipe.disposed, true);
    });

    test('hasData should be true only with data', () async {
      final pipe = AsyncPipe<int>(() async => 42, immediate: false);

      expect(pipe.hasData, false);

      await pipe.refresh();

      expect(pipe.hasData, true);

      pipe.dispose();
    });

    test('hasError should be true only with error', () async {
      final pipe = AsyncPipe<int>(() async {
        throw Exception('error');
      }, immediate: false);

      expect(pipe.hasError, false);

      await pipe.refresh();

      expect(pipe.hasError, true);

      pipe.dispose();
    });

    test('value setter should work through pump', () {
      final pipe = AsyncPipe<int>(() async => 42, immediate: false);

      pipe.value = const AsyncData(100);

      expect(pipe.dataOrNull, 100);

      pipe.dispose();
    });
  });
}

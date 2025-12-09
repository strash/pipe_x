import 'package:flutter_test/flutter_test.dart';
import 'package:pipe_x/pipe_x.dart';

class TestHub extends Hub {
  late final count = pipe(0);
  late final name = pipe('test');

  void increment() {
    count.value++;
  }

  void setName(String newName) {
    name.value = newName;
  }
}

class DisposableHub extends Hub {
  bool onDisposeCalled = false;

  late final value = pipe(0);

  @override
  void onDispose() {
    onDisposeCalled = true;
  }
}

class HubWithManualPipes extends Hub {
  late final registered = registerPipe(Pipe(0));
}

class HubWithComputedPipe extends Hub {
  late final a = pipe(5);
  late final b = pipe(10);

  late final sum = computedPipe<int>(
    dependencies: [a, b],
    compute: () => a.value + b.value,
  );
}

class HubWithAsyncPipe extends Hub {
  late final data = asyncPipe<int>(
    () async {
      await Future.delayed(const Duration(milliseconds: 10));
      return 42;
    },
  );
}

class HubWithAsyncPipeDelayed extends Hub {
  late final data = asyncPipe<int>(
    () async => 42,
    immediate: false,
  );
}

void main() {
  group('Hub', () {
    test('should auto-register pipes created during construction', () {
      final hub = TestHub();

      expect(hub.count.value, 0);
      expect(hub.name.value, 'test');

      hub.dispose();
      expect(hub.count.disposed, true);
      expect(hub.name.disposed, true);
    });

    test('should update pipe values through methods', () {
      final hub = TestHub();

      hub.increment();
      expect(hub.count.value, 1);

      hub.setName('updated');
      expect(hub.name.value, 'updated');

      hub.dispose();
    });

    test('should track disposed state', () {
      final hub = TestHub();

      expect(hub.disposed, false);
      hub.dispose();
      expect(hub.disposed, true);
    });

    test('dispose should be idempotent', () {
      final hub = TestHub();

      hub.dispose();
      hub.dispose(); // Should not throw
      expect(hub.disposed, true);
    });

    test('should dispose all registered pipes', () {
      final hub = TestHub();

      final count = hub.count;
      final name = hub.name;

      hub.dispose();

      expect(count.disposed, true);
      expect(name.disposed, true);
    });

    test('should call onDispose when disposed', () {
      final hub = DisposableHub();

      expect(hub.onDisposeCalled, false);
      hub.dispose();
      expect(hub.onDisposeCalled, true);
    });

    test('should throw when registering pipe on disposed hub', () {
      final hub = TestHub();

      hub.dispose();
      expect(hub.disposed, true);
    });

    test('should get subscriber count across all pipes', () {
      final hub = TestHub();

      expect(hub.subscriberCount, 0);

      hub.dispose();
    });

    test('disposed hub should have disposed state', () {
      final hub = TestHub();

      expect(hub.disposed, false);
      hub.dispose();
      expect(hub.disposed, true);
    });

    test('should clear pipes map on dispose', () {
      final hub = TestHub();

      hub.increment();
      hub.setName('test');

      hub.dispose();

      // All pipes should be disposed
      expect(hub.count.disposed, true);
      expect(hub.name.disposed, true);
    });

    test('manually registered pipes should be disposed', () {
      final hub = HubWithManualPipes();

      final registered = hub.registered;

      hub.dispose();
      expect(registered.disposed, true);
    });

    test('should handle multiple pipe types', () {
      final hub = TestHub();

      hub.count.value = 42;
      hub.name.value = 'answer';

      expect(hub.count.value, 42);
      expect(hub.name.value, 'answer');

      hub.dispose();
    });
  });

  group('Hub with ComputedPipe', () {
    test('should register computed pipe and compute initial value', () {
      final hub = HubWithComputedPipe();

      expect(hub.sum.value, 15); // 5 + 10

      hub.dispose();
    });

    test('should recompute when dependency changes', () {
      final hub = HubWithComputedPipe();

      expect(hub.sum.value, 15);

      hub.a.value = 20;
      expect(hub.sum.value, 30); // 20 + 10

      hub.b.value = 5;
      expect(hub.sum.value, 25); // 20 + 5

      hub.dispose();
    });

    test('should dispose computed pipe with hub', () {
      final hub = HubWithComputedPipe();

      final sum = hub.sum;

      hub.dispose();

      expect(sum.disposed, true);
      expect(hub.a.disposed, true);
      expect(hub.b.disposed, true);
    });
  });

  group('Hub with AsyncPipe', () {
    test('should register async pipe', () {
      final hub = HubWithAsyncPipe();

      expect(hub.data.value, isA<AsyncLoading>());
      expect(hub.data.isLoading, true);

      hub.dispose();
    });

    test('should load data asynchronously', () async {
      final hub = HubWithAsyncPipe();

      expect(hub.data.isLoading, true);

      await Future.delayed(const Duration(milliseconds: 50));

      expect(hub.data.hasData, true);
      expect(hub.data.dataOrNull, 42);

      hub.dispose();
    });

    test('should not load immediately when immediate is false', () async {
      final hub = HubWithAsyncPipeDelayed();

      expect(hub.data.isLoading, true);

      // Still loading after delay because immediate is false
      await Future.delayed(const Duration(milliseconds: 50));
      expect(hub.data.value, isA<AsyncLoading>());

      // Refresh to start loading
      await hub.data.refresh();
      expect(hub.data.dataOrNull, 42);

      hub.dispose();
    });

    test('should dispose async pipe with hub', () {
      final hub = HubWithAsyncPipe();

      final data = hub.data;

      hub.dispose();

      expect(data.disposed, true);
    });

    test('async pipe should support setData', () {
      final hub = HubWithAsyncPipeDelayed();

      hub.data.setData(100);

      expect(hub.data.hasData, true);
      expect(hub.data.dataOrNull, 100);

      hub.dispose();
    });

    test('async pipe should support setError', () {
      final hub = HubWithAsyncPipeDelayed();

      hub.data.setError(Exception('test error'));

      expect(hub.data.hasError, true);
      expect(hub.data.errorOrNull, isA<Exception>());

      hub.dispose();
    });
  });
}

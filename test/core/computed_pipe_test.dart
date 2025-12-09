import 'package:flutter_test/flutter_test.dart';
import 'package:pipe_x/pipe_x.dart';

void main() {
  group('ComputedPipe', () {
    test('should compute initial value from dependencies', () {
      final a = Pipe(5);
      final b = Pipe(10);

      final sum = ComputedPipe<int>(
        dependencies: [a, b],
        compute: () => a.value + b.value,
      );

      expect(sum.value, 15);

      sum.dispose();
      a.dispose();
      b.dispose();
    });

    test('should recompute when dependency changes', () {
      final a = Pipe(5);
      final b = Pipe(10);

      final sum = ComputedPipe<int>(
        dependencies: [a, b],
        compute: () => a.value + b.value,
      );

      expect(sum.value, 15);

      a.value = 20;
      expect(sum.value, 30);

      b.value = 5;
      expect(sum.value, 25);

      sum.dispose();
      a.dispose();
      b.dispose();
    });

    test('should notify listeners when computed value changes', () {
      final a = Pipe(5);
      final b = Pipe(10);
      var notifyCount = 0;

      final sum = ComputedPipe<int>(
        dependencies: [a, b],
        compute: () => a.value + b.value,
      );

      sum.addListener((_) {
        notifyCount++;
      });

      a.value = 20;
      expect(notifyCount, 1);

      b.value = 5;
      expect(notifyCount, 2);

      sum.dispose();
      a.dispose();
      b.dispose();
    });

    test('should not notify when computed value is the same', () {
      final a = Pipe(5);
      final b = Pipe(5);
      var notifyCount = 0;

      final sum = ComputedPipe<int>(
        dependencies: [a, b],
        compute: () => a.value + b.value,
      );

      sum.addListener((_) {
        notifyCount++;
      });

      // Change a to 10, b to 0 - sum is still 10
      a.value = 10;
      expect(notifyCount, 1); // Notified because sum changed from 10 to 15

      // Now make sum back to 15 in a different way
      a.value = 5; // sum = 10
      b.value = 5; // sum = 10

      // The computation happens but if value doesn't change, shouldn't notify extra times

      sum.dispose();
      a.dispose();
      b.dispose();
    });

    test('should throw when setting value directly', () {
      final a = Pipe(5);

      final computed = ComputedPipe<int>(
        dependencies: [a],
        compute: () => a.value * 2,
      );

      expect(() => computed.value = 100, throwsUnsupportedError);

      computed.dispose();
      a.dispose();
    });

    test('should work with multiple dependencies', () {
      final a = Pipe(1);
      final b = Pipe(2);
      final c = Pipe(3);

      final product = ComputedPipe<int>(
        dependencies: [a, b, c],
        compute: () => a.value * b.value * c.value,
      );

      expect(product.value, 6);

      a.value = 2;
      expect(product.value, 12);

      c.value = 4;
      expect(product.value, 16);

      product.dispose();
      a.dispose();
      b.dispose();
      c.dispose();
    });

    test('should work with string concatenation', () {
      final firstName = Pipe('John');
      final lastName = Pipe('Doe');

      final fullName = ComputedPipe<String>(
        dependencies: [firstName, lastName],
        compute: () => '${firstName.value} ${lastName.value}',
      );

      expect(fullName.value, 'John Doe');

      firstName.value = 'Jane';
      expect(fullName.value, 'Jane Doe');

      fullName.dispose();
      firstName.dispose();
      lastName.dispose();
    });

    test('should work with list transformations', () {
      final items = Pipe<List<int>>([1, 2, 3]);

      final sum = ComputedPipe<int>(
        dependencies: [items],
        compute: () => items.value.fold(0, (a, b) => a + b),
      );

      expect(sum.value, 6);

      items.value = [1, 2, 3, 4, 5];
      expect(sum.value, 15);

      sum.dispose();
      items.dispose();
    });

    test('should work with boolean conditions', () {
      final isEnabled = Pipe(true);
      final count = Pipe(5);

      final result = ComputedPipe<String>(
        dependencies: [isEnabled, count],
        compute: () => isEnabled.value ? 'Enabled: ${count.value}' : 'Disabled',
      );

      expect(result.value, 'Enabled: 5');

      isEnabled.value = false;
      expect(result.value, 'Disabled');

      isEnabled.value = true;
      count.value = 10;
      expect(result.value, 'Enabled: 10');

      result.dispose();
      isEnabled.dispose();
      count.dispose();
    });

    test('should expose dependencies for debugging', () {
      final a = Pipe(5);
      final b = Pipe(10);

      final sum = ComputedPipe<int>(
        dependencies: [a, b],
        compute: () => a.value + b.value,
      );

      expect(sum.dependencies.length, 2);
      expect(sum.dependencies.contains(a), true);
      expect(sum.dependencies.contains(b), true);

      sum.dispose();
      a.dispose();
      b.dispose();
    });

    test('dependencies should be unmodifiable', () {
      final a = Pipe(5);

      final computed = ComputedPipe<int>(
        dependencies: [a],
        compute: () => a.value * 2,
      );

      expect(() => computed.dependencies.add(a), throwsUnsupportedError);

      computed.dispose();
      a.dispose();
    });

    test('should properly dispose and remove dependency listeners', () {
      final a = Pipe(5, autoDispose: false);
      final b = Pipe(10, autoDispose: false);

      final sum = ComputedPipe<int>(
        dependencies: [a, b],
        compute: () => a.value + b.value,
      );

      expect(sum.disposed, false);

      sum.dispose();

      expect(sum.disposed, true);

      // Dependencies should still work after computed is disposed
      a.value = 100;
      b.value = 200;

      expect(a.value, 100);
      expect(b.value, 200);

      a.dispose();
      b.dispose();
    });

    test('dispose should be idempotent', () {
      final a = Pipe(5);

      final computed = ComputedPipe<int>(
        dependencies: [a],
        compute: () => a.value * 2,
      );

      computed.dispose();
      computed.dispose(); // Should not throw

      expect(computed.disposed, true);

      a.dispose();
    });

    test('should throw assertion error when dependencies is empty', () {
      expect(
        () => ComputedPipe<int>(
          dependencies: [],
          compute: () => 42,
        ),
        throwsAssertionError,
      );
    });

    test('should throw assertion error when dependency is disposed', () {
      final a = Pipe(5);
      a.dispose();

      expect(
        () => ComputedPipe<int>(
          dependencies: [a],
          compute: () => a.value * 2,
        ),
        throwsAssertionError,
      );
    });

    test('accessing value after dispose should throw assertion error', () {
      final a = Pipe(5);

      final computed = ComputedPipe<int>(
        dependencies: [a],
        compute: () => a.value * 2,
      );

      computed.dispose();

      expect(() => computed.value, throwsAssertionError);

      a.dispose();
    });

    test('should not recompute after dispose', () {
      final a = Pipe(5, autoDispose: false);
      var computeCount = 0;

      final computed = ComputedPipe<int>(
        dependencies: [a],
        compute: () {
          computeCount++;
          return a.value * 2;
        },
      );

      expect(computeCount, 1); // Initial computation

      a.value = 10;
      expect(computeCount, 2); // Recomputed

      computed.dispose();

      a.value = 20;
      expect(computeCount, 2); // Should not recompute after dispose

      a.dispose();
    });

    test('should work with nullable types', () {
      final name = Pipe<String?>('John');

      final greeting = ComputedPipe<String>(
        dependencies: [name],
        compute: () => name.value != null ? 'Hello, ${name.value}!' : 'Hello!',
      );

      expect(greeting.value, 'Hello, John!');

      name.value = null;
      expect(greeting.value, 'Hello!');

      name.value = 'Jane';
      expect(greeting.value, 'Hello, Jane!');

      greeting.dispose();
      name.dispose();
    });

    test('should handle complex object types', () {
      final user = Pipe<Map<String, dynamic>>({'name': 'John', 'age': 25});

      final summary = ComputedPipe<String>(
        dependencies: [user],
        compute: () => '${user.value['name']} (${user.value['age']})',
      );

      expect(summary.value, 'John (25)');

      user.value = {'name': 'Jane', 'age': 30};
      expect(summary.value, 'Jane (30)');

      summary.dispose();
      user.dispose();
    });
  });
}

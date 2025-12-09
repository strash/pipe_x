import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:pipe_x/pipe_x.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PipeX State Management Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      initialRoute: '/',
      onGenerateRoute: _onGenerateRoute,
    );
  }

  static Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const ExamplesListScreen());
      case '/counter':
        return MaterialPageRoute(
          builder: (_) => HubProvider(
            create: () => CounterHub(),
            child: const CounterExample(),
          ),
        );
      case '/multiple-pipes':
        return MaterialPageRoute(
          builder: (_) => HubProvider(
            create: () => UserHub(),
            child: const MultiplePipesExample(),
          ),
        );
      case '/standalone-pipe':
        return MaterialPageRoute(builder: (_) => const StandalonePipeExample());
      case '/single-sink':
        return MaterialPageRoute(
          builder: (_) => HubProvider(
            create: () => TimerHub()..startTimer(),
            child: const SingleSinkExample(),
          ),
        );
      case '/multiple-sinks':
        return MaterialPageRoute(
          builder: (_) => HubProvider(
            create: () => MultiCounterHub(),
            child: const MultipleSinksExample(),
          ),
        );
      case '/well':
        return MaterialPageRoute(
          builder: (_) => HubProvider(
            create: () => CalculatorHub(),
            child: const WellExample(),
          ),
        );
      case '/hub-provider':
        return MaterialPageRoute(
          builder: (_) => HubProvider(
            create: () => ThemeHub(),
            child: const HubProviderExample(),
          ),
        );
      case '/multi-hub-provider':
        return MaterialPageRoute(
          builder: (_) => MultiHubProvider(
            hubs: [
              () => AuthHub(),
              () => SettingsHub(),
            ],
            child: const MultiHubProviderExample(),
          ),
        );
      case '/hub-provider-value':
        // Pre-create the hub instance
        final preCreatedHub = ThemeHub();
        return MaterialPageRoute(
          builder: (_) => HubProvider<ThemeHub>.value(
            value: preCreatedHub,
            child: const HubProviderValueExample(),
          ),
        );
      case '/multi-hub-provider-value':
        // Pre-create hub instances
        final authHub = AuthHub();
        final settingsHub = SettingsHub();
        return MaterialPageRoute(
          builder: (_) => MultiHubProvider(
            hubs: [
              authHub, // Existing instance
              settingsHub, // Existing instance
            ],
            child: const MultiHubProviderValueExample(),
          ),
        );
      case '/scoped-vs-global':
        return MaterialPageRoute(
          builder: (_) => HubProvider(
            create: () => CounterGlobalHub(),
            child: const ScopedVsGlobalExample(),
          ),
        );
      case '/computed-values':
        return MaterialPageRoute(
          builder: (_) => HubProvider(
            create: () => ShoppingHub(),
            child: const ComputedValuesExample(),
          ),
        );
      case '/async-basic':
        return MaterialPageRoute(
          builder: (_) => HubProvider(
            create: () => SimpleAsyncHub(),
            child: const SimpleAsyncExample(),
          ),
        );
      case '/async-advanced':
        // Ensure services are registered before creating DataHub
        if (!ServiceLocator.instance.isRegistered<IUserRepository>()) {
          setupServices();
        }
        return MaterialPageRoute(
          builder: (_) => HubProvider(
            create: () => DataHub(),
            child: const AsyncExample(),
          ),
        );
      case '/form':
        return MaterialPageRoute(
          builder: (_) => HubProvider(
            create: () => FormHub(),
            child: const FormExample(),
          ),
        );
      case '/class-type':
        return MaterialPageRoute(
          builder: (_) => HubProvider(
            create: () => UserProfileHub(),
            child: const ClassTypeExample(),
          ),
        );
      case '/hub-listener':
        return MaterialPageRoute(
          builder: (_) => HubProvider(
            create: () => TargetCounterHub(),
            child: const HubListenerExample(),
          ),
        );
      default:
        return null;
    }
  }
}

class ExamplesListScreen extends StatelessWidget {
  const ExamplesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('💧 PipeX Examples'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        children: [
          _buildSection(context, '📦 Basic Examples', const [
            _Example('Counter with Hub', '/counter'),
            _Example('Multiple Pipes', '/multiple-pipes'),
            _Example('Standalone Pipe (Auto-dispose)', '/standalone-pipe'),
            _Example('Class Type in Pipe', '/class-type'),
          ]),
          _buildSection(context, '🔄 Reactive Widgets', const [
            _Example('Single Sink', '/single-sink'),
            _Example('Multiple Sinks', '/multiple-sinks'),
            _Example('Well (Multiple Pipes)', '/well'),
          ]),
          _buildSection(context, '🏗️ Dependency Injection', const [
            _Example('HubProvider Basics', '/hub-provider'),
            _Example('MultiHubProvider', '/multi-hub-provider'),
            _Example('HubProvider.value (External Lifecycle)',
                '/hub-provider-value'),
            _Example(
                'MultiHubProvider with Values', '/multi-hub-provider-value'),
            _Example('Scoped vs Global', '/scoped-vs-global'),
          ]),
          _buildSection(context, '⚡ Advanced Patterns', const [
            _Example('Computed Values (Computed Pipe)', '/computed-values'),
            _Example('Async Operations (Basic)', '/async-basic'),
            _Example('Async Operations (Either + DI)', '/async-advanced'),
            _Example('Form Management', '/form'),
            _Example('HubListener (Conditional Side Effects)', '/hub-listener'),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(
      BuildContext context, String title, List<_Example> examples) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        ...examples.map((example) => ListTile(
              leading: const Icon(Icons.arrow_forward_ios, size: 16),
              title: Text(example.title),
              onTap: () => Navigator.pushNamed(context, example.route),
            )),
        const Divider(),
      ],
    );
  }
}

class _Example {
  final String title;
  final String route;
  const _Example(this.title, this.route);
}

// ============================================================================
// EXAMPLE 1: Counter with Hub
// ============================================================================

class CounterHub extends Hub {
  late final count = pipe(0);

  void increment() => count.value++;
  void decrement() => count.value--;
  void reset() => count.value = 0;
}

class CounterExample extends StatelessWidget {
  const CounterExample({super.key});

  @override
  Widget build(BuildContext context) {
    final hub = context.read<CounterHub>();

    return Scaffold(
      appBar: AppBar(title: const Text('Counter Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Basic counter with Hub & Sink:'),
            const SizedBox(height: 16),
            Sink(
              pipe: hub.count,
              builder: (context, value) {
                return Text(
                  '$value',
                  style: Theme.of(context).textTheme.displayLarge,
                );
              },
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  heroTag: 'dec',
                  onPressed: () => hub.decrement(),
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(width: 16),
                FloatingActionButton(
                  heroTag: 'inc',
                  onPressed: () => hub.increment(),
                  child: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => hub.reset(),
              child: const Text('Reset'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 2: Multiple Pipes
// ============================================================================

class UserHub extends Hub {
  late final name = pipe('John Doe');
  late final age = pipe(25);
  late final email = pipe('john@example.com');

  // Computed value using computed pipe
  late final summary = computedPipe(
    dependencies: [name, age],
    compute: () => '${name.value}, ${age.value} years old',
  );
}

class MultiplePipesExample extends StatelessWidget {
  const MultiplePipesExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Multiple Pipes')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Multiple independent pipes in one Hub:'),
            const SizedBox(height: 24),
            Sink(
              pipe: context.read<UserHub>().name,
              builder: (context, value) =>
                  Text('Name: $value', style: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 8),
            Sink(
              pipe: context.read<UserHub>().age,
              builder: (context, value) =>
                  Text('Age: $value', style: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 8),
            Sink(
              pipe: context.read<UserHub>().email,
              builder: (context, value) =>
                  Text('Email: $value', style: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final hub = context.read<UserHub>();
                hub.name.value = 'Jane Smith';
                hub.age.value = 30;
                hub.email.value = 'jane@example.com';
              },
              child: const Text('Update User'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 3: Standalone Pipe (Auto-dispose)
// ============================================================================

class StandalonePipeExample extends StatefulWidget {
  const StandalonePipeExample({super.key});

  @override
  State<StandalonePipeExample> createState() => _StandalonePipeExampleState();
}

class _StandalonePipeExampleState extends State<StandalonePipeExample> {
  late final Pipe<int> counter;
  late final Pipe<String> message;

  @override
  void initState() {
    super.initState();
    // These pipes are created outside a Hub, so they'll auto-dispose
    counter = Pipe(0);
    message = Pipe('Hello!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Standalone Pipe')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Pipes without Hub (auto-dispose on unmount):'),
            const SizedBox(height: 24),
            Sink(
              pipe: counter,
              builder: (context, value) => Text(
                'Counter: $value',
                style: const TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(height: 16),
            Sink(
              pipe: message,
              builder: (context, value) => Text(
                value,
                style: const TextStyle(fontSize: 18, color: Colors.blue),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                counter.value++;
                message.value = 'Count: ${counter.value}';
              },
              child: const Text('Increment'),
            ),
            const SizedBox(height: 16),
            Text(
              'These pipes will auto-dispose when you go back',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 4: Single Sink
// ============================================================================

class TimerHub extends Hub {
  late final seconds = pipe(0);

  void startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!disposed) {
        seconds.value++;
        return true;
      }
      return false;
    });
  }
}

class SingleSinkExample extends StatelessWidget {
  const SingleSinkExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Single Sink')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Only the Sink rebuilds, not the entire screen:'),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Sink(
                pipe: context.read<TimerHub>().seconds,
                builder: (context, value) {
                  return Text(
                    'Timer: $value seconds',
                    style: const TextStyle(
                        fontSize: 32, fontWeight: FontWeight.bold),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'This text never rebuilds!',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 5: Multiple Sinks
// ============================================================================

class MultiCounterHub extends Hub {
  late final counterA = pipe(0);
  late final counterB = pipe(0);
  late final counterC = pipe(0);

  void incrementA() => counterA.value++;
  void incrementB() => counterB.value++;
  void incrementC() => counterC.value++;
}

class MultipleSinksExample extends StatelessWidget {
  const MultipleSinksExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Multiple Sinks')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Each Sink rebuilds independently:'),
            const SizedBox(height: 32),
            _CounterRow('Counter A', context.read<MultiCounterHub>().counterA,
                () {
              context.read<MultiCounterHub>().incrementA();
            }),
            const SizedBox(height: 16),
            _CounterRow('Counter B', context.read<MultiCounterHub>().counterB,
                () {
              context.read<MultiCounterHub>().incrementB();
            }),
            const SizedBox(height: 16),
            _CounterRow('Counter C', context.read<MultiCounterHub>().counterC,
                () {
              context.read<MultiCounterHub>().incrementC();
            }),
          ],
        ),
      ),
    );
  }
}

class _CounterRow extends StatelessWidget {
  final String label;
  final Pipe<int> pipe;
  final VoidCallback onIncrement;

  const _CounterRow(this.label, this.pipe, this.onIncrement);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 18)),
        Row(
          children: [
            Sink(
              pipe: pipe,
              builder: (context, value) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('$value',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: onIncrement,
            ),
          ],
        ),
      ],
    );
  }
}

// ============================================================================
// EXAMPLE 6: Well (Multiple Pipes)
// ============================================================================

class CalculatorHub extends Hub {
  late final a = pipe(5);
  late final b = pipe(10);
  late final operation = pipe<String>('+');

  // Computed value using computed pipe
  late final result = computedPipe<double>(
    dependencies: [a, b, operation],
    compute: () {
      switch (operation.value) {
        case '+':
          return (a.value + b.value).toDouble();
        case '-':
          return (a.value - b.value).toDouble();
        case '*':
          return (a.value * b.value).toDouble();
        case '/':
          return b.value != 0 ? a.value / b.value : 0;
        default:
          return 0;
      }
    },
  );
}

class WellExample extends StatelessWidget {
  const WellExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Well Example')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Well listens to multiple pipes at once:'),
            const SizedBox(height: 32),
            Well(
              pipes: [
                context.read<CalculatorHub>().a,
                context.read<CalculatorHub>().b,
                context.read<CalculatorHub>().operation,
                context.read<CalculatorHub>().result,
              ],
              builder: (context) {
                final hub = context.read<CalculatorHub>();
                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.purple[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${hub.a.value} ${hub.operation.value} ${hub.b.value} = ${hub.result.value.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => context.read<CalculatorHub>().a.value++,
                  child: const Text('A+'),
                ),
                ElevatedButton(
                  onPressed: () => context.read<CalculatorHub>().b.value++,
                  child: const Text('B+'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: ['+', '-', '*', '/'].map((op) {
                return ElevatedButton(
                  onPressed: () =>
                      context.read<CalculatorHub>().operation.value = op,
                  child: Text(op),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 7: HubProvider Basics
// ============================================================================

class ThemeHub extends Hub {
  late final isDark = pipe(false);

  void toggle() => isDark.value = !isDark.value;
}

class HubProviderExample extends StatelessWidget {
  const HubProviderExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Sink(
      pipe: context.read<ThemeHub>().isDark,
      builder: (context, isDark) {
        return MaterialApp(
          theme: isDark ? ThemeData.dark() : ThemeData.light(),
          home: Scaffold(
            appBar: AppBar(
              title: const Text('HubProvider Example'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isDark ? '🌙 Dark Mode' : '☀️ Light Mode',
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.read<ThemeHub>().toggle(),
                    child: const Text('Toggle Theme'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ============================================================================
// EXAMPLE 8: MultiHubProvider
// ============================================================================

class AuthHub extends Hub {
  late final isLoggedIn = pipe(false);
  late final username = pipe('Guest');

  void login(String name) {
    username.value = name;
    isLoggedIn.value = true;
  }

  void logout() {
    username.value = 'Guest';
    isLoggedIn.value = false;
  }
}

class SettingsHub extends Hub {
  late final fontSize = pipe(16.0);
  late final enableNotifications = pipe(true);

  void increaseFontSize() => fontSize.value += 2;
  void decreaseFontSize() => fontSize.value -= 2;
}

class MultiHubProviderExample extends StatelessWidget {
  const MultiHubProviderExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MultiHubProvider')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Multiple Hubs without nesting:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Well(
              pipes: [
                context.read<AuthHub>().isLoggedIn,
                context.read<AuthHub>().username,
              ],
              builder: (context) {
                final auth = context.read<AuthHub>();
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Auth Status: ${auth.isLoggedIn.value ? "Logged In" : "Logged Out"}'),
                        Text('Username: ${auth.username.value}'),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            if (auth.isLoggedIn.value) {
                              auth.logout();
                            } else {
                              auth.login('John Doe');
                            }
                          },
                          child:
                              Text(auth.isLoggedIn.value ? 'Logout' : 'Login'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Sink<double>(
              pipe: context.read<SettingsHub>().fontSize,
              builder: (context, fontSize) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Font Size: ${fontSize.toInt()}',
                            style: TextStyle(fontSize: fontSize)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () => context
                                  .read<SettingsHub>()
                                  .decreaseFontSize(),
                              child: const Text('A-'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () => context
                                  .read<SettingsHub>()
                                  .increaseFontSize(),
                              child: const Text('A+'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 8.1: HubProvider.value (External Lifecycle)
// ============================================================================
//
// Use HubProvider.value when you want to manage the hub's lifecycle yourself.
// The hub is NOT automatically disposed when the provider is removed.
//
// Use cases:
// - Share a hub instance across multiple routes
// - When you need to keep state alive beyond widget lifecycle
// - Integration with existing dependency injection systems
// - Testing scenarios where you provide mock instances
// ============================================================================

class HubProviderValueExample extends StatefulWidget {
  const HubProviderValueExample({super.key});

  @override
  State<HubProviderValueExample> createState() =>
      _HubProviderValueExampleState();
}

class _HubProviderValueExampleState extends State<HubProviderValueExample> {
  int _toggleCount = 0;

  @override
  Widget build(BuildContext context) {
    return Sink(
      pipe: context.read<ThemeHub>().isDark,
      builder: (context, isDark) {
        return MaterialApp(
          theme: isDark ? ThemeData.dark() : ThemeData.light(),
          home: Scaffold(
            appBar: AppBar(
              title: const Text('HubProvider.value Example'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Info card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline,
                                  color: Colors.orange.shade700),
                              const SizedBox(width: 8),
                              const Text(
                                'HubProvider.value',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'This example uses HubProvider.value constructor.\n\n'
                            '✅ Hub was created BEFORE the provider\n'
                            '✅ You manage the lifecycle (not auto-disposed)\n'
                            '✅ Perfect for sharing state across routes\n'
                            '✅ Useful for testing with mock instances',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Theme toggle
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            isDark ? '🌙 Dark Mode' : '☀️ Light Mode',
                            style: const TextStyle(fontSize: 32),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Toggled $_toggleCount times',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() => _toggleCount++);
                              context.read<ThemeHub>().toggle();
                            },
                            icon: const Icon(Icons.brightness_6),
                            label: const Text('Toggle Theme'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Code example
                  Card(
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '📝 How this example was created:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            '// 1. Create the hub FIRST\n'
                            'final myHub = ThemeHub();\n\n'
                            '// 2. Provide it using .value\n'
                            'HubProvider<ThemeHub>.value(\n'
                            '  value: myHub,  // Pass existing instance\n'
                            '  child: MyApp(),\n'
                            ')\n\n'
                            '// 3. You must dispose it manually\n'
                            '// when you\'re done:\n'
                            'myHub.dispose();',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Comparison
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'HubProvider.create vs .value',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildComparisonRow(
                            'Lifecycle Management',
                            'Automatic',
                            'Manual',
                          ),
                          _buildComparisonRow(
                            'Auto-dispose',
                            'Yes ✅',
                            'No ❌',
                          ),
                          _buildComparisonRow(
                            'Created',
                            'By provider',
                            'Before provider',
                          ),
                          _buildComparisonRow(
                            'Use case',
                            'Most cases',
                            'Shared state',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildComparisonRow(String label, String create, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    create,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 8.2: MultiHubProvider with Existing Instances
// ============================================================================
//
// MultiHubProvider can accept both:
// - Factory functions: () => MyHub() (will be created and disposed)
// - Hub instances: myHub (will NOT be disposed)
//
// Mix and match as needed for your use case!
// ============================================================================

class MultiHubProviderValueExample extends StatelessWidget {
  const MultiHubProviderValueExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MultiHubProvider with Values'),
        backgroundColor: Colors.teal.shade700,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info card
            Card(
              color: Colors.teal.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.layers, color: Colors.teal.shade700),
                        const SizedBox(width: 8),
                        const Text(
                          'Pre-created Hub Instances',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Both hubs in this example were created BEFORE '
                      'the MultiHubProvider:\n\n'
                      '✅ Full control over initialization\n'
                      '✅ Can configure hubs before providing them\n'
                      '✅ Easy to test with dependency injection\n'
                      '✅ You manage disposal manually',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Auth Hub section
            Well(
              pipes: [
                context.read<AuthHub>().isLoggedIn,
                context.read<AuthHub>().username,
              ],
              builder: (context) {
                final auth = context.read<AuthHub>();
                return Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.account_circle,
                              color: auth.isLoggedIn.value
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Auth Hub (Pre-created)',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        Text(
                          'Status: ${auth.isLoggedIn.value ? "Logged In ✅" : "Logged Out ❌"}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          'User: ${auth.username.value}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            if (auth.isLoggedIn.value) {
                              auth.logout();
                            } else {
                              auth.login('Alice');
                            }
                          },
                          icon: Icon(
                            auth.isLoggedIn.value ? Icons.logout : Icons.login,
                          ),
                          label: Text(
                            auth.isLoggedIn.value ? 'Logout' : 'Login',
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Settings Hub section
            Sink<double>(
              pipe: context.read<SettingsHub>().fontSize,
              builder: (context, fontSize) {
                return Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.settings, color: Colors.blue),
                            SizedBox(width: 8),
                            Text(
                              'Settings Hub (Pre-created)',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        Text(
                          'Font Size: ${fontSize.toInt()}px',
                          style: TextStyle(fontSize: fontSize),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => context
                                  .read<SettingsHub>()
                                  .decreaseFontSize(),
                              icon: const Icon(Icons.text_decrease),
                              label: const Text('Smaller'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: () => context
                                  .read<SettingsHub>()
                                  .increaseFontSize(),
                              icon: const Icon(Icons.text_increase),
                              label: const Text('Larger'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // Code example
            Card(
              color: Colors.grey.shade100,
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📝 Code for this example:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      '// 1. Create hub instances first\n'
                      'final authHub = AuthHub();\n'
                      'final settingsHub = SettingsHub();\n\n'
                      '// 2. Pass them to MultiHubProvider\n'
                      'MultiHubProvider(\n'
                      '  hubs: [\n'
                      '    authHub,        // Existing instance\n'
                      '    settingsHub,    // Existing instance\n'
                      '  ],\n'
                      '  child: MyApp(),\n'
                      ')\n\n'
                      '// You can also mix factories and values:\n'
                      'MultiHubProvider(\n'
                      '  hubs: [\n'
                      '    authHub,           // Existing (no dispose)\n'
                      '    () => ThemeHub(),  // Factory (auto-dispose)\n'
                      '  ],\n'
                      '  child: MyApp(),\n'
                      ')',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 9: Scoped vs Global
// ============================================================================

class CounterGlobalHub extends Hub {
  late final count = pipe(0);
  void increment() => count.value++;
}

class ScopedVsGlobalExample extends StatelessWidget {
  const ScopedVsGlobalExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scoped vs Global')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Global Hub (survives navigation):'),
            Sink(
              pipe: context.read<CounterGlobalHub>().count,
              builder: (context, value) => Text('Global Count: $value',
                  style: const TextStyle(fontSize: 24)),
            ),
            ElevatedButton(
              onPressed: () => context.read<CounterGlobalHub>().increment(),
              child: const Text('Increment Global'),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ScopedScreen()),
                );
              },
              child: const Text('Open Scoped Screen'),
            ),
          ],
        ),
      ),
    );
  }
}

class ScopedScreen extends StatelessWidget {
  const ScopedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return HubProvider(
      create: () => CounterGlobalHub(), // New instance, disposed on pop
      child: Scaffold(
        appBar: AppBar(title: const Text('Scoped Screen')),
        body: Center(
          child: Comp(),
        ),
      ),
    );
  }
}

class Comp extends StatelessWidget {
  const Comp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Scoped Hub (disposed on back):'),
        Sink(
          pipe: context.read<CounterGlobalHub>().count,
          builder: (context, value) => Text('Scoped Count: $value',
              style: const TextStyle(fontSize: 24)),
        ),
        ElevatedButton(
          onPressed: () => context.read<CounterGlobalHub>().increment(),
          child: const Text('Increment Scoped'),
        ),
      ],
    );
  }
}

// ============================================================================
// EXAMPLE 10: Computed Values (Computed Pipe)
// ============================================================================

class ShoppingHub extends Hub {
  late final items = pipe<List<String>>([]);
  late final pricePerItem = pipe(9.99);

  // Computed values using computed pipes
  late final itemCount = computedPipe<int>(
    dependencies: [items],
    compute: () => items.value.length,
  );

  late final total = computedPipe<double>(
    dependencies: [items, pricePerItem],
    compute: () => items.value.length * pricePerItem.value,
  );

  late final summary = computedPipe<String>(
    dependencies: [items, pricePerItem],
    compute: () =>
        '${items.value.length} items - \$${(items.value.length * pricePerItem.value).toStringAsFixed(2)}',
  );

  void addItem(String item) {
    items.value = [...items.value, item];
  }

  void clear() {
    items.value = [];
  }
}

class ComputedValuesExample extends StatelessWidget {
  const ComputedValuesExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Computed Values')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Use computed pipes for derived state:',
                style: TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            Well(
              pipes: [
                context.read<ShoppingHub>().itemCount,
                context.read<ShoppingHub>().pricePerItem,
                context.read<ShoppingHub>().total,
              ],
              builder: (context) {
                final hub = context.read<ShoppingHub>();
                return Card(
                  color: Colors.blue[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Items: ${hub.itemCount.value}',
                            style: const TextStyle(fontSize: 18)),
                        Text(
                            'Price per item: \$${hub.pricePerItem.value.toStringAsFixed(2)}'),
                        const Divider(),
                        Text(
                          'Total: \$${hub.total.value.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Sink(
                pipe: context.read<ShoppingHub>().items,
                builder: (context, items) {
                  if (items.isEmpty) {
                    return const Center(child: Text('No items yet'));
                  }
                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: const Icon(Icons.shopping_cart),
                        title: Text(items[index]),
                      );
                    },
                  );
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final hub = context.read<ShoppingHub>();
                      hub.addItem('Item ${hub.itemCount.value + 1}');
                    },
                    child: const Text('Add Item'),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => context.read<ShoppingHub>().clear(),
                  child: const Text('Clear'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 11: Async Operations (Basic AsyncPipe)
// ============================================================================
//
// Simple example showing AsyncPipe basics:
// - Loading, data, and error states
// - Pattern matching with state.when()
// - Refresh and error simulation
//
// ============================================================================

/// Simple data model
class Post {
  final int id;
  final String title;
  final String body;

  const Post({required this.id, required this.title, required this.body});
}

/// Simple async hub - no Either, no DI, just basic AsyncPipe usage
class SimpleAsyncHub extends Hub {
  // Flag to simulate error
  bool _simulateError = false;

  // AsyncPipe automatically handles loading/data/error states
  late final posts = asyncPipe<List<Post>>(
    () => _fetchPosts(),
    immediate: true, // Starts loading immediately (default)
  );

  // Simulated API call - always succeeds unless error is simulated
  Future<List<Post>> _fetchPosts() async {
    await Future.delayed(const Duration(seconds: 2));

    // Check if we should simulate an error
    if (_simulateError) {
      _simulateError = false; // Reset for next time
      throw Exception('Network error! Failed to load posts.');
    }

    return const [
      Post(
          id: 1,
          title: 'Getting Started with PipeX',
          body: 'Learn the basics of reactive state management...'),
      Post(
          id: 2,
          title: 'AsyncPipe Deep Dive',
          body: 'Handle async operations with ease...'),
      Post(
          id: 3,
          title: 'Error Handling Patterns',
          body: 'Best practices for handling errors...'),
    ];
  }

  // Simulate an error on next fetch
  void simulateError() {
    _simulateError = true;
    posts.refresh();
  }

  // Normal refresh
  void refresh() {
    _simulateError = false;
    posts.refresh();
  }
}

class SimpleAsyncExample extends StatelessWidget {
  const SimpleAsyncExample({super.key});

  @override
  Widget build(BuildContext context) {
    final hub = context.read<SimpleAsyncHub>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('AsyncPipe Basics'),
      ),
      body: Column(
        children: [
          // Action buttons
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.grey.shade100,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => hub.refresh(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh (Success)'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => hub.simulateError(),
                    icon: const Icon(Icons.error_outline, color: Colors.red),
                    label: const Text('Simulate Error'),
                    style:
                        OutlinedButton.styleFrom(foregroundColor: Colors.red),
                  ),
                ),
              ],
            ),
          ),

          // Posts list with async state handling
          Expanded(
            child: Sink<AsyncValue<List<Post>>>(
              pipe: hub.posts,
              builder: (context, state) {
                // Pattern matching with state.when()
                return state.when(
                  // Loading state
                  loading: () => const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading posts...'),
                      ],
                    ),
                  ),

                  // Success state
                  data: (posts) => ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: posts.length + 1, // +1 for header
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle,
                                  color: Colors.green, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                '${posts.length} posts loaded successfully',
                                style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        );
                      }
                      final post = posts[index - 1];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(child: Text('${post.id}')),
                          title: Text(post.title),
                          subtitle: Text(post.body,
                              maxLines: 2, overflow: TextOverflow.ellipsis),
                        ),
                      );
                    },
                  ),

                  // Error state
                  onError: (error, stackTrace) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 48, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(
                            error.toString(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => hub.refresh(),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Info card
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.blue.shade50,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AsyncPipe Features:',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                SizedBox(height: 4),
                Text(
                  '• asyncPipe() - creates async reactive state\n'
                  '• state.when() - pattern match loading/data/error\n'
                  '• refresh() - re-fetch data\n'
                  '• setError() / setData() - manually set state',
                  style: TextStyle(fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 12: Async Operations with Either Pattern & Service Architecture
// ============================================================================
//
// This example demonstrates a production-ready architecture with:
// 1. dartz Either<L, R> for type-safe error handling
// 2. Sealed Failure classes for domain errors
// 3. Abstract Repository interfaces
// 4. Concrete implementations (Mock/Real)
// 5. Simple Service Locator for DI
// 6. Hub consuming repository through DI
//
// Using: import 'package:dartz/dartz.dart';
//   - left(failure) creates Left<Failure, T>
//   - right(success) creates Right<Failure, T>
//   - result.fold((l) => ..., (r) => ...) pattern matches
//
// ============================================================================

// =============================================================================
// PART 1: Domain Failures (Sealed Classes)
// =============================================================================

/// Base sealed class for all domain failures
sealed class Failure {
  final String message;
  final String? code;
  final StackTrace? stackTrace;

  const Failure(this.message, {this.code, this.stackTrace});
}

/// Network connectivity failures
final class NetworkFailure extends Failure {
  final bool isTimeout;
  final bool isNoInternet;

  const NetworkFailure(
    super.message, {
    super.code,
    super.stackTrace,
    this.isTimeout = false,
    this.isNoInternet = false,
  });
}

/// Authentication/Authorization failures
final class AuthFailure extends Failure {
  final bool isTokenExpired;
  final bool isUnauthorized;
  final bool isForbidden;

  const AuthFailure(
    super.message, {
    super.code,
    super.stackTrace,
    this.isTokenExpired = false,
    this.isUnauthorized = false,
    this.isForbidden = false,
  });
}

/// Resource not found failures
final class NotFoundFailure extends Failure {
  final String? resourceType;
  final String? resourceId;

  const NotFoundFailure(
    super.message, {
    super.code,
    super.stackTrace,
    this.resourceType,
    this.resourceId,
  });
}

/// Validation/Input failures
final class ValidationFailure extends Failure {
  final Map<String, List<String>> fieldErrors;

  const ValidationFailure(
    super.message, {
    super.code,
    super.stackTrace,
    this.fieldErrors = const {},
  });
}

/// Server-side failures
final class ServerFailure extends Failure {
  final int? statusCode;
  final bool isMaintenanceMode;

  const ServerFailure(
    super.message, {
    super.code,
    super.stackTrace,
    this.statusCode,
    this.isMaintenanceMode = false,
  });
}

/// Cache/Local storage failures
final class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.code, super.stackTrace});
}

/// Unknown/Unexpected failures
final class UnknownFailure extends Failure {
  final Object? originalError;

  const UnknownFailure(
    super.message, {
    super.code,
    super.stackTrace,
    this.originalError,
  });
}

// =============================================================================
// PART 3: Domain Models
// =============================================================================

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String city;
  final String occupation;
  final String gender;
  final int age;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.city,
    required this.occupation,
    required this.gender,
    required this.age,
  });

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? city,
    String? occupation,
    String? gender,
    int? age,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      occupation: occupation ?? this.occupation,
      gender: gender ?? this.gender,
      age: age ?? this.age,
    );
  }
}

// =============================================================================
// PART 4: Abstract Repository Interface
// =============================================================================

/// Abstract repository interface - defines the contract
abstract class IUserRepository {
  /// Fetch user profile by ID
  Future<Either<Failure, UserProfile>> getUserProfile(String userId);

  /// Update user profile
  Future<Either<Failure, UserProfile>> updateUserProfile(UserProfile profile);

  /// Delete user profile
  Future<Either<Failure, void>> deleteUserProfile(String userId);
}

// =============================================================================
// PART 5: Concrete Repository Implementations
// =============================================================================

/// Scenario enum for demo purposes
enum MockScenario {
  success('Success', Icons.check_circle, Colors.green),
  networkError('Network Error', Icons.wifi_off, Colors.orange),
  authError('Auth Error', Icons.lock, Colors.red),
  notFound('Not Found', Icons.search_off, Colors.purple),
  validationError('Validation', Icons.warning, Colors.amber),
  serverError('Server Error', Icons.cloud_off, Colors.grey);

  final String label;
  final IconData icon;
  final Color color;

  const MockScenario(this.label, this.icon, this.color);
}

/// Mock repository implementation for testing/demo
class MockUserRepository implements IUserRepository {
  MockScenario scenario;

  MockUserRepository({this.scenario = MockScenario.success});

  @override
  Future<Either<Failure, UserProfile>> getUserProfile(String userId) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Return based on scenario using dartz's left() and right() functions
    return switch (scenario) {
      MockScenario.success => right(UserProfile(
          id: userId,
          name: 'John Doe',
          email: 'john@example.com',
          phone: '+1 (555) 123-4567',
          city: 'San Francisco',
          occupation: 'Software Engineer',
          gender: 'Male',
          age: 28,
        )),
      MockScenario.networkError => left(const NetworkFailure(
          'Unable to connect. Check your internet connection.',
          code: 'NETWORK_ERROR',
          isNoInternet: true,
        )),
      MockScenario.authError => left(const AuthFailure(
          'Session expired. Please log in again.',
          code: 'TOKEN_EXPIRED',
          isTokenExpired: true,
        )),
      MockScenario.notFound => left(NotFoundFailure(
          'User profile not found.',
          code: 'USER_NOT_FOUND',
          resourceType: 'UserProfile',
          resourceId: userId,
        )),
      MockScenario.validationError => left(const ValidationFailure(
          'Invalid request parameters.',
          code: 'VALIDATION_ERROR',
          fieldErrors: {
            'userId': ['Must be a valid UUID format'],
          },
        )),
      MockScenario.serverError => left(const ServerFailure(
          'Internal server error. Please try again later.',
          code: 'INTERNAL_ERROR',
          statusCode: 500,
        )),
    };
  }

  @override
  Future<Either<Failure, UserProfile>> updateUserProfile(
      UserProfile profile) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return right(profile);
  }

  @override
  Future<Either<Failure, void>> deleteUserProfile(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return right(null);
  }
}

// =============================================================================
// PART 6: Simple Service Locator (DI)
// =============================================================================

/// Simple service locator for dependency injection
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._();
  static ServiceLocator get instance => _instance;

  ServiceLocator._();

  final Map<Type, Object> _services = {};

  /// Register a service
  void register<T extends Object>(T service) {
    _services[T] = service;
  }

  /// Get a registered service
  T get<T extends Object>() {
    final service = _services[T];
    if (service == null) {
      throw Exception('Service $T not registered');
    }
    return service as T;
  }

  /// Check if service is registered
  bool isRegistered<T extends Object>() => _services.containsKey(T);

  /// Clear all services
  void reset() => _services.clear();
}

// Initialize services (call this at app startup)
void setupServices() {
  final locator = ServiceLocator.instance;

  // Register mock repository (in production, use real implementation)
  locator.register<IUserRepository>(MockUserRepository());
}

// =============================================================================
// PART 7: Hub with Repository Integration
// =============================================================================

class DataHub extends Hub {
  // Get repository from service locator
  final IUserRepository _repository;

  // Expose scenario for demo UI
  late final selectedScenario = pipe<MockScenario>(MockScenario.success);

  // AsyncPipe for user profile - uses Either pattern internally
  late final userProfile = asyncPipe<UserProfile>(
    () => _fetchProfile(),
  );

  DataHub({IUserRepository? repository})
      : _repository =
            repository ?? ServiceLocator.instance.get<IUserRepository>();

  /// Fetch profile using Either pattern
  Future<UserProfile> _fetchProfile() async {
    // Update mock scenario if using mock repository
    final repo = _repository;
    if (repo is MockUserRepository) {
      repo.scenario = selectedScenario.value;
    }

    // Call repository - returns Either<Failure, UserProfile>
    final result = await _repository.getUserProfile('USR-12345');

    // Fold the Either to either throw or return value
    return result.fold(
      (failure) => throw failure, // Convert Left to exception for AsyncPipe
      (profile) => profile, // Return Right value
    );
  }

  /// Retry with different scenario
  void retryWithScenario(MockScenario scenario) {
    selectedScenario.value = scenario;
    userProfile.refresh();
  }

  /// Update gender with optimistic update
  void updateGender(String newGender) {
    final current = userProfile.dataOrNull;
    if (current != null) {
      userProfile.setData(current.copyWith(gender: newGender));
    }
  }

  /// Update age with optimistic update
  void updateAge(int newAge) {
    final current = userProfile.dataOrNull;
    if (current != null) {
      userProfile.setData(current.copyWith(age: newAge));
    }
  }
}

// =============================================================================
// PART 8: UI Widgets
// =============================================================================

class AsyncExample extends StatelessWidget {
  const AsyncExample({super.key});

  @override
  Widget build(BuildContext context) {
    final hub = context.read<DataHub>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Either Pattern + DI'),
        backgroundColor: Colors.indigo,
      ),
      body: Column(
        children: [
          // Architecture info banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.indigo.shade50,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Clean Architecture Demo',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                SizedBox(height: 4),
                Text(
                  'Either<Failure, T> • Abstract Repository • Service Locator',
                  style: TextStyle(fontSize: 11, color: Colors.indigo),
                ),
              ],
            ),
          ),

          // Scenario selector
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.grey[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mock Repository Response:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Sink<MockScenario>(
                  pipe: hub.selectedScenario,
                  builder: (context, selected) {
                    return Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: MockScenario.values.map((scenario) {
                        return ChoiceChip(
                          avatar: Icon(scenario.icon,
                              size: 16, color: scenario.color),
                          label: Text(scenario.label,
                              style: const TextStyle(fontSize: 11)),
                          selected: selected == scenario,
                          onSelected: (_) => hub.retryWithScenario(scenario),
                          selectedColor: scenario.color.withOpacity(0.2),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),

          // Main content
          Expanded(
            child: Sink<AsyncValue<UserProfile>>(
              pipe: hub.userProfile,
              builder: (context, state) {
                return state.when(
                  loading: () => const _LoadingWidget(),
                  data: (profile) => _ProfileScreen(hub: hub, profile: profile),
                  onError: (error, _) =>
                      _FailureWidget(failure: error, hub: hub),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Fetching from repository...', style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}

// =============================================================================
// PART 9: Failure Widget with Pattern Matching
// =============================================================================

class _FailureWidget extends StatelessWidget {
  final Object failure;
  final DataHub hub;

  const _FailureWidget({required this.failure, required this.hub});

  @override
  Widget build(BuildContext context) {
    // Pattern match on sealed Failure type!
    return switch (failure) {
      NetworkFailure f => _buildFailureCard(
          context,
          icon: Icons.wifi_off,
          color: Colors.orange,
          title: 'Network Failure',
          message: f.message,
          code: f.code,
          details: f.isNoInternet
              ? '📡 No internet connection'
              : f.isTimeout
                  ? '⏱️ Request timed out'
                  : null,
        ),
      AuthFailure f => _buildFailureCard(
          context,
          icon: Icons.lock_outline,
          color: Colors.red,
          title: 'Auth Failure',
          message: f.message,
          code: f.code,
          details: f.isTokenExpired ? '🔑 Token expired' : null,
          primaryAction: 'Log In Again',
          primaryIcon: Icons.login,
        ),
      NotFoundFailure f => _buildFailureCard(
          context,
          icon: Icons.search_off,
          color: Colors.purple,
          title: 'Not Found',
          message: f.message,
          code: f.code,
          details: f.resourceType != null
              ? '📦 ${f.resourceType}: ${f.resourceId}'
              : null,
        ),
      ValidationFailure f => _buildValidationFailure(context, f),
      ServerFailure f => _buildFailureCard(
          context,
          icon: Icons.cloud_off,
          color: Colors.grey,
          title: 'Server Failure',
          message: f.message,
          code: f.code,
          details: f.statusCode != null ? '🔢 HTTP ${f.statusCode}' : null,
        ),
      CacheFailure f => _buildFailureCard(
          context,
          icon: Icons.storage,
          color: Colors.brown,
          title: 'Cache Failure',
          message: f.message,
          code: f.code,
        ),
      UnknownFailure f => _buildFailureCard(
          context,
          icon: Icons.error_outline,
          color: Colors.red,
          title: 'Unknown Failure',
          message: f.message,
          code: f.code,
        ),
      _ => _buildFailureCard(
          context,
          icon: Icons.error,
          color: Colors.red,
          title: 'Error',
          message: failure.toString(),
        ),
    };
  }

  Widget _buildFailureCard(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String message,
    String? code,
    String? details,
    String? primaryAction,
    IconData? primaryIcon,
  }) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: color),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
            if (code != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Code: $code',
                  style: TextStyle(
                    fontSize: 11,
                    fontFamily: 'monospace',
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
            if (details != null) ...[
              const SizedBox(height: 8),
              Text(details,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => hub.userProfile.refresh(),
                  icon: Icon(primaryIcon ?? Icons.refresh),
                  label: Text(primaryAction ?? 'Retry'),
                ),
                OutlinedButton.icon(
                  onPressed: () => hub.retryWithScenario(MockScenario.success),
                  icon: const Icon(Icons.check),
                  label: const Text('Mock Success'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValidationFailure(BuildContext context, ValidationFailure f) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.warning_amber,
                  size: 48, color: Colors.amber),
            ),
            const SizedBox(height: 16),
            const Text(
              'Validation Failure',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 8),
            Text(f.message, textAlign: TextAlign.center),
            if (f.fieldErrors.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Field Errors:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...f.fieldErrors.entries.map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('• ${e.key}: ',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                              Expanded(child: Text(e.value.join(', '))),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => hub.retryWithScenario(MockScenario.success),
              icon: const Icon(Icons.check),
              label: const Text('Fix & Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// PART 10: Profile Screen
// =============================================================================

class _ProfileScreen extends StatelessWidget {
  final DataHub hub;
  final UserProfile profile;

  const _ProfileScreen({required this.hub, required this.profile});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Success banner
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle, size: 20, color: Colors.green),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Either.Right(UserProfile) returned successfully!',
                    style: TextStyle(fontSize: 12, color: Colors.green),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Profile fields
          _buildField('ID', profile.id, Icons.badge),
          _buildField('Name', profile.name, Icons.person),
          _buildField('Email', profile.email, Icons.email),
          _buildField('Phone', profile.phone, Icons.phone),
          _buildField('City', profile.city, Icons.location_city),
          _buildField('Occupation', profile.occupation, Icons.work),

          const SizedBox(height: 16),

          // Gender
          const Text('Gender:', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: ['Male', 'Female', 'Other']
                .map((g) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(g),
                        selected: profile.gender == g,
                        onSelected: (_) => hub.updateGender(g),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),

          // Age
          Row(
            children: [
              const Text('Age:', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(width: 12),
              Text('${profile.age}',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold)),
              IconButton(
                  icon: const Icon(Icons.remove_circle),
                  onPressed: () {
                    if (profile.age > 1) hub.updateAge(profile.age - 1);
                  }),
              IconButton(
                  icon: const Icon(Icons.add_circle),
                  onPressed: () => hub.updateAge(profile.age + 1)),
            ],
          ),

          const SizedBox(height: 24),

          // Architecture info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('📚 Architecture Pattern:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text(
                  '• Either<Failure, T> for type-safe errors\n'
                  '• Sealed Failure classes for pattern matching\n'
                  '• Abstract IUserRepository interface\n'
                  '• MockUserRepository implementation\n'
                  '• ServiceLocator for dependency injection\n'
                  '• Hub consumes repository via DI',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          Center(
            child: ElevatedButton.icon(
              onPressed: () => hub.userProfile.refresh(),
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600])),
              Text(value, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 12: Form Management
// ============================================================================

class FormHub extends Hub {
  late final name = pipe('');
  late final email = pipe('');
  late final age = pipe('');

  // Validation computed pipes
  late final isNameValid = computedPipe<bool>(
    dependencies: [name],
    compute: () => name.value.length >= 3,
  );

  late final isEmailValid = computedPipe<bool>(
    dependencies: [email],
    compute: () => email.value.contains('@'),
  );

  late final isAgeValid = computedPipe<bool>(
    dependencies: [age],
    compute: () =>
        int.tryParse(age.value) != null && int.parse(age.value) >= 18,
  );

  late final isFormValid = computedPipe<bool>(
    dependencies: [name, email, age],
    compute: () =>
        name.value.length >= 3 &&
        email.value.contains('@') &&
        (int.tryParse(age.value) != null && int.parse(age.value) >= 18),
  );

  void submit() {
    if (isFormValid.value) {
      // Handle submission
    }
  }
}

class FormExample extends StatelessWidget {
  const FormExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Form Management')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration:
                  const InputDecoration(labelText: 'Name (min 3 chars)'),
              onChanged: (value) => context.read<FormHub>().name.value = value,
            ),
            Sink<bool>(
              pipe: context.read<FormHub>().isNameValid,
              builder: (context, isValid) {
                return Text(
                  isValid ? '✓ Valid' : '✗ Too short',
                  style: TextStyle(
                      color: isValid ? Colors.green : Colors.red, fontSize: 12),
                );
              },
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(labelText: 'Email'),
              onChanged: (value) => context.read<FormHub>().email.value = value,
            ),
            Sink<bool>(
              pipe: context.read<FormHub>().isEmailValid,
              builder: (context, isValid) {
                return Text(
                  isValid ? '✓ Valid' : '✗ Invalid email',
                  style: TextStyle(
                      color: isValid ? Colors.green : Colors.red, fontSize: 12),
                );
              },
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(labelText: 'Age (18+)'),
              keyboardType: TextInputType.number,
              onChanged: (value) => context.read<FormHub>().age.value = value,
            ),
            Sink<bool>(
              pipe: context.read<FormHub>().isAgeValid,
              builder: (context, isValid) {
                return Text(
                  isValid ? '✓ Valid' : '✗ Must be 18+',
                  style: TextStyle(
                      color: isValid ? Colors.green : Colors.red, fontSize: 12),
                );
              },
            ),
            const SizedBox(height: 24),
            Sink<bool>(
              pipe: context.read<FormHub>().isFormValid,
              builder: (context, isValid) {
                final hub = context.read<FormHub>();
                return ElevatedButton(
                  onPressed: isValid ? () => hub.submit() : null,
                  child: const Text('Submit'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 13: Class Type in Pipe
// ============================================================================

/// User profile model class (MUTABLE)
/// This class demonstrates using mutable objects with Pipe.forceUpdate()
class MutableUserProfile {
  String name;
  int age;
  String email;
  String bio;
  bool isPremium;

  MutableUserProfile({
    required this.name,
    required this.age,
    required this.email,
    required this.bio,
    required this.isPremium,
  });
}

class UserProfileHub extends Hub {
  late final user = pipe<MutableUserProfile>(
    MutableUserProfile(
      name: 'John Doe',
      age: 28,
      email: 'john@example.com',
      bio: 'Flutter developer',
      isPremium: false,
    ),
  );

  /// Update specific fields by mutating the object and calling forceUpdate
  /// This demonstrates using mutable objects with Pipe
  void updateName(String name) {
    user.value.name = name;
    user.pump(user.value); // Force rebuild even though reference didn't change
  }

  void updateAge(int age) {
    user.value.age++;
    user.pump(user.value);
  }

  void updateEmail(String email) {
    user.value.email = email;
    user.pump(user.value);
  }

  void updateBio(String bio) {
    user.value.bio = bio;
    user.pump(user.value);
  }

  void togglePremium() {
    user.value.isPremium = !user.value.isPremium;
    user.pump(user.value);
  }
}

class ClassTypeExample extends StatelessWidget {
  const ClassTypeExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Class Type in Pipe')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Using MUTABLE classes in Pipes:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Entire object is stored in one Pipe. Mutate fields and call forceUpdate().',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // Display user profile
            Sink(
              pipe: context.read<UserProfileHub>().user,
              builder: (context, user) {
                return Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor:
                                  user.isPremium ? Colors.amber : Colors.grey,
                              child: Text(
                                user.name.isNotEmpty ? user.name[0] : '?',
                                style: const TextStyle(
                                    fontSize: 24, color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        user.name,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (user.isPremium)
                                        const Padding(
                                          padding: EdgeInsets.only(left: 8),
                                          child: Icon(Icons.star,
                                              color: Colors.amber, size: 20),
                                        ),
                                    ],
                                  ),
                                  Text(
                                    '${user.age} years old',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          children: [
                            const Icon(Icons.email,
                                size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(user.email),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.info,
                                size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(child: Text(user.bio)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),
            const Text(
              'Update Methods:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Update name
            TextField(
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                context.read<UserProfileHub>().updateName(value);
              },
            ),
            const SizedBox(height: 12),

            // Update email
            TextField(
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                context.read<UserProfileHub>().updateEmail(value);
              },
            ),
            const SizedBox(height: 12),

            // Update bio
            TextField(
              decoration: const InputDecoration(
                labelText: 'Bio',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              onChanged: (value) {
                context.read<UserProfileHub>().updateBio(value);
              },
            ),
            const SizedBox(height: 24),

            // Age buttons
            Row(
              children: [
                const Text('Age: '),
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () {
                    final hub = context.read<UserProfileHub>();
                    final newAge = (hub.user.value.age - 1).clamp(0, 120);
                    hub.updateAge(newAge);
                  },
                ),
                Sink(
                  pipe: context.read<UserProfileHub>().user,
                  builder: (context, user) => Text(
                    '${user.age}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    final hub = context.read<UserProfileHub>();
                    final newAge = (hub.user.value.age + 1).clamp(0, 120);
                    hub.updateAge(newAge);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Premium toggle
            ElevatedButton.icon(
              onPressed: () => context.read<UserProfileHub>().togglePremium(),
              icon: const Icon(Icons.star),
              label: const Text('Toggle Premium Status'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),

            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💡 Key Points:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('• Entire object stored in Pipe<UserProfile>'),
                  Text('• Mutate object fields directly'),
                  Text('• Call forceUpdate() to trigger Sink rebuild'),
                  Text('• Useful for mutable objects (e.g., from APIs)'),
                  Text('• Reference stays same, but UI updates'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// EXAMPLE: HubListener - Conditional Side Effects
// ============================================================================

class TargetCounterHub extends Hub {
  late final count = pipe(0);
  late final target = pipe(5);
  late final VoidCallback _removeListener;

  void onTargetReached(BuildContext context) {
    // _removeListener is a function that removes the listener from the hub.
    // You may or may not call it in dispose, it's up to you.
    // If you don't call it in dispose, the listener will be also disposed when the hub is disposed.
    _removeListener = addListener(() {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎯 Target Reached!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    });
  }

  void increment() => count.value++;
  void decrement() => count.value--;
  void setTarget(int value) => target.value = value;

  @override
  void dispose() {
    _removeListener();
    super.dispose();
  }
}

class HubListenerExample extends StatelessWidget {
  const HubListenerExample({super.key});

  @override
  Widget build(BuildContext context) {
    final hub = context.read<TargetCounterHub>();
    hub.onTargetReached(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('HubListener Example'),
        backgroundColor: Colors.purple,
      ),
      body: HubListener<TargetCounterHub>(
        listenWhen: (hub) {
          // Condition: when count equals target
          return hub.count.value == hub.target.value;
        },
        onConditionMet: () {
          // Side effect: show snackbar (NO rebuild!)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🎯🎯🎯 Target Reached!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '🎯 Target Counter',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),

              // Current count
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Count: ',
                    style: TextStyle(fontSize: 20),
                  ),
                  Sink<int>(
                    pipe: hub.count,
                    builder: (context, count) => Text(
                      count.toString(),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Target value
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Target: ',
                    style: TextStyle(fontSize: 20),
                  ),
                  Sink<int>(
                    pipe: hub.target,
                    builder: (context, target) => Text(
                      target.toString(),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Counter buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: hub.decrement,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(20),
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Icon(Icons.remove, size: 32),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: hub.increment,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(20),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Icon(Icons.add, size: 32),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Target selection
              const Text(
                'Set Target:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [3, 5, 10, 15, 20].map((value) {
                  return Sink<int>(
                    pipe: hub.target,
                    builder: (context, currentTarget) => OutlinedButton(
                      onPressed: () => hub.setTarget(value),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: currentTarget == value
                            ? Colors.purple.withOpacity(0.2)
                            : null,
                        side: BorderSide(
                          color: currentTarget == value
                              ? Colors.purple
                              : Colors.grey,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        value.toString(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: currentTarget == value
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const Spacer(),

              // Info box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '💡 How HubListener works:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('• Monitors ALL pipes in the hub'),
                    Text('• listenWhen: checks condition on every change'),
                    Text('• onConditionMet: executes when condition is true'),
                    Text('• Child widget NEVER rebuilds'),
                    Text('• Perfect for: snackbars, dialogs, navigation'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

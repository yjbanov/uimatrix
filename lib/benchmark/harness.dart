import 'dart:async';
import 'package:benchmark_harness/benchmark_harness.dart';

BenchmarkHarness benchmarkHarness = BenchmarkHarness();

typedef GroupFunction = void Function();
typedef SetupFunction = void Function();
typedef ComputeFunction = Object? Function();
typedef PostComputeFunction = void Function(Object?);
typedef TearDownFunction = void Function();

abstract interface class ResultsPrinter {
  void start();
  void groupStart(String name);
  void benchmark(String name, double result);
  void groupEnd();
  void end();
}

final class DefaultResultsPrinter implements ResultsPrinter {
  const DefaultResultsPrinter();

  @override
  void start() {
    print('Running benchmarks');
  }

  @override
  void groupStart(String name) {
    print(name);
  }

  @override
  void benchmark(String name, double result) {
    print('  ✓ ${name}: ${result.toStringAsFixed(2)} μs');
  }

  @override
  void groupEnd() {
  }

  @override
  void end() {
  }
}

final class TsvResultsPrinter implements ResultsPrinter {
  TsvResultsPrinter();

  @override
  void start() {}

  late String _currentGroup;

  @override
  void groupStart(String name) {
    _currentGroup = name;
  }

  @override
  void benchmark(String name, double result) {
    print('${_currentGroup}\t${name}\t${result.toStringAsFixed(2)}');
  }

  @override
  void groupEnd() {}

  @override
  void end() {}
}

final class BenchmarkHarness {
  BenchmarkHarness({ResultsPrinter printer = const DefaultResultsPrinter()}) : _printer = printer;

  final ResultsPrinter _printer;
  final List<_BenchmarkGroup> _groups = <_BenchmarkGroup>[];

  Future<void> run() async {
    _printer.start();
    for (_BenchmarkGroup group in _groups) {
      _printer.groupStart(group.name);
      for (_Benchmark benchmark in group._benchmarks) {
        await Future<void>.delayed(Duration.zero);
        final double measure = benchmark.measure();
        _printer.benchmark(benchmark.name, measure);
      }
      _printer.groupEnd();
    }
    _printer.end();
  }
}

class _BenchmarkGroup {
  _BenchmarkGroup(this.name);

  final String name;

  final List<_Benchmark> _benchmarks = <_Benchmark>[];
}

class _Benchmark extends BenchmarkBase {
  _Benchmark(super.name, this.setupFn, this.compute, this.postCompute, this.tearDownFn);

  final SetupFunction? setupFn;
  final ComputeFunction compute;
  final PostComputeFunction? postCompute;
  final TearDownFunction? tearDownFn;

  @override
  void setup() {
    setupFn?.call();
  }

  @override
  void teardown() {
    tearDownFn?.call();
  }

  @override
  void warmup() {
    for (int i = 0; i < 10; i++) {
      exercise();
    }
  }

  @override
  void exercise() {
    final Object? result = compute();
    postCompute?.call(result);
  }
}

_BenchmarkGroup? _currentGroup;

void group(String name, GroupFunction callback) {
  if (_currentGroup != null) {
    throw StateError('Cannot nest groups. Group ${_currentGroup!.name} is in scope.');
  }

  _currentGroup = _BenchmarkGroup(name);
  benchmarkHarness._groups.add(_currentGroup!);
  callback();
  _currentGroup = null;
}

void benchmark(String name, ComputeFunction callback, { PostComputeFunction? postCompute, SetupFunction? setup, TearDownFunction? tearDown }) {
  if (_currentGroup == null) {
    throw StateError('Dangling benchmark. Benchmark must be defined within a group.');
  }
  _currentGroup!._benchmarks.add(_Benchmark(name, setup, callback, postCompute, tearDown));
}

import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week3_todo/providers/stats_provider.dart';

/// Random palsu: mengembalikan nilai berurutan dari daftar.
/// Nilai < 0.3 berarti "gagal", nilai >= 0.3 berarti "sukses".
class FakeRandom implements Random {
  FakeRandom(this.values);
  final List<double> values;
  int _i = 0;

  @override
  double nextDouble() => values[_i++ % values.length];
  @override
  int nextInt(int max) => 0;
  @override
  bool nextBool() => false;
}

ProviderContainer makeContainer(List<double> randomValues) {
  final container = ProviderContainer(overrides: [
    statsRandomProvider.overrideWithValue(FakeRandom(randomValues)),
    statsDelayProvider.overrideWithValue(Duration.zero),
  ]);
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('sukses: mengembalikan 3 item statistik', () async {
    final container = makeContainer([0.9]);

    final data = await container.read(statsProvider.future);

    expect(data.length, 3);
  });

  test('gagal: state menjadi error saat random < 0.3', () async {
    final container = makeContainer([0.1]);

    await expectLater(
      container.read(statsProvider.future),
      throwsException,
    );
    expect(container.read(statsProvider).hasError, isTrue);
  });

  test('retry: error pertama, lalu pulih menjadi data', () async {
    // Panggilan pertama gagal (0.1), panggilan kedua sukses (0.9).
    final container = makeContainer([0.1, 0.9]);

    await expectLater(
      container.read(statsProvider.future),
      throwsException,
    );

    await container.read(statsProvider.notifier).retry();

    final state = container.read(statsProvider);
    expect(state.hasValue, isTrue);
    expect(state.value!.length, 3);
  });
}
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week8_mid_project_review/data/prefs.dart';
import 'package:week8_mid_project_review/pages/settings_page.dart';

class FakePrefsRepository extends PrefsRepository {
  FakePrefsRepository(this.lastOpened);

  String? lastOpened;
  bool markedOpened = false;

  @override
  Future<String?> getLastOpened() async => lastOpened;

  @override
  Future<void> markOpenedNow() async {
    markedOpened = true;
    lastOpened = DateTime.now().toIso8601String();
  }
}

void main() {
  test(
    'startup returns previous open time before saving current time',
    () async {
      const previousTime = '2026-10-01T12:00:00.000';
      final repository = FakePrefsRepository(previousTime);
      final container = ProviderContainer(
        overrides: [prefsRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      final displayedPreviousTime = await container.read(
        lastOpenedProvider.future,
      );

      expect(displayedPreviousTime, previousTime);
      expect(repository.markedOpened, isTrue);
      expect(DateTime.tryParse(repository.lastOpened!), isNotNull);
      expect(repository.lastOpened, isNot(previousTime));
    },
  );
}

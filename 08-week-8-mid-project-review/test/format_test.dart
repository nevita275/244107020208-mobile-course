import 'package:flutter_test/flutter_test.dart';
import 'package:week8_mid_project_review/core/format.dart';

void main() {
  test('formatDateTime formats local date and time consistently', () {
    final value = DateTime(2026, 9, 27, 8, 5, 3);
    expect(formatDateTime(value), '2026-09-27 08:05:03');
  });

  test('formatStoredDateTime returns null for invalid stored value', () {
    expect(formatStoredDateTime('not a date'), isNull);
  });

  test('parseRouteId reads the id from a matching route', () {
    expect(parseRouteId('/notes/42', resource: 'notes'), 42);
  });

  test('parseRouteId rejects malformed or unrelated routes', () {
    expect(parseRouteId('/posts/42', resource: 'notes'), isNull);
    expect(parseRouteId('/notes/not-an-id', resource: 'notes'), isNull);
    expect(parseRouteId('/notes/42/edit', resource: 'notes'), isNull);
  });
}

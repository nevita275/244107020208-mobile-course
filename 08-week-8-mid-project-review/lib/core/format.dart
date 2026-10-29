String formatDateTime(DateTime value) {
  final local = value.toLocal();
  final year = local.year.toString().padLeft(4, '0');
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  final second = local.second.toString().padLeft(2, '0');
  return '$year-$month-$day $hour:$minute:$second';
}

String? formatStoredDateTime(String value) {
  final parsed = DateTime.tryParse(value);
  return parsed == null ? null : formatDateTime(parsed);
}

int? parseRouteId(String location, {required String resource}) {
  final uri = Uri.tryParse(location);
  if (uri == null) return null;

  final segments = uri.pathSegments;
  if (segments.length != 2 || segments.first != resource) return null;
  return int.tryParse(segments.last);
}

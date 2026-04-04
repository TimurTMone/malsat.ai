String timeAgo(DateTime dateTime, Map<String, dynamic>? dict) {
  final now = DateTime.now();
  final diff = now.difference(dateTime);

  if (diff.inMinutes < 1) {
    return _t(dict, 'common.timeAgo.justNow');
  } else if (diff.inHours < 1) {
    return _t(dict, 'common.timeAgo.minutesAgo', {'count': '${diff.inMinutes}'});
  } else if (diff.inDays < 1) {
    return _t(dict, 'common.timeAgo.hoursAgo', {'count': '${diff.inHours}'});
  } else {
    return _t(dict, 'common.timeAgo.daysAgo', {'count': '${diff.inDays}'});
  }
}

String _t(Map<String, dynamic>? dict, String key, [Map<String, String>? params]) {
  if (dict == null) return key;
  final parts = key.split('.');
  dynamic value = dict;
  for (final part in parts) {
    if (value is Map<String, dynamic> && value.containsKey(part)) {
      value = value[part];
    } else {
      return key;
    }
  }
  var result = value.toString();
  if (params != null) {
    params.forEach((k, v) {
      result = result.replaceAll('{$k}', v);
    });
  }
  return result;
}

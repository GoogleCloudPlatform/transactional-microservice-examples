bool isNumeric(String s) {
  if (s == null) {
    return false;
  }
  try {
    double.parse(s);
  } on FormatException catch (_) {
    return false;
  }
  return true;
}

String normalizeKey(String key) {
  if (key == null) {
    return '';
  }
  key = key.replaceAll(' ', ''); //remove spaces
  return key;
}

String clearText(String text) {
  if (text == null) {
    return '';
  }
  var value = text.replaceAll('\n', ''); //line-breaking spaces
  value = value.replaceAll('\t', ''); //?
  value = value.replaceAll('\xa0', ''); //non-breaking spaces
  return value;
}

String removeNumbers(String text) {
  return text.split('').where((i) => !int.tryParse(i)!.isFinite).join('');
}

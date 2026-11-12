bool isValidSriLankanMobile(String input) {
  final compact = input.replaceAll(RegExp(r'[\s()-]'), '');
  return RegExp(r'^(?:\+?94|0)?7\d{8}$').hasMatch(compact);
}

String normalizeSriLankanMobile(String input) {
  final digits = input.replaceAll(RegExp(r'\D'), '');
  if (digits.startsWith('94') && digits.length == 11) return '+$digits';
  if (digits.startsWith('0') && digits.length == 10) {
    return '+94${digits.substring(1)}';
  }
  if (digits.length == 9 && digits.startsWith('7')) return '+94$digits';
  return input.trim();
}

String formatDisplayPhone(String input) {
  final norm = normalizeSriLankanMobile(input);
  if (norm.startsWith('+94') && norm.length == 12) {
    return '+94 ${norm.substring(3, 5)} ${norm.substring(5, 8)} ${norm.substring(8)}';
  }
  return input;
}

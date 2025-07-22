// lib/helpers/string_extensions.dart

extension StringExtension on String {
  /// Capitalizes the first letter of a string.
  String capitalize() {
    if (isEmpty) {
      return "";
    }
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

class TextConvert {
  // Format currency based on locale
  static String formatCurrency(String value, {required String locale}) {
    String symbol = '\$';

    String formattedValue = double.tryParse(value)?.toStringAsFixed(2) ?? value;
    if (locale == 'pt') {
      symbol = 'R\$';
      formattedValue = formattedValue.replaceAll('.', ',');
    }
    return '$symbol $formattedValue';
  }
}

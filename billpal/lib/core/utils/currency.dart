/// Sehr einfache Euro-Formatierung.
/// Später gern intl/NumberFormat benutzen.
String euro(num value) => '${value.toStringAsFixed(2).replaceAll('.', ',')}€';

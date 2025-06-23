import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

void main() {
  test('La función formatDate retorna la fecha esperada', () {
    final date = DateTime(2025, 5, 29);
    final result = DateFormat('dd/MM/yyyy').format(date);
    expect(result, '29/05/2025');
  });
}

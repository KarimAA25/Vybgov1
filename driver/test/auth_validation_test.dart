import 'package:driver/constant/constant.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Driver auth validation: email and required', () {
    final constant = Constant();

    expect(constant.validateEmail(null), 'Email is Required');
    expect(constant.validateEmail('not-an-email'), 'Invalid Email');
    expect(constant.validateEmail('driver@example.com'), isNull);

    expect(constant.validateRequired('', 'Name'), 'Name required');
    expect(constant.validateRequired('Sam', 'Name'), isNull);
  });
}

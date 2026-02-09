import 'package:admin/app/constant/constants.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Admin auth validation: email and password', () {
    expect(Constant.validateEmail(null), 'Enter valid email');
    expect(Constant.validateEmail('bad-email'), 'Enter valid email');
    expect(Constant.validateEmail('admin@example.com'), isNull);

    expect(Constant.validatePassword(''), 'Current Password is required');
    expect(Constant.validatePassword('12345'), 'Password must be at least 6 characters');
    expect(Constant.validatePassword('123456'), isNull);
  });
}

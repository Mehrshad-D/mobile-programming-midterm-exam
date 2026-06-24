import 'dart:math';

class OtpService {
  OtpService._();

  static final OtpService instance = OtpService._();

  final Random _random = Random.secure();

  String? _currentOtp;
  String? _phoneNumber;

  String generateOtp() {
    final otp = (100000 + _random.nextInt(900000)).toString();
    _currentOtp = otp;
    return otp;
  }

  void setPhoneNumber(String phone) {
    _phoneNumber = phone;
  }

  String? get phoneNumber => _phoneNumber;

  bool verifyOtp(String entered) {
    if (_currentOtp == null) {
      return false;
    }
    return entered.trim() == _currentOtp;
  }

  void clear() {
    _currentOtp = null;
    _phoneNumber = null;
  }
}

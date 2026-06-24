import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../services/auth_service.dart';
import '../services/otp_service.dart';
import '../widgets/secure_screen_mixin.dart';
import 'biometric_screen.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({
    super.key,
    required this.expectedOtp,
  });

  final String expectedOtp;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen>
    with WidgetsBindingObserver, SecureScreenMixin {
  final _otpController = TextEditingController();
  String? _errorMessage;
  bool _isVerifying = false;
  bool _smsDelivered = false;
  SmsAutoFill? _smsAutoFill;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _initSmsAutofill();
    }
  }

  Future<void> _initSmsAutofill() async {
    try {
      _smsAutoFill = SmsAutoFill();
      await _smsAutoFill!.listenForCode();
    } catch (_) {
      // SMS listener may fail on emulators — demo uses simulated SMS card.
    }
  }

  void _simulateSmsDelivery() {
    setState(() => _smsDelivered = true);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('New SMS received — tap the message to autofill'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'View',
          onPressed: () {},
        ),
      ),
    );
  }

  void _autofillFromSms() {
    _otpController.text = widget.expectedOtp;
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('OTP autofilled from SMS'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    if (!kIsWeb) {
      _smsAutoFill?.unregisterListener();
    }
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    final entered = _otpController.text.trim();

    if (entered.length != 6) {
      setState(() {
        _errorMessage = 'Please enter the 6-digit code';
      });
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    await Future<void>.delayed(const Duration(milliseconds: 400));

    if (!OtpService.instance.verifyOtp(entered)) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isVerifying = false;
        _errorMessage = 'Invalid OTP. Please try again.';
      });
      return;
    }

    final phone = OtpService.instance.phoneNumber ?? 'user';
    await AuthService.instance.storeSession(phone);

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const BiometricScreen()),
    );
  }

  Widget _buildOtpInput(ColorScheme colorScheme) {
    if (kIsWeb) {
      return TextFormField(
        controller: _otpController,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 6,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: Theme.of(context).textTheme.headlineSmall,
        decoration: InputDecoration(
          hintText: '000000',
          counterText: '',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onFieldSubmitted: (_) => _verifyOtp(),
        onChanged: (value) {
          if (value.length == 6) {
            _verifyOtp();
          }
        },
      );
    }

    return PinFieldAutoFill(
      controller: _otpController,
      codeLength: 6,
      decoration: BoxLooseDecoration(
        textStyle: Theme.of(context).textTheme.headlineSmall,
        strokeColorBuilder: FixedColorBuilder(colorScheme.primary),
        gapSpace: 10,
        radius: const Radius.circular(12),
      ),
      onCodeSubmitted: (_) => _verifyOtp(),
      onCodeChanged: (code) {
        if (code?.length == 6) {
          _verifyOtp();
        }
      },
    );
  }

  Widget _buildSmsSimulation(ColorScheme colorScheme) {
    if (!_smsDelivered) {
      return OutlinedButton.icon(
        onPressed: _simulateSmsDelivery,
        icon: const Icon(Icons.mark_email_unread_outlined),
        label: const Text('Simulate SMS Delivery'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      );
    }

    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(16),
      color: colorScheme.surfaceContainerHighest,
      child: InkWell(
        onTap: _autofillFromSms,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: colorScheme.primaryContainer,
                child: Icon(
                  Icons.sms_rounded,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Secure Banking',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Text(
                          'now',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Your verification code is ${widget.expectedOtp}. '
                      'Do not share this code.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.touch_app_outlined,
                          size: 16,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Tap to autofill OTP',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final phone = OtpService.instance.phoneNumber ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify OTP'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.sms_outlined,
                size: 56,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Enter Verification Code',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'A 6-digit code was sent to $phone',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 20),
              _buildSmsSimulation(colorScheme),
              const SizedBox(height: 28),
              _buildOtpInput(colorScheme),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: TextStyle(color: colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ],
              const Spacer(),
              FilledButton(
                onPressed: _isVerifying ? null : _verifyOtp,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isVerifying
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Verify'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

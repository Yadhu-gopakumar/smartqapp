import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
// import 'package:smartq/services/booking_services.dart';

class PaymentService {
  late Razorpay _razorpay;
  final Function(String) onSuccess;
  final Function(String) onError;

  PaymentService({required this.onSuccess, required this.onError}) {
    _razorpay = Razorpay();

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    onSuccess(response.paymentId ?? "Unknown");
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    onError(response.message ?? "Payment failed");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint("External Wallet Selected: ${response.walletName}");
  }

  void startPayment(double amount) {
    var options = {
      'key': 'YOUR_RAZORPAY_KEY', // Replace with actual API key
      'amount': (amount * 100).toInt(),
      'name': 'SmartQ',
      'description': 'Order Payment',
      'prefill': {
        'contact': '9876543210',
        'email': 'user@example.com',
      },
      'theme': {'color': '#3399cc'},
    };

    try {
   
      _razorpay.open(options);
    } catch (e) {
      debugPrint("Razorpay Error: $e");
    }
  }

  void dispose() {
    _razorpay.clear();
  }
}

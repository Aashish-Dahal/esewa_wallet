import 'package:esewa_wallet/esewa_wallet.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'eSewa Payment Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const PaymentHomePage(),
    );
  }
}

class PaymentHomePage extends StatelessWidget {
  const PaymentHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final paymentData = PaymentData(
      amount: '100',
      taxAmount: '10',
      totalAmount: '110',
      transactionUuid: UniqueKey().toString(),
      productCode: 'EPAYTEST',
      productServiceCharge: '0',
      productDeliveryCharge: '0',
      successUrl: 'https://developer.esewa.com.np/success',
      failureUrl: 'https://developer.esewa.com.np/failure',
      secretKey: '8gBm/:&EnhH.1/q',
    );
    return Scaffold(
      appBar: AppBar(title: const Text('eSewa Payment Example')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Amount: ${paymentData.amount}'),
            Text('Tax Amount: ${paymentData.taxAmount}'),
            Text('Total Amount: ${paymentData.totalAmount}'),
            Text('Transaction UUID: ${paymentData.transactionUuid}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ESewaPayment.dev(paymentData: paymentData).initiatePayment(
                  context,
                  onSuccess: (url) {
                    debugPrint('Payment Successful: $url');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Payment Successful: $url')),
                    );
                  },
                  onFailure: (url) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Payment Failed: $url')),
                    );
                  },
                );
              },
              child: const Text('Proceed to Payment (Dev)'),
            ),
          ],
        ),
      ),
    );
  }
}

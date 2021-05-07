import 'dart:async';

import 'package:flutter/material.dart';
import 'package:simple_flutter_apple_pay/simple_flutter_apple_pay.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> makeSuccessPayment() async {
    PaymentResultData result;
    PaymentItem paymentItems =
        PaymentItem(label: 'Label', amount: 51.0, isFinal: true);
    try {
      result = await FlutterApplePay.startPayment(
        countryCode: "CZ",
        currencyCode: "CZK",
        // payment network doesn't work yet
        // paymentNetworks: [PaymentNetwork.visa, PaymentNetwork.mastercard],
        merchantIdentifier: "merchant.example.mcc.cz",
        paymentItems: [paymentItems],
      );
      print(result);

      // Make api request
      // CODE

      // Handle api result and close payment sheet
      Future.delayed(Duration(seconds: 5),
          () => FlutterApplePay.finishPayment(result: PaymentResult.success));
    } on Exception {
      // Exception thrown OS isn't iOS
    }
  }

  Future<void> makeErrorPayment() async {
    PaymentResultData result;
    PaymentItem paymentItems =
        PaymentItem(label: 'Label', amount: 51.0, isFinal: true);
    try {
      result = await FlutterApplePay.startPayment(
        countryCode: "CZ",
        currencyCode: "CZK",
        // payment network doesn't work yet
        // paymentNetworks: [PaymentNetwork.visa, PaymentNetwork.mastercard],
        merchantIdentifier: "merchant.example.mcc.cz",
        paymentItems: [paymentItems],
      );
      print(result);

      // Make api request
      // CODE

      // Handle api result and close payment sheet
      Future.delayed(Duration(seconds: 5),
          () => FlutterApplePay.finishPayment(result: PaymentResult.error));
    } on Exception {
      // Exception thrown OS isn't iOS
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Apple Pay Test'),
        ),
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Apple pay example.'),
            ElevatedButton(
              child: Text('Success payment'),
              onPressed: () => makeSuccessPayment(),
            ),
            ElevatedButton(
              child: Text('Error payment'),
              onPressed: () => makeErrorPayment(),
            )
          ],
        )),
      ),
    );
  }
}

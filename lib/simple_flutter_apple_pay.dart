import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class FlutterApplePay {
  static const MethodChannel _channel =
      const MethodChannel('simple_flutter_apple_pay');

  static Future<PaymentResultData> startPayment({
    @required String countryCode,
    @required String currencyCode,
    // @required List<PaymentNetwork> paymentNetworks,
    List<PaymentNetwork> paymentNetworks = const [],
    @required String merchantIdentifier,
    bool isPending = false,
    @required List<PaymentItem> paymentItems,
  }) async {
    assert(countryCode != null);
    assert(currencyCode != null);
    assert(paymentItems != null);
    assert(merchantIdentifier != null);
    assert(paymentItems != null);

    final Map<String, Object> args = <String, dynamic>{
      'paymentNetworks':
          paymentNetworks.map((item) => item.toString().split('.')[1]).toList(),
      'countryCode': countryCode,
      'currencyCode': currencyCode,
      'paymentItems':
          paymentItems.map((PaymentItem item) => item._toMap()).toList(),
      'merchantIdentifier': merchantIdentifier,
    };
    if (Platform.isIOS) {
      final dynamic result = await _channel.invokeMethod('startPayment', args);
      return PaymentResultData(result);
    } else {
      throw Exception("Not supported operation system");
    }
  }

  static Future<void> finishPayment({@required PaymentResult result}) async {
    if (result == PaymentResult.success) {
      await _channel.invokeMethod('closeWithSuccess');
    } else {
      await _channel.invokeMethod('closeWithError');
    }
  }
}

class PaymentResultData {
  String error;
  bool isSuccess;
  PaymentSuccessResultData resultData;

  PaymentResultData(dynamic result) {
    Map<String, dynamic> resultJson = Map<String, dynamic>.from(result);
    if (resultJson['error'] != null) {
      if (resultJson['error'].runtimeType == String) {
        error = resultJson['error'];
      } else {
        error = resultJson['error']['message'];
      }
      isSuccess = false;
    } else {
      isSuccess = true;
      resultData = PaymentSuccessResultData(
          paymentData: resultJson['data']['paymentData'],
          transactionIdentifier: resultJson['data']['transactionIdentifier']);
    }
  }

  @override
  String toString() {
    return 'PaymentResult{error: $error, isSuccess: $isSuccess, resultData: $resultData}';
  }
}

class PaymentSuccessResultData {
  String paymentData;
  String transactionIdentifier;

  PaymentSuccessResultData(
      {@required this.paymentData, @required this.transactionIdentifier});

  @override
  String toString() {
    return 'PaymentResultData{paymentData: $paymentData, transactionIdentifier: $transactionIdentifier}';
  }
}

class PaymentItem {
  final String label;
  final double amount;
  final bool isFinal;

  PaymentItem(
      {@required this.label, @required this.amount, @required this.isFinal}) {
    assert(this.label != null);
    assert(this.amount != null);
    assert(this.isFinal != null);
  }

  Map<String, dynamic> _toMap() {
    Map<String, dynamic> map = new Map();
    map["label"] = this.label;
    map["amount"] = this.amount;
    map["isFinal"] = this.isFinal;
    return map;
  }
}

enum PaymentResult {
  success,
  error,
}

enum PaymentNetwork {
  visa,
  mastercard,
  amex,
  quicPay,
  chinaUnionPay,
  discover,
  interac,
  privateLabel
}

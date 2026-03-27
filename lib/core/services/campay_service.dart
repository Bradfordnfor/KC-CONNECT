import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class CampayService {
  static String get _baseUrl =>
      dotenv.env['CAMPAY_BASE_URL'] ?? 'https://demo.campay.net/api';
  static String get _token => dotenv.env['CAMPAY_TOKEN'] ?? '';

  static Map<String, String> get _headers => {
        'Authorization': 'Token $_token',
        'Content-Type': 'application/json',
      };

  /// Normalises any common Cameroonian phone format to `237XXXXXXXXX`.
  static String formatPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.startsWith('237')) return digits;
    if (digits.startsWith('0')) return '237${digits.substring(1)}';
    return '237$digits';
  }

  /// Initiates a mobile money collection request.
  /// Returns the Campay transaction reference on success, or `null` on failure.
  static Future<String?> initiatePayment({
    required String phone,
    required int amount,
    required String description,
    required String externalRef,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/collect/'),
            headers: _headers,
            body: jsonEncode({
              'amount': amount.toString(),
              'currency': 'XAF',
              'from': formatPhone(phone),
              'description': description,
              'external_reference': externalRef,
            }),
          )
          .timeout(const Duration(seconds: 30));

      debugPrint('Campay initiate [${response.statusCode}]: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['reference'] as String?;
      }
      return null;
    } catch (e) {
      debugPrint('CampayService.initiatePayment error: $e');
      return null;
    }
  }

  /// Checks the status of a transaction by its reference.
  /// Returns `'SUCCESSFUL'`, `'FAILED'`, or `'PENDING'`.
  static Future<String> checkStatus(String reference) async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/transaction/$reference/'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 15));

      debugPrint('Campay status [${response.statusCode}]: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return (data['status'] as String?) ?? 'PENDING';
      }
      return 'FAILED';
    } catch (e) {
      debugPrint('CampayService.checkStatus error: $e');
      return 'FAILED';
    }
  }
}

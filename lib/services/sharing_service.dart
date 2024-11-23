// lib/services/sharing_service.dart
import 'package:share_plus/share_plus.dart';
import 'dart:io';

class SharingService {
  static Future<void> shareViaWhatsApp(File pdfFile, String phoneNumber) async {
    try {
      await Share.shareXFiles(
        [XFile(pdfFile.path)],
        text: 'Please find the invoice attached',
      );
    } catch (e) {
      throw 'Could not share via WhatsApp: $e';
    }
  }

  static Future<void> shareViaEmail(
    File pdfFile,
    String emailAddress,
    String clientName,
    String invoiceNumber,
  ) async {
    try {
      final String body = 'Dear $clientName,\n\nPlease find attached the invoice $invoiceNumber.\n\nThank you for your business.';
      
      // Use Share.shareXFiles for better compatibility
      await Share.shareXFiles(
        [XFile(pdfFile.path)],
        text: body,
        subject: 'Invoice $invoiceNumber',
      );
    } catch (e) {
      throw 'Could not share via email: $e';
    }
  }
}
// lib/utils/pdf_generator.dart
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/invoice_model.dart';

class PdfGenerator {
  static Future<File> generateInvoice(InvoiceModel invoice) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          _buildHeader(invoice),
          pw.SizedBox(height: 20),
          _buildInvoiceInfo(invoice),
          pw.SizedBox(height: 20),
          _buildItemsTable(invoice),
          pw.SizedBox(height: 20),
          _buildTotal(invoice),
          if (invoice.notes.isNotEmpty) ...[
            pw.SizedBox(height: 20),
            _buildNotes(invoice),
          ],
        ],
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/invoice_${invoice.invoiceNumber}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static pw.Widget _buildHeader(InvoiceModel invoice) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'INVOICE',
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Divider(),
      ],
    );
  }

  static pw.Widget _buildInvoiceInfo(InvoiceModel invoice) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Bill To:'),
            pw.Text(invoice.clientName),
            pw.Text(invoice.clientEmail),
            pw.Text(invoice.clientPhone),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text('Invoice #: ${invoice.invoiceNumber}'),
            pw.Text('Date: ${invoice.date.toString().split(' ')[0]}'),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildItemsTable(InvoiceModel invoice) {
    return pw.Table.fromTextArray(
      border: null,
      headers: ['Description', 'Quantity', 'Unit Price', 'Total'],
      data: invoice.items.map((item) => [
        item.description,
        item.quantity.toString(),
        '\$${item.unitPrice.toStringAsFixed(2)}',
        '\$${item.total.toStringAsFixed(2)}',
      ]).toList(),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      headerDecoration: pw.BoxDecoration(
        borderRadius: pw.BorderRadius.circular(2),
        color: PdfColors.grey300,
      ),
      cellAlignment: pw.Alignment.center,
      cellAlignments: {0: pw.Alignment.centerLeft},
    );
  }

  static pw.Widget _buildTotal(InvoiceModel invoice) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        children: [
          pw.Text(
            'Total Amount: ',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Text(
            '\$${invoice.totalAmount.toStringAsFixed(2)}',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildNotes(InvoiceModel invoice) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Notes:',
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          invoice.notes,
          style: const pw.TextStyle(
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
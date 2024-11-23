// lib/models/invoice_model.dart
import 'package:uuid/uuid.dart';

class InvoiceModel {
  final String id;
  final String invoiceNumber;
  final DateTime date;
  final String clientName;
  final String clientEmail;
  final String clientPhone;
  final List<InvoiceItem> items;
  final String notes;
  final double totalAmount;
  final String status; // 'draft', 'sent', 'paid'

  InvoiceModel({
    String? id,
    required this.invoiceNumber,
    required this.date,
    required this.clientName,
    required this.clientEmail,
    required this.clientPhone,
    required this.items,
    this.notes = '',
    this.status = 'draft',
  })  : id = id ?? const Uuid().v4(),
        totalAmount = items.fold(0, (sum, item) => sum + item.total);

  Map<String, dynamic> toJson() => {
        'id': id,
        'invoiceNumber': invoiceNumber,
        'date': date.toIso8601String(),
        'clientName': clientName,
        'clientEmail': clientEmail,
        'clientPhone': clientPhone,
        'items': items.map((item) => item.toJson()).toList(),
        'notes': notes,
        'totalAmount': totalAmount,
        'status': status,
      };

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['id'],
      invoiceNumber: json['invoiceNumber'],
      date: DateTime.parse(json['date']),
      clientName: json['clientName'],
      clientEmail: json['clientEmail'],
      clientPhone: json['clientPhone'],
      items: (json['items'] as List)
          .map((item) => InvoiceItem.fromJson(item))
          .toList(),
      notes: json['notes'],
      status: json['status'] ?? 'draft',
    );
  }
}

class InvoiceItem {
  final String description;
  final int quantity;
  final double unitPrice;
  final double total;

  InvoiceItem({
    required this.description,
    required this.quantity,
    required this.unitPrice,
  }) : total = quantity * unitPrice;

  Map<String, dynamic> toJson() => {
        'description': description,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'total': total,
      };

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      description: json['description'],
      quantity: json['quantity'],
      unitPrice: json['unitPrice'].toDouble(),
    );
  }
}
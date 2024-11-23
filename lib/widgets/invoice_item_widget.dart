import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/invoice_model.dart';

class InvoiceItemWidget extends StatefulWidget {
  final InvoiceItem item;
  final Function onDelete;
  final Function(InvoiceItem)? onItemChanged;

  const InvoiceItemWidget({
    super.key,
    required this.item,
    required this.onDelete,
    this.onItemChanged,
  });

  @override
  State<InvoiceItemWidget> createState() => _InvoiceItemWidgetState();
}

class _InvoiceItemWidgetState extends State<InvoiceItemWidget> {
  late TextEditingController descriptionController;
  late TextEditingController quantityController;
  late TextEditingController unitPriceController;

  @override
  void initState() {
    super.initState();
    descriptionController = TextEditingController(text: widget.item.description);
    quantityController = TextEditingController(text: widget.item.quantity.toString());
    unitPriceController = TextEditingController(text: widget.item.unitPrice.toString());

    // Add listeners to update the item when values change
    descriptionController.addListener(_updateItem);
    quantityController.addListener(_updateItem);
    unitPriceController.addListener(_updateItem);
  }

  void _updateItem() {
    final quantity = int.tryParse(quantityController.text) ?? 0;
    final unitPrice = double.tryParse(unitPriceController.text) ?? 0.0;

    final updatedItem = InvoiceItem(
      description: descriptionController.text,
      quantity: quantity,
      unitPrice: unitPrice,
    );

    widget.onItemChanged?.call(updatedItem);
  }

  @override
  void dispose() {
    descriptionController.dispose();
    quantityController.dispose();
    unitPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Item Details',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => widget.onDelete(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter item description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: unitPriceController,
                    decoration: const InputDecoration(
                      labelText: 'Unit Price',
                      border: OutlineInputBorder(),
                      prefixText: '\$',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Total: \$${(widget.item.quantity * widget.item.unitPrice).toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// lib/screens/invoice_form_screen.dart

import 'package:flutter/material.dart';
import '../models/invoice_model.dart';
import '../widgets/invoice_item_widget.dart';
import '../utils/pdf_generator.dart';
import '../services/sharing_service.dart';
import '../widgets/custom_text_field.dart';

class InvoiceFormScreen extends StatefulWidget {
  const InvoiceFormScreen({super.key});

  @override
  InvoiceFormScreenState createState() => InvoiceFormScreenState();
}

class InvoiceFormScreenState extends State<InvoiceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<InvoiceItem> _items = [];
  bool _isLoading = false;
  
  final _clientNameController = TextEditingController();
  final _clientEmailController = TextEditingController();
  final _clientPhoneController = TextEditingController();
  final _notesController = TextEditingController();
  
  double get _totalAmount => _items.fold(0, (sum, item) => sum + item.total);

  @override
  void dispose() {
    _clientNameController.dispose();
    _clientEmailController.dispose();
    _clientPhoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _generateAndShareInvoice(String method) async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one item to the invoice')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final invoice = InvoiceModel(
        invoiceNumber: 'INV-${DateTime.now().millisecondsSinceEpoch}',
        date: DateTime.now(),
        clientName: _clientNameController.text,
        clientEmail: _clientEmailController.text,
        clientPhone: _clientPhoneController.text,
        items: _items,
        notes: _notesController.text,
      );

      final pdfFile = await PdfGenerator.generateInvoice(invoice);

      if (method == 'whatsapp') {
        await SharingService.shareViaWhatsApp(
          pdfFile,
          _clientPhoneController.text,
        );
      } else {
        await SharingService.shareViaEmail(
          pdfFile,
          _clientEmailController.text,
          _clientNameController.text,
          invoice.invoiceNumber,
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invoice shared successfully')),
      );

      // Optionally clear the form after successful sending
      _clearForm();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sharing invoice: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _clearForm() {
    setState(() {
      _clientNameController.clear();
      _clientEmailController.clear();
      _clientPhoneController.clear();
      _notesController.clear();
      _items.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Invoice'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _clearForm,
          ),
        ],
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildClientInformationCard(),
                const SizedBox(height: 16),
                _buildInvoiceItemsCard(),
                const SizedBox(height: 16),
                _buildNotesCard(),
                const SizedBox(height: 16),
                _buildTotalAmountCard(),
                const SizedBox(height: 24),
                _buildShareButtons(),
                const SizedBox(height: 32),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black45,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildClientInformationCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person_outline),
                const SizedBox(width: 8),
                Text(
                  'Client Information',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _clientNameController,
              label: 'Client Name',
              prefixIcon: Icons.person,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter client name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _clientEmailController,
              label: 'Client Email',
              prefixIcon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter client email';
                }
                if (!value!.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _clientPhoneController,
              label: 'Client Phone',
              prefixIcon: Icons.phone,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter client phone';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceItemsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.shopping_cart_outlined),
                    const SizedBox(width: 8),
                    Text(
                      'Invoice Items',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _items.add(InvoiceItem(
                        description: '',
                        quantity: 1,
                        unitPrice: 0,
                      ));
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Item'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_items.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No items added yet. Click "Add Item" to start.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ..._items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return InvoiceItemWidget(
                key: ValueKey('item_$index'),
                item: item,
                onDelete: () {
                  setState(() => _items.removeAt(index));
                },
                onItemChanged: (updatedItem) {
                  setState(() => _items[index] = updatedItem);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.note_outlined),
                const SizedBox(width: 8),
                Text(
                  'Notes',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _notesController,
              label: 'Additional Notes',
              maxLines: 3,
              prefixIcon: Icons.note,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalAmountCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total Amount:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              '\$${_totalAmount.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : () => _generateAndShareInvoice('whatsapp'),
            icon: const Icon(Icons.phone_android),
            label: const Text('Send via WhatsApp'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF25D366),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // not need for now
        // Expanded(
        //   child: ElevatedButton.icon(
        //     onPressed: _isLoading ? null : () => _generateAndShareInvoice('email'),
        //     icon: const Icon(Icons.email),
        //     label: const Text('Send via Email'),
        //     style: ElevatedButton.styleFrom(
        //       padding: const EdgeInsets.symmetric(vertical: 16),
        //     ),
        //   ),
        // ),
      ],
    );
  }
}
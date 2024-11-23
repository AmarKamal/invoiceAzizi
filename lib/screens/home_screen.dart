// lib/screens/home_screen.dart
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Azizi Online Invoice'),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.history),
        //     onPressed: () => Navigator.pushNamed(context, '/invoice-history'),
        //   ),
        // ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome to Azizi Online Invoice',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create and send professional invoices easily',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),
              _buildQuickActionCard(
                context,
                title: 'Create New Invoice',
                description: 'Generate a new invoice and send it via WhatsApp or Email',
                icon: Icons.add_circle_outline,
                onTap: () => Navigator.pushNamed(context, '/create-invoice'),
              ),
              const SizedBox(height: 16),
              // _buildQuickActionCard(
              //   context,
              //   title: 'View History',
              //   description: 'Access your previously created invoices',
              //   icon: Icons.history,
              //   onTap: () => Navigator.pushNamed(context, '/invoice-history'),
              // ),
              const SizedBox(height: 32),
              // Text(
              //   'Recent Invoices',
              //   style: Theme.of(context).textTheme.titleLarge,
              // ),
              // not need for now
              // Expanded(
              //   child: _buildRecentInvoicesList(),
              // ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/create-invoice'),
        label: const Text('New Invoice'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                icon,
                size: 32,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentInvoicesList() {
    return ListView.builder(
      itemCount: 0, // You'll need to implement this with actual data
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            title: const Text('Invoice #123'),
            subtitle: const Text('Client Name'),
            trailing: const Text('\$000.00'),
            onTap: () {
              // Handle invoice tap
            },
          ),
        );
      },
    );
  }
}
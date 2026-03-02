import 'package:flutter/material.dart';
import '../models/invoice.dart';
import '../models/invoice_group.dart';
import '../services/api_service.dart';
import 'signature_screen.dart';

class GroupDetailScreen extends StatefulWidget {
  final InvoiceGroup group;
  const GroupDetailScreen({super.key, required this.group});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  GroupDetail? _detail;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final detail =
          await ApiService.instance.getGroupDetail(widget.group.customerVisitGroup);
      setState(() => _detail = detail);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Could not load invoice details.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openSignature() async {
    if (_detail == null) return;
    final signed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => SignatureScreen(group: _detail!),
      ),
    );
    if (signed == true) {
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          widget.group.customerName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _ErrorSection(message: _error!, onRetry: _load)
              : _DetailBody(
                  detail: _detail!,
                  onSign: _openSignature,
                ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  final GroupDetail detail;
  final VoidCallback onSign;

  const _DetailBody({required this.detail, required this.onSign});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final delivered = detail.allAcknowledged;

    return Column(
      children: [
        // Header card
        Container(
          color: theme.colorScheme.primaryContainer,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (detail.routeDisplay != null)
                      Text(
                        detail.routeDisplay!,
                        style: TextStyle(
                          color: theme.colorScheme.onPrimaryContainer
                              .withValues(alpha: 0.7),
                          fontSize: 13,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      '${detail.invoiceCount} invoice${detail.invoiceCount != 1 ? 's' : ''}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${detail.totalAmount.toStringAsFixed(2)}',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _StatusBadge(delivered: delivered),
                ],
              ),
            ],
          ),
        ),

        // Invoice list
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: detail.invoices.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (_, i) => _InvoiceRow(invoice: detail.invoices[i]),
          ),
        ),

        // Sign button
        if (!delivered)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: FilledButton.icon(
                onPressed: onSign,
                icon: const Icon(Icons.draw_outlined),
                label: const Text(
                  'Sign & Submit',
                  style: TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w600),
                ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ),

        if (delivered)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.green.shade300),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle,
                        color: Colors.green.shade700, size: 24),
                    const SizedBox(width: 10),
                    Text(
                      'Signed & Delivered',
                      style: TextStyle(
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _InvoiceRow extends StatelessWidget {
  final Invoice invoice;
  const _InvoiceRow({required this.invoice});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: invoice.isDelivered
                  ? Colors.green.shade50
                  : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              invoice.isDelivered
                  ? Icons.check_circle_outline
                  : Icons.receipt_long_outlined,
              color: invoice.isDelivered
                  ? Colors.green.shade600
                  : Colors.orange.shade600,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              invoice.invoiceNumber,
              style: theme.textTheme.bodyLarge
                  ?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            '₹${invoice.amount.toStringAsFixed(2)}',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool delivered;
  const _StatusBadge({required this.delivered});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: delivered ? Colors.green.shade600 : Colors.orange.shade600,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        delivered ? 'DELIVERED' : 'PENDING',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _ErrorSection extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorSection({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 52, color: Colors.red.shade400),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

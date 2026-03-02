// Matches the backend InvoiceInfo schema returned by /customer-group/{group_id}
class Invoice {
  final String id;
  final String invoiceNumber;
  final String customerName;
  final double amount;
  final String? invoiceDate;
  final String status;
  final String branch;
  final bool isAcknowledged;
  final int? routeNumber;
  final String? routeName;
  final String? routeDisplay;

  Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.customerName,
    required this.amount,
    this.invoiceDate,
    required this.status,
    required this.branch,
    required this.isAcknowledged,
    this.routeNumber,
    this.routeName,
    this.routeDisplay,
  });

  bool get isDelivered => status == 'delivered' || isAcknowledged;

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id']?.toString() ?? '',
      invoiceNumber: json['invoice_number'] as String? ?? '',
      customerName: json['customer_name'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      invoiceDate: json['invoice_date'] as String?,
      status: json['status'] as String? ?? 'pending',
      branch: json['branch'] as String? ?? '',
      isAcknowledged: json['is_acknowledged'] as bool? ?? false,
      routeNumber: json['route_number'] as int?,
      routeName: json['route_name'] as String?,
      routeDisplay: json['route_display'] as String?,
    );
  }
}

import 'invoice.dart';

class InvoiceGroup {
  final String customerVisitGroup;
  final String customerName;
  final String? shopAddress;
  final int? routeNumber;
  final String? routeName;
  final String? routeDisplay;
  final int invoiceCount;
  final double totalAmount;
  final String status;
  final int? firstInvoiceId;
  final List<String> invoiceNumbers;
  final String? branch;

  InvoiceGroup({
    required this.customerVisitGroup,
    required this.customerName,
    this.shopAddress,
    this.routeNumber,
    this.routeName,
    this.routeDisplay,
    required this.invoiceCount,
    required this.totalAmount,
    required this.status,
    this.firstInvoiceId,
    required this.invoiceNumbers,
    this.branch,
  });

  bool get isDelivered => status == 'delivered';

  factory InvoiceGroup.fromJson(Map<String, dynamic> json) {
    return InvoiceGroup(
      customerVisitGroup: json['customer_visit_group'] as String? ?? '',
      customerName: json['customer_name'] as String? ?? '',
      shopAddress: json['shop_address'] as String?,
      routeNumber: json['route_number'] as int?,
      routeName: json['route_name'] as String?,
      routeDisplay: json['route_display'] as String?,
      invoiceCount: json['invoice_count'] as int? ?? 0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'pending',
      firstInvoiceId: json['first_invoice_id'] as int?,
      invoiceNumbers: (json['invoice_numbers'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      branch: json['branch'] as String?,
    );
  }
}

class GroupDetail {
  final String customerVisitGroup;
  final String customerName;
  final int? routeNumber;
  final String? routeName;
  final String? routeDisplay;
  final List<Invoice> invoices;
  final double totalAmount;
  final int invoiceCount;
  final bool allAcknowledged;
  final String? branch;

  GroupDetail({
    required this.customerVisitGroup,
    required this.customerName,
    this.routeNumber,
    this.routeName,
    this.routeDisplay,
    required this.invoices,
    required this.totalAmount,
    required this.invoiceCount,
    required this.allAcknowledged,
    this.branch,
  });

  factory GroupDetail.fromJson(Map<String, dynamic> json) {
    return GroupDetail(
      customerVisitGroup: json['customer_visit_group'] as String? ?? '',
      customerName: json['customer_name'] as String? ?? '',
      routeNumber: json['route_number'] as int?,
      routeName: json['route_name'] as String?,
      routeDisplay: json['route_display'] as String?,
      invoices: (json['invoices'] as List<dynamic>?)
              ?.map((e) => Invoice.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      invoiceCount: json['invoice_count'] as int? ?? 0,
      allAcknowledged: json['all_acknowledged'] as bool? ?? false,
      branch: json['branch'] as String?,
    );
  }
}

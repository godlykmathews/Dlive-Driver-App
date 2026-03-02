class RouteInfo {
  final int routeNumber;
  final String? routeName;
  final String routeDisplay;
  final int invoiceCount;
  final String createdDate;

  RouteInfo({
    required this.routeNumber,
    this.routeName,
    required this.routeDisplay,
    required this.invoiceCount,
    required this.createdDate,
  });

  factory RouteInfo.fromJson(Map<String, dynamic> json) {
    return RouteInfo(
      routeNumber: json['route_number'] as int,
      routeName: json['route_name'] as String?,
      routeDisplay: json['route_display'] as String? ?? 'Route ${json['route_number']}',
      invoiceCount: json['invoice_count'] as int? ?? 0,
      createdDate: json['created_date'] as String? ?? '',
    );
  }
}
